defmodule WetransferExTest do
  use ExUnit.Case
  doctest WetransferEx

  defp build_req_options(context) do
    new_context = context
    |> Map.put(:opts, {"1234", "555"})
    |> Map.put(:uri, "https://wetransfer.com/api/v4/transfers/1234/download")
    {:ok, new_context}
  end

  setup_all do
    {:ok,
    invalid_urls: ["asdasd", "www.google.com"],
    }
  end

  describe "Test build req api" do
    setup [:build_req_options]

    test "build req api", %{opts: opts, uri: uri} do
      req = WetransferEx.build_req(opts)
      assert req.url == URI.parse(uri)
      assert req.body == nil
      assert req.method == :post
      assert req.options |> Map.has_key?(:json)
      assert req.options.json |> Map.get(:intent) == "entire_transfer"
      assert req.options.json |> Map.get(:security_hash) == opts |> elem(1)
    end

  end

  test "test invalids url", state do
    Enum.each(state[:invalid_urls], fn url ->
      assert WetransferEx.download(url) == :error
    end)
  end

  test "capture id and security hash from url" do
    uri = "https://wetransfer.com/downloads/#{:test_id}/#{:test_security_hash}"
    assert WetransferEx.get_id_and_security_hash(uri) == {"test_id", "test_security_hash"}
  end
end
