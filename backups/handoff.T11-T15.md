# Paket Kilat! — Handoff T11–T15

Tanggal: 7 November 2026, Asia/Jakarta. **T01–T15 selesai; berhenti sebelum T16.** Tidak ada publikasi, pembelian, unggahan aset, atau DataStore.

## Hasil dan penerimaan T10

Pemilik mengganti jawaban sebelumnya “belum mencoba” dengan **“sudah mencoba bisa lanjukan 11-15”**. Ini dicatat sebagai penerimaan untuk melanjutkan dan tidak ada bug penghalang yang dilaporkan. Perangkat/jumlah putaran pribadi tidak disebutkan; tidak diklaim sebagai uji HP asli. Bukti: `verification/t10-owner-acceptance.json`. Jawaban lama dipertahankan sebagai riwayat, bukan status terkini.

Lima tujuan tersedia dengan nama/warna/landmark berbeda. Bu Sari mempunyai jalan U aman dan papan pintas; Pak Budi mempunyai jalan U aman dan pintasan licin. Jalan kampung menghubungkan tiga rumah lain dan menyediakan jalur memutar penghalang bergerak. Paket Biasa/Rapuh, rekor sesi, rincian hadiah, penanda kembali ke depot, serta cue ambil/benturan/antar sudah tersedia.

## Status place dan cadangan

Place: `D:\YANG CORPORATE\Roblox\Game1\main_game.rbxl`.

- **Tersimpan lokal**, File > Save to File lewat UIAutomation pada jendela proyek yang diverifikasi.
- Ukuran **132.975 byte**; waktu tulis **7 November 2026 01:48:43 WIB**.
- SHA-256: `C0A907742DA67025104FD51425205CB076D6B171F2F1899A868F1C4C7893BE4A`.
- Bukti `verification/stage3-save-status.json`. File akhir belum ditutup/dibuka ulang. File dasar tahap kedua berhasil dibuka kembali ketika memulai pekerjaan ini.
- Studio ditinggalkan **Edit**, simulator **default**; nol paket aktif/Script uji dalam place final.
- Delapan script runtime cocok sumber lokal; ada lima DestinationPoint dan 89 BasePart map pada audit.

Studio sempat tertutup dan dibuka kembali. Target MCP terbaru `0d3d7df1-4486-40ed-84bd-972e548eeedc`, nama `main_game.rbxl`, PlaceId/GameId 0. Pusat DepotPad tetap (0,1045,0). Baseplate, Camera, Terrain, spawn awal dalam `Workspace/OriginalContent`, depot, Rumah01, dan map awal dipertahankan.

Cadangan sebelum mutasi:

| Artefak | Isi |
| --- | --- |
| `backups/main_game.before-T11-T15.20261107.rbxl` | Place tahap kedua, 122.320 byte; SHA-256 `5A1B0C24A707BF2FBDE574D966E9AB59936070F1DA25760292967FE154628276`. |
| `backups/studio-before-T11-T15-inspection.json` | Sumber dan posisi map aktual sebelum perubahan. |
| `ServerStorage/PaketKilat_PreStage3_Backup` | Salinan map, shared/remotes, server scripts, template, input dan UI melalui MCP. |
| `backups/handoff.T07-T10.md`, `backups/handoff.T01-T06.md` | Handoff lama utuh; kontrak dan riwayat uji sebelumnya. |
| Cadangan T01–T06 dan T07–T10 sebelumnya | Tetap tersedia, tidak ditimpa. |

## Struktur instance

