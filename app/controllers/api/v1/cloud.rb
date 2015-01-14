# lib/api/v1/cloud.rb

module API
  module V1
    class Cloud < Grape::API
      resource :cloud do

        desc 'Get pricing for cloud providers', {
            notes: <<-NOTE
              Cette methode permet de connaitre toutes les informations sur les prix par heure de differents providers.

              ## Requête
              * Le paramètre de provider `:provider` est obligatoire
              * Pour le moment, seuls Amazon `aws` et Google Compute Engine `gce` sont disponibles.
            NOTE
        }
        params do
          requires :provider, type: String, values: Settings.cloud['providers'], desc: "Define provider to get"
        end
        get '/:provider/pricing' do

          case params[:provider]
            when 'aws'
              begin
                aws = JSON.parse(open(Settings.cloud['provider_aws_url']).read)
              rescue
                error!("api #{params[:provider]} not available", 503)
              end

              result = {}
              aws.each do |instance|
                result[instance['instance_type']] = {
                    spec: {
                      vcpu: instance['vCPU'],
                      memory: instance['memory'],
                      network: instance['network_performance'],
                      storage: instance['storage'],
                    },
                    pricing: instance['pricing']
                }
              end
              result
            when 'gce'
              begin
                gce = JSON.parse(open(Settings.cloud['provider_gce_url']).read)
              rescue
                error!("api #{params[:provider]} not available", 503)
              end

              result = {}
              gce['gcp_price_list'].each do |instance, details|
                if (instance =~ /^CP\-COMPUTEENGINE/)
                  result[instance.gsub('CP-COMPUTEENGINE-VMIMAGE-', '').underscore.gsub('_','-')] = {
                      spec: {
                          vcpu: details['cores'],
                          memory: details['memory'],
                          network: 'N/A',
                          storage: {
                              ssd: details['ssd']
                          },
                      },
                      pricing: {
                          europe: details['eu'],
                          usa: details['us'],
                          asia_pacific: details['apac']
                      }
                  }
                end
              end
              result
          end
        end
      end
    end
  end
end

