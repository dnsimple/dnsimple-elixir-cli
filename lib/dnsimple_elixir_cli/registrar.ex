defmodule DnsimpleElixirCli.Registrar do
  def check(client, name) do
    account = DnsimpleElixirCli.whoami
    IO.puts "Connected as #{account.email} (ID: #{account.id})"
    IO.puts "Checking domain availability..."
    case Dnsimple.Registrar.check_domain(client, account.id, name) do
      {:ok, response} ->
        case response.data.available do
          true -> IO.puts "Domain #{name} is available for registration"
          false -> IO.puts "Domain #{name} is not available for registration"
        end
      {:error, err} ->
        IO.puts "Error checking domain availability: #{err.message}"
    end
  end

  def register(client, name, registrant_id) do
    account = DnsimpleElixirCli.whoami
    IO.puts "Connected as #{account.email} (ID: #{account.id})"
    IO.puts "Attempting to register domain..."
    case Dnsimple.Registrar.register_domain(client, account.id, name, %{registrant_id: registrant_id}) do
      {:ok, response} ->
        IO.puts "Domain #{name} registered! Expires on #{response.data.expires_on}"
      {:error, err} ->
        IO.puts "Error registering domain: #{err.message}"
    end
  end
end
