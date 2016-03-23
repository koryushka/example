class AddingTimesatampsToEvents < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        add_column :events, :created_at, :datetime
        add_column :events, :updated_at, :datetime

        execute <<-SQL
          CREATE OR REPLACE VIEW complex_events AS
            SELECT * FROM recurring_events_for('epoch')
            UNION ALL (SELECT * FROM events WHERE frequency IS NULL)
        SQL
      end
      dir.down do
        execute <<-SQL
          DROP VIEW IF EXISTS complex_events
        SQL

        remove_column :events, :created_at
        remove_column :events, :updated_at

        execute <<-SQL
          CREATE VIEW complex_events AS
            SELECT * FROM recurring_events_for('epoch')
            UNION ALL (SELECT * FROM events WHERE frequency IS NULL)
        SQL
      end
    end
  end
end
