defmodule MessagingService.Structs.NewMessage do
  @moduledoc """
  Struct that represents a new message that has not yet been persisted.
  """
  defstruct [:type, :body, :attachments, :messaging_provider_id, :from_number_id, :to_number_id, :from_email_id, :to_email_id]

  @type t :: %__MODULE__{
    type: :sms | :mms | :email,
    body: String.t(),
    attachments: [String.t()],
    messaging_provider_id: String.t(),
    from_number_id: String.t(),
    to_number_id: String.t(),
    from_email_id: String.t(),
    to_email_id: String.t()
  }
end
