-- Shared, pure status calculation. Only server EconomyService grants rewards.
local M={}
local function finite(n)return type(n)=='number'and n==n and math.abs(n)<math.huge end
function M.Get(c,s)
 if not c then return nil end
 local function result(code,eligible,lost,reason,short)
  return {code=code,eligible=eligible,irreversible=lost,reason=reason,short=short}
 end
 if (c.kind~='priority'and c.kind~='perfect'and c.kind~='explore')or not finite(c.condition)or not finite(c.reward)
  or c.reward<0 or(c.kind=='priority'and not finite(c.seconds))or(c.kind=='explore'and not finite(c.stamps))then
  return result('invalid',false,true,'Kontrak tidak tersedia','Kontrak tidak tersedia')
 end
 if not finite(s.condition)or not finite(s.duration)or not finite(s.recoveryCount)or not finite(s.stamps)then
  return result('invalid',false,true,'Status belum tersedia','Status belum tersedia')
 end
 if s.recoveryCount~=0 then return result('recovered',false,true,'Paket sudah dipulihkan','Gugur: paket dipulihkan')end
 if s.condition<c.condition then return result('condition',false,true,'Kondisi di bawah '..c.condition,'Gugur: kondisi <'..c.condition)end
 if c.kind=='priority'and s.duration>c.seconds then return result('late',false,true,'Waktu target terlewat','Gugur: lewat waktu')end
 if c.kind=='explore'and s.stamps<c.stamps then
  return result('stamps',false,false,'Cap belum cukup',string.format('Cap %d/%d · bonus +%d',s.stamps,c.stamps,c.reward))
 end
 local short=c.kind=='priority'and string.format('%s %ds · +%d',c.express and 'Ekspres' or 'Prioritas',math.max(0,math.ceil(c.seconds-s.duration)),c.reward)
  or c.kind=='perfect'and string.format('Mulus %d · +%d',c.condition,c.reward)or 'Cap lengkap · antar paket'
 return result('ready',true,false,'Syarat terpenuhi',short)
end
return M
