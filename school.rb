class School < ActiveRecord::Base

  has_many :terms
  validates_presence_of :name, presence: { message: "must be given please" }

  def add_terms(term)
    self.id = term.school_id
    term.save
  end

  default_scope { order('name') }
end
