require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'from_omniauth creates a new user with google credentials' do
    auth = mock_google_auth('user1@example.com', '123456789')
    user = User.from_omniauth(auth)

    assert user.persisted?
    assert_equal 'user1@example.com', user.email
    assert_equal 'Test User', user.name
    assert_equal '123456789', user.google_uid
    assert_equal 'access_token_value', user.google_access_token
    assert_equal 'refresh_token_value', user.google_refresh_token
  end

  test 'from_omniauth finds existing user by google_uid' do
    auth1 = mock_google_auth('user2@example.com', '987654321')
    user1 = User.from_omniauth(auth1)

    auth2 = mock_google_auth('user2@example.com', '987654321')
    user2 = User.from_omniauth(auth2)

    assert_equal user1.id, user2.id
  end

  test 'google_token_expired? returns true when token is expired' do
    user = User.new(
      email: 'user3@example.com',
      name: 'Test',
      google_uid: '111111',
      google_token_expires_at: 1.day.ago
    )

    assert user.google_token_expired?
  end

  test 'google_token_expired? returns false when token is valid' do
    user = User.new(
      email: 'user4@example.com',
      name: 'Test',
      google_uid: '222222',
      google_token_expires_at: 1.day.from_now
    )

    assert_not user.google_token_expired?
  end

  test 'google_token_expired? returns false when expires_at is nil' do
    user = User.new(
      email: 'user5@example.com',
      name: 'Test',
      google_uid: '333333',
      google_token_expires_at: nil
    )

    assert_not user.google_token_expired?
  end

  private

  def mock_google_auth(email = 'test@example.com', uid = '123456789')
    info = Struct.new(:email, :name).new(email, 'Test User')
    credentials = Struct.new(:token, :refresh_token, :expires_at).new(
      'access_token_value',
      'refresh_token_value',
      (Time.current + 1.hour).to_i
    )
    Struct.new(:uid, :info, :credentials).new(uid, info, credentials)
  end
end