```text
Workspace
  Baseplate, Camera, Terrain, OriginalContent/SpawnLocation
  PaketKilat
    Map
      DepotPad, HousePad, jalan U lama, NarrowPlank
      Depot, Rumah01, RecoveryPoint, PrototypeSpawn
      Rumah02, Rumah03, Rumah04, Rumah05
      Expansion
        Roads                  jalan barat/utara/market dan bypass
        Hazards                Puddle, MovingBarrier, BarrierZone, posts
        Decor                  pohon, papan kampung, petunjuk bypass
    ActivePackages
ReplicatedStorage/PaketKilat
  Shared/Config
  Remotes/ActionRequest, StateChanged
ServerScriptService/PaketKilat
  Bootstrap
  DeliveryService, PackageService, EconomyService, PlayerLifecycle
  HazardService                baru
ServerStorage
  PaketKilat/PackageTemplate
  PaketKilat_PreStage1_Backup, PreStage2_Backup, PreStage3_Backup
StarterPlayer/StarterPlayerScripts/PaketKilatInput
StarterGui/PaketKilatUI/Root
  TopCard                      tujuan, jenis/kondisi/rekor, saldo, hasil
  Actions/Primary, Secondary
```

LocalScript membuat penanda tujuan/depot dan `SoundService/PaketKilatSFX` pada masing-masing klien. Objek audio/penanda klien tidak disimpan sebagai instance runtime dalam place. Prompt lama tetap disimpan dan dinonaktifkan, menghindari input E ganda.

## File dan konfigurasi yang berubah

| File | Perubahan |
| --- | --- |
| `design.md` | v0.4; kontrak tahap ketiga ditulis sebelum implementasi dan perubahan deteksi kontak. Bagian tahap pertama/kedua menjadi riwayat. |
| `task_list.md` | T10 diterima pemilik, T11–T15 memiliki bukti, T16+ tetap terbuka. |
| `src/Config.luau` | Lima Routes, jadwal 10 kombinasi, PackageTypes, parameter rintangan, batas arena, dan tiga cue audio. |
| `src/ExpandVillage.luau` | Generator tambahan map; sudah dijalankan sekali. Menolak duplikasi Expansion, tidak membangun ulang map lama. |
| `src/HazardService.luau` | Volume genangan/sapuan penghalang dan efek planar, cooldown, pembersihan. |
| `src/DeliveryService.luau` | Penetapan tujuan/tipe server, posisi tujuan dinamis, snapshot rekor/preview, damage per tipe, pembersihan efek. |
| `src/EconomyService.luau` | Target per rute, jadwal pesanan, rekor per tujuan/tipe, kelayakan dan hasil; ledger kredit sekali tetap. |
| `src/PackageService.luau` | Label/warna jenis paket dan target dinamis; sampel posisi serta assembly untuk benturan raycast. |
| `src/Bootstrap.server.luau` | Wiring HazardService. PlayerLifecycle tetap memakai cleanup DeliveryService yang kini juga membersihkan efek. |
| `src/PrototypeInput.client.luau` | Jenis/rekor/hasil, flash kondisi, cue audio, penanda tujuan/depot. Kontrol E/Q/R dan tombol tetap. |
| `src/BuildUI.luau` | Placeholder sesi/rekor, hint 12 px, secondary tersembunyi sebelum state. |
| `asset_sources.md` | Sumber visual buatan proyek, audio bawaan Roblox, batas pemakaian serta bukti muat/pemutaran. |
| `verification/Stage3*.luau` | Harness server/fisik/driver/jalan/presentasi. Hanya dipasang sementara dalam Play. |
| `verification/stage3-*.json` | Bukti aktual akhir dan beberapa riwayat percobaan awal yang gagal. |

Tidak ada sinkronisasi otomatis/Rojo. Sumber delapan script cocok dengan instance final dalam `stage3-studio-manifest.json`. Jangan menjalankan ulang generator map/perluasan/UI pada place yang sudah berisi objeknya.

## Tujuan dan keseimbangan awal

Koordinat berikut relatif pusat DepotPad, X/Z; titik penyerahan berada 1,15 stud di atas pusat Y dan Z+3 dari pusat rumah.

| ID | Nama / landmark | Pusat X,Z | Target detik | Jalan aman terukur |
| --- | --- | --- | --- | --- |
| Rumah01 | Bu Sari, biru/pot bunga | 100,0 | 45 | 11,90 dtk |
| Rumah02 | Pak Budi, oranye/warung | -100,0 | 45 | 11,85 dtk |
| Rumah03 | Bu Rina, ungu/kebun | 0,120 | 35 | 14,62 dtk |
| Rumah04 | Pak Agus, hijau/peti | 100,120 | 60 | 20,88 dtk |
| Rumah05 | Bu Dewi, kuning/tangki | -100,120 | 60 | 17,80 dtk |

Pengukuran memakai MoveTo karakter uji, bukan pemain manusia; waktu penggunaan nyata dan sasaran desain awal 60–120 detik belum divalidasi. Target sekarang memberi kelonggaran prototipe dan perbedaan bonus antarjalan, bukan klaim keseimbangan final.

Server mengurutkan: Bu Sari/Biasa, Pak Budi/Rapuh, Bu Rina/Biasa, Pak Agus/Rapuh, Bu Dewi/Biasa, lalu lima rumah yang sama dengan tipe kebalikannya. Jadwal maju pada Start yang sah, termasuk jika pesanan kemudian dibatalkan. Reset mempertahankan jadwal sesi; sesi baru mulai dari awal.

Formula tidak berubah:

```text
25 + floor(15 * kondisi / 100)
   + floor(10 * clamp(1 - durasiServer / targetRute, 0, 1))
```

Biasa/Rapuh sama-sama mulai 100 dan memakai formula yang sama. Damage benturan 10/20, cooldown damage 1 detik. Pemulihan -20, cooldown 5 detik, tidak mengulang ID/tujuan/timer. Kondisi 0 tetap bisa diantar; tanpa bonus waktu, dasar 25. Rekor tidak memberi koin ekstra.

Batas arena relatif depot minimum (-126,-14,-55), maksimum (136,96,154). Paket di luar batas ditahan sebelum mesin menghapusnya. Pulihkan memindahkan paket ke depot; pemain yang sudah jatuh di bawah/di luar arena ikut kembali ke spawn aman.

## Mekanik tiga rintangan

- **Papan sempit:** mekanik lama dipertahankan. Jalan aman U tersedia. Gagal di samping papan menjadi Dropped/OOB dan dapat dipulihkan.
- **Genangan:** berada pada pintasan barat ke Pak Budi. Dua sampel kaki dalam volume dan laju horizontal minimal 5 mengonfirmasi kontak. Selip menargetkan laju planar 18 selama 0,65 detik, cooldown 3 detik. Paket dilepas dan rusak menurut tipe. Input dilepas pun masih menggeser karakter sesaat, terbukti pada uji tambahan.
- **Penghalang bergerak:** di jalan utara X=-24, Z=65; amplitudo 9, periode 4 detik. Volume sapuan antarsampel server diuji pada pembawa/paket lepas, laju minimum 4, cooldown 2 detik. Benturan memberi dorongan 18 selama 0,25 detik. Part visual tidak bertabrakan native; volume server dan constraint menghindari fling. Jalur bypass X=-48 aman.

Tidak memakai laporan benturan klien atau Touched tunggal. Semua damage berbagi cooldown. Benturan lantai memerlukan laju sebelumnya/estimasi perpindahan server dan raycast kontak. Attachment/LinearVelocity dibersihkan saat kedaluwarsa, pulih, batal, reset dan keluar.

## Kontrak data, RemoteEvent dan rekor

Kontrak request tetap:

```lua
ActionRequest:FireServer(action, orderId?, destinationId?)
StateChanged:FireClient(player, snapshot, resultCode)
```

Aksi tetap Start/Pickup/Drop/Recover/Deliver/Sync. Start tidak menerima pilihan tipe/tujuan; server menetapkannya. Batas string 16 byte untuk action, 64 untuk ID/tujuan; interval request 0,2 detik, termasuk payload salah. Identitas Player dari OnServerEvent. Klien tidak mengirim kondisi/hadiah/posisi resmi.

State resmi tetap Idle → Carrying ↔ Dropped → Delivered → Idle. Penyerahan memeriksa pemain hidup, ID/pemilik, status/paket, tujuan, jarak pemain ≤12 dan paket ≤15. Kunci dan ledger `creditedOrders` mencegah kredit ulang. Seluruh validasi/kredit tanpa yield; paket/koneksi dibersihkan sebelum Idle.

Snapshot mempertahankan field lama: orderId, ownerUserId, packageType, destinationId/name, status, condition, startedAt, rewardProcessed, completionLocked, recoveryCount, lastRecoveryAt, outOfBounds, coins, deliveryCount, lastResult, posisi depot/pulih/tujuan.

Tambahan:

| Data | Makna |
| --- | --- |
| `bestTimes` | Salinan tabel durasi terbaik per `destinationId|packageType`, hanya milik pemain tersebut. |
| `currentBestTime` | Rekor pasangan pesanan aktif jika ada. |
| `nextOrder` | destinationId/name, packageType, targetSeconds, bestTime untuk preview server berikutnya. |
| `lastResult.packageType` | Jenis paket pada ringkasan hasil. |
| `recordEligible`, `recordReason` | Tanpa pemulihan memenuhi syarat; memakai pemulihan menghasilkan false/Recovered. |
| `previousBest`, `bestTime`, `newRecord` | Nilai sebelumnya/terbaik dan apakah durasi lebih cepat. Nilai yang belum ada boleh nil. |

Hasil tetap memuat ID/tujuan, durasi, kondisi, recoveryCount, komponen hadiah, total dan completedAt. Snapshot/hasil/bestTimes disalin. Rekor pertama dan durasi lebih kecil memperbarui; seri/lambat tidak. Kerusakan tanpa pemulihan tetap boleh mencetak rekor. Pemulihan tidak membuat rekor pertama maupun mengganti rekor lama meski lebih cepat.

Kode event baru Slip dan Barrier memakai kanal StateChanged yang sama; penolakan UnavailableDestination menjaga bila instance tujuan hilang. Kode serta validasi lama dipertahankan. Tidak ada remote untuk mengubah jadwal, rekor atau kondisi.

Koin, rekor dan jadwal bertahan pada respawn, hilang pada keluar/sesi baru. T16–T17 belum dibuat.

## Bukti verifikasi

| Bukti | Hasil |
| --- | --- |
| `stage3-server-checks.json` | **138/138 lulus**: 10 pasangan, penugasan server, perbedaan damage/cooldown, tujuan salah/jarak, formula tiap rute, replay, ledger, kondisi 0, record pertama/cepat/lambat/seri/pulih, salinan tabel, reset dan sesi. Suite diulang setelah pembaruan kontak. |
| `stage3-physics-checks.json` | **40/40 lulus**: Biasa/Rapuh pada genangan/penghalang/gagal papan, pemulihan ID/timer/penalti, cleanup efek, hard landing membawa/lepas, reset saat efek aktif, tanpa uang tambahan. Hard landing teramati hingga 78,48 stud/detik; kondisi 90/80. |
| `stage3-slide-release-checks.json` | Kedua tipe masih bergeser setelah input dihentikan, lebih dari 6 stud pada sampel uji; bukan hanya perubahan warna/damage. |
| `stage3-walk-checks.json` | **7 lintasan selesai:** lima aman tanpa damage, papan pintas 6,31 detik/Rapuh/kondisi100/hadiah48; pintasan licin 9,20 detik/Biasa/dua lepas-ambil ulang/kondisi80/hadiah44. Deviasi carry maksimal sekitar 0,0000083 stud. |
| `stage3-eligible-presentation.json`, `stage3-recovered-presentation.json` | Fixture presentasi: Rapuh/Rumah04 rekor 22,42 detik tidak diganti perjalanan dipulihkan 5,42 detik. Keduanya dibayar sesuai formula. |
| `stage3-desktop-layout.json`, `stage3-phone-*.json` | Desktop 1350×921 dan iPhone 17 Pro emulator 874×402 (viewport aman750×381): tipe/rekor/hasil/penolakan rekor muat, kedua tombol tidak saling menutupi. |
| `stage3-touch-actions.json` | 4 Touch, 0 Keyboard: ambil Rapuh, lepas, pulih, ambil ulang; akhirnya Carrying/80. Ini uji aksi tahap ketiga, bukan klaim siklus baru lima rumah di HP asli. |
| `stage3-audio-checks.json` | Tiga Sound dimuat; Play/Ended positif. Pickup46/36, Impact23/23, Delivered17/17 pada sesi audit. |
| `stage3-depot-marker.json` | Saat Idle jauh dari depot, penanda DEPOT tampil. |
| `stage3-fresh-session.json` | Sesi baru coins0, deliveryCount0, records0, jadwal kembali Rumah01/Biasa. Console terakhir hanya bootstrap siap. |
| `stage3-studio-manifest.json`, `stage3-save-status.json` | Delapan sumber cocok, lima tujuan, 89 Part, simulator default, tidak ada artefak uji aktif di Edit; simpan diverifikasi hash disk. |

