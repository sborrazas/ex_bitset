defmodule ExBitset.UndefinedItemError do
  @moduledoc """
  Error for dealing with items not defined in the set domain.
  """

  defexception [:message, :item, :mod]

  def exception(opts) do
    item = Keyword.fetch!(opts, :item)
    mod = Keyword.fetch!(opts, :mod)

    %__MODULE__{
      message: "Item `#{inspect(item)}` not defined for bitset `#{mod}`",
      item: item,
      mod: mod
    }
  end
end
