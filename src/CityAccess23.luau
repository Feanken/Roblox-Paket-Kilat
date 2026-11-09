-- Open real crossings through the old canal parapets, now between two paved districts.
local map=workspace.PaketKilat.Map local root=map.City23 local basis=map.DepotPad.CFrame
assert(not root:FindFirstChild('Access'),'City23 access exists')
local folder=Instance.new('Folder')folder.Name='Access'folder.Parent=root
local retired,segments,posts=0,0,0
for _,p in map.Polish05:GetChildren()do
	if not p:IsA('BasePart')or p.Transparency>=.99 then continue end
	local at=basis:PointToObjectSpace(p.Position)
	if math.abs(at.Z-35)>.05 then continue end
	if p.Name=='ParapetPost'and(math.abs(at.X-47)<5.5 or math.abs(at.X+90)<5.5)then
		p.Transparency=1 p.CanCollide=false p.CanQuery=false p.CastShadow=false posts+=1
	elseif p.Name=='CanalParapet'or p.Name=='ParapetCap'then
		local x1,x2=at.X-p.Size.X/2,at.X+p.Size.X/2
		local opening=at.X<0 and -90 or 47
		if opening+5>x1 and opening-5<x2 then
			for _,range in {{x1,opening-5},{opening+5,x2}}do
				if range[2]-range[1]>.05 then
					local q=p:Clone()q.Name='Crossing'..p.Name
					q.Size=Vector3.new(range[2]-range[1],p.Size.Y,p.Size.Z)
					q.CFrame=CFrame.new(basis:PointToWorldSpace(Vector3.new((range[1]+range[2])/2,at.Y,at.Z)))*p.CFrame.Rotation
					q.Parent=folder segments+=1
				end
			end
			p.Transparency=1 p.CanCollide=false p.CanQuery=false p.CastShadow=false retired+=1
		end
	end
end
-- Replace clipping floating labels with physical boards on the courtyard frontage.
for _,spec in {
	{'TOKO ROTI','ROTI KAMPUNG','DIPANGGANG SETIAP PAGI'},
	{'RUMAH SUSUN','WISMA KILAT','HUNIAN WARGA'},
	{'BENGKEL','BENGKEL SEPEDA','SERVIS & SUKU CADANG'},
	{'TOKO BUKU','BUKU & CERITA','BACA · TULIS · BELAJAR'},
	{'KANTOR KAMPUNG','BALAI WARGA','KAMPUNG KILAT'},
}do
	local old=map.City13[spec[1]]local body=old.Body
	for _,v in old:GetDescendants()do if v:IsA('BillboardGui')then v.Enabled=false end end
	local at=basis:PointToObjectSpace(body.Position)
	local board=Instance.new('Part')board.Name='CourtyardSign'board.Size=Vector3.new(body.Size.X-1,2.3,.35)
	board.CFrame=basis*CFrame.new(at.X,9.1,at.Z+body.Size.Z/2+.35)*CFrame.Angles(0,math.pi,0)
	board.Color=old.Roof.Color board.Material=Enum.Material.SmoothPlastic board.Anchored=true board.CanCollide=false board.CanTouch=false board.CanQuery=false board.Parent=folder
	local g=Instance.new('SurfaceGui')g.Face=Enum.NormalId.Front g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud g.PixelsPerStud=35 g.Parent=board
	local title=Instance.new('TextLabel')title.Size=UDim2.fromScale(1,.62)title.BackgroundTransparency=1 title.Font=Enum.Font.GothamBold title.Text=spec[2]title.TextScaled=true title.TextColor3=Color3.fromRGB(239,229,207)title.Parent=g
	local sub=title:Clone()sub.Position=UDim2.fromScale(0,.63)sub.Size=UDim2.fromScale(1,.3)sub.Font=Enum.Font.GothamMedium sub.Text=spec[3]sub.Parent=g
end
return {retiredPanels=retired,segments=segments,hiddenPosts=posts}
