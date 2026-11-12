# Paket Kilat

Paket Kilat adalah game kurir di Roblox. Ambil pesanan di depot, pilih jalur melewati kampung dan distrik kota, lalu serahkan paket dalam kondisi sebaik mungkin. Proyek ini masih dalam pengembangan dan pengujian di Roblox Studio.

**Mulai cepat.** Buka [main_game.rbxl](main_game.rbxl) di Roblox Studio, tekan **F5**, lalu ikuti penanda ke depot. Pilih **Cerita** untuk kiriman pertama ke Rumah Bu Sari.

## Cara bermain

1. Ikuti penanda ke depot dan buka papan pesanan.
2. Pilih kiriman dari tab **Cerita**, **Biasa**, **Kontrak**, atau **Borongan**. Pratinjau menampilkan tujuan, jarak, peta rute, dan syarat bonus.
3. Ikuti penanda jalan. Sprint menghemat waktu dan menguras stamina serta genggaman. Paket rapuh memerlukan perhatian lebih saat melewati rintangan.
4. Dekati titik serah. Saat penanda hijau menampilkan **Siap diserahkan**, pilih **Antar paket**.
5. Gunakan koin hasil pengantaran untuk membeli tas atau meningkatkan sarung tangan di depot.

| Aksi | Desktop | Mobile |
| --- | --- | --- |
| Buka papan pesanan, ambil ulang, atau serahkan paket | **E** | Tombol aksi kontekstual |
| Lepas paket | **Q** | **Lepas** |
| Pulihkan paket ke depot | **R** | **Pulihkan** |
| Tampilkan atau sembunyikan panduan rute | **G** | **Menu → Rute** |
| Buka peta dengan posisi pemain dan tujuan | **K** atau **Peta** | **Menu → Peta** |
| Buka toko perlengkapan | **B** | **Menu → Toko** |
| Akhiri pesanan aktif | **X** | **Menu → Akhiri** |
| Baca panel pameran setelah cerita selesai | **F** di dekat panel | **Baca panel** |

Mengambil ulang paket yang jatuh menghindari penalti pemulihan. **Pulihkan** memindahkan paket ke petak depot, mengurangi kondisi, dan menggugurkan kelayakan rekor. Saat paket masih bisa diambil, aksi pemulihan meminta konfirmasi. Mengakhiri pesanan juga meminta konfirmasi. Koin dari kiriman yang sudah diselesaikan tetap tersimpan dalam profil yang aktif.

## Cerita, kota, dan progres

- **Pameran Foto Kampung.** Lima bab membawa pemain dari depot dan rumah warga ke Menara Kilat, Kantor Arsitek, dan Galeri Tepi Air. Dua bab paket rapuh punya bonus opsional untuk kondisi akhir paket. Setelah bab terakhir, tiga panel pameran dapat dibaca di galeri.
- **Kota.** Kampung lama memuat depot, rumah warga, pasar, dan area komersial. Pusat kota memuat taman dan perkantoran. Jembatan kanal menghubungkan area utama dengan Bata Quay, distrik ruko bata. Sebagian bangunan berfungsi sebagai landmark atau calon alamat pengantaran.
- **Jenis pesanan.** Kiriman biasa, rapuh, dan lintas kanal tersedia melalui papan pesanan. Kontrak dapat meminta batas waktu, kondisi tinggi, atau cap rute. Borongan menggabungkan beberapa tujuan berurutan. Pada rute tertentu, pelanggan menawarkan titipan lanjutan.
- **Karier.** Jumlah kiriman membuka pangkat dan akses Ekspres Distrik. Target mingguan berganti rotasi. Pilih target di tab Karier untuk melihat pesanan yang cocok. Galeri juga menerima pesanan reguler setelah cerita tamat.
- **Perlengkapan.** Tas punya model berbeda dan bisa dipratinjau di toko. Upgrade sarung tangan mengurangi pemakaian genggaman saat sprint. Toko saat ini menggunakan koin dalam game.

## Buka dan jalankan di Roblox Studio

