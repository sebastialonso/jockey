defmodule Jockey.ApiClient do
  use Tesla
  alias Jockey.Support
  @moduledoc """
  This module is the client which communicates with the NurData users service.
  It should be used mainly for pre-request authorization
  """

  plug Tesla.Middleware.JSON

  @doc """
  Builds a runtime client with a dynamic token value
  """
  def make_client(token) do
    Tesla.build_client [
      {Tesla.Middleware.BaseUrl, users_api_url()},
      {Tesla.Middleware.Headers, %{"authorization" => token}}
    ]
  end

  @doc """
  Runs the authorization request to the NurData users service,
  checking if the client is authorized for the given action
  """
  def authorize(client, params) do
    query = Map.keys(params) |> Enum.map(fn key ->
      { key, params[key]}
    end)
    get(client, "/api/authorize", query: %{params: query})
  end
  
  def fetch_resources(client, params) do
    get(client, "/api/resources", query: params)
  end

  def users_api_url do
    case Support.users_api_url() do
      nil ->
        "http://no_host_defined_in_config"
      url ->
        url
    end
  end
end