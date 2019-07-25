# frozen_string_literal: true

module Support
  module Github
    protected

    GITHUB_USER_URL = %r{\Ahttps://api.github.com/user}
    GITHUB_USER_ORGANIZATION_URL = %r{\Ahttps://api.github.com/user/orgs}

    def mock_token_request
      stub_request(
        :post, Authorization.access_token_url
      ).and_return(
        body: Rack::Utils.build_query(
          access_token: @access_token,
          token_type: 'bearer'
        )
      )
    end

    def mock_github_user_request
      stub_request(
        :get, GITHUB_USER_URL
      ).and_return(
        headers: { 'Content-Type' => 'application/json' },
        body: JSON.dump(
          name: @name,
          login: @login,
          avatar_url: 'https://avatars3.githubusercontent.com/u/87?v=4'
        )
      )
    end

    def mock_github_organizaton_request
      stub_request(
        :get, GITHUB_USER_ORGANIZATION_URL
      ).and_return(
        headers: { 'Content-Type' => 'application/json' },
        body: JSON.dump(
          @organizations.map do |name|
            { login: name }
          end
        )
      )
    end

    def mock_oauth
      mock_token_request
      mock_github_user_request
      mock_github_organizaton_request
    end
  end
end
