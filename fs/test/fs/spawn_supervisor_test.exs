defmodule FS.CreateSpawnerTest do
	use ExUnit.Case, async: true
	
	setup do
		spawner = start_supervised!(FS.Spawner)
		%{spawner: spawner}
	end
	
	test "spawn supervisor", %{spawner: spawner} do
		assert FS.Spawner.start_supervisor(spawner, "supervisor") == :ok
	end
end
