# lib/api/root.rb
require 'grape-swagger'
require 'uri'
require 'open-uri'

module CommunityHelpers
  def call_community_api(route, params)
    begin
      uri = (Settings.config['community_call_url'] + '?route=' + route + '&params=' + params)
      begin
        api_response = JSON.parse(open(uri.to_s, {:read_timeout => 10}).read)
      rescue
        api_response = {}
      end

      return api_reponse
    rescue
      return []
    end
  end
end

module API
  class Root < Grape::API
#    prefix 'api'
    version Settings.config['api_version']
    format :json
    content_type :xml, 'application/xml'
    content_type :json, 'application/json'

    helpers CommunityHelpers

    mount API::V1::Api
    mount API::V1::Cloud
    mount API::V1::Edf
    mount API::V1::Geolocation
    mount API::V1::Holidays
    mount API::V1::Hosting
    mount API::V1::Network
    mount API::V1::Season
    mount API::V1::Weather
    mount API::V1::Weekend

    add_swagger_documentation(
        mount_path: 'doc.json',
        markdown: GrapeSwagger::Markdown::KramdownAdapter,
        api_version: Settings.config['api_version'],
        base_path: Settings.config['api_baseurl'],
        info: {
            :title => 'Documentation',
            :description => 'Public API to simplify data access',
            :contact => 'apipub@nassi.me'
        }
    )

    error_formatter :json, API::ErrorFormatter
  end
end
