require 'minitest/autorun'
require 'minitest/pride'
require './migration'
require './application'
require './user'

ActiveRecord::Base.establish_connection(
adapter:  'sqlite3',
database: 'test.sqlite3'
)

ActiveRecord::Migration.verbose = false

begin ApplicationMigration.migrate(:down); rescue; end
ApplicationMigration.migrate(:up)

class UserTest < Minitest::Test

  def test_truth
    assert true
  end

  def test_new_user
    new_user = User.create!(first_name: "Alex", last_name: "Guy", email: "amax3000@gmail.com")
    refute_equal new_user.id, nil
  end

  def test_new_user_needs_first_name
    assert_raises do
      User.create!(last_name: "Guy", email: "amax3001@gmail.com")
    end
  end

  def test_new_user_needs_last_name
    assert_raises do
      User.create!(first_name: "Alex", email: "amax3002@gmail.com")
    end
  end

  def test_new_user_needs_email
    assert_raises do
      User.create!(first_name: "Alex", last_name: "Guy")
    end
  end

  def test_email_is_unique_block
    User.create!(first_name: "Alex", last_name: "Guy", email: "amax3002@gmail.com")
    assert_raises do
      User.create!(first_name: "Larry", last_name: "Guy", email: "amax3002@gmail.com")
    end
  end

  def test_email_is_valid_no_AT_sign
    assert_raises do
      User.create!(first_name: "Alex", last_name: "Guy", email: "amax3004gmail.com")
    end
  end

  def test_email_is_valid_no_com_ending
    assert_raises do
      User.create!(first_name: "Alex", last_name: "Guy", email: "amax3005@gmail.")
    end
  end

  def test_email_photo_url_error_for_not_starting_correctly
    assert_raises do
    User.create!(first_name: "Alex", last_name: "Guy", email: "amax3006@gmail.com", photo_url: "dsafhttp://")
    end
  end

  def test_email_is_valid_http_start_for_photo_url
    new_user = User.create!(first_name: "Alex", last_name: "Guy", email: "amax3007@gmail.com",photo_url: "http://")
    assert_equal new_user.photo_url, "http://"
  end

  def test_email_is_valid_https_start_for_photo_url
    new_user = User.create!(first_name: "Alex", last_name: "Guy", email: "amax3008@gmail.com",photo_url: "https://")
    assert_equal new_user.photo_url, "https://"
  end

end
