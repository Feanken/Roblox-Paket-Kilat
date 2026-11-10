-- Edit-time migration. Reuses existing cleaned Creator Store bench meshes.
local map=workspace.PaketKilat.Map
assert(not map:FindFirstChild('RestStops27'),'Rest stops already installed')
local folder=Instance.new('Folder')folder.Name='RestStops27'
local benches={
 {'Depot',map.CreatorStore07.DepotBench},
 {'Plaza',map.City23.Spaces.PlazaBenchWest},
 {'Reading',map.City23.ReadingCorner.ReadingBench1},
 {'North',map.CityDecor15.Bench2},
}
for _,entry in ipairs(benches)do
 local mesh=assert(entry[2]:FindFirstChildWhichIsA('BasePart',true))
 local seat=Instance.new('Seat')seat.Name=entry[1]seat.Size=Vector3.new(math.min(mesh.Size.X*.6,4),.2,mesh.Size.Z*.5)
 seat.CFrame=mesh.CFrame*CFrame.new(0,-mesh.Size.Y*.08,-mesh.Size.Z*.1)
 seat.Transparency=1 seat.Anchored=true seat.CanCollide=false seat.CanTouch=false seat.CanQuery=false seat.CastShadow=false
 seat:SetAttribute('RestBench27',true)
 local reference=Instance.new('ObjectValue')reference.Name='BenchModel'reference.Value=entry[2]reference.Parent=seat
 local prompt=Instance.new('ProximityPrompt')prompt.Name='RestPrompt27'prompt.ActionText='Beristirahat'
 prompt.ObjectText='Bangku pemulihan'prompt.KeyboardKeyCode=Enum.KeyCode.F prompt.GamepadKeyCode=Enum.KeyCode.ButtonX
 prompt.HoldDuration=.35 prompt.MaxActivationDistance=8 prompt.RequiresLineOfSight=false
 prompt.Exclusivity=Enum.ProximityPromptExclusivity.OnePerButton prompt.Parent=seat
 seat.Parent=folder
end
folder.Parent=map
workspace.PaketKilat:SetAttribute('RestRevision','PublicBenches27')
return #folder:GetChildren()
