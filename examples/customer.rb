require 'lightspeed'

Lightspeed.configure do |config|
  config.domain_prefix = ENV['LIGHTSPEED_DOMAIN_PREFIX']
  config.access_token = ENV['LIGHTSPEED_ACCESS_TOKEN']
end

# List customers
customers = Lightspeed::Customer.all
puts customers

# Get a Customer
customer = customers[:data].first
puts Lightspeed::Customer.find(customer[:id])

# Create a Customer
customer = Lightspeed::Customer.create(first_name: 'Test', last_name: 'Test')[:data]
puts customer

# Update a Customer
puts Lightspeed::Customer.update(customer[:id], phone: '1234567890')

# Destroy a Customer
puts Lightspeed::Customer.destroy(customer[:id])
