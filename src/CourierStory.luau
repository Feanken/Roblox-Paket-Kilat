local Story = {}

local chapters = {
	{
		title = "Surat dari Depot", destinationId = "Rumah01", packageType = "Biasa", cargo = "Album kampung", bonus = 20,
		brief = "Bu Sari menyimpan foto sebelum jembatan dibangun. Antar album kosong untuk foto-fotonya.",
		greeting = "Album yang kutunggu! Foto sebelum jembatan dibangun sudah kusiapkan.",
		receipt = "Album sudah kuterima. Tolong lanjutkan pengarsipan bersama Maya.",
	},
	{
		title = "Album yang Belum Lengkap", destinationId = "CBD01", packageType = "Rapuh", cargo = "Cetakan foto", bonus = 25,
		brief = "Bawa cetakan foto warga ke Maya di Menara Kilat.",
		careCondition = 90, careBonus = 10,
		greeting = "Foto-foto itu akan kuberi tanggal dan nama jalan. Terima kasih sudah menjaganya.",
		receipt = "Cetakan sudah kuterima. Raka menunggu denah untuk menentukan tempat pajangan.",
	},
	{
		title = "Di Seberang Kanal", destinationId = "BQ10", packageType = "Biasa", cargo = "Denah pameran", bonus = 30,
		brief = "Ikuti jalan ke jembatan kanal, lalu serahkan denah pameran kepada Raka.",
		greeting = "Aku perlu denah itu untuk menyediakan ruang bagi cerita dari kedua sisi kanal.",
		receipt = "Denahnya sudah sampai. Kini Bu Dewi bisa membagikan undangan ke warga.",
	},
	{
		title = "Menjelang Pameran", destinationId = "Rumah05", packageType = "Biasa", cargo = "Undangan warga", bonus = 25,
		brief = "Titipkan undangan pembukaan kepada Bu Dewi.",
		greeting = "Warga menunggu undangannya. Banyak yang belum pernah datang ke galeri.",
		receipt = "Undangan akan kubagikan. Tinggal bingkai foto yang perlu sampai ke Nisa.",
	},
	{
		title = "Pintu Galeri Terbuka", destinationId = "BQ16", packageType = "Rapuh", cargo = "Bingkai pameran", bonus = 45,
		brief = "Serahkan bingkai kepada Nisa untuk membuka pameran.",
		careCondition = 95, careBonus = 15,
		greeting = "Bingkai itu kiriman terakhir. Setelah ini, pameran foto kampung bisa dibuka.",
		receipt = "Pameran sudah terbuka. Lihat tiga panel foto di depan galeri.",
	},
}
for _, chapter in ipairs(chapters) do table.freeze(chapter) end
Story.Count = #chapters

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

function Story.Chapter(index)
	return chapters[index]
end

function Story.Offer(completed)
	local index = completed + 1
	local chapter = chapters[index]
	if not chapter then return nil end
	return {
		id = "pameran:" .. index,
		name = chapter.title,
		DestinationId = chapter.destinationId,
		PackageType = chapter.packageType,
		JobBonus = 0,
		StoryChapter = index,
		description = chapter.brief,
	}
end

function Story.Contact(destination)
	return people[destination]
end

return Story
