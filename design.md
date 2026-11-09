# Paket Kilat! — Desain dan Spesifikasi

Status: Spesifikasi v0.6 — T21 dan persiapan T22–T23; uji manusia menunggu bukti  
Tanggal: 7 November 2026  
Platform: Roblox; komputer dan perangkat sentuh  
Place lokal: `main_game.rbxl`

## 1. Cara menggunakan dokumen

Dokumen ini menerapkan SDD (Specification-Driven Development): kebutuhan → desain → tugas → verifikasi. Setiap kebutuhan memiliki ID agar implementasi dan hasil uji dapat dilacak melalui `task_list.md`.

Belum ditemukan template SDK kit atau aturan SDD khusus di folder proyek. Struktur ini adalah acuan sementara, bukan klaim kesesuaian dengan kit tertentu. Perubahan perilaku harus diperbarui di spesifikasi sebelum tugas terkait dikerjakan. Nilai keseimbangan di bawah adalah hipotesis untuk diuji.

## 2. Tujuan produk

Pemain menjadi kurir di kampung Indonesia bergaya kartun. Pemain mengambil paket, memilih rute, melewati rintangan, dan mengantarkan paket untuk memperoleh koin serta membuka kosmetik.

Janji permainan: mengantarkan paket mudah dipahami, tetapi menjaga kondisinya memberi tantangan. Kelucuan muncul dari gerakan, jatuh, dan usaha menyelamatkan paket.

Tujuan awal adalah membuktikan bahwa pemain memahami pengantaran dan ingin mengulanginya. Tujuan bisnis jangka lanjut adalah pendapatan sampingan melalui produk kosmetik. Tidak ada proyeksi pendapatan atau jaminan jumlah pemain dalam rancangan ini.

## 3. Pemain dan prinsip desain

- Ditujukan untuk pemain kasual yang menyukai tantangan gerak dan sesi pendek.
- Bisa dimainkan sendirian; kehadiran teman menambah suasana.
- Aksi pertama harus mudah ditemukan tanpa penjelasan panjang.
- Kegagalan ringan, bisa dipulihkan, dan tidak menghapus seluruh usaha.
- Kontrol inti nyaman di HP dan komputer.
- Kemampuan dasar dan rekor tidak bergantung pada pembelian peningkatan kecepatan.

## 4. Batas lingkup

### Prototipe inti

Satu depot, satu rumah, satu paket biasa, satu rintangan, satu siklus hadiah, dan UI minimum. Penyimpanan permanen dan pembelian belum diperlukan untuk membuktikan mekanik.

### MVP yang dapat dirilis untuk pengujian publik

- Satu kampung kecil dengan lima rumah tujuan.
- Rute aman dan jalan pintas untuk sedikitnya dua tujuan.
- Paket biasa dan rapuh.
- Papan sempit, genangan licin, dan penghalang bergerak.
- Koin, rekor pribadi per tujuan dan jenis paket, kosmetik, serta penyimpanan progres.
- Map bersama dengan pesanan terpisah; kapasitas awal usulan delapan pemain, diverifikasi lewat pengujian.
- UI komputer dan sentuh, petunjuk awal, serta pencatatan kejadian dasar.

### Pengembangan setelah validasi

Paket besar, pesanan ekspres, tantangan bergilir, pengantaran berdua, produk berbayar, dan tambahan wilayah.

### Di luar lingkup awal

Kendaraan, pets, trading, PvP, pencurian paket, dunia luas, beberapa mata uang, NPC berbasis LLM, dan ketergantungan API OpenAI.

## 5. Kebutuhan dan kriteria penerimaan

| ID | Kebutuhan | Kriteria penerimaan |
| --- | --- | --- |
| REQ-01 | Memulai pengantaran | Pemain mengambil satu pesanan di depot; pesanan kedua ditolak selama pesanan pertama aktif. |
| REQ-02 | Membawa dan melepas paket | Paket terlihat saat dibawa; aksi melepas tersedia di komputer dan sentuh; paket bisa diambil kembali oleh pemiliknya. |
| REQ-03 | Tujuan dan penyerahan | Nama serta penanda tujuan terlihat. Server hanya menerima paket milik pemain pada tujuan yang ditugaskan dan jarak yang sah. |
| REQ-04 | Jatuh dan pemulihan | Benturan yang memenuhi aturan melepas paket. Paket di luar batas dikembalikan ke titik aman melalui aksi pemulihan; pemulihan mengurangi bonus kondisi dan tidak memberi uang tambahan. |
| REQ-05 | Kondisi paket | Kondisi berada pada rentang 0–100. Benturan sah mengurangi kondisi dengan jeda antarkerusakan; paket rapuh menerima kerusakan lebih besar. Kondisi 0 tetap bisa diantar dengan bayaran dasar. |
| REQ-06 | Hadiah | Pengantaran sah memberi bayaran dasar dan bonus maksimal satu kali. Mengulang permintaan penyerahan tidak memberi hadiah kedua. |
| REQ-07 | Progres | Koin, kosmetik yang dimiliki/dipakai, jumlah pengantaran, dan rekor tersimpan. Kegagalan memuat data tidak boleh menimpa data lama dengan nilai awal. |
| REQ-08 | Rute dan rintangan | Lima tujuan dapat dicapai; sedikitnya dua memiliki pilihan rute. Tiga jenis rintangan dapat dilalui dan kegagalannya dapat dipulihkan. |
| REQ-09 | Kosmetik | Kosmetik koin bisa dibeli dan dipakai. Server menolak pembelian tanpa saldo atau pemakaian barang yang tidak dimiliki. Kosmetik tidak mengubah kecepatan. |
| REQ-10 | Multipemain | Pemain tidak bisa mengambil paket pemain lain. Tabrakan tubuh antarpemain tidak menjatuhkan pemain atau paket yang sedang dibawa. Keluar/reset membersihkan pesanan tanpa hadiah. |
| REQ-11 | Kontrol dan UI | Ambil, lepas, pulihkan, dan antar dapat dilakukan pada komputer dan layar sentuh; tujuan, kondisi, serta saldo terbaca dan tidak tertutup tombol. |
| REQ-12 | Validasi server | Server memeriksa kepemilikan, status pesanan, tujuan, jarak, saldo, dan frekuensi permintaan. Klien tidak menentukan hadiah atau kondisi resmi. |
| REQ-13 | Observasi dan uji | Kejadian mulai, paket pertama diambil, paket dipulihkan, pengantaran selesai, dan sesi berakhir dapat ditinjau tanpa merekam isi chat atau API key. |

## 6. Alur dan aturan permainan

Alur: muncul di depot → ambil pesanan → lihat tujuan → bawa paket → antar → lihat hasil → kembali ke depot.

Status pesanan: `Idle → Carrying ↔ Dropped → Delivered → Idle`. Keluar atau reset membatalkan pesanan dan membersihkan paket. Pemain dapat mengambil pesanan baru setelah muncul kembali. Pesanan aktif tidak disimpan antarserver pada MVP.

Pemulihan dari `Dropped` memindahkan paket ke titik aman dekat depot dan mempertahankan tujuan serta waktu mulai. Titik tersebut harus bebas dari rintangan. Aksi pemulihan memiliki cooldown usulan lima detik untuk mencegah spam.

Pada map percobaan yang ditinggikan, pemulihan juga memindahkan pemain hidup yang sudah berada di bawah lantai arena atau di luar batas arena ke spawn aman depot. Ini mencegah pemain terjebak di Baseplate bawah; pemain tetap mengambil ulang paket di titik pemulihan. Pemain yang masih berada di jalur arena tidak dipindahkan.

Parameter awal yang dapat diubah dari konfigurasi:

| Parameter | Nilai usulan |
| --- | --- |
| Durasi satu pengantaran | 60–120 detik, sasaran desain |
| Kondisi awal | 100 |
| Kerusakan benturan biasa / rapuh | 10 / 20 |
| Jeda kerusakan | 1 detik |
| Penalti pemulihan | 20 kondisi |
| Bayaran dasar | 25 koin |
| Bonus kondisi maksimum | 15 koin |
| Bonus waktu maksimum | 10 koin |

Hadiah = 25 + floor(15 × kondisi / 100) + floor(10 × clamp(1 − durasi / waktuTargetRute, 0, 1)). Waktu target ditentukan per rute. Tidak ada penalti saldo negatif atau kegagalan karena terlalu lama. Penggunaan pemulihan membuat perjalanan tidak memenuhi syarat rekor waktu, tetapi tetap memperoleh hadiah sesuai formula.

Ambang benturan ditentukan melalui percobaan prototipe. Rintangan memberi sinyal benturan yang divalidasi server; laporan klien atau event `Touched` tunggal tidak boleh langsung menjadi bukti kerusakan atau hadiah. Rancangan ini mengurangi penyalahgunaan, bukan menjamin bebas eksploitasi fisika.

## 7. Map, visual, dan suara

Map menggunakan bentuk sederhana, warna cerah, jalur mudah dibaca, serta landmark berbeda untuk setiap rumah. Depot, warung, gang, selokan, dan pembangunan memberi identitas lokal. Penanda tujuan tidak hanya mengandalkan warna; gunakan nama atau ikon.

