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

  def test_create_school
    assert School.create!
  end

  def test_schools_associate_with_terms
    school = School.create!
    term = school.terms.create!
    assert_equal school.id, term.school_id
  end

end
