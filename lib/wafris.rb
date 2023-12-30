# frozen_string_literal: true

require 'connection_pool'
require 'forwardable'
require 'hiredis-client'
require 'rails'
require 'redis'

require 'wafris/configuration'
require 'wafris/logger'
require 'wafris/middleware'

require 'wafris/railtie' if defined?(Rails::Railtie)

module Wafris
  class << self
    attr_accessor :configuration

    extend Forwardable
    def_delegator :@configuration, :connection_pool
    def_delegator :@configuration, :logger
    def_delegator :@configuration, :create_settings

    def configure
      raise ArgumentError unless block_given?

      yield(@configuration = Configuration.new)

      logger.info "[Wafris] attempting firewall connection via Wafris.configure initializer."

      create_settings
    rescue ArgumentError
      Logger.info "[Wafris] block is required to configure Wafris. More info can be found at: https://github.com/Wafris/wafris-rb"
    rescue StandardError => e
      Logger.info "[Wafris] firewall disabled due to: #{e.message}. Cannot connect via Wafris.configure. Please check your configuration settings. More info can be found at: https://github.com/Wafris/wafris-rb"
    end

    def allow_request?(request)
      connection_pool.with do |conn|
        time = Time.now.utc.to_i * 1000

        status = conn.evalsha(
          configuration.core_sha,
          argv: [
            request.ip,
            IPAddr.new(request.ip).to_i,
            time,
            request.user_agent,
            request.path,
            request.query_string,
            request.host,
            request.request_method
          ]
        )

        return false if status == 'Blocked'

        true
      rescue Redis::TimeoutError
        Logger.info(
          "[Wafris] Wafris timed out during processing. Request passed without rules check."
        )

        true
      rescue StandardError => e
        Logger.info(
          "[Wafris] Redis connection error: #{e.message}. Request passed without rules check."
        )

        true
      end
    end
  end
end
