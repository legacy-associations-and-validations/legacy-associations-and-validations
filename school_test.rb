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

  def test_validate_creation_of_new_school_without_name_creates_error
    assert_raises do
      School.create!
    end
  end

  def test_create_school
    assert School.create!(name: "Friends\' Central School")
  end

  def test_schools_associate_with_terms
    school = School.create!(name: "Bob\'s Art School for the Left Handed")
    term = school.terms.create!(name: "American History", starts_on: Date.new(1999,9,10),ends_on: Date.new(2000/11/20))
    assert_equal school.id, term.school_id
  end

  def test_schools_have_courses_through_terms
    school = School.create!(name: "hogwarts")
    term = school.terms.create!(name: "American History", starts_on: Date.new(1999,9,10),ends_on: Date.new(2000/11/20))
    course1 = term.courses.create!(name: "course 1", course_code: "aaa111")
    course2 = term.courses.create!(name: "course 2", course_code: "aaa112")
    assert course1, school.courses.first
    assert course2, school.courses.last
  end

end
