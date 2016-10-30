class Reading < ActiveRecord::Base
  
  belongs_to :lesson
  validates_presence_of :order_number, :lesson_id, :url
  validates :url, format: { with: /\A(http|https):\/\// }

  default_scope { order('order_number') }

  scope :pre, -> { where("before_lesson = ?", true) }
  scope :post, -> { where("before_lesson != ?", true) }

  def clone
    dup
  end
end
