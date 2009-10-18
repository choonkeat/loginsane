# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_loginsane_session',
  :secret      => '45c3c0b0a6571120e5a9245288ec72e4b3ac6d9e98bbacafc331c84bb9c322d08ae53d5ceaa5b7a8ef4c0d384249032a4fb7bdef0fabd8ffd4305090e8ff9f9c'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
