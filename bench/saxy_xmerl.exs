Benchee.run(
  %{
    "saxy" => fn input -> BUPE.Parser.run_ng(input) end,
    "xmerl" => fn input -> BUPE.Parser.run(input) end
  },
  inputs: %{
    "Elixir" => File.read!("Elixir.epub"),
    "Moby Dick" => File.read!("moby.epub") 
  },
  time: 10,
  formatters: [{Benchee.Formatters.Console, extended_statistics: true}]
)
