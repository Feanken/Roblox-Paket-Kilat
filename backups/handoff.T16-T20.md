# Paket Kilat! — Handoff T16–T20

Tanggal: 7 November 2026, Asia/Jakarta. **T01–T20 selesai; berhenti sebelum T21.** Tidak ada Publish, Save to Roblox, pembelian, Robux, unggahan aset, atau biaya oleh asisten.

## Hasil dan riwayat yang dipertahankan

Profil, penyimpanan DataStore uji, toko tas dan validasi server tersedia. Dua dan delapan klien nyata Studio diuji; progres benar-benar bertahan di antara sesi Studio berbeda. Cadangan dan log tahap sebelumnya tidak dihapus. Handoff T11–T15 lengkap di `backups/handoff.T11-T15.md`; tahap T01–T10 juga tetap pada arsip/log lama.

T10 diterima pemilik (“sudah mencoba bisa lanjukan 11-15”). Perangkat/rincian putaran tidak diberikan; tidak ditafsirkan sebagai uji HP asli. Arena aktual tetap Y1045; catatan lama Y196 adalah riwayat. Lima rumah, dua tipe Biasa/Rapuh, papan/genangan/penghalang, penalti pulih20/cooldown5, formula hadiah dan kelayakan rekor tanpa pemulihan dipertahankan. Rekor sekarang disimpan dalam profil. Urutan pesanan dan hasil terakhir tetap hanya sesi.

## Place, izin, cadangan dan simpan

- Place uji yang dibuka pemilik: **121172771262094**, universe **10775037187**, nama Place Uji DataStore. Inspeksi MCP menemukan map/script Paket Kilat sebelum mutasi.
- Skill MCP `rbx-permissions` diperiksa sebelum akses. Place lokal ids0 menolak handle DataStore (harus diterbitkan); asisten tidak menerbitkannya. Place uji pertama menolak baca dengan502 Access forbidden. Pemilik mengaktifkan Save & load data/read+update serta Studio API Services, lalu probe baca dan UpdateAsync berhasil. Tidak melewati penolakan melalui runtime alternatif.
- Namespace tunggal: DataStore **PaketKilat_TEST_v1**, scope **T16_T20_QA**, key **qa:<UserId>**. Adapter menolak universe lain dan nama/scope/prefix lain. Tidak ada Open Cloud DataStore atau key publik yang diakses.
- Fixture tersisa hanya di namespace uji: `qa:permission_probe`, `qa:-160017`, pemain Studio `qa:-1` sampai `qa:-8`, serta akun Play `qa:4737266825`. Tidak dihapus/reset; angka rekor fixture sangat singkat karena teleport setup, bukan catatan perjalanan manusia.
- Cadangan penuh sebelum tahap: `backups/main_game.before-T16-T20.20261107.rbxl`,132.975 byte, SHA256 C0A907742DA67025104FD51425205CB076D6B171F2F1899A868F1C4C7893BE4A. Isi scoped sebelum mutasi place uji disalin ke `ServerStorage/PaketKilat_PreStage4_Backup`. Cadangan tahap1–3 tetap ada.
- **Simpan lokal berhasil** memakai File > Download a Copy (menu untuk place cloud), tujuan `D:\YANG CORPORATE\Roblox\Game1\main_game.rbxl`. Ukuran **142.107 byte**, waktu **2026-11-07 07:34:27 WIB**, SHA256 **7AF5E4C39F92FD01D5DEC6B40CF84E9169D03F42E6F86E12DCF76F729873BFAF**. Log Studio mengakui unduhan selesai. Pemeriksaan hash awal sebelum download selesai masih membaca file lama; hanya hash akhir ini dipakai sebagai bukti.
- Tidak melakukan Save to Roblox/Publish. Perubahan place uji yang terbuka ada di Studio dan salinan lokal; jangan menganggap versi terbit sudah diperbarui. Studio akhir Edit, simulator default,0 paket aktif,0 harness QA.
- **Buka ulang berhasil** pada proses Studio terpisah: main_game.rbxl mempunyai PlaceId/GameId0,13 sumber tepat sama dengan manifest sebelum simpan, cadangan Stage4 tersedia,0 paket/QA. Play baru Ready/0 koin menampilkan banner StudioMemory yang benar, console bootstrap tanpa error. Sudah Stop kembali ke Edit. Bukti: stage4-reopen.json dan stage4-local-fresh.json. Percobaan menu Open sebelumnya gagal menemukan elemen UI; pembukaan lewat executable Studio terpisah yang berhasil digunakan sebagai bukti.

