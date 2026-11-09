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
