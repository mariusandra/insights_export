# insights_export

For use with [insights](https://github.com/mariusandra/insights). Read the installation instructions [here](https://github.com/mariusandra/insights).

## Configuration

To configure the gem, create a file like `config/initializers/insights_export.rb` with this content:

```rb
InsightsExport.configure do |config|
  # The path to the export file
  config.export_path = "#{Rails.root}/config/insights.yml"

  # Export only models in this list
  # Array of strings or regexps to filter or blank to export all.
  config.only_models = []

  # Exclude these models from the export
  # Array of strings or regexps to filter or blank to export all.
  config.except_models = []

  # Print a backtrace when the export throws an exception.
  config.debug = false
end
```