Rute aman lebih lebar dan panjang. Jalan pintas lebih singkat tetapi membutuhkan ketelitian. Hindari jalur yang membuat pemain terjebak permanen. Paket dibawa dengan attachment yang stabil dan tidak mengganggu tubuh pemain; setelah dilepas menjadi objek fisik yang dapat diambil kembali.

Umpan balik minimum: suara ambil, benturan, dan pengantaran; indikator perubahan kondisi; ringkasan hadiah. Gunakan aset yang hak penggunaannya jelas dan catat sumbernya saat implementasi.

## 8. Desain teknis Roblox

Struktur berikut adalah acuan implementasi bertahap. Inspeksi 6 November 2026: place lokal `main_game.rbxl`, PlaceId/GameId 0, Baseplate dan SpawnLocation bawaan, tanpa script game. Objek awal dipertahankan.

| Lokasi | Isi yang direncanakan |
| --- | --- |
| `Workspace/PaketKilat` | Map, depot, tujuan, rintangan, titik aman, dan paket aktif |
| `ReplicatedStorage/PaketKilat/Shared` | Konfigurasi jenis paket, hadiah, tujuan, dan katalog kosmetik |
| `ReplicatedStorage/PaketKilat/Remotes` | Permintaan aksi dan pembaruan state yang disetujui server |
| `ServerScriptService/PaketKilat` | Bootstrap, DeliveryService, PackageService, EconomyService, DataService, CosmeticService, dan TelemetryService |
| `ServerStorage/PaketKilat` | Template paket dan aset yang hanya diperlukan server |
| `StarterPlayer/StarterPlayerScripts` | Pengendali input, penanda tujuan, dan presentasi klien |
| `StarterGui/PaketKilatUI` | HUD, petunjuk, hasil pengantaran, dan toko kosmetik |

Server mengelola ID pesanan unik, pemilik, jenis paket, tujuan, status, kondisi, waktu mulai, dan penanda hadiah sudah diproses. Transisi pengantaran dikunci sebelum saldo ditambah untuk mencegah hadiah ganda.

Paket yang dilepas diprioritaskan memiliki otoritas fisika server selama biaya performanya masih sesuai hasil uji. Collision group memisahkan pemain, paket yang dibawa, dan paket lepas. Semua koneksi/event serta instance milik pesanan dibersihkan saat selesai atau dibatalkan.

## 9. Data dan kegagalan layanan

Profil versi 1: `schemaVersion`, `coins`, `ownedCosmetics`, `equippedCosmetic`, `deliveryCount`, dan `bestTimes` dengan kunci tujuan + jenis paket.

Gunakan DataStore dari server, validasi skema, penyimpanan terjadwal yang dibatasi, retry dengan backoff, dan perlindungan sesi agar dua server tidak menimpa profil yang sama. Pembaruan memakai pola atomik yang sesuai. Detail izin akses ditinjau sebelum menghubungkan DataStore.

Jika profil gagal dimuat, tampilkan pesan dan cegah sesi ekonomi memakai profil kosong. Jika simpan gagal, tandai data masih perlu disimpan dan coba ulang; kegagalan tetap dicatat. Penyimpanan saat keluar dan penutupan server bersifat upaya terbaik, sehingga risiko kehilangan progres terakhir harus diuji dan diperkecil.

Uji penyimpanan menggunakan lingkungan/key terpisah dari data pemain publik. Tidak ada secret di LocalScript, shared module, atau repositori.

## 10. Monetisasi dan validasi produk

### Spesifikasi T16–T20 (7 November 2026, sebelum implementasi)

- Profil v1 berisi schemaVersion, coins (integer 0..1 miliar), deliveryCount, ownedCosmetics (set ID katalog), equippedCosmetic milik sendiri, dan bestTimes (tujuan|tipe, detik positif). Default baru: koin/count 0, TasStandar dimiliki/dipakai, rekor kosong. Migrasi v0 mempertahankan saldo sah dan memberi field baru; data rusak/versi masa depan ditolak, tidak diganti default.
- Penyimpanan hanya namespace `PaketKilat_TEST_v1`, scope `T16_T20_QA`, key `qa:<UserId>`; dilarang menyentuh namespace publik. Konfigurasi server mengunci universe uji 10775037187. Mode StudioMemory eksplisit hanya untuk Studio lokal; kegagalan DataStoreTest tidak pernah beralih ke profil kosong atau memori.
- Envelope v1 menyimpan profile, revision, updatedAt, lastCommitId dan lock token/owner/expiresAt. UpdateAsync mengakuisisi lease 120 detik; simpan/renew 30 detik, retry maksimum 3 dengan backoff. Transform tidak yield dan memeriksa token serta masa lease. Token commit membuat retry setelah respons hilang idempoten. Sesi lain yang belum kedaluwarsa ditolak; sesi kehilangan lease dibekukan. Data dimuat hanya setelah respons sukses dan valid.
- Ekonomi nonaktif selama Loading/Failed/Lost/Closing atau lease mendekati habis. Gagal muat tidak mempunyai data yang boleh disimpan. Simpan gagal mempertahankan dirty dan mencoba lagi; perubahan saat save berlangsung tetap dirty. Keluar membatalkan pesanan, melepas lease dan membersihkan koneksi; BindToClose memberi batas global 25 detik. Ini upaya terbaik, bukan jaminan tanpa kehilangan pada crash.
- Katalog kosmetik: TasStandar gratis, TasMerah 50, TasBiru 75, TasHijau 100 koin. Tas primitive dipasang server, tanpa perubahan kecepatan/keuntungan. Beli/pakai hanya dekat ShopPoint depot (12 stud), hidup dan profil Ready. Duplikat ditolak tanpa potongan; item tak dimiliki tidak bisa dipakai. Saldo, kepemilikan/pilihan dan rekor disimpan; urutan pesanan serta ledger replay bersifat sesi.
- Kontrak ActionRequest tetap tiga argumen. Tambahan BuyCosmetic/EquipCosmetic memakai argumen kedua ID kosmetik dan argumen ketiga nil; harga tidak diterima dari klien. Pemeriksaan tipe/panjang, allowlist, identitas, jarak, ownership, saldo dan throttle tetap server. Sync boleh membaca status profil belum siap; request lain tidak boleh mengubah data.
- HUD menambah tombol Toko (B), katalog dan status penyimpanan. Profil belum siap menampilkan saldo — dan aksi ekonomi nonaktif. Mode memori diberi label progres hilang saat Stop; hanya acknowledgment backend DataStore boleh diberi status tersimpan.
- Pengujian membedakan adapter memori/injeksi kegagalan, DataStore riil lintas sesi, klien Studio nyata dan HP asli. Minimum 2 klien, upayakan 8 lewat StudioTestService. Jumlah yang benar-benar hadir dicatat. Tidak ada publikasi, aset berbayar, Robux, atau T21.
- Paket bawaan antarpemain dan antara paket bawaan/paket lepas tidak saling bertabrakan, agar pemain lain tidak menjatuhkan pesanan hanya dengan berdempetan. Kontak paket lepas dengan map tetap aktif.

Prototipe memakai koin permainan tanpa pembelian Robux. Setelah gameplay tervalidasi, kandidat produk adalah tas, efek langkah, atau animasi pengantaran. Konten berbayar belum termasuk kriteria selesai MVP.

Sesi uji awal menargetkan 10–20 orang sebagai sampel kualitatif, bukan bukti pasar. Catat apakah pemain menemukan depot, berhasil mengantar, memulai pesanan kedua, serta alasan berhenti. Sasaran awal usulan: 8 dari 10 tester pertama menyelesaikan pengantaran tanpa panduan lisan. Jika gagal, perbaiki onboarding sebelum menambah konten.

Waktu bermain, jumlah pengantaran, dan pemain kembali ditinjau setelah tersedia data. Pendapatan belum menjadi ukuran kelulusan prototipe.

## 11. Verifikasi dan definisi selesai

Prototipe selesai jika pengantaran dapat diulang tiga kali, hadiah tidak ganda, reset tidak meninggalkan paket, dan kontrol inti berjalan di komputer serta emulator sentuh.

MVP selesai jika REQ-01 sampai REQ-13 memiliki bukti pemeriksaan, penyimpanan lintas sesi berhasil, skenario gagal muat tidak menimpa profil, dan sedikitnya dua klien dapat menyelesaikan pesanan bersamaan tanpa tertukar. Uji kapasitas delapan pemain dicatat terpisah; jangan menyatakan lulus bila hanya dua klien yang diuji.

Sasaran performa awal adalah setidaknya 30 FPS pada perangkat HP uji yang disebutkan dalam laporan. Emulator tidak membuktikan performa HP asli. Bug yang menggandakan uang, menghilangkan progres, atau menghalangi penyelesaian pesanan harus diperbaiki sebelum rilis.

## 12. Pembagian peran dan keputusan terbuka

