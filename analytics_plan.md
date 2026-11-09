# Paket Kilat! — Rencana dan hasil instrumentasi T21

Mode: **instrument**, berdasarkan permintaan eksplisit T21 untuk lima kejadian dan ukuran pesanan kedua T23. Target perubahan: main_game.rbxl (PlaceId/GameId0). Universe uji yang diizinkan sink live:10775037187. Tidak ada Publish, Open Cloud write, HTTP eksternal, atau pembacaan dashboard. Sumber panduan: skill MCP rbx-instrument-analytics dan rbx-permissions, diperiksa sebelum implementasi; API resmi [AnalyticsService](https://create.roblox.com/docs/reference/engine/classes/AnalyticsService) serta [custom events](https://create.roblox.com/docs/production/analytics/custom-events).

## A. Analitik yang sudah ada

Tidak ada pada13 sumber runtime yang dipindai sebelum perubahan. Server mengelola paket/pesanan, koin, profil dan toko. Satu mata uang Coins, empat tas kosmetik koin; tidak ada IAP, Robux, match atau quest terpisah. Onboarding sebelumnya hanya hint kontekstual; ditambahkan panel tahap dan Petunjuk. Sesudah perubahan:13 script/module server,1 shared Config,2 LocalScript;16 sumber runtime. AnalyticsService hanya berada dalam TelemetryService server.

## B. Skema final dan hook

### Economy

| Currency | Direction | transactionType | itemSku | Trigger (script:line) | customFields | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Coins | Source | Gameplay | Biasa/Rapuh | DeliveryService:76, setelah Award sukses; TelemetryService:68/122 | Destination - Rumah01…05; Package - Biasa/Rapuh; Condition - Good/Damaged/Zero | amount=result.total; endingBalance sesudah kredit. Setiap pengantaran sah satu event, replay gagal tidak masuk. |

Pembelian tas tidak ditambahkan sebagai event baru di lingkup lima kejadian ini. Tidak ada mata uang atau transaksi baru.

### Onboarding funnel (one-time)

| Step | Step name | Trigger | customFields |
| --- | --- | --- | --- |
| — | Tidak digunakan | Profil tidak dimigrasi untuk menandai tutorial permanen | — |

### Recurring funnels

| Funnel name | sessionId strategy | Step | Step name | Trigger |
| --- | --- | --- | --- | --- |
| PaketKilatTrial_v1 | GUID acak baru per kunjungan server | 1 | Session Started | PlayerLifecycle:24 → Begin, sekali; tidak pada respawn |
| PaketKilatTrial_v1 | GUID sesi yang sama | 2 | First Package Picked | DeliveryService:123 → OrderStarted pertama yang sah |
| PaketKilatTrial_v1 | GUID sesi yang sama | 3 | First Delivery Completed | DeliveryService:76 → Completed pertama setelah Award |
| PaketKilatTrial_v1 | GUID sesi yang sama | 4 | Second Order Started | Start sah sesudah≥1 pengantaran sesi; sekali |

Ini konversi per kunjungan, bukan klaim pemain baru sepanjang umur akun. Identifikasi10 tester baru dilakukan manual di test_report, tanpa mengunggah label/kontak tester.

### Custom events

| Event name | Counter / Value | Value source | Trigger | customFields | Notes |
| --- | --- | --- | --- | --- | --- |
| PKPackageRecovered | Counter1 | Recover server sukses | DeliveryService:145 | Package - Biasa/Rapuh; Destination - Rumah01…05 | recoveryCount monoton per pesanan, duplikat ditolak |
| PKSessionOutcome | Counter1 | Tahap terakhir sesi | PlayerLifecycle:15 / callback Bootstrap BindToClose | Stage - NoPickup/Picked/FirstDelivered/SecondOrder; End - Left/ServerClosing; Deliveries - 0/1/2plus | Outcome gameplay, bukan durasi sesi atau penghitung sesi generik. Engine bisa mengirim PlayerRemoving sebelum callback shutdown; End pertama menang. |

Jurnal lokal juga menamai SessionStarted, FirstPackagePicked, PackageRecovered, DeliveryCompleted, SessionEnded dan SecondOrderStarted. Baris lokal bukan tambahan custom event cloud. GUID/sequence/elapsed hanya untuk audit lokal; orderId/UserId/nama/chat tidak dimasukkan.

## C. Audit duplikasi

| Trigger / proposed event | Primary event | Other occurrence / built-in dashboard | Decision | Justification |
| --- | --- | --- | --- | --- |
| Kunjungan dimulai | Funnel step1 | Engagement joins | Simpan anchor funnel; tanpa custom SessionStart/PlayerJoined | Anchor diperlukan untuk mengukur alur, bukan menduplikasi DAU |
| Antar pertama | Economy Coins Source | Funnel step3 | Keduanya dipertahankan | Economy mengukur koin pascakredit; funnel mengukur konversi pengantaran pertama |
| Antar berikutnya | Economy Coins Source | — | Satu cloud event per penyerahan | Tidak menambah custom CoinsEarned/DeliveryCompleted |
| Sesi berakhir | PKSessionOutcome | Engagement duration | Hanya kategori tahap berhenti | Tidak mengunggah durasi, retention atau FPS custom |
| Pemulihan | PKPackageRecovered | — | Satu custom event | Bukan milestone wajib; tidak dimasukkan sebagai langkah funnel |

## D. Infrastruktur, izin dan anggaran

TelemetryService + TelemetryConfig server, dihubungkan ke Bootstrap/PlayerLifecycle/DeliveryService. Tidak ada RemoteEvent analitik baru; klien tidak bisa mengirim nama event atau payload. Snapshot StateChanged menambah onboarding.stage/deliveryCount/firstPickup, sementara kontrak ActionRequest lama tetap. Semua sumber diedit melalui MCP multi_edit; konstruksi GUI melalui migrasi Edit aditif UpgradeOnboardingUI.

API engine Log* menggunakan capability Basic di server; tidak memerlukan token Open Cloud/publishing untuk menulis kode. Metode API tersedia pada inspeksi. **Studio adalah LocalOnly**, tidak mencoba menganggap no-op Log* sebagai data terkirim. Sink Roblox hanya di server live, universe uji sesuai konfigurasi. Pengiriman/izin dashboard live **belum diuji** karena tidak ada build live versi ini yang dipublikasikan dalam tugas. Jangan meminta atau memakai scope Publish untuk menutup celah itu.

| Limit | Cap panduan | Dipakai | Sisa |
| --- | --- | --- | --- |
| Currencies | 10 | 1 | 9 |
| Funnels | 10 | 1 | 9 |
| Custom event names | 100 | 2 | 98 |
| Custom fields/event | 3 | maksimum3 | 0 pada Economy/Outcome |

Jurnal256 baris FIFO, antrean128, maksimum100 call/minute global dan24/sesi/minute; worker0,2 detik. Ini di bawah anggaran layanan minimal120+20×CCU menurut panduan. Drop/error dihitung. Handler kredit tidak yield; sink dibungkus pcall. Tidak retry karena error mungkin terjadi setelah event diterima. Flush saat keluar mempertahankan FIFO dan melepas referensi Player. Callback shutdown terpisah menunggu Close; tidak melepas task tanpa menunggu. Call-returned berarti fungsi kembali, **bukan** bukti diterima dashboard.

## E. Validasi dan pemeriksaan manual tersisa

- Load tiga module/config melalui MCP berhasil. Re-scan hanya menemukan AnalyticsService pada TelemetryService server.
- verification/stage5-telemetry-checks.json:33/33, transport injeksi, replay, kategori/privasi, antrean/jurnal terbatas, FIFO, failure isolation dan cleanup.
- verification/stage5-regression.json:73/73, dua klien nyata StudioMemory, lima penyerahan sah→lima event completion, recovery1, session starts2, first pickups2, second order2 (satu per masing-masing klien), satu keluar nyata. Pengujian awal salah mengharapkan total second order1; fixture diperbaiki, tidak mengubah gameplay untuk meluluskan tes.
- Layout/UI/FPS Studio dicatat terpisah; bukan bukti HP asli. Tidak ada tanda terima dashboard live. Jika nanti pemilik menyediakan build live yang cocok dengan akses yang sudah ada, verifikasi lewat Creator Dashboard/View Events, lalu chart sesuai delay layanan. Tugas ini tidak menginstruksikan publikasi.
- Rekomendasi tinjauan setelah bukti tersedia: funnel langkah1→2→3→4, net Coins Source, dan PKSessionOutcome/PKPackageRecovered. Tidak menambah event baru sebelum melihat kebutuhan dari data.

## F. Keputusan/hasil yang masih menunggu pemilik

Pemilik menjawab **“belum ada akses build HP”** pada7 November2026. Tidak ada pertanyaan skema yang menghalangi implementasi T21; akses build yang cocok menghalangi T22/T23 dan konfirmasi dashboard live. T22/T23 tetap terbuka; lihat test_report.md. Tidak mengeksekusi T24/T25.
