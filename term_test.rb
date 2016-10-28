require 'minitest/autorun'
require 'minitest/pride'
require 'pry'
require './migration'
require './application'
require './school'

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
    new_school = School.create!(name: "New School")
    new_term = new_school.terms.create!(name: "American History", starts_on: Date.new(1999,9,10),ends_on: Date.new(2000/11/20))
    assert_equal new_term.school_id, new_school.id
  end

  def test_terms_associate_with_courses
    new_school = School.create!(name: "New School")
    new_term = new_school.terms.create!(name: "American History", starts_on: Date.new(1999,9,10),ends_on: Date.new(2000/11/20))
    course = new_term.courses.create!(name: "course 1", course_code: "aaa111")
    assert_equal new_term.id, course.term_id
  end

  def test_terms_will_not_delete_with_dependents
    new_school = School.create!(name: "New School")
    new_term = new_school.terms.create!(name: "American History", starts_on: Date.new(1999,9,10),ends_on: Date.new(2000/11/20))
    course1 = new_term.courses.create!(name: "course 1", course_code: "aaa111")
    course2 = new_term.courses.create!(name: "course 2", course_code: "aaa112")
    refute new_term.destroy
  end

end
