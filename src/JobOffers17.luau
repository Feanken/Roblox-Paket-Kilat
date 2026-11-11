-- Server-generated offers; the client submits only an opaque current offer id.
local M={}
function M.Build(config,index,revision,tuning,expressUnlocked)
 local scheduled=config.OrderSchedule[index]
 local offers={
  {id=revision..':regular',name='Reguler',DestinationId=scheduled.DestinationId,PackageType='Biasa',JobBonus=0,description='Pilihan rute berikutnya.'},
  {id=revision..':fragile',name='Rapuh · Pusat Kota',DestinationId='CBD01',PackageType='Rapuh',JobBonus=math.floor(tuning.JobFragileBonus),description='Antar paket rapuh ke lobi Menara Kilat.'},
  {id=revision..':long',name='Lintas Kanal',DestinationId='BQ10',PackageType='Biasa',JobBonus=math.floor(tuning.JobLongBonus),description='Seberangi kanal, lalu cari Kantor Arsitek.'},
 }
 for _,v in require(script.Parent.Contracts24).Build(config,index,revision,tuning,expressUnlocked)do table.insert(offers,v)end
 return offers
end
return M