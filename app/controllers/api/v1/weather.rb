# lib/api/v1/weather.rb
require 'yahoo_weather'
require 'geoip'
require 'date'

module API
  module V1
    class Weather < Grape::API

      resource :weather do

        desc 'Get city weather by IP', {
                                   notes: <<-NOTE
                                   Cette methode permet de connaitre toutes les informations météorologique en se basant sur l'adresse ip de sortie vers internet et sa localisation.
                                   NOTE
                               }
        params do
          optional :unit, type: String, values: ['celsius', 'fahrenheit'], default: 'celsius', desc: "Unit for temperature"
        end
        get do
          w = YahooWeather::Client.new
          if w
            if params[:ip]
              c = GeoIP.new(Rails.root.join('db', 'GeoLiteCity.dat')).country(params[:ip])
            else
              remote_ip = open(Settings.network['url_akamai_tool']).read rescue {}
              c = GeoIP.new(Rails.root.join('db', 'GeoLiteCity.dat')).country(remote_ip)
            end

            if c
              if (params[:unit] == 'celsius')
                weather_hash = w.fetch_by_location("#{c.city_name}, #{c.country_name}", YahooWeather::Units::CELSIUS)
              else
                weather_hash = w.fetch_by_location("#{c.city_name}, #{c.country_name}", YahooWeather::Units::FAHRENHEIT)
              end

              {
                  city_name: weather_hash.doc['location']['city'],
                  country_name: weather_hash.doc['location']['country'],
                  units: weather_hash.doc['units'],
                  wind: weather_hash.doc['wind'],
                  atmosphere: weather_hash.doc['atmosphere'],
                  previsions: {
                      now: weather_hash.doc['item']['condition'],
                      next: weather_hash.doc['item']['forecast'],
                  },
                  latitude: weather_hash.lat,
                  longitude: weather_hash.long
              }
            else
              error!({ error: "not found", message: "unable to locate you from your ip address" }, 404)
            end

          else
            error!({ error: "not found", message: "unable to find informations about this ip" }, 404)
          end
        end

        desc 'Get city weather by defined city', {
                                                   notes: <<-NOTE
                                                   Cette methode permet de connaitre toutes les informations météorologique en se basant sur une ville definie dans un pays defini.
                                                   NOTE
                                               }
        params do
          optional :unit, type: String, values: ['celsius', 'fahrenheit'], default: 'celsius', desc: "Unit for temperature"
          requires :city, type: String, regexp: /^[a-zA-Z\-\ ]+$/, desc: "City to search"
          requires :country, type: String, regexp: /^[a-zA-Z\-\ ]+$/, desc: "Country of city searched"
        end
        get '/:country/:city' do
          w = YahooWeather::Client.new
          if w

            if (params[:unit] == 'celsius')
              weather_hash = w.fetch_by_location("#{params[:city]}, #{params[:country]}", YahooWeather::Units::CELSIUS)
            else
              weather_hash = w.fetch_by_location("#{params[:city]}, #{params[:country]}", YahooWeather::Units::FAHRENHEIT)
            end

            {
                city_name: weather_hash.doc['location']['city'],
                country_name: weather_hash.doc['location']['country'],
                units: weather_hash.doc['units'],
                wind: weather_hash.doc['wind'],
                atmosphere: weather_hash.doc['atmosphere'],
                sun: weather_hash.doc['astronomy'],
                previsions: {
                    now: weather_hash.doc['item']['condition'],
                    next: weather_hash.doc['item']['forecast'],
                },
                latitude: weather_hash.lat,
                longitude: weather_hash.long
            }
          else
            error!({ error: "not found", message: "unable to locate #{params[:city]}, #{params[:country]}" }, 404)
          end
        end

      end
    end
  end
end

