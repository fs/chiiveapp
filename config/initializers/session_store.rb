# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_chiive_session',
  :secret      => 'f41aa64737c2ad8d7b5849ef9d9e88db2d508a2ac7e2263fd439409e336d0705f2338fcb209694e8a11d6f93807d138f54d685832e1486ee563e6627a5f17bdf'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
