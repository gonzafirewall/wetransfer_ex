defmodule WetransferEx.CLI do
  def main(args) do
    {opts, args, _ } = OptionParser.parse(args, strict: [url: :string, path: :string])
    Req.default_options(finch_config())
    case {opts, args} do
      {[], [url]} -> WetransferEx.download(url)
      _ -> IO.puts("Usage: wetransfer_ex <url>")
    end
  end

  def finch_config() do
    Application.get_env(:finch, :finch_config)
  end
end
