# Paket Kilat! — Handoff prototipe T07–T10

Tanggal: 7 November 2026, Asia/Jakarta. **T01–T09 selesai; T10 menunggu hasil pemilik.** T11 dan sesudahnya tidak dikerjakan. Tidak ada publikasi, pembelian, DataStore, atau monetisasi.

## Pemeriksaan prasyarat permintaan T11–T15

Konfirmasi pemilik pada 7 November 2026: **“belum mencoba”**. Belum ada hasil T10 yang dapat ditinjau atau feedback gameplay yang dapat ditangani.

Permintaan perluasan diterima dengan syarat T10 selesai dan feedback pemilik ditangani. Pada pemeriksaan ini, laporan pemilik masih belum diterima, sehingga T10 dan T11–T15 tetap terbuka. Hasil uji otomatis tahap kedua tidak digunakan sebagai pengganti playtest pemilik.

Inspeksi MCP terbaru pada 7 November 2026: Studio target tetap sama, mode Edit, DataModel `main_game.rbxl`, PlaceId/GameId 0, DepotPad Y=1045, satu tujuan Rumah01, satu NarrowPlank, HUD PaketKilatUI, dua RemoteEvent, tujuh script runtime cocok sumber lokal, nol paket aktif, serta spawn awal tersedia. Console yang dibaca berisi pesan bootstrap siap; tidak ada sesi uji baru yang dijalankan. Bukti terstruktur: `verification/t10-gate-check.json`.

Place tidak dimutasi pada pemeriksaan prasyarat. File disk masih 122.320 byte dan hash `5A1B0C24A707BF2FBDE574D966E9AB59936070F1DA25760292967FE154628276`, sama dengan simpan tahap kedua. Tidak ada perubahan place baru yang perlu disimpan; cadangan sebelumnya tetap tersedia. Dokumen serta bukti inspeksi saja yang diperbarui. Belum ada konfigurasi baru, rumah tambahan, genangan/penghalang bergerak, paket rapuh, rekor, atau aset audio yang dipasang maupun dinyatakan lulus.

Yang diperlukan dari pemilik: perangkat/platform, hasil tiga pengantaran, jatuh → pulih → ambil ulang, reset → pesanan baru/saldo, bug atau bagian membingungkan, dan penilaian rasa kontrol. Panduan mencoba serta format laporan ada di akhir dokumen. Setelah laporan masuk, perbaiki masalah yang menghalangi dan verifikasi ulang sebelum mencentang T10 atau memulai T11.

## Hasil dan penyimpanan

Siklus ambil → bawa → antar → hadiah → kembali ke depot dapat diulang. Pemain bisa melepas, mengambil ulang, memulihkan paket jatuh, dan melanjutkan pesanan. HUD mendukung komputer serta emulator sentuh dalam landscape. Saldo hanya berlaku pada sesi, tetap saat respawn, dan mulai 0 pada sesi baru.

Place `D:\\YANG CORPORATE\\Roblox\\Game1\\main_game.rbxl` **sudah disimpan lokal** melalui menu **File > Save to File**, dipanggil lewat UIAutomation pada jendela Studio yang cocok dengan path proyek. Ctrl+S pada percobaan awal tidak mengubah file; percobaan itu tidak dicatat sebagai simpan berhasil.

- Ukuran akhir: **122.320 byte**.
- Waktu tulis: **7 November 2026 00:31:03 WIB**.
- SHA-256: `5A1B0C24A707BF2FBDE574D966E9AB59936070F1DA25760292967FE154628276`.
- Bukti: `verification/stage2-save-status.json`. File akhir belum ditutup/dibuka ulang; beberapa sesi Play dan bootstrap sudah diperiksa.
- Status setelah pekerjaan: **Edit**, simulator **default**, nol paket aktif atau Script uji sementara dalam place tersimpan. Play baru terbukti Idle, saldo 0, satu HUD.

Cadangan sebelum perubahan besar:

| Cadangan | Isi |
| --- | --- |
| `backups/main_game.before-T07-T10.20261107.rbxl` | Place tahap pertama, 107.594 byte; SHA-256 `427ABCA22663342A08E24009222A9DE954EBFA7AF285AEDC22445BF50396B089`. |
| `ServerStorage/PaketKilat_PreStage2_Backup` | Salinan script/shared/remotes/template tahap pertama melalui MCP. |
| `backups/studio-before-T07-T10-inspection.json` | Hasil inspeksi sebelum mutasi: lima sumber Edit, tinggi arena aktual, keberadaan spawn awal dan nama GUI; melengkapi cadangan file disk tahap pertama. Shortcut simpan awal tidak dapat diandalkan, sehingga cadangan file tidak diklaim mencakup perubahan Edit yang belum tersimpan saat itu. |
| `backups/main_game.before-T01-T06.20261106.rbxl` | Place awal sebelum implementasi, 88.600 byte; SHA-256 `8971F7A1C892BD85FDA63DF67A4E310EB6E2C7AA37E4A1B0C0C3933B9B77877F`. |
| `backups/handoff.T01-T06.md` | Handoff tahap pertama utuh, termasuk kontrak lama, hasil 28 pemeriksaan, dan keterbatasannya. |

