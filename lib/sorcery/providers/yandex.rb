module Sorcery
  module Providers
    # This class adds support for OAuth with yandex.ru.
    #
    #   config.yandex.key = <key>
    #   config.yandex.secret = <secret>
    #   ...
    #
    class Yandex < Base
      include Protocols::Oauth2

      attr_accessor :auth_url, :scope, :token_url, :user_info_url

      def initialize
        super

        @site          = 'https://oauth.yandex.ru/authorize'
        @auth_url      = '/authorize'
        @token_url     = '/token'
        @user_info_url = 'https://login.yandex.ru/info?format=json'
        @scope         = nil
      end

      def get_user_hash(access_token)
        response = access_token.get(user_info_url)

        auth_hash(access_token).tap do |h|
          h[:user_info] = JSON.parse(response.body)
          h[:uid] = h[:user_info]['id']
        end
      end

      # calculates and returns the url to which the user should be redirected,
      # to get authenticated at the external provider's site.
      def login_url(_params, _session)
        authorize_url(authorize_url: auth_url)
      end

      # tries to login the user from access token
      def process_callback(params, _session)
        args = {}.tap do |a|
          a[:code] = params[:code] if params[:code]
        end

        get_access_token(args, token_url: token_url, token_method: :post)
      end
    end
  end
end
