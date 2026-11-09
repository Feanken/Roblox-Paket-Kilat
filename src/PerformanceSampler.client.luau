-- Opt-in local diagnostic, never uploaded. Render cadence, not a GPU benchmark.
local Run=game:GetService("RunService")
local C=require(game.ReplicatedStorage:WaitForChild("PaketKilat").Shared.Config)
local root=game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("PaketKilatUI"):WaitForChild("Root")
local guide=root:WaitForChild("Guide")
local running=false local elapsed,window,frames,slow=0,0,0,0 local samples={}
local function summary(done)
	local sorted=table.clone(samples) table.sort(sorted)
	local median=#sorted>0 and sorted[math.ceil(#sorted/2)] or 0
	local low=#sorted>0 and sorted[1] or 0
	local text=string.format("FPS median %.0f · min %.0f · lambat %d\n%s %d/%d dtk",median,low,slow,done and "Selesai" or "Mengukur",math.floor(elapsed),C.Performance.Duration)
	root:SetAttribute("PerfText",text)
	root:SetAttribute("PerfMedian",median) root:SetAttribute("PerfMin",low) root:SetAttribute("PerfSlowFrames",slow)
	root:SetAttribute("PerfSeconds",elapsed) root:SetAttribute("PerfSamples",#samples)
end
guide.FPS.Activated:Connect(function()
	if running then running=false root:SetAttribute("PerfRunning",false) root:SetAttribute("PerfShowing",false) guide.FPS.Text="FPS" return end
	running=true elapsed,window,frames,slow=0,0,0,0 table.clear(samples)
	root:SetAttribute("PerfRunning",true) root:SetAttribute("PerfShowing",true) root:SetAttribute("PerfComplete",false)
	guide.FPS.Text="Stop" summary(false)
end)
Run.RenderStepped:Connect(function(dt)
	if not running or dt<=0 or dt~=dt or dt==math.huge then return end
	elapsed+=dt window+=dt frames+=1 if dt>C.Performance.SlowFrameSeconds then slow+=1 end
	if window>=1 then table.insert(samples,frames/window) window=0 frames=0 summary(false) end
	if elapsed>=C.Performance.Duration then
		running=false root:SetAttribute("PerfRunning",false) root:SetAttribute("PerfComplete",true)
		guide.FPS.Text="Ulang" summary(true)
	end
end)
