# Paket Kilat! — Daftar Tugas SDD

Acuan: [design.md](design.md)  
Status: T01–T21 selesai secara teknis; T22/T23 terbuka menunggu akses build HP dan bukti manusia  
Tanggal: 7 November 2026

## Aturan pengerjaan

- `[ ]` belum selesai; `[x]` selesai dan memiliki bukti verifikasi.
- Kerjakan menurut dependensi. Tugas tidak selesai hanya karena script sudah dibuat.
- Sebelum mengubah perilaku, perbarui kebutuhan di `design.md`, kemudian tugas dan kriterianya.
- Catat bukti singkat pada log di akhir: mode tes, hasil, serta keterbatasan. Jangan mencentang uji perangkat asli dari hasil emulator.
- Simpan cadangan place sebelum perubahan besar. Jangan menimpa konten lama sebelum inspeksi.
- Tidak ada estimasi tanggal atau biaya yang disepakati dalam daftar ini.

## Milestone 0 — Persiapan

- [x] **T00 — Menyusun spesifikasi dan daftar tugas.** Acuan: seluruh REQ. Hasil: `design.md` dan `task_list.md`; asumsi SDD dan keputusan terbuka tercatat. Ini tidak berarti desain sudah diuji.
- [x] **T01 — Memeriksa place dan koneksi MCP.** Dependensi: T00. Target lokal `main_game.rbxl`, Studio `f95030e1-cb9f-415f-ab90-cec8b8dfa7a8`, PlaceId/GameId 0. Awalnya tidak ada script game. Baseplate, spawn, kamera, terrain diidentifikasi; error historis dicatat di handoff. Bukti: inspeksi MCP dan `verification/studio-manifest.json`.
- [x] **T02 — Membuat cadangan serta struktur proyek.** Dependensi: T01. Cadangan penuh `backups/main_game.before-T01-T06.20261106.rbxl` (88.600 byte), hash cocok dengan file awal sebelum mutasi. MCP juga membuat cadangan objek awal dalam ServerStorage. Lima script modular terpasang dan cocok dengan sumber lokal; beberapa sesi Play membuka place dan bootstrap tanpa error baru. Place akhir tersimpan lokal; bukti hash di handoff dan `verification/save-status.json`.

## Milestone 1 — Satu pengantaran yang bisa dimainkan

- [x] **T03 — Membuat map percobaan.** Acuan: REQ-01, 03, 08. Dependensi: T02. Spawn, depot, Rumah Bu Sari, jalan aman U, papan 3 stud, dan titik pemulihan tersedia. Depot memiliki lorong belakang. Perjalanan pulang-pergi memakai Humanoid:MoveTo melewati 14 waypoint, seluruhnya tercapai tanpa teleport selama rute. Bukti: `verification/walk-checks.json`.
- [x] **T04 — Membuat state pesanan di server.** Acuan: REQ-01, 03, 06, 12. Dependensi: T03. ID unik, pemilik, tujuan, state, dan kunci penyelesaian internal terpasang. Pesanan kedua, tujuan palsu, start/pickup/penyelesaian jauh, ID lama, argumen salah, dan aksi Deliver ditolak. Kunci internal hanya bisa diperoleh sekali; hadiah belum diimplementasi. Bukti: `verification/server-checks.json` (28/28).
- [x] **T05 — Membuat ambil, bawa, lepas, dan ambil ulang paket.** Acuan: REQ-02, 10, 12. Dependensi: T04. E/Q/E diuji lewat input keyboard MCP; paket lepas memiliki network owner server. Selama rute, deviasi posisi relatif bawa teramati 0 stud. Identitas asing ditolak pada batas service; ini simulasi identitas, belum dua klien nyata. Bukti: `verification/keyboard-checks.json`, `walk-checks.json`, dan `server-checks.json`.
- [x] **T06 — Membuat jatuh dan pemulihan.** Acuan: REQ-04, 05, 12. Dependensi: T05. Ambang direvisi 24→55 setelah percobaan; jatuh 12 stud dan jatuh saat membawa menghasilkan kerusakan 10, jatuh ringan sampai 6 stud tidak rusak. Cooldown kerusakan/pemulihan, kondisi 0, dan batas dunia diuji. Jatuh nyata di samping papan → Dropped/OOB → R mengembalikan pemain/paket → berjalan dan ambil ulang, ID tetap dan kondisi 80. Bukti: `verification/physics-checks.json`, `fall-recovery-checks.json`, dan `server-checks.json`.
- [x] **T07 — Membuat pengantaran dan hadiah sementara.** Acuan: REQ-03, 06, 12. Dependensi: T06. EconomyService menyimpan saldo sesi; server memeriksa pemilik/status/tujuan serta jarak pemain dan paket, mengunci pesanan sebelum kredit, dan menolak replay. Formula dan kondisi 0 diuji; tiga perjalanan nyata memberi 47/40/46 koin sesuai durasi dan kondisi server. Bukti: `verification/stage2-server-checks.json` (43/43) dan `stage2-journey-checks.json`.
- [x] **T08 — Membuat HUD dan kontrol komputer/sentuh.** Acuan: REQ-11. Dependensi: T07. HUD menampilkan tujuan, kondisi/bar, saldo, petunjuk, dan rincian hasil; E/Q/R serta tombol kontekstual berbagi validasi server. Desktop dan emulator iPhone 17 Pro lulus; satu siklus lengkap dengan joystick dan tombol merekam 8 awal sentuhan, 0 keyboard. Galaxy A06 juga diperiksa untuk layout aktif. Bukti: `stage2-touch-cycle.json`, `stage2-desktop-layout.json`, `stage2-iphone17pro-*-layout.json`, `stage2-galaxy-a06-layout.json`. HP asli belum diuji; orientasi prototipe landscape.
- [x] **T09 — Memeriksa reset, keluar, dan pergantian pesanan.** Acuan: REQ-04, 10, 12. Dependensi: T08. Kematian saat Carrying dan pergantian karakter saat Dropped membersihkan paket/koneksi tanpa hadiah, menjaga saldo, dan membolehkan ID pesanan baru. PlayerRemoving nyata lewat Kick lokal menghapus pesanan, cache, koneksi, sesi; saldo 43 tidak bertambah sebelum dibuang. Sesi baru Idle/0 dan hanya satu HUD. Bukti: `stage2-server-checks.json`, `stage2-exit-checks.json`, `stage2-fresh-session.json`.
- [x] **T10 — Playtest prototipe bersama pemilik.** Acuan: REQ-01–06, 11. Dependensi: T09. Pada 7 November 2026 pemilik menyatakan “sudah mencoba bisa lanjukan 11-15”, menggantikan jawaban sebelumnya “belum mencoba”. Ini penerimaan pemilik untuk melanjutkan; tidak ada bug penghalang yang dilaporkan. Perangkat, hitungan putaran dan rincian hasil pribadi tidak diberikan, sehingga tidak diklaim sebagai bukti HP asli atau tiga putaran pemilik. Bukti teknis tiga putaran/reset/pemulihan tetap pada laporan tahap kedua.

## Milestone 2 — Konten MVP