Asisten: inspeksi place, implementasi melalui MCP, pengujian teknis, dokumentasi, dan perbaikan. Pemilik: arahan visual, penilaian rasa permainan, tes HP asli, perekrutan tester, dan keputusan publikasi atau pengeluaran.

Keputusan terbuka: template SDK kit yang dimaksud; nama final game; perangkat HP acuan; pilihan bahasa UI final; sumber aset; serta angka ekonomi setelah playtest. Gunakan nama kerja Paket Kilat!, gaya kartun, dan teks UI singkat yang dipusatkan agar mudah dilokalkan. Keputusan ini tidak menghalangi prototipe inti.

## 13. Spesifikasi tahap T21–T23 (7 November 2026, sebelum implementasi)

- Petunjuk ringkas mengikuti state resmi: dekati depot/ambil → ikuti tujuan/antar → kembali/ambil pesanan kedua. Saat Dropped, petunjuk menawarkan ambil ulang atau pulih dengan penalti. Panel bawah tengah tidak menutup joystick/lompat; dapat disembunyikan/dibuka lagi lewat Petunjuk dan otomatis selesai setelah pesanan kedua dimulai sesudah pengantaran pertama. Reset tidak mereset pencapaian sesi. Tidak menambah field profil persisten atau RemoteEvent.
- Pengukur FPS bersifat pilihan untuk operator tes: tombol FPS hanya muncul ketika Petunjuk dibuka secara manual, bukan pada panduan otomatis awal. Menutup panel menyembunyikan pengukur; sampel tetap lokal. Ini menjaga fokus pemain baru pada permainan.
- TelemetryService server terpusat mencatat SessionStarted, FirstPackagePicked, PackageRecovered, DeliveryCompleted, SessionEnded; SecondOrderStarted menambahkan ukuran pengulangan yang diperlukan T23. Hook hanya sesudah transisi gameplay sah; penyerahan/recovery replay tidak menghasilkan event sukses. Logging tidak yield pada jalur kredit, tidak mengubah saldo, dibatasi antrean/jurnal dan gagal tanpa menghentikan gameplay.
- Jurnal lokal server memakai GUID sesi acak, nomor urut, elapsed dan field allowlist. Tidak merekam chat, nama/UserId, orderId, alamat, token, secret, teks bebas atau alasan berhenti bebas. Player hanya parameter yang diwajibkan AnalyticsService; identitas standar Roblox tidak diduplikasi ke customFields. Jurnal memori maksimal256 baris, bukan penyimpanan permanen atau bukti dashboard.
- Pemetaan cloud: funnel sesi `PaketKilatTrial_v1` langkah1 mulai,2 ambil pertama,3 antar pertama,4 pesanan kedua; Economy Coins/Source/Gameplay pada setiap pengantaran sah, dengan nilai hadiah dan saldo sesudah kredit; custom `PKPackageRecovered` dan `PKSessionOutcome` (tahap berhenti, Left/ServerClosing). Funnel+Economy pada antar pertama dibenarkan karena mengukur konversi awal dan aliran koin yang berbeda. Tidak menggandakan durasi sesi/FPS yang telah disediakan platform.
- Maksimal3 customFields/event, nilai kategori tetap;1 currency,1 funnel,2 custom event names. Studio memakai LocalOnly secara eksplisit. Sink Roblox hanya server live universe uji10775037187; tidak ada publikasi, HTTP eksternal, atau Open Cloud analytics write. Status queued/call-returned bukan bukti diterima dashboard. Transport error/drop dicatat dan tidak di-retry otomatis untuk menghindari event ganda.
- Pemeriksaan T01–T20 memakai bukti JSON, kecocokan sumber aktual dan regresi runtime terkait; checklist saja tidak cukup. Uji baru membedakan simulator Studio, HP fisik dan manusia. T22 menunggu model HP/OS/build, sumber FPS, angka performa dan hasil kontrol/siklus nyata; target awal30 FPS, tanpa menyimpulkan dari emulator.
- T23 menunggu10–20 tester manusia baru, boleh beberapa gelombang≤8 serentak sesuai kapasitas teruji. Instruksi netral tidak mengungkap depot/tombol/rute sebelum observasi pertama; tandai bantuan/riwayat bermain. Sasaran8 dari10 pertama menyelesaikan pengantaran tanpa bantuan dalam jendela observasi10 menit; timeout/keluar/kegagalan teknis dilaporkan terpisah dan tidak dihapus diam-diam dari denominator. Catat pesanan kedua dan alasan berhenti dengan kode anonim T01–T20, tanpa username/kontak.
- Build yang diuji wajib cocok dengan versi baru. File rbxl lokal tidak dapat diasumsikan bisa dimainkan di HP. Bila build baru belum tersedia pada akses HP/tester yang sudah ada, catat sebagai hambatan; jangan menerbitkan atau memakai hasil versi lama sebagai kelulusan.

### Riwayat tahap pertama (T01–T06)

- Batas tahap ini: satu paket biasa per pemain, rumah `Rumah01`, tanpa penyerahan, uang, penyimpanan progres, toko, atau HUD T08. T04 menyediakan pemeriksaan tujuan/jarak dan kunci penyelesaian internal; belum ada aksi klien untuk menyelesaikan pesanan. T07 ke atas tetap belum dikerjakan.
- Kontrol percobaan minimum: prompt depot untuk pesanan/ambil; prompt paket untuk ambil ulang; tombol aksi kontekstual bawaan Roblox untuk Lepas (Q) dan Pulihkan (R). Tombol sentuh bawaan hanya sarana mencoba T05/T06; kelayakan UI sentuh penuh tetap T08. Status/kondisi terlihat pada label paket.
- Konfigurasi lokal tunggal `Shared/Config`: jarak aksi 12 stud, jeda permintaan 0,2 detik, pemulihan 5 detik, kerusakan 10, jeda kerusakan 1 detik, penalti pemulihan 20, ambang benturan 55 stud/detik. Percobaan awal ambang 24 merusak paket pada jatuh 2 stud (kecepatan teramati 28,6); ambang direvisi sebelum implementasi ulang agar pelepasan biasa aman. Paket rapuh belum diaktifkan (T13).
- Benturan dihitung server dari kecepatan sebelum kontak dan raycast lintasan/permukaan (bukan laporan klien atau satu Touched). Saat dibawa, benturan diuji dari laju turun karakter menuju lantai; saat lepas, dari laju paket sebelum kontak. Kecepatan minimum dan kontak dekat harus keduanya terpenuhi. Tubuh pemain dan paket lain dikecualikan. Benturan sah melepas paket dan mengurangi kondisi dengan cooldown.
- Paket dibawa melalui WeldConstraint, tanpa tabrakan, massless; paket lepas memiliki network owner server. Collision group karakter saling tidak bertabrakan; paket lepas tidak bertabrakan dengan karakter/paket lain. Bagian map tetap bertabrakan.
- Map uji ditinggikan dari Baseplate yang dipertahankan: dua pad dan jalan aman berbentuk U; papan sempit menjadi jalan pintas melintasi celah. Jatuh ke Baseplate tetap bisa pulih. Batas paket: kotak relatif terhadap `DepotPad.Position`, minimum (-24,-14,-55), maksimum (124,96,24); perubahan ketinggian arena tidak mengubah logika batas. Paket di luar batas ditandai `outOfBounds` dan ditahan agar tidak terhapus mesin. Pemulihan selalu tersedia dari Dropped, termasuk di luar batas, dan memindahkan paket ke titik aman depot; tidak otomatis mengambilnya.
- State resmi: `orderId`, `ownerUserId`, `packageType`, `destinationId`, `status` (Carrying/Dropped; Idle bila tiada pesanan), `condition`, `startedAt`, `rewardProcessed`, `completionLocked`, `recoveryCount`, `lastRecoveryAt`, `outOfBounds`, serta referensi paket di server. Pulih mempertahankan ID, tujuan, dan waktu mulai; kondisi dijepit 0–100. Reset/keluar membersihkan pesanan sebagai penjagaan dasar; audit lengkap tetap T09.
- `ActionRequest(action, orderId?)`: hanya Start, Pickup, Drop, Recover, Sync. Server memeriksa tipe/panjang argumen, pemain hidup, cooldown, ID, status, kepemilikan, dan jarak yang sesuai (Recover tidak membutuhkan jarak paket agar paket hilang tetap dapat dipulihkan). Tidak menerima nilai kondisi, posisi paket, atau hadiah dari klien. `StateChanged(snapshot, resultCode)` hanya dikirim server ke pemilik. State tidak dibagikan lewat tabel yang bisa dimutasi pemanggil.
- Modul server terpisah `DeliveryService` (state/validasi), `PackageService` (fisika/visual), `Bootstrap` (wiring). Layanan ekonomi/data/kosmetik/telemetri belum dibuat agar tidak mendahului tugasnya.
- Depot memiliki lorong belakang selebar 4 stud untuk menyambung ke jalan aman tanpa memanjat dinding. Posisi arena tersimpan saat ini: pusat DepotPad (0,196,0); generator map mencerminkan posisi ini.

