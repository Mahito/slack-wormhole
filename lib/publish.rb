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
        end
      end

      rtm.on :reaction_added do |data|
        post_reaction(data)
      end

      rtm.on :reaction_removed do |data|
        remove_reaction(data)
      end

      rtm.on :closed do |data|
        rtm_start!
      end

      rtm_start!
    end

    def self.post_message(data)
      if user = user(data.user)
        username = user.profile.display_name ||
          user.profile.real_name ||
          user.name
        icon = user.profile.image_192

        payload = {
          action: 'post',
          timestamp: data.ts,
          room: channel(data.channel).name,
          username: username,
          icon_url: icon,
          text: data.text,
        }

        publish(payload)
      end
    end

    def self.post_files(data)
      payload = {
        channel: data.channel,
        text: 'ファイル転送はまだてきてません。PR待ってます☆ミ',
        as_user: false
      }
      web.chat_postMessage(payload)
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
        username = user.profile.display_name ||
          user.profile.real_name ||
          user.name
        icon = user.profile.image_192

        payload = {
          action: 'reaction_add',
          timestamp: data.ts,
          thread_ts: data.item.ts,
          room: channel(data.item.channel).name,
          username: username,
          icon_url: icon,
          text: ":#{data.reaction}:",
        }

        publish(payload)
      end
    end

    def self.remove_reaction(data)
      user = user(data.user)
      username = user.profile.display_name ||
        user.profile.real_name ||
        user.name
      payload = {
        action: 'reaction_remove',
        room: channel(data.item.channel).name,
        username: username,
        timestamp: data.item.ts,
      }

      publish(payload)
    end

    def self.post_reply(data)
      user = user(data.user)
      username = user.profile.display_name ||
        user.profile.real_name ||
        user.name

      icon = user.profile.image_192

      payload = {
        action: 'post_reply',
        thread_ts: data.thread_ts,
        timestamp: data.ts,
        room: channel(data.channel).name,
        username: username,
        icon_url: icon,
        text: data.text,
      }

      q = query.where('timestamp', '=', data.thread_ts).limit(1)
      datastore.run(q).each do |task|
        payload[:thread_ts] = task['originalTs']
      end

      publish(payload)
    end

    def self.publish(payload)
      topic.publish(payload)
    end

    private
    def self.rtm_start!
      rtm.stop! if rtm.started?
      sleep(1)
      begin
        thread = rtm.start_async
        thread.join
      rescue Errno::EPIPE => e
        logger.error(e)
        rtm_start!
      end
    end
  end
end
