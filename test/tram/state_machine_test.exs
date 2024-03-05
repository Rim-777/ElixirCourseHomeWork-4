defmodule Tram.StateMachineTest do
  use ExUnit.Case
  import ExUnit.CaptureLog

  require Logger

  alias Tram.StateMachine

  setup do
    {:ok, _pid} = Tram.System.start_link()
    :ok
  end

  test "initial state", _state do
    assert StateMachine.get_state() == %{
             previous_state: :initial,
             current_state: :unlaunched
           }
  end

  test "from unlaunched to launched" do
    :ok = StateMachine.transit(:unlaunched, :launched)

    assert Tram.StateMachine.get_state() == %{
             previous_state: :unlaunched,
             current_state: :launched
           }
  end

  test "from launched to unlaunched" do
    :ok = StateMachine.transit(:unlaunched, :launched)
    :ok = StateMachine.transit(:launched, :unlaunched)

    assert StateMachine.get_state() == %{
             previous_state: :launched,
             current_state: :unlaunched
           }
  end

  test "from launched to mooving" do
    :ok = StateMachine.transit(:unlaunched, :launched)
    :ok = StateMachine.transit(:launched, :moving)

    assert StateMachine.get_state() == %{
             previous_state: :launched,
             current_state: :moving
           }
  end

  test "from moving to launched" do
    :ok = StateMachine.transit(:unlaunched, :launched)
    :ok = StateMachine.transit(:launched, :moving)
    :ok = StateMachine.transit(:moving, :launched)

    assert StateMachine.get_state() == %{
             previous_state: :moving,
             current_state: :launched
           }
  end

  test "from unlauched to moving" do
    :ok = StateMachine.transit(:unlaunched, :moving)

    assert StateMachine.get_state() == %{
             previous_state: :initial,
             current_state: :unlaunched
           }
  end

  test "from is equal to" do
    :ok = StateMachine.transit(:unlaunched, :unlaunched)

    assert StateMachine.get_state() == %{
             previous_state: :initial,
             current_state: :unlaunched
           }
  end

  test "not applicable state type" do
    assert StateMachine.transit(:ufo, :unlaunched) ==
             {:error, "#{:ufo} is not applicable state type"}

    assert StateMachine.transit(:unlaunched, :ufo) ==
             {:error, "#{:ufo} is not applicable state type"}
  end
end