## Inspeksi dan riwayat penting

Target MCP tetap Studio `f95030e1-cb9f-415f-ab90-cec8b8dfa7a8`, daftar koneksi Place1, DataModel Edit `main_game.rbxl`, PlaceId/GameId 0. Sebelum perubahan, lima script aktual cocok dengan sumber lokal. Studio mula-mula Play dan dihentikan untuk inspeksi Edit/cadangan.

**Pusat DepotPad aktual pada inspeksi tahap kedua (0,1045,0)** dipertahankan. Handoff tahap pertama mencatat Y=196; itu catatan historis, bukan posisi terbaru. Batas paket tetap relatif terhadap depot. Generator map lokal disesuaikan ke Y=1045 dan tidak dijalankan ulang pada map yang ada.

Baseplate, Camera, Terrain, dan spawn awal dalam `Workspace/OriginalContent/SpawnLocation` dipertahankan. Spawn prototipe tetap terpisah. Tahap pertama awalnya tidak mempunyai script; log lama pernah berisi error `Workspace.UnGroup...` mengenai Shared yang tidak ada. Script itu sudah tidak ada saat inspeksi awal; error tersebut bukan error bootstrap final.

Ambang benturan **55 stud/detik** dari tahap pertama dipertahankan: percobaan 24 terlalu sensitif pada jatuh 2 stud. Kerusakan 10, jeda kerusakan 1 detik, penalti pemulihan 20, cooldown pemulihan 5 detik, kondisi 0–100. Pemulihan mempertahankan ID/tujuan/waktu; pemain yang jatuh di bawah/di luar arena kembali ke spawn aman. Bukti tahap pertama dalam `verification/server-checks.json`, `physics-checks.json`, `keyboard-checks.json`, `walk-checks.json`, dan `fall-recovery-checks.json` tetap utuh; file baru tahap kedua memakai awalan `stage2-`.

## Struktur instance final

```text
Workspace
  Baseplate, Camera, Terrain
  OriginalContent/SpawnLocation
  PaketKilat
    Map
      DepotPad, HousePad
      SafeRoadDepot, SafeRoadAcross, SafeRoadHouse
      NarrowPlank
      Depot/BackWall, BackWallRight, Roof, PickupPoint/StartPrompt
      Rumah01/Body, Roof, Door, DestinationPoint
      RecoveryPoint, PrototypeSpawn
    ActivePackages
ReplicatedStorage/PaketKilat
  Shared/Config                                  ModuleScript
  Remotes/ActionRequest, StateChanged             RemoteEvent
ServerScriptService/PaketKilat
  Bootstrap                                      Script
  DeliveryService, PackageService                 ModuleScript
  EconomyService, PlayerLifecycle                 ModuleScript (baru)
ServerStorage
  PaketKilat/PackageTemplate                      Part + Label + PickupPrompt
  PaketKilat_PreStage1_Backup
  PaketKilat_PreStage2_Backup
StarterPlayer/StarterPlayerScripts/PaketKilatInput LocalScript
StarterGui/PaketKilatUI                           ScreenGui (baru)
  Root
    TopCard/Title, Coins, Destination, ConditionText, ConditionTrack/Fill, Hint
    Actions/Primary, Secondary
```

Penanda tujuan dibuat lokal oleh pengendali klien saat ada pesanan; berisi teks TUJUAN/nama rumah dan tetap tersedia walaupun model rumah tidak ter-stream. Prompt lama tetap disimpan tetapi dinonaktifkan; keyboard dan sentuh menggunakan tombol/handler HUD yang sama. Kontrol gerak dan kamera produksi tetap bawaan Roblox. Tidak ada aset marketplace atau script asing yang diimpor.

## File dan instance yang berubah

