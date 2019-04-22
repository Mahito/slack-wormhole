require_relative  'utils'

module SlackWormhole
  module Subscribe
    def self.start
      subscription_names = ENV['WORMHOLE_SUBSCRIPTION_NAMES']
      subscription_names.split(',').each do |name|
        subscribe(name)
      end
    end

    def self.subscribe(subscription_name)
      subscription = pubsub.subscription(subscription_name)
      subscriber = subscription.listen do |received_message|
        received_message.acknowledge!
        data =  received_message.grpc.message.attributes

        unless allowed_channel?(data['room'])
          logger.info("\"#{data['room']}\" is not allowed to receive channel !")
          return nil
        end

        case data['action']
        when 'post'
          payload = {
            channel: data['room'],
            username: data['username'],
            icon_url: data['icon_url'],
            text: data['text'],
            as_user: false,
          }
          message = post_message(payload)
          save_message(subscription_name, message, data['timestamp'])
        when 'update'
          q = query.where('originalTs', '=', data['timestamp']).limit(1)
          datastore.run(q).each do |task|
            payload = {
              channel: task['channelID'],
              text: data['text'],
              ts: task['timestamp']
            }
            edit_message(payload)
          end
        when 'delete'
          q = query.where('originalTs', '=', data['timestamp']).limit(1)
          datastore.run(q).each do |task|
            payload = {
              channel: task['channelID'],
              ts: task['timestamp']
            }
            delete_message(payload)
            datastore.delete(task)
          end
        when 'reaction_add'
          add_reaction(subscription_name, data)
        when 'reaction_remove'
          remove_reaction(data)
        when 'post_reply'
          payload = {
            channel: data['room'],
            thread_ts: data['thread_ts'],
            text: data['text'],
            username: data['username'],
            icon_url: data['icon_url'],
            as_user: false,
            reply_broadcast: data['reply_broadcast']
          }

          q = query.where('originalTs', '=', data['thread_ts']).limit(1)
          datastore.run(q).each do |task|
            payload[:thread_ts] = task['timestamp']
          end

          message = post_message(payload)
          save_message(subscription_name, message, data['timestamp'])
        end
      end
      subscriber.start
    end

    def self.post_message(payload)
      web.chat_postMessage(payload)
    end

    def self.edit_message(payload)
      web.chat_update(payload)
    end

    def self.delete_message(payload)
      web.chat_delete(payload)
    end

    def self.save_message(entity_name, message, original_timestamp, user='', reaction='')
      task = datastore.entity entity_name do |t|
        t["originalTs"] = original_timestamp
        t["timestamp"] = message.ts
        t["channelID"] = message.channel
        t['user'] = user
        t['reaction'] = reaction
      end

      datastore.save(task)
    end

    def self.add_reaction(subscription_name, data)
      payload = {
        channel: data['room'],
        thread_ts: data['thread_ts'],
        text: ":#{data['reaction']}:",
        username: data['username'],
        icon_url: data['icon_url'],
        as_user: false,
      }
      q = query.where('originalTs', '=', data['thread_ts']).limit(1)
      datastore.run(q).each do |task|
        payload[:thread_ts] = task['timestamp']
      end

      message = post_message(payload)
      save_message(subscription_name, message, data['thread_ts'], data['userid'], data['reaction'])
    end

    def self.remove_reaction(data)
      q = query.
        where('originalTs', '=', data['timestamp']).
        where('user', '=', data['userid']).
        where('reaction', '=', data['reaction']).
        limit(1)
      datastore.run(q).each do |task|
        payload = {
          channel: task['channelID'],
          ts: task['timestamp']
        }
        delete_message(payload)
        datastore.delete(task)
      end
    end

    def self.allowed_channel?(channel)
      allowed_channels = ENV['WORMHOLE_ALLOW_CHANNELS']
      return allowed_channels && allowed_channels.split(',').include?(channel)
    end

  end
end
