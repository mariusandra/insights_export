module InsightsExport
  class ExportModels
    def self.config_file
      InsightsExport.configuration.export_path
    end

    def self.load
      structure = YAML::load_file(config_file) rescue get_structure

      structure.select { |k, v| v['enabled'] }.map do |k, v|
        [k, v.merge({ 'columns' => v['columns'].select { |_, vv| vv.present? } })]
      end.to_h
    end

    def self.export
      input = YAML::load_file(config_file) rescue nil
      structure = get_structure.deep_stringify_keys
      output = {}

      if input.present?
        output = input.dup.deep_stringify_keys
        structure.each do |model_name, model_structure|
          # we already had this model in the output
          if output[model_name].present?
            model_structure.each do |key, value|
              if key == 'custom'
                next
              elsif key == 'columns' || key == 'aggregate'
                output[model_name][key] ||= {}
                value.each do |value_key, value_value|
                  existing = output[model_name][key][value_key]
                  if existing != false
                    output[model_name][key][value_key] = (existing || {}).merge(value_value)
                  end
                end
              elsif key != 'enabled'
                output[model_name][key] = value
              end
            end
          else
            output[model_name] = model_structure
          end
        end
      else
        output = structure
      end

      File.open(config_file, 'w') {|f| f.write output.deep_stringify_keys.to_yaml }
    end

    def self.get_structure
      Rails.application.eager_load! if Rails.env.development?

      models = ActiveRecord::Base.descendants

      # skip all abstract classes (e.g. ApplicationRecord)
      models = models.reject { |m| m.abstract_class? }

      # models to include
      only_models = InsightsExport.configuration.only_models
      if only_models.present?
        models = models.select { |m| only_models.select { |lm| lm.is_a?(Regexp) ? lm.match(m.to_s) : lm == m.to_s }.present? }
      end

      # models to exclude
      except_models = InsightsExport.configuration.except_models
      if except_models.present?
        models = models.reject { |m| except_models.select { |lm| lm.is_a?(Regexp) ? lm.match(m.to_s) : lm == m.to_s }.present? }
      end

      # sort them
      models = models.sort_by { |m| m.to_s }

      # cache the strings
      model_strings = models.map(&:to_s)

      # show that we're doing something
      puts "InsightsExport: #{model_strings.join(', ')}"

      # this will contain our result
      return_object = {}

      models.each do |model|
        columns_hash = model.columns_hash

        begin
          model_structure = {
            enabled: true,
            model: model.to_s,
            table_name: model.table_name,
            primary_key: model.primary_key,
            columns: columns_hash.map do |key, column|
              obj = if column.type.in? %i(datetime date)
                      { type: :time }
                    elsif column.type.in? %i(integer decimal float)
                      { type: :number }
                    elsif column.type.in? %i(string text)
                      { type: :string }
                    elsif column.type.in? %i(boolean)
                      { type: :boolean }
                    elsif column.type.in? %i(json)
                      { type: :payload }
                    elsif column.type.in? %i(geography)
                      { type: :geo }
                    else
                      puts "Warning! Unknown column type: :#{column.type} for #{model.to_s}, column #{key}"
                      { unknown: column.type }
                    end

              if key == model.primary_key
                obj[:index] = :primary_key
              end

              [key.to_sym, obj]
            end.to_h,
            custom: {},
            links: {
              incoming: {},
              outgoing: {}
            }
          }

          model.reflections.each do |association_name, reflection|
            begin
              reflection_class = reflection.class_name.gsub(/^::/, '')

              next unless model_strings.include?(reflection_class)

              if reflection.macro == :belongs_to
                # reflection_class # User
                # reflection.foreign_key # user_id
                # reflection.association_primary_key # id

                model_structure[:columns].delete(reflection.foreign_key.to_sym)
                model_structure[:links][:outgoing][association_name] = {
                  model: reflection_class,
                  model_key: reflection.association_primary_key,
                  my_key: reflection.foreign_key
                }
              elsif reflection.macro.in? %i(has_one has_many)
                # skip has_many :through associations
                if reflection.options.try(:[], :through).present?
                  next
                end

                model_structure[:links][:incoming][association_name] = {
                  model: reflection_class,
                  model_key: reflection.foreign_key,
                  my_key: reflection.association_primary_key
                }
              else
                puts "Warning! Unknown reflection :#{reflection.macro} for association '#{association_name}' on model '#{model.to_s}'"
              end
            rescue => error
              puts "!! Error when exporting association '#{association_name}' on model '#{model.to_s}'"
              print_exception(error)
            end
          end

          return_object[model.to_s] = model_structure
        rescue => error
          puts "!! Error when exporting model '#{model.to_s}'"
          print_exception(error)
        end
      end

      return_object.sort_by { |k, v| k }.to_h.deep_stringify_keys
    end

    def self.print_exception(error)
      puts "!! Exception: #{error.message}"
      if InsightsExport.configuration.debug
        puts error.backtrace
      else
        puts "-> Set config.debug = true to see the full backtrace"
      end
    end
  end
end

