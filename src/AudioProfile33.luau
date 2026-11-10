-- Cosmetic mix and asset selection. Session preferences are local, never economy/profile data.
local P={
 CrossfadeSeconds=2,UpdateInterval=.1,LoadTimeout=8,
 Defaults={Music=.6,Ambience=.65,Effects=.8},
 Tracks={
  {Name="Prima Bossa Nova",Id="rbxassetid://1837070127",Volume=.16},
  {Name="Happy Folk",Id="rbxassetid://1842176791",Volume=.15},
 },
 Zones={
  {Name="KebunWarga",Id="rbxassetid://9112742473",Offset=Vector3.new(-62,3,1),Volume=.17,Min=8,Max=42,Phase=0},
  {Name="TamanTimur",Id="rbxassetid://9112742473",Offset=Vector3.new(135,3,72),Volume=.14,Min=7,Max=35,Phase=11},
  {Name="KebunPiknik",Id="rbxassetid://9112742473",Offset=Vector3.new(-60,3,101),Volume=.16,Min=7,Max=40,Phase=23},
  {Name="AirMancur",Id="rbxassetid://9120557315",Offset=Vector3.new(48,3,86),Volume=.21,Min=6,Max=34,Phase=4},
 },
 Cues={
  Pickup={Id="rbxassetid://9113578876",Volume=.34,Speed=1.08,Cooldown=.18,Fallback="rbxasset://sounds/action_get_up.mp3"},
  Drop={Id="rbxassetid://9113578876",Volume=.24,Speed=.88,Cooldown=.25,Fallback="rbxasset://sounds/action_jump_land.mp3"},
  Impact={Id="rbxassetid://9113579352",Volume=.38,Speed=1,Cooldown=.65,Fallback="rbxasset://sounds/action_jump_land.mp3"},
  Delivered={Id="rbxassetid://1839881844",Volume=.34,Speed=1,Cooldown=.6,Fallback="rbxasset://sounds/volume_slider.ogg",Important=true,DuckSeconds=5.5},
  Excellent={Id="rbxassetid://1836860398",Volume=.31,Speed=1,Cooldown=.6,Fallback="rbxasset://sounds/volume_slider.ogg",Important=true,DuckSeconds=5.8},
  Stamp={Id="rbxassetid://9126073001",Volume=.16,Speed=1.4,Cooldown=.3,Fallback="rbxasset://sounds/volume_slider.ogg"},
  Recover={Id="rbxasset://sounds/volume_slider.ogg",Volume=.17,Speed=.85,Cooldown=.4},
  Click={Id="rbxasset://sounds/volume_slider.ogg",Volume=.07,Speed=1.9,Cooldown=.07},
  Success={Id="rbxassetid://9126073001",Volume=.18,Speed=1.15,Cooldown=.3,Fallback="rbxasset://sounds/volume_slider.ogg"},
 },
}
for _,list in {P.Defaults,P.Tracks,P.Zones,P.Cues}do
 for _,v in list do if type(v)=="table"then table.freeze(v)end end table.freeze(list)
end
return table.freeze(P)
