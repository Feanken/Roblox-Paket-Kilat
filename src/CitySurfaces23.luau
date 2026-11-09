-- Edit migration. Split existing grass tiles; never layer a second floor over them.
local map = workspace.PaketKilat.Map
local surface = map.Surface15
assert(not surface:GetAttribute("City23"), "City23 surfaces already applied")
local basis = map.DepotPad.CFrame
local cuts = {
	{-124,134,-23,-18}, {45,51,-18,-11}, -- coastal walk and park connection
	{44,52,18,21}, {-93,-87,11,21}, -- crosswalk approaches
	{-111,-33,35,38}, {0,96,35,38}, -- connect district paving to street curb
	{-119,-114,38,134}, {113,118,38,134}, -- perimeter garden walks
}
local function rect(part)
	local p = basis:PointToObjectSpace(part.Position)
	return {x1=math.round((p.X-part.Size.X/2)*100)/100,x2=math.round((p.X+part.Size.X/2)*100)/100,
		z1=math.round((p.Z-part.Size.Z/2)*100)/100,z2=math.round((p.Z+part.Size.Z/2)*100)/100,y=p.Y}
end
local replaced,created = 0,0
for _, old in surface:GetChildren() do
	if not old:IsA("BasePart") or old.Name ~= "Grass" then continue end
	local r = rect(old)
	local relevant = {}
	local xs,zs = {r.x1,r.x2},{r.z1,r.z2}
	for _,c in cuts do
		local x1,x2,z1,z2 = math.max(r.x1,c[1]),math.min(r.x2,c[2]),math.max(r.z1,c[3]),math.min(r.z2,c[4])
		if x2-x1>.01 and z2-z1>.01 then
			table.insert(relevant,c)
			table.insert(xs,x1)table.insert(xs,x2)table.insert(zs,z1)table.insert(zs,z2)
		end
	end
	if #relevant==0 then continue end
	local function unique(a)
		table.sort(a)local b={}
		for _,v in a do if #b==0 or v-b[#b]>.01 then table.insert(b,v)end end
		return b
	end
	xs,zs=unique(xs),unique(zs)
	for i=1,#xs-1 do for j=1,#zs-1 do
		local x,z=(xs[i]+xs[i+1])/2,(zs[j]+zs[j+1])/2
		local paved=false
		for _,c in relevant do if x>c[1]and x<c[2]and z>c[3]and z<c[4]then paved=true break end end
		local p=old:Clone()
		p.Name=paved and "Pavement"or "Grass"
		p.Size=Vector3.new(xs[i+1]-xs[i],old.Size.Y,zs[j+1]-zs[j])
		p.CFrame=basis*CFrame.new(x,r.y,z)
		if paved then p.Material=Enum.Material.Pavement p.Color=Color3.fromRGB(175,175,160)end
		p:SetAttribute("City23",true)p.Parent=surface created+=1
	end end
	old:Destroy()replaced+=1
	task.wait()
end
surface:SetAttribute("City23",true)
return {replaced=replaced,created=created,tiles=#surface:GetChildren()}
