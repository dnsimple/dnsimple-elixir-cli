defmodule DnsimpleElixirCli do
  def main(args) do
    Code.eval_file("local.exs", "config")
    args |> parse_args |> process
  end

  def config(app, kv) do
    Enum.each(kv, fn({k, v}) ->
      Application.put_env(app, k, v)
    end)
  end

  defp process({_options, ["whoami"]}) do
    case Dnsimple.Identity.whoami(client) do
      {:ok, response} ->
        IO.puts """
        You are currently authenticated as:

          Account ID: #{response.data.account.id}
          Account email: #{response.data.account.email}
        """
      {:error, response} ->
        IO.puts """
        Failed to authenticate: #{response}
        """
    end
  end

  defp process({_options, ["contacts.list"]}) do
    IO.puts "Retrieving contact list..."
    account = whoami
    case Dnsimple.Contacts.list_contacts(client, account.id) do
      {:ok, %Dnsimple.Response{data: contacts}} ->
        IO.puts """
        Contacts in the account #{account.email} (ID: #{account.id}):
        """

        Enum.each(contacts, fn(contact) ->
          IO.puts "  * #{contact.id} : #{contact.first_name}"
        end)
      {:error, _} ->
        IO.puts "Error retrieving contacts"
    end
  end

  defp process({_options, ["domains.list"]}) do
    IO.puts "Retrieving domain list..."
    account = whoami
    case Dnsimple.Domains.all_domains(client, account.id) do
      {:ok, domains} ->
        IO.puts """
        Domains in the account #{account.email} (ID: #{account.id}):
        """

        Enum.each(domains, fn(domain) ->
          IO.puts "  * #{domain.name}"
        end)
      {:error, _} ->
        IO.puts "Error retrieving domains"
    end
  end

  defp process({_options, ["domains.get", name]}) do
    account = whoami
    IO.puts "Connected as #{account.email} (ID: #{account.id})"
    IO.puts "Retrieving domain details..."
    case Dnsimple.Domains.get_domain(client, account.id, name) do
      {:ok, response} ->
        IO.puts """
        Details for #{response.data.name}:

          State:      #{response.data.state}
          Created at: #{response.data.created_at}
          Updated at: #{response.data.updated_at}
        """

        if response.data.state == "registered" do
          IO.puts """
            Expires on: #{response.data.expires_on}
          """
        end

      {:error, _} ->
        IO.puts "Error retrieving domain details"
    end
  end

  defp process({_options, ["registrar.check", name]}) do
    account = whoami
    IO.puts "Connected as #{account.email} (ID: #{account.id})"
    IO.puts "Checking domain availability..."
    case Dnsimple.Registrar.check_domain(client, account.id, name) do
      {:ok, response} ->
        case response.data.available do
          true -> IO.puts "Domain #{name} is available for registration"
          false -> IO.puts "Domain #{name} is not available for registration"
        end
      {:error, _} ->
        IO.puts "Error checking domain availability"
    end
  end

  defp process({_options, ["registrar.register", name, registrant_id]}) do
    account = whoami
    IO.puts "Connected as #{account.email} (ID: #{account.id})"
    IO.puts "Attempting to register domain..."
    case Dnsimple.Registrar.register_domain(client, account.id, name, %{registrant_id: registrant_id}) do
      {:ok, response} ->
        IO.puts "Domain #{name} registered! Expires on #{response.data.expires_on}"
      {:error, _} ->
        IO.puts "Error registering domain"
    end
  end

  defp process(_) do
    IO.puts """
    Usage: command

    Commands available:

    * whoami                  Display account details
    * contacts.list           List contacts in your account
    * domains.list            List domains in your account
    * domains.get name        Display details for a particular domain
    * registrar.check name    Check if a domain is available for registration
    """
  end

  defp parse_args(args) do
    {options, args, _} = OptionParser.parse(args,
      switches: [command: :string]
    )
    {options, args}
  end

  defp client do
    %Dnsimple.Client{access_token: access_token, base_url: base_url}
  end

  defp access_token do
    Application.get_env(:dnsimple, :access_token)
  end

  defp base_url do
    Application.get_env(:dnsimple, :base_url, "https://api.dnsimple.com/")
  end

  defp whoami do
    case Dnsimple.Identity.whoami(client) do
      {:ok, response} ->
        response.data.account
      {:error, _} ->
        IO.puts """
        Failed to authenticate
        """
        Kernel.exit({:shutdown, 1})
    end
  end
end
