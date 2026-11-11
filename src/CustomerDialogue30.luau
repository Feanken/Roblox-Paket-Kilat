-- Cosmetic dialogue only; delivery and payment remain server-owned.
local Status=require(script.Parent.ContractStatus25)
local Story = require(script.Parent.CourierStory)
local M={}
local greetings={
 CBD01='Selamat datang di Menara Kilat. Paket kantor bisa diantar di petak depan.',
 BQ10='Paket gambar untuk studio kami? Antar di sini, ya.',
 BQ16='Selamat datang di galeri! Aku menunggu kirimanmu.',
 Rumah01='Halo, kurir! Paketnya boleh diantar di sini.',
 Rumah02='Halo! Aku tunggu paketnya di depan warung.',
 Rumah03='Paket untukku? Aku sudah menunggu!',
 Rumah04='Lewat sini, kurir! Petaknya di depan rumah.',
 Rumah05='Terima kasih sudah mampir. Antar di sini, ya.',
}
local reactions={
 {'Sudah kuterima. Lain kali lebih hati-hati, ya.','Paketnya sampai. Tolong jaga lebih baik berikutnya.','Terima kasih. Semoga paket berikutnya lebih aman.'},
 {'Paketnya aman. Terima kasih!','Pas sekali, paketnya sudah kutunggu.','Terima kasih sudah menjaga paketku.'},
 {'Wah, rapi dan cepat! Terima kasih.','Cepat sekali! Paketnya juga tetap rapi.','Mantap, paket tiba tepat waktu dan utuh!'},
}
function M.Greeting(id,s)
 local chapter = s.storyChapter and Story.Chapter(s.storyChapter)
 if chapter and chapter.destinationId == id then return chapter.greeting end
 local c=s.contract local b=s.routeBonus or {}
 if c and c.kind=='explore'then
  local status=Status.Get(c,{condition=s.condition,duration=0,recoveryCount=s.recoveryCount or 0,stamps=b.count or 0})
  if status and status.code=='stamps'then return 'Kalau mengejar bonus cap, boleh keliling dulu. Aku menunggu.'end
 end
 local contact = Story.Contact(id)
 return contact and contact.line or greetings[id]or 'Halo, kurir! Antar paket di petak tujuan, ya.'
end
function M.Reaction(result,hasRelay,count)
 local chapter = result.storyChapter and Story.Chapter(result.storyChapter)
 if chapter then return chapter.receipt end
 local stars=result.rating and result.rating.stars or 1
 stars=math.clamp(math.floor(stars),1,3)
 local pool=reactions[stars]local line=pool[((count or 1)-1)%#pool+1]
 if result.isBatch then line=result.batchIndex<result.batchTotal and 'Paketku sudah kuterima. Semangat untuk kiriman berikutnya!'or 'Semua kiriman borongan selesai. Terima kasih, kurir!'end
 if result.contractSucceeded then line='Targetmu tercapai! Paketnya sudah kuterima.'end
 if result.isExpress and result.contractSucceeded then line='Paket ekspres tiba tepat waktu. Terima kasih sudah menjaganya!'end
 if hasRelay then line..=' Ada titipan lagi.'end
 return line
end
return M