| File sumber | Instance/peran |
| --- | --- |
| `src/Config.luau` | Shared/Config: hadiah 25/15/10, target Rumah01 90 detik, jarak paket 15, saldo awal 0, offset spawn, interval UI; parameter fisika lama dipertahankan. |
| `src/DeliveryService.luau` | State/validasi, Deliver, snapshot sesi/posisi, transisi Delivered→Idle, pembersihan pemain. |
| `src/EconomyService.luau` (baru) | Saldo/count sesi, formula dan ledger ID yang sudah dibayar, salinan hasil. |
| `src/PlayerLifecycle.luau` (baru) | Bind/unbind pemain dan karakter; menjaga callback karakter lama tidak membatalkan karakter baru. |
| `src/Bootstrap.server.luau` | Inisialisasi Economy/Lifecycle, wiring request tiga argumen dan collision group. |
| `src/PackageService.luau` | Prompt ambil ulang dinonaktifkan untuk mencegah dua aksi; mekanik fisika lama tetap. |
| `src/PrototypeInput.client.luau` | Render HUD, proximity lokal, E/Q/R, Activated mouse/sentuh, pesan hasil/error, cooldown visual, penanda tujuan. |
| `src/BuildUI.luau` (baru) | Generator HUD Edit; sudah dijalankan sekali, menolak duplikasi. |
| `src/BuildMap.luau` | Generator diselaraskan dengan Y=1045 dan petunjuk aksi terbaru; tidak dipakai untuk membangun ulang map. |
| `design.md` | Spesifikasi v0.3, kontrak tahap kedua ditulis sebelum implementasi. Bagian 13 tetap riwayat tahap pertama. |
| `task_list.md` | T07–T09 dicentang berdasarkan bukti; T10 tetap terbuka, log lama dipertahankan. |
| `main_game.rbxl` | Tujuh script runtime, HUD, petunjuk depot/rumah/pemulihan, prompt nonaktif, cadangan objek. |
| `verification/Stage2*.luau`, `InspectHUD.luau` | Harness sementara untuk server, perjalanan, sentuh, keluar, dan layout. Tidak ada dalam place final. |
| `verification/stage2-*.json` | Hasil aktual dan status simpan; termasuk riwayat uji awal yang belum lulus. |

Tujuh script runtime cocok dengan sumber lokal pada audit akhir (`stage2-studio-manifest.json`). Tidak ada Rojo/sinkronisasi otomatis. Jangan menjalankan generator map/UI lagi pada place yang sudah berisi instance tersebut.

## Kontrak pesanan dan saldo

State server: `Idle → Carrying ↔ Dropped → Delivered → Idle`. Idle berarti tidak ada record aktif. Delivered adalah transisi internal sinkron; klien menerima Idle dengan `lastResult`.

Record pesanan tetap memuat `orderId` GUID unik, `ownerUserId`, `packageType=Biasa`, `destinationId=Rumah01`, `status`, `condition`, `startedAt`, `rewardProcessed`, `completionLocked`, `recoveryCount`, `lastRecoveryAt`, `outOfBounds`. Referensi Player/Part/weld/koneksi, cooldown `os.clock()`, dan sampel fisika hanya berada di server.

Snapshot selalu menambah:

| Field | Makna |
| --- | --- |
| `coins` | Bilangan koin sesi resmi. |
| `deliveryCount` | Jumlah pengantaran sah sesi. |
| `lastResult` | Salinan ringkasan terakhir atau nil; tetap tersedia saat kembali Idle. |
| `depotPosition`, `recoveryPosition`, `destinationPosition` | Vector3 server untuk HUD/proximity/penanda; tidak bergantung streaming rumah. |
| `destinationName` | Rumah Bu Sari ketika ada pesanan. |

Hasil terakhir: `orderId`, `destinationId`, `destinationName`, `duration`, `condition`, `recoveryCount`, `baseReward`, `conditionBonus`, `timeBonus`, `total`, `completedAt`. Waktu memakai `Workspace:GetServerTimeNow()`. Snapshot dan hasil adalah salinan; mengubah tabel snapshot tidak mengubah state resmi.

Formula saat ini:

```text
durasi = max(0, waktuSelesaiServer - startedAt)
hadiah = 25
       + floor(15 * kondisi / 100)
       + floor(10 * clamp(1 - durasi / 90, 0, 1))
```

Pemulihan tidak mengulang startedAt. Kondisi 0 tetap memperoleh dasar dan bonus waktu yang sah. Rekor belum dibuat (T14). EconomyService mempunyai ledger `creditedOrders[orderId]` per sesi, sehingga kredit ganda juga ditolak pada batas ekonomi. Ledger tidak disimpan antarserver.

Penyerahan memeriksa pemain hidup, pemilik/ID, Carrying, paket ada/tidak OOB, tujuan cocok, jarak pemain ≤12 dan paket ≤15 stud dari DestinationPoint. Server memperoleh kunci, mengubah status Delivered, menandai kredit sebelum menambah saldo, lalu menghancurkan paket/koneksi dan kembali Idle. Tidak ada yield di rangkaian validasi/kredit tersebut.