- [x] **T11 — Memperluas kampung menjadi lima tujuan.** Acuan: REQ-08. Dependensi: T10. Rumah Bu Sari, Pak Budi, Bu Rina, Pak Agus dan Bu Dewi mempunyai warna/nama/landmark berbeda. Lima jalan aman ditempuh dengan MoveTo tanpa paket rusak; papan pintas Bu Sari dan pintasan licin Pak Budi juga selesai diantar. Bukti: `verification/stage3-walk-checks.json` (7 lintasan), `stage3-studio-manifest.json` (5 tujuan).
- [x] **T12 — Menambahkan genangan dan penghalang bergerak.** Acuan: REQ-04, 08. Dependensi: T11. Genangan bersampel server, penghalang sinus dengan volume sapuan, dorongan/selip planar dan jalan memutar tersedia. Dua tipe paket diuji pada genangan, penghalang, dan gagal di samping papan; pemulihan mempertahankan ID/waktu serta membersihkan efek. Bukti: `stage3-physics-checks.json` (40/40), `stage3-slide-release-checks.json`, dan lintasan pintasan licin yang berhasil ambil ulang dua kali.
- [x] **T13 — Menambahkan paket rapuh dan keseimbangan awal.** Acuan: REQ-05, 06. Dependensi: T12. Biasa/Rapuh berlabel dan berwarna berbeda; damage 10/20, kondisi clamp 0–100, kondisi 0 tetap dibayar dasar. Target per rute 45/45/35/60/60 detik, formula tetap 25 + bonus kondisi 15 + bonus waktu 10. Sepuluh pasangan, formula, replay, cooldown dan target rute diuji. Bukti: `stage3-server-checks.json` (138/138), `stage3-physics-checks.json`, `stage3-walk-checks.json`. Angka ini keseimbangan awal, bukan validasi rasa bermain lima rumah oleh pemilik.
- [x] **T14 — Membuat rekor pribadi dan ringkasan hasil.** Acuan: REQ-06, 07. Dependensi: T13. Rekor sesi per tujuan|tipe hanya diperbarui durasi lebih cepat tanpa pemulihan. Kasus pertama/lebih cepat/lambat/seri/pulih, snapshots, reset dan penghapusan sesi diuji. HUD menampilkan komponen hadiah, rekor baru/terbaik atau alasan tidak layak. Bukti: `stage3-server-checks.json`, `stage3-eligible-presentation.json`, `stage3-recovered-presentation.json`, serta layout desktop/phone.
- [x] **T15 — Menambahkan visual dan audio minimum.** Acuan: REQ-08, 11. Dependensi: T13. Dekor kampung dan landmark memakai primitive buatan proyek, penanda tujuan/depot berbasis teks, flash kondisi, dan tiga cue bawaan Roblox. Sumber/pemakaian tercatat di `asset_sources.md`. Cue dimuat dan Play/Ended teramati; HUD baru muat pada desktop/iPhone emulator, aksi paket Rapuh memakai 4 Touch/0 Keyboard. Bukti: `stage3-audio-checks.json`, `stage3-phone-*.json`, `stage3-touch-actions.json`, `stage3-depot-marker.json`. Kenyamanan suara/gerak HP asli belum diperiksa.

## Milestone 3 — Progres dan keamanan

- [x] **T16 — Menyiapkan skema profil dan DataStore uji.** Acuan: REQ-07, 12. Dependensi: T14. Skema/envelope v1, default dan migrasi v0 tervalidasi. Skill rbx-permissions dibaca sebelum akses; setelah pemilik mengaktifkan izin, baca/UpdateAsync namespace `PaketKilat_TEST_v1` / `T16_T20_QA` berhasil pada universe uji 10775037187. Tidak menyentuh data publik. Bukti: `stage4-permissions.json`, `stage4-cloud-adapter.json`, `stage4-profile-checks.json` (59/59 termasuk ekonomi).
- [x] **T17 — Menambahkan load/save dan perlindungan sesi.** Acuan: REQ-07. Dependensi: T16. UpdateAsync + lease token120 detik, autosave30, retry/backoff3, dirty/revision, keluar dan BindToClose25 detik. Gagal muat/versi rusak tidak disimpan sebagai default; lease asing/expired menolak mutasi. Saldo/count/rekor/kepemilikan/equip benar-benar dimuat pada sesi Studio berbeda. Autosave serta perubahan terakhir sebelum penutupan terverifikasi pada masuk ulang. Bukti: `stage4-profile-checks.json`, `stage4-cross-session.json` (18/18), `stage4-autosave-close.json` (17/17), `stage4-close-reload.json` (14/14). Kegagalan jaringan/konflik disuntikkan lewat adapter; bukan outage layanan Roblox yang disengaja.
- [x] **T18 — Membuat toko kosmetik menggunakan koin.** Acuan: REQ-09, 12. Dependensi: T17. Empat tas primitive, harga0/50/75/100; beli/pakai dekat depot, tanpa keuntungan kecepatan. Pembelian/saldo kurang/duplikat/equip tak dimiliki/reset diuji server; kepemilikan dan equip bertahan lintas sesi. Tombol HUD desktop membeli/memakai tas merah, saldo147→97; layout iPhone muat. Bukti: `stage4-two-clients.json`, `stage4-eight-clients.json`, `stage4-desktop-store.json`, `stage4-phone-layout.json`. Input toko emulator bercampur; bukan kelulusan sentuh murni/HP asli.
- [x] **T19 — Meninjau permintaan klien dan ekonomi.** Acuan: REQ-06, 09, 12. Dependensi: T18. Allowlist, tipe/panjang/arity, identitas/pemilik, profil siap, jarak, saldo/katalog dan throttle server. Tujuan palsu/jauh, ID asing, replay, duplikat, payload tabel/boolean/argumen keempat ditolak. Spam dispatcher50 menghasilkan49 RateLimited; spam nyata100 lewat RemoteEvent tidak menambah/mengurangi saldo, tanpa error tak tertangani. Bukti: `stage4-two-clients.json`, `stage4-eight-clients.json`, `stage4-autosave-close.json` (wireResult). Ini bukan antieksploit teleport/gerak penuh.
- [x] **T20 — Menguji multipemain dan pembersihan resource.** Acuan: REQ-10, 12. Dependensi: T19. StudioTestService benar-benar menjalankan 2 lalu8 klien (handshake dan Player.UserId berbeda). 65/65 dan107/107 lulus: paket/ID/hadiah privat, tabrakan kelompok dinonaktifkan, reset membersihkan pesanan, tas tunggal muncul ulang, Kick/PlayerRemoving membersihkan binding/request/order/paket/ekonomi/profil dan lease, seluruh paket dibersihkan. Bukti: `stage4-two-clients.json`, `stage4-eight-clients.json`, `stage4-studio-manifest.json`. Delapan adalah klien simulasi Studio pada satu komputer, bukan8 pemain manusia/perangkat/ukuran FPS. Riwayat percobaan awal gagal dipertahankan; T21 belum dikerjakan.

## Milestone 4 — Validasi sebelum rilis

- [x] **T21 — Menambahkan petunjuk awal dan kejadian analitik.** Acuan: REQ-11, 13. Dependensi: T20. Audit bukti T01–T20 dan13 sumber awal cocok; regresi2 klien73/73, telemetri injeksi33/33. Petunjuk state resmi, Help/Close dan diagnostik FPS manual tersedia. Hook mulai/ambil pertama/pulih/antar/akhir sesi plus pesanan kedua hanya server; lima penyerahan sah→lima event, replay tidak ganda, jurnal tanpa identitas/chat/secret. Skill/izin AnalyticsService ditinjau sebelum implementasi; Studio LocalOnly, sink live hanya universe uji. Bukti: stage5-dependency-audit.json, stage5-telemetry-checks.json, stage5-regression.json, stage5-guide-phases.json, analytics_plan.md. Pengiriman dashboard live belum diuji; bukan klaim analitik cloud diterima.
- [ ] **T22 — Menguji HP asli dan performa.** Acuan: REQ-08, 11. Dependensi: T15, T21. Pelaksana: pemilik + asisten. Alat FPS60 detik, protokol perangkat/kontrol/reset/rintangan dan test_report.md siap. Sampel desktop Studio60,01 detik: median59,99/min59,83,59 jendela sampel,0 frame>100ms; hanya diam di depot. Layout iPhone emulator muat, bukan HP asli. Pemilik menjawab “belum ada akses build HP”; belum ada hasil fisik untuk target30 FPS atau kenyamanan. Tetap TERBUKA sampai build cocok dan bukti perangkat tersedia.
- [ ] **T23 — Mengadakan uji 10–20 pemain.** Acuan: REQ-01, 03, 11, 13. Dependensi: T22. Pelaksana: pemilik merekrut, asisten evaluasi. test_report.md menyiapkan20 baris anonim, skrip undangan/instruksi netral, jendela10 menit, bantuan/timeout/keluar, pesanan kedua dan alasan berhenti. Gelombang≤8; jumlah manusia sebenarnya0. Sasaran8/10 pertama belum dapat dihitung. Akses build dan T22 belum tersedia; jangan menganggap klien Studio sebagai tester manusia. Tetap TERBUKA.
- [ ] **T24 — Memperbaiki hasil uji dan audit penerimaan.** Acuan: REQ-01–13. Dependensi: T23. Lulus: setiap kebutuhan memiliki bukti; tidak ada bug penggandaan uang, kehilangan progres yang diketahui tanpa penanganan, atau pengantaran buntu. Perubahan diuji ulang pada skenario terkait.
- [ ] **T25 — Menyiapkan paket rilis untuk ditinjau pemilik.** Dependensi: T24. Siapkan nama/deskripsi, ikon/thumbnail, daftar aset, konfigurasi akses, dan catatan keterbatasan. Lulus: hasil siap diperiksa. Publikasi dan pengeluaran diputuskan pemilik; tugas ini sendiri tidak mengizinkan publikasi atau belanja.

