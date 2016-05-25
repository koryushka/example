class ComplexEventsDefaultTimeZone < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        execute <<-SQL
          CREATE  OR REPLACE VIEW complex_events AS
            SELECT * FROM recurring_events_for('epoch', 'now()', 'UTC')
        SQL
      end
      dir.down do
        execute <<-SQL
          CREATE  OR REPLACE VIEW complex_events AS
            SELECT * FROM recurring_events_for('epoch')
            UNION ALL (SELECT * FROM events WHERE frequency IS NULL)
        SQL
      end
    end
  end
end
