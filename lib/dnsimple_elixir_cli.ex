defmodule DnsimpleElixirCli do
  @production_url "https://api.dnsimple.com/"

  def main(args) do
    args |> parse_args |> configure |> process
  end

  defp parse_args(args) do
    {options, args, _} = OptionParser.parse(args,
      switches: [env: :string]
    )
    {options, args}
  end

  defp configure(args = {options, _}) do
    env = options[:env] || "local"
    Code.eval_file("#{env}.exs", "settings")
    args
  end

  # The commands

  defp process({_options, ["whoami"]}), do: DnsimpleElixirCli.Identity.whoami(client)

  defp process({_options, ["contacts.list"]}), do: DnsimpleElixirCli.Contacts.list(client)

  defp process({_options, ["domains.list"]}), do: DnsimpleElixirCli.Domains.list(client)
  defp process({_options, ["domains.get", name]}), do: DnsimpleElixirCli.Domains.get(client, name)

  defp process({_options, ["registrar.check", name]}), do: DnsimpleElixirCli.Registrar.check(client, name)
  defp process({_options, ["registrar.register", name, registrant_id]}), do: DnsimpleElixirCli.Registrar.register(client, name, registrant_id)

  defp process(_) do
    IO.puts """
    Usage: command

    Commands available:

    * whoami                                  Display account details

    * contacts.list                           List contacts in your account

    * domains.list                            List domains in your account
    * domains.get name                        Display details for a particular domain

    * registrar.check name                    Check if a domain is available for registration
    * registrar.register name registrant_id   Register a domain to the given registrant
    """
  end

  # Internal functions

  def config(app, kv) do
    Enum.each(kv, fn({k, v}) ->
      Application.put_env(app, k, v)
    end)
  end

  def whoami do
    case Dnsimple.Identity.whoami(client) do
      {:ok, response} ->
        response.data.account
      {:error, _} ->
        IO.puts "Failed to authenticate"
        Kernel.exit({:shutdown, 1})
    end
  end

  defp client do
    %Dnsimple.Client{access_token: access_token, base_url: base_url}
  end

  defp access_token do
    Application.get_env(:dnsimple, :access_token)
  end

  defp base_url do
    Application.get_env(:dnsimple, :base_url, @production_url)
  end
end
