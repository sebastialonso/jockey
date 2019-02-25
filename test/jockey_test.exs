defmodule JockeyTest do
  use ExUnit.Case
  import Mock
  # doctest Jockey
  
  defmodule DoesImportantThings do
    use Jockey

    @decorate allow("write_thing", "Thing")
    def create_important_things(conn, _map) do
      5 + 5
    end

    @decorate fetch("Thing")
    def fetch_important_things(conn, _map) do
      conn.assigns.resources
    end

    def reject_mock(_conn, _api_call) do
      :failed
    end
  end

  defmodule ApiClientMock do
    use Tesla

    def make_client(_token) do
      Tesla.build_client [
        {Tesla.Middleware.BaseUrl, "test-no-url"},
        {Tesla.Middleware.Headers, %{"authorization" => "test-no-bearer-token"}}
      ]
    end

    def authorize(_client, _params) do
      %Plug.Conn {
        status: 200
      }
    end

    def resources(_client, _params) do
      %Plug.Conn {
        status: 200,
        resp_body: %{resources: [%{id: 1, name: "Green Thing"}, %{id: 2, name: "Red Thing"}]}
      }
    end
  end
  
  describe "allow decorator" do
    setup do
      Application.put_env(:jockey, :reject_func, &DoesImportantThings.reject_mock/2)
      Application.put_env(:jockey, :client, nil)
      Application.put_env(:jockey, :users_api_url, "http://example.com")
      [conn: %Plug.Conn{}]
    end

    test "successfully allows", %{conn: conn} do
      with_mock Jockey.ApiClient, [
        make_client: fn(token) ->  ApiClientMock.make_client(token) end,
        authorize: fn(_client, _params) -> %Plug.Conn{status: 200} end
      ] 
      do
        assert DoesImportantThings.create_important_things(conn, %{"one" => "Carlos"}) == 10
      end
    end
  
    test "successfully forbids", %{conn: conn} do
      with_mock Jockey.ApiClient, [
        make_client: fn(token) ->  ApiClientMock.make_client(token) end,
        authorize: fn(_client, _params) -> %Plug.Conn{status: 401} end
      ]
      do
        assert DoesImportantThings.create_important_things(conn, %{"one" => "Carlos"}) == :failed
      end
    end
  end

  describe "fetch decorator" do
    setup do
      Application.put_env(:jockey, :reject_func, &DoesImportantThings.reject_mock/2)
      Application.put_env(:jockey, :client, nil)
      Application.put_env(:jockey, :users_api_url, "http://example.com")
      [conn: %Plug.Conn{}]
    end

    test "successfully fetch", %{conn: conn} do
      with_mock Jockey.ApiClient, [
        make_client: fn(token) ->  ApiClientMock.make_client(token) end,
        authorize: fn(_client, _params) -> %Plug.Conn{status: 200} end,
        fetch_resources: fn(client, params) -> ApiClientMock.resources(client, params) end
      ] 
      do
        resources = DoesImportantThings.fetch_important_things(conn, %{"one" => "Carlos"})
        assert is_list(resources)
        assert Enum.count(resources) == 2
      end
    end

    test "runs reject_func when failed", %{conn: conn} do
      with_mock Jockey.ApiClient, [
        make_client: fn(token) ->  ApiClientMock.make_client(token) end,
        authorize: fn(_client, _params) -> %Plug.Conn{status: 200} end,
        fetch_resources: fn(_client, _params) -> %Plug.Conn{status: 401} end
      ] 
      do
        assert DoesImportantThings.fetch_important_things(conn, %{"one" => "Carlos"}) == :failed
      end
    end
  end
end
