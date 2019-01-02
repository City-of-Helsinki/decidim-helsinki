module OmniAuth
  module Strategies
    class OpenIDConnectHelsinki < OpenIDConnect
      def authorize_uri
        client.redirect_uri = redirect_uri
        opts = {
          response_type: options.response_type,
          scope: options.scope,
          state: new_state,
          login_hint: options.login_hint,
          prompt: options.prompt,
          nonce: (new_nonce if options.send_nonce),
          hd: options.hd,
        }
        if locale = request.params['locale']
          # Pass the ?lang=xx to Tunnistamo, it should use exactly the same
          # codes
          opts[:lang] = locale
        end

        client.authorization_uri(opts.reject { |k, v| v.nil? })
      end

      def redirect_uri
        extra_params = {}
        if rd_uri = request.params['redirect_uri']
          extra_params['redirect_uri'] = rd_uri
        end
        if locale = request.params['locale']
          # Currently Tunnistamo gives a "Invalid redirect_uri" error in case
          # we pass something else than what is exactly the configured URL.
          #extra_params['locale'] = locale
        end

        return client_options.redirect_uri if extra_params.empty?

        "#{ client_options.redirect_uri }#{ hash_to_query(extra_params) }"
      end

      private
        def hash_to_query(hash)
          query = ''
          separator = '?'
          hash.each do |key, val|
            query << "#{separator}#{key}=#{val}"
            separator = '&'
          end
          query
        end
    end
  end
end

OmniAuth.config.add_camelization 'openid_connect_helsinki', 'OpenIDConnectHelsinki'
