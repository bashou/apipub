# lib/api/v1/api.rb

module API
  module V1
    class Api < Grape::API
      resource :api do

        desc 'Get version', {
          notes: <<-NOTE
            Cette methode permet d'obtenir la version de l'api.
          NOTE
        }
        get '/version' do
          {
              version: '1',
              date: '31-12-2014'
          }
        end

        desc 'Get Changelog', {
            notes: <<-NOTE
                        Cette methode permet d’obtenir le changelog complet de l'api.
            NOTE
        }
        get '/changelog' do
          {
              latest_version: '1.0.1',
              versions: [
                {
                  date: '02-01-2015',
                  version: '1.0.1',
                  features: [
                    {
                        desc: 'add cloud feature for pricing check between providers',
                        operation: '/v1/cloud/:provider/pricing'
                    },
                    {
                        desc: 'add hosting feature to get dedicated servers availability from providers',
                        operation: '/v1/hosting/:provider/servers/stock'
                    }
                  ],
                  improvements: [
                    {
                        desc: 'add ostruct to manage variables between environnements',
                    }
                  ],
                  bugfix: [
                  ]
                },
                {
                    date: '31-12-2014',
                    version: '1.0.0',
                    features: [
                        {
                            desc: 'add edf features to check edf tempo and ejp',
                            operation: '/v1/edf'
                        },
                        {
                            desc: 'add api features to get api informations',
                            operation: '/v1/api'
                        },
                        {
                            desc: 'add network features to get (for the moment) you public ip address',
                            operation: '/v1/network'
                        },
                        {
                            desc: 'add geolocation features for geolocalisation check',
                            operation: '/v1/geolocation'
                        },
                        {
                            desc: 'add holidays features for public and country holiday check',
                            operation: '/v1/holidays'
                        },
                        {
                            desc: 'add season features to check which season we are',
                            operation: '/v1/season'
                        },
                        {
                            desc: 'add weekend features to check if we are in week-end',
                            operation: '/v1/weekend'
                        },
                        {
                            desc: 'add weather features to get weather informations from geolocation or specified city',
                            operation: '/v1/weather'
                        }
                    ],
                    improvements: [
                    ],
                    bugfix: [
                    ]
                }

              ]
          }
        end
      end
    end
  end
end

