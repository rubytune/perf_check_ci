# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength

# Service class to process GitHub OAuth and decide if the corresponding GitHub
# user may have access to the application based on access to GitHub
# organizations.
class Authorization
  include ActiveModel::Model

  attr_accessor :callback_url
  attr_accessor :error, :error_description, :error_uri
  attr_accessor :code, :state
  attr_accessor :access_token, :scope, :token_type

  def url
    self.class.github_authorize_url + '?' + Rack::Utils.build_query(
      client_id: APP_CONFIG['github_client_id'],
      redirect_uri: callback_url,
      # This should contain a random string to protect against forgery attacks
      # and could contain any other arbitrary data to identify the OAuth
      # request when it returns from GitHub.
      state: SecureRandom.alphanumeric,
      # Request read access to read a user's profile data and their orgs
      # because we want to know their avatar and full name and verify that they
      # have access to the configured organization.
      scope: 'read:user,read:org'
    )
  end

  def process
    process_error &&
      fetch_access_token &&
      user_organization_matches &&
      upsert_user
  rescue Octokit::InternalServerError => e
    e.errors.each { |error| errors.add(:base, error) }
    false
  end

  def self.github_authorize_url
    'https://github.com/login/oauth/authorize'
  end

  def self.access_token_url
    'https://github.com/login/oauth/access_token'
  end

  private

  def process_error
    if error.present?
      errors.add(:base, error_description)
      false
    else
      true
    end
  end

  # Returns true when the GitHub user has access to any of the configured
  # required organizations.
  def user_organization_matches
    return true if any_organization_matches?

    errors.add(
      :github_user,
      'must have access to one of the configured organizations to access ' \
      'this application.'
    )
    false
  end

  def access_token_uri
    URI.parse(self.class.access_token_url)
  end

  def access_token_params
    {
      client_id: APP_CONFIG['github_client_id'],
      client_secret: APP_CONFIG['github_client_secret'],
      redirect_uri: APP_CONFIG['github_oauth_callback_url'],
      code: code,
      state: state
    }
  end

  def verify_response(response)
    if response.code =~ /\A2..\Z/
      true
    else
      errors.add(:base, 'Failed to fetch access token from GitHub')
      false
    end
  end

  def fetch_access_token
    response = Net::HTTP.post_form(access_token_uri, access_token_params)
    return unless verify_response(response)

    self.attributes = Rack::Utils.parse_query(response.body)
    process_error
  end

  def client
    @client ||= begin
      fetch_access_token
      client = Octokit::Client.new(access_token: access_token)
      client.auto_paginate = true
      client
    end
  end

  def github_user
    @github_user ||= client.user
  end

  def github_user_organizations
    @github_user_organizations ||= client.organizations(github_user)
  end

  def any_organization_matches?
    return true if APP_CONFIG['github_organizations'].blank?

    github_user_organizations.any? do |organization|
      APP_CONFIG['github_organizations'].include?(organization.login)
    end
  end

  def user_attributes
    {
      name: github_user.name,
      github_login: github_user.login,
      github_avatar_url: github_user.avatar_url,
      created_at: Time.zone.now,
      updated_at: Time.zone.now
    }
  end

  def upsert_user
    User.upsert(
      user_attributes,
      unique_by: :github_login,
      returning: %i[id]
    ).to_a[0].fetch('id')
  end
end

# rubocop:enable Metrics/ClassLength
