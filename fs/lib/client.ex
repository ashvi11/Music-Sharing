defmodule FS.Client do

	@doc """
	Attempts to call http request to the server.
	Requests the urls to use to request a file from the server.

	artist- string of artist/author name.
	song- string of title of song/book etc.
	"""
	def server_download(artist, song) do
		list = [song_name: "#{song}", artist: "#{artist}"]
		{_status, result} = JSON.encode(list)
		case HTTPoison.post("localhost:8085/download",result) do
			{:ok, %HTTPoison.Response{status_code: 200, body: body}}->
			resp = JSON.decode!(body)
			resp_length = length(resp)
			case resp_length do
				0->IO.puts("Artist/Title combination not found on server.")
				_->get_files(resp,resp_length)
				IO.puts("Downloaded from server.")
			end
			{:error, reason}->IO.inspect(reason)
		end
	end

	@doc """
	Makes get request to the server to receive files.
	files-List of dictionaries with files to call get request on.
	size- Length of files if 1 don't make directory in .songs.
	file- artist: url: title:
	"""
	def get_files(files,size) do
		title = List.first(files)["title"]
		artist = List.first(files)["artist"]
		if size > 1 do
			#Make dir for book/multi file
			path = Path.expand("~")
			case File.mkdir("#{path}/.songs/#{artist}-#{title}") do
				:ok->IO.puts("Created directory for requested file.")
				{:error, _reason}->IO.puts("Requested title and author directory exists.")
			end
		end
		for file <- files do
				url = file["url"]
				#Send GET request
				file_name = String.split(url,"/")
				file_name = List.last(file_name)
				id = Enum.at(String.split(file_name,"_"), 1) #get book id
				file_extension = List.last(String.split(file_name, "."))
				path = Path.expand("~")
				#Download song from server
				case size do
					#Single file
					1->
					case HTTPoison.get(url) do
						{:ok, %HTTPoison.Response{status_code: 200, body: body}}->
						File.touch("#{path}/.songs/#{file_name}")
						f = File.open!("#{path}/.songs/#{file_name}",[:write])
						IO.binwrite(f,body)

						{:error, %HTTPoison.Error{reason: reason}}->IO.inspect(reason)
					end
					#Rename file
					File.rename("#{path}/.songs/#{file_name}","#{path}/.songs/#{artist}-#{title}.#{file_extension}")

					#Multi file/book
					_->
					case HTTPoison.get(url) do
						{:ok, %HTTPoison.Response{status_code: 200, body: body}}->
						File.touch("#{path}/.songs/#{artist}-#{title}/#{file_name}")
						f = File.open!("#{path}/.songs/#{artist}-#{title}/#{file_name}",[:write])
						IO.binwrite(f,body)

						{:error, %HTTPoison.Error{reason: reason}}->IO.inspect(reason)
					end
					File.rename("#{path}/.songs/#{artist}-#{title}/#{file_name}","#{path}/.songs/#{artist}-#{title}/#{artist}-#{title}-#{id}.#{file_extension}")

				end
		end
				#Update .songs.csv
				SongCollection.write(%{Artist: "#{artist}", Song: "#{title}"})
		end
end
