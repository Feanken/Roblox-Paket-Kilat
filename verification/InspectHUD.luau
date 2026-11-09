-- Eksekusi read-only pada Client; posisi HUD memakai koordinat area CoreUI.
local player=game.Players.LocalPlayer
local gui=player.PlayerGui.PaketKilatUI
local root=gui.Root
local out={viewport=tostring(workspace.CurrentCamera.ViewportSize),rootSize=tostring(root.AbsoluteSize),touch=game:GetService("UserInputService").TouchEnabled,orientation=tostring(game.StarterGui.ScreenOrientation),screenInsets=tostring(gui.ScreenInsets),elements={},coreControls={}}
local objects={root.TopCard,root.Actions.Primary,root.Actions.Secondary}
local function rect(o)
	local p,s=o.AbsolutePosition,o.AbsoluteSize
	return {x=p.X,y=p.Y,w=s.X,h=s.Y}
end
local function overlap(a,b)
	return a.x<b.x+b.w and a.x+a.w>b.x and a.y<b.y+b.h and a.y+a.h>b.y
end
out.pass=true
for _,o in ipairs(objects) do
	if o.Visible then
		local bounds=rect(o)
		local within=bounds.x>=0 and bounds.y>=0 and bounds.x+bounds.w<=root.AbsoluteSize.X+1 and bounds.y+bounds.h<=root.AbsoluteSize.Y+1
		out.pass=out.pass and within
		table.insert(out.elements,{name=o.Name,bounds=bounds,within=within,text=o:IsA("TextButton") and o.Text or nil})
	end
end
for a=1,#out.elements do for b=a+1,#out.elements do if overlap(out.elements[a].bounds,out.elements[b].bounds) then out.pass=false end end end
for _,o in ipairs(root.TopCard:GetChildren()) do
	if o:IsA("TextLabel") then
		local fits=o.TextBounds.X<=o.AbsoluteSize.X+1 and o.TextBounds.Y<=o.AbsoluteSize.Y+1
		table.insert(out.elements,{name=o.Name,text=o.Text,textFits=fits})
		out.pass=out.pass and fits
	end
end
local touch=player.PlayerGui:FindFirstChild("TouchGui")
if touch then for _,o in ipairs(touch:GetDescendants()) do
	if o:IsA("GuiObject") and (o.Name=="JumpButton" or o.Name=="DynamicThumbstickFrame") then table.insert(out.coreControls,{name=o.Name,bounds=rect(o),visible=o.Visible}) end
end end
local inset=game:GetService("GuiService"):GetGuiInset()
out.guiInset=tostring(inset)
out.state=root:GetAttributes()
return game.HttpService:JSONEncode(out)
