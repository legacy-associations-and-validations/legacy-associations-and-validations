require 'minitest/autorun'
require 'minitest/pride'
require './migration'
require './application'
require './assignment'

ActiveRecord::Base.establish_connection(
adapter:  'sqlite3',
database: 'test.sqlite3'
)

ActiveRecord::Migration.verbose = false

begin ApplicationMigration.migrate(:down); rescue; end
ApplicationMigration.migrate(:up)

class AssignmentTest < Minitest::Test

  def setup
    Course.delete_all
  end

  def test_truth
    assert true
  end

  def test_creation_of_assignment
    a = Course.create!(name: "History", course_code: "HIS4556", color: "Red", period: "eighth", description: "History Course")
    new_assignment = a.assignments.create!(name: "First_day_of_reading", percent_of_grade: 0.02)
    refute_equal new_assignment.id, nil
  end

  def test_new_assignment_needs_name
    a = Course.create!(name: "History", course_code: "HIS4556", color: "Red", period: "eighth", description: "History Course")
    assert_raises do
    a.assignments.create!(percent_of_grade: 0.02)
    end
  end

  def test_new_assignment_needs_percent_of_grade
    a = Course.create!(name: "History", course_code: "HIS4556", color: "Red", period: "eighth", description: "History Course")
    assert_raises do
    a.assignments.create!(name: "First_day_of_reading")
    end
  end

  def test_new_assignment_needs_course_id
    assert_raises do
    Assignment.create!(name: "First_day_of_reading", percent_of_grade: 0.02)
    end
  end

  def test_creation_of_assignment_unique_name_and_course_id
    a = Course.create!(name: "History", course_code: "HIS4556", color: "Red", period: "eighth", description: "History Course")
    b = Course.create!(name: "Art", course_code: "ART4556", color: "Blue", period: "first", description: "Modern Art Course")
    new_assignment = a.assignments.create!(name: "First_day_of_reading", percent_of_grade: 0.02)
    new_assignment2 = b.assignments.create!(name: "First_day_of_reading", percent_of_grade: 0.03)
    refute_equal new_assignment.id, nil
    refute_equal new_assignment2.id, nil
  end

  def test_creation_of_assignment_unique_name_and_course_id_produce_error
    a = Course.create!(name: "History", course_code: "HIS4556", color: "Red", period: "eighth", description: "History Course")
    a.assignments.create!(name: "First_day_of_reading", percent_of_grade: 0.02)
    assert_raises do
    a.assignments.create!(name: "First_day_of_reading", percent_of_grade: 0.03)
    end
  end

end
