# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'

# Include both the migration and the app itself
require './migration'
require './application'

require './reading'
require './lesson'

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
class LessonTest < Minitest::Test

  def test_truth
    assert true
  end

  def test_classes_exist
    assert Lesson
    assert Reading
  end

  def test_creation_of_new_lesson
    a = Lesson.new(course_id: 12, name: "American History", description: "American History from 1820-1914", outline: "I will put outline here.", lead_in_question: nil, pre_class_assignment_id: nil, in_class_assignment_id: nil, slide_html: nil)
    a.save
    assert_equal 12, a.course_id
  end

  def test_creation_of_new_reading
    a = Reading.new(caption: "Reading_1", url: "google.com")
    a.save
    assert_equal "Reading_1", a.caption
  end

  def test_assign_reading_to_lesson
    a = Lesson.new(course_id: 12, name: "American History", description: "American History from 1820-1914", outline: "I will put outline here.")
    a.save
    new_reading = a.readings.create(caption: "Reading_1", url: "google.com")
    assert_equal a.id, new_reading.lesson_id
  end

  def test_destroy_lesson_and_reading
    a = Lesson.new(course_id: 12, name: "American History", description: "American History from 1820-1914", outline: "I will put outline here.")
    a.save
    new_reading = a.readings.create(caption: "Reading_1", url: "google.com")
    a.destroy
    assert_raises do
      Lesson.find(a.id)
    end
    assert_raises do
      Reading.find(new_reading.id)
    end
  end

  def test_add_inclass_assignment_to_lesson
    a = Lesson.new(course_id: 12, name: "American History", description: "American History from 1820-1914", outline: "I will put outline here.")
    a.save
    new_assignment = Assignment.new(name: "First inclass reading")
    new_assignment.save
    a.add_inclass_assignment(new_assignment)
    assert_equal a.in_class_assignment_id, new_assignment.id
  end


end
