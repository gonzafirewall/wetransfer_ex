defmodule WetransferEx do
  @moduledoc """
  Documentation for `WetransferEx`.
  """

  @api_url "https://wetransfer.com/api/v4/transfers/"

  # def download(url, path: path), do: IO.inspect("Downloading #{url} to #{path}")
  def download(url) do
    url
    |> URI.parse()
    |> get_direct_link()
    |> download_to()
  end

  def download_to(direct_link) do
    [path|_tail] = direct_link |> URI.parse() |> Map.get(:path) |> String.split("/") |> Enum.reverse()
    file = File.open!(path, [:write, :exclusive])
    fun = fn request, finch_request, finch_name, finch_options ->
      fun = fn
        {:status, status}, response ->
          %{response | status: status}

        {:headers, headers}, response ->
          %{response | headers: headers}

        {:data, data}, response ->
          IO.binwrite(file, data)
          response
      end

      case Finch.stream(finch_request, finch_name, Req.Response.new(), fun, finch_options) do
        {:ok, response} -> {request, response}
        {:error, exception} -> {request, exception}
      end
    end

    Req.get!(direct_link, finch_request: fun)
    File.close(file)
  end

  defp get_direct_link(%URI{host: nil}) do
    IO.puts("Invalid URL")
  end
  defp get_direct_link(%URI{host: "we.tl"} = uri) do
    IO.puts("Downloading #{uri |> URI.to_string()}")
    [location] = uri
                |> URI.to_string()
                |> Req.get!(redirect: false)
                |> Map.get(:headers)
                |> Map.get("location")
    get_direct_link(location)
  end
  defp get_direct_link(%URI{host: "wetransfer.com"} = uri) do
    uri
    |> URI.to_string()
    |> get_direct_link()
  end
  defp get_direct_link(%URI{}), do: IO.puts("Cannot download from this URL")

  defp get_direct_link(uri) do
    [_, _, we_id, security_hash] = uri
        |> URI.parse()
        |> Map.get(:path)
        |> String.split("/")
    json_data = %{security_hash: security_hash, intent: "entire_transfer"}
    res = Req.post!("#{@api_url}#{we_id}/download", json: json_data)
    res.body["direct_link"]
  end

  def test() do
    path = "/tmp/README.md"
    file = File.open!(path, [:write, :exclusive])
    fun = fn request, finch_request, finch_name, finch_options ->
      fun = fn
        {:status, status}, response ->
          %{response | status: status}

        {:headers, headers}, response ->
          %{response | headers: headers}

        {:data, data}, response ->
          IO.binwrite(file, data)
          response
      end

      case Finch.stream(finch_request, finch_name, Req.Response.new(), fun, finch_options) do
        {:ok, response} -> {request, response}
        {:error, exception} -> {request, exception}
      end
    end

    Req.get!("https://httpbin.org/stream/10", finch_request: fun)
    File.close(file)

    # path = "/tmp/README.md"
    # file = File.open!(path, [:write, :exclusive])
    # url = "https://download.wetransfer.com/usgv/de2da4784f9210dc812edb8794d1ba3c20240320182930/5cb478ee13149129b991404478df7128944c3330/wetransfer_testigos-xhct-y-xhvz-del-11mar24_2024-03-20_1830.zip?cf=y&token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImRlZmF1bHQifQ.eyJleHAiOjE3MTA5OTM3NTcsImlhdCI6MTcxMDk5MzE1NywiZG93bmxvYWRfaWQiOiI2M2ZiYjU3Mi1mYzExLTRiNjAtYjA2YS0zNTg0OGY3NzhmZTQiLCJzdG9yYWdlX3NlcnZpY2UiOiJzdG9ybSJ9.KpSTWPzYIgc5nMzYk7DlBnCYi9KouZiYkvwyBiylqzI"
    # request = Finch.build(:get, url)

    # Finch.stream(request, App.Finch, nil, fn
    #   {:status, status}, _ ->
    #     IO.inspect("Download assets status: #{status}")

    #   {:headers, headers}, _ ->
    #     IO.inspect("Download assets headers: #{inspect(headers)}")

    #   {:data, data}, _ ->
    #     IO.binwrite(file, data)
    # end)

    # File.close(file)

    # fun = fn request, finch_request, finch_name, finch_options ->
    #   file = File.open!(path, [:write, :exclusive])
    #   fun = fn
    #     {:status, status}, response ->
    #       IO.inspect("Download assets status: #{status}")
    #       %{response | status: status}

    #     {:headers, headers}, response ->
    #       IO.inspect("Download assets headers: #{inspect(headers)}")
    #       %{response | headers: headers}

    #     {:data, data}, response ->
    #       IO.binwrite(file, data)
    #       response
    #   end
    #   File.close(file)

    #   case Finch.stream(finch_request, finch_name, Req.Response.new(), fun, finch_options) do
    #     {:ok, response} -> {request, response}
    #     {:error, exception} -> {request, exception}
    #   end
    # end
    # Req.get!(url, finch_request: fun)
  end

end
