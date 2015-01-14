# lib/api/v1/holidays.rb
require 'date'
require 'holidays'
require 'net/http'

module API
  module V1
    class Holidays < Grape::API

      resource :holidays do
        desc 'Check if today or tomorrow is a public holiday', {
                                                                 notes: <<-NOTE
                                                                 Cette methode permet de savoir si aujourd'hui ou demain est des jours fériés.
                                                                 NOTE
                                                             }
        params do
          requires :period, type: String, values: ['today', 'tomorrow'], default: 'today', desc: "'today' or 'tomorrow'"
          optional :country_code, type: String, regexp: /^([a-z_]{2,5})+$/, default: 'fr', desc: "Set country"
        end
        get '/public/:period' do
          case params[:period]
            when 'today'
              date = Date.civil(Date.today.year,Date.today.month,Date.today.day)
            when 'tomorrow'
              date = Date.civil(Date.tomorrow.year,Date.tomorrow.month,Date.tomorrow.day)
          end

          if date.holiday?(params[:country_code].to_sym)
            message = "good news, it is public holiday #{params[:period]}"
            response = true
            details = date.holidays(params[:country_code].to_sym)
          else
            message = "sorry, you have to work #{params[:period]}"
            response = false
            details = false
          end

          {
            status: response,
            country_code: params[:country_code],
            date: date,
            message: message,
            details: details
          }
        end

        desc 'Check if today or tomorrow is a school holiday (only for French countries)', hidden: true
        params do
          requires :period, type: String, values: ['today', 'tomorrow'], default: 'today', desc: "Set type of holidays you look for"
          requires :zone, type: String, values: ['A', 'B', 'C'], desc: "Set zone"
        end
        get '/school/:period/:zone' do
          case params[:period]
            when 'today'
              date = Date.civil(Date.today.year,Date.today.month,Date.today.day)
            when 'tomorrow'
              date = Date.civil(Date.tomorrow.year,Date.tomorrow.month,Date.tomorrow.day)
          end

          cal_file=(Net::HTTP.get 'media.education.gouv.fr', "/ics/Calendrier_Scolaire_Zone_#{params[:zone]}.ics")
          cals = Icalendar.parse(cal_file)

          error!({ error: "developpement in progress" }, 503)
        end

        desc 'Check public holiday for a custom date', {
                                                         notes: <<-NOTE
                                                         Cette methode permet de savoir si la date choisie est des jours fériés.

                                                        ### Requête

                                                        Les paramètres suivants sont necessaires :

                                                        * L'année `:year`
                                                        * Le mois `:month`
                                                        * Le jour `:day`
                                                        NOTE
                                                     }
        params do
          optional :country_code, type: String, regexp: /^([a-z_]{2,5})+$/, desc: "Set country"
          requires :year, type: Integer, desc: "Set custom year"
          requires :month, type: Integer, desc: "Set custom month"
          requires :day, type: Integer, desc: "Set custom day"
        end
        get '/public/custom/:year/:month/:day' do

          date = Date.civil(params[:year],params[:month],params[:day])

          if params[:country_code]
            if date.holiday?(params[:country_code].to_sym)
              response = true
              details = date.holidays(params[:country_code].to_sym)
              message = "good news, it is public holiday"
            else
              response = false
              details = false
              message = "sorry, you have to work"
            end
          else
            response = true
            details = date.holidays()
            message = "you can show if this day is public holiday in the world"
          end

          {
              status: response,
              country_code: params[:country_code],
              date: date,
              message: message,
              details: details
          }

        end

      end
    end
  end
end

