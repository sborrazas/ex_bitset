defmodule ExBitsetTest do
  use ExUnit.Case

  doctest ExBitset

  defmodule ExBitsetText.Roles do
    import ExBitset, only: [defbitset: 1]

    defbitset([:admin, :owner, :writer, :viewer, :guest])
  end

  alias ExBitset.UndefinedItemError
  alias ExBitsetText.Roles

  describe "new/2" do
    test "it raises an exception when sending invalid items" do
      assert_raise UndefinedItemError, fn ->
        ExBitset.new(Roles, [:admin, :foo])
      end
    end
  end

  describe "Enum.to_list/1" do
    test "it returns a list with all items" do
      roles = Roles |> ExBitset.new([:admin, :owner]) |> Enum.to_list()

      assert 2 = length(roles)
      assert :admin in roles
      assert :owner in roles
    end
  end

  describe "Enum.count/1" do
    test "it returns a list with all items" do
      roles = ExBitset.new(Roles, [:admin, :owner, :viewer])

      assert 3 = Enum.count(roles)
    end
  end

  describe "integer serialization" do
    test "it returns the serialized integer" do
      roles = ExBitset.new(Roles, [:admin, :owner])
      integer_roles = ExBitset.to_int(roles)

      assert Roles
             |> ExBitset.from_int(integer_roles)
             |> Enum.member?(:admin)
    end
  end

  describe "binary serialization" do
    test "it returns the serialized integer" do
      roles = ExBitset.new(Roles, [:admin, :owner])
      binary_roles = ExBitset.to_binary(roles)

      assert Roles
             |> ExBitset.from_binary(binary_roles)
             |> Enum.member?(:admin)
    end
  end

  describe "domain/1" do
    test "it returns a list with all of the domain items" do
      roles = ExBitset.new(Roles, [:admin, :owner])
      domain = ExBitset.domain(roles)

      assert 5 = length(domain)
      assert :admin in domain
      assert :owner in domain
      assert :writer in domain
      assert :viewer in domain
      assert :guest in domain
    end
  end

  describe "union/2" do
    test "it contains the elements from both bitsets" do
      roles1 = ExBitset.new(Roles, [:admin, :owner])
      roles2 = ExBitset.new(Roles, [:guest])
      roles3 = ExBitset.union(roles1, roles2)

      assert Enum.member?(roles3, :admin)
      assert Enum.member?(roles3, :guest)
      refute Enum.member?(roles3, :writer)
    end
  end

  describe "intersection/2" do
    test "it only contains the elements present in both bitsets" do
      roles1 = ExBitset.new(Roles, [:admin, :owner])
      roles2 = ExBitset.new(Roles, [:guest, :owner])
      roles3 = ExBitset.intersection(roles1, roles2)

      assert Enum.member?(roles3, :owner)
      refute Enum.member?(roles3, :guest)
      refute Enum.member?(roles3, :admin)
    end
  end

  describe "subtract/2" do
    test "it only contains the sets subtraction" do
      roles1 = ExBitset.new(Roles, [:admin, :owner])
      roles2 = ExBitset.new(Roles, [:guest, :owner])
      roles3 = ExBitset.subtract(roles1, roles2)

      assert Enum.member?(roles3, :admin)
      refute Enum.member?(roles3, :guest)
      refute Enum.member?(roles3, :owner)
    end
  end

  describe "member?/2" do
    test "it determines whether the item exists in the bitset or not" do
      roles = ExBitset.new(Roles, [:admin, :owner])

      assert ExBitset.member?(roles, :admin)
      refute ExBitset.member?(roles, :guest)
    end

    test "it raises an exception when the member does not exist" do
      roles = ExBitset.new(Roles, [:admin, :owner])

      assert_raise UndefinedItemError, fn ->
        assert ExBitset.member?(roles, :foo)
      end
    end
  end
end
