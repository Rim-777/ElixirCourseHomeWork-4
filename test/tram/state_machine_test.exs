defmodule Tram.StateMachineTest do
  use ExUnit.Case

  test "tram state changing" do
    {:ok, _pid} = Tram.System.start_link()

    assert Tram.StateMachine.get_state() == %{previous_state: nil, current_state: :unlaunched}
    assert Tram.StateMachine.on_transition({:unlaunched, :launched}) == :launched
    assert Tram.StateMachine.on_transition({:unlaunched, :launched}) == :already_launched

    assert Tram.StateMachine.get_state() == %{
             current_state: :launched,
             previous_state: :unlaunched
           }

    assert Tram.StateMachine.on_transition({:launched, :moving}) == :moving
    assert Tram.StateMachine.on_transition({:launched, :moving}) == :already_moving
    assert Tram.StateMachine.on_transition({:stopped, :moving}) == :already_moving

    assert Tram.StateMachine.get_state() == %{
             current_state: :moving,
             previous_state: :launched
           }

    assert Tram.StateMachine.on_transition({:moving, :unlaunched}) == :unaccaptable_action

    assert Tram.StateMachine.get_state() == %{
             current_state: :moving,
             previous_state: :launched
           }

    assert Tram.StateMachine.on_transition({:moving, :unlaunched}) == :unaccaptable_action
    assert Tram.StateMachine.on_transition({:moving, :stopped}) == :stopped

    assert Tram.StateMachine.get_state() == %{
             current_state: :stopped,
             previous_state: :moving
           }
  end
end
