# Release Notes

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