## Backlog setelah MVP tervalidasi

- [ ] **B01 — Mengevaluasi kosmetik berbayar.** Setelah T24 dan bukti minat pemain. Spesifikasikan produk/harga bersama pemilik; validasi pembelian server dan pemrosesan ulang transaksi sebelum rilis monetisasi.
- [ ] **B02 — Menambahkan tantangan bergilir.** Tetapkan aturan dan hadiah dalam desain terlebih dahulu.
- [ ] **B03 — Mencoba paket besar atau ekspres.** Uji satu jenis baru sebelum menambah keduanya.
- [ ] **B04 — Mencoba pengantaran berdua.** Hanya setelah permainan solo dan sinkronisasi multipemain stabil.
- [ ] **B05 — Mengevaluasi distribusi dan pendapatan.** Tinjau pemain kembali, feedback, biaya, serta kelayakan DevEx saat relevan. Anggaran promosi memerlukan keputusan pemilik.

## Log verifikasi

| Tanggal | Tugas | Bukti / hasil | Keterbatasan |
| --- | --- | --- | --- |
| 2026-11-06 | T00 | Dua dokumen dibuat dan diperiksa keterkaitan kebutuhan/tugasnya. | SDK kit khusus belum tersedia; Studio dan gameplay belum diperiksa atau diubah. |
| 2026-11-06 | T01–T02 | Inspeksi Edit; cadangan penuh sebelum mutasi; struktur modular melalui MCP. Bootstrap berjalan pada Play. Audit akhir: lima script sesuai sumber, 16 bagian map, nol paket aktif atau Script uji di Edit; objek awal dipertahankan, spawn awal di `Workspace/OriginalContent`. | Output awal berisi error historis script UnGroup yang sudah tidak ada. File akhir tidak ditutup dan dibuka ulang; beberapa sesi Play berhasil pada place yang terbuka. |
| 2026-11-06 | T03, T05 | Satu klien Play, Humanoid:MoveTo pulang-pergi 14 waypoint; paket tetap Carrying/100, maxCarryError 0. E ambil, Q lepas, E ambil ulang, Q/R pulih, E ambil ulang lulus. | Satu klien komputer; sentuh dan dua klien nyata belum diuji. |
| 2026-11-06 | T04–T06 | Script server sementara: 28/28 pemeriksaan lulus. Penguncian penyelesaian hanya kontrak internal; aksi penyerahan tidak tersedia. Seluruh Script uji sementara hilang saat Stop. | Penolakan pemilik lain memakai identitas simulasi pada service. REQ-10 penuh tetap menunggu T20. |
| 2026-11-06 | T06 | Sampel fisika nyata pada ambang 55: tinggi 0,1/1/2/6 → kondisi 100, tinggi 12 → 90; jatuh membawa → Dropped/90. Batas relatif arena dan pemulihan pemain jatuh ditambahkan setelah desain diperbarui. Jatuh nyata → pulih → ambil ulang lulus. | Ini ambang prototipe; variasi avatar, jaringan, perangkat sentuh dan HP asli belum diuji. Uji awal gagal disimpan dalam `initial-trials.json` sebagai riwayat, bukan kelulusan. |
| 2026-11-06 | Penyimpanan | Studio Edit, Ctrl+S ke jendela file lokal yang sudah diverifikasi; `main_game.rbxl` menjadi 107.594 byte, SHA-256 berubah, cadangan awal tetap utuh. | Tidak dipublikasikan; tidak ada pembelian/monetisasi. Detail status di `handoff.md`. |

| 2026-11-07 | Inspeksi / cadangan tahap 2 | Implementasi aktual melalui MCP cocok dengan lima sumber tahap pertama. Arena aktual Y=1045 dipertahankan. Cadangan penuh `backups/main_game.before-T07-T10.20261107.rbxl`, SHA-256 427ABCA…B089; cadangan script/template melalui MCP di ServerStorage. | Handoff lama mencatat Y=196; catatan itu dipertahankan sebagai riwayat. |
| 2026-11-07 | T07 | Server Script sementara: 43/43 lulus, termasuk tujuan palsu, jarak pemain/paket, payload hadiah, replay segera/tertunda/saat pesanan baru, formula 40/42/25 dan maksimum 50, kondisi 0, serta pemulihan yang tetap memakai waktu awal. | Fixture formula memakai waktu server yang diatur oleh harness internal; klien produksi tidak dapat mengaturnya. Uji awal pada batas pembulatan 45 detik diperbaiki menjadi 44 detik dan diulang. |
| 2026-11-07 | T07–T08 | Tiga perjalanan memakai Humanoid:MoveTo dan input E/Q/R aktual; hadiah 47/40/46, saldo 144→277, kondisi 100/80/100; putaran kedua memuat lepas, ambil ulang, jatuh nyata dan pulih. Deviasi carry maksimal sekitar 0,00000763 stud. | Saldo awal 144 berasal dari harness server sebelumnya; sesi baru diperiksa terpisah pada 0. Setup awal dan setup jatuh memakai PivotTo. |
| 2026-11-07 | T08 | iPhone 17 Pro emulator: ambil/lepas/ambil ulang/pulih/ambil ulang, joystick melintasi papan, antar; 8 awal Touch, 0 Keyboard, hadiah 43, lulus. HUD aktif dan hasil muat. Galaxy A06 emulator: layout aktif dan teks muat, tombol aksi tidak menutup lompat. | Kamera uji sentuh diarahkan tetap untuk rute joystick; kenyamanan kamera/gerak pemilik belum dinilai. Percobaan dengan input campuran tidak dipakai sebagai kelulusan. Bukan uji HP asli atau performa. |
| 2026-11-07 | T09 | Reset Carrying dan Dropped lulus; koneksi tidak menumpuk. Keluar aktual satu klien membersihkan semua resource/cache tanpa uang tambahan. Play baru Idle/0, satu HUD, bootstrap tanpa error. | Bukan pengujian dua pemain; T20 tetap terbuka. |
| 2026-11-07 | Simpan / T10 | Tujuh script cocok sumber lokal; nol paket aktif/Script uji di Edit. File > Save to File melalui UIAutomation berhasil: 122.320 byte, 2026-11-07 00:31:03 WIB, SHA-256 5A1B0C…8276. Emulator kembali default, Studio Edit. T10 menunggu hasil pemilik. | Ctrl+S awal tidak menulis perubahan; tidak dicatat berhasil. File akhir belum ditutup/dibuka ulang. Tidak ada publikasi atau pembelian. |

| 2026-11-07 | T10 | Pemilik menyatakan “sudah mencoba bisa lanjukan 11-15”; penerimaan untuk perluasan dicatat dalam `verification/t10-owner-acceptance.json`. | Perangkat dan rincian putaran pemilik tidak diberikan; tidak diklaim sebagai HP asli atau rincian uji baru. |
| 2026-11-07 | Cadangan / inspeksi T11–T15 | Studio sempat tertutup, dibuka lagi pada file lokal; koneksi MCP baru terverifikasi. Delapan sumber akhir cocok, objek awal dipertahankan. Cadangan penuh sebelum mutasi `backups/main_game.before-T11-T15.20261107.rbxl` (122.320 byte), SHA-256 5A1B0C…8276; salinan map/script/UI melalui MCP di ServerStorage. | Arsip handoff T07–T10 dan inspeksi sebelum mutasi dipertahankan. |
| 2026-11-07 | T11–T13 | Lima rute aman dan dua pintasan selesai. Waktu jalan aman sekitar 11,90 / 11,85 / 14,62 / 20,88 / 17,80 detik. Papan 6,31 detik; pintasan licin 9,20 detik, dua kali lepas/ambil ulang, kondisi 80 dan hadiah 44. | Setup posisi di antara percobaan memakai PivotTo; selama rute memakai MoveTo tanpa teleport. Bukan pengukuran pemain manusia atau uji pulang-pergi semua rumah. |
| 2026-11-07 | T12–T14 | 138 pemeriksaan state/hadiah/rekor dan 40 pemeriksaan fisik lulus. Selip tanpa input masih memindahkan pemain; efek habis/reset/pulih dibersihkan. Hard landing memberi 10/20, gagal papan bisa pulih. | Harness awal gagal menggerakkan/menyiapkan jatuh karakter; tidak dihitung lulus. Driver klien dan persiapan jatuh diperbaiki, deteksi kontak memakai assembly+perpindahan server+raycast, lalu uji akhir diulang. |
| 2026-11-07 | T14–T15 | Ringkasan eligible dan dipulihkan diperiksa pada iPhone 17 Pro emulator: rekor 22,42 detik tidak diganti perjalanan pulih 5,42 detik. Teks muat; empat sentuhan tanpa keyboard menguji paket rapuh ambil/lepas/pulih/ambil ulang. Tiga cue audio Loaded dan Ended, rekor/koin bersih pada sesi baru. | Fixture presentasi mengatur waktu di server untuk menampilkan kedua keadaan UI. HP asli, FPS, jaringan lambat, multipemain dan penilaian pendengaran belum diuji. |
| 2026-11-07 | Simpan akhir T15 | File > Save to File terverifikasi: 132.975 byte, 2026-11-07 01:48:43 WIB, SHA-256 C0A907…BE4A. Edit, simulator default, 5 tujuan/89 Part, 8 script cocok sumber, nol paket aktif/Script uji. | Tidak dipublikasikan atau dibeli; file akhir belum ditutup/dibuka ulang. T16 belum dikerjakan. |

