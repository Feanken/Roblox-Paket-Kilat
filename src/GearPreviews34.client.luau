-- Shop-only 3D previews use the same factory as equipped server cosmetics.
local player=game.Players.LocalPlayer local shared=game.ReplicatedStorage:WaitForChild("PaketKilat")
local V=require(shared.Shared:WaitForChild("GearVisuals34"))local C=require(shared.Shared.Config)
local root=player:WaitForChild("PlayerGui"):WaitForChild("PaketKilatUI"):WaitForChild("Root")
local shop=root:WaitForChild("Shop")local views={}
local function viewport(parent,name,size,pos,models)
 local view=Instance.new("ViewportFrame")view.Name=name view.Size=size view.Position=pos view.BackgroundTransparency=1 view.ZIndex=12 view.Ambient=Color3.fromRGB(190,195,188)view.LightColor=Color3.fromRGB(255,245,225)view.LightDirection=Vector3.new(-1,-1,-2)view.Parent=parent
 local world=Instance.new("WorldModel")world.Parent=view
 local camera=Instance.new("Camera")camera.FieldOfView=35 camera.CFrame=CFrame.lookAt(Vector3.new(2.7,1.3,4.7),Vector3.new(0,.05,0))camera.Parent=view view.CurrentCamera=camera
 for _,m in models or {}do m.Parent=world end
 return view,world
end
for _,id in C.CosmeticOrder do
 local row=shop:WaitForChild(id)
 local m=V.Bag(id,C.Cosmetics[id].Color)
 local view=viewport(row,"BagPreview34",UDim2.fromOffset(48,42),UDim2.fromOffset(2,1),{m})
 views[id]=view local label=row:FindFirstChild("Name")if label then label.Text=C.Cosmetics[id].Name label.Position=UDim2.fromOffset(54,0)label.Size=UDim2.new(1,-184,1,0)label.TextSize=12 end
end
local gear=shop:WaitForChild("GearPanel20")
local view,world=viewport(gear,"GlovePreview34",UDim2.fromOffset(100,100),UDim2.new(1,-108,0,8),{})
view.CurrentCamera.CFrame=CFrame.lookAt(Vector3.new(2.3,.8,-3.5),Vector3.zero)
local note=Instance.new("TextLabel")note.Name="ModelLabel34"note.BackgroundTransparency=1 note.TextColor3=Color3.fromRGB(95,114,110)note.Font=Enum.Font.GothamMedium note.TextSize=10 note.Size=UDim2.fromOffset(100,16)note.Position=UDim2.new(1,-108,0,110)note.ZIndex=12 note.Parent=gear
local last
shared.Remotes.StateChanged.OnClientEvent:Connect(function(s)
 local level=s.gear and s.gear.level or 0 local nextLevel=math.min(level+1,3)
 if last==nextLevel then return end last=nextLevel world:ClearAllChildren()
 for i,side in {"Left","Right"}do
  local glove=V.Glove(nextLevel,side,Vector3.new(.72,.65,.72))
  glove:PivotTo(CFrame.new((i==1 and -.5 or .5),0,0))glove.Parent=world
 end
 note.Text=level<3 and("Model Lv "..nextLevel)or "Model Lv 3"
end)
gear.Title.Size=UDim2.new(1,-128,0,24)gear.Level.Size=UDim2.new(1,-128,0,22)gear.Detail.Size=UDim2.new(1,-128,0,60)gear.Detail.TextSize=11
