FactoryGirl.define do
  factory :user do
    sequence(:name) { |i| "user#{i}" }
    sequence(:fullname) { |i| "User #{i}" }
    sequence(:email) { |i| "user.#{i}@example.com" }
    password 'password'
    password_confirmation 'password'

    factory :employee do
      rate 10
      profile 1
    end

    factory :manager do
      profile 2
    end

    factory :admin do
      profile 3
    end

    first_time false
  end

  factory :invoice do
    user
    start_date '2016-01-30'
    status 'In Progress'
    check_no 1234
  end

  factory :payment do
    invoice
    date '2016-01-30'
    description 'Testing'
    hours 3
  end
end