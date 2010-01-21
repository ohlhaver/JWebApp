# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_Jurnalo_session',
  :secret      => 'fed8479e43a7a897aa6ca18df2dcb9afae22dfde17adbe054f15e8736a23bcdad5002994041494eec5e9d6c4ac9fe38f4ee26fbfa71baa9348f94ac8a5e403e2'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
