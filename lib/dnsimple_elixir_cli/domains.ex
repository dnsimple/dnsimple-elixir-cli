defmodule DnsimpleElixirCli.Domains do

  def list(client) do
    IO.puts "Retrieving domain list..."
    account = DnsimpleElixirCli.whoami
    case Dnsimple.Domains.all_domains(client, account.id) do
      {:ok, domains} ->
        IO.puts """
        Domains in the account #{account.email} (ID: #{account.id}):
        """

      Enum.each(domains, fn(domain) ->
        IO.puts "  * #{domain.name}"
      end)
      {:error, err} ->
        IO.puts "Error retrieving domains: #{err.message}"
    end
  end

  def get(client, name) do
    account = DnsimpleElixirCli.whoami
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

      {:error, err} ->
        IO.puts "Error retrieving domain details: #{err.message}"
    end
  end
end

