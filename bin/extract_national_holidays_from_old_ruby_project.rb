#!/usr/bin/env ruby
# frozen_string_literal: true

require 'national_holidays'
require 'countries'

holidays = NationalHolidays::Main.new

config_directory = File.expand_path('../conf', __dir__)

Dir.chdir config_directory do
  holidays.countries.countries.each do |country_name|
    country_config = holidays.country(country_name)

    country_name = 'united arab emirates' if country_name == 'dubai'
    country_name = country_name.tr('_', ' ')
    country = ISO3166::Country.find_country_by_name(country_name)
    country_code = country.alpha2.downcase
    local_language_code = country.languages.first

    Dir.mkdir(country_code) unless Dir.exist?(country_code)

    Dir.chdir country_code do
      country_config.regions.each do |region_config|
        config = {
          'name' => region_config.region_name,
          'years' => {}
        }

        region_config.regional_national_holidays.each do |national_holiday|
          year = national_holiday.start_date.year.to_s

          if national_holiday.start_date != national_holiday.end_date
            abort "Holiday #{[country_code, region_code, national_holiday.english_name].join(' > ')} has a different start and end date"
          end

          config['years'][year] ||= []
          config['years'][year] << {
            'public_holiday' => true,
            'date' => national_holiday.start_date.strftime('%Y-%m-%d'),
            'names' => {
              'en' => national_holiday.english_name,
              local_language_code => national_holiday.local_name
            }
          }
        end

        File.open("#{region_config.region_code}.yml", 'w') do |file|
          file.write(config.to_yaml)
        end
      end
    end
  end
end