Mati/reset membatalkan pesanan tanpa hadiah tetapi mempertahankan coins/count sesi. Keluar menghapus semuanya; sesi baru mulai 0. Belum ada saldo permanen, toko, pembelian, atau DataStore.

## Kontrak RemoteEvent

Path `ReplicatedStorage/PaketKilat/Remotes`.

```lua
-- Player diterima otomatis oleh OnServerEvent; bukan argumen klien.
ActionRequest:FireServer(action, orderId?, destinationId?)
StateChanged:FireClient(player, snapshot, resultCode)
```

| Aksi | Pemeriksaan server |
| --- | --- |
| Start | Hidup, belum ada pesanan, dekat PickupPoint. |
| Pickup | ID sendiri, Dropped, tidak OOB, dekat paket. |
| Drop | ID sendiri, Carrying. |
| Recover | ID sendiri, Dropped, hidup, cooldown 5 detik; tidak perlu dekat paket yang hilang. |
| Deliver (baru) | ID sendiri, tujuan benar, status/paket/jarak sah; kredit hanya sekali. |
| Sync | Mengirim snapshot milik pemain tersebut. |

Action string maksimal 16 byte; ID/tujuan maksimal 64 byte jika diberikan. Deliver memerlukan destinationId string; aksi lain menolak destinationId tambahan. Tidak menerima kondisi, jumlah hadiah, posisi, atau identitas pemilik dari klien. Batas 0,2 detik per pemain diperiksa sebelum payload, termasuk payload salah. RateLimited tidak menghasilkan reply remote terus-menerus.

Kode sukses/peristiwa: Start, Pickup, Drop, Recover, Delivered, Sync, Impact, OutOfBounds, Respawned, Cancelled. Penolakan: InvalidArguments, UnknownAction, PlayerInactive, NotAlive, OrderActive, TooFar, NotOwnerOrStale, InvalidState, CompletionLocked, WrongDestination, RecoveryCooldown. AlreadyRewarded adalah guard ekonomi internal. Replay normal setelah selesai menghasilkan NotOwnerOrStale; tidak menambah uang.

## HUD dan kontrol

HUD kiri menampilkan nama tujuan, kondisi numerik/bar, saldo, petunjuk, pesan kejadian, dan komponen hadiah. Primary/Secondary berada di kanan; keyboard E memilih aksi utama kontekstual, Q melepas, R memulihkan. Teks keyboard disembunyikan pada sentuh. Tombol yang belum memenuhi kedekatan/status/cooldown dinonaktifkan; server tetap memeriksa ulang ketika menerima request.

Orientasi prototipe `LandscapeSensor`, inset `CoreUISafeInsets`, tombol 152×48. ContextActionService tidak membuat tombol duplikat. Poll kedekatan hanya lokal setiap 0,1 detik; tidak ada polling remote. UI tetap satu setelah respawn.

## Hasil verifikasi tahap kedua

| Bukti | Hasil |
| --- | --- |
| `stage2-server-checks.json` | **43/43 lulus**: tujuan/jarak/paket/pemilik, payload hadiah, spam, tiga formula 40/42/25, maksimum 50, kondisi 0, replay segera/tertunda/saat pesanan baru, guard ekonomi, snapshot, pemulihan, respawn Carrying/Dropped, saldo, koneksi, pesanan baru. |
| `stage2-journey-checks.json` | Tiga perjalanan safe road memakai Humanoid:MoveTo dan E/Q/R aktual. Hadiah **47 / 40 / 46**, kondisi **100 / 80 / 100**, durasi sekitar **20,83 / 58,82 / 30,77 detik**; total 133, saldo 144→277. Saldo awal 144 berasal dari harness server. Putaran 2 juga memuat lepas/ambil ulang, jatuh nyata di samping papan, pemulihan dan ambil ulang. |
| `stage2-touch-cycle.json` | iPhone 17 Pro emulator: ambil, lepas, ambil ulang, lepas/pulih, ambil ulang, joystick menyeberangi papan dan antar. **8 Touch began, 0 Keyboard**, kondisi 80, durasi sekitar 27,07 detik, hadiah **43**, saldo 0→43. Setup posisi awal saja memakai teleport; tidak ada MoveTo/teleport untuk perjalanan sentuh setelah setup. |
| `stage2-desktop-layout.json` | Desktop 1350×961; teks muat, elemen dalam area HUD, panel dan tombol tidak tumpang tindih. |
| `stage2-iphone17pro-active-layout.json`, `stage2-iphone17pro-result-layout.json` | Preset 874×402 landscape, viewport aman aktual 750×381. HUD aktif/hasil terbaca dan tombol terpisah dari lompat pada tangkapan layar. |
| `stage2-galaxy-a06-layout.json` | Preset 800×360, viewport aktual 705×338. Layout aktif, kedua tombol dan teks muat; diperiksa visual terhadap lompat. |
| `stage2-exit-checks.json` | PlayerRemoving nyata lewat Kick lokal: paket/koneksi/pesanan/request cache/lifecycle/session hilang, saldo 43 tidak bertambah sebelum dibuang, nol paket tertinggal. |
| `stage2-fresh-session.json` | Play baru: Idle, coins 0, tepat satu HUD, simulator default; console hanya bootstrap siap tanpa error baru. |
| `stage2-studio-manifest.json` | Tujuh script cocok sumber, original spawn tersedia, nol paket/Script uji di Edit; posisi map dipertahankan. |
| `stage2-save-status.json` | Simpan file lokal terverifikasi lewat ukuran/waktu/hash disk. |

