# insights_export

For use with [insights](https://github.com/mariusandra/insights). Read the installation instructions [here](https://github.com/mariusandra/insights).

## Configuration

To configure the gem, create a file like `config/initializers/insights_export.rb` with this content:

```rb
InsightsExport.configure do |config|
  # The path to the export file
  # Defaults to "#{Rails.root}/config/insights.yml"
  config.export_path = "#{Rails.root}/config/insights2.yml"

  # Export only models in this list
  # Array of strings to filter or blank to export all.
  config.only_models = []

  # Exclude these models from the export
  # Array of strings to filter or blank to export all.
  config.except_models = []
end
```
