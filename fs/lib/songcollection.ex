defmodule SongCollection do
  def write(song_info) do
    path = Path.expand('~')
    artist = song_info[:Artist]
    song = song_info[:Song]
    file = File.open!('#{path}/.songs.csv', [:append])
    IO.write(file, '#{artist},#{song}\n' )
    File.close(file)
  end
  def read(song_info) do
		#Search our song.csv for the song and artist requested.
		#Input: song_info- dictionary of Artist and Song of the
    #request information.
    path = Path.expand('~')
		wanted_song = song_info[:Song]
		wanted_artist = song_info[:Artist]
    song = "#{path}/.songs.csv"
    |> Path.expand(__DIR__)
    |> File.stream!
    |> CSV.decode(separator: ?,, headers: [:Artist, :Song])
    |> Enum.to_list()
    |> Enum.find(fn(x)->
      {:ok, track_info } = x
      artist = track_info[:Artist]
      song  = track_info[:Song]
      artist == wanted_artist && song == wanted_song
    end
    )
		case song do
		 {:ok, info} -> {:ok,"#{info[:Artist]}-#{info[:Song]}"}
			_->{:NA}
		end
  end
end
