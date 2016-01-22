class User < ActiveRecord::Base
  has_secure_password

  validates :name, presence: true
  validates :email, presence: true,
            format: {with: /\A # begin of input
[-\w.]+ # dash, wordy, plus, or dot characters
@ # required at sign
[-a-z\d.]+ # dash, letter, digit, or dot chars
\z # end of input
/xi}

  validates :password, presence: true, on: :create
end
