FactoryGirl.define do
  factory :event do
=begin
    title character varying(128) NOT NULL,
  user_id integer NOT NULL,
  starts_on date,
  ends_on date,
  starts_at timestamp without time zone,
  ends_at timestamp without time zone,
  separation integer NOT NULL DEFAULT 1,
  count integer,
  until date,
  timezone_name character varying NOT NULL DEFAULT 'Etc/UTC'::character varying,
  kind integer NOT NULL DEFAULT 0,
  latitude double precision,
  longitude double precision,
  location_name character varying,
  notes
=end
    title {Faker::Lorem.word}
    user
    starts_at {Date.yesterday}
    ends_at {Date.yesterday + 1.hour}
    notes {Faker::Lorem.sentence(4)}
    latitude {Faker::Address.latitude}
    longitude {Faker::Address.longitude}
    frequency 'once'
    updated_at Time.now

    factory :repeating_event_with_cancellation do
      after(:create) do |event|
        create_list(:event_cancellation, 1, event: event)
        create_list(:event_recurrence, 2, event: event)
      end
    end
  end
end
