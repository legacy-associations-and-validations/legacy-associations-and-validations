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

class ReadingTest < Minitest::Test

  def test_truth
    assert true
  end

  def test_create_reading
    assert Reading.create!(lesson_id: 2, caption: "hey", url: "https://www.reading.com", order_number: 3, created_at: Date.today, updated_at: Date.today)
  end

  def test_order_number_presence_validation
    assert_raises do
      Reading.create!(lesson_id: 2, caption: "hey", url: "https://www.reading.com", order_number: nil, created_at: Date.today, updated_at: Date.today)
    end
  end

  def test_lesson_id_presence_validation
    assert_raises do
      Reading.create!(lesson_id: nil, caption: "hey", url: "https://www.reading.com", order_number: 3, created_at: Date.today, updated_at: Date.today)
    end
  end

  def test_url_presence_validation
    assert_raises do
      Reading.create!(lesson_id: 2, caption: "hey", url: nil, order_number: 3, created_at: Date.today, updated_at: Date.today)
    end
  end

  def test_url_contains_https_validation
    assert_raises do
      Reading.create!(lesson_id: 2, caption: "hey", url: "www.reading.com", order_number: 3, created_at: Date.today, updated_at: Date.today)
    end
    assert Reading.create!(lesson_id: 2, caption: "hey", url: "https://www.reading.com", order_number: 3, created_at: Date.today, updated_at: Date.today)
  end

end
