# Paket Kilat! — Laporan T22/T23

Tanggal persiapan: 7 November 2026 (WIB). **T22/T23 BELUM SELESAI.** Hasil HP asli: belum tersedia. Tester manusia T23: **0/10–20**. Jangan mengisi kolom kosong dengan hasil emulator.

## Gerbang build dan akses

- Versi yang harus diuji: **T21-v1**, panel Petunjuk dan tombol FPS tersedia. File lokal `main_game.rbxl` bukan aplikasi yang bisa langsung dibuka di HP Roblox.
- Build HP/tester yang sudah dapat diakses tanpa publikasi baru: **BELUM TERSEDIA**. Jawaban pemilik7 November2026: “belum ada akses build HP”.
- PlaceId/versi build yang benar-benar dimainkan: ___; cara akses yang sudah tersedia: ___; tanggal/jam WIB: ___. Jangan tulis kode undangan privat/token di laporan.
- Jika hanya versi terbit lama tersedia, catat “build tidak cocok” dan hentikan penilaian T22/T23 untuk versi ini. Asisten tidak menerbitkan, mengganti akses, merekrut lewat pesan, atau membeli apa pun.

## Tes HP singkat — pemilik/operator, setelah fase onboarding tanpa bantuan

1. Catat model HP, OS/versi Roblox, orientasi landscape, level grafis, jaringan (Wi-Fi/seluler), jumlah pemain aktual dan build. Hindari nama akun, kontak, alamat/IP, chat, lokasi rinci atau data pribadi lain.
2. Mulai sesi baru. Sebelum diberi langkah kontrol, beri kesempatan maksimal10 menit mencari alur sendiri; catat waktu mengambil paket dan pengantaran pertama, bantuan yang diberikan, serta apakah memulai pesanan kedua. Tester T23 tidak diberi langkah3–6 sebelum observasi ini selesai.
3. Sesudah observasi, uji tombol Ambil, Lepas, Ambil ulang dan Pulihkan. Coba jatuh dari papan, lalu pulih/ambil ulang. Catat tombol terhalang, kamera, teks sulit dibaca dan keadaan yang membuat buntu.
4. Antar satu paket, mulai pesanan kedua, lalu Reset saat membawa. Pastikan pesanan dibatalkan, saldo tetap dan tas tidak ganda. Toko opsional: beli/pakai hanya dengan koin. Masuk ulang menguji progres hanya pada build DataStoreTest, bukan StudioMemory.
5. Ukur FPS **di HP fisik**: Petunjuk → FPS, lalu berjalan60 detik (depot→jalan aman→rintangan→rumah, kamera digerakkan). Catat median/min FPS, frame lambat>100ms, lama/sampel dan jumlah pemain. FPS berasal frekuensi RenderStepped per jendela1 detik; bukan pengukuran GPU atau puncak sesaat. Jangan minimize aplikasi selama pengukuran. Jika overlay tidak ada/versi lama, catat tidak diukur; jangan menebak.
6. Ulangi60 detik di area/rintangan terberat. Nilai sasaran awal30 FPS dari pengukuran yang disebutkan; min rendah atau macet berulang tetap menjadi masalah meski median≥30. Catat panas/penurunan, putus sambungan atau crash tanpa menyimpulkan penyebabnya. Akhiri dengan komentar kenyamanan kontrol/audio.

| Perangkat fisik | OS/Roblox | Build & metode akses | Grafis/jaringan | Pemain aktual | Skenario60dtk | Median/min FPS | >100ms & sampel/durasi | Kontrol/UI/kamera | Hasil & bukti |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| BELUM DIUJI | — | — | — | — | — | — | — | — | — |

T22 lulus hanya setelah perangkat disebutkan, siklus lengkap diuji nyaman dan angka FPS nyata dievaluasi. Bila FPS tidak diukur atau masalah kontrol menghalangi pengantaran, tetap terbuka.

## Rekrutmen dan panduan fasilitator T23

Rekrut10–20 manusia yang belum mengetahui solusi permainan; tanpa pembayaran/iklan. Gunakan kanal pribadi yang sudah Anda kelola. Undangan netral yang boleh disalin:

