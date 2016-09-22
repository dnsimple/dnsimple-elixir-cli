defmodule DnsimpleElixirCli.Mixfile do
  use Mix.Project

  def project do
    [app: :dnsimple_cli,
     version: "0.1.0",
     elixir: "~> 1.3",
     escript: [main_module: DnsimpleElixirCli],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger, :dnsimple]]
  end

  defp deps do
    [
      {:dnsimple, git: "https://github.com/dnsimple/dnsimple-elixir.git"}
    ]
  end
end
