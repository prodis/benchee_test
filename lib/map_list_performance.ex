defmodule MapListPerformance do
  @moduledoc """
  Documentation for MapListPerformance.

  https://medium.com/@damonvjanis/map-vs-list-performance-in-elixir-c45642a25c6
  """

  def benchmark do
    {leads, contacts} = dataset()

    Benchee.run(%{
      # "list_match" => fn -> list_match(leads, contacts) end,
      "map_match" => fn -> map_match(leads, contacts) end,
      "improved_match" => fn -> improved_match(leads, contacts) end
    })

    nil
  end

  defp list_match(leads, contacts) do
    for lead <- leads do
      matching_contacts = Enum.filter(contacts, fn c -> c["email"] == lead["email"] end)

      {lead, matching_contacts}
    end
  end

  defp map_match(leads, contacts) do
    contacts = Enum.group_by(contacts, fn c -> c["email"] end)

    for lead <- leads do
      matching_contacts = contacts[lead["email"]]

      if matching_contacts do
        {lead, matching_contacts}
      end
    end
    |> Enum.filter(& &1)
  end

  defp improved_match(leads, contacts) do
    contacts = Enum.group_by(contacts, fn c -> c["email"] end)

    leads
    |> Enum.reduce([], fn lead, acc ->
      email = lead["email"]

      case contacts do
        %{^email => matching_contacts} -> [{lead, matching_contacts} | acc]
        _ -> acc
      end
    end)
  end

  defp dataset do
    random = fn -> Enum.random(97..122) end
    string = fn -> to_string([random.(), random.(), random.(), random.()]) end

    leads =
      for _ <- 1..10_000 do
        %{"first" => string.(), "last" => string.(), "email" => string.() <> "@example.com"}
      end

    contacts =
      for _ <- 1..10_000 do
        %{"first" => string.(), "last" => string.(), "email" => string.() <> "@example.com"}
      end

    {leads, contacts}
  end
end
