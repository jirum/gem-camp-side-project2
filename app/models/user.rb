class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates_uniqueness_of :username
  validates :phone, phone: {allow_blank: true}
  has_many :addresses
  belongs_to :parent, class_name: "User", optional: true
  has_many :children, class_name: "User", foreign_key: 'parent_id'

  mount_uploader :image, ImageUploader

  def client?
    role == 'client'
  end

  def admin?
    role == 'admin'
  end
end
