require 'rails_config'
#all_config = YAML.load_file("#{Rails.root}/config/config.yml") || {}
#env_config = all_config[Rails.env] || {}
#Settings = OpenStruct.new(env_config)

RailsConfig.setup do |config|
  config.const_name = "Settings"
  config.use_env = true
end