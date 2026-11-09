# Paket Kilat! — Handoff tahap T01–T06

Tanggal: 6 November 2026 (Asia/Jakarta). T01–T06 selesai; T07 dan seterusnya belum dikerjakan. Target satu paket dapat diambil, dibawa, dilepas, diambil ulang, dan dipulihkan sudah diuji pada satu klien komputer di Studio Play.

## Place, cadangan, dan penyimpanan

- Proyek: `D:\YANG CORPORATE\Roblox\Game1`.
- Target MCP: Studio `f95030e1-cb9f-415f-ab90-cec8b8dfa7a8`, daftar koneksi menampilkan Place1; DataModel Edit bernama `main_game.rbxl`, PlaceId/GameId 0. Judul jendela Windows cocok dengan path proyek.
- Inspeksi awal: Camera, Terrain kosong, Baseplate (2048×16×2048, pusat 0,-8,0), SpawnLocation (12×1×12, pusat 0,0.5,0), tanpa script game.
- Output awal memuat error historis `Workspace.UnGroup.ServerScriptService.Server.Data` tentang `ReplicatedStorage.Shared`. Instance tersebut tidak ada pada inspeksi; itu bukan error bootstrap PaketKilat. Sesi uji baru tidak menghasilkan error runtime dari lima script final.
- Cadangan penuh dibuat sebelum mutasi: `backups/main_game.before-T01-T06.20261106.rbxl`, 88.600 byte. Hash awal dan cadangan cocok: `8971F7A1C892BD85FDA63DF67A4E310EB6E2C7AA37E4A1B0C0C3933B9B77877F`.
- MCP juga membuat `ServerStorage/PaketKilat_PreStage1_Backup` berisi Baseplate dan SpawnLocation. Ini cadangan objek, bukan pengganti cadangan file penuh. Percobaan clone Terrain awal ditolak sebelum perubahan; Terrain tidak diubah.
- Baseplate, Terrain, Camera dipertahankan. Spawn awal sempat tidak ada pada audit berikutnya dan dipulihkan dari cadangan, dengan posisi/ukuran awal, di `Workspace/OriginalContent/SpawnLocation`. Spawn prototipe terpisah; bootstrap memilihnya untuk pemain.
- **Place telah disimpan lokal** melalui Ctrl+S pada jendela target yang diverifikasi, setelah Stop/masuk Edit. MCP tidak menyediakan tool simpan file lokal, sehingga hanya langkah simpan memakai shortcut jendela Windows. Verifikasi disk: `main_game.rbxl`, 107.594 byte, waktu tulis 6 November 2026 23:54:50 WIB, SHA-256 `427ABCA22663342A08E24009222A9DE954EBFA7AF285AEDC22445BF50396B089`.
- Audit sebelum simpan: lima script game cocok dengan sumber lokal; tidak ada paket aktif atau Script uji sementara di Edit. Cadangan awal tetap utuh. Buka ulang setelah simpan belum terkonfirmasi: percobaan Open pada audit terakhir bertepatan dengan Studio kembali ke Play, sehingga tidak dicatat lulus. Kemampuan menjalankan place diperiksa melalui beberapa sesi Play. Hash file akhir diperiksa kembali dan tetap sama. Studio berada di Play pada pemeriksaan terakhir. Tidak ada publikasi, pembelian, atau monetisasi.

## Struktur objek dan script

```text
Workspace
  Baseplate, Terrain, Camera                    # objek awal
  OriginalContent/SpawnLocation                 # spawn awal dipertahankan
  PaketKilat
    Map
      DepotPad, HousePad
      SafeRoadDepot, SafeRoadAcross, SafeRoadHouse
      NarrowPlank
      Depot/BackWall, BackWallRight, Roof, PickupPoint/StartPrompt
      Rumah01/Body, Roof, Door, DestinationPoint
      RecoveryPoint
      PrototypeSpawn
    ActivePackages                             # kosong dalam Edit
ReplicatedStorage/PaketKilat
  Shared/Config                                # ModuleScript
  Remotes/ActionRequest, StateChanged           # RemoteEvent
ServerScriptService/PaketKilat
  Bootstrap                                    # Script
  DeliveryService, PackageService               # ModuleScript
ServerStorage
  PaketKilat/PackageTemplate                    # Part + Label + PickupPrompt
  PaketKilat_PreStage1_Backup/Baseplate, SpawnLocation
StarterPlayer/StarterPlayerScripts/PaketKilatInput # LocalScript
```

Setiap tanda map menggunakan BillboardGui/TextLabel. Template paket adalah Part sederhana dengan ProximityPrompt dan label pemilik, tujuan, status, kondisi. Seluruh visual memakai bentuk/warna bawaan; tidak ada aset marketplace atau script asing yang diimpor. StarterGui/HUD, ekonomi, data, kosmetik, dan telemetri belum dibuat.

Pusat DepotPad saat ini (0,196,0); lantai atas Y=197. Rumah berada 100 stud ke arah +X. Jalan aman membentuk U ke Z=-40; papan pintas panjang 72, lebar 3 stud pada Z=0. Lorong belakang depot selebar 4 stud menyambung jalan aman. RecoveryPoint (8,197.15,4); spawn (-6,197.5,5). Batas paket relatif terhadap pusat DepotPad, sehingga ketinggian arena dapat diubah tanpa memperbarui koordinat batas.

## File yang dibuat atau diubah

| File | Peran |
| --- | --- |
| `design.md` | Spesifikasi v0.2; kontrak tahap pertama, ambang benturan, batas relatif arena, pemulihan pemain jatuh, lorong depot. Diperbarui sebelum perubahan perilaku. |
| `task_list.md` | Status T01–T06, bukti penerimaan, batas uji; T07+ tetap terbuka. |
| `main_game.rbxl` | Place final yang disimpan lokal. |
| `backups/main_game.before-T01-T06.20261106.rbxl` | Cadangan place awal. |
| `src/Config.luau` | Parameter gameplay tunggal. |
| `src/BuildMap.luau` | Sumber generator map Edit; hanya untuk place bersih setelah inspeksi, menolak map PaketKilat yang sudah ada. Jangan jalankan pada place final. |
| `src/Bootstrap.server.luau` | Wiring layanan, remotes, prompt, collision group, karakter, pembersihan dasar. |
| `src/DeliveryService.luau` | Pesanan, validasi, transisi, cooldown, kontrak penyelesaian internal. |
| `src/PackageService.luau` | Clone paket, weld, fisika lepas, raycast benturan, batas dunia, label. |
| `src/PrototypeInput.client.luau` | Tombol Q/R dan tombol sentuh bawaan ContextActionService sementara. |
| `verification/*.luau` | Harness uji server, fisika, berjalan, jatuh/pemulihan; hanya dipasang sementara dalam Play, tidak ada dalam place tersimpan. |
| `verification/*.json` | Hasil aktual server, fisika, keyboard, rute, pemulihan, manifest, penyimpanan; `initial-trials.json` menyimpan percobaan awal yang belum lulus. |
| `handoff.md` | Dokumen ini. |

Sumber lima script runtime cocok dengan instance pada audit akhir (`studio-manifest.json`). Tidak ada sinkronisasi otomatis/Rojo; perubahan berikutnya harus disalin melalui MCP dan diperiksa kecocokannya.

## Kontrak data pesanan

Satu record per `UserId`, hanya di memori server. Tanpa record berarti Idle. Tahap ini memakai `Carrying ↔ Dropped`; Delivered dan hadiah belum aktif.

| Field snapshot | Tipe / makna |
| --- | --- |
| `orderId` | GUID string dari server. |
| `ownerUserId` | number, identitas pemilik yang diterima server. |
| `packageType` | string `Biasa`; paket rapuh belum aktif. |
| `destinationId`, `destinationName` | `Rumah01`, `Rumah Bu Sari`. |
| `status` | Idle jika tiada record; Carrying atau Dropped jika aktif. |
| `condition` | number 0–100, awal 100. |
| `startedAt` | waktu server `Workspace:GetServerTimeNow()`. |
| `rewardProcessed`, `completionLocked` | boolean, awal false; penguncian internal disiapkan untuk T07. |
| `recoveryCount`, `lastRecoveryAt` | jumlah pemulihan; waktu server atau -1 sebelum pemulihan pertama. |
| `outOfBounds` | boolean; paket di luar batas ditahan anchored agar tidak terhapus mesin. |

