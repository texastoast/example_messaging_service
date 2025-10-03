defmodule MessagingService.Schema do
  @moduledoc """
  Base module used by `Ecto.Schema` modules to define app defaults
  """
  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
      @timestamp_opts [type: :utc_datetime]
    end
  end
end