## Struktur dan sumber yang berubah

```text
ServerScriptService/PaketKilat
  Bootstrap (Script)
  DeliveryService, PackageService, EconomyService, PlayerLifecycle, HazardService
  DataService, StorageBackend, StorageConfig, ProfileSchema, CosmeticService (ModuleScripts baru)
ReplicatedStorage/PaketKilat
  Shared/Config
  Remotes/ActionRequest, StateChanged (tetap dua RemoteEvent)
Workspace/PaketKilat/Map/Depot/ShopPoint (baru)
StarterGui/PaketKilatUI/Root
  TopCard, Actions (dipertahankan)
  StorageStatus, ShopToggle, Shop (baru; 4 baris tas, tombol beli/pakai/tutup)
StarterPlayer/StarterPlayerScripts/PaketKilatInput
Character/PaketKilatBag (Part + WeldConstraint runtime, maksimal satu)
ServerStorage/PaketKilat_PreStage4_Backup
```

Lima sumber baru di `src`: StorageConfig, ProfileSchema, StorageBackend, DataService, CosmeticService. Sumber lama yang diubah: Bootstrap.server, EconomyService, DeliveryService, PlayerLifecycle, Config, PrototypeInput.client. `UpgradeStoreUI.luau` merupakan migrasi Edit aditif, **jangan dijalankan dua kali**. PackageService/HazardService dan map kampung lama dipertahankan. Bootstrap menambah pengecualian tabrakan PKCarried↔PKCarried/PKDropped.13 sumber runtime pada place cocok file lokal; manifest di verification.

Seluruh script pemeriksaan `verification/Stage4*` adalah harness sementara, bukan script produksi. Script/Remote QA/fixture runtime sudah dibuang; modul isolasi uji juga dihancurkan. Objek awal Baseplate/Terrain/Camera dan OriginalContent/SpawnLocation tetap dipertahankan. Tas baru dibuat dari primitive kode proyek, dicatat di `asset_sources.md`.

## Data profil dan mekanisme penyimpanan

```lua
profile = {
  schemaVersion = 1,
  coins = 0, deliveryCount = 0, -- integer 0..1e9
  ownedCosmetics = { TasStandar = true }, -- set ID katalog
  equippedCosmetic = "TasStandar", -- wajib dimiliki
  bestTimes = { ["Rumah01|Biasa"] = 12.34 }, -- finite, >0; tujuan/tipe sah
}
envelope = {
  envelopeVersion = 1, profile = profile,
  revision = 1, updatedAt = unixTime, lastCommitId = "GUID",
  lock = { token = "GUID", owner = "server-session-GUID", expiresAt = unixTime },
}
-- lock={} setelah release; schemaVersion0 DI DALAM envelope dimigrasi.
```

Default hanya dibuat ketika UpdateAsync melihat nil dan berhasil. v0 wajib mempunyai saldo integer sah; field baru diberi default, saldo dipertahankan. Versi masa depan, envelope/profil rusak, equipment tak dimiliki dan rekor tak sah ditolak tanpa menimpa data. Tidak ada secret dalam shared/client.

StorageConfig server: lease120 detik, margin15, autosave/renew30,3 percobaan dengan backoff0,5 lalu1 detik, batas BindToClose25 detik. Semua operasi memakai **UpdateAsync**, transform tanpa yield; budget diperiksa sebelum request. Load mengunci profil dengan token unik; lock server lain yang belum habis ditolak. Save memverifikasi token+expiry, snapshot profil dan revision. Commit ID stabil selama retry mencegah commit ulang setelah respons hilang. Mutasi selama save tetap dirty untuk save berikutnya.

Profil Loading/Failed/Lost/Closing atau lease mendekati habis tidak boleh mengubah ekonomi. Gagal load tidak mempunyai profil yang boleh disimpan; tidak pernah fallback ke profil kosong. Gagal save menahan dirty dan mencatat warn/RetryPending; tick mencoba lagi. Lease hilang membatalkan pesanan dan membekukan ekonomi. Keluar membersihkan binding/order/efek/ekonomi lalu release profil; leave saat load/save berlangsung ditangani. BindToClose menyimpan/melepas profil paralel dengan batas global. Crash/layanan gagal sampai batas akhir tetap bisa kehilangan perubahan terakhir; lease mencegah sesi lama menimpa server baru.

