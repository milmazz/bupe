# The epubcheck tag needs Java and the EPUBCheck jar; the CI workflow runs it
# in a dedicated job via `mix test --only epubcheck`.
ExUnit.start(exclude: [:epubcheck])

ExUnit.after_suite(fn _ ->
  File.rm_rf!("tmp")
end)
