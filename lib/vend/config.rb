# frozen_string_literal: true

module Vend
  class Config < Hashie::Mash
    def api_url
      "https://#{domain_prefix}.retail.lightspeed.app/api"
    end
  end
end
