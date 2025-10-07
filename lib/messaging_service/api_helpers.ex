defmodule MessagingService.ApiHelpers do
  @moduledoc """
  Helpers for the API.
  """

  @spec convert_to_map(struct()) :: any()
  def convert_to_map(%Ecto.Association.NotLoaded{}), do: nil

  @spec convert_to_map(struct()) :: String.t()
  def convert_to_map(%DateTime{} = datetime), do: DateTime.to_iso8601(datetime)

  @spec convert_to_map(struct()) :: String.t()
  def convert_to_map(%NaiveDateTime{} = naive_datetime),
    do: NaiveDateTime.to_iso8601(naive_datetime)

  @spec convert_to_map(struct()) :: map()
  def convert_to_map(struct) when is_struct(struct) do
    struct
    |> Map.from_struct()
    |> Map.filter(fn {key, value} ->
      not String.starts_with?(to_string(key), "__") and
        not is_struct(value, Ecto.Association.NotLoaded)
    end)
    |> convert_nested_structs()
  end

  @spec convert_to_map(list()) :: list()
  def convert_to_map(value) when is_list(value) do
    Enum.map(value, &convert_to_map/1)
  end

  @spec convert_to_map(any()) :: any()
  def convert_to_map(value), do: value

  @spec convert_nested_structs(map()) :: map()
  def convert_nested_structs(map) when is_map(map) do
    map
    |> Map.new(fn {key, value} ->
      {key, convert_to_map(value)}
    end)
    |> Map.filter(fn {_key, value} -> value != nil end)
  end
end
