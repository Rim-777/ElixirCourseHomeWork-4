defmodule Tram.StateMachine do
  @moduledoc """
  Documentation for `Tram.StateMachine`.
  Processes states of Trams
  """
  require Logger
  use GenServer

  @applicable_states [:initial, :unlaunched, :launched, :moving]

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl GenServer
  def init(_args) do
    {:ok, %{previous_state: :initial, current_state: :unlaunched}}
  end

  def transit(from, _to) when from not in @applicable_states do
    not_applicable_state_message(from)
  end

  def transit(_from, to) when to not in @applicable_states do
    not_applicable_state_message(to)
  end

  def transit(from, to) do
    GenServer.cast(__MODULE__, {:transition, from, to})
  end

  def get_state do
    GenServer.call(__MODULE__, :get_state)
  end

  defp not_applicable_state_message(state),
    do: {:error, "#{state} is not applicable state type"}

  @impl GenServer
  def handle_cast({:transition, from, to}, %{current_state: current} = state)
      when from != current do
    Logger.warning("Requested transition #{from} → #{to} but current is #{current}")

    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:transition, from, to}, state) when to == from do
    Logger.warning("Stop raping the tram!!!")

    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:transition, :unlaunched, :launched}, _state) do
    new_state = %{previous_state: :unlaunched, current_state: :launched}

    {:noreply, new_state}
  end

  @impl GenServer
  def handle_cast({:transition, :launched, to}, _state) when to in [:unlaunched, :moving] do
    new_state = %{previous_state: :launched, current_state: to}
    {:noreply, new_state}
  end

  @impl GenServer
  def handle_cast({:transition, :moving, :launched}, _state) do
    new_state = %{previous_state: :moving, current_state: :launched}
    {:noreply, new_state}
  end

  def handle_cast({:transition, from, to}, state) do
    Logger.warning("State #{to}: is unreachable from: #{from}")
    {:noreply, state}
  end

  @impl GenServer
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end
end
