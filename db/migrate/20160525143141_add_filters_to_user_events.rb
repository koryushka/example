class AddFiltersToUserEvents < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        execute <<-SQL
          DROP FUNCTION IF EXISTS user_events(INTEGER);
          DROP FUNCTION IF EXISTS user_events(INTEGER, INTEGER);
          CREATE OR REPLACE FUNCTION public.user_events(
              current_user_id integer,
              events_filter character varying DEFAULT NULL::character varying)
            RETURNS SETOF events AS
          $BODY$
          DECLARE family_id INTEGER;
            is_my_events BOOLEAN DEFAULT NULL;
            is_family_events BOOLEAN DEFAULT NULL;
            family_member_id INTEGER DEFAULT NULL;
          BEGIN
            /* see https://weezlabs.atlassian.net/browse/CUR-1534 for filters info */
            IF events_filter IS NOT NULL THEN
              IF events_filter = 'me' THEN
                is_my_events := TRUE;
              ELSIF events_filter = 'family' THEN
                is_family_events = TRUE;
              ELSE
                BEGIN
                  family_member_id := CAST(events_filter AS INTEGER);
                EXCEPTION WHEN invalid_text_representation THEN
                  family_member_id := NULL;
                END;
              END IF;
            END IF;

            IF is_my_events IS NULL THEN
              SELECT groups.id INTO family_id FROM groups WHERE groups.user_id = current_user_id;
              IF family_id IS NULL THEN
                SELECT p.participationable_id INTO family_id FROM participations p
                WHERE p.participationable_type = 'Group' AND p.user_id = current_user_id;
              END IF;
            END IF;

            RETURN QUERY
            SELECT * FROM events
            WHERE events.user_id = current_user_id AND (events_filter IS NULL OR is_family_events IS NULL AND family_member_id IS NULL)
            UNION ALL
            SELECT events.* FROM participations p
            INNER JOIN events ON events.id = p.participationable_id
              AND p.participationable_type = 'Event'
              AND p.user_id = current_user_id
            WHERE events_filter IS NULL OR family_member_id IS NOT NULL AND events.user_id = family_member_id
            UNION ALL
            SELECT events.* FROM (
              SELECT p.user_id FROM participations p
              WHERE p.participationable_type = 'Group' AND p.participationable_id = family_id
                          AND p.status = 2 AND p.user_id != current_user_id
              UNION ALL
              SELECT groups.user_id FROM groups WHERE id = family_id
            ) u
            INNER JOIN events ON events.user_id = u.user_id
            WHERE events.id NOT IN (
              SELECT id FROM events
              WHERE events.user_id = current_user_id
              UNION ALL
              SELECT events.id FROM participations p
              INNER JOIN events ON events.id = p.participationable_id
              AND p.participationable_type = 'Event' AND p.user_id = current_user_id
            ) AND (is_my_events IS NULL OR events_filter IS NULL OR family_member_id IS NOT NULL AND events.user_id = family_member_id);
          END;
          $BODY$
          LANGUAGE plpgsql STABLE;
        SQL
      end
      dir.down do
        execute <<-SQL
          CREATE OR REPLACE FUNCTION user_events(current_user_id INTEGER) RETURNS SETOF events AS
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
              SELECT id FROM events
              WHERE events.user_id = current_user_id
              UNION ALL
              SELECT events.id FROM participations p
              INNER JOIN events ON events.id = p.participationable_id
              AND p.participationable_type = 'Event' AND p.user_id = current_user_id
            );
          END;
          $BODY$
          LANGUAGE plpgsql STABLE;
        SQL
      end
    end
  end
end