Persiapan posisi di antara percobaan jalan memakai PivotTo, selama lintasan memakai MoveTo tanpa teleport. Lima rute aman diuji dari depot; tidak diklaim sebagai uji pulang-pergi seluruh rumah. Fixture fisik memakai driver sementara dan persiapan freefall yang deterministik; fixture presentasi mengatur waktu di server untuk menampilkan kasus UI. Semua harness hilang saat Stop, bukan fitur produksi.

Percobaan awal fisik gagal menggerakkan/menyiapkan karakter dan tidak dihitung lulus. Riwayat tersimpan dalam `stage3-initial-physics-checks.json` dan `stage3-physics-before-sweep.json`; hanya laporan akhir 138/40 dan lintasan final dipakai untuk penerimaan.

## Batas dan pekerjaan tersisa

- Uji satu klien Studio. HP asli, performa/FPS, jaringan lambat, ragam avatar serta dua/delapan klien belum diperiksa.
- Kamera/gerak dan volume/timbre audio perlu penilaian pemilik. Muat serta Ended membuktikan jalur teknis, bukan kenyamanan suara manusia.
- Keseimbangan lima rumah adalah tahap awal; waktu raw MoveTo lebih singkat dari sasaran produk awal. Rasa tantangan dan keinginan mengulang belum dinilai pemilik pada map baru.
- Gerak karakter tetap replikasi Roblox biasa; validasi request bukan sistem antieksploit gerak lengkap.
- Tidak ada penyimpanan lintas sesi, toko, kosmetik, analitik layanan atau monetisasi. Jangan menyatakan REQ-07 penuh lulus dari rekor sesi.
- Batas pengembangan berhenti T15. T16 memerlukan permintaan berikutnya.

## Cara mencoba

1. Buka `main_game.rbxl`, tekan Play. Saldo/rekor sesi baru mulai kosong.
2. Dekati depot dan E/**Ambil pesanan**. Baca nama tujuan dan jenis paket; urutan bergilir otomatis.
3. Bu Sari: jalan U di belakang depot atau papan. Pak Budi: jalan U barat atau genangan. Rumah utara: lewat jalan kampung; gunakan bypass untuk menghindari penghalang oranye.
4. Dekati petak rumah dan E/**Antar**. Lihat komponen hadiah serta rekor. Penanda DEPOT membantu pulang untuk pesanan berikutnya.
5. Coba Q/**Lepas**, E/**Ambil ulang**, R/**Pulihkan**. Pemulihan -20, cooldown5 detik, dan membatalkan kelayakan rekor perjalanan itu.
6. Coba kedua tipe pada rintangan: Biasa rusak10, Rapuh20. Setelah jatuh di bawah arena, Pulihkan mengembalikan pemain ke depot bersama pemulihan paket.
7. Lanjutkan sampai 10 pesanan untuk seluruh kombinasi, atau Reset untuk membatalkan pesanan aktif dan mengambil berikutnya. Reset menjaga saldo/rekor sesi; Stop/keluar menghapusnya.
8. Pada sentuh, landscape dengan tombol HUD dan kontrol Roblox. Laporkan masalah suara, kamera atau tombol pada perangkat asli secara terpisah.