Snapshot baru disalin per pengiriman, bukan referensi tabel resmi. Record server juga menyimpan Player, Part paket, weld, koneksi prompt, sampel gerak, dan waktu cooldown internal `os.clock()`; field internal itu tidak dikirim ke klien. Pulih mempertahankan ID, tujuan, startedAt, status Dropped; mengurangi kondisi 20 dan menambah recoveryCount. Kondisi 0 tetap bisa diambil. Tidak ada saldo atau hadiah pada tahap ini.

`DeliveryService.ValidateCompletion(player, orderId, destinationId)` memeriksa pemilik, ID, Carrying, tujuan, jarak, dan lock. `LockCompletion` memperoleh kunci satu kali tanpa memberi hadiah atau menyelesaikan pengantaran. Ini kontrak internal T04, belum terhubung aksi klien dan belum mengimplementasikan T07.

## Kontrak RemoteEvent

Path: `ReplicatedStorage/PaketKilat/Remotes`.

| Arah | Kontrak |
| --- | --- |
| Klien → server | `ActionRequest:FireServer(action, orderId?)`. `action` string maksimal 16 karakter, ID maksimal 64 karakter jika ada. Player berasal dari OnServerEvent, tidak dikirim klien. |
| Server → pemilik | `StateChanged:FireClient(player, snapshot, resultCode)`. Idle hanya mengandung status. Tidak mengirim state pesanan pemain lain. |

- `Start`: tanpa ID, hanya pemain hidup dalam 12 stud dari PickupPoint dan belum mempunyai pesanan. Paket langsung Carrying.
- `Pickup`: ID pesanan sendiri, status Dropped, tidak OOB, dalam 12 stud dari paket.
- `Drop`: ID sendiri dan Carrying.
- `Recover`: ID sendiri, Dropped, pemain hidup, cooldown 5 detik. Tidak memerlukan jarak ke paket yang hilang. Paket kembali ke RecoveryPoint. Pemain di bawah/di luar arena kembali ke spawn; pemain yang masih di arena tidak dipindahkan.
- `Sync`: meminta snapshot, juga terkena batas frekuensi.
- Jeda permintaan 0,2 detik per pemain. Penolakan `RateLimited` tidak dibalas listener remote agar spam tidak menghasilkan reply terus-menerus.
- Penolakan lain: `InvalidArguments`, `UnknownAction`, `NotAlive`, `OrderActive`, `TooFar`, `NotOwnerOrStale`, `InvalidState`, `CompletionLocked`, `RecoveryCooldown`. Pemeriksaan tujuan internal menambah `WrongDestination`.
- Tidak ada aksi Deliver; tidak menerima posisi, kondisi, kecepatan benturan, pemilik, atau jumlah hadiah dari klien.
- ProximityPrompt depot/paket memanggil validasi service yang sama. Prompt paket dapat terlihat pemain lain, tetapi server menolak pengambilannya.

## Fisika dan konfigurasi

WeldConstraint menempelkan paket 2,5 stud di depan HumanoidRootPart. Paket dibawa massless/tanpa tabrakan. Paket lepas memiliki network owner nil (server). Grup `PKCharacters` tidak bertabrakan antarkarakter; `PKDropped` tidak bertabrakan dengan karakter atau paket lain; map tetap bertabrakan. Grup ditetapkan bootstrap saat server dimulai.

Server menyampel kecepatan dan posisi melalui Heartbeat (target interval 1/30 detik). Benturan membutuhkan kecepatan sebelumnya dan raycast kontak/lintasan dengan normal permukaan yang sesuai; tidak memakai laporan benturan klien atau satu Touched. Saat membawa, yang diuji adalah laju turun karakter; saat lepas, laju paket. Semua karakter dan paket aktif dikecualikan dari raycast.