> Saya sedang menguji prototipe game Roblox. Bersedia mencoba sekitar10–15 menit dan memberi komentar? Mainkan seperti biasa menggunakan petunjuk di dalam game. Saya ingin melihat bagian yang mudah atau membingungkan.

Jangan sertakan depot, tombol E/Q/R, rute aman atau cara pulih pada undangan. Jangan berikan dokumen operator ini kepada tester sebelum fase awal. Pemilik mengatur akses yang sudah tersedia; tidak ada publikasi baru yang diotorisasi oleh tugas ini. Kapasitas teknis sebelumnya8 klien Studio; gunakan gelombang≤8, misalnya5+5 atau5+5+5+5. **10–20 berarti total manusia, bukan harus10–20 serentak.** Catat puncak pemain nyata.

Berikan instruksi awal hanya: **“Coba game ini dengan petunjuk di layar. Mainkan seperti biasanya; ceritakan jika ada yang membingungkan.”** Mulai timer saat pemain dapat mengendalikan karakter/profil Ready. Amati maksimal10 menit pertama tanpa menunjukkan solusi, layar operator, atau contoh pemain lain. Jika diminta bantuan, catat waktu/isi singkat; keberhasilan sesudah bantuan bukan “tanpa panduan”. Jangan memaksa pemain melanjutkan. Bug teknis tetap dicatat.

Sesudah observasi, tanyakan: apa tujuan permainan menurutmu; apa yang membingungkan; apakah ingin pesanan kedua; mengapa berhenti? Alasan boleh berupa kategori dan parafrasa pendek yang dibersihkan dari data pribadi. Kemudian barulah lakukan skrip kontrol/FPS di atas. T22 perangkat milik operator harus dievaluasi sebelum sesi manusia T23 dihitung selesai.

## Baris tester manusia — isi kode anonim saja

“Pertama” = pengantaran sah; “kedua” = benar-benar mulai pesanan kedua. Tandai baru/pernah main, bantuan, waktu, selesai/tidak/timeout/keluar/gangguan teknis. Tentukan10 tester pertama menurut urutan mulai sebelum melihat hasil; jangan memilih10 hasil terbaik atau mengganti kegagalan diam-diam.

| Kode | Tanggal/gelombang | Perangkat & build | Baru? | Ambil pertama (detik) | Antar pertama (detik/hasil) | Bantuan? | Pesanan kedua? | Berhenti pada/alasannya | Masalah kontrol/teknis |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| T01 | — | — | — | — | — | — | — | — | — |
| T02 | — | — | — | — | — | — | — | — | — |
| T03 | — | — | — | — | — | — | — | — | — |
| T04 | — | — | — | — | — | — | — | — | — |
| T05 | — | — | — | — | — | — | — | — | — |
| T06 | — | — | — | — | — | — | — | — | — |
| T07 | — | — | — | — | — | — | — | — | — |
| T08 | — | — | — | — | — | — | — | — | — |
| T09 | — | — | — | — | — | — | — | — | — |
| T10 | — | — | — | — | — | — | — | — | — |
| T11 | — | — | — | — | — | — | — | — | — |
| T12 | — | — | — | — | — | — | — | — | — |
| T13 | — | — | — | — | — | — | — | — | — |
| T14 | — | — | — | — | — | — | — | — | — |
| T15 | — | — | — | — | — | — | — | — | — |
| T16 | — | — | — | — | — | — | — | — | — |
| T17 | — | — | — | — | — | — | — | — | — |
| T18 | — | — | — | — | — | — | — | — | — |
| T19 | — | — | — | — | — | — | — | — | — |
| T20 | — | — | — | — | — | — | — | — | — |

## Evaluasi — belum ada hasil manusia

- Jumlah manusia dengan bukti: **0**; puncak serentak: belum tersedia. Emulator/bot Studio tidak termasuk.
- Penyelesaian tanpa bantuan pada10 pertama: **belum dapat dihitung**, bukan0% dan bukan lulus. Sasaran≥8/10; laporkan pembilang/denominator dan timeout/keluar/gangguan teknis secara terpisah. Jika denominator belum10, kesimpulan sementara saja.
- Pesanan kedua: ___/___; median waktu pengantaran pertama: ___ (hanya hasil sah, sebutkan N); alasan berhenti utama: ___.
- Masalah yang perlu diperbaiki (kode, langkah, expected/actual, dampak): belum ada bukti baru. Jika<8/10, buat daftar perbaikan onboarding untuk lingkup berikutnya; jangan mengerjakan T24 di tahap ini.
- Keputusan T22: **TERBUKA** — akses build HP belum tersedia menurut pemilik; belum ada HP fisik/FPS/kontrol yang dapat dievaluasi.
- Keputusan T23: **TERBUKA** — menunggu T22 dan10–20 tester manusia.

## Pemisahan bukti teknis

T01–T20 sebelumnya memakai Studio; delapan klien benar-benar dijalankan, tetapi bukan delapan manusia/HP. T21 sudah menambah regresi dua klien73/73, telemetri injeksi33/33, layout emulator dan sampel FPS desktop60 detik. Angka teknis itu dicatat di verification/handoff, tidak disalin sebagai hasil manusia pada tabel di atas. Dashboard analitik live belum diverifikasi.


## City32 — verifikasi teknis lokal, 10 November 2026

Tambahan visual462part/38mesh pada Map.City32. Empat segmenMoveTo pendek berhasil,38mesh preloadSuccess/0failure,17anchor dan140bidang floor cocok baseline; consolePlay freshBootstrap saja. Screenshot3D/Edit tersedia. Fixture memindahkan avatar ke awal masing-masing segmen dan berjalan ke ujung; tidak membawa paket dan bukan uji pemain manusia/HP fisik/performa. HP/FPS/multiplayer tidak dievaluasi ulang pada pass ini. Bukti verification/city32-audit.json; ini tidak mengubah status T22/T23 atau izin rilis/pemain luar.


## Audio33 — verifikasi teknis lokal, 10 November 2026

Tujuh audioStoregratis dimuat, dua musik bergantian/crossfade,4emitter3D berhenti saatjauh, kontrolbus terpisah danprefsnondefault bertahanrespawn. FixtureStudioMemory memicuPickup/Drop/Impact/Recover/Stamp/Delivered; Play/Ended danDeliveredduck.32 terukur, replayreceipt tidak mengulangcue. Cleanup melaluiobserverindependen lolos setelahperbaikan. ProfileIDkosong fixturefallback dipulihkan;7source disk/Edit cocok. ConsolefreshBootstrap saja. Desktop danGalaxyA06landscape/Root705×280 diperiksa; sentuhfisik/FPS/pendengaran asisten tidak diklaim. Publikasi/pemain luar tetap ditunda; T22/T23 tidak dicentang.


## Upgrade34 — verifikasi lokal, 10 November 2026

32kombinasi gear pada rig engineR6/R15,16pada avatar aktif,respawn;pengantaran3bintang/biasa/capPos3/replay;duaMoveTo dan343sampelfloor;5targetplannerterhubung;previewdesktopdanGalaxyA06landscape muat. Semua fixtureStudioMemory dengan penempatan/elapsed terkontrol, bukan perjalanan manusia atauHPfisik. Renderer gelap juga dilaporkan pemilik, lalu kembali setelah refresh kualitaslokal dan dipotret diEditor/Play. ConsoleakhirBootstrap saja. Bukti upgrade34-audit.json;tidak mengubah statusT22/T23 atau izin rilis.


## District35 — pusat kota, ruko dan jembatan (10 November 2026)

Sesi AutoRecovery yang disetujui. Baru:16ruko/4kantor/taman/jalan grid+diagonal/jembatan25stud/furnitur dan66model gratis dari library bersih.20calon alamat+16node; tujuan order aktif/bounds/ekonomi tetap.2122Part/114Mesh/682collider/0script/0light di root; menghapus578sel native redundan lewat penggabungan bidang setara luas.

