defmodule ExBitset do
  @moduledoc """
  ExBitset provides the functionality to create/query bitarray sets.

  To define a set constructor you first need to specify all possible
  set elements. This is done via the defbitset macro:

  ```
  defmodule Roles
    import ExBitset, only: [defbitset: 1]

    defbitset [:admin, :owner, :writer, :viewer, :guest]
  end
  ```

  Then, create a new set specifying all of the elements in it:

  ```
  roles = ExBitset.new(Roles, [:admin, :owner])
  ```

  To then query the set, you can use any of the following functions:

  ```
  ExBitset.member?(roles, :owner) # => true

  roles2 = ExBitset.new(Roles, [:admin, :writer])

  ExBitset.union(roles, roles2) |> Enum.to_list() # => [:admin, :owner, :writer]
  ExBitset.intersection(roles, roles2) |> Enum.to_list() # => [:admin]
  ExBitset.subtract(role, roles2) |> Enum.to_list() # => [:owner]

  # OR alternatively using Enum functions
  Enum.join(roles, ", ") # => "admin, owner"
  Enum.map(roles, &to_string/1) # => ["admin", "owner"]
  ```
  """

  use Bitwise

  defstruct [:mod, :value]

  alias ExBitset.UndefinedItemError

  @opaque t() :: %__MODULE__{
            mod: module(),
            value: non_neg_integer()
          }

  @type item() :: term()

  @spec new(module(), [item()]) :: t()
  def new(mod, items \\ []) do
    base_items = mod.__bitset__()

    value = Enum.reduce(items, 0, &(Bitwise.bsl(1, find_index(base_items, &1, mod)) + &2))

    %__MODULE__{mod: mod, value: value}
  end

  @spec member?(t(), term()) :: boolean()
  def member?(%__MODULE__{mod: mod, value: value}, item) do
    index = find_index(mod.__bitset__(), item, mod)

    (bsl(1, index) &&& value) > 0
  end

  @spec count(t()) :: non_neg_integer()
  def count(%__MODULE__{value: value}) do
    Stream.unfold(value, fn
      0 -> nil
      n -> {(n &&& 1) > 0, bsr(n, 1)}
    end)
    |> Enum.count(& &1)
  end

  @spec domain(t()) :: [item()]
  def domain(%__MODULE__{mod: mod}) do
    mod.__bitset__()
  end

  @spec to_list(t()) :: [item()]
  def to_list(%__MODULE__{mod: mod, value: value}) do
    base_items = mod.__bitset__()

    Stream.unfold(value, fn
      0 -> nil
      n -> {(n &&& 1) > 0, bsr(n, 1)}
    end)
    |> Stream.with_index()
    |> Stream.filter(fn {val, _index} -> val end)
    |> Stream.map(fn {_val, index} -> Enum.at(base_items, index) end)
    |> Enum.to_list()
  end

  @spec to_int(t()) :: non_neg_integer()
  def to_int(%__MODULE__{value: value}) do
    value
  end

  @spec from_int(module(), non_neg_integer()) :: t()
  def from_int(mod, value) do
    %__MODULE__{mod: mod, value: value}
  end

  @spec to_binary(t()) :: binary()
  def to_binary(%__MODULE__{value: value}) do
    :binary.encode_unsigned(value)
  end

  @spec from_binary(module(), binary()) :: t()
  def from_binary(mod, bin) do
    %__MODULE__{mod: mod, value: :binary.decode_unsigned(bin)}
  end

  @spec union(t(), t()) :: t()
  def union(%__MODULE__{mod: mod, value: val1}, %__MODULE__{mod: mod, value: val2}) do
    %__MODULE__{mod: mod, value: val1 ||| val2}
  end

  @spec intersection(t(), t()) :: t()
  def intersection(%__MODULE__{mod: mod, value: val1}, %__MODULE__{mod: mod, value: val2}) do
    %__MODULE__{mod: mod, value: val1 &&& val2}
  end

  @spec subtract(t(), t()) :: t()
  def subtract(%__MODULE__{mod: mod, value: val1}, %__MODULE__{mod: mod, value: val2}) do
    %__MODULE__{mod: mod, value: val1 &&& ~~~val2}
  end

  defp find_index(items, item, mod) do
    case Enum.find_index(items, &(&1 == item)) do
      nil -> raise UndefinedItemError, item: item, mod: mod
      index -> index
    end
  end

  defmacro defbitset(set_domain) do
    quote do
      def __bitset__ do
        unquote(set_domain)
      end
    end
  end

  defimpl Enumerable, for: ExBitset do
    @impl true
    def count(bitset) do
      {:ok, ExBitset.count(bitset)}
    end

    @impl true
    def member?(bitset, element) do
      {:ok, ExBitset.member?(bitset, element)}
    end

    @impl true
    def reduce(bitset, acc, fun) do
      Enumerable.reduce(ExBitset.to_list(bitset), acc, fun)
    end

    @impl true
    def slice(bitset) do
      set_domain = ExBitset.set_domain(bitset)

      {:ok, ExBitset.count(bitset), fn start, length -> Enum.slice(set_domain, start, length) end}
    end
  end
end
