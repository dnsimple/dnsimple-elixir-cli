# Dnsimple CLI

A simple CLI for the DNSimple v2 API.

## Configuration

Create a file `settings/local.exs` with the following:

```elixir
DnsimpleElixirCli.config :dnsimple,
  access_token: "token"
```

You may also connect to the [DNSimple sandbox](https://sandbox.dnsimple.com) by specifying the base URL:

```elixir
DnsimpleElixirCli.config :dnsimple,
  base_url: "https://api.sandbox.dnsimple.com",
  access_token: "sandbox-token"
```

Make sure to use a token generated in the sandbox as a token from production will not work in the sandbox.

You can also create different settings by giving them whatever name you want and then using the `--env` switch when running the script to choose your settings.

For example

```sh
./dnsimple_elixir_cli registrar.check example.com --env production
```

Would use `settings/production.exs` for its settings.

## Building

Build the escript with:

`mix escript.build`
