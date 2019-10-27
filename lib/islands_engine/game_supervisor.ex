defmodule IslandsEngine.GameSupervisor do
  use DynamicSupervisor

  alias IslandsEngine.Game

  def start_link(_args) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def start_game(name) when is_binary(name) do
    spec = Game.child_spec(name)
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def stop_game(name) when is_binary(name) do
    case pid_from_name(name) do
      nil ->
        {:error, :game_does_not_exist}

      pid ->
        DynamicSupervisor.terminate_child(__MODULE__, pid)
    end
  end

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  defp pid_from_name(name) do
    Game.via_tuple(name)
    |> GenServer.whereis()
  end
end
