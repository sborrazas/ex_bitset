# ExBitset

Fast implementation for dealing with immutable bitarray sets.

## Installation

Add ExBitset to your `mix.exs` dependencies:

```elixir
def deps do
  [
    {:ex_bitset, "~> 0.1.0"}
  ]
end
```

## Usage

To define a bitset type you need to use the `defbitset` function inside the
Elixir module (similar to how you would define structs).

```elixir
defmodule Roles do
  import ExBitset, only: [defbitset: 1]

  defbitset [:admin, :owner, :writer, :viewer, :guest]
end
```

You can then create new bitsets using the previously defined structure and
perform operations on it:


```elixir
roles = ExBitset.new(Roles, [:admin, :owner])

assert Enum.member?(roles, :admin)
assert :owner in Enum.to_list(roles)

bin_roles = ExBitset.to_binary(roles)
int_roles = ExBitset.to_int(roles)

assert Roles
  |> ExBitset.from_binary(bin_roles)
  |> Enum.member?(:admin)
assert Roles
  |> ExBitset.from_int(int_roles)
  |> Enum.member?(:admin)
```

### Usage with Ecto

To store one of these bitsets on the DB using, you can define a new Ecto type.
The type being stored can be an integer or binary, we're going to use integer in
this example because it would be more efficient for small sets, but you could
use any.

```elixir
defmodule MyApp.EctoTypes.Roles do
  import ExBitset, only: [defbitset: 1]
  use Ecto.Type

  defbitset [:admin, :owner, :writer, :viewer, :guest]

  def type, do: :integer

  def cast(roles) when is_list(roles) do
    {:ok, ExBitset.new(__MODULE__, roles)}
  end

  def cast(roles) when is_struct(roles, ExBitset) do
    {:ok, roles}
  end

  def cast(_roles), do: :error

  def load(roles) when is_integer(roles) do
    {:ok, ExBitset.from_int(__MODULE__, roles)}
  end

  def dump(roles) when is_struct(roles, ExBitset) do
    {:ok, ExBitset.to_int(roles)}
  end

  def dump(_roles), do: :error
end
```
