require 'action_dispatch/routing/route_set'
require 'active_support/core_ext/module/aliasing'

module ActionDispatch
  module Routing
    class RouteSet

      # Add a secure option to the rewrite method.
      def url_for_with_secure_option(options = {})
        current_host = @request.try(:host) || options[:host]
        current_port = @request.try(:port) || options[:port]
        current_protocol = (@request.try(:protocol) || options[:protocol] || "http://").split("://").first

        secure = options.delete(:secure)

        # if secure && ssl check is not disabled, convert to full url with https
        if !secure.nil? && !SslRequirement.disable_ssl_check?
          if [true, 1, "true"].include? secure
            protocol = "https"
            host = SslRequirement.ssl_host || current_host
            port = Integer(SslRequirement.ssl_port || 443)
            port_std = port == 443
          else
            protocol = "http"
            host = SslRequirement.non_ssl_host || current_host
            port = Integer(SslRequirement.non_ssl_port || 80)
            port_std = port == 80
          end

          options[:protocol] = protocol

          if host != current_host
            options[:host] = host
            options[:only_path] = false
          end

          if !port_std or current_port != port
            options[:port] = port_std ? nil : port
            options[:only_path] = false
          end
        end

        url_for_without_secure_option(options)
      end

      alias_method_chain :url_for, :secure_option
    end
  end
end
