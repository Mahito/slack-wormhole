require_relative  'utils'

module SlackWormhole
  module Publish
    def self.start
      rtm.on :message do |data|
        case data.subtype
        when nil
          if data.files
            post_files(data)
          elsif data.thread_ts
            post_reply(data)
          else
            post_message(data)
          end
        when 'bot_message'
        when 'message_changed'
          edit_message(data)
        when 'message_deleted'
          delete_message(data)
        when 'channel_join', 'channel_leave'
          if user = user(data.user)
            name = username(user)
            data.text.sub!(/<.+>/, name)
            data.user = nil
          end
          post_message(data)
        when 'thread_broadcast'
          if data.bot_id.nil?
            data.reply_broadcast = true
            post_reply(data)
          end
        end
      end

      rtm.on :reaction_added do |data|
        post_reaction(data)
      end

      rtm.on :reaction_removed do |data|
        remove_reaction(data)
      end

      rtm.on :close do |data|
        logger.info('Received a close event from Slack')
        rtm_start!
      end

      rtm.on :closed do |data|
        logger.info('RTM connection has been closed')
        rtm_start!
      end

      rtm_start!
    end

    def self.post_message(data)
      if user = user(data.user)
        name = username(user)
        icon = user.profile.image_192
      end

      payload = {
        action: 'post',
        timestamp: data.ts,
        room: channel(data.channel).name,
        username: name,
        icon_url: icon,
        text: data.text,
      }

      publish(payload)
    end

    def self.post_files(data)
      data['files'].each do |f|
        payload = {
          file: f['id']
        }

        res = web.files_sharedPublicURL(payload)
        data.text += "\n" + res['file']['permalink_public']
      end
      post_message(data)
    end

    def self.edit_message(data)
      if user = user(data.message.user)
        payload = {
          action: 'update',
          room: channel(data.channel).name,
          timestamp: data.message.ts,
          text: data.message.text,
        }

        publish(payload)
      end
    end

    def self.delete_message(data)
      payload = {
        room: channel(data.channel).name,
        action: 'delete',
        timestamp: data.deleted_ts,
      }

      publish(payload)
    end

    def self.post_reaction(data)
      if user = user(data.user)
        name = username(user)
        icon = user.profile.image_192

        payload = {
          action: 'reaction_add',
          timestamp: data.ts,
          thread_ts: data.item.ts,
          room: channel(data.item.channel).name,
          userid: data.user,
          username: name,
          icon_url: icon,
          reaction: data.reaction,
        }

        q = query.where('timestamp', '=', payload[:thread_ts]).limit(1)
        datastore.run(q).each do |task|
          payload[:thread_ts] = task['originalTs']
        end

        publish(payload)
      end
    end

    def self.remove_reaction(data)
      user = user(data.user)
      name = username(user)
      payload = {
        action: 'reaction_remove',
        room: channel(data.item.channel).name,
        userid: data.user,
        username: name,
        reaction: data.reaction,
        timestamp: data.item.ts,
      }

      publish(payload)
    end

    def self.post_reply(data)
      if user = user(data.user)
        name = username(user)
        icon = user.profile.image_192
      end

      payload = {
        action: 'post_reply',
        thread_ts: data.thread_ts,
        timestamp: data.ts,
        room: channel(data.channel).name,
        username: name,
        icon_url: icon,
        text: data.text,
        reply_broadcast: data.reply_broadcast,
      }

      q = query.where('timestamp', '=', data.thread_ts).limit(1)
      datastore.run(q).each do |task|
        payload[:thread_ts] = task['originalTs']
      end

      publish(payload)
    end

    def self.publish(payload)
      begin
        replace_username(payload) if payload[:text]
        json = JSON.dump(payload)
        data = Base64.strict_encode64(json)
        topic.publish(data)
        logger.info("Message has been published - Action[#{payload[:action]}]")
      rescue Google::Cloud::InvalidArgumentError => e
        logger.error(e)
        error_payload = {
          channel: payload[:room],
          text: 'Error - ' + e.message,
          as_user: false
        }
        web.chat_postMessage(error_payload)
      rescue => e
        logger.error(e)
        sleep 5
        retry
      end
    end

    def self.replace_username(payload)
      text = payload[:text]
      while match = text[/<@([UW].*?)>/, 1]
        text.sub!('<@'+match+'>', '@' + username(user(match)))
      end
      payload[:text] = text
    end

    private
    def self.rtm_start!
      rtm.start!
    rescue Interrupt => e
      logger.error(e)
      raise Interrupt
    rescue Exception => e
      logger.error(e)
      sleep 5
      retry
    end
  end
end
