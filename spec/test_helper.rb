# frozen_string_literal: true

require 'minitest/autorun'

$LOAD_PATH.unshift(File.expand_path('support/stubs', __dir__))

ENV['SLACK_API_TOKEN'] ||= 'test-token'
ENV['GCP_PROJECT_ID'] ||= 'test-project'

