# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
if defined?(Slices::Application)
  Slices::Application.config.secret_token = 'b101d69faed18665b8d3b9f7dd321593b6687ddaced0c9b563ad92627ae5d53c835d3977918d8322c2928e5a7cd3b28d909f386d15156a950d7ca8f5669f3693'
end
