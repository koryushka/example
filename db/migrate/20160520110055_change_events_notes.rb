class ChangeEventsNotes < ActiveRecord::Migration
  def change
    execute <<-SQL
      DROP VIEW IF EXISTS complex_events;
      ALTER TABLE events DROP COLUMN notes RESTRICT;
      ALTER TABLE events ADD COLUMN notes TEXT;
      CREATE  OR REPLACE VIEW complex_events AS
        SELECT * FROM recurring_events_for('epoch')
        UNION ALL (SELECT * FROM events WHERE frequency IS NULL)
    SQL
  end
end
