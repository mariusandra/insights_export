module InsightsExport
  class Configuration
    # The path to the export file
    # Defaults to "#{Rails.root}/config/insights.yml"
    attr_accessor :export_path

    # Export only models in this list
    # Array of strings to filter or empty array to export all.
    attr_accessor :only_models

    # Exclude these models from the export
    # Array of strings to filter or empty array to export all.
    attr_accessor :except_models

    def initialize
      @export_path = "#{Rails.root}/config/insights.yml"
      @only_models = []
      @except_models = []
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configuration=(config)
    @configuration = config
  end

  def self.configure
    yield configuration
  end
end
