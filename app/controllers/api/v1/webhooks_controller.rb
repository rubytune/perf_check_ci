require 'github_mention'
class Api::V1::WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :require_user
  before_action :require_no_user
  before_action :verify_signature

  def github
    GithubMention.extract_and_spawn_jobs(params)
    render json: { success: true, message: "OK" }
  end

  private

  def verify_signature
    if github_webhook_secret = APP_CONFIG[:github_webhook_secret]
      signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), github_webhook_secret, request.body.read)
      unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'] || "")
        render json: { errors: "Signatures didn't match" }, status: 422
        return
      end
    end
  end

end