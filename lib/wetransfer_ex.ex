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

end
