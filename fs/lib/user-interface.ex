defmodule UI do

	def start do
		IO.puts("Welcome to audio file share.")
		IO.puts("Type help for options.")
		get_response(:continue)
	end

	def get_response(status) do
		case status do

		:continue->
		response = IO.gets("Please enter a command: ")
		response = String.trim(response)
		handle_response(response)

		:exit->
		IO.puts("Thank you, applcation shutting down.")
		end
	end

	def handle_response(r) do
		case r do

		"download"-> download()
		get_response(:continue)

		"help" -> IO.puts("download: Attempted to download audio file.")
		IO.puts("help: List possible commands.")
		IO.puts("list-files: List local audio files.")
		IO.puts("exit: Quit the application.")
		get_response(:continue)

		"list-files" -> IO.puts("Audio Files:")
		IO.puts("Artist/Author,Title")
    path = Path.expand('~')
		IO.puts(File.read!("#{path}/.songs.csv"))
		File.close("#{path}/.songs.csv")
		get_response(:continue)

		"exit" -> get_response(:exit)

		_-> IO.puts("Unknown command please try again.")
		get_response(:continue)
		end
	end

	def download() do
	#Function to download song from either server or local network.
	artist = IO.gets("Enter artist/author name: ")
	artist = String.trim(artist)
	song = IO.gets("Enter song/book title: ")
	song = String.trim(song)
	
	case SongCollection.read(%{Artist: "#{artist}", Song: "#{song}"}) do
	{:ok, _info} ->
		IO.puts("File exists on device.")
	{:NA} ->
		#Try to search local network for file
		cluster_response = FS.search_network(%{Artist: "#{artist}", Song: "#{song}"})
		case cluster_response do
			{:ok} -> IO.puts("File found on local network")
			:SONG_NOT_FOUND ->
				IO.puts("File not found on local network")
				#Download file from server
				FS.Client.server_download(artist,song)
			_->IO.puts("Possible error has occured please try again.")
		end
	end
	end


end
