class WebhooksController < ApplicationController
  before_action :verify_signature

  def pull_request
    GithubMention.extract_and_spawn_jobs(payload)

    render text: "OK"
  end

  def comment
    pull_request_payload = payload['pull_request']

    if pull_request_payload['action'] == ''
      GithubMention.extract_and_spawn_jobs(payload['pull_request'])
    end

    render text: "OK"    
  end

  private

  def payload
    params[:payload]
  end

  def verify_signature
    if github_webhook_secret = APP_CONFIG[:github_webhook_secret]
      signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), github_webhook_secret, request.body.read)
      unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
        render json: { errors: "Signatures didn't match" }, status: 422
      end
    end
  end

end