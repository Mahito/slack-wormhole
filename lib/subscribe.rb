# frozen_string_literal: true

require_relative 'utils'

module SlackWormhole
  class Subscriber
    def initialize(name)
      @subscription = name
    end

    def subscribe
      subscription = pubsub.subscription(@subscription)

      subscriber = subscription.listen do |received_message|
        received_message.acknowledge!
        json = Base64.strict_decode64(received_message.grpc.message.data)
        data = JSON.parse(json)

        if allowed_channel?(data['room'])
          event = data['action']
          send(event, data) if respond_to?(event)
        else
          logger.info("\"#{data['room']}\" is not allowed to receive channel !")
        end
      end

      subscriber.start
    end

    def allowed_channel?(channel)
      allowed_channels = ENV['WORMHOLE_ALLOW_CHANNELS']&.split(',')
      allowed_channels ? allowed_channels.include?(channel) : true
    end

    def save_message(message, original_timestamp, user = '', reaction = '')
      task = datastore.entity @subscription do |t|
        t['originalTs'] = original_timestamp
        t['timestamp'] = message.ts
        t['channelID'] = message.channel
        t['user'] = user
        t['reaction'] = reaction
      end

      datastore.save(task)
    end

    def post(data)
      payload = {
        channel: data['room'],
        username: data['username'],
        icon_url: data['icon_url'],
        text: data['text'],
        as_user: false,
        unfurl_links: true
      }
      message = web.chat_postMessage(payload)
      save_message(message, data['timestamp'])
    end

    def update(data)
      q = query.where('originalTs', '=', data['timestamp']).limit(1)
      datastore.run(q).each do |task|
        payload = {
          channel: task['channelID'],
          text: data['text'],
          ts: task['timestamp']
        }
        web.chat_update(payload)
      end
    end

    def delete(data)
      q = query.where('originalTs', '=', data['timestamp']).limit(1)
      datastore.run(q).each do |task|
        payload = {
          channel: task['channelID'],
          ts: task['timestamp']
        }
        web.chat_delete(payload)
        datastore.delete(task)
      end
    end

    def reaction_add(data)
      payload = {
        channel: data['room'],
        thread_ts: data['thread_ts'],
        text: ":#{data['reaction']}:",
        username: data['username'],
        icon_url: data['icon_url'],
        as_user: false
      }
      q = query.where('originalTs', '=', data['thread_ts']).limit(1)
      datastore.run(q).each do |task|
        payload[:thread_ts] = task['timestamp']
      end

      message = web.chat_postMessage(payload)
      save_message(message, data['thread_ts'], data['userid'], data['reaction'])
    end

    def reaction_remove(data)
      q = query
          .where('originalTs', '=', data['timestamp'])
          .where('user', '=', data['userid'])
          .where('reaction', '=', data['reaction'])
          .limit(1)
      datastore.run(q).each do |task|
        payload = {
          channel: task['channelID'],
          ts: task['timestamp']
        }
        web.chat_delete(payload)
        datastore.delete(task)
      end
    end

    def post_reply(data)
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

      message = web.chat_postMessage(payload)
      save_message(message, data['timestamp'])
    end

    class << self
      def start(name)
        subscriber = new(name)
        subscriber.subscribe
      end
    end
  end
end
