defmodule DnsimpleElixirCli.Contacts do

  def list(client) do
    IO.puts "Retrieving contact list..."
    account = DnsimpleElixirCli.whoami
    case Dnsimple.Contacts.list_contacts(client, account.id) do
      {:ok, %Dnsimple.Response{data: contacts}} ->
        IO.puts """
        Contacts in the account #{account.email} (ID: #{account.id}):
        """

      Enum.each(contacts, fn(contact) ->
        IO.puts "  * #{contact.id} : #{contact.first_name}"
      end)
      {:error, err} ->
        IO.puts "Error retrieving contacts: #{err.message}"
    end
  end

end
