defmodule MessagingService.ApiHelpersTest do
  @moduledoc """
  Tests for the MessagingService.ApiHelpers module.
  """

  use ExUnit.Case, async: true

  alias MessagingService.ApiHelpers

  describe "convert_to_map/1" do
    test "converts Ecto.Association.NotLoaded to nil" do
      not_loaded = %Ecto.Association.NotLoaded{__cardinality__: :one, __field__: :contact, __owner__: TestSchema}

      result = ApiHelpers.convert_to_map(not_loaded)

      assert result == nil
    end

    test "converts DateTime to ISO8601 string" do
      datetime = ~U[2023-01-01 12:00:00Z]

      result = ApiHelpers.convert_to_map(datetime)

      assert result == "2023-01-01T12:00:00Z"
    end

    test "converts NaiveDateTime to ISO8601 string" do
      naive_datetime = ~N[2023-01-01 12:00:00]

      result = ApiHelpers.convert_to_map(naive_datetime)

      assert result == "2023-01-01T12:00:00"
    end

    test "converts struct to map filtering private fields and NotLoaded associations" do
      struct = %{
        __struct__: TestStruct,
        id: 1,
        name: "Test",
        __private_field__: "private",
        not_loaded_assoc: %Ecto.Association.NotLoaded{__cardinality__: :one, __field__: :contact, __owner__: TestSchema},
        nested_struct: %{__struct__: NestedStruct, value: "nested"}
      }

      result = ApiHelpers.convert_to_map(struct)

      expected = %{
        id: 1,
        name: "Test",
        nested_struct: %{value: "nested"}
      }

      assert result == expected
    end

    test "converts list of values" do
      values = [
        %{__struct__: TestStruct, id: 1, name: "Test1"},
        %{__struct__: TestStruct, id: 2, name: "Test2"}
      ]

      result = ApiHelpers.convert_to_map(values)

      expected = [
        %{id: 1, name: "Test1"},
        %{id: 2, name: "Test2"}
      ]

      assert result == expected
    end

    test "returns primitive values unchanged" do
      assert ApiHelpers.convert_to_map("string") == "string"
      assert ApiHelpers.convert_to_map(123) == 123
      assert ApiHelpers.convert_to_map(true) == true
      assert ApiHelpers.convert_to_map(nil) == nil
      assert ApiHelpers.convert_to_map([1, 2, 3]) == [1, 2, 3]
    end

    test "converts nested structs recursively" do
      struct = %{
        __struct__: TestStruct,
        id: 1,
        nested: %{
          __struct__: NestedStruct,
          value: "nested",
          deeply_nested: %{
            __struct__: DeepStruct,
            data: "deep"
          }
        }
      }

      result = ApiHelpers.convert_to_map(struct)

      expected = %{
        id: 1,
        nested: %{
          value: "nested",
          deeply_nested: %{
            data: "deep"
          }
        }
      }

      assert result == expected
    end

    test "filters out nil values from converted map" do
      struct = %{
        __struct__: TestStruct,
        id: 1,
        name: "Test",
        nil_field: nil,
        not_loaded_assoc: %Ecto.Association.NotLoaded{__cardinality__: :one, __field__: :contact, __owner__: TestSchema}
      }

      result = ApiHelpers.convert_to_map(struct)

      expected = %{
        id: 1,
        name: "Test"
      }

      assert result == expected
    end
  end

  describe "convert_nested_structs/1" do
    test "converts nested structs in map" do
      map = %{
        id: 1,
        struct_field: %{__struct__: TestStruct, value: "test"},
        regular_field: "regular"
      }

      result = ApiHelpers.convert_nested_structs(map)

      expected = %{
        id: 1,
        struct_field: %{value: "test"},
        regular_field: "regular"
      }

      assert result == expected
    end

    test "filters out nil values" do
      map = %{
        id: 1,
        nil_field: nil,
        regular_field: "regular"
      }

      result = ApiHelpers.convert_nested_structs(map)

      expected = %{
        id: 1,
        regular_field: "regular"
      }

      assert result == expected
    end
  end
end