Mode **DataStoreTest** hanya universe uji tersebut. File lokal dengan GameId0 memilih **StudioMemory** eksplisit; backend ini dilarang di runtime non-Studio. HUD menulis “UJI LOKAL · progres hilang saat Stop”. Ini bukan fallback dari gagal DataStore. Untuk menguji persistensi gunakan place uji dengan API Services aktif. Universe selain yang dikonfigurasi sengaja terkunci.

## Ekonomi, kosmetik dan kontrak RemoteEvent

Koin/count/rekor/owned/equipped memakai referensi profil yang telah tervalidasi; pembelian/pengantaran tidak yield. Data ditandai dirty setelah mutasi, penyimpanan dijadwalkan terpisah. `creditedOrders` dan rewardProcessed/completionLocked tetap mencegah kredit ulang; request ID lama setelah order selesai ditolak. Angka hadiah tetap25+bonus kondisi15+bonus waktu10. Durasi minimum0,001 detik menjaga rekor serializable; ini tidak membuat teleport sebagai perjalanan sah untuk validasi produk.

Katalog Config: TasStandar0, TasMerah50, TasBiru75, TasHijau100. Beli/pakai memerlukan profil Ready, karakter hidup dan jarak≤12 stud dari ShopPoint depot. ID/ownership/saldo diperiksa server, harga dari Config server. Duplikat mengembalikan AlreadyOwned tanpa memotong lagi; NotOwned/InsufficientCoins/UnknownCosmetic menolak. Membeli tidak otomatis memakai. Tas berwarna ditempel server ke torso, massless/noncolliding; tidak mengubah WalkSpeed. Pilihan diterapkan kembali saat respawn.

```lua
ActionRequest:FireServer(action, orderIdOrCosmeticId?, destinationId?)
StateChanged:FireClient(player, snapshot, resultCode)
-- lama: Start/Pickup/Drop/Recover/Deliver/Sync
-- baru: BuyCosmetic, EquipCosmetic; arg2 ID katalog, arg3 nil
```

Action maksimum16 byte, ID/tujuan64, argumen keempat ditolak. Tipe dan allowlist diperiksa sebelum akses state; throttle0,2 detik termasuk payload salah. Start/Sync menolak ID tambahan. Sync boleh membaca status profil belum siap; aksi lain perlu Ready. Identitas Player berasal OnServerEvent. Tidak ada remote grant koin/harga/kondisi/waktu/save/profile.

Snapshot lama dan order/state Carrying/Dropped/Delivered tetap. Field baru: `profileOwnerUserId`, `profileReady`, `profileStatus` (Loading/Ready/Failed/Lost/Closing), `storageMode`, `saveStatus` (Loading/Pending/Saving/RetryPending/Acknowledged), salinan ownedCosmetics/equippedCosmetic. coins/count/rekor tidak dikirim saat profil belum siap; HUD saldo— dan aksi terkunci. Acknowledged berarti backend mengakui snapshot terakhir; mode memori tidak ditampilkan sebagai tersimpan permanen. Snapshot awal yang terlewat dipulihkan dengan Sync ulang tiap1 detik selama Loading.

Kode baru: ProfileReady/ProfileUnavailable/StorageStatus/Purchased/Equipped/AlreadyOwned/InsufficientCoins/NotOwned/UnknownCosmetic/EconomyLimit. Kontrak kesalahan dan input E/Q/R lama tetap. B/tombol Toko membuka katalog dan menonaktifkan aksi pesanan selama toko terbuka.

## Bukti pengujian

