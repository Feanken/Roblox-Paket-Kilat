-- Start the bounded local resident controller. House delivery customers remain separate.
local shared=game.ReplicatedStorage:WaitForChild("PaketKilat"):WaitForChild("Shared")
local map=workspace:WaitForChild("PaketKilat"):WaitForChild("Map")
map:WaitForChild("DepotPad")
local residents=require(shared:WaitForChild("CityResidents37"))
residents.Start(game.Players.LocalPlayer,map,require(shared:WaitForChild("ResidentProfiles37")),script)
