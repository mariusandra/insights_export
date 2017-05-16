module InsightsExport
  class Railtie < Rails::Railtie
    rake_tasks do
      namespace :insights do
        desc 'Export database structure to config/insights.yml'
        task export: :environment do
          Rails.application.eager_load!
          InsightsExport::ExportModels.export
        end
      end
    end
  end
end
