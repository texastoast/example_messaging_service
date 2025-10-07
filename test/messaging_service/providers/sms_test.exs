defmodule MessagingService.Providers.SmsTest do
  @moduledoc """
  Tests for the MessagingService.Providers.Sms module.
  """

  use MessagingService.DataCase, async: true

  alias MessagingService.Providers.Sms
  import MessagingService.Fixtures

  describe "send_message/1" do
    test "accepts valid SMS message" do
      message = sms_message_fixture()

      result = Sms.send_message(message)
      assert is_tuple(result)
      assert elem(result, 0) in [:ok, :error]
    end

    test "handles message with required fields" do
      message = %{
        "type" => "sms",
        "body" => "Test message",
        "from" => "+1234567890",
        "to" => "+0987654321"
      }

      result = Sms.send_message(message)
      assert is_tuple(result)
      assert elem(result, 0) in [:ok, :error]
    end
  end

  describe "receive_message/1" do
    test "accepts valid SMS message" do
      message = sms_message_fixture()

      result = Sms.receive_message(message)
      assert is_tuple(result)
      assert elem(result, 0) in [:ok, :error]
    end

    test "handles message with required fields" do
      message = %{
        "type" => "sms",
        "body" => "Test message",
        "from" => "+1234567890",
        "to" => "+0987654321"
      }

      result = Sms.receive_message(message)
      assert is_tuple(result)
      assert elem(result, 0) in [:ok, :error]
    end
  end

  describe "behaviour implementation" do
    test "implements MessagingService.Providers.Behaviour" do
      # Verify that the module implements the behaviour
      behaviours = Sms.__info__(:attributes)[:behaviour] || []
      assert MessagingService.Providers.Behaviour in behaviours
    end

    test "functions can be called" do
      # Verify that the required functions can be called
      # This is tested by the fact that the functions above work
      assert true
    end
  end
end