| 2026-11-07 | T16–T17 | Izin MCP awal ditolak502; setelah pemilik mengaktifkan, read/write pada universe uji10775037187 berhasil. 59 pemeriksaan profil/ekonomi injeksi lulus. DataStore riil, lease, autosave dan lintas sesi diuji (18/17/14 pemeriksaan). | Tidak mempublikasikan place. Retry/failure memakai adapter injeksi; tidak menjanjikan penyimpanan tanpa kehilangan saat crash. |
| 2026-11-07 | T18–T20 | Dua klien65/65; delapan klien107/107. Pembelian/equip, saldo kurang, replay, spam, reset dan keluar lulus; saldo/count/rekor/tas dimuat kembali pada sesi berbeda. Desktop membeli/memakai tas merah147→97. Layout toko emulator750×323 muat. | Teleport setup harness mengacaukan sampel benturan pada percobaan awal; fixture diperbaiki. Race snapshot HUD awal diperbaiki dengan Sync ulang saat memuat. Input toko mobile bercampur dan SendTouchEvent dibatasi capability; tidak diklaim lulus sentuh murni/HP asli. |
| 2026-11-07 | Simpan T20 | File > Download a Copy dari place uji ke main_game.rbxl:142.107 byte,07:34:27 WIB, SHA-256 7AF5E4…873BFAF.13 sumber cocok,0 paket/QA aktif di Edit, simulator default. | Tidak memakai Save to Roblox/Publish dan tidak mengeluarkan biaya. Rincian penyimpanan/reopen di handoff. |

| 2026-11-07 | Dependensi T01–T20 / cadangan T21 | 13 sumber aktual cocok hash sumber sebelum edit; bukti final28/43/138/40/59/18/107 pemeriksaan ditinjau, termasuk siklus/rute/sentuh/reset/keluar serta penerimaan T10. Cadangan lengkap142.107 byte dan scoped PreStage5 dibuat sebelum mutasi. | Ini audit bukti sebelumnya ditambah regresi2 klien baru; bukan pengulangan semua tes atau HP asli. |
| 2026-11-07 | T21 | Telemetri33/33 dan regresi73/73 lulus.2 klien StudioMemory,5 completions/5 event,2 awal/ambil pertama,1 recovery,2 second order,1 leave. Guide Carrying/Dropped/Recover/ReturnDepot/Complete muat pada iPhone emulator. | Salah ekspektasi fixture second-order1 diperbaiki menjadi2 (masing-masing klien memang memulai); percobaan awal tidak dihitung lulus. Sink injeksi/LocalOnly, dashboard live belum terverifikasi. |
| 2026-11-07 | Persiapan T22/T23 | Pengukur FPS manual60 detik dan laporan/protokol/rekrutmen anonim siap. Pemilik: “belum ada akses build HP”. Hasil desktop Studio terpisah dari HP/manusia. | T22/T23 belum selesai;0 tester manusia, belum ada perangkat/fps fisik. Tidak mempublikasikan untuk membuka akses. |
| 2026-11-07 | Simpan T21 | Pemilik mengonfirmasi Save to File setelah otomatisasi menu tidak merespons revisi terakhir. File149.380 byte,08:19:50 WIB, SHA2566EA58E…81423B. | Hash simpan antara149.349 byte bukan versi final; status buka ulang akhir dicatat di handoff/verifikasi. |

## Langkah berikutnya

Berhenti dalam lingkup T21–T23: T21 implementasi teknis selesai, T22/T23 menunggu **akses build HP yang cocok** dan hasil pemilik/manusia. Simpan final dibuka ulang:16 sumber cocok, backup ada,0 QA/paket; Play Ready/0 koin dengan guide awal muat dan FPS otomatis tersembunyi; kembali Edit (`stage5-reopen.json`). Gunakan [test_report.md](test_report.md) untuk urutan tes dan20 baris anonim. File lokal bisa Play, tetapi tidak otomatis tersedia pada HP dan tidak membuktikan pengiriman analitik live. Tidak menjalankan T24/T25, publikasi atau pengeluaran. Setelah hasil ada, evaluasi angka FPS, masalah kontrol,8/10 pertama, pesanan kedua dan alasan berhenti; jangan mengisi hasil yang belum tersedia.

## Perbaikan kualitas sebelum deploy — Polish01

- [x] P01-A: cadangan file dan scoped backup live; inspeksi posisi map aktual Y5568.
- [x] P01-B: poles depot/Rumah01, material jalan, papan jarak dekat, fondasi dan kanal dekoratif.
- [x] P01-C: verifikasi90 geometri awal tetap;133 dekorasi noncollision, nol script dekorasi; satu pengantaran otomatis42 koin dan penolakan replay.
- [x] P01-D: simpan sumber migrasi, ekspor geometri, screenshot dan bukti di folder proyek.
- [ ] P01-E: simpan place Studio ke main_game.rbxl dan verifikasi file disk berubah (belum terkonfirmasi).
- [ ] P01-F: penilaian visual dan rasa bermain oleh pemilik; bukan uji HP/T22.

Perubahan visual tidak menyelesaikan T22/T23 atau mengizinkan deploy. Detail di handoff.md; bukti verification/polish01-audit.json.

## Perbaikan kualitas — Polish02

- [x] P02-A: backup template/input/UI live dan sumber input lokal.
- [x] P02-B: pita/label kardus berbasis SurfaceGui; collider asli tetap.
- [x] P02-C: penanda jarak dan paket jatuh, highlight, notifikasi, panel hasil dari snapshot server.
- [x] P02-D: drop/pickup/recover/reset/Rapuh/replay dan satu pengantaran47 koin; teks hasil muat750×323 iPhone emulator; panel tunggal dan auto-hide.
- [x] P02-E: source, installer pemulihan, screenshot dan audit tersimpan; Studio Edit/viewport default.
- [ ] P02-F: konfirmasi simpan place lokal P01/P02; file disk masih versi149380 byte.
- [ ] P02-G: uji rasa bermain oleh pemilik dan HP fisik (tidak disamakan dengan emulator).

## Perbaikan kualitas — Polish03: jalan depan dan arsitektur

- [x] P03-A: inspeksi, cadangan disk195057 byte dan scoped world live.
- [x] P03-B: pindah jalan belakang baris pertama ke depanZ28; susun jalan depan baris keduaZ144, teras, spine dan trotoar.
- [x] P03-C: bangun ulang6 atap simetris/gable tertutup; koreksi depot rusak dan trim rumah02–05.
- [x] P03-D: uji5 pengantaran melalui jalan depan, kondisi100; bypass03–05 dan replay04/05; anchor tujuan tetap.
- [x] P03-E: migrasi, screenshot, audit, dan handoff tersimpan. Studio kembali Edit/HUD aktif/0 paket.
- [ ] P03-F: simpan place lokal revisiP03 dan konfirmasi dari file disk.
- [ ] P03-G: evaluasi pemilik tentang susunan jalan depan dan bentuk rumah.

## Polish04 — sesi pemilik, lantai, pohon

