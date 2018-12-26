# Map vs List Performance

An improved implementation for the code in the follow blog post:
https://medium.com/@damonvjanis/map-vs-list-performance-in-elixir-c45642a25c6

## Original implementation using `for` and `Enum.filter/2`

```elixir
contacts = Enum.group_by(contacts, fn c -> c["email"] end)

for lead <- leads do
  matching_contacts = contacts[lead["email"]]

  if matching_contacts do
    {lead, matching_contacts}
  end
end
|> Enum.filter(& &1)
```

## Alternative implementation using `Enum.reduce/3` and pattern matching

```elixir
contacts = Enum.group_by(contacts, fn c -> c["email"] end)

leads
|> Enum.reduce([], fn lead, acc ->
  email = lead["email"]

  case contacts do
    %{^email => matching_contacts} -> [{lead, matching_contacts} | acc]
    _ -> acc
  end
end)
```

## Benchmark

```elixir
iex> MapListPerformance.benchmark
```

Some results running on my notebook for 10,000 entries:
```
Name                     ips        average  deviation         median         99th %
improved_match        137.89        7.25 ms    ±22.84%        6.72 ms       11.71 ms
map_match             116.17        8.61 ms    ±14.37%        8.19 ms       12.15 ms

Comparison:
improved_match        137.89
map_match             116.17 - 1.19x slower
```

```
Name                     ips        average  deviation         median         99th %
improved_match        110.63        9.04 ms    ±19.43%        8.92 ms       16.40 ms
map_match             107.59        9.29 ms    ±14.44%        8.99 ms       13.21 ms

Comparison:
improved_match        110.63
map_match             107.59 - 1.03x slower
```

```
Name                     ips        average  deviation         median         99th %
improved_match        104.47        9.57 ms    ±18.44%        9.46 ms       16.03 ms
map_match              83.67       11.95 ms    ±20.65%       11.75 ms       23.72 ms

Comparison:
improved_match        104.47
map_match              83.67 - 1.25x slower
```