## 14. Kontrak prototipe T07–T10

Riwayat tahap kedua: ketentuan saldo hanya sesi di bawah digantikan oleh spesifikasi profil T16–T20 pada bagian10. Aturan penyerahan, fisika dan kontrak dasar tetap berlaku kecuali diperluas secara eksplisit.

Bagian ini mencatat kontrak tahap kedua; batas satu rumah/paket biasa adalah riwayat tahap tersebut. Pemilik menyatakan sudah mencoba dan mengizinkan T11–T15 pada 7 November 2026; tidak ada masalah penghalang yang dilaporkan. Perangkat dan rincian putaran pemilik tidak disebutkan.

- Satu tujuan tetap `Rumah01`. Waktu target rute sementara 90 detik dalam konfigurasi per tujuan. Bayaran server = 25 + floor(15 × kondisi/100) + floor(10 × clamp(1 − durasi/90,0,1)). Durasi memakai waktu mulai dan waktu selesai server; pemulihan tidak mengulang timer. Kondisi 0 tetap memperoleh dasar dan bonus waktu yang sah. Rekor pribadi belum diimplementasikan (T14).
- Inspeksi tahap kedua menemukan pusat DepotPad aktual (0,1045,0). Posisi ini dipertahankan; angka Y=196 pada catatan tahap pertama adalah riwayat. Generator map lokal disesuaikan menjadi Y=1045 dan tidak dijalankan ulang pada map yang sudah ada.
- `EconomyService` menyimpan koin sesi (awal 0), jumlah pengantaran, ringkasan hasil terakhir, dan ID pesanan yang sudah dibayar. Saldo bertahan saat reset/respawn, dihapus ketika pemain keluar; sesi/server baru mulai 0. Tidak ada DataStore atau transaksi Robux.
- Penyerahan mengharuskan pemain hidup, ID milik sendiri, Carrying, paket masih ada/tidak OOB, tujuan cocok, pemain dalam 12 stud dan paket dalam 15 stud dari titik tujuan. Server mengunci transisi menjadi Delivered sebelum kredit. Kredit dan penandaan hadiah diproses sinkron tanpa yield; paket/koneksi dibersihkan, lalu Idle. Replay ID lama atau penyerahan serentak tidak memberi uang kedua, termasuk setelah pesanan berikutnya dimulai.
- Kontrak request menjadi `ActionRequest(action, orderId?, destinationId?)`, dengan tambahan aksi `Deliver`. Ketiga argumen diperiksa tipe/panjangnya, identitas Player dari OnServerEvent. Hanya Deliver menerima destinationId; hadiah/kondisi/posisi tidak pernah diterima dari klien. Semua aksi termasuk payload salah terkena batas frekuensi server.
- Snapshot server menambah `coins`, `deliveryCount`, `lastResult`, `depotPosition`, `recoveryPosition`, dan `destinationPosition` untuk HUD/penanda meski map sedang tidak ter-stream. Hasil memuat orderId, tujuan, durasi, kondisi, jumlah pemulihan, komponen hadiah, total, serta waktu selesai. Snapshot disalin, bukan referensi tabel resmi.
- HUD `StarterGui/PaketKilatUI` menampilkan tujuan, kondisi/bar, saldo sesi, petunjuk, pesan penolakan yang terbaca, dan rincian hadiah terakhir. Penanda tujuan lokal menggunakan teks; tidak hanya warna. Orientasi sentuh prototipe adalah landscape (`LandscapeSensor`), menghormati area aman layar dan kontrol gerak Roblox.
- Seluruh aksi memakai tombol HUD yang bisa ditekan mouse/sentuh. E = aksi utama kontekstual (ambil pesanan/ambil ulang/antar), Q = lepas, R = pulihkan. Tombol primer dan sekunder ditempatkan di sisi kanan, terpisah dari HUD kiri, joystick dan tombol lompat bawah. Prompt lama dipertahankan tetapi dinonaktifkan agar E tidak mengirim dua aksi. Kontrol gerak bawaan Roblox dipertahankan.
- Server memvalidasi ulang seluruh aksi walaupun tombol klien tampak aktif. Tombol pemulihan menunjukkan cooldown; kondisi OOB tidak memerlukan kedekatan paket. Klien tidak melakukan polling remote; pembaruan kedekatan hanya lokal.
- Mati/reset/CharacterRemoving membatalkan pesanan tanpa hadiah dan membersihkan Part, weld serta koneksi pesanan. Saldo sesi tidak berubah. CharacterAdded dapat memulai pesanan baru di depot. PlayerRemoving juga memutus koneksi karakter/pemain dan menghapus cache sesi. Callback karakter lama tidak boleh membatalkan pesanan karakter baru.
- Verifikasi: tiga siklus nyata; formula dan replay; tujuan salah/jarak/ID/payload; jatuh dan pemulihan; reset saat membawa dan saat lepas; pesanan baru sesudah respawn; keluar; UI desktop serta satu siklus tanpa keyboard pada emulator sentuh. Emulator tidak membuktikan HP asli, jaringan nyata, atau dua pemain. HP asli dan playtest pemilik dicatat terpisah.

## 15. Kontrak perluasan T11–T15

Riwayat tahap ketiga: pernyataan belum ada DataStore/rekor hanya sesi mencatat batas saat T15 selesai. T16–T20 memperbaruinya menjadi profil persisten pada namespace uji; jadwal pesanan dan ringkasan hasil tetap sesi. Sinkronisasi ulang selama Loading memperluas ketentuan lama tanpa polling remote di bawah.

- Map lama dan posisi aktual depot dipertahankan. Ditambahkan Rumah Pak Budi (-100,0), Bu Rina (0,120), Pak Agus (100,120), dan Bu Dewi (-100,120), dalam koordinat X/Z relatif depot. Rumah Bu Sari (100,0) tetap. Setiap rumah mempunyai nama, warna, nomor, dan landmark berbeda. Jalan aman lebar serta papan pintas ke Bu Sari dipertahankan; Pak Budi mendapat jalan U aman dan jalan pintas licin. Jalan kampung utara menghubungkan tiga rumah lain, dengan jalan memutar yang bebas penghalang bergerak.
- Batas arena diperluas relatif DepotPad: minimum (-126,-14,-55), maksimum (136,96,154). Tidak mengisi celah bawah papan dengan tanah agar mekanik jatuh tetap dapat diuji.
- Paket biasa dan Rapuh memakai Part/template yang sama dengan label/warna/tanda berbeda. Kerusakan setiap benturan sah 10/20, kondisi awal 100 dan clamp 0–100; kecepatan dasar pemain tidak berubah. Pemulihan tetap penalti 20 dan jeda 5 detik untuk kedua tipe, mempertahankan tujuan, ID dan waktu mulai.
- Server membagikan pesanan secara berurutan melalui jadwal 10 kombinasi tujuan+tipe agar semua dapat dicoba; pesanan baru yang sah menggeser jadwal, reset tidak mengulang jadwal dalam sesi. Start tetap tanpa argumen pemilihan. Snapshot Idle memuat pratinjau pesanan berikutnya; klien tidak menentukan tipe/tujuan. Kontrak ActionRequest tiga argumen tetap kompatibel.
- Konfigurasi Routes menyimpan nama, landmark, dan TargetSeconds per rumah. Nilai awal 45/45/35/60/60 detik, ditinjau melalui uji jalan. Formula tetap 25 + floor(15×kondisi/100) + floor(10×clamp(1−durasi/TargetSeconds,0,1)); kedua tipe memakai formula yang sama. Belum ada produk berbayar, progres permanen atau T16.
- Genangan pada pintasan Pak Budi dikonfirmasi server melalui dua sampel kontak kaki dalam volume map dan kecepatan horizontal minimal 5 stud/detik. Kontak sah membuat paket lepas/rusak dan memberi selip horizontal 18 stud/detik selama 0,65 detik memakai constraint fisika, dengan jeda pemicu 3 detik. Tidak memakai laporan klien atau Touched tunggal.
- Penghalang oranye bergerak sinus di jalan utara, amplitudo 9 stud dan periode 4 detik. Server menguji volume sapuan antarposisi terhadap karakter pembawa/paket lepas, dengan ambang laju 4 stud/detik dan jeda 2 detik. Benturan sah memberi damage tipe paket, melepas, dan dorongan singkat 0,25 detik bagi pembawa. Part visual tidak bertabrakan secara native untuk menghindari fling; volume dan dorongan dikelola server. Jalan memutar tetap aman.
- Semua penyebab benturan berbagi jeda kerusakan 1 detik. Efek selip/dorong dan attachment dibersihkan ketika berakhir, reset, batal atau keluar. Pemulihan tetap tersedia setelah gagal di ketiga rintangan. Batas aman tidak menjadi bukti kerusakan dengan sendirinya.
- Deteksi benturan lantai memakai kecepatan assembly sebelumnya serta laju perpindahan antarsampel posisi yang diamati server, dikonfirmasi raycast lintasan/kontak. Ini menutup kasus laju assembly sudah nol ketika posisi pendaratan diterima; perpindahan saja tanpa kontak permukaan tidak memberi kerusakan. Sampel direset pada ambil/lepas/pulih.
- Rekor sementara server dipisahkan per `destinationId|packageType`. Hanya pengantaran sah tanpa pemulihan yang memenuhi syarat; kondisi rusak sendiri tidak membatalkan kelayakan. Durasi lebih kecil saja memperbarui rekor, seri/lambat tidak. Hadiah tidak bergantung pada rekor dan tidak bertambah dari replay. Reset mempertahankan rekor sesi, keluar/sesi baru menghapusnya.
- `lastResult` ditambah packageType, recordEligible, recordReason, previousBest, bestTime dan newRecord; snapshot mengirim salinan bestTimes serta rekor pasangan pesanan aktif/berikutnya. HUD menampilkan jenis paket, kondisi, hasil per komponen, rekor baru/terbaik, atau alasan tidak layak akibat pemulihan.
- Penanda lokal menuntun ke tujuan saat ada pesanan dan kembali ke depot saat Idle jauh dari depot, memakai teks yang jelas; tidak mengandalkan warna saja.
- Visual memakai Part sederhana dan dekor asli yang dibuat dalam proyek. Audio cue ambil/benturan/antar memakai referensi audio bawaan Roblox yang benar-benar tersedia; sumber/pemakaian dalam runtime Roblox dicatat di asset_sources.md. Tidak ada pembelian atau unggahan/publikasi aset. Muat dan pemutaran audio diverifikasi; penilaian kenyamanan suara tetap terpisah dari bukti teknis.


