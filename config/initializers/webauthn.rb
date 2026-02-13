WebAuthn.configure do |config|
  config.rp_name = "Tokoo"
  config.rp_id   = "localhost" # dev
  config.allowed_origins = [ "http://localhost:3000" ]
end
