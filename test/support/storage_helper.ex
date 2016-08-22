defmodule Phamello.StorageHelper do
  def clear_fixtures_storage() do
    File.rm_rf("fixture/storage")
    File.mkdir("fixture/storage")
  end
end