Ambang final prototipe 55 stud/detik, kerusakan 10, jeda kerusakan 1 detik. Batas relatif depot minimum (-24,-14,-55), maksimum (124,96,24). Semua nilai mekanik dapat ditinjau di Config. Ini belum sistem antieksploit fisika penuh; karakter memakai replikasi gerak Roblox biasa.

## Bukti pengujian dan batasnya

| Bukti | Hasil |
| --- | --- |
| `server-checks.json` | 28/28 lulus: data resmi, satu pesanan, argumen/aksi/ID, pemilik, jarak, snapshot terpisah, kunci penyelesaian sekali, lepas/ambil ulang, network owner, damage debounce, recovery cooldown, batas, kondisi 0, pembersihan dasar. |
| `physics-checks.json` | Ambang 55: jatuh paket 0,1/1/2/6 stud tetap 100; 12 stud menjadi 90, laju maksimal sekitar 69,49. Jatuh membawa paket: laju sekitar 62,13 → Dropped/90. |
| `keyboard-checks.json` | E/Q/E/Q/R/E lulus pada pesanan yang sama; pemulihan 100→80. |
| `walk-checks.json` | 14 waypoint depot–rumah–depot ditempuh memakai Humanoid:MoveTo; kondisi tetap 100, maxCarryError teramati 0. Hanya setup awal memakai teleport. |
| `fall-recovery-checks.json` | Jatuh nyata dari samping papan: Dropped/OOB, pemain di bawah arena, Recover mengembalikan ke depot, ID tetap, kondisi 80, berjalan dan ambil ulang menjadi Carrying. |
| `studio-manifest.json` | Lima script cocok dengan file sumber, 16 bagian map, objek awal dan nol paket aktif pada audit Edit. |
| `initial-trials.json` | Riwayat gagal awal. Ambang 24 merusak pada jatuh 2 stud; harness awal terkena cooldown benturan sebelum pemeriksaan eksplisit. Setelah spesifikasi/angka dan isolasi uji diperbaiki, uji akhir lulus. |

Uji memakai satu klien komputer. Pemeriksaan pemilik asing memakai identitas simulasi pada service, bukan dua pemain nyata. Emulator sentuh, HP asli, ragam avatar, jaringan lambat, kapasitas dua/delapan pemain, serta performa HP belum diperiksa. Tombol sentuh bawaan tersedia dalam kode tetapi **belum dinyatakan lulus**. Reset/keluar mempunyai pembersihan dasar; audit lengkap tetap T09/T20. Pembukaan ulang file tersimpan belum terkonfirmasi. Pengantaran, hadiah, HUD penuh, audio, profil permanen, dan monetisasi belum dibuat.

## Cara mencoba

1. Buka `main_game.rbxl`, tekan Play. Pemain muncul di depot tinggi.
2. Dekati kotak kuning dan tahan E sebentar untuk mengambil pesanan. Paket dan label tujuan/kondisi muncul.
3. Berjalan melalui lorong belakang depot dan jalan abu-abu berbentuk U menuju Rumah Bu Sari, lalu kembali. Papan kayu sempit adalah pintasan.
4. Tekan Q untuk melepas; dekati paket dan tahan E untuk mengambil ulang.
5. Lepaskan lagi lalu tekan R: paket berpindah ke petak biru depot dan kondisi berkurang 20. Jeda pemulihan 5 detik. Dekati dan ambil ulang dengan E.
6. Coba jatuh dari samping papan sambil membawa paket; setelah paket Dropped, tekan R. Pemain yang jatuh kembali ke depot bersama pemulihan paket. Pesanan tetap sama. Untuk pesanan baru, reset karakter atau Stop lalu Play.

Rumah hanya tujuan percobaan; belum menerima paket atau memberi koin. Berhenti pada T06. Pekerjaan berikutnya memerlukan permintaan baru untuk T07.
