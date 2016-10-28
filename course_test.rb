
# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'

# Include both the migration and the app itself
require './migration'
require './application'

require './reading'
require './lesson'
require './course'

# Overwrite the development database connection with a test connection.
ActiveRecord::Base.establish_connection(
adapter:  'sqlite3',
database: 'test.sqlite3'
)

ActiveRecord::Migration.verbose = false

# Gotta run migrations before we can run tests.  Down will fail the first time,
# so we wrap it in a begin/rescue.
begin ApplicationMigration.migrate(:down); rescue; end
ApplicationMigration.migrate(:up)

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

  def setup
    Course.delete_all
  end

  def test_truth
    assert true
  end

  def test_classes_exist
    assert Lesson
    assert Course
  end

  def test_creation_of_new_course
    a = Course.new(name: "History", course_code: "HIS4556", color: "Red", period: "eighth", description: "History Course")
    a.save
    assert_equal "History", a.name
  end

  def test_assign_leasson_to_course
    a = Course.new(name: "History", course_code: "HIS4556", color: "Red", period: "eighth", description: "History Course")
    a.save
    new_lesson = a.lessons.create!(name: "American History", description: "American History from 1820-1914", outline: "I will put outline here.")
    assert_equal a.id, new_lesson.course_id
  end

  def test_destroy_course_and_lesson
    a = Course.new(name: "History", course_code: "HIS4556", color: "Red", period: "eighth", description: "History Course")
    a.save
    new_lesson = a.lessons.create!(name: "American History", description: "American History from 1820-1914", outline: "I will put outline here.")
    a.destroy
    assert_raises do
      Course.find(a.id)
    end
    assert_raises do
      Lesson.find(new_lesson.id)
    end
  end

  def test_assign_course_instructor_to_course
    a = Course.new(name: "History", course_code: "HIS4556", color: "Red", period: "eighth", description: "History Course")
    a.save
    new_course_instructor = a.course_instructors.create!
    assert_equal a.id, new_course_instructor.course_id
  end

  def test_destroy_course_but_not_course_instructor
    a = Course.new(name: "History", course_code: "HIS4556", color: "Red", period: "eighth", description: "History Course")
    a.save
    new_course_instructor = a.course_instructors.create!
    a.destroy
    assert_raises do
      Course.find(a.id)
    end
    refute_equal nil, CourseInstructor.find(new_course_instructor.id)
  end


  def test_create_course
    assert Course.create!(name: "history", course_code: "seven")
  end

  def test_courses_associate_with_students
    course = Course.create!(name: "history", course_code: "seven")
    course_student = course.course_students.create!
    assert_equal course.id, course_student.course_id
  end

  def test_courses_will_not_delete_with_dependents
    course = Course.create!(name: "history", course_code: "seven")
    course_student1 = course.course_students.create!
    course_student2 = course.course_students.create!
    refute course.destroy
  end

  def test_assignments_destroyed_if_course_destroyed
    course = Course.create!(name: "history", course_code: "seven")
    assignment1 = course.assignments.create!
    assignment2 = course.assignments.create!
    course.destroy
    assert_raises do
      Assignment.find(assignment1.id)
    end
    assert_raises do
      Assignment.find(assignment2.id)
    end
  end

  def test_courses_cannot_be_created_without_code
    assert_raises do
      Course.create!(name: "history")
    end
  end

  def test_courses_cannot_be_created_without_name
    assert_raises do
      Course.create!(course_code: "seven")
    end
  end

  def test_course_code_for_uniqueness_on_term_id
    term = Term.create!
    term.courses.create!(name: "history", course_code: "seven")
    assert_raises do
      term.courses.create!(name: "math", course_code: "seven")
    end
  end

end