- [x] P04-A: temukan dua sesi/P02 vs P03; pindahkan pekerjaan ke sesi pemilik4b3a852b dengan backup dan pemasanganP03.
- [x] P04-B: ubin depot, lantai beton,5 pohon pada halaman aktual dengan dukungan fondasi; audit dukungan lulus.
- [x] P04-C: streaming guard pada feedback; fixture pickup/drop/pickup/deliver100/48 lulus.
- [x] P04-D: sumber/audit/screenshot tersimpan; Edit/HUD aktif/0 paket.
- [ ] P04-E: simpan main_game.rbxl dari sesi pemilik dan verifikasi disk; jangan simpan sesi lama.
- [x] P04-F: ditutup oleh P05; lima rute aktual berjalan via MoveTo, kondisi100 dan replay ditolak. Bukti polish05-audit.json.


## Polish05 — akses halaman, fondasi, detail jalan

- [x] P05-A: backup file/live; inspeksi posisi rumah aktual pada sesi pemilik.
- [x] P05-B: selaraskan5 akses halaman,23 fondasi mencapai dasar kanal, tepi jalan tidak menutup junction.
- [x] P05-C: paving pintu/teras, papan alamat dan kotak pos di halaman yang didukung.
- [x] P05-D:5 rute berjalan/kondisi100/hadiah47,47,45,45,46; replay semua ditolak; anchor tujuan tetap; console hanya bootstrap.
- [x] P05-E: source, screenshot/audit/handoff tersimpan; Studio Edit/HUD aktif/0 paket.
- [ ] P05-F: simpan .rbxl revisiP05 dari sesi pemilik; belum terkonfirmasi.
- [ ] P05-G: penilaian kenyamanan manusia/HP fisik; tidak digantikan tes otomatis.

## Polish06 — HUD dan penunjuk arah

- [x] P06-A: backup input/feedback/GUI/world dan file lokal.
- [x] P06-B: HUD desktop320x132/HP280x132, status22, guide52/66; warna dan teks lebih ringkas.
- [x] P06-C: hasil menyembunyikan kartu/status sementara, nextOrder tampil, expiry/reset mengembalikan HUD.
- [x] P06-D: tiga papan arah berdiri pada trotoar/bypass; tidak memblokir jalan.
- [x] P06-E: emulatorlayout/desktopmanualHelp, keyboardtoko, drop/recover/pickup/jalan/antar80/44, replay dan reset diperiksa; batas input sentuh tercatat.
- [x] P06-F: source/audit/screenshot/handoff tersimpan; Studio Edit dan simulator default.
- [ ] P06-G: simpan .rbxl dari sesi pemilik serta verifikasi disk; belum terkonfirmasi.
- [ ] P06-H: uji touch/HP fisik dan penilaian pemilik.

## Polish07 — aset gratis Creator Store

- [x] P07-A: backup file/world dan pencarian Creator Store free.
- [x] P07-B: audit5kandidat; tolak paket berisi6script/GUI/kamera, pilih3aset tanpa script.
- [x] P07-C:5pohon baru, bangku dan3pagar depot;19mesh statis/0script/0collision; preview/review dihapus.
- [x] P07-D:5meshId preloadSuccess,9model bertumpu lantai, anchor tetap; uji1pengantaran100/47 dan replay ditolak.
- [x] P07-E: source, identitas/link aset, screenshot dan audit disimpan; StudioEdit/HUDaktif/0paket.
- [ ] P07-F: simpan revisi .rbxl dari sesi pemilik dan verifikasi disk.
- [ ] P07-G: penilaian visual pemilik serta uji performa/HP sebelum memperluas pemakaian aset.

## Polish08 — rute aman dan startup

- [x] P08-A: inspeksi sesi baru/origin4477, backup file/world/input/GUI/hazard.
- [x] P08-B:5polyline relatifdepot,16titiklokal dan tombolG/Rute; jalurbalik sesudahantar.
- [x] P08-C: perbaiki Bootstrap terhenti karena Puddle hilang; genanganopsional tanpa memulihkan objekhapus.
- [x] P08-D:683sampellantaijalan, toggle/toko/drop/pickup/return, fixture100/40/replay, resetIdle/titik0/folder1.
- [x] P08-E: layoutemulator750x323/tombol84x44/TextFits; source/audit/screenshot disimpan; StudioEdit/viewportdefault.
- [ ] P08-F: simpan .rbxl revisiP08 dan verifikasidisk.
- [ ] P08-G: ujimanusia/HPsentuh dan perjalananberjalan penuh pada mapterbaru; ujiotomatisawal terhenti.

## Polish09 dipulihkan / Polish10 — lebih banyak aset gratis

- [x] P10-A: inspeksireopen; P09hilang, versi rumahpemilik dibackup tanpa restorasiworldlama.
- [x] P10-B: cekulangfree/audit lampu/semak/batu dan pasang42part noncollision/0script.
- [x] P10-C: kardusgratis12084344112,4copy, buangkameraasal; total46part baru/0script/0camera.
- [x] P10-D: sesuaikanrute dengan bypasshapus dan gapspine;599sampel/0tanpalantai, rumah/anchor tetap.
- [x] P10-E: fixturepickup/drop/pickup/deliver100/48/replay/returnguide lulus; tesjalanotomatis tidaklulus dantercatat.
- [x] P10-F: source/audit/screenshot/sourceasset disimpan. Filebinary membuktikanasetP09/P10 sudahada di .rbxl.
- [ ] P10-G: saveulang routefinal CurrentStreets10 ke .rbxl; marker belumada pada file304601byte yang diperiksa.
- [ ] P10-H: tesjalanmanusia/HP pada layoutterbaru; bukan diganti fixtureatau raycast.

## Mechanics11 — sprint/stamina/genggaman

- [x] M11-A: backup perchild/server/GUI dan spesifikasi; skillconfigdibaca.
- [x] M11-B: servermeter/speed/intentboolean+lease/rate; snapshotmovement tanpa skemaprofilbaru.
- [x] M11-C: Shift/toggleHP, meter, warning/cueGripLost, focus/toko/resetrelease.
- [x] M11-D:22,4→16; stamina0/pulih; commonmin74; rapuhGripLost1/kondisi80; pickup/delivery80/37/replay.
- [x] M11-E: payloadinvalid/spam/lease, shop/textfocus, respawn100/speed16/panel1; emulatorlayout750x323; startupRacefix.
- [x] M11-F: source/bukti/screenshot/handoffdisimpan; StudioEdit/viewportdefault/0paket.
- [ ] M11-G: simpan .rbxl mekanikSprintGrip11 (marker belumada di file304601byte).
- [ ] M11-H: teskenyamananmanusia/HPsentuh/multiplayer dan penyesuaianbalance.

## UI12 — perombakan tampilan HUD dan toko

- [x] UI12-A: inspeksi UI aktif, backup place/source/GUI, dan tulis spesifikasi di design.md.
- [x] UI12-B: tema krem, hijau gelap, dan kuning; kartu tujuan, badge saldo, toolbar, tombol aksi, meter, serta petunjuk konsisten.
- [x] UI12-C: toko dengan latar redup dan HUD tersembunyi; panel hadiah serta notifikasi mengikuti tema.
- [x] UI12-D: periksa desktop 1350x863 dan emulator landscape 750x323; teks yang diperiksa muat, tombol toolbar/sprint 84x44.
- [x] UI12-E: klik toko/buka/tutup dan petunjuk di desktop; fixture Start/Drop/Pickup/Deliver dengan hadiah +41; panel hasil terbaca dan console tanpa error runtime.
- [x] UI12-F: sinkronkan 5 source, simpan screenshot/audit/handoff; akhir Studio Edit, device default, HUD aktif, 0 paket.
- [ ] UI12-G: simpan sesi Studio ke main_game.rbxl; marker CourierUI12/UITheme12 belum ada pada file disk yang diperiksa.
- [ ] UI12-H: penilaian pemilik dan uji sentuh pada HP fisik; emulator serta input remote fixture belum menggantikan uji ini.

## City13 — pilihan rute dan kota bertingkat

- [x] C13-A: inspeksi/backup sesi terbaru, source, serta file place sebelum mutasi.
- [x] C13-B: lima pos bonus server, dua cap berbeda per pesanan, enam koin per cap, kredit hanya saat pengantaran.
- [x] C13-C: snapshot/HUD/cap lokal/rincian hadiah; tuning melalui adapter ConfigService yang ada.
- [x] C13-D: blok kota, lima fasad bertingkat, tiga kios, plaza/jam/planter, jembatan dan ramp tanpa perubahan Terrain/posisi rumah.
- [x] C13-E: fixture 0→1→2 cap, duplicate/pos ketiga tetap2, saldo0 sebelum antar; pembayaran54 termasuk bonus12, replay tidak menambah saldo.
- [x] C13-F: sampel lantai ramp tersambung; emulator750x323 teks bonus/hasil muat, cap lokal berubah; startup final tanpa error runtime.
- [x] C13-G: source/build migrasi, audit, screenshot dan handoff disimpan; akhir Edit/default/HUD aktif/0 paket.
- [ ] C13-H: simpan revisi CityChoices13 ke main_game.rbxl; file yang diperiksa baru mencakup UI12/M11.
- [ ] C13-I: uji berjalan penuh, kenyamanan ramp dan pilihan bonus oleh pemain; HP sentuh/multiplayer/performa/balance.

