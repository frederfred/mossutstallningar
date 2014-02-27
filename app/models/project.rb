class Project < ActiveRecord::Base
  has_many :images

  validates :title, presence: true

  accepts_nested_attributes_for :images, allow_destroy: true

  def self.search(query)
    where('title LIKE ?', "%#{query}%")
  end
end