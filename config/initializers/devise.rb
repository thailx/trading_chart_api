Devise.setup do |config|
  config.authentication_keys = [:login]
  config.case_insensitive_keys = [:login]
end