-- Konfigurasi gameplay lokal T11-T15. Tidak ada layanan daring/pembelian.
local routes = {
	CBD01 = {Name="Menara Kilat", Landmark="Pusat kota · pintu utama", Offset=Vector3.new(-38,0,168), TargetSeconds=65, DepotJobOnly=true},
	BQ16 = {Name="Galeri Tepi Air", Landmark="Bata Quay · galeri", Offset=Vector3.new(-223.8,0,243.7), TargetSeconds=110, DepotJobOnly=true},
	BQ10 = {Name="Kantor Arsitek", Landmark="Bata Quay · ruko bata", Offset=Vector3.new(-223.8,0,186.2), TargetSeconds=100, DepotJobOnly=true},
	Rumah01 = {Name="Rumah Bu Sari", Landmark="Biru · pot bunga", Offset=Vector3.new(100,0,0), TargetSeconds=45},
	Rumah02 = {Name="Rumah Pak Budi", Landmark="Oranye · warung", Offset=Vector3.new(-100,0,0), TargetSeconds=45},
	Rumah03 = {Name="Rumah Bu Rina", Landmark="Ungu · kebun", Offset=Vector3.new(0,0,120), TargetSeconds=35},
	Rumah04 = {Name="Rumah Pak Agus", Landmark="Hijau · peti", Offset=Vector3.new(100,0,120), TargetSeconds=60},
	Rumah05 = {Name="Rumah Bu Dewi", Landmark="Kuning · tangki", Offset=Vector3.new(-100,0,120), TargetSeconds=60},
}
for _,r in pairs(routes) do table.freeze(r) end
local schedule = {}
for i=1,10 do
	schedule[i] = table.freeze({DestinationId=string.format("Rumah%02d",(i-1)%5+1), PackageType=i%2==1 and "Biasa" or "Rapuh"})
end
return table.freeze({
 Onboarding=table.freeze({Width=430,Height=66,
  FindDepot="1/3 · Dekati DEPOT, lalu Ambil pesanan.",
  Deliver="2/3 · Ikuti TUJUAN. Dekati titik serah, lalu Antar.",
  Dropped="Paket lepas: Ambil ulang, atau Pulihkan (-20 kondisi).",
  ReturnDepot="3/3 · Berhasil! Kembali ke DEPOT untuk pesanan kedua.",
  Complete="Siap! Pilih rute, jaga paket, dan terus antar.",
 }),
 Performance=table.freeze({Duration=60,SlowFrameSeconds=0.1}),
	ActionDistance=12, RequestCooldown=0.2, RecoveryCooldown=5,
	InitialCondition=100, InitialCoins=0, BaseReward=25, ConditionBonus=15, TimeBonus=10,
	Routes=table.freeze(routes), OrderSchedule=table.freeze(schedule),
	PackageTypes=table.freeze({
		Biasa=table.freeze({ImpactDamage=10,Color=Color3.fromRGB(200,151,79)}),
		Rapuh=table.freeze({ImpactDamage=20,Color=Color3.fromRGB(236,135,135)}),
	}),
	PackageDeliveryDistance=15, UIUpdateInterval=0.1,
	ImpactDamage=10, DamageCooldown=1, RecoveryPenalty=20,
	SpawnOffset=Vector3.new(0,4,0), RecoveryPlayerOffset=Vector3.new(0,3,0),
	ImpactSpeed=55, ContactMargin=0.8, PhysicsSampleInterval=1/30,
	PackageSize=Vector3.new(2.5,2,2), CarryOffset=CFrame.new(0,0,-2.5), DropOffset=CFrame.new(0,0,-4),
	BoundsMin=Vector3.new(-445,-14,-55), BoundsMax=Vector3.new(145,96,310),
	DestinationId="Rumah01", DestinationName="Rumah Bu Sari", PackageType="Biasa", PromptHoldDuration=0.15,
	Hazards=table.freeze({
		SampleInterval=0.05, SlipSamples=2, SlipMinimumSpeed=5,
		SlipSpeed=18, SlipDuration=0.65, SlipCooldown=3,
		BarrierAmplitude=9, BarrierPeriod=4, BarrierMinimumSpeed=4,
		BarrierCooldown=2, KnockbackSpeed=18, KnockbackDuration=0.25, MaxForce=40000,
	}),
	Audio=table.freeze({
		Pickup=table.freeze({Id="rbxasset://sounds/action_get_up.mp3",Volume=0.35,Speed=1.2}),
		Impact=table.freeze({Id="rbxasset://sounds/action_jump_land.mp3",Volume=0.55,Speed=0.85}),
		Delivered=table.freeze({Id="rbxasset://sounds/volume_slider.ogg",Volume=0.45,Speed=1.4}),
	}),
	CosmeticOrder=table.freeze({"TasStandar","TasMerah","TasBiru","TasHijau"}),
	Cosmetics=table.freeze({
		TasStandar=table.freeze({Name="Pos klasik",Price=0,Color=Color3.fromRGB(200,151,79)}),
		TasMerah=table.freeze({Name="Ransel kilat",Price=50,Color=Color3.fromRGB(238,89,88)}),
		TasBiru=table.freeze({Name="Roll-top biru",Price=75,Color=Color3.fromRGB(75,163,242)}),
		TasHijau=table.freeze({Name="Penjelajah hijau",Price=100,Color=Color3.fromRGB(71,194,132)}),
	}),
	Labels=table.freeze({Start="Ambil pesanan",Pickup="Ambil ulang",Drop="Lepas",Recover="Pulihkan",Deliver="Antar"}),
})
