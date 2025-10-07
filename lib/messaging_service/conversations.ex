defmodule MessagingService.Conversations do
  @moduledoc """
  Module for managing conversations.
  """
  import Ecto.Query
  import Ecto.Changeset

  alias MessagingService.Schemas.Conversation
  alias MessagingService.Schemas.Contact
  alias MessagingService.Schemas.Message
  alias MessagingService.Repo

  @spec list_conversations() :: [Conversation.t()]
  def list_conversations do
    # this should return an ordered list of conversations, most recent first, with the messages preloaded and ordered by most recent first
    Conversation
    |> order_by(desc: :inserted_at)
    |> Repo.all()
    |> Repo.preload(contacts: [:contact_phone_numbers, :contact_emails])
  end

  @spec list_messages_for_conversation(Conversation.t()) :: [Message.t()]
  def list_messages_for_conversation(conversation_id) do
    Message
    |> where(conversation_id: ^conversation_id)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  @spec find_or_create_conversation_by_contacts([Contact.t()]) :: Conversation.t()
  def find_or_create_conversation_by_contacts(contacts) do
    contact_ids = Enum.map(contacts, & &1.id)

    conversation =
      Repo.one(
        from c in Conversation,
          join: contact in assoc(c, :contacts),
          where: contact.id in ^contact_ids,
          group_by: c.id,
          having: count(contact.id) == ^length(contact_ids)
      )

    if conversation do
      conversation
    else
      changeset =
        %Conversation{}
        |> change()
        |> put_assoc(:contacts, contacts)

      {:ok, conversation} = Repo.insert(changeset)
      conversation
    end
  end
end