## Revisi kualitas P01 — 7 November 2026

Permintaan pemilik: perbaiki bertahap sebelum deploy. Lingkup pertama: depot dan Rumah01, material jalan, halaman, kanal visual di bawah rute, papan kecil jarak dekat. Posisi titik interaksi, collision rute, ekonomi, data dan kontrak remote dipertahankan. Dekorasi baru tidak memiliki collision/touch/query, tidak membuka jalan baru. Kanal adalah dekorasi, bukan lantai aman. Aset depot prosedural diperiksa sebelum dipasang. Kriteria: area terbaca tanpa billboard menumpuk, dekorasi tidak menutup rute, pengantaran tetap bisa selesai. Penilaian rasa bermain dan HP tetap membutuhkan pemilik.

## Revisi kualitas P02 — paket dan respons pengantaran

Lingkup: dekorasi GUI pada template kardus (pita, label pengiriman), billboard paket hanya saat terlepas, penanda tujuan dengan jarak dan target paket ketika Dropped, highlight titik interaksi lokal dan ringkasan hadiah sementara setelah Delivered. Efek singkat tanpa camera shake atau lampu kilat layar penuh. Gunakan snapshot server yang sudah ada; tidak menambah remote, hadiah, data profil atau perubahan fisika/kecepatan. Panel hasil ditutup otomatis atau saat pesanan baru/reset, tidak menyerap input dan hilang saat toko dibuka. Semua listener visual dibersihkan saat script dihancurkan. Kriteria: drop/pickup/recover/antar/replay/reset tetap berfungsi; hasil hanya muncul pada Delivered dengan total resmi dari snapshot; label jarak bukan klaim jarak jalan dan tidak memberi reward.

## Revisi P03 — jalan di depan rumah dan perbaikan arsitektur

Permintaan pemilik: jalan utama tidak berada di belakang rumah; bentuk rumah/atap yang rusak diperbaiki. Front bangunan tetap +Z. Jalan utama baris depot/Rumah01–02 dipindah dari Z-40 ke Z28 relatif DepotPad, jalan lingkungan baris Rumah03–05 ke Z144, dengan akses trotoar/teras di depan setiap tujuan. Spine X-24 tetap melayani hazard dan bypass. Gang pintas papan/genangan tetap opsional di antara halaman. Titik tujuan, depot, hazard, bounds dan formula hadiah tidak dipindah; TargetSeconds belum dituning ulang. Hilangkan penanda garis/papan rute yang menunjuk susunan lama. Atap dibangun ulang dari panel simetris, gable tertutup dan eaves; tidak menumpuk atap lama. Detail rumah lain diselaraskan tanpa memindahkan pintu. Uji semua tujuan lewat jalur depan serta akses depot, hazard/bypass dan recovery. Cadangan map/UI/source sebelum mutasi; tidak deploy.

## Revisi P04 — konsistensi sesi, lantai depot, pohon

Ditemukan dua sesi main_game.rbxl:8290d62f memiliki P03, sesi baru4b3a852b yang sedang dimainkan pemilik hanya P02. Lanjutkan pada sesi baru setelah backup dan migrasi P03; sesi lama tidak diubah lagi. Buat lantai depot berupa ubin nonrumput tepat setinggi lantai asli; pindahkan lima kelompok pohon ke dalam bidang halaman/fondasi yang jelas, tidak di jalan dan tidak di pulau rumput tanpa fondasi. Kriteria: tidak ada perubahan anchor interaksi, ukuran/tinggi jalan P03; lantai rata/tidak menutup aksi pickup; seluruh pohon memiliki dukungan halaman; depot dari depan atap utuh. Simpan lokal harus diverifikasi dari file dan bukan disimpulkan dari judul tab yang sama.

## Revisi P05 — sambungan aktual dan fondasi

Gunakan hanya sesi pemilik4b3a852b. Akses jalan/teras mengikuti pusat halaman aktual, termasuk rumah baris kedua yang bergeser keZ111. Fondasi halaman, jalan dan akses diperpanjang sampai dasar kanal agar tidak mengambang. Tambah penanda tepi jalan/pembatas pada sisi kanal tanpa menutup junction spine atau pintu. Detail alamat/kotak pos berada di dalam halaman yang didukung. Path/drop/pickup/delivery tetap authoritative; tidak ubah profil, remote, reward atau posisi anchor. Uji lima tujuan melalui waypoint berdasarkan posisi aktual, bukan konstanta prototype; setup kembali ke depot boleh memakai teleport dan harus dicatat terpisah dari perjalanan antar.

## P06 — HUD ringkas dan petunjuk lingkungan

HUD desktop320x132, pendek/HP280x132 dengan teks/track ditata ulang. Status simpan tetap terlihat sebagai bar22px agar peringatan data tidak hilang. Guide otomatis52px, mode manual66px; tombol tetap44px. Saat panel hasil muncul, kartu pesanan/status sementara disembunyikan untuk mencegah tumpukan; otomatis kembali saat hasil hilang/toko/reset. Panel hasil menyebut tujuan berikut dari snapshot server. Tambah papan arah fisik dekat persimpangan dengan tiang yang bertumpu pada trotoar/halaman; tidak ada collider di jalur inti. Tidak mengubah hadiah, data/remote atau posisi tujuan. Verifikasi desktop, emulator HP landscape, state Idle/Carrying/Dropped/Delivered/reset/toko, serta expiry panel. Bukan klaim HP fisik atau uji manusia.

## P07 — percobaan aset gratis Creator Store

Cari dengan scope creator_store/priceFilter free. Kandidat pohon/bangku/pagar dimasukkan ke ServerStorage untuk audit sebelum Play, tidak mengganti layanan game. Clone hanya geometri statis yang sudah dibersihkan dari script, link package dan perilaku lain; bagian di-anchor, collision/query/touch dimatikan untuk dekorasi, Seat tidak mengaktifkan duduk. Pasang terbatas di halaman/fondasi depot agar tidak menghalangi pickup/recovery/jalan, nilai gaya lewat screenshot sebelum menggandakan. Catat assetId/creator/link/isFree saat pencarian, jumlah bagian dan konten yang dibuang. Tidak mengklaim audit bebasmalware atau semua hak tekstur sudah diverifikasi; tidak ada pembelian. Aset mesh/tekstur yang gagal muat harus ditolak atau diganti.

## P08 — panduan rute aman lokal

Navigasi opsional berupa maksimal16 titik lokal/noncollision, jarak5stud dan lookahead80stud pada polyline jalan aman. Jalur memutar hazard, tanpa teleport/pathfollowing otomatis. Saat Carrying arah ke tujuan; Idle setelah Delivered arah balik depot. Dropped/outOfBounds/toko/loading/karakter mati: titik disembunyikan. TombolRute dan G menyalakan/mematikan panduan, tidak mengirim remote baru. Ambil jalur dari geometri aktual saat Edit, simpan offset relatif PickupPoint dan gunakan snapshot.depotPosition agar translasi seluruh map tidak merusak navigasi. Jika jalan/rumah bergeser sendiri, bangun ulang konfigurasi. Pilih segmen terdekat secara horizontal, batasi jarak off-route30stud; bukan pathfinding dinamis. UIHelp/Shop diperlebar ruangnya untuk3tombol44px, kontrol chat tidak ditelan olehG. Verifikasi rute keluar/balik, toggle, drop/recover, hide ketika toko, reset, kondisi/hadiah tetap dan0collider.

Tambahan P08: pada place tersimpan Puddle tidak ada sehingga HazardService.Init melempar error dan Bootstrap tidak mencapai bindprofil. Genangan menjadi opsional: FindFirstChild dan efek slip hanya jika instance masih ada. Tidak menambahkan kembali objek yang telah dihapus pemilik. Penghalang bergerak tetap ada dan perilakunya dipertahankan.

## P09 — aset Creator Store mengikuti lingkungan pemilik

Inspeksi map/terrain aktual sebelum menempatkan dekorasi; tidak mengubah voxel Terrain, rumah, jalan atau anchor. Cari model gratis untuk lampu lingkungan, semak dan batu. Audit dalam ServerStorage saatEdit, tolak script/GUI/Remote tak perlu, gunakan hanya clone geometri statis. Lampu boleh menyertakan cahaya bawaan tanpa script, range/brightness dibatasi dan shadowfalse. Tempatkan lampu di trotoar, semak di tanah/pot, batu kecil di taman, bukan air/jalur paket. Dasar model mengikuti raycast permukaan aktual, bukan ketinggian hardcode. Simpan metadata/link/freeAtReview dan hasilmuatmesh. Jangan membeli/publish. Verifikasi dukungan,0scriptaktif/0colliderdekor, anchor/terrain tetap, startup/profil/pengantaran dan panduan tetapjalan.

## P10 — pemulihan taman dan detail depot

Sesi baru9November: Landscape09 dan template09 tidak ada pada fileterbuka; finalisasiP09 sebelumnya terputus. Backup versi rumah/terrain terbaru dahulu. Pulihkan lampu/semak/batu dari asetgratis yang diperiksa ulang; jalankan migrasiLandscapeAssets09 relatif permukaan map sekarang, tanpa mengembalikan map lama. Tambahkan satu tumpukan kardus CreatorStore gratis sebagai detail operasional depot bila lolos audit/ukuran. Pertahankan bangunan/terrain pemilik, logic/hadiah/rute. Bukti/source harus selesai disimpan sebelum laporan akhir. Simpan .rbxl tetap membutuhkan verifikasi tersendiri.

## M11 — sprint, stamina dan genggaman

Mekanik: kecepatan dasar mengikuti Humanoid.WalkSpeed awal karakter; Sprint multiplier1,4 (normal16→22,4), stamina100 menguras18/detik saat bergerak dan pulih16/detik ketika normal. Saat stamina0, sprint berhenti dan baru bisa dimulai lagi setelah20. Sprint memerlukan intentboolean valid dengan lease1,2detik; pelepasan/kehilanganfokus/toko/mati menghentikan intent. Gerak aktual horizontal>2stud/detik untuk menguras meter, bukan tombol saja. Server memegang meter dan WalkSpeed, bukan klien.

Genggaman100 per pesanan baru; hanya terkuras ketika membawa sambil sprint:14/detik biasa,22/detik rapuh, pulih10/detik saat normal atau paket terlepas. Pada0 server memanggil Impact causeGripLost (damage10/20 sesuai tipe), melepas paket, berhenti sprint dan mengembalikan grip40. Tidak ada hilangbarang/permadeath atau perubahan harga/hadiah. Warning meter oranye ketika<=25. Drop manual tidak mereset grip; kematian/reset memulihkan state baru. Meter bukan data persisten.

Kontrol desktopShift tahan, HP tombol toggle; server lease diperbarui .4detik, intent dibatasi .12detik, boolean/arity diperiksa; release selalu diterima. Meter ditampilkan bottomcenter diatas guide; disembunyikan saat modalhasil/toko/notifikasi agar tidak tumpang tindih. Tombol sprint84x44 berada di sisi kanan panel meter bawah tengah; panel tidak menutup joystick/lompat pada emulator750x323. Onboarding/cue menjelaskan GripLost.

Konfigurasi server terpusat dengan fallback lokal; experience published boleh membaca nilai ConfigService PK_* secara async, perubahan diterapkan saat karakter/pesanan baru. Tidak membuat/publish konfigurasi cloud atau eksperimen. Kriteria: sprint benar2menaikkan WalkSpeed, meter pulih/berkurang, stamina0 memaksa normal, genggamanrapuh habis lebih cepat, GripLost melepas paket satu kali, release/lease/toko/reset membersihkan speed, spam/payload tidakvalid tidak memodifikasi ekonomi, pengantaran/replay tetap valid. Angka awal adalah hipotesis playtest, bukan balancefinal.


## UI12 — sistem tampilan seragam

Lihat bagian City13 di akhir dokumen untuk penambahan pilihan rute dan variasi kota setelah UI12.

Tema krem/inkteal/gold: kartu tujuan terang, saldo badge, hierarki nama tujuan lebihbesar, status simpan sebagai catatan kecil tetapada; tombol aksi utama gold dan sekunder terang. Toolbar3tombol44px konsisten. Panelmeter gelap dengan barlebihjelas, petunjuk terang, toko dan hasil mengikuti tema. Shared/UITheme12 mengelola token/style/layout, empatcontroller input/feedback/movement/route memakainya agar aturan lama tidak menimpa desain. Tetap pertahankan namaobjek, callbacks, remote dan state sumber; jangan mengubah harga, stamina/grip atau hadiah. Desktopcard300x152, phone260x136 (adaptif pada lebarkecil). Status/failure tetap terbaca; fokus pada viewport750x323 landscape dan desktop. Teks/hitarea/interaksi/openclose/panelhasil/resize diperiksa sebelum selesai. Tidak menambah asset gambar eksternal.

Implementasi akhir: panel meter 352x56, toolbar dan tombol sprint 84x44. Status penyimpanan memakai latar krem agar tetap terbaca di atas dunia permainan. Saat toko terbuka, latar diredupkan, kartu tujuan/aksi/meter/petunjuk disembunyikan, dan tombol tutup tetap dapat diklik. Saat hasil pengantaran tampil, kartu tujuan/aksi disembunyikan sementara. Latar toko mengikuti ukuran viewport dan mempertahankan safe area bawaan ScreenGui. Warna penanda tujuan serta animasi garis kartu menggunakan token tema yang sama.

## City13 — pilihan perjalanan dan variasi ruang kota

Ground14 kemudian menyatukan seluruh tapak daratan; platform terpisah di atas air bukan lagi desain akhir lingkungan.

Masalah: loop pengantaran terlalu banyak berjalan tanpa keputusan; lingkungan terdiri dari rumah terpisah dan jalan datar. Tambahkan pilihan opsional, tanpa mewajibkan perjalanan lebih panjang untuk menyelesaikan pesanan.

Lima pos cap berada di jalur kota; pemain yang membawa paket dapat mengambil maksimal dua pos berbeda per pesanan. Default enam koin per cap, dibayarkan hanya pada pengantaran sukses melalui ledger ekonomi yang sama. Pemain memilih langsung mengantar demi bonus waktu atau mengambil cap untuk bonus pos. Drop/pickup tidak membuat pesanan baru atau mereset cap. Tidak ada remote untuk meminta bonus; server memeriksa profil, karakter hidup, status Carrying, jarak, dan ID pos. Snapshot hanya mengirim salinan visited/count/limit/total. Nilai PK_CityStampReward, PK_CityStampLimit, PK_CityStampRadius mengikuti adapter ConfigService server yang sudah ada, dengan fallback lokal dan batas nilai; reward/limit dibulatkan ke integer per pesanan.

Kota mendapat dua blok fondasi, plaza pasar, lima bangunan fasad dengan tinggi berbeda, tiga kios, planter, landmark jam, serta jembatan pejalan kaki dengan ramp dan pos bonus di atasnya. Seluruh geometri baru berada di Map.City13, tanpa menulis Terrain atau memindahkan rumah pemilik. Jalan di bawah jembatan tetap terbuka; ramp terhubung ke blok baru. Bangunan berupa fasad, belum memiliki interior/NPC. Angka reward dan kepadatan kota perlu diuji pemain; tidak dianggap sudah membuktikan retensi atau pendapatan.

## Ground14 — daratan dan pertemuan permukaan

City15 menggantikan lapisan permukaan Ground14/legacy dengan partisi permukaan tunggal agar tidak ada z-fighting pada persimpangan dan jalur lama.



Ganti tampilan pulau-pulau platform yang terputus dengan satu tapak daratan kontinu. Ground14 berisi tanah dasar dan rumput berukuran282x180, batas x[-136,146], z[-24,156]. Permukaan rumput4477.75 berada.25stud di bawah jalan/floor4478, sehingga tidak menimpa aspal atau interior. Lima HousePad rumput lama disembunyikan dan collider/shadow dimatikan; lantainya digantikan rumput kontinu, bukan dihapus. Posisi rumah/tujuan/depot dipertahankan. Air dan bed diperluas ke perimeter luar, bukan sela antarbangunan. Native Terrain voxels tidak disentuh; lingkungan ini menggunakan Parts.

Tiga lantai blok City13 dan trotoar/jalur pintu menggunakan Pavement senada. Tambah sambungan rumah ke sidewalk, dua trotoar panjang, jalur sisi jalan tengah serta lintasan taman. Jalur barat digeser dari tiang jembatan. Planter/hedge yang berada di bawah ramp dipindah8stud ke arahZ. Migrasi satu kali src/UnifyGround14.luau menolak Ground14 yang sudah ada. Semua perubahan dapat dipulihkan dari backup Map sebelum migrasi.

