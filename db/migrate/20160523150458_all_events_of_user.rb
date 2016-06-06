class AllEventsOfUser < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        execute <<-SQL
          CREATE OR REPLACE FUNCTION public.user_events(current_user_id INTEGER) RETURNS SETOF events AS
            $BODY$
            DECLARE family_id INTEGER;
            BEGIN
              SELECT groups.id INTO family_id FROM groups WHERE groups.user_id = current_user_id;
              IF family_id IS NULL THEN
                SELECT p.participationable_id INTO family_id FROM participations p
                WHERE p.participationable_type = 'Group' AND p.user_id = current_user_id;
              END IF;

              RETURN QUERY
              SELECT * FROM events
              WHERE events.user_id = current_user_id
              UNION ALL
              SELECT events.* FROM participations p
              INNER JOIN events ON events.id = p.participationable_id
                AND p.participationable_type = 'Event'
                AND p.user_id = current_user_id
              UNION ALL
              SELECT events.* FROM (
                SELECT p.user_id FROM participations p
                WHERE p.participationable_type = 'Group' AND p.participationable_id = family_id
                            AND p.status = #{Participation::ACCEPTED} AND p.user_id != current_user_id
                UNION ALL
                SELECT groups.user_id FROM groups WHERE id = family_id
              ) u
              INNER JOIN events ON events.user_id = u.user_id
              WHERE events.id NOT IN (
                SELECT events.id FROM participations p
                INNER JOIN events ON events.id = p.participationable_id
                AND p.participationable_type = 'Event' AND p.user_id = current_user_id
              );
            END;
            $BODY$
            LANGUAGE plpgsql STABLE;
        SQL
      end
      dir.down do
        execute <<-SQL
          DROP FUNCTION IF EXISTS user_events(INTEGER)
        SQL
      end
    end
  end
end
