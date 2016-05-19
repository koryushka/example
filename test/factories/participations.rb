FactoryGirl.define do
  factory :participation do
    user
    association :sender, factory: :user
    participationable nil
    status Participation::PENDING

    factory :participation_with_participationable do
      transient do
        participationable_type :group
      end
      before(:create) do |participation, evaluator|
        participation.participationable = FactoryGirl.create(
            evaluator.participationable_type, owner: participation.user)
      end
    end
  end
end
