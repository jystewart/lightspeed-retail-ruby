# Release Notes

## 0.4.0 - OAuth Scope Support

Adds full support for Lightspeed's mandatory scope parameter, required for all new OAuth connections from **1 June 2026**.

### New Features

* **`config.scopes`** — Declare the OAuth scopes your application needs in `Lightspeed.configure`. Accepts an array or space-delimited string.
* **Scope-aware OAuth URLs** — `Lightspeed::Oauth2::AuthCode#authorize_url` now accepts a `scopes:` keyword argument and automatically includes scopes from the global config when none are passed explicitly.
* **`Lightspeed::ScopeError`** — Raised before any HTTP request when a resource method is called and its required scope is not in the configured scopes list. Provides a clear, actionable message.
* **`Resource.scope_required(:action)`** — Query what scope a particular action requires, e.g. `Lightspeed::Sale.scope_required(:all) #=> "sales:read"`.
* **`read_scope` / `write_scope` helpers** — Shorthand for declaring the same scope across all standard read or write actions on a resource class.
* All 22 built-in resources have scope requirements declared based on the [official Lightspeed scope documentation](https://x-series-api.lightspeedhq.com/docs/scopes).

### Backward Compatibility

Scope checking is entirely opt-in. Existing code with no `config.scopes` configured continues to work without any changes. Scope validation is skipped unless scopes are explicitly set.

## 0.3.1 - Critical bug fix

* Fixed API domain name

## 0.3.0 - Lightspeed Rebranding

### 🎉 Major Changes

* **RENAMED:** `vend-ruby-v2` → `lightspeed-retail-ruby` to reflect Lightspeed's acquisition of Vend
* **RENAMED:** All `Vend` module/class references → `Lightspeed` throughout the codebase
* **UPDATED:** API domain from `vendhq.com` → `retail.lightspeed.app`
* **UPDATED:** Documentation URLs from `docs.vendhq.com` → `x-series-api.lightspeedhq.com`
* **ADDED:** Full backward compatibility layer - existing `Vend` code continues to work
* **ADDED:** Environment variable compatibility - both `VEND_*` and `LIGHTSPEED_*` supported
* **ADDED:** Deprecation warnings for legacy `Vend` usage to guide migration
* **ADDED:** Comprehensive migration guide (MIGRATION.md)

### ✅ Backward Compatibility

Version 0.3.0 is **fully backward compatible**:

* ✅ `require 'vend'` still works (shows deprecation warning)
* ✅ `Vend` constant available as alias to `Lightspeed`
* ✅ All `Vend::*` classes work via aliasing
* ✅ `VEND_DOMAIN_PREFIX` and `VEND_ACCESS_TOKEN` environment variables supported (show deprecation warning)
* ✅ Existing code requires no immediate changes

### 🔄 Migration Path

Users can migrate gradually:

1. **Phase 1:** Update gem dependency (existing code works with warnings)
2. **Phase 2:** Update code references from `Vend` to `Lightspeed`
3. **Phase 3:** Update environment variables from `VEND_*` to `LIGHTSPEED_*`

See [MIGRATION.md](MIGRATION.md) for detailed migration instructions.

### ⚠️ Future Deprecation

The `Vend` compatibility layer will be removed in v1.0.0 (planned Q2 2026).

### 📝 Files Changed

* Renamed: `lib/vend/` → `lib/lightspeed/` (36 files)
* Updated: All module declarations from `module Vend` to `module Lightspeed`
* Updated: All internal requires from `require 'vend/*'` to `require 'lightspeed/*'`
* Updated: API domain endpoints to `retail.lightspeed.app`
* Updated: OAuth endpoints to `secure.retail.lightspeed.app`
* Updated: 21 documentation URL comments to `x-series-api.lightspeedhq.com`
* Added: `lib/vend.rb` as compatibility shim
* Added: `lightspeed-retail-ruby.gemspec`
* Added: `MIGRATION.md`
* Updated: `README.md` with new naming throughout
* Updated: Examples to use `Lightspeed` namespace
* Updated: All test files to use `Lightspeed` namespace

### 🔧 Technical Details

* Main entry point: `require 'lightspeed'`
* Legacy entry point: `require 'vend'` (loads `lightspeed` + creates alias)
* Config auto-detection: Checks `LIGHTSPEED_*` first, falls back to `VEND_*`
* Deprecation warnings: Shown once per session to avoid log spam
* All 22 resource classes updated to `Lightspeed` namespace
* All 15 exception classes updated to `Lightspeed` namespace
* Thread-safe configuration maintained
* OAuth2 implementation updated for new domain

## 0.2.0

### External changes

* Add automatic pagination support for v2.0 API endpoints via `auto_paginate_v2` method that fetches all pages and returns a flat array of results
* Add memory-efficient page iteration via `each_page_v2` method that processes one page at a time
* Add automatic retry logic with exponential backoff for rate limits (429) and transient failures (503)
* Retry logic respects `Retry-After` header from API responses for optimal rate limit handling
* Add comprehensive documentation with examples for pagination, retry logic, thread safety, OAuth2, and performance optimizations
* Improve error handling with proper exception types: `TooManyRequests`, `ServiceUnavailable`, etc.
* All resources now support cursor-based pagination with `after` parameter for efficient large dataset handling

### Internal changes

* Enable frozen string literals across all files for 5-10% memory allocation reduction
* Replace `File.expand_path(__FILE__)` with modern `__dir__` for cleaner file path handling
* Optimize string allocation in `PathBuilder` using unary `+` operator only when needed
* Adopt safe navigation operator (`&.`) for cleaner nil handling in exception middleware
* Replace `attr_accessor` with `attr_reader` in `AuthCode` to prevent accidental mutation
* Use consistent hash syntax with proper spacing around braces
* Migrate to Ruby 3+ pattern matching (`case/in`) for version handling
* Add `faraday-retry` gem dependency for robust retry middleware
* Improve test coverage with comprehensive specs for pagination and retry logic
* All code now follows modern Ruby 3+ idioms while maintaining compatibility with Ruby 3.0+

## 0.1.0

* Initial release
* Support for all Vend API v2.0 resources (Products, Customers, Sales, etc.)
* OAuth2 authentication support
* Thread-safe connection handling
* Basic error handling and HTTP client implementation
