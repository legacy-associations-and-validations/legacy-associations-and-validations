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

# Gotta run migrations before we can run tests.  Down will fail the first time,
# so we wrap it in a begin/rescue.
begin ApplicationMigration.migrate(:down); rescue; end
ApplicationMigration.migrate(:up)


# Finally!  Let's test the thing.
class ApplicationTest < Minitest::Test

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
    new_lesson = a.lessons.create(name: "American History", description: "American History from 1820-1914", outline: "I will put outline here.")
    assert_equal a.id, new_lesson.course_id
  end

  def test_destroy_course_and_lesson
    a = Course.new(name: "History", course_code: "HIS4556", color: "Red", period: "eighth", description: "History Course")
    a.save
    new_lesson = a.lessons.create(name: "American History", description: "American History from 1820-1914", outline: "I will put outline here.")
    a.destroy
    assert_raises do
      Course.find(a.id)
    end
    assert_raises do
      Lesson.find(new_lesson.id)
    end
  end


end
