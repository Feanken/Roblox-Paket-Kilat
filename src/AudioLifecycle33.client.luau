-- Independent observer: Deferred Destroying does not run a destroyed script's own callbacks.
-- This script stays outside the audio controller so its resource cleanup can finish.
local player=game.Players.LocalPlayer local scripts=script.Parent
local SoundService=game:GetService("SoundService")local CAS=game:GetService("ContextActionService")
local watched=setmetatable({},{__mode="k"})
local function cleanup()
 local mix=SoundService:FindFirstChild("PaketKilatAudio33")
 if mix then
  local effects=mix:FindFirstChild("Effects")local refs=mix:FindFirstChild("CharacterGroups33")
  if refs then for _,ref in refs:GetChildren()do
   local sound=ref.Value local previous=ref:FindFirstChild("PreviousGroup")
   if sound and sound.Parent and sound.SoundGroup==effects then sound.SoundGroup=previous and previous.Value or nil end
  end end
  for _,sound in mix:GetDescendants()do if sound:IsA("Sound")then sound:Stop()end end
  mix:Destroy()
 end
 local world=workspace:FindFirstChild("PaketKilatLocalAudio33")if world then world:Destroy()end
 local gui=player:FindFirstChild("PlayerGui")local screen=gui and gui:FindFirstChild("PaketKilatUI")local root=screen and screen:FindFirstChild("Root")
 if root then
  for _,name in {"AudioToggle33","AudioPanel33","AudioBackdrop33"}do local v=root:FindFirstChild(name)if v then v:Destroy()end end
  root:SetAttribute("AudioOpen33",false)
 end
 CAS:UnbindAction("PKMusic33")
end
local function watch(owner)
 if owner.Name~="PaketKilatSoundscape33"or not owner:IsA("LocalScript")or watched[owner]then return end
 watched[owner]=true
 owner.Destroying:Connect(cleanup)
 owner:GetPropertyChangedSignal("Enabled"):Connect(function()if not owner.Enabled then cleanup()end end)
 owner.AncestryChanged:Connect(function()if not owner:IsDescendantOf(scripts)then cleanup()end end)
end
scripts.ChildAdded:Connect(watch)
for _,v in scripts:GetChildren()do watch(v)end
