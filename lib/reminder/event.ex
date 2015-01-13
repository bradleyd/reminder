defmodule Reminder.Event do
  defmodule State do
    defstruct [:server, name: "", to_go: 0]
  end

  def start(event_name, delay) do
    spawn(__MODULE__, :init, [self(), event_name, delay])
  end

  def start_link(event_name, delay) do
    spawn_link(__MODULE__, :init, [self(), event_name, delay]) 
  end

  def init(server, event_name, delay) do
    loop(%Reminder.Event.State{server: server, name: event_name, to_go: normalize(delay)})
  end

  def cancel(pid) do
    ref = Process.monitor(pid)
    send(pid, {self(), ref, :cancel})
    receive do
      {ref, :ok, _} ->
        Process.demonitor(ref, [:flush])
        :ok
      {:DOWN, ref, :process, pid, _reason} ->
        :ok
      {foo, ref, :process, pid, _r} ->
        IO.puts foo
    end
  end

  def loop(s = %Reminder.Event.State{server: server, to_go: [t|n]}) do
    receive do
      {server, ref, :cancel} ->
        send(server, {ref, :ok, "true"})
    after 
      (t * 1000) ->
        cond do
          n == [] ->
            send(server, {:done, s.name})
          n != [] ->
            loop(%{s | to_go: n })
        end
    end
  end

  defp normalize(n) do
    limit = 49*24*60*60
    [rem(n, limit) | List.duplicate(n, div(limit, limit))]
  end
end
