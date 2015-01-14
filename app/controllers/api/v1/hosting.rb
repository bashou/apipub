# lib/api/v1/hosting.rb
require 'geoip'
require 'open-uri'
require 'nokogiri'
require 'json'

module API
  module V1
    class Hosting < Grape::API

      resource :hosting do

        desc 'Get availability of server for specified provider', {
                                                                    notes: <<-NOTE
                                                                    Cette methode permet de connaitre toutes les informations sur le stock (et les prix pour certains) disponible chez differents providers en terme de serveurs dédiés.
                                                                    NOTE
                                                                }
        params do
          requires :provider, type: String, values: ['online_net', 'ovh', 'ovh-kimsufi', 'ovh-soyoustart', 'firstheberg'], desc: "Define provider to check"
        end

        get '/:provider/servers/stock' do

          case params[:provider]
            when 'firstheberg'
              begin
                string_api = JSON.parse(open(Settings.hosting['url_firstheberg']).read)
              rescue
                error!("api #{params[:provider]} not available", 503)
              end

              stock = []
              string_api.each do |key, value|
                stock.push({
                               server: key,
                               stock: value['hdd'] + value['ssd'],
                               detail: value
                           })
              end

              stock
            when 'online_net'
              begin
                string_page = Nokogiri::HTML(open(Settings.hosting['url_online_net']))
              rescue
                  error!("api #{params[:provider]} not available", 503)
              end

              stock = []

              content_table = string_page.xpath('//table/tbody/tr')
              content_table.collect do |row|
                detail = {}
                [
                    [:name, 'td[1]/text()'],
                    [:cpu, 'td[2]/text()'],
                    [:ram, 'td[3]/text()'],
                    [:disk, 'td[4]/text()'],
                    [:network, 'td[5]/text()'],
                    [:stock, 'td[6]/span[1]/text()'],
                    [:price, 'td[7]/text()'],
                ].each do |name, xpath|
                  detail[name] = row.at_xpath(xpath).to_s.strip
                end

                stock.push({
                    server: detail[:name],
                    stock: (detail[:stock] != 'back order' ? detail[:stock].to_i : 0),
                    details: detail
                           })

              end

              stock

            when 'ovh-kimsufi'
              begin
                string_api = JSON.parse(open(Settings.hosting['url_ovh']).read)
              rescue
                error!("api #{params[:provider]} not available", 503)
              end

              stock = []

              server_ks = {}
              server_ks['150sk10'] = 'KS-1'
              server_ks['150sk20'] = 'KS-2a'
              server_ks['150sk21'] = 'KS-2b'
              server_ks['150sk22'] = 'KS-2c'
              server_ks['150sk30'] = 'KS-3'
              server_ks['150sk40'] = 'KS-4'
              server_ks['150sk50'] = 'KS-5'
              server_ks['150sk60'] = 'KS-6'

              dc = {}
              dc['bhs'] = 'Beauharnois, Canada (Americas)'
              dc['gra'] = 'Gravelines, France'
              dc['rbx'] = 'Roubaix, France (Western Europe)'
              dc['sbg'] = 'Strasbourg, France (Central Europe)'
              dc['par'] = 'Paris, France'

              string_api['answer']['availability'].each do |server|
                if server_ks.include?(server['reference'])

                  server_zone = []
                  server_stock = 0
                  server['zones'].each do |zone|

                    server_stock_tmp = (zone['availability'] =~ /^(unavailable|unknown)$/) ? 0 : 1
                    zone.reject!{ |k| k == '__class' }
                    server_zone.push({
                                         id: zone['zone'],
                                         location: (dc.include?(zone['zone'])) ? dc[zone['zone']] : 'N/A',
                                         stock: server_stock_tmp
                                     })

                    server_stock = server_stock + server_stock_tmp

                  end

                  stock.push({
                                 server: server_ks[server['reference']],
                                 stock: server_stock,
                                 details: {
                                     zones: server_zone,
                                 }
                             })
                end
              end

              stock
            when 'ovh-soyoustart'
              begin
                string_api = JSON.parse(open(Settings.hosting['url_ovh']).read)
              rescue
                error!("api #{params[:provider]} not available", 503)
              end
              stock = []

              server_ks = {}
              server_ks['142sys4'] = 'SYS-IP-1'
              server_ks['142sys5'] = 'SYS-IP-2'
              server_ks['142sys8'] = 'SYS-IP-4'
              server_ks['142sys6'] = 'SYS-IP-5'
              server_ks['142sys10'] = 'SYS-IP-5S'
              server_ks['142sys7'] = 'SYS-IP-6'
              server_ks['142sys9'] = 'SYS-IP-6S'
              server_ks['143sys4'] = 'E3-SAT-1'
              server_ks['143sys1'] = 'E3-SAT-2'
              server_ks['143sys2'] = 'E3-SAT-3'
              server_ks['143sys3'] = 'E3-SAT-4'
              server_ks['143sys13'] = 'E3-SSD-1'
              server_ks['143sys10'] = 'E3-SSD-2'
              server_ks['143sys11'] = 'E3-SSD-3'
              server_ks['143sys12'] = 'E3-SSD-4'
              server_ks['141bk1'] = 'BK-8T'
              server_ks['141bk2'] = 'BK-24T'

              dc = {}
              dc['bhs'] = 'Beauharnois, Canada (Americas)'
              dc['gra'] = 'Gravelines, France'
              dc['rbx'] = 'Roubaix, France (Western Europe)'
              dc['sbg'] = 'Strasbourg, France (Central Europe)'
              dc['par'] = 'Paris, France'

              string_api['answer']['availability'].each do |server|
                if server_ks.include?(server['reference'])

                  server_zone = []
                  server_stock = 0
                  server['zones'].each do |zone|

                    server_stock_tmp = (zone['availability'] =~ /^(unavailable|unknown)$/) ? 0 : 1
                    zone.reject!{ |k| k == '__class' }
                    server_zone.push({
                                         id: zone['zone'],
                                         location: (dc.include?(zone['zone'])) ? dc[zone['zone']] : 'N/A',
                                         stock: server_stock_tmp
                                     })

                    server_stock = server_stock + server_stock_tmp

                  end

                  stock.push({
                                 server: server_ks[server['reference']],
                                 stock: server_stock,
                                 details: {
                                     zones: server_zone,
                                 }
                             })
                end
              end

              stock
          end

        end

      end
    end
  end
end

