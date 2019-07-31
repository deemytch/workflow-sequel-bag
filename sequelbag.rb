require 'bundler/setup'
require 'sequel'
require 'workflow'

Sequel.extension :pg_array, :pg_inet, :pg_json, :pg_json_ops, :pg_array, :pg_array_ops, :pg_row, :pg_hstore, :pg_json_ops
      Sequel::Model.raise_on_save_failure = false
      Sequel::Model.plugin :validation_helpers
      Sequel::Database.extension :pg_inet, :pg_json, :pg_array, :pg_range, :pg_row, :pg_enum

Sequel::Model.db = $db = Sequel.connect 'postgresql://postgres@localhost/sequelbagz'

class Sequelbag < Sequel::Model
  include Workflow
  workflow_column :jobstatus
  WHITELIST = (self.columns - [:id]).freeze

  workflow do
    state :new do
      event :run, transition_to: :working
    end
    state :working do
      event :done, transition_to: :shutdown
      event :error, transition_to: :failed
    end
    state :shutdown
    state :failed
  end

  def load_workflow_state
    send(self.class.workflow_column)
  end

  def persist_workflow_state(new_value)
    send("#{self.class.workflow_column}=", new_value)
    save(changed: true, validate: false)
    # save(changed: true, columns: [self.class.workflow_column], validate: false)
  end

  def before_validation
    send("#{self.class.workflow_column}=", current_state.to_s) unless send(self.class.workflow_column)
    super
  end

  ## временный костыль от баги в workflow
  def dataset_update( attrs )
    self.class.instance_dataset.where(id: id).update( attrs.delete_if{|k,v| ! WHITELIST.include?(k) } )
  end
end


print "Создаю новый объект: "
x0 = Sequelbag.create
puts "#{ x0.inspect } создан успещно."

print "\nТеперь обновляю его: "
begin
  x0.update(client_id: 1)
  puts " получилось, #{  x0.inspect }."
rescue Exception => e
  puts e
end

print "\nВторая попытка: "
begin
  x0.client_id = 2
  x0.save
  puts " получилось, #{  x0.inspect }."
rescue Exception => e
  puts e
end
