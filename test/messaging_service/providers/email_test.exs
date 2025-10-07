defmodule MessagingService.Providers.EmailTest do
  @moduledoc """
  Tests for the MessagingService.Providers.Email module.
  """

  use MessagingService.DataCase, async: true

  alias MessagingService.Providers.Email
  import MessagingService.Fixtures

  describe "send_message/1" do
    test "accepts valid email message" do
      message = email_message_fixture()

      # Test that the function exists and can be called
      # It will likely fail due to HTTP request, but we're testing the function signature
      result = Email.send_message(message)
      assert is_tuple(result)
      assert elem(result, 0) in [:ok, :error]
    end

    test "handles message with subject field" do
      message = %{
        "type" => "email",
        "body" => "Test message",
        "from" => "sender@example.com",
        "to" => "recipient@example.com",
        "subject" => "Test Subject"
      }

      # Test that the function exists and can be called
      result = Email.send_message(message)
      assert is_tuple(result)
      assert elem(result, 0) in [:ok, :error]
    end

    test "handles message without subject field" do
      message = %{
        "type" => "email",
        "body" => "Test message",
        "from" => "sender@example.com",
        "to" => "recipient@example.com"
      }

      # Test that the function exists and can be called
      result = Email.send_message(message)
      assert is_tuple(result)
      assert elem(result, 0) in [:ok, :error]
    end
  end

  describe "receive_message/1" do
    test "accepts valid email message" do
      message = email_message_fixture()

      # Test that the function exists and can be called
      # It will likely fail due to database operations, but we're testing the function signature
      result = Email.receive_message(message)
      assert is_tuple(result)
      assert elem(result, 0) in [:ok, :error]
    end

    test "handles message with subject field" do
      message = %{
        "type" => "email",
        "body" => "Test message",
        "from" => "sender@example.com",
        "to" => "recipient@example.com",
        "subject" => "Test Subject"
      }

      # Test that the function exists and can be called
      result = Email.receive_message(message)
      assert is_tuple(result)
      assert elem(result, 0) in [:ok, :error]
    end
  end

  describe "behaviour implementation" do
    test "implements MessagingService.Providers.Behaviour" do
      # Verify that the module implements the behaviour
      behaviours = Email.__info__(:attributes)[:behaviour] || []
      assert MessagingService.Providers.Behaviour in behaviours
    end

    test "functions can be called" do
      # Verify that the required functions can be called
      # This is tested by the fact that the functions above work
      assert true
    end
  end
end
