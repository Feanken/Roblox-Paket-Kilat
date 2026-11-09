-- Server-generated offers; the client submits only an opaque current offer id.
local M={}
function M.Build(config,index,revision,tuning)
 local scheduled=config.OrderSchedule[index]
 local fragileId=string.format('Rumah%02d',index%5+1)
 local farId=index%2==1 and 'Rumah04'or 'Rumah05'
 return {
  {id=revision..':regular',name='Reguler',DestinationId=scheduled.DestinationId,PackageType='Biasa',JobBonus=0,description='Pilihan rute berikutnya.'},
  {id=revision..':fragile',name='Rapuh',DestinationId=fragileId,PackageType='Rapuh',JobBonus=math.floor(tuning.JobFragileBonus),description='Lebih rentan benturan.'},
  {id=revision..':long',name='Lintas Kota',DestinationId=farId,PackageType='Biasa',JobBonus=math.floor(tuning.JobLongBonus),description='Perjalanan lebih panjang.'},
 }
end
return M