ExUnit.start()

ExUnit.after_suite(fn _ ->
  File.rm_rf!("tmp")
end)
