defmodule Reminder.Event do
  defmodule State do
    defstruct [:server, name: "", to_go: 0]
  end

  def loop(s = %Reminder.Event.State{server: server, to_go: n}) do
    receive do
      {server, ref, cancel} ->
      send(server, {ref, :ok, "true"})
    after 
      (n * 1000) ->
        send(server, {:done, s.name})
    end
  end
end
