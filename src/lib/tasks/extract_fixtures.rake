def fixture_entry(table_name, obj)
  res = []
  if table_name == "items2"
    klass = "item2".camelize.constantize
    res << "item2#{obj['id']}:"
  else

    klass = table_name.singularize.camelize.constantize
    res << "#{table_name.singularize}#{obj['id']}:"
  end
  klass.columns.each do |column|
    if obj[column.name]
      if column.name == "text"||column.name == "user_name"
        res << "  #{column.name}: \"#{Regexp.escape(obj[column.name]).gsub("\""){"\\\""}}\""
      elsif column.name == "created_at" || column.name =="updated_at"
        res << "  #{column.name}: #{obj[column.name]}"
      elsif column.name == "status_ids" || column.name == "valid_status_ids" || column.name == "selected_status_ids"
        res << "  #{column.name}: \"#{obj[column.name]}\""
      else
        res << "  #{column.name}: #{obj[column.name]}"
      end
    else
      res << "  #{column.name}: #{obj[column.name]}"
    end
  end
  res.join("\n")
end

namespace :db do
  fixtures_dir = "#{Rails.root.to_s}/test/fixtures/"
  namespace :fixtures do
    desc "Extract database data to the tmp/fixtures/ directory. Use FIXTURES=table_name[,table_name...] to specify table names to extract. Otherwise, all the table data will be extracted."
    task :extract => :environment do
      sql = "SELECT * FROM %s ORDER BY id DESC"
      if ENV['LIMIT']
        sql = sql + " LIMIT " + ENV['LIMIT']
      end
      skip_tables = ["schema_info"]
      ActiveRecord::Base.establish_connection
      FileUtils.mkdir_p(fixtures_dir)

      if ENV['FIXTURES']
        table_names = ENV['FIXTURES'].split(/,/)
      else
        table_names = (ActiveRecord::Base.connection.tables - skip_tables)
      end

      table_names.each do |table_name|
        File.open("#{fixtures_dir}#{table_name}.yml", "w") do |file|
          objects  = ActiveRecord::Base.connection.select_all(sql % table_name)
          objects.each do |obj|
            file.write  fixture_entry(table_name, obj) + "\n\n"
          end
        end
      end
    end
  end
end
