require 'minitest/autorun'
require 'minitest/pride'

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

  #NOT THE RIGHT WAY TO DO THIS
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

end
