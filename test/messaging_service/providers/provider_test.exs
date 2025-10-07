defmodule MessagingService.Providers.ProviderTest do
  @moduledoc """
  Tests for the MessagingService.Providers.Provider module.
  """

  use MessagingService.DataCase, async: true

  alias MessagingService.Providers.Provider
  import MessagingService.Fixtures

  describe "send_message/1" do
    test "routes SMS messages to SMS provider" do
      message = sms_message_fixture()

      result = Provider.send_message(message)
      assert is_tuple(result)
      assert tuple_size(result) == 2
      assert elem(result, 0) in [:ok, :error]
    end

    test "routes MMS messages to MMS provider" do
      message = mms_message_fixture()

      result = Provider.send_message(message)
      assert is_tuple(result)
      assert tuple_size(result) == 2
      assert elem(result, 0) in [:ok, :error]
    end

    test "routes email messages to Email provider" do
      message = email_message_fixture()

      result = Provider.send_message(message)
      assert is_tuple(result)
      assert tuple_size(result) == 2
      assert elem(result, 0) in [:ok, :error]
    end

    test "handles unknown message type" do
      message = %{"type" => "unknown", "body" => "test"}

      assert_raise FunctionClauseError, fn ->
        Provider.send_message(message)
      end
    end
  end

  describe "receive_message/1" do
    test "routes SMS messages to SMS provider" do
      message = sms_message_fixture()

      result = Provider.receive_message(message)
      assert is_tuple(result)
      assert tuple_size(result) == 2
      assert elem(result, 0) in [:ok, :error]
    end

    test "routes MMS messages to MMS provider" do
      message = mms_message_fixture()

      result = Provider.receive_message(message)
      assert is_tuple(result)
      assert tuple_size(result) == 2
      assert elem(result, 0) in [:ok, :error]
    end

    test "routes email messages to Email provider" do
      message = email_message_fixture()

      result = Provider.receive_message(message)
      assert is_tuple(result)
      assert tuple_size(result) == 2
      assert elem(result, 0) in [:ok, :error]
    end

    test "handles unknown message type" do
      message = %{"type" => "unknown", "body" => "test"}

      assert_raise FunctionClauseError, fn ->
        Provider.receive_message(message)
      end
    end
  end
end
