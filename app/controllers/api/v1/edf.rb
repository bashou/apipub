# lib/api/v1/edf.rb
require 'date'

module API
  module V1
    class Edf < Grape::API

      resource :edf do
        desc 'Get EDF Tempo option', {
                                       notes: <<-NOTE
                                       L'option Tempo propose des prix variables selon les jours et les heures d'utilisation.
                                       NOTE
                                   }
        get '/tempo' do
          # Get pages content for Tempo/EDF history
          page_tempo = open(Settings.edf['url_tempo']).read rescue {}
          tempo = page_tempo.scan(/.*<span class=\"period\">(.*)<\/span>.*/)

          {
              describe: "L'option Tempo propose des prix variables selon les jours et les heures d'utilisation.",
              today: tempo[1].first.underscore,
              tomorrow: tempo[4].first.underscore
          }

        end


        desc 'Get EDF days of EJP option (Effacement des Jours de Pointe)', {
                                                                              notes: <<-NOTE
                                                                              Cette methode permet d'obtenir le status de jour et du lendemain de l'option EJP EDF pour une zone `:zone` definie. L'option EJP (Effacement des Jours de Pointe) me fait bénéficier 343 jours par an d’un tarif avantagueux, proche de celui des Heures Creuses de l’option Heures Pleines / Heures Creuses.
                                                                              NOTE
                                                                          }
        get '/ejp' do
          # Get pages content for EJP and EJP/EDF history
          page_ejp = open(Settings.edf['url_ejp']).read rescue {}
          page_ejp_history = open(Settings.edf['url_ejp_history']).read rescue {}

          ejp = page_ejp.scan(/.*FRONT\/NetExpress\/img\/ejp_(.*).png.*/)
          ejp_days = page_ejp_history.scan(/.*<td.*>(\d+)<\/td>.*/)

          {
              describe: "L'option EJP (Effacement des Jours de Pointe) me fait beneficier 343 jours par an d'un tarif avantagueux, proche de celui des Heures Creuses de l'option Heures Pleines / Heures Creuses.",
              nord: {
                  today: ejp[0].first,
                  tomorrow: ejp[7].first,
                  remaining_days: ejp_days[0].first.to_i
              },
              paca: {
                  today: ejp[1].first,
                  tomorrow: ejp[8].first,
                  remaining_days: ejp_days[1].first.to_i
              },
              ouest: {
                  today: ejp[2].first,
                  tomorrow: ejp[9].first,
                  remaining_days: ejp_days[2].first.to_i
              },
              sud: {
                  today: ejp[3].first,
                  tomorrow: ejp[10].first,
                  remaining_days: ejp_days[3].first.to_i
              },
          }

        end

        desc 'Get EDF days of EJP option (Effacement des Jours de Pointe) for specific zone', {
                                                                                                notes: <<-NOTE
                                                                                                                                                                              Cette methode permet d'obtenir le status de jour et du lendemain de l'option EJP EDF pour une zone `:zone` definie. L'option EJP (Effacement des Jours de Pointe) me fait bénéficier 343 jours par an d’un tarif avantagueux, proche de celui des Heures Creuses de l’option Heures Pleines / Heures Creuses.
                                                                                                NOTE
                                                                                            }
        params do
          optional :zone, type: String, values: ['nord','paca','ouest','sud'], desc: "French zone needed"
        end
        get '/ejp/:zone' do
          # Get pages content for EJP and EJP/EDF history
          page_ejp = open("https://particuliers.edf.com/gestion-de-mon-contrat/options-tempo-et-ejp/option-ejp/l-observatoire-2584.html").read rescue {}
          page_ejp_history = open("http://edf-ejp-tempo.sfr-sh.fr/index.php?m=eh").read rescue {}

          ejp = page_ejp.scan(/.*FRONT\/NetExpress\/img\/ejp_(.*).png.*/)
          ejp_days = page_ejp_history.scan(/.*<td.*>(\d+)<\/td>.*/)

          case params[:zone]
            when 'nord'
              today = ejp[0].first
              tomorrow = ejp[7].first
              remaining_days = ejp_days[0].first.to_i
            when 'paca'
              today = ejp[1].first
              tomorrow = ejp[8].first
              remaining_days = ejp_days[1].first.to_i
            when 'ouest'
              today = ejp[2].first
              tomorrow = ejp[9].first
              remaining_days = ejp_days[2].first.to_i
            when 'sud'
              today = ejp[3].first
              tomorrow = ejp[10].first
              remaining_days = ejp_days[3].first.to_i
          end

          {
              zone: params[:zone],
              describe: "L'option EJP (Effacement des Jours de Pointe) me fait beneficier 343 jours par an d'un tarif avantagueux, proche de celui des Heures Creuses de l'option Heures Pleines / Heures Creuses.",
              today: today,
              tomorrow: tomorrow,
              remaining_days: remaining_days
          }

        end

      end
    end
  end
end

