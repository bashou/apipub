# lib/api/error_formatter.rb
module API
  module ErrorFormatter
    def self.call message, backtrace, options, env
      { :response_type => 'error', :response => message }.to_json
    end
  end
end

