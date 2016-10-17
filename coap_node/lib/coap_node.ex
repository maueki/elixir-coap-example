defmodule CoapNode do
  use Application

  def start(_type, port) do
    IO.puts "CoapNode.start"
    CoapNode.Supervisor.start_link(port)
  end

end
