# Author: Stephen Gregory <sgregory@compendium.com>
#
#
#

require 'rack/session/abstract/id'
require 'php_serialize'
require 'dalli'

module Rack
  module Session
    #
    # Rack::Session:Agavi
    #
    #
    class Agavi < Abstract::ID
      TTL = 100

      DEFAULT_OPTIONS = Abstract::ID::DEFAULT_OPTIONS.merge \
        :namespace => '',
        :key => 'Agavi',
        :path => '/',
        :memcache_server => 'localhost:11211'

      def debug(msg)
        if @logger
          @logger.debug msg
        end
      end


      def initialize(app, options={})
        unless options.key?(:key)
          options[:key] = 'Agavi'
        end

        options[:path] = '/'
        options[:namespace] = ''
        options[:namespace_separator] = ''
        @logger = options[:logger]

        super
        @default_options = options
        @mutex = Mutex.new
        mserv = @default_options[:memcache_server]

        @pool = options[:cache] || Dalli::Client.new(mserv, {})
        debug "initialized agavi sessionhandler #{options.inspect}"
        debug "key is #{@key}"
      end



      def generate_sid
        loop do
          sid = super
          break sid unless @pool.get("session_#{sid}")
        end
      end


      def get_session(env, sid)
        if sid.nil?
          [sid, nil]
        end
        with_lock(env, [nil, {}]) do
          begin
            unless sid && session = @pool.get("session_#{sid}")
              debug " sid #{sid} session #{session.inspect}"
              sid = generate_sid
              session = PHP.serialize_session({:fromruby => true}, true)

              unless /^STORED/ =~ @pool.add("session_#{sid}", session)
                raise "Session collision on '#{sid.inspect}'"
              end
            end
          rescue Exception => msg
            debug "exception caught #{msg.inspect}"
          end

          [sid, PHP.unserialize(session)]
        end
      end

      def set_session(env, session_id, new_session, options)
        expiry = options[:expire_after]
        expiry = expiry.nil? ? 0 : expiry + 1

        debug "setting SESSION ID #{session_id}"
        with_lock(env, false) do
          @pool.set "session_#{session_id}", PHP.serialize_session(new_session, true), expiry, :raw => true
          session_id
        end
        session_id
      end

      def destroy_session(env, session_id, options)
        with_lock(env) do
          @pool.delete(session_id)
          generate_sid unless options[:drop]
        end
      end

      def with_lock(env, default=nil)
        @mutex.lock if env['rack.multithread']
        yield
      rescue Exception
        if $VERBOSE
          warn "#{self} is unable to find memcached server."
          warn $!.inspect
        end
        default
      ensure
        @mutex.unlock if @mutex.locked?
      end
    end
  end
end