1. Buka [main_game.rbxl](main_game.rbxl) lewat **File → Open**.
2. Jalankan **Play** dengan **F5** untuk menguji dari sudut pandang pemain. Buka **Output** untuk memeriksa pesan bootstrap dan kesalahan client atau server.
3. Gunakan **Device Emulator** dan orientasi landscape untuk memeriksa HUD, papan pesanan, toko, dan panel galeri pada layar kecil.
4. Tekan **Stop** sebelum menyimpan edit. Gunakan **File → Save to File As…** dan pilih file `main_game.rbxl` di folder proyek jika ingin menimpa salinan lokal.

File place memuat map, UI, dan script yang dipakai saat Play. Folder `src/` memuat salinan Luau untuk review dan pengembangan. Perubahan di `src/` perlu diterapkan ke instance script yang sesuai di Studio. Perubahan di Studio perlu disimpan ke file place agar ikut terbawa saat proyek dibuka ulang. Status penyimpanan revisi Studio terakhir ke binary lokal belum terverifikasi.

## Struktur proyek

| Lokasi | Isi |
| --- | --- |
| [main_game.rbxl](main_game.rbxl) | File place Roblox Studio |
| [src/](src/) | Script runtime Luau serta script authoring untuk map dan UI |
| [tests/](tests/) | Fixture dan audit yang dijalankan melalui Studio |
| [verification/](verification/) | Hasil audit dan bukti pengujian |
| [backups/](backups/) | Salinan sebelum perubahan tertentu |
| [design.md](design.md) dan [task_list.md](task_list.md) | Desain dan daftar pekerjaan proyek |
| [handoff.md](handoff.md) dan [test_report.md](test_report.md) | Catatan pengerjaan dan pengujian |
| [asset_sources.md](asset_sources.md) | Catatan sumber aset |
| [analytics_plan.md](analytics_plan.md) | Rencana pengukuran gameplay |

Di dalam place, `Workspace.PaketKilat` memuat map dan paket aktif. `ReplicatedStorage.PaketKilat` memuat modul bersama dan remote. Script di `StarterPlayerScripts` menangani UI, navigasi, dan feedback. Layanan di `ServerScriptService.PaketKilat` memvalidasi pesanan, perubahan kondisi, pembelian, dan pembayaran.

## Alur pengembangan

| Jika mengubah | Source utama | Lokasi di Explorer |
| --- | --- | --- |
| HUD dan tombol paket | [PrototypeInput.client.luau](src/PrototypeInput.client.luau) | `StarterPlayer.StarterPlayerScripts.PaketKilatInput` |
| Papan pesanan dan pratinjau peta | [JobBoard17.client.luau](src/JobBoard17.client.luau) | `StarterPlayer.StarterPlayerScripts.PaketKilatJobBoard17` |
| Panduan jalan dan panah HUD | [RouteGuide.client.luau](src/RouteGuide.client.luau), [CourierNavigation19.client.luau](src/CourierNavigation19.client.luau) | `StarterPlayer.StarterPlayerScripts` |
| Bab cerita dan dialog | [CourierStory.luau](src/CourierStory.luau), [CustomerDialogue30.luau](src/CustomerDialogue30.luau) | `ReplicatedStorage.PaketKilat.Shared` |
| Validasi pengantaran dan koin | [DeliveryService.luau](src/DeliveryService.luau), [EconomyService.luau](src/EconomyService.luau) | `ServerScriptService.PaketKilat` |
| Target mingguan dan pangkat | [CourierCareer.luau](src/CourierCareer.luau) | `ServerScriptService.PaketKilat.CourierCareer` |

1. Buka place dalam mode **Edit** dan cocokkan file Luau dengan script di Explorer. Jika memakai MCP, periksa nama place dan mode Studio yang terhubung sebelum mengubahnya.
2. Terapkan perubahan ke script Studio dan salinan Luau di `src/`. Untuk perubahan map atau template GUI, lakukan edit pada instance yang dipakai di mode **Edit**.
3. Jalankan **Play** dari awal dan uji satu aksi yang dipengaruhi perubahan. Catat hasil serta skenario yang belum diperiksa.
4. Hentikan Play, simpan ke `main_game.rbxl`, lalu cek nama file dan waktu modifikasinya. Jika sebelumnya memakai AutoRecovery, buka ulang file target dan ulangi tes singkat untuk memastikan revisinya ikut tersimpan.
5. Periksa perubahan yang siap masuk Git. Stage file yang relevan secara eksplisit agar file lock dan hasil pengujian sementara tidak ikut terbawa.

