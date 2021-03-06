defmodule CoapNode.Resources.Switch do
  use Coap.Resource
  alias Coap.Storage

  def start(path, params) do
    {:ok, port} = Application.fetch_env(:coap_node, :coap_port)
    {:ok, registry_endpoint} = Application.fetch_env(:coap_node, :registry_endpoint)
    {:ok, :content, {:coap_content, _etags, _max_age, _format_, payload}} = :coap_client.request(
      :post, registry_endpoint,
      coap_content(payload: path_to_string(path) <> " " <> Integer.to_string(port))
    )

    case payload do
      "ok" ->
        Storage.set(path_to_string(path), false)
        super(path, params)
      "path taken" -> :path_taken
    end
  end

  # gen_coap handlers

  def coap_get(_ch_id, prefix, _name, _query) do
    key = path_to_string(prefix)
    IO.puts "CoapNode.Resources.Switch.coap_get: key = #{key}"
    case Storage.get(key) do
      :not_found -> coap_content(payload: "not found")
      value -> coap_content(payload: key <> " " <> serialize_value(value))
    end
  end

  def coap_put(_ch_id, prefix, _name, content) do
    {:coap_content, _etag, _max_age, _format, payload } = content
    key = path_to_string(prefix)
    response = process_payload(key, payload)
    IO.puts "CoapNode.Resources.Switch.coap_put key: #{key}"
    :coap_responder.notify(prefix, coap_content(payload: key <> " " <> serialize_value(response)))
  end

  defp serialize_value(value) do
    cond do
      is_boolean(value) -> if(value, do: "on", else: "off")
      true -> value
    end
  end

  defp path_to_string(path) do
    Enum.join(path, "/")
  end

  defp process_payload(storage_key, payload) do
    case payload do
      "on" -> Storage.set(storage_key, true, true)
      "off" -> Storage.set(storage_key, false, true)
      "toggle" -> Storage.set(storage_key, fn(state) -> !state end, true)
      _ -> "not recognized"
    end

  end

end
