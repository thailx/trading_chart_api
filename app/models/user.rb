class User < ActiveRecord::Base
  attr_accessor :login
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :rememberable,
         :trackable, :validatable, authentication_keys: [:login]
  include DeviseTokenAuth::Concerns::User
  has_many :portfolios
end