## Ground14 — rapikan seluruh tapak kota

- [x] G14-A: inspeksi ketinggian/footprint Parts dan backup Map/place sebelum perubahan.
- [x] G14-B: tanah/rumput kontinu, hapus tampilan batas plot lama, air berada di perimeter; tanpa voxel Terrain writes.
- [x] G14-C: paving/sidewalk seragam, sambungan rumah/taman, pindahkan planter dari ramp dan sidewalk dari tiang jembatan.
- [x] G14-D:3036 sampel final tanpa celah lantai, pivot keenam bangunan tetap; Humanoid berjalan18stud dengan sisa jarak.90/health100.
- [x] G14-E: startup tanpa error runtime dan pickupCarrying/profileReady; akhirEdit/HUDaktif/0paket.
- [x] G14-F: migrasi source, audit, screenshot dan handoff disimpan.
- [ ] G14-G: simpan sesi Studio ke main_game.rbxl; marker Ground14/ContinuousDistrict14 belum ada di disk.
- [ ] G14-H: penilaian visual pemilik dan uji berjalan semua rute/HP fisik.

## City15 — hapus tumpukan lantai, isi taman dan pasar

- [x] C15-A: backup Map/place; identifikasi lapisan lama dan persimpangan aspal bertumpuk.
- [x] C15-B:94patch Surface15,51permukaan lama disembunyikan; prioritas aspal/paving/rumput, sambungan pasar ditutup paving.
- [x] C15-C:0pasangan patch saling overlap;3036sampel lantai tanpa celah, pivot rumah tetap.
- [x] C15-D: cari aset gratis; audit gerobak/meja, tolak pohon berscript;28model/208Parts dekor bersih dan bertumpu lantai.
- [x] C15-E: dua warga lokal berjalan; startup streaming diperbaiki, gerak3.05stud/detik teramati, tanpa error final.
- [x] C15-F: Humanoid melewati persimpangan22stud, sisa.70/health100; pickupCarrying/profileReady.
- [x] C15-G: source, metadata aset, screenshot, audit/handoff disimpan; akhirEdit/HUDaktif/0paket.
- [ ] C15-H: simpan .rbxl dari sesi aktif; marker SingleSurface15/CreatorCity15 belum ada di file disk.
- [ ] C15-I: playtest semua rute, HP sentuh/performa/multiplayer dan penilaian visual pemilik.

## Challenge16 — target sesi

- [x] M16-A: backup source dan place, spesifikasi target sesi/reward/reset.
- [x] M16-B: module progres server murni, integrasi snapshot dan ledger; tidak ada remote klaim baru.
- [x] M16-C: HUD progres desktop/HP dan rincian bonus hasil, hide saat toko/hasil.
- [x] M16-D: logic tiga target, kriteria gagal/Recover, preview tidak memutasi, reward20/25/30, complete tidak memberi bonus lagi.
- [x] M16-E: dua pengantaran fixture: progres1/2 lalu target2; hadiah48 lalu68 termasuk bonus20, replay tetap.
- [x] M16-F: emulator750x323 teks muat, bebas dari kartu/toolbar; sesi baru0/2; startup final tanpa error.
- [x] M16-G: source/audit/screenshot/handoff disimpan; akhirEdit/default/HUDaktif/0paket.
- [ ] M16-H: simpan SessionTargets16 ke file main_game.rbxl dari Studio aktif; marker belum ada pada file disk.
- [ ] M16-I: playtest manusia/HP, balance reward; integrasi pengantaran tahap2/3 dan ConfigService published belum diuji.

## Jobs17 — papan pilihan pesanan

- [x] J17-A: backup8source/place dan spesifikasi alur pilihan di depot.
- [x] J17-B: tiga tawaran server, cache/revisi monoton, AcceptJob tervalidasi, bonus pekerjaan sesuai kondisi di ledger.
- [x] J17-C: menuReguler/Rapuh/LintasKota, primary/E, hide HUD/rute/sprint/target, penutupan otomatis dan rincian bonus hasil.
- [x] J17-D:10set tawaran valid pada modulefresh; RegulerBiasa, RapuhRapuh, tujuan jauh04/05, revisi berbeda.
- [x] J17-E: E membuka, mouse memilih Rapuh/Rumah02/bonus8; pengantaran55termasuk8, replay saldo tetap.
- [x] J17-F: jauhTooFar, aktifOrderActive, tawaranlamaOfferExpired, extraarg/tableInvalidArguments; profil tetapIdle pada penolakan.
- [x] J17-G: ekonomi terisolasi kondisi80→bonus6, replay ditolak, EconomyLimit tidak mengubah progres target; folder test dibuang.
- [x] J17-H: desktop dan emulator750x323 semua teks muat, menu620x280; source/audit/screenshot/handoff tersimpan; akhirEdit/default/HUDaktif/0paket.
- [ ] J17-I: simpan revisi DepotOffers17 ke main_game.rbxl dari sesi aktif; marker belum ada di disk.
- [ ] J17-J: uji jalan penuh/HPsentuh/multiplayer/performa dan balance bonus; penerimaanLintasKota terkontrol diverifikasi pada N19.

## MobileMarket18 — tiga perbaikan permintaan pemilik

- [x] M18-A: backup Map/GUI/source dan file sebelum perubahan; simpan struktur kandidat aset.
- [x] M18-B: layout phone238x84/Menu/meter kecil/Sprint terpisah; target dan petunjuk melalui disclosure, error tetap tersedia.
- [x] M18-C: emulator iPhone750x323 dan GalaxyA06705x280, teks/menu muat; desktop300x152 tetap, tombol Menu tersembunyi.
- [x] M18-D: pointer desktop dengan override runtime memverifikasi Menu/Target/Petunjuk; override dihapus. Touch fisik belum diklaim.
- [x] M18-E:67prop diperiksa geometri;11diturunkan, dua meja≈.91stud; audit ulang0koreksi tambahan, dukungan kardus bertumpuk diverifikasi XZ/Y.
- [x] M18-F:3kategori pasar,4sumbergratis,15display/78Parts/0vendorScript;15kontak geometri tepatcountertop,17preloadSuccess.
- [x] M18-G: maprotasi terbaru diikuti oleh barang/rute/warga;16dot mempunyai lantai; susunan rumah sesuai transformasi kaku dengan galat<.001stud.
- [x] M18-H: source/audit/screenshot/handoff disimpan; akhirEdit/default/HUDaktif/0paket/reviewfolderdihapus.
- [ ] M18-I: simpan ulang sesi Studio; file447995byte baru mencakup sebagianM18 dan belum memuat source/market final.
- [ ] M18-J: uji HP fisik/touch, semua kontrol menu, performa dan multiplayer; percobaan pointer Route/Toko belum menjadi bukti touch.

## Navigation19 — arahan dan batas map

- [x] N19-A: backup5source/place sebelum edit; satu LocalScript navigasi baru.
- [x] N19-B: kompas/jarak pada header, lookahead rute, indikator siap, fallback posisi server untuk paket yang tidak tampil lokal.
- [x] N19-C: mobile hanya menampilkan Primary yang bisa dipakai; Secondary mengisi slot kosong; tanpa panel baru.
- [x] N19-D: PackageService/Recover memakai koordinat lokal DepotPad, lima tujuan valid dan titik di luar tetap outOfBounds.
- [x] N19-E: bearing kamera0/90/180/-90 sesuai; rute302stud, ready✓ di depot/tujuan; title mobile muat.
- [x] N19-F: LintasKota Rumah04 tetapCarrying/outOfBoundsfalse dan diantar100/56koin; fixture bukan perjalanan berjalan penuh.
- [x] N19-G: paket dihilangkan sementara dari client tetap ditunjuk25stud; outOfBounds memintaRecover tanpa panah; Recover dari distrik sah tidak teleport, kondisi80/recovery1.
- [x] N19-H: source/audit/screenshot/handoff tersimpan; akhirEdit/default/HUDaktif/0paket.
- [x] N19-I: save berikutnya395960byte sudah memuat CourierCompass19; source praRelay dan komponen navigasi diperiksa kembali pada Relay21.
- [ ] N19-J: uji rute berjalan penuh/HP fisik/multiplayer/performa dan kondisi map yang jalannya dipindah individual.