## Challenge16 — tiga target per sesi

Tujuan: memberi arah permainan setelah onboarding. Tiga target berurutan: Kurir Rapi (dua pengantaran kondisi≥90 tanpa Recover, hadiah20), Jelajah Kota (satu pengantaran dengan cap bonus tanpa Recover, hadiah25), Spesialis Rapuh (satu paket Rapuh kondisi≥80 tanpa Recover, hadiah30). Pengantaran yang menyelesaikan target hanya dihitung untuk target aktif itu; tidak menyelesaikan beberapa target sekaligus. Pengantaran yang tidak memenuhi syarat tidak mengurangi progres.

Progres disimpan pada sesi EconomyService, bertahan ketika respawn dan direset ketika keluar/server baru. Bonus koin ditambahkan ke hasil pengantaran lewat ledger lama; tidak ada tombol/remote klaim baru. Preview menghitung state baru tanpa memutasi state aktif; commit dilakukan setelah pemeriksaan batas ekonomi dan satu kali per order. Setelah seluruh target selesai, bonus target berikutnya nol. Koin mengikuti mode penyimpanan profil yang sudah ada; target ini bukan target harian atau progres persisten.

MovementTuning menyediakan fallback dan opsi PK_ChallengeCleanCount/CleanCondition/FragileCondition/CleanReward/ExploreReward/FragileReward dari ConfigService. Nilai dikunci saat sesi dibuat, reward/count integer dan dibatasi. HUD target menampilkan progres/hadiah, tersembunyi saat toko/hasil terbuka, desktop300x90 dan landscape pendek180x90. Hasil pengantaran menampilkan TARGET TERCAPAI dan rincian bonus. Tidak mengubah map/aset atau membuat konfigurasi cloud baru.

## Jobs17 — pilihan pekerjaan di depot

Pemain membuka papan melalui E/tombol Pilih pesanan ketika dekat depot, lalu memilih satu dari tiga kartu. Reguler memakai paket Biasa dan tujuan urutan berikutnya, tanpa bonus pekerjaan. Rapuh memakai tujuan bergilir dan paket Rapuh, bonus maksimal8. Lintas Kota memilih Rumah04/05 dengan paket Biasa, bonus maksimal10. Bonus pekerjaan dibayar floor(bonusTawaran*kondisi/InitialCondition), bersama hadiah dasar/waktu/kondisi/cap/target yang lama. Angka awal belum dianggap balance final.

Server membuat dan menyimpan tiga tawaran pada revisi sesi yang sama; bonus yang ditampilkan tidak berubah sampai revisi pesanan berganti. Client hanya mengirim AcceptJob(id), tidak mengirim tujuan/harga/bonus. Server tetap memvalidasi profil, karakter hidup, jarak depot, tidak ada pesanan aktif, argumen, dan ID tawaran saat ini. AdvanceAssignment menaikkan revisi monoton dan membuang cache, sehingga ID lama kedaluwarsa meskipun jadwal10pesanan berulang. Parameter PK_JobFragileBonus/PK_JobLongBonus mengikuti ConfigService adapter, default8/10 dan dibatasi0..20; tawaran baru memakai konfigurasi saat dibuat.

Menu620x280 berisi tujuan/jenis/bonus maksimal dan tombol44px. HUD perjalanan, meter sprint, petunjuk/rute, dan target sesi disembunyikan sementara. Toko menutup papan, pesanan diterima menutup papan otomatis, tombol×/E menutup tanpa mengambil paket. Alur lama Start tetap tersedia untuk kompatibilitas server, dengan jadwal asli dan bonus pekerjaan0; UI pemain memakai papan. State hasil menyertakan jobName/jobBonus, dan rincian hadiah menjelaskan bonus Kerja. Tidak menambah map/aset/DataStore schema.

## MobileMarket18 — HUD ponsel, dukungan geometri, kategori pasar

Ponsel ditentukan dari TouchEnabled serta viewport lebar<1000 atau tinggi<600. Desktop memakai layout sebelumnya. HUD ponsel: kartu238x84 berisi tujuan, saldo, kondisi dan cap; satu Menu84x44 membuka rute/petunjuk/toko/target. Target sesi dan petunjuk tidak otomatis memenuhi layar. Status penyimpanan normal disembunyikan; error/loading tetap tampil dan kesalahan aksi mendapat notice sementara. Meter238x32 saat Carrying,118x32 ketika stamina terpakai tanpa paket, hilang saat idle penuh. Sprint100x44 terpisah di bawah, berjarak dari joystick/lompat. Target/petunjuk/menu tidak ditampilkan bertumpuk; saat membaca target tombol aksi disembunyikan. Label dunia depot/pemulihan hanya muncul sesuai status; toko tersedia melalui Menu. Semua hadiah, input dan validasi server tetap berlaku.

Audit prop memakai raycast dari bawah ke geometri, bukan GetBoundingBox saja. Pada67prop,11perlu penurunan, termasuk dua meja piknik sekitar.91stud. Tanaman di pot dan dua kardus lapisan atas dipertahankan sebagai benda bertumpu pada objek lain. Setelah koreksi, audit ulang tidak menemukan koreksi tambahan. GroundProps18.luau menyimpan migrasi/audit; rumah dan marker gameplay tidak digeser sebagai prop tanah.

Pasar menjadi ROTI HANGAT, SAYUR SEGAR dan BUAH SEGAR. Empat model gratis yang diaudit menghasilkan15display/78Parts: empat roti, enam wortel mendatar, satu peti buah dan empat display buah. Barang ditambatkan secara geometris ke CFrame countertop aktual, dengan proyeksi ukuran dunia untuk rotasi, sehingga tidak melayang ketika map diputar. Produk kotak lama disembunyikan. No script vendor dipakai. Penempatan statis, tanpa pembelian barang/sistem jual beli baru.

Orientasi map berubah secara global selama pengerjaan; migrasi mengikuti posisi terbaru. Snapshot routeBasis berasal dari rotasi DepotPad. RouteGuide dan warga dekoratif mentransformasikan offset lokal melalui basis ini. Susunan rumah sesuai transformasi kaku yang sama dengan galat<.001stud; tidak mengembalikan map ke orientasi backup lama.

## Navigation19 — kompas kurir dan batas area mengikuti map

Gunakan ruang header kartu tujuan untuk panah relatif kamera dan jarak perjalanan, tanpa panel tambahan. Dengan rute aktif, panah menuju titik panduan ketiga yang masih terlihat dan jarak adalah panjang jalur tersisa ditambah jarak untuk kembali ke jalur. Jika panduan dimatikan/tidak tersedia, panah langsung ke tujuan dan jarak horizontal langsung. Saat jarak3D memenuhi ActionDistance, panah berubah menjadi✓ dan teks menjadi Pilih pesanan/Ambil ulang/Siap diantar. Status mati/loading menyembunyikan arah, dan status outOfBounds meminta pemulihan tanpa panah ke tujuan yang keliru.

Snapshot paket aktif menyertakan packagePosition. Saat objek paket tidak tersedia di client, indikator masih menunjuk posisi server untuk paket milik pemain itu. Marker lama tidak lagi menunjuk rumah ketika status Dropped dan paket belum tersedia. Mobile menampilkan Primary hanya ketika ActionEnabled; Secondary bergeser ke slot atas saat Primary tersembunyi. Desktop mempertahankan tombol nonaktif sebelumnya. Label aksi dekat tujuan menjadi Antar paket.

Bug perhitungan batas ditemukan setelah map diputar: PackageService dan logika teleport Recover sebelumnya mengurangi Position DepotPad sehingga tetap memakai sumbu dunia. Kini keduanya memakai DepotPad.CFrame:PointToObjectSpace, dengan batas konfigurasi yang sama. Lima tujuan kota berada dalam batas lokal; titik di luar batas tetap ditolak. Hadiah/harga/kerusakan tidak diubah. Ini mendukung transformasi map secara keseluruhan, bukan pathfinding dinamis untuk jalan yang dipindah satu per satu.

## Gear20 — tujuan belanja dan peningkatan genggaman

Koin pengantaran sekarang dapat ditabung untuk tiga level sarung tangan, selain membeli warna tas. Harga per level: 80, 140, 220 koin (total 440). Setiap level mengurangi pemakaian genggaman saat sprint sebesar 10 poin persentase, maksimal 30%. Kecepatan, stamina, kondisi paket, dan regenerasi genggaman tetap mengikuti mekanik sebelumnya. Nilai bonus dikunci ketika pesanan baru dimulai; membeli tidak mengisi ulang meter. Harga dan pengurangan mengikuti adapter ConfigService dengan fallback lokal dan batas nilai; kutipan harga/bonus dikunci per sesi.

