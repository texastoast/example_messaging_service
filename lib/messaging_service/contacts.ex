defmodule MessagingService.Contacts do
  @moduledoc """
  Module for managing contacts.
  """

  import Ecto.Query

  alias MessagingService.Schemas.ContactPhoneNumber
  alias MessagingService.Schemas.ContactEmail
  alias MessagingService.Schemas.Contact
  alias MessagingService.Repo

  @spec find_or_create_contact_by_phone_number(String.t()) :: Contact.t()
  def find_or_create_contact_by_phone_number(phone_number) do
    contact =
      Contact
      |> join(:inner, [c], p in ContactPhoneNumber, on: c.id == p.contact_id)
      |> where([c, p], p.number == ^phone_number)
      |> preload([:contact_phone_numbers, :contact_emails])
      |> Repo.one()

    if contact do
      contact
    else
      {:ok, contact} = Repo.insert(%Contact{name: ""})
      Repo.insert(%ContactPhoneNumber{number: phone_number, contact_id: contact.id})
      Repo.preload(contact, [:contact_phone_numbers, :contact_emails])
    end
  end

  @spec find_or_create_contact_by_email(String.t()) :: Contact.t()
  def find_or_create_contact_by_email(email) do
    contact =
      Contact
      |> join(:inner, [c], e in ContactEmail, on: c.id == e.contact_id)
      |> where([c, e], e.email == ^email)
      |> preload([:contact_phone_numbers, :contact_emails])
      |> Repo.one()

    if contact do
      contact
    else
      {:ok, contact} = Repo.insert(%Contact{name: ""})
      Repo.insert(%ContactEmail{email: email, contact_id: contact.id})
      Repo.preload(contact, [:contact_phone_numbers, :contact_emails])
    end
  end

  @spec find_phone_number_id_by_number(Contact.t(), String.t()) :: binary() | nil
  def find_phone_number_id_by_number(contact, phone_number) do
    contact.contact_phone_numbers
    |> Enum.find(fn phone_number_record -> phone_number_record.number == phone_number end)
    |> case do
      nil -> nil
      phone_number_record -> phone_number_record.id
    end
  end

  @spec find_email_id_by_address(Contact.t(), String.t()) :: binary() | nil
  def find_email_id_by_address(contact, email) do
    contact.contact_emails
    |> Enum.find(fn email_record -> email_record.email == email end)
    |> case do
      nil -> nil
      email_record -> email_record.id
    end
  end

  def get_contact_info_by_type(params) do
    type = Map.get(params, "type")

    from_contact =
      case type do
        "email" ->
          find_or_create_contact_by_email(Map.get(params, "from"))

        _ ->
          find_or_create_contact_by_phone_number(Map.get(params, "from"))
      end

    to_contact =
      case type do
        "email" ->
          find_or_create_contact_by_email(Map.get(params, "to"))

        _ ->
          find_or_create_contact_by_phone_number(Map.get(params, "to"))
      end

    %{from: from_contact, to: to_contact}
  end

  def get_contact_method_ids(contact, contact_value, type) do
    case type do
      "email" ->
        email_record = Repo.get_by(ContactEmail, contact_id: contact.id, email: contact_value)
        {nil, email_record && email_record.id}

      _ ->
        phone_record =
          Repo.get_by(ContactPhoneNumber, contact_id: contact.id, number: contact_value)

        {phone_record && phone_record.id, nil}
    end
  end
end
