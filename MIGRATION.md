# Migration Guide: vend-ruby-v2 → lightspeed-retail-ruby

This guide helps you migrate from `vend-ruby-v2` to `lightspeed-retail-ruby`.

## Why the rename?

Following Lightspeed's acquisition of Vend, the API has been rebranded as "Lightspeed Retail (X-Series)". This gem has been renamed to reflect that change while maintaining full backward compatibility.

## Quick Migration (4 steps)

### 1. Update Gemfile

```diff
- gem 'vend-ruby-v2'
+ gem 'lightspeed-retail-ruby'
```

### 2. Update requires

```diff
- require 'vend'
+ require 'lightspeed'
```

### 3. Update code references

```diff
- Vend.configure do |config|
-   config.domain_prefix = ENV['VEND_DOMAIN_PREFIX']
-   config.access_token = ENV['VEND_ACCESS_TOKEN']
+ Lightspeed.configure do |config|
+   config.domain_prefix = ENV['LIGHTSPEED_DOMAIN_PREFIX']
+   config.access_token = ENV['LIGHTSPEED_ACCESS_TOKEN']
  end

- products = Vend::Product.all
- customer = Vend::Customer.find(id)
+ products = Lightspeed::Product.all
+ customer = Lightspeed::Customer.find(id)
```

### 4. Update environment variables

```diff
- VEND_DOMAIN_PREFIX=your-store
- VEND_ACCESS_TOKEN=your-token
+ LIGHTSPEED_DOMAIN_PREFIX=your-store
+ LIGHTSPEED_ACCESS_TOKEN=your-token
```

## Backward Compatibility

Version 0.3.0 maintains full backward compatibility:

- ✅ `require 'vend'` still works (with deprecation warning)
- ✅ `Vend` constant still available (aliased to `Lightspeed`)
- ✅ All `Vend::*` classes still work
- ✅ `VEND_*` environment variables still work (with deprecation warning)

This means you can update your gem dependency immediately and migrate your code gradually.

## Step-by-Step Migration

### Phase 1: Update Gem (No Code Changes)

1. Update your Gemfile:
   ```ruby
   gem 'lightspeed-retail-ruby', '~> 0.3.0'
   ```

2. Run `bundle update vend-ruby-v2`

3. Your existing code continues to work with deprecation warnings

### Phase 2: Migrate Code (Gradual)

Migrate one file at a time:

**Before:**
```ruby
require 'vend'

Vend.configure do |config|
  config.domain_prefix = ENV['VEND_DOMAIN_PREFIX']
  config.access_token = ENV['VEND_ACCESS_TOKEN']
end

class ProductSync
  def sync
    Vend::Product.auto_paginate_v2.each do |product|
      process(product)
    end
  end

  def find_customer(id)
    Vend::Customer.find(id)
  rescue Vend::NotFound
    nil
  end
end
```

**After:**
```ruby
require 'lightspeed'

Lightspeed.configure do |config|
  config.domain_prefix = ENV['LIGHTSPEED_DOMAIN_PREFIX']
  config.access_token = ENV['LIGHTSPEED_ACCESS_TOKEN']
end

class ProductSync
  def sync
    Lightspeed::Product.auto_paginate_v2.each do |product|
      process(product)
    end
  end

  def find_customer(id)
    Lightspeed::Customer.find(id)
  rescue Lightspeed::NotFound
    nil
  end
end
```

### Phase 3: Update Environment Variables

Update your deployment configuration:

**Heroku:**
```bash
heroku config:set LIGHTSPEED_DOMAIN_PREFIX=your-store
heroku config:set LIGHTSPEED_ACCESS_TOKEN=your-token
heroku config:unset VEND_DOMAIN_PREFIX
heroku config:unset VEND_ACCESS_TOKEN
```

**Docker / .env:**
```diff
- VEND_DOMAIN_PREFIX=your-store
- VEND_ACCESS_TOKEN=your-token
+ LIGHTSPEED_DOMAIN_PREFIX=your-store
+ LIGHTSPEED_ACCESS_TOKEN=your-token
```

**AWS / Kubernetes / etc:**
Update your secrets management system to use the new variable names.

## What Changed

### API Endpoints

The gem now uses the new Lightspeed domain:

```diff
- https://{domain_prefix}.vendhq.com/api
+ https://{domain_prefix}.lightspeedhq.com/api

- https://secure.vendhq.com/connect
+ https://secure.lightspeedhq.com/connect
```

### Documentation URLs

API documentation has moved:

```diff
- https://docs.vendhq.com/
+ https://x-series-api.lightspeedhq.com/
```

### Module Names

All modules renamed:

| Old (v0.2.0)               | New (v0.3.0)                    |
|----------------------------|----------------------------------|
| `Vend`                     | `Lightspeed`                     |
| `Vend::Product`            | `Lightspeed::Product`            |
| `Vend::Customer`           | `Lightspeed::Customer`           |
| `Vend::Config`             | `Lightspeed::Config`             |
| `Vend::NotFound`           | `Lightspeed::NotFound`           |
| `Vend::Oauth2::AuthCode`   | `Lightspeed::Oauth2::AuthCode`   |
| ... (all 36 classes)       | ...                              |

## Breaking Changes in v0.3.0

None! This is a **non-breaking** major version bump. The version was bumped to 0.3.0 to signal the significant rename, but all existing code continues to work.

## Future Deprecation (v1.0.0)

The `Vend` compatibility layer will be removed in v1.0.0:

- ❌ `require 'vend'` will no longer work
- ❌ `Vend` constant will no longer be available
- ❌ `VEND_*` environment variables will no longer be checked

**Timeline:** Version 1.0.0 is planned for Q2 2026, giving you plenty of time to migrate.

## Need Help?

- 📖 [Full Documentation](https://github.com/coaxsoft/lightspeed-retail-ruby)
- 🐛 [Report Issues](https://github.com/coaxsoft/lightspeed-retail-ruby/issues)
- 💬 [Discussions](https://github.com/coaxsoft/lightspeed-retail-ruby/discussions)

## Checklist

Use this checklist to track your migration:

- [ ] Updated Gemfile to use `lightspeed-retail-ruby`
- [ ] Ran `bundle update`
- [ ] Changed `require 'vend'` to `require 'lightspeed'`
- [ ] Replaced `Vend.configure` with `Lightspeed.configure`
- [ ] Replaced all `Vend::*` class references with `Lightspeed::*`
- [ ] Updated environment variables from `VEND_*` to `LIGHTSPEED_*`
- [ ] Verified no deprecation warnings in logs
- [ ] Updated documentation/comments in your code
- [ ] Notified team members of the change
