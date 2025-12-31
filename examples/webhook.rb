require 'lightspeed'

Lightspeed.configure do |config|
  config.domain_prefix = ENV['LIGHTSPEED_DOMAIN_PREFIX']
  config.access_token = ENV['LIGHTSPEED_ACCESS_TOKEN']
end

# List Webhooks
webhooks = Lightspeed::Webhook.all
puts webhooks

# Get a Webhook
webhook = webhooks.first
puts Lightspeed::Webhook.find(webhook[:id])

# Create a Webhook
webhook = Lightspeed::Webhook.create(data: { url: 'https://12345678.ngrok.io', active: false, type: 'product.update' })
puts webhook

# Update a Webhook
puts Lightspeed::Webhook.update(webhook[:id], data: { active: true })

# Destroy a Webhook
puts Lightspeed::Webhook.destroy(webhook[:id])