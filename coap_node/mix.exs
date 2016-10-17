defmodule CoapNode.Mixfile do
  use Mix.Project

  @default_port 5683

  def project do
    [app: :coap_node,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      mod: {CoapNode, port()},
      applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:gen_coap, git:  "https://github.com/gotthardp/gen_coap.git"},
      {:coap, path: "../coap"}
    ]
  end

  defp port do
    if port = System.get_env("COAP_PORT") do
      case Integer.parse(port) do
        {port, ""} -> port
        _ -> @default_port
      end
    else
      @default_port
    end
  end
end
