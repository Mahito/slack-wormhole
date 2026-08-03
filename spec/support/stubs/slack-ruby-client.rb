# frozen_string_literal: true

require 'ostruct'

module Slack
  class Config < OpenStruct
  end

  class << self
    def config
      @config ||= Config.new
    end

    def configure
      yield config
    end
  end

  module Web
    class Client
      def initialize(*, **)
      end
    end
  end
end