Audit7337sampel area0lubang, tinggiY4478; luas44997+59784stud².11koridor×3offset bebas penghalang solid. Dua ray tepat pada batas sel memerlukan toleransi.005stud, bukan lubang yang dapat menjatuhkan karakter; tes Humanoid melewati sambungan.66model feet gap maksimum.0181stud.17anchor final cocok baseline, setelah PickupPoint dipulihkan atas persetujuan pemilik. Bursa Kreatif hasil edit manual dipertahankan.

Play awal:4segmen player lolos. Percobaan teleport client jauh gagal/tidak dipakai sebagai lulus karena Streaming/input; probe PlayerModule menghasilkan error harness. Rig server-owned sementara:6segmen(jembatan/3diagonal/avenue barat/depan ruko) lolos health100. FreshPlay setelah penggabungan lantai:2segmen jembatan/barat lolos, consoleBootstrap saja. RequestStreamAroundAsync mengonfirmasi dua area client tersedia;114mesh/11ID preloadSuccess. AkhirEdit/tanpafixture. Bukan pengujian perjalanan order penuh, HP fisik, FPS atau multiplayer.

Source authoring3file cocokdisk/Edit, audit/alamat/owner override/status simpan dan3JPEG disimpan di verification/district35-*. Pemilik menyimpan ulang main_game555260byte/14:54:39WIB: District35/Upgrade34 dan ketiga source akhir cocok persis. Titik depot pada Edit sudah pulih; tidak ada save tertunda untuk tahap35. Tidak ada publikasi/pemain luar.


## City36 — perbaikan dan pengisian kota (10 November 2026)

10757sampel floor0lubang/0tinggi salah;9koridor×3offset bebas blocker.17anchor tidak berubah, empat OfficeBody edit pemilik cocok posisi/ukuran/warna.10calon pintu baru didukungfloor dan bebas body di volume akses. Audit nativefloor kota lama sebelum perapian approach0overlap>.006stud; satu exact-edge ray bridge memakai toleransi.005stud.

Play:10segmen Humanoid server-owned sampai health100;2segmenjunction diulang setelah aspal approach dirapikan, keduanya sampai/Asphalt.37mesh/8content ID preloadSuccess,consoleBootstrap saja. ServicefixtureStudioMemory: tokoEquipCosmetic danStart berhasil, paketCarrying/outOfBoundsfalse dix-130/132,Cancel→Idle dan koin tidak berubah. Karakterdipulihkan,fixture dibersihkan,akhirEdit. Bukan perjalanan order utuh atau tes HPfisik/FPS/multiplayer.

Teks papan sempat gepeng karena CanvasSizing default;22SurfaceGui diubah kePixelsPerStud. Tangkapan transisi yang membesar dibuang; capture stabil terbaca normal.6source disk/Edit cocok. Map utama619614byte sudahCity36,tetapi koreksi canvasCityInfill36 terakhir belum tersimpan pada target proyek; pengguna menjelaskanCtrl+S padaAutoRecovery. Statuslanjut pada verification/city36-save-status.json. Tidak ada publikasi/pemain luar.


## City37 — warga dan penyelesaian fasad

464sampel18profil:floorhilang0/blockerbangunan0.405Partartanchored/noncollision/nontouch/nonquery,0script/light;17anchor dan30bodymodel tidakberubah. FreshPlay3aktor dekatspawn,7Quay,7taman,maxbudget8; motion~3.4stud/1.2s. Far→0/return→7. Disable/destroy membersihkanfolder,replace→1folder/7aktor,respawn→1folder/3aktor. BagianNPCsemuaanchored/nocollide/touch/query. SceneAnalysisOpaque satuview48764tri/35draw versus47636/34tanpawarga, bukanFPS.

GalaxyA06landscapeTouchtrue,Root705×280,5aktor/budget5,HUDtrue. Defaultviewport dipulihkan;akhirEdit/tanparuntimeNPC. HUDtemplateawalfalse dipulihkantrue. Viewportgelap terpulih viaEditQualityLevel1→Automatic; penyebabtidakterisolasi. ConsoleakhirBootstrap saja. Tidak mengujiHPfisik/multiplayer/antarorderpenuh atau memberi hadiah. Source5cocokEdit/disk; source/artifactdanSDDtercatat, statusSaveAsmain_game pada city37-save-status.json.
