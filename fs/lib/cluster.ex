defmodule Cluster do
  use Application
  def start(_type, _args) do
    topologies = [
      example: [
        strategy: Cluster.Strategy.Gossip,
        config: [
          port: 45892,
          if_addr: "0.0.0.0",
          multicast_addr: "230.1.1.251",
          secret: "token"
        ]
      ]
    ]
    children = [
      {Cluster.Supervisor, [topologies, [name: Cluster ]]},
      {Task.Supervisor, name: FS.TaskSupervisor},
    ]
    init()
    Supervisor.start_link(children, strategy: :one_for_one, name: MyApp.Supervisor)
  end
  defp init() do
    path = Path.expand("~")
    File.mkdir('#{path}/.songs')
    File.touch('#{path}/.songs.csv')
  end
end
