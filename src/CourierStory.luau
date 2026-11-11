local Story = {}

local chapters = {
	{rank = "Kurir Pemula", title = "Surat dari Depot", note = "Pak Arman mempercayakan kiriman pertamamu. Bu Sari sedang mengumpulkan foto lama kampung."},
	{rank = "Kurir Kampung", title = "Album yang Belum Lengkap", note = "Foto warga terkumpul. Maya di Menara Kilat membantu menyiapkan arsip untuk dipamerkan."},
	{rank = "Kurir Kota", title = "Di Seberang Kanal", note = "Raka menyiapkan denah pameran di Bata Quay. Antar kiriman ke sana lewat Jembatan Kanal."},
	{rank = "Kurir Lintas Distrik", title = "Menjelang Pameran", note = "Nisa menyusun foto dan cerita warga di galeri. Kiriman dari kedua sisi kanal mulai berdatangan."},
	{rank = "Kurir Andalan", title = "Pintu Galeri Terbuka", note = "Pameran sudah dibuka. Warga bisa melihat foto kampung dan bertemu tetangga dari seberang kanal."},
}

local people = {
	Rumah01 = {name = "Bu Sari", line = "Foto kampungku sudah siap. Ada yang dari sebelum jembatan dibangun."},
	Rumah02 = {name = "Pak Budi", line = "Foto warung lamaku boleh dipajang. Dulu kurir sering mampir berteduh di sini."},
	Rumah03 = {name = "Bu Rina", line = "Aku sudah tulis nama orang-orang di foto. Biar anak-anak bisa mengenali mereka."},
	Rumah04 = {name = "Pak Agus", line = "Aku punya foto waktu kanal mulai dibangun. Titip buat pameran, ya."},
	Rumah05 = {name = "Bu Dewi", line = "Peta kampung sudah kutandai. Nisa bisa memakainya untuk menjelaskan letak tiap foto."},
	CBD01 = {name = "Maya", line = "Terima kasih sudah datang. Aku sedang mencocokkan tanggal dan alamat di foto warga."},
	BQ10 = {name = "Raka", line = "Denah pameran sudah hampir selesai. Sisakan ruang untuk foto dari kampung lama, ya."},
	BQ16 = {name = "Nisa", line = "Selamat datang di galeri. Kami punya satu dinding untuk cerita dari tiap sisi kanal."},
}

function Story.Chapter(rank)
	for index, chapter in ipairs(chapters) do
		if chapter.rank == rank then return chapter, index end
	end
	return chapters[1], 1
end

function Story.Contact(destination)
	return people[destination]
end

return Story
