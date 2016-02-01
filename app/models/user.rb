class User < ActiveRecord::Base
  has_many :invoices, inverse_of: :user

  has_secure_password

  validates :name, presence: true
#  validates :email,
#            format: {with: /\A # begin of input
#[-\w.]+ # dash, wordy, plus, or dot characters
#@ # required at sign
#[-a-z\d.]+ # dash, letter, digit, or dot chars
#\z # end of input
#/xi}

  validates :password, presence: true
  #validates :rate, presence: true
end
