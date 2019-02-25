defmodule Jockey do
  use Decorator.Define, [allow: 2, fetch: 1]
  alias Jockey.{Support, ApiClient}
  @moduledoc """
  Documentation for Jockey.
  """
  def allow(action, object_name, body, %{args: [conn, _params]}) do
    quote do
      params = %{action: unquote(action), object_name: unquote(object_name)}
      api_call = unquote(conn)
        |> Plug.Conn.get_req_header("authorization")
        |> List.to_string()
        |> ApiClient.make_client()
        |> ApiClient.authorize(params)
      
      case api_call.status do
        200  ->
          unquote(body)
        _ ->
          Support.reject_func(unquote(conn), api_call)
      end
    end
  end

  def fetch(object_name, body, %{args: [conn, _params]}) do
    quote do
      params = %{object_name: unquote(object_name)}
      api_call = unquote(conn)
        |> Plug.Conn.get_req_header("authorization")
        |> List.to_string()
        |> ApiClient.make_client()
        |> ApiClient.fetch_resources(params)
        
      case api_call.status do
        200 ->
          unquote(conn) = Plug.Conn.assign(unquote(conn), :resources, api_call.resp_body.resources)
          unquote(body)
        _ ->
          Support.reject_func(unquote(conn), api_call)  
      end
    end
  end
end
