# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_chiiveapp_session',
  :secret      => '50851adfcddb863af7e45198d28f8208471f2b424d1cb225af4ed370bc8c03b0f447f52b16b4021884bd629d7a8ef8f3065100c4ead93cf42975e6e2bac84d02'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
