# Script for populating the database.
import Ecto.Query

alias MessagingService.Schemas.{Contact, ContactEmail, ContactPhoneNumber}
alias MessagingService.Repo

if is_nil(Repo.one(from c in Contact, where: c.name == "Local User")) do
  # First contact: Local User
  local_user = Repo.insert!(%Contact{name: "Local User"})
  Repo.insert!(%ContactPhoneNumber{number: "+12016661234", contact_id: local_user.id})
  Repo.insert!(%ContactEmail{email: "user@usehatchapp.com", contact_id: local_user.id})
end

if is_nil(Repo.one(from c in Contact, where: c.name == "External Contact")) do
  # Second contact: External Contact
  external_contact = Repo.insert!(%Contact{name: "External Contact"})
  Repo.insert!(%ContactPhoneNumber{number: "+18045551234", contact_id: external_contact.id})
  Repo.insert!(%ContactEmail{email: "contact@gmail.com", contact_id: external_contact.id})
end
