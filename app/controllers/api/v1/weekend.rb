# lib/api/v1/weekend.rb
require 'date'

module API
  module V1
    class Weekend < Grape::API

      resource :weekend do

        desc 'Know if we are on week end', {
                                             notes: <<-NOTE
                                             Cette methode permet de savoir si aujourd'hui ou demain est le weekend.
                                             NOTE
                                         }
        params do
          requires :period, values: ['today', 'tomorrow'], type: String, desc: "'today' or 'tomorrow'"
        end
        get '/:period' do
          case params[:period]
            when 'today'
              {
                  status: (Date.today.saturday?) ? true : (Date.today.sunday?) ? true : false
              }
            when 'tomorrow'
              {
                  status: (Date.tomorrow.saturday?) ? true : (Date.tomorrow.sunday?) ? true : false
              }
          end


        end

        desc 'Check if weekend for a custom date', {
                                                     notes: <<-NOTE
                                                     Cette methode permet de savoir si la date choisie est un jour de weekend.
                                                    NOTE
                                                 }
        params do
          requires :year, type: Integer, desc: "Set custom year"
          requires :month, type: Integer, desc: "Set custom month"
          requires :day, type: Integer, desc: "Set custom day"
        end
        get '/custom/:year/:month/:day' do

          date = Date.civil(params[:year],params[:month],params[:day])
          {
              year: params[:year],
              month: params[:month],
              day: params[:day],
              status: (date.saturday?) ? true : (date.sunday?) ? true : false
          }
        end
      end
    end
  end
end

