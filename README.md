# Vend Ruby SDK (v2)

A modern Ruby client library for the [Lightspeed Retail (X-Series/Vend) API](https://x-series-api.lightspeedhq.com/).

[![Ruby Version](https://img.shields.io/badge/ruby-%3E%3D%203.0.0-ruby.svg)](https://www.ruby-lang.org)

## Features

- ✅ **Automatic Pagination** - Efficiently handle large datasets with cursor-based pagination
- ✅ **Automatic Retry Logic** - Built-in handling for rate limits and transient failures
- ✅ **Modern Ruby 3+** - Leverages latest Ruby features and idioms
- ✅ **Thread-Safe** - Support for concurrent API requests
- ✅ **Comprehensive** - Full coverage of Vend API v2.0 resources

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'vend-ruby-v2'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install vend-ruby-v2
```

## Quick Start

```ruby
# Configure the client
Vend.configure do |config|
  config.domain_prefix = ENV['VEND_DOMAIN_PREFIX']  # Your store name
  config.access_token = ENV['VEND_ACCESS_TOKEN']    # OAuth token
end

# Fetch a single page of products
products = Vend::Product.all
# => {:data=>[{:id=>"...", :name=>"Product 1", ...}], :version=>{:min=>1, :max=>100}}

# Fetch all products automatically (handles pagination)
all_products = Vend::Product.auto_paginate_v2
# => [{:id=>"...", :name=>"Product 1"}, {:id=>"...", :name=>"Product 2"}, ...]

# Fetch a specific product
product = Vend::Product.find("product-id-here")
# => {:data=>{:id=>"...", :name=>"Product 1", ...}}
```

## Pagination

The gem provides powerful pagination support for v2.0 API endpoints that prevents memory issues when working with large datasets.

### Automatic Pagination

Automatically fetch all pages and return a flat array:

```ruby
# Fetch all products across all pages
all_products = Vend::Product.auto_paginate_v2
# => [{...}, {...}, ...] (all products)

# With filters
deleted_products = Vend::Product.auto_paginate_v2(deleted: true)

# Works with all v2.0 resources
all_customers = Vend::Customer.auto_paginate_v2
all_sales = Vend::Sale.auto_paginate_v2
```

### Manual Pagination (Memory Efficient)

Process pages one at a time for better memory efficiency:

```ruby
Vend::Product.each_page_v2 do |products|
  products.each do |product|
    puts "Processing: #{product[:name]}"
    # Process each product without loading everything into memory
  end
end

# With filters
Vend::Product.each_page_v2(deleted: true) do |products|
  # Process deleted products page by page
end
```

### Single Page (Default Behavior)

For backward compatibility, `.all` returns only the first page:

```ruby
response = Vend::Product.all
products = response[:data]          # First page of products
version = response[:version][:max]  # Cursor for next page

# Manual pagination
next_page = Vend::Product.all(after: version)
```

## Error Handling & Retry Logic

The gem automatically handles rate limits and transient failures with exponential backoff.

### Automatic Retry

Requests automatically retry on:
- **429 Too Many Requests** (rate limiting)
- **503 Service Unavailable** (transient failures)

Configuration:
- Max retries: 3
- Backoff: 0.5s → 1s → 2s (with randomization)
- Respects `Retry-After` header from API

```ruby
# This will automatically retry if rate limited
products = Vend::Product.auto_paginate_v2

# No additional code needed - retry happens automatically!
```

### Exception Handling

All API errors raise specific exceptions:

```ruby
begin
  product = Vend::Product.find("invalid-id")
rescue Vend::NotFound => e
  puts "Product not found"
rescue Vend::TooManyRequests => e
  # Already retried 3 times, still rate limited
  puts "Rate limit exceeded, retry after: #{e.response_headers[:retry_after]}"
rescue Vend::Unauthorized => e
  puts "Invalid access token"
rescue Vend::HttpError => e
  # Catch-all for any HTTP error
  puts "API error: #{e.message}"
end
```

Available exceptions:
- `Vend::BadRequest` (400)
- `Vend::Unauthorized` (401)
- `Vend::Forbidden` (403)
- `Vend::NotFound` (404)
- `Vend::TooManyRequests` (429)
- `Vend::InternalServerError` (500)
- `Vend::ServiceUnavailable` (503)
- And more... (see [lib/vend/exception.rb](lib/vend/exception.rb))

## Available Resources

All standard Vend API v2.0 resources are supported:

```ruby
# Products
Vend::Product.all
Vend::Product.find(id)
Vend::Product.create(params)
Vend::Product.update(id, params)

# Customers
Vend::Customer.all
Vend::Customer.find(id)

# Sales
Vend::Sale.all
Vend::Sale.find(id)
Vend::Sale.create(params)

# Other resources
Vend::Brand
Vend::Consignment
Vend::CustomerGroup
Vend::Inventory
Vend::Outlet
Vend::PaymentType
Vend::PriceBook
Vend::Register
Vend::Supplier
Vend::Tax
Vend::User
# ... and more
```

See [lib/vend/resources/](lib/vend/resources/) for the complete list.

## Thread Safety

### Simple Usage (Not Thread-Safe)

For single-threaded applications or CLIs:

```ruby
Vend.configure do |config|
  config.domain_prefix = 'your-store'
  config.access_token = 'your-token'
end

# Use resources normally
products = Vend::Product.all
```

### Thread-Safe Usage

For multi-threaded applications, create separate connections per thread:

```ruby
# Create a connection
config = Vend::Config.new(
  domain_prefix: ENV['VEND_DOMAIN_PREFIX'],
  access_token: ENV['VEND_ACCESS_TOKEN']
)
connection = Vend::Connection.build(config)

# Pass connection to requests
products = Vend::Product.all(connection: connection)
customer = Vend::Customer.find(id, connection: connection)

# Example: Thread pool
connections = ThreadLocal.new do
  Vend::Connection.build(Vend::Config.new(
    domain_prefix: ENV['VEND_DOMAIN_PREFIX'],
    access_token: ENV['VEND_ACCESS_TOKEN']
  ))
end

threads = 10.times.map do |i|
  Thread.new do
    conn = connections.value
    Vend::Product.all(connection: conn)
  end
end

threads.each(&:join)
```

## OAuth2 Authentication

```ruby
# Initialize OAuth2 client
auth = Vend::Oauth2::AuthCode.new(
  'your-store',           # domain prefix
  'your-client-id',       # OAuth client ID
  'your-client-secret',   # OAuth client secret
  'your-redirect-uri'     # OAuth redirect URI
)

# Get authorization URL
auth_url = auth.authorize_url
# => "https://secure.vendhq.com/connect?client_id=..."

# Exchange authorization code for token
token = auth.token_from_code(params[:code])
access_token = token.token
refresh_token = token.refresh_token

# Refresh an expired token
new_token = auth.refresh_token(access_token, refresh_token)
```

## Advanced Usage

### Custom Request Parameters

All methods accept a params hash:

```ruby
# Filter products
active_products = Vend::Product.all(active: true)

# Pagination with filters
deleted_products = Vend::Product.auto_paginate_v2(deleted: true)

# Custom connection
products = Vend::Product.all(connection: custom_connection)
```

### API Versioning

Resources automatically use the correct API version:

```ruby
# Most resources use v2.0 API
Vend::Product.all  # => GET /api/2.0/products

# Some resources use v0.9 for backward compatibility
Vend::Webhook.all  # => GET /api/webhooks (v0.9)

# Explicit version methods when needed
Vend::Product.find_v0_9(id)  # Use v0.9 endpoint
```

## Performance & Optimization

This gem includes several performance optimizations:

- **Frozen string literals** - Reduces memory allocations by ~5-10%
- **Efficient pagination** - Cursor-based pagination prevents loading large datasets into memory
- **Connection reuse** - HTTP connection pooling via Faraday
- **Automatic retry** - Exponential backoff prevents wasted requests

## Configuration Options

```ruby
Vend.configure do |config|
  # Required
  config.domain_prefix = 'your-store'   # Your Vend store name
  config.access_token = 'your-token'     # OAuth access token

  # Optional
  config.request_type = :json            # Request format (default: :json)
  # config.request_type = :url_encoded   # For webhooks

  # Note: Timeout, retry, and other connection settings are
  # configured automatically with sensible defaults
end
```

Default connection settings:
- Timeout: 120 seconds
- Retry: 3 attempts with exponential backoff
- Rate limit handling: Automatic with `Retry-After` header support

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

### Running Tests

```bash
bundle exec rspec
```

### Test Coverage

```bash
bundle exec rspec
# See coverage report in coverage/index.html
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/coaxsoft/vend-ruby-v2. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Resources

- [API Documentation](https://x-series-api.lightspeedhq.com/)
- [Pagination Guide](https://x-series-api.lightspeedhq.com/docs/pagination)
- [Rate Limiting](https://x-series-api.lightspeedhq.com/docs/rate_limiting)
- [OAuth2 Setup](https://x-series-api.lightspeedhq.com/docs/authorization)
