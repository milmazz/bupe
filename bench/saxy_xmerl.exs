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
  memory_time: 2,
  formatters: [{Benchee.Formatters.Console, extended_statistics: true}],
  after_each: fn _ -> :erlang.garbage_collect() end
)

# $ mix run bench/saxy_xmerl.exs                                                                                                                                                           (base)
# Operating System: macOS
# CPU Information: Apple M1 Max
# Number of Available Cores: 10
# Available memory: 64 GB
# Elixir 1.19.0-rc.0
# Erlang 28.0.1
# JIT enabled: true
#
# Benchmark suite executing with the following configuration:
# warmup: 2 s
# time: 10 s
# memory time: 2 s
# reduction time: 0 ns
# parallel: 1
# inputs: Elixir, Moby Dick
# Estimated total run time: 56 s
#
# Benchmarking saxy with input Elixir ...
# Benchmarking saxy with input Moby Dick ...
# Benchmarking xmerl with input Elixir ...
# Benchmarking xmerl with input Moby Dick ...
# Calculating statistics...
# Formatting results...
#
# ##### With input Elixir #####
# Name            ips        average  deviation         median         99th %
# saxy          54.57       18.33 ms     ±1.80%       18.34 ms       19.24 ms
# xmerl         41.19       24.28 ms     ±6.27%       24.63 ms       25.53 ms
#
# Comparison:
# saxy          54.57
# xmerl         41.19 - 1.32x slower +5.95 ms
#
# Extended statistics:
#
# Name          minimum        maximum    sample size                     mode
# saxy         17.36 ms       19.87 ms            54518.25 ms, 18.32 ms, 18.69
# xmerl        18.64 ms       26.02 ms            41224.79 ms, 24.49 ms, 24.49
#
# Memory usage statistics:
#
# Name          average  deviation         median         99th %
# saxy          5.75 MB     ±0.00%        5.75 MB        5.75 MB
# xmerl        18.63 MB     ±0.00%       18.63 MB       18.63 MB
#
# Comparison:
# saxy          5.75 MB
# xmerl        18.63 MB - 3.24x memory usage +12.88 MB
#
# Extended statistics:
#
# Name          minimum        maximum    sample size                     mode
# saxy          5.75 MB        5.75 MB            104                  5.75 MB
# xmerl        18.63 MB       18.63 MB             79                 18.63 MB
#
# ##### With input Moby Dick #####
# Name            ips        average  deviation         median         99th %
# saxy         333.59        3.00 ms     ±1.95%        2.99 ms        3.16 ms
# xmerl        264.96        3.77 ms    ±12.48%        3.49 ms        4.51 ms
#
# Comparison:
# saxy         333.59
# xmerl        264.96 - 1.26x slower +0.78 ms
#
# Extended statistics:
#
# Name          minimum        maximum    sample size                     mode
# saxy          2.91 ms        3.35 ms         3.32 K2.93 ms, 3.01 ms, 2.99 ms
# xmerl         3.21 ms        4.65 ms         2.64 K         3.30 ms, 3.31 ms
#
# Memory usage statistics:
#
# Name     Memory usage
# saxy          0.60 MB
# xmerl         2.73 MB - 4.54x memory usage +2.13 MB
#
# **All measurements for memory usage were the same**
