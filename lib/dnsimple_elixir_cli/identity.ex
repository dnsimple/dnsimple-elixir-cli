defmodule DnsimpleElixirCli.Identity do
  def whoami(client) do
    case Dnsimple.Identity.whoami(client) do
      {:ok, response} ->
        IO.puts """
        You are currently authenticated as:

          Account ID: #{response.data.account.id}
          Account email: #{response.data.account.email}
        """
      {:error, err} ->
        IO.puts "Failed to authenticate: #{err.message}"
    end
  end
end
