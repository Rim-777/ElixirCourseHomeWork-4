defmodule Tram.StateMachine do
  @moduledoc """
  Documentation for `Tram.StateMachine`.
  Processes states of Trams
  """

  use GenServer

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl GenServer
  def init(_args) do
    {:ok, %{previous_state: nil, current_state: :unlaunched}}
  end

  def on_transition({:unlaunched, :launched} = transition) do
    case current_tram_state() do
      :launched ->
        :already_launched

      _ ->
        send_transition(transition)
    end
  end

  def on_transition({from_state, :moving} = transition)
      when from_state in [:stopped, :launched] do
    case current_tram_state() do
      :moving ->
        :already_moving

      _ ->
        send_transition(transition)
    end
  end

  def on_transition({from_state, :stopped} = transition) when from_state in [:moving] do
    case current_tram_state() do
      :stopped ->
        :already_stopped

      _ ->
        send_transition(transition)
    end
  end

  def on_transition({from_state, :unlaunched} = transition)
      when from_state in [:stopped, :launched] do
    case current_tram_state() do
      :unlaunched ->
        :already_unlaunched

      _ ->
        send_transition(transition)
    end
  end

  def on_transition(_) do
    :unaccaptable_action
  end

  def get_state do
    GenServer.call(__MODULE__, :get_state)
  end

  defp current_tram_state do
    %{current_state: current_state} = get_state()
    current_state
  end

  defp send_transition(transition) do
    GenServer.call(__MODULE__, transition)
  end

  @impl GenServer
  def handle_call({from_state, to_state}, _from, _state) do
    new_state = %{previous_state: from_state, current_state: to_state}
    {:reply, to_state, new_state}
  end

  @impl GenServer
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end
end
