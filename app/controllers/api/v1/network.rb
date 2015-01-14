# lib/api/v1/network.rb
require 'geoip'
require 'open-uri'
require 'net/ping'
require 'resolv'

module API
  module V1
    class Network < Grape::API

      resource :network do

        desc 'Get user ip location', {
                                       notes: <<-NOTE
                                       Cette methode permet d'obtenir des informations sur son adresse ip de sortie vers internet.
                                       NOTE
                                   }
        get '/myip' do
          remote_ip = open(Settings.network['url_akamai_tool']).read rescue {}
          c = GeoIP.new(Rails.root.join('db', 'GeoLiteCity.dat')).country(remote_ip)

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
            {
                ip: remote_ip,
            }
          end
        end

        desc 'Get response of DNS checks', {
                                             notes: <<-NOTE
                                             Cette methode permet de resoudre des noms DNS.
                                             Cette option est compatible avec community.
                                             NOTE
                                         }
        params do
          requires :host, type: String, regexp: /^[a-z0-9\.]+$/, desc: "Define host to check"
        end
        get '/check/dns' do

          if (params[:host] =~ /^([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})$/)
            dns = Resolv.new.getnames(params[:host]) rescue []
          else
            dns = Resolv.new.getaddresses(params[:host]) rescue []
          end

          {
              host: params[:host],
              response: dns,
              community: (params[:community] ? call_community_api(route, params) : false)
          }
        end

        desc 'Get response of url', {
            notes: <<-NOTE
                                             Cette methode permet de faire des requêtes HTTP et HTTPS sur des urls DNS.
                                             Cette option est compatible avec community.
        NOTE
        }
        params do
          optional :port, type: Integer, regexp: /^[0-9]+$/, default: 80, desc: "Define port to check"
          requires :url, type: String, regexp: /^[a-z0-9\-_:\.\/\?]+$/, desc: "Define url to check (http or https)"
        end
        get '/check/url' do

          request = open(params[:url])

          {
              url: params[:url],
              response: request.status,
              details: request.meta,
              community: (params[:community] ? call_community_api(route, params) : false)
          }
        end

        desc 'Get response of tcp/udp/ping checks', {
                                                  notes: <<-NOTE
                                                  Cette methode permet de faire des requêtes TCP, UDP et PING sur des noms de domaine ou adresse IP.
                                                  Cette option est compatible avec community.
                                                  NOTE
                                              }
        params do
          requires :protocol, type: String, values: ['tcp','udp', 'ping'], desc: "Define Protocol to check"
          requires :host, type: String, regexp: /^[a-z0-9\.]+$/, desc: "Define host to check"
          optional :port, type: Integer, regexp: /^[0-9]+$/, default: 7, desc: "Define port to check"
        end
        get '/check/:protocol' do

          case params[:protocol]
            when 'tcp'
              host = Net::Ping::TCP.new(params[:host], params[:port], 1)
            when 'udp'
              host = Net::Ping::UDP.new(params[:host], params[:port], 1)
            when 'ping'
              host = Net::Ping::External.new(params[:host], 7, 1)
          end

          {
              response: host.ping?,
              details: host,
              community: (params[:community] ? call_community_api(route, params) : false)
          }

        end

      end
    end
  end
end

