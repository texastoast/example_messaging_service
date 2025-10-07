This is a sample project. The structure is a basic Phoenix project.

Files to pay attention to (the rest are basically unmodified from the base Phoenix install except for config files):
- messaging_service/providers/*
- messaging_service/schemas/*
- messaging_service/api_helpers.ex
- messaging_service/contacts.ex
- messaging_service/conversations.ex
- messaging_service/messages.ex
- messaging_service_web/controllers/webhooks_controller.ex
- messaging_service_web/router.ex

Notes:
- The database is using UUID's for the id fields, so I had to change the test.sh to extract a conversation's UUID in order to use if for the last test.
- Includes behaviours for providers allowing easy addition of new providers.
- Includes ex_unit tests.
