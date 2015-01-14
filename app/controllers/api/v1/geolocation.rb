# lib/api/v1/geolocation.rb
require 'geoip'
require 'geocoder'

module API
  module V1
    class Geolocation < Grape::API

      resource :geolocation do

        desc 'Get user ip location', {
                                       notes: <<-NOTE
                                        Cette methode permet d'obtenir des informations sur la geolocalisation de votre adresse ip de sortie vers internet.
                                       NOTE
                                   }
        params do
          optional :address, type: String, regexp: /^[0-9\.]+$/, desc: "IP to check"
        end
        get '/ip' do
          if params[:address]
            c = GeoIP.new(Rails.root.join('db', 'GeoLiteCity.dat')).country(params[:address])
          else
            remote_ip = open(Settings.network['url_akamai_tool']).read rescue {}
            c = GeoIP.new(Rails.root.join('db', 'GeoLiteCity.dat')).country(remote_ip)
          end

          if c
            {
                ip: c.ip,
                country_name: c.country_name,
                city_name: c.city_name,
                latitude: c.latitude,
                longitude: c.longitude,
                timezone: c.timezone,
                region_name: c.real_region_name
            }
          else
            error!({ error: "not found", message: "unable to find informations about this ip" }, 404)
          end
        end

        desc 'Get city informations', {
                                        notes: <<-NOTE
                                                                                Cette methode permet d'obtenir des informations sur la geolocalisation d'une ville definie dans un pays defini.
                                        NOTE
                                    }
        params do
          requires :city, type: String, regexp: /^[a-zA-Z\-\ ]+$/, desc: "City to search"
          requires :country, type: String, regexp: /^[a-zA-Z\-\ ]+$/, desc: "Country of city searched"
        end
        get '/:country/:city' do
          c = Geocoder.search("#{params[:city]}, #{params[:country]}").first

          if c
            {
                location: c.data['formatted_address'],
                city_name: params[:city],
                country_name: params[:country],
                latitude: c.latitude,
                longitude: c.longitude,
#                details: c.data
            }
          else
            error!({ error: "not found", message: "unable to locate #{params[:city]}, #{params[:country]}" }, 404)
          end
        end

      end
    end
  end
end

