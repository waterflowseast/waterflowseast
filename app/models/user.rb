class User < ActiveRecord::Base
  attr_accessible :nickname, :email, :password, :password_confirmation, :avatar, :words, :invitation_token
end
