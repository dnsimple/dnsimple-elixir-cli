defmodule DnsimpleElixirCliTest do
  use ExUnit.Case
  doctest DnsimpleElixirCli

  test "config sets application env" do
    DnsimpleElixirCli.config(:dnsimple, base_url: "base_url")
    assert Application.get_env(:dnsimple, :base_url) == "base_url"
  end
end
