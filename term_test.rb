require 'minitest/autorun'
require 'minitest/pride'
require 'pry'
require './migration'
require './application'

ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'test.sqlite3'
)

ActiveRecord::Migration.verbose = false

begin ApplicationMigration.migrate(:down); rescue; end
ApplicationMigration.migrate(:up)

class ApplicationTest < Minitest::Test

  def test_truth
    assert true
  end

  def test_create_term
    assert Term.create!
  end

  def test_terms_associate_with_courses
    term = Term.create!
    course = term.courses.create!
    assert_equal term.id, course.term_id
  end

  def test_terms_will_not_delete_with_dependents
    term = Term.create!
    course1 = term.courses.create!
    course2 = term.courses.create!
    refute term.destroy
  end

end