## Gear20 — progres peralatan kurir

- [x] G20-A: backup place/source sebelum edit; pertahankan map, aset, serta mekanik pengantaran sebelumnya.
- [x] G20-B: sarung tangan tiga level 80/140/220, drain genggaman -10/-20/-30%; quote server dan tuning terkunci per sesi.
- [x] G20-C: pembelian di depot ketika Idle; validasi saldo/level/argumen/max, token level lama menolak pembelian ganda.
- [x] G20-D: ProfileSchema2 dan migrasi 0/1; pengujian terisolasi mempertahankan data lama, menolak upgrade invalid, round-trip level3.
- [x] G20-E: pembelian aktual level1 memotong 80 sekali, glove terpasang, pembelian ketika membawa paket ditolak.
- [x] G20-F: efek level3 terukur pada sprint terkontrol (drain20, perkiraan21.38 dengan pembulatan/timing); level/glove bertahan saat respawn.
- [x] G20-G: tab toko Tas/Peralatan, HP Galaxy705x280 muat via fixture modal terbuka; desktop pointer membuka toko, empat baris tas muat.
- [x] G20-H: fresh StudioMemory kembali coins0/Grip0, source final sinkron, fixture dihapus, Edit/default/HUDaktif, console fresh Bootstrap saja.
- [x] G20-I: audit/screenshot/migrasi label/design/handoff tersimpan di workspace.
- [x] G20-J: save berikutnya395960byte sudah memuat Gear20/Navigation19; source praRelay dan module Gear20 sesuai pada pemeriksaan Relay21.
- [ ] G20-K: uji published DataStore migrasi/save/rejoin dan rencana rollback kompatibel schema2 sebelum deploy.
- [ ] G20-L: HP touch fisik, multiplayer/performa, avatar R6 dan balance harga; pointer menu emulator belum membuktikan alur mobile.

## Relay21 — kurangi perjalanan kosong kembali ke depot

- [x] R21-A: backup tujuh source aktif di disk serta backup place/handoff sebelum edit; folder ServerStorage dipulihkan dari snapshot praedit pada pemeriksaan akhir (7source).
- [x] R21-B: satu tawaran opsional setelah pesanan depot; sumber rumah pelanggan, tujuan berbeda, batas ambil default60detik.
- [x] R21-C: validasi token/arity/profil/hidup/jarak/order aktif; expired/stale/far/extra argumen ditolak; skip tanpa kredit.
- [x] R21-D: penerimaan tidak memajukan jadwal depot, tidak memberi koin; pengantaran memakai ledger lama, replay tanpa kredit.
- [x] R21-E: titipan selesai tidak membuat rantai tak terbatas; tidak mengubah rekor depot; cancel/respawn menghapus tawaran.
- [x] R21-F:20pasangan rute berarah diuji endpoint/panjang simetris; panduan menyambung jalan pada simpang bersama.
- [x] R21-G: satu rute Rumah01→Rumah02 ditempuh via tool navigasi speed1 melalui empat waypoint, sampai Carrying100/ready dan diantar via tombol aktual.
- [x] R21-H: desktop Ambil/Lewati aktual, phoneGalaxy705x280 seluruh teks muat, countdown/bar pada kartu lama; dekat depot tetap Start/depot/highlightdepot.
- [x] R21-I: fresh StudioMemory coins0/deliveries0/Grip0/noOffer, console fresh Bootstrap saja; source/audit/screenshot/handoff disimpan.
- [x] R21-J: save442913byte berikutnya memuat NeighborRelay21 (diperiksa pada Contracts24).
- [ ] R21-K: playtest manusia/balance target waktu/harga, rute lain penuh, HP touch fisik, multiplayer dan performa; belum diverifikasi.

## Quality22 — hasil pengantaran dan pelanggan

- [x] Q22-A: backup4source aktif/place/handoff sebelum edit; salinan rollback ServerStorage4source diverifikasi saat akhir.
- [x] Q22-B: penilaian server3/2/1bintang, target waktu sesuai rute, tuning terkunci per sesi; rumus koin/rekor/schema2 tetap.
- [x] Q22-C: rangkaian rapi/terbaik sesi, commit bersama ledger; replay/batas ekonomi tidak memutasi rangkaian.
- [x] Q22-D: pengujian terisolasi6kasus penilaian, preview murni, batas9999, formula hadiah lama, dirtyWrites3 untuk3award.
- [x] Q22-E: runtime3bintang→2bintang(titipan)→1bintang(Drop/Recover/Pickup/Deliver), rangkaian1→2→0, terbaik2 dan replay tanpa kredit.
- [x] Q22-F: cancelIdle menjaga rangkaian; cancelActive mereset current dan menjaga best; tidak ada field rangkaian di profil.
- [x] Q22-G:5pelanggan/56Part, lantai aktual dan tanpa collision; kaki semua terukur≈.0298stud di atas permukaan, animasi/bubble mengikuti hasil sah.
- [x] Q22-H: panel330x212 muat pada Galaxy705x280, semua teks muat; actualdesktop×menutup hasil dan memperlihatkan bubble; replay UI tidak mengulang reaksi.
- [x] Q22-I: finalfreshStudioMemory coins0/delivery0/Grip0/current0/best0, consoleBootstrap saja, Edit/default/0paket/tanpa fixture; source/audit/gambar/handoff tersimpan.
- [x] Q22-J: save442913byte berikutnya memuat CustomerRatings22 (diperiksa pada Contracts24).
- [ ] Q22-K: uji HP touch fisik, semua orientasi/perangkat, multiplayer/performa, balance penilaian dan playtest manusia; phone×belum terverifikasi sebagai aksi yang ditargetkan.

## City23 — penataan kota

- [x] C23-A: backup Map27anak dan Lighting9objek ke ServerStorage; backup binary/handoff sebelum migrasi.
- [x] C23-B: lima fasad, storefront dua arah, kanopi dengan clearance, trim/jendela/atap/tangki berbeda; label gedung lama tidak lagi terpotong.
- [x] C23-C: air mancur CreatorStore gratis13782728612, whitelist render17Part/3SurfaceAppearance/0script; kandidat177Part tidak dipakai.
- [x] C23-D: plaza pasar/bangku/tanaman, pergola taman, pojok baca, jalur tepi kota dan jalur taman samping.
- [x] C23-E: split19tile→70tile, total144/luas50760,0pasangan overlap dalam toleransi.01stud; posisi10marker penting tidak bergeser.
- [x] C23-F: dua zebra cross memiliki celah pembatas10stud; bbox clearance tanpa penghalang, kedua penyeberangan ditempuh via tool speed1.
- [x] C23-G:16model grounding tanpa reviewflag,2bangku baca gap0,75preloadSuccess/0failure; jalur tepi kota dan clearance kanopi diuji saat Play.
- [x] C23-H: rute depot-apron→Rumah01 ditempuh dan diantar100/47koin/3bintang/tawaranRelay; console clean. Fixture pertama dari markerPickup yang collidable dikecualikan.
- [x] C23-I:5source gameplay/client cocok dengan disk, akhirEdit/HUDaktif/0paket/tanpa fixture/reviewfolder; source migrasi/audit/gambar/handoff tersimpan.
- [x] C23-J: save442913byte berikutnya memuat LivedInTown23 (diperiksa pada Contracts24).
- [ ] C23-K: profiling HP fisik/multiplayer, semua rute manusia dan interaksi avatar berukuran ekstrem; belum diuji.

## Contracts24 — sepuluh perbaikan internal

