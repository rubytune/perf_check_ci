module Github
  class Client
    def self.post(path, data)
      path.sub!(/^\//, '')
      url = path.match(/^https?:/) ? path : "https://api.github.com/#{path}"

      puts "Posting to #{url}"
      options = {
        query: { access_token: APP_CONFIG[:github_token] },
        body: data.to_json
      }

      response = HTTParty.post(url, options)
      return response
    end
  end
end
