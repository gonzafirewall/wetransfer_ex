defmodule WetransferExTest do
  use ExUnit.Case
  doctest WetransferEx

  test "build req api" do
    opts = {"1234", "555"}
    req = WetransferEx.build_req(opts)
    assert req.url == URI.parse("https://wetransfer.com/api/v4/transfers/1234/download")
    assert req.body == nil
    assert req.method == :post
    assert req.options |> Map.has_key?(:json)
    assert req.options.json |> Map.get(:intent) == "entire_transfer"
    assert req.options.json |> Map.get(:security_hash) == opts |> elem(1)
  end

  test "test invalids url" do
    invalid_urls = ["asdasd", "www.google.com"]
    Enum.each(invalid_urls, fn url ->
      assert WetransferEx.download(url) == :error
    end)
  end

  test "capture id and security hash from url" do
    uri = "https://wetransfer.com/downloads/#{:test_id}/#{:test_security_hash}"
    assert WetransferEx.get_id_and_security_hash(uri) == {"test_id", "test_security_hash"}
  end
end
