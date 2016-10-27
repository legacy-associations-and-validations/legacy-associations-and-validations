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

  def test_create_course
    assert Course.create!
  end

  def test_courses_associate_with_students
    course = Course.create!
    course_student = course.course_students.create!
    assert_equal course.id, course_student.course_id
  end

  def test_courses_will_not_delete_with_dependents
    course = Course.create!
    course_student1 = course.course_students.create!
    course_student2 = course.course_students.create!
    refute course.destroy
  end

end
