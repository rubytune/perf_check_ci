# frozen_string_literal: true

module Support
  module Authentication
    def login(label)
      post "/test/sessions", params: { user_id: users(label).id }
    end
  end
end