| Bukti dalam verification | Hasil dan batas |
| --- | --- |
| stage4-permissions.json, stage4-cloud-adapter.json | Probe baca+tulis riil berhasil hanya namespace uji. Dua manager berurutan memuat nilai meningkat0→1 di qa:-160017. |
| stage4-profile-checks.json | **59/59**: schema/default/migrasi/versi rusak, nilai nonfinite, lock asing/takeover/stale save, failed-load tanpa overwrite, retry/backoff, dirty/save outage, respons commit/release hilang, perubahan selama save, leave saat load, lease margin dan ekonomi gagal profil. Backend INJEKSI, bukan cloud outage riil. |
| stage4-two-clients.json | **65/65**,2 klien nyata (-2,-1), profil DataStore riil, order simultan/private, replay, ownership, jarak, tipe/arity, saldo kurang, duplikat, equip, drop/recover/pickup,3 delivery tambahan, reset dan Kick/cleanup. |
| stage4-eight-clients.json | **107/107**,8 klien nyata (-8…-1),8 handshake,8 order/paket dan kredit terpisah; collision group, reset tas/paket, leave membersihkan seluruh cache/resource dan lease. |
| stage4-cross-session.json | **18/18**,sesi2 klien berbeda: uid-2 memuat244 koin,count6,4 rekor, TasMerah owned/equipped dan Part tas. |
| stage4-autosave-close.json | **17/17**,autosave30 detik teramati.4 payload salah+100 spam lewat RemoteEvent nyata menahan saldo147,5 respons penolakan. EndTest dengan perubahan dirty tanpa explicit release untuk menguji BindToClose. |
| stage4-close-reload.json | **14/14**,sesi baru uid-1 memuat196 koin,count4 dan2 rekor termasuk perubahan dirty sebelum shutdown. |
| stage4-desktop-store.json | B membuka toko; tombol mouse membeli lalu memakai TasMerah,147→97. Semua teks muat, pilihan tampil Dipakai. |
| stage4-phone-layout.json | iPhone17Pro emulator: root750×323, toko430×300 di dalam area aman, seluruh teks TextFits, target beli/pakai/tutup44px tinggi. Input bercampur1 Keyboard/1 Touch; **bukan** kelulusan sentuh murni atau HP asli. SendTouchEvent ditolak capability RobloxScript; tidak dinyatakan berhasil. |
| stage4-studio-manifest.json, stage4-save-status.json |13 sumber cocok,0 paket/harness aktif, Edit/default viewport; hash/waktu/ukuran file akhir terverifikasi. |
| stage4-reopen.json, stage4-local-fresh.json | File akhir dibuka ulang:13 sumber cocok, PlaceId/GameId0, cadangan ada. Play Ready/0 koin dengan banner lokal, console hanya bootstrap. Stop kembali Edit. |

Pengantaran harness memakai teleport setup dan waktu server nyata, **bukan** walkthrough manusia atau benchmark rute. Sampel benturan sebelum teleport persiapan direset hanya di harness agar setup tidak dihitung jatuh. Percobaan awal dua klien gagal, bukan penerimaan; riwayat `stage4-two-clients-initial.json` dipertahankan. Pengetatan collision group diterapkan, tetapi kegagalan yang berulang hilang setelah perbaikan fixture teleport; jangan menyatakan tabrakan pemain sebagai penyebab yang telah terbukti. Race snapshot awal HUD ditemukan saat reload dan diperbaiki, lalu reload lulus.

## Keterbatasan dan cara mencoba

Delapan klien adalah8 DataModel klien Studio satu komputer, bukan8 manusia/perangkat dan bukan bukti FPS/jaringan lambat. HP asli, performa, kenyamanan sentuh/kamera/audio dan uji produk lanjutan tetap belum dilakukan (T22+). Sistem memeriksa aksi ekonomi; belum antieksploit teleport/gerak penuh. Tidak ada analitik/T21, rilis publik atau monetisasi.

1. Buka main_game.rbxl dan Play untuk gameplay lokal. Jika GameId0, perhatikan banner UJI LOKAL: Stop menghapus progres memori.
2. Untuk persistensi, gunakan **Place Uji DataStore121172771262094** yang sudah dibuka pemilik, dengan implementasi baru pada Studio dan Studio API Services aktif. Jangan mempublikasikan hanya untuk mencoba; versi terbit belum diperbarui.
3. E/Ambil di depot → ikuti rumah → E/Antar. Q lepas, E ambil ulang, R pulihkan (-20, tanpa rekor). Lima rumah/dua jenis bergilir.
4. Kumpulkan minimal50 koin. Dekati petak TOKO TAS di depot, tekan B atau tombol Toko tas; Beli TasMerah kemudian Pakai. Tas tidak mempercepat gerak.
5. Reset: pesanan aktif dibatalkan, saldo/rekor/pilihan tas tetap dan tas muncul satu kali. Stop lalu Play lagi pada place uji: saldo, rekor dan kosmetik dimuat dari DataStore uji.
6. Perhatikan Pending/Menyimpan/Tersimpan. Jika profil gagal dimuat, saldo— dan aksi dikunci; jangan menganggapnya akun baru. Jika simpan gagal, tetap dirty/retry. Masuk ulang mungkin perlu menunggu lease≤120 detik setelah crash.
7. Pada sentuh pakai landscape dan tombol HUD. Laporkan hasil toko di HP asli secara terpisah; uji emulator tahap ini hanya menjamin layout.

Berhenti di **T20**. Jangan mengganti namespace ke data publik, mengerjakan T21, menambah Robux atau menerbitkan tanpa lingkup berikutnya.
