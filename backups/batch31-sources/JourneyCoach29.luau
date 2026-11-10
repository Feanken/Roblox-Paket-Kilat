-- Presentation only. Existing server snapshots own orders, damage and rewards.
local M={}
function M.HazardDistance(foot,velocity,cf,size,range)
 local p=cf:PointToObjectSpace(foot)
 -- Keep bridge users separate from street hazards underneath them.
 if math.abs(p.Y)>size.Y/2+2 then return nil end
 local dx,dz=math.max(0,math.abs(p.X)-size.X/2),math.max(0,math.abs(p.Z)-size.Z/2)
 local distance=Vector2.new(dx,dz).Magnitude
 if distance>range then return nil end
 local toward=Vector3.new(cf.Position.X-foot.X,0,cf.Position.Z-foot.Z)
 local speed=Vector3.new(velocity.X,0,velocity.Z)
 if distance>.01 and speed.Magnitude>2 and speed:Dot(toward)<=0 then return nil end
 if distance>range/2 and speed.Magnitude<=2 then return nil end
 return distance
end
function M.Get(s,c)
 if not s.profileReady or not c.alive then return nil end
 local function hint(kind,text,alert,announce)
  return {kind=kind,text=text,alert=alert==true,announce=announce==true}
 end
 if s.status=='Dropped'then
  if s.outOfBounds then return hint('recover','Paket keluar jalur. Pulihkan ke depot (-20 kondisi).',true,true)end
  return hint('dropped',c.canPickup and 'Pilih Ambil ulang. Pulihkan mengurangi kondisi paket.'or 'Ikuti PAKETMU untuk mengambil ulang. Pulihkan mengurangi kondisi.',true,true)
 end
 if s.status~='Carrying'then return nil end
 local m=s.movement or {}
 if m.resting then return hint('rest','Stamina dan genggaman pulih lebih cepat. Lompat untuk berdiri.')end
 if c.hazard=='puddle'then return hint('puddle','Ada genangan di depan. Lewati sisi kering agar paket tidak terlepas.',true,true)end
 if c.hazard=='barrier'then return hint('barrier','Penghalang bergerak di depan. Tunggu celah sebelum lewat.',true,true)end
 if m.grip and m.grip<=25 then return hint('grip','Genggaman menipis. Hentikan sprint; bangku membantu pemulihan.',true)end
 local status=c.contractStatus
 if status and status.irreversible then return hint('lost:'..status.code,'Bonus kontrak gugur. Pengantaran tetap dibayar; lanjutkan ke rumah.',true,true)end
 local contract=s.contract local b=s.routeBonus or {}
 if contract and contract.kind=='explore'and(b.count or 0)<contract.stamps then
  local text
  if c.nearDestination then text='Cap belum lengkap. Cari POS CAP, atau antar tanpa bonus kontrak.'
  elseif c.guidedStamp then text=string.format('Cap %d/%d. Ikuti POS CAP; cap diambil otomatis saat dilewati.',b.count or 0,contract.stamps)
  elseif c.routeEnabled==false then text='Aktifkan Rute untuk panduan cap, atau cari POS BONUS di jalan.'
  else text='Cari POS BONUS di jalan. Cap diambil otomatis saat dilewati.'end
  return hint('stamp:'..(b.count or 0),text,false,true)
 end
 if c.nearDestination then return hint('deliver','Sudah di rumah tujuan. Pilih Antar paket untuk menyelesaikan pesanan.')end
 if contract and contract.kind=='explore'then return hint('stampsReady','Cap lengkap! Lanjut ke rumah tujuan, lalu pilih Antar paket.',false,true)end
 if s.packageType=='Rapuh'then return hint('fragile','Paket rapuh: batasi sprint dan jaga genggaman. Ikuti TUJUAN.')end
 return hint('destination','Ikuti TUJUAN. Hindari benturan, lalu Antar paket di rumah yang benar.')
end
return M