- [x] B24-01: kontrak Prioritas dengan target kondisi/waktu.
- [x] B24-02: kontrak Paket mulus untuk paket Rapuh.
- [x] B24-03: kontrak Pemburu cap untuk eksplorasi jalur.
- [x] B24-04: tab Biasa/Kontrak/Riwayat, enam pilihan tanpa enam kartu sekaligus.
- [x] B24-05: target perjalanan ringkas termasuk countdown Prioritas.
- [x] B24-06: bonus bersyarat server, base tetap saat gagal, replay/overflow tanpa commit.
- [x] B24-07: riwayat lima pengantaran sesi; snapshot tidak memutasi profil.
- [x] B24-08: rincian bonus dan status kontrak pada panel hasil.
- [x] B24-09: guard fokus TextBox untuk E/Q/R/B; verifikasi source, belum uji mengetik manual.
- [x] B24-10: peringatan genggaman≤25, rearm≥50; diverifikasi memakai snapshot uji.
- [x] B24-11: tujuh kasus kontrak, ledger/history/overflow, pembelian tawaran dan payout Prioritas aktual lewat fixture; desktop tab/riwayat klik berhasil; HP layout muat.
- [x] B24-12: fresh coins0/history0/gear0/offers6, consoleBootstrap saja, backup8source, Edit/default/HUDaktif/0paket/tanpa fixture.
- [x] B24-13: main_game449312byte terverifikasi10November memuat SpecialContracts24.
- [ ] B24-14: penilaian pemilik/balance dan input HP fisik. Publikasi/uji pemain luar ditunda sesuai arahan pemilik.

## Status25 — permintaan Make It Better #23

- [x] S25-A: backup lima source sebelum edit; binary/handoff dan ServerStorage5source tersedia.
- [x] S25-B: evaluator status shared dan server bonus konsisten;504kombinasi memberi payout sama dengan aturan sebelumnya.
- [x] S25-C: HUD membedakan gugur vs cap belum cukup; hasil dan riwayat menampilkan alasan yang spesifik.
- [x] S25-D: lima kasus live fixture menghasilkan ready/late/condition/recovered/stamps; replay tanpa kredit/history tambahan.
- [x] S25-E: riwayat5pesanan muat di desktop/phone705x280; status aktif dan hint hasil muat; tab default dikembalikan0.
- [x] S25-F: kontrak terlambat tetap dapat diantar, total40/base25/bonus0; freshcoins0/history0/offers6, consoleBootstrap saja.
- [x] S25-G: source/dokumen/audit/screenshot tersimpan; Edit/default/HUDaktif/0paket/tanpa fixture, backup5source.
- [x] S25-H: main_game449312byte terverifikasi10November memuat ClearStatus25.
- [ ] S25-I: penilaian pemilik dan HP touch fisik; publikasi/pemain luar tetap ditunda.


## Stamp26 — panduan cap sebelum tujuan (2026-11-09)

- [x] Tambah planner graf jalan untuk pos yang belum dikunjungi, mempertimbangkan dua cap dan rumah tujuan.
- [x] Kirim geometri pos/ramp/jembatan saat kontrak eksplorasi masih aktif/layak.
- [x] Hubungkan titik jalan, kompas, billboard dan highlight ke target cap yang sama.
- [x] Pulihkan panduan rumah setelah cap lengkap; prioritaskan paket saat Drop; pertahankan toggle G.
- [x] Periksa tujuh kasus planner, konektivitas lima pos, pengambilan dua cap + pengantaran, serta ramp/jembatan.
- [x] Cek GalaxyA06 landscape, fresh sesi tanpa fixture, backup enam source dan kesamaan tujuh source disk/Studio.
- [x] Simpan bukti dan perbarui design/handoff.
- [x] Stamp26 tersimpan: main_game449312byte terverifikasi10November memuat RouteStamps26.
- [ ] Uji HP fisik/multiplayer/performa dan seluruh jalur; publikasi serta uji pemain luar tetap ditunda.


## Rest27 — bangku publik berfungsi (10 November 2026)

- [x] Konfirmasi pemilik untuk mengubah main_game_AutoRecovery_0.rbxl yang terbuka.
- [x] Backup tiga source aktif dan baseline binary/handoff.
- [x] Pasang empatSeat pada bangku lama tanpa mengubah mesh kota.
- [x] Handler server untuk jarak/seat/profil/hidup/occupant, promptF/X bawaan.
- [x] Regen2x bounded/ConfigService melalui tuning movement; timer/kondisi paket/reward tetap.
- [x] Meter Istirahat dan pembatalan sprint saat duduk tanpa panel HUD permanen.
- [x] Uji empatSeat, normal vs2x, cap100, F/Space desktop, kondisi70/coins0/startedAt tetap.
- [x] Layout GalaxyA06 landscape muat; bukti dan batas input/kamera dicatat.
- [x] Empat source disk/Edit cocok, akhirEdit/default/0paket/tanpafixture, diffcheck lolos.
- [x] Rest27 tersimpan: main_game456270byte terverifikasi memuat PublicBenches27 pada Preview28.
- [ ] Uji sentuh fisik/gamepad, kamera semua arah dan multiplayer; publikasi/pemain luar tetap ditunda.


## Preview28 — pratinjau pekerjaan (10 November 2026)

- [x] Backup source board aktif, binarybaseline dan handoff.
- [x] Daftar pilih kiri/detail kanan dengan sketsa jalan, panjang rute dan marker depot/tujuan.
- [x] Syarat Prioritas/Paket mulus/Pemburu cap eksplisit; dasar dan bonus dibedakan tanpa menjanjikan total.
- [x] Pilih kartu tanpa membuat order; tombol Ambil mengirim offerid terpilih, fallback revisibaru.
- [x] Tujuh pemeriksaan helper, seleksiIdle, tokenlamaOfferExpired dan penerimaanRumah02 sesuai pilihan.
- [x] Layout kontrak/riwayat HP muat; temporary tab dipulihkan0 dan fixture dibersihkan.
- [x] Dua source disk/Edit sama, freshIdle/koin0/history0/offers6, consoleBootstrap, akhirEdit/default/0paket.
- [x] Simpan source, audit, gambar, design/handoff.
- [x] Preview28 tersimpan: main_game458926byte terverifikasi memuat RoutePreview28 pada Coach29.
- [ ] Pemeriksaan sentuh/gamepad fisik dan multiplayer; publikasi/pemain luar ditunda.


## Coach29 — bantuan saat perjalanan (10 November 2026)

- [x] Backup client aktif, binarybaseline dan handoff.
- [x] Helper konteks untuk cap, RuteOFF, rumah tujuan, kontrak gugur, paket jatuh/keluar jalur, genggaman dan bangku.
- [x] Peringatan barrier berbasis footprint/arah/ketinggian tanpa mengubah hazard server.
- [x] Gunakan Guide/MobileNotice lama; dedupe perorder, hormati pesan aktif/menu/toko/hasil/dismiss/diagnostik.
- [x] 22kasus helper dan integrasi aktual; pengujian terganggu benturan teleport diulang pada posisi tetap.
- [x] HP layout muat, notifikasi tidak menimpa pesan aktif atau mengulang tiap snapshot.
- [x] Dua source disk/Edit sama, freshIdle/koin0/history0/offers6; akhirEdit/default/0paket/tanpafixture.
- [x] Source/audit/gambar/design/handoff tersimpan, diffcheck lolos.
- [ ] Simpan AutoRecovery ke main_game.rbxl untuk ContextCoach29; binary458926byte belum memuatnya.
- [ ] HP/gamepad fisik, kamera/seluruh rute/multiplayer/performa; publikasi/pemain luar tetap ditunda.


## Customers30 — interaksi pelanggan (10 November 2026)

- [x] Backup client aktif, binarybaseline dan handoff.
- [x] Sapaan unik lima rumah; hanya tujuan aktif, sekali perorder, cap dipahami lewat helperstatus yang sama.
- [x] Respons Delivered menunggu panelhasil/menu selesai; parcel lokal lalu lambaian, variasi dialog dan info titipan.
- [x] Parcel/tape noncollision, grounding lama dan orientasi keluar pintu, resetrespawn/timeout/dedupe20.
- [x] Delapan aturan helper; wronghouse/greeting/Sync/deliveredreplay tidak mengulang respons.
- [x] Data receipt, parcelopacity, rating/coin dan TextFits desktop/phone terverifikasi pada sesi lokal.
- [x] Dua source disk/Edit sama; freshIdle/koin0/history0/offers6,5groundedNPC,0parcelvisible; akhirEdit/default/0paket/tanpafixture.
- [x] Source/audit/design/handoff tersimpan, diffcheck lolos.
- [ ] Periksa pose/kliping/penampilan di viewport3D normal; MCP memberi tangkapan3Dhitam. Tidak dianggap lolos visual.
- [ ] Simpan AutoRecovery ke main_game.rbxl untuk Coach29 dan Customers30; binary458926byte belum memuat keduanya.
- [ ] HP/gamepad fisik, multiplayer dan profiling; publikasi/pemain luar tetap ditunda.