Toko 620x272 memiliki tab Tas dan Peralatan, tanpa panel HUD permanen baru. Tab Peralatan menampilkan level, efek level berikutnya, saldo/harga dan tombol 44px. Sarung tangan cokelat/teal/emas dipasang pada tangan avatar sesuai level, massless dan tanpa collision. Geometri buatan sendiri; tidak membutuhkan aset eksternal. Source mendukung anggota tubuh R15/R6, tetapi uji avatar R6 fisik belum dilakukan.

Client mengirim BuyGrip dengan level saat ini sebagai token pembelian. Server memvalidasi profil, karakter hidup, jarak ShopPoint aktual, tidak ada pesanan aktif, level, batas maksimal dan saldo; harga hanya dihitung server. Permintaan ulang dengan level lama tidak membeli level berikutnya. Pengurangan koin dan kenaikan level terjadi tanpa yield lalu menandai profil dirty.

ProfileSchema versi 2 menambah upgrades.Grip integer 0..3. Migrasi schema 0/1 mempertahankan koin, kepemilikan tas, tas aktif, jumlah pengantaran dan rekor; Grip dimulai dari 0. Envelope tetap versi 1. Progres upgrade memakai jalur penyimpanan profil yang sudah ada, bukan progres target sesi. Pengujian saat ini hanya StudioMemory lokal, sehingga saldo/upgrade uji hilang setelah Stop. Migrasi/rejoin pada DataStore published belum diuji. Rollback reader lama schema 1 tidak kompatibel dengan profil yang telah disimpan versi 2; jangan deploy rollback lama terhadap data tersebut.

## Relay21 — titipan antar rumah

Setelah pesanan dari depot selesai, pelanggan menawarkan satu titipan Biasa ke rumah lain. Pemain dapat mengambilnya pada titik pengantaran rumah tersebut atau melewatinya untuk kembali ke depot. Tawaran berlangsung 60 detik secara default; ini batas waktu mengambil tawaran, bukan batas waktu menyelesaikan pengantaran. Kartu tujuan lama menampilkan tujuan baru, hitung mundur dan bar waktu emas. Tombol Ambil titipan/Lewati titipan memakai slot aksi E/Q yang sudah ada. Tidak menambah panel permanen di HP. Dekat depot, aksi utama dan navigasi tetap memilih pesanan depot.

Server memilih bergantian dari dua tujuan dengan panjang jalur terpendek, selain rumah sumber. CourierPaths21 menyambungkan rute jalan sumber yang dibalik dengan rute tujuan pada simpang bersama terakhir; koordinat tetap mengikuti basis map yang sudah berotasi. Setelah diterima, paket benar-benar diambil dari posisi pemain di rumah sumber dan panduan menuju rumah baru. Titipan yang selesai tidak menghasilkan titipan berikutnya: satu pesanan depot maksimal diikuti satu perjalanan lanjutan. Jadwal pesanan depot tidak maju ketika mengambil titipan.

Tawaran disimpan per pemain di DeliveryService, dengan ID server, sumber, tujuan dan waktu kedaluwarsa. AcceptRelay memeriksa profil, karakter hidup, tidak ada pesanan aktif, jumlah/tipe argumen, token saat ini, masa berlaku dan jarak 3D ke titik rumah sumber aktual. SkipRelay tidak memberi hadiah. Tawaran hilang setelah diterima, dilewati, kedaluwarsa, mengambil pesanan depot baru, cancel, respawn atau keluar. Tidak ada remote baru; dua aksi melewati ActionRequest yang sudah ada dan tetap memakai request cooldown.

Hadiah titipan memakai ledger pengantaran yang sama: dasar/kondisi/waktu/cap/target sesi. Tidak ada bonus uang khusus untuk menerima tawaran, tidak ada job bonus titipan, dan replay tidak memberi kredit ulang. Target waktu titipan dihitung dari panjang jalur / 16 × RelayTimeScale (default 1.4), minimum 15 detik. PK_RelayOfferSeconds dan PK_RelayTimeScale mengikuti adapter ConfigService, masing-masing dibatasi 20–120 dan 1–3. Tuning tawaran dikunci saat dibuat. Rekor depot tidak dipakai atau ditulis oleh titipan karena titik awal berbeda; hasil diberi recordReason=RelayRoute. Schema profil tetap 2.

## Quality22 — penilaian dan pelanggan

Setiap pengantaran sah mendapat penilaian server: 3 bintang ISTIMEWA untuk kondisi minimal95, tanpa Recover dan selesai dalam target waktu; 2 bintang RAPI untuk kondisi minimal80 tanpa Recover; selain itu 1 bintang TUNTAS. Target waktu memakai target rute depot atau target jalur titipan sesuai pesanan. Ini tidak mengubah rumus hadiah, syarat menyelesaikan paket, atau rekor waktu. PK_RatingCleanCondition(default80,bounds50..95) dan PK_RatingExcellentCondition(default95,bounds80..100) melalui adapter ConfigService, dikunci per sesi. Ambang Istimewa tidak dapat lebih rendah dari ambang Rapi.

Pengantaran dengan 2/3 bintang menambah rangkaian rapi berturut-turut; 1 bintang mereset rangkaian. Membatalkan pesanan aktif juga meresetnya, sedangkan cancel tanpa pesanan tidak menghukum pemain. Terbaik sesi tetap dipertahankan. Rangkaian dan terbaiknya hanya hidup dalam sesi EconomyService, tidak ditambahkan ke profil persisten. Preview penilaian/rangkaian terjadi sebelum pemeriksaan batas ekonomi; commit bersamaan dengan ledger, sehingga kegagalan/replay tidak menambah progres. Tidak ada bonus koin dari bintang atau rangkaian.

Panel hasil lama menjadi330x212: bintang, petunjuk meningkatkan kualitas, penghitung koin singkat, rincian hadiah dua baris, rangkaian/terbaik sesi dan langkah berikutnya. Panel hilang setelah5detik atau tombol×44px. HUD/aksi/meter yang lama disembunyikan selama hasil tampil. Tidak menambah panel permanen pada HP.

Lima pelanggan lokal berada di samping titik rumah, memakai56Part total dengan variasi warna/rambut. Penempatan menguji lantai lewat raycast dan ruang badan bebas penghalang; tidak memiliki collision/touch/query. Model disembunyikan di luar65stud, animasi dekat pemain diperbarui20Hz. Pelanggan menghadap pemain dan melambaikan tangan selama12detik setelah hasil Delivered baru. Dialog sesuai kualitas dan menyebut titipan ketika tersedia; bubble tersembunyi ketika hasil/toko/papan pesanan tampil. Replay/Sync tidak mengulang reaksi. Karakter ini dekoratif dan tidak memvalidasi transaksi atau memberikan koin.

## City23 — pusat kota, taman dan jalur tepi kota

Lima blok pusat kota mendapat fasad tiga sisi yang sebelumnya polos: jendela berbingkai, etalase, pintu menghadap jalan, kanopi bergaris, trim lantai, parapet dan tangki atap bundar. Identitas kawasan: Roti Kampung, Wisma Kilat, Bengkel Sepeda, Buku & Cerita, Balai Warga. Papan nama fisik tersedia di sisi jalan dan halaman; label melayang lama pada lima gedung dinonaktifkan. Rumah tujuan dan marker gameplay tetap di posisi semula. Etalase/pintu gedung adalah dekorasi, bukan sistem toko baru atau interior yang dapat dimasuki.

Plaza pasar memiliki air mancur dekoratif dari aset Creator Store gratis yang dibersihkan menjadi17MeshPart/3SurfaceAppearance, dua bangku berhadapan dan tanaman rendah. Taman depan mendapat pergola di atas meja piknik yang sudah ada. Halaman toko buku/balai warga menjadi pojok baca dengan lemari buku terlindung dan dua bangku. Jalur tepi kota terhubung ke taman, dengan tiga bangku, dua lampu dan pagar rendah. Dua jalur taman samping, planter dan tempat sampah memberi fungsi pada ruang kosong. Furnitur dekoratif tidak menambah transaksi/interaksi baru.

Permukaan baru memotong tile rumput Surface15 yang lama; tidak menumpuk lantai atau menghapus voxel Terrain.19tile diganti70tile, total144tile dengan luas282×180 tetap. Dua zebra cross berhubungan dengan celah10stud pada pembatas lama di z35, x47 dan x-90 dalam basis DepotPad.4panel lama disembunyikan,8segmen pengganti mempertahankan collision di luar celah,2tiang lama yang berada di celah disembunyikan. Clearance kanopi baru minimal sekitar6stud di atas lantai; planter tepi kota berada di luar jalur berjalan. Grounding clone mesh diperiksa dari bawah agar kaki bangku/lampu dan dasar air mancur menyentuh tumpuannya.

Semua elemen City23 dibangun statis lewat migrasi Edit, tanpa script vendor atau script gameplay baru. Total659Part pada folder City23 termasuk segmen pengganti pembatas. Peningkatan ini belum dianggap optimal untuk HP fisik sebelum dilakukan profiling perangkat; pemeriksaan Play mencakup akses jalan, pemuatan aset dan satu pengantaran utuh melalui tool navigasi.
