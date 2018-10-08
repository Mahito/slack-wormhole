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
        case data['action']
        when 'post'
          payload = {
            channel: data['channel'],
            username: data['username'],
            icon_url: data['icon_url'],
            text: data['text'],
            as_user: false,
          }
          message = post_message(payload)
        when 'edit'
        when 'delete'
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
      web.chat_delete
    end

  end
end
