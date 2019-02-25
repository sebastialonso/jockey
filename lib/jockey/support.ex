defmodule Jockey.Support do
  def users_api_url do
    Application.get_env(:jockey, :users_api_url, nil)
  end

  def client do
    Application.get_env(:jockey, :client)
  end

  def reject_func(arg, arg2) do
    Application.get_env(:jockey, :reject_func).(arg, arg2)
  end
end