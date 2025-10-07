ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(MessagingService.Repo, :manual)

# Start Mox
Mox.defmock(MessagingService.HTTPClientMock, for: MessagingService.HTTPClientBehaviour)
