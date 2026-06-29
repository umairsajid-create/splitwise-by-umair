# frozen_string_literal: true

require "searchkick"

Searchkick.client = Elasticsearch::Client.new(
  url: ENV.fetch("ELASTICSEARCH_URL", "http://localhost:9200"),
  transport_options: { request: { timeout: 5 } }
)

Searchkick.disable_callbacks if Rails.env.test?

# Ensure searchkick is on ActiveRecord even if the gem loaded after AR boot
ActiveRecord::Base.extend(Searchkick::Model) unless ActiveRecord::Base.respond_to?(:searchkick)

Rails.application.config.to_prepare do
  ApplicationRecord.extend(Searchkick::Model) unless ApplicationRecord.respond_to?(:searchkick)
end