```powershell
git status --short
git diff --check
git diff -- src/
```

File `.rbxl` berbentuk binary, jadi gunakan diff Luau dan hasil uji Studio saat mereview perubahan gameplay.

## Data dan analytics

- **Place lokal dengan `GameId == 0`** memakai `StudioMemory`. Progres dan saldo uji berakhir saat sesi Play dihentikan.
- **Place dengan `GameId`** memakai konfigurasi `DataStoreTest`. Periksa universe, scope, dan prefix di [StorageConfig.luau](src/StorageConfig.luau) sebelum menguji penyimpanan. Kegagalan penyimpanan tidak otomatis mengalihkan sesi ke profil baru di memori.
- **Telemetry** berjalan dalam mode lokal saat Play di Studio. Pengiriman analytics Roblox dibatasi oleh konfigurasi universe di [TelemetryConfig.luau](src/TelemetryConfig.luau).

Adapter DataStore menegakkan universe dan namespace QA. Sebelum rilis ke universe produksi, tentukan konfigurasi penyimpanan produksi dan uji bahwa profil tetap terbaca setelah keluar dan masuk lagi. Lihat implementasinya di [StorageBackend.luau](src/StorageBackend.luau).

## Checklist pengujian

- Jalankan pengantaran pertama dari spawn hingga hasil. Pastikan tujuan, kondisi paket, koin, dan bab berikutnya tampil benar.
- Coba paket jatuh, ambil ulang, pemulihan ke depot, pembatalan, dan respawn. Pastikan paket lama hilang setelah pesanan berakhir.
- Uji kontrak berhasil dan gagal, tiga kiriman borongan, serta pembayaran mingguan. Periksa saldo sebelum dan sesudah setiap aksi.
- Uji pembelian, pemakaian tas, upgrade sarung tangan, dan pembukaan pameran. Gunakan profil uji saat memeriksa penyimpanan antar sesi.
- Periksa layar landscape kecil, input sentuh, perjalanan penuh antardistrik, dan sesi beberapa pemain sebelum rilis.

Pengujian yang tercatat mencakup skenario Studio dengan profil sementara, beberapa perpindahan posisi, dan simulasi ukuran layar. Retensi pemain sungguhan belum diukur. Status pengembangan, batas pengujian, dan bukti tiap revisi dapat dilihat di [handoff.md](handoff.md), [test_report.md](test_report.md), dan [verification/](verification/).

## Pemecahan masalah

| Gejala | Pemeriksaan |
| --- | --- |
| Perubahan belum terlihat saat Play | Hentikan Play, cek apakah script yang diedit ada di Explorer pada mode Edit, lalu jalankan Play lagi. Jika baru membuka ulang Studio, cocokkan nama dan lokasi file place dengan file yang terakhir disimpan. |
| Studio membuka AutoRecovery | Periksa revisi yang ada di sesi itu. Jika isinya memang versi yang ingin dipakai, simpan lewat **Save to File As…** ke file target dan konfirmasi Replace. |
| Tombol **Antar paket** belum aktif | Cek alamat aktif, status paket, dan jarak pemain serta paket ke titik serah. Ikuti penanda sampai muncul **Siap diserahkan**. |
| Koin atau progres hilang saat Stop | Cek indikator penyimpanan. Sesi `StudioMemory` memulai profil uji baru pada Play berikutnya. |
| Profil gagal dimuat di place QA | Cek Output server dan cocokkan universe serta namespace dengan konfigurasi QA. |
| UI terlihat penuh di ponsel | Uji viewport landscape kecil dengan menu tertutup dan terbuka. Periksa apakah daftar pesanan, katalog, dan teks panel galeri masih bisa digulir. |
