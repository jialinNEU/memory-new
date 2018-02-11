defmodule MemoryWeb.GamesChannel do
  use MemoryWeb, :channel

  alias Memory.Game
  alias Memory.GameBackup

  def join("games:" <> name, payload, socket) do
    if authorized?(payload) do

      game = GameBackup.load(name) || Game.new()

      socket = socket
      |> assign(:game, game)
      |> assign(:name, name)

      {:ok, %{ "view" => Game.client_view(game) }, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end


  def handle_in("game_restart", %{}, socket) do
    game1 = Game.new()
    GameBackup.save(socket.assigns[:name], game1)
    socket = assign(socket, :game, game1)
    {:reply, {:ok, %{"view" => Game.client_view(game1)} }, socket}
  end


  def handle_in("user_click", %{"index" => idx}, socket) do
    game0 = socket.assigns[:game]
    game1 = Game.handle_click(game0, idx);
    GameBackup.save(socket.assigns[:name], game1)

    socket = assign(socket, :game, game1)
    {:reply, {:ok, %{"view" => Game.client_view(game1)} }, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (games:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
