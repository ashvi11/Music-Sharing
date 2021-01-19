defmodule FS do
  def remote_search(requested_audio) do
    IO.puts("searching for audio")
    response = SongCollection.read(requested_audio)
    Tuple.append(response, Node.self())
  end

  def remote_read_file(file_name) do
    path = Path.expand('~')
    isDir = File.dir?('#{path}/.songs/#{file_name}')
    case isDir do
      true ->
        file_list = File.ls!('#{path}/.songs/#{file_name}')
        files = Enum.map(file_list, fn file -> %{file_name: file, file: File.read!('#{path}/.songs/#{file_name}/#{file}')} end)
        {file_name, files, isDir }
      false ->
        files = [%{file_name: file_name, file: File.read!('#{path}/.songs/#{file_name}.mp3')}]
        {file_name, files, isDir }
    end
  end

  @doc """
    TODO
    code for writing audio on local node
  """
  def write_file(response) do
    # example working code to write the file in tmp folder
    {file_name, files, isDir } = response
    path = Path.expand('~')
    case isDir do
      true ->
        File.mkdir!('#{path}/.songs/#{file_name}')
        Enum.map(files, fn file -> File.write!('#{path}/.songs/#{file_name}/#{file[:file_name]}', file[:file]) end)
      false ->
        file = List.first(files)
        File.write!('#{path}/.songs/#{file_name}.mp3', file[:file])
    end
  end

  def search_network(requested_audio) do
    response =
    Stream.filter(Node.list(), fn node ->
      String.match?(Atom.to_string(node), ~r/localhost/iu)
    end)
    |> Stream.map(fn node -> search_request(node, requested_audio) end)
    |> Enum.to_list()
    |> List.first()

    case response do
      {:ok, file_name, node_with_the_file} ->
        read_and_write_file(node_with_the_file, file_name)
        SongCollection.write(requested_audio)
        {:ok}
      _ ->
        :SONG_NOT_FOUND
    end
  end

  @doc """
  the method that is called when sending a search request to a remote node
  """
  def search_request(recipient, requested_audio) do
    spawn_task(__MODULE__, :remote_search, recipient, [requested_audio])
  end

  def read_and_write_file(recipient, file_name) do
    response = spawn_task(__MODULE__, :remote_read_file, recipient, [file_name])
    write_file(response)
  end

  @doc """
  Spawns a supervisor on a remote node and adds a task to in the supervision tree
  Waits for the task to complete and Pipes the output to the current(Parent) node
  Look up Task.supervisor and IO for more details.
  """
  def spawn_task(module, fun, recipient, args) do
    recipient
    |> remote_supervisor()
    |> Task.Supervisor.async(module, fun, args)
    |> Task.await()
  end

  defp remote_supervisor(recipient) do
    {FS.TaskSupervisor, recipient}
  end
end
