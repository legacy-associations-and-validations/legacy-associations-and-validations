class School < ActiveRecord::Base

  has_many :terms

  def add_terms(term)
    self.id = term.school_id
    term.save
  end

  default_scope { order('name') }
end
