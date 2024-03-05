defmodule Tram.StateMachine do
  @moduledoc """
  Documentation for `Tram.StateMachine`.
  Processes states of Trams
  """
  require Logger
  use GenServer

  @applicable_states [:initial, :unlaunched, :launched, :moving]

  def start_link(_args) do
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
    Logger.error("Requested transition #{from} → #{to} but current is #{current}")

    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:transition, from_to, from_to}, state) do
    Logger.warning("Stop raping the tram!!!")

    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:transition, :unlaunched, :launched}, %{current_state: :unlaunched}) do
    new_state = %{previous_state: :unlaunched, current_state: :launched}

    {:noreply, new_state}
  end

  @impl GenServer
  def handle_cast({:transition, :launched, :unlaunched}, %{current_state: :launched}) do
    new_state = %{previous_state: :launched, current_state: :unlaunched}
    {:noreply, new_state}
  end

  @impl GenServer
  def handle_cast({:transition, :launched, :moving}, %{current_state: :launched}) do
    new_state = %{previous_state: :launched, current_state: :moving}
    {:noreply, new_state}
  end

  @impl GenServer
  def handle_cast({:transition, :moving, :launched}, %{current_state: :moving}) do
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
