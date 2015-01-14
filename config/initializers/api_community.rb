require 'rest-client'


if (Settings.config['community'] == true)
  puts "[apipub] Thanks for sharing your api and help community to have access to awesome data ! =)".green
  begin
    api_routes = []

    API::Root.routes.each do |route|
      info = route.instance_variable_get :@options

      api_routes.push(
          {
              :route  => info[:path].gsub(':version', Settings.config['api_version']).gsub('(.:format)',''),
              :method => info[:method],
              :description => info[:description]
          }
      )
    end

    RestClient.post(
      Settings.config['community_registry_url'],
      {
        :name => Settings.config['api_name'] || Settings.config['api_baseurl'] || false,
        :url => Settings.config['api_baseurl'] || false,
        :version => Settings.config['api_version'] || false,
        'routes[]' => api_routes || false,
        :env => Rails.env
      }
    )
  rescue Exception => e
    puts "[apipub] Something went wrong when i try to register to apipub ... Anyway, we will try on next restart".yellow
  end

else
  puts "[apipub] Please consider that if you disable community mode, you'll not be referenced on ApiPub and you can't use your API with distributed operations mode".yellow
end