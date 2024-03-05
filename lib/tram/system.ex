defmodule Tram.System do
  def start_link do
    Supervisor.start_link(
      [
        Tram.StateMachine
      ],
      strategy: :one_for_one
    )
  end
end