Uji server awal memakai durasi fixture tepat 45 detik; saat request diproses durasi sudah lewat batas sehingga bonus floor berkurang satu. Fixture digeser ke 44 detik dan seluruh uji diulang pada sesi baru; riwayat gagal tetap di `stage2-initial-server-checks.json`. Ini koreksi nilai harapan uji, bukan perubahan formula.

Beberapa percobaan emulator sempat tercampur input keyboard/Studio dihentikan dan tidak dipakai untuk kelulusan. Setelah koordinasi, siklus sentuh diulang pada sesi bersih dengan pencatatan input. Koordinat drag joystick dikalibrasi pada GUI emulator; kamera harness diarahkan tetap sepanjang papan. Pengendali/kamera uji tersebut sementara dan tidak ada dalam place final.

## Batas verifikasi dan masalah tersisa

- **T10 belum selesai.** Pemilik sempat menggunakan Studio tetapi belum memberikan laporan hasil; aktivitas itu tidak dianggap persetujuan penerimaan.
- HP asli, FPS/performa, kenyamanan kamera sentuh, jaringan lambat, avatar lain, dua/delapan klien belum diuji. Emulator membuktikan input/layout pada konfigurasi uji, bukan pengalaman perangkat asli. T20/T22 tetap terbuka.
- Game tetap satu rumah/paket biasa/rintangan papan. T11, paket rapuh, audio, rekor, progres permanen, kosmetik dan monetisasi belum dikerjakan.
- Otoritas/validasi server mengurangi penyalahgunaan request; ini bukan sistem antieksploit gerak penuh. Karakter masih memakai replikasi fisika Roblox biasa.
- File tersimpan belum ditutup/dibuka ulang. Shortcut Ctrl+S tidak dapat diandalkan pada sesi ini; gunakan File > Save to File dan periksa waktu tulis bila menyimpan manual.
- Keseimbangan hadiah/target 90 detik dan ambang benturan masih nilai prototipe. Penilaian rasa bermain menunggu pemilik.

## Cara mencoba dan mencatat T10

1. Buka `main_game.rbxl`, tekan Play; saldo sesi baru mulai 0.
2. Dekati kotak kuning depot. Tekan E atau tombol **Ambil pesanan**.
3. Ikuti tujuan Rumah Bu Sari. Jalan aman melalui lorong belakang depot dan rute U; papan kayu adalah pintasan.
4. Dekati petak depan rumah; tekan E atau **Antar**. Lihat rincian hadiah dan kenaikan saldo, lalu kembali ke depot.
5. Ulangi sampai tiga pengantaran. Coba Q/**Lepas**, E/**Ambil ulang**, serta R/**Pulihkan**. Pemulihan -20 kondisi dan cooldown 5 detik.
6. Coba jatuh dari samping papan lalu Pulihkan; pemain di bawah arena kembali ke depot. Coba Reset saat membawa/lepas: pesanan hilang, saldo tetap, dan pesanan baru bisa diambil.
7. Pada emulator/HP landscape, gunakan joystick, lompat, dan tombol aksi yang sama tanpa keyboard.

Kirim hasil dengan format singkat:

```text
Perangkat / desktop atau emulator atau HP asli:
Tiga pengantaran: berhasil/gagal; hadiah yang terlihat:
Jatuh → pulihkan → ambil ulang:
Reset → pesanan baru; saldo:
Bagian membingungkan / bug:
Rasa kontrol dan apakah ingin mengulang:
```

T10 tetap terbuka sampai hasil ini diterima dan ditinjau. Jangan lanjut ke T11 tanpa arahan baru.
