FactoryGirl.define do
  factory :user do
    sequence(:name) { |i| "user#{i}" }
    sequence(:fullname) { |i| "User  #{i}" }
    sequence(:email) { |i| "user.#{i}@example.com" }
    password 'password'
    password_confirmation 'password'

    factory :employee do
      rate 10
    end

    factory :manager do
      admin true
    end

    factory :admin do
      admin true
      master true
    end

    first_time false
  end

  factory :invoice do
    user
    start_date '2016-12-30'
    end_date '2016-12-31'
    status 'Started'
  end

  factory :payment do
    invoice
    date '2016-12-30'
    description 'Testing'
    hours 3
  end
end