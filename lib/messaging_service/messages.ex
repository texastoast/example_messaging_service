defmodule MessagingService.Messages do
  @moduledoc """
  Module for managing messages.
  """

  alias MessagingService.Contacts
  alias MessagingService.Conversations

  @spec get_new_message_assocs(map()) :: map()
  def get_new_message_assocs(params) do
    contacts = Contacts.get_contact_info_by_type(params)

    conversation =
      Conversations.find_or_create_conversation_by_contacts([contacts.from, contacts.to])

    {from_number_id, from_email_id} =
      Contacts.get_contact_method_ids(
        contacts.from,
        Map.get(params, "from"),
        Map.get(params, "type")
      )

    {to_number_id, to_email_id} =
      Contacts.get_contact_method_ids(contacts.to, Map.get(params, "to"), Map.get(params, "type"))

    %{
      conversation_id: conversation.id,
      from_number_id: from_number_id,
      to_number_id: to_number_id,
      from_email_id: from_email_id,
      to_email_id: to_email_id
    }
  end
end
