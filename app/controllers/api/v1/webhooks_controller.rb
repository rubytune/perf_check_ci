class WebhooksController < ApplicationController
  before_action :verify_signature

  def create
    
  end

  private

  def verify_signature
    signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), APP_CONFIG[:github_webhook_secret], request.body.read)
    unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
      return halt 500, "Signatures didn't match!" 
    end
  end

end