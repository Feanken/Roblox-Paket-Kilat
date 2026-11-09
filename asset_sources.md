# Paket Kilat! — Sumber aset T15

## MobileMarket18 — 9 November 2026

Semua sumber berikut muncul sebagai isFree=true/priceCents0 pada pencarian Creator Store MCP. Tidak ada pembelian. Link/creator adalah metadata saat review.

| Aset | Creator | Tautan | Pemakaian |
| --- | --- | --- | --- |
| Low-Poly Bread Loaf | heresiarh | [14375985405](https://create.roblox.com/store/asset/14375985405) |2Union, Weld dibuang;4loaf pada ROTI HANGAT |
| Grow A Garden Carrot Plant | lego_manmarshall | [80121378677251](https://create.roblox.com/store/asset/80121378677251) |6Part,11Weld dibuang;6wortel mendatar pada SAYUR SEGAR; penamaan vendor tidak ditampilkan dalam game |
| Fruit basket | SirWilliamHowe | [4563688216](https://create.roblox.com/store/asset/4563688216) |30Part;1peti pada BUAH SEGAR |
| Fruit Model | posthxc | [12831453](https://create.roblox.com/store/asset/12831453) |1Part+SpecialMesh; StringValue dibuang,4display buah |

Ditolak: [100398742284940](https://create.roblox.com/store/asset/100398742284940), Ixfe1700, Cagette De Fruit Basket Crate Blox Shop Stand Box. Hasil impor berisi4Script/LocalScript,2RemoteFunction,ScreenGui dan banyak GUI, meskipun deskripsi pencarian menyebut tanpa script. Tidak dipakai; reviewfolder dibuang. Kandidat lain yang tidak dipilih tidak diimpor.

Library bersih ServerStorage/PaketKilat_MarketAssets18, penempatan Map/MarketGoods18.15model/78Parts anchored/noncollision,0script vendor.17callback preloadSuccess; seluruh15model diuji kontak geometri pada countertop. Source CleanMarketAssets18.luau/MarketGoods18.luau dan bukti verification/creator-assets18.json. Metadata gratis/audit struktur tidak menetapkan hak IP pihak lain atau menjamin performa HP.

## City15 — 9 November 2026

Search Creator Store MCP priceFilter=free mengembalikan isFree=true/priceCents=0 untuk dua aset baru. Tidak ada pembelian.

| Aset | Creator | Tautan | Pemakaian |
| --- | --- | --- | --- |
| food cart for hunter project | HxHTester | [5362266328](https://create.roblox.com/store/asset/5362266328) | Dua gerobak,26Parts/copy, tinggi7.2 |
| Simple low poly picnic table | taate | [5256845941](https://create.roblox.com/store/asset/5256845941) | Dua meja,50Parts/copy, tinggi4.4; Camera asal tidak disertakan |

Ditolak: Low-Poly Tree. Stylized Tree Decor Park [74446384811689](https://create.roblox.com/store/asset/74446384811689), ViperUoNovatoRaven11; berisi Script, ModuleScript, Camera, AlignPosition. Tidak dijalankan. Review folder dihapus sebelum Play. Pohon pengganti memakai template BroadleafTree yang sudah bersih dari P07 (Abishpc/4893246329),16copy; ParkBench4copy dan WoodFence4copy juga dari library P07 yang tercatat di bawah.

Clean library ServerStorage.PaketKilat_CreatorAssets15, penempatan Map.CityDecor15. Total28model/208Parts,0script/0collider/semua anchored, semua bounding-box bottom tepat pada ground.166 callback preloadSuccess. Sumber src/CleanCreatorAssets15.luau dan DecorateCity15.luau. Dua warga bergerak adalah primitive lokal dari CityLife15.client.luau, bukan model vendor. Audit struktur tidak menetapkan hak IP pihak lain atau menjamin performa HP; gratis merupakan kondisi saat pencarian.

Tambahan T21: panel Petunjuk dan diagnostik FPS memakai GUI/teks/font bawaan Roblox yang disusun lewat kode proyek. Tidak ada aset gambar/model/audio baru, impor, pembelian atau unggahan.

Tambahan T18 (7 November 2026): empat warna tas dan petak toko dibuat dari Part, WeldConstraint, teks/font serta warna engine melalui `CosmeticService.luau` dan `UpgradeStoreUI.luau`. Visual buatan kode proyek, tanpa aset, mesh, gambar, audio atau lisensi pihak ketiga baru. Tidak ada unggahan, pembelian, atau Robux.

Tanggal: 7 November 2026. Tidak ada pembelian, impor model Creator Store, unggahan audio, atau publikasi place/aset.

| Aset | Sumber | Pemakaian / hak |
| --- | --- | --- |
| Rumah, jalan, papan, genangan, penghalang, pohon, pot, peti, tangki, papan nama | Part/Model/SurfaceGui yang dibuat oleh kode proyek (`BuildMap.luau`, `ExpandVillage.luau`) | Visual buatan proyek; tanpa model, gambar atau mesh pihak ketiga. Material, font dan primitive adalah fitur bawaan engine Roblox. |
| Cue ambil | `rbxasset://sounds/action_get_up.mp3` | Audio bawaan distribusi Roblox Studio/client. Direferensikan untuk runtime Roblox; tidak disalin, diunggah ulang atau didistribusikan sebagai berkas audio. |
| Cue benturan/selip/penghalang | `rbxasset://sounds/action_jump_land.mp3` | Audio bawaan Roblox; batas pemakaian sama. |
| Cue pengantaran | `rbxasset://sounds/volume_slider.ogg` | Audio bawaan Roblox; batas pemakaian sama. |

Ketiga berkas audio benar-benar tersedia dalam instalasi Studio yang digunakan: `content/sounds` pada versi `version-67c8b1dedbb74fed`. Ini bukan klaim lisensi redistribusi bebas di luar Roblox. Pemakaiannya tetap mengikuti ketentuan platform Roblox; tidak ada lisensi pihak ketiga baru yang diperoleh atau diasumsikan.

Referensi resmi: [format URL aset Roblox](https://create.roblox.com/docs/projects/assets), [penggunaan aset audio](https://create.roblox.com/docs/audio/assets). Dokumentasi Creator Store menjelaskan audio bebas digunakan dalam pengalaman Roblox; proyek ini memakai referensi bawaan client, bukan mengimpor aset Store.

Muat/decode ketiga Sound sudah diperiksa pada sesi Play T15 (`IsLoaded=true`, TimeLength sekitar 0,575 / 0,261 / 0,845 detik). `verification/stage3-audio-checks.json` membuktikan pemicu dan akhir pemutaran: Pickup 46 Play/36 Ended, Impact 23/23, Delivered 17/17. Beberapa cue ambil dipicu kembali sebelum selesai, sehingga jumlah Ended lebih kecil. Pemeriksaan teknis audio tidak menggantikan penilaian pendengaran pemilik atas volume dan kenyamanan suara.

## Polish01

DepotFacade: Roblox procedural generation8a74bd48-5f8c-4e42-b7a7-1b670915870d, dibuat untuk proyek ini pada7 November2026.53 bagian statis; source generator di backup Studio, ekspor final src/DepotFacade01.json. Tidak memasukkan marketplace asset, gambar eksternal, atau audio baru. Detail halaman/papan/material dari primitive bawaan lewat src/PolishVillage01.luau. Tidak ada pembelian aset; status hak dari layanan generatif mengikuti ketentuan Roblox, bukan audit hukum terpisah.

## Polish02

Pita dan label paket dibuat dari SurfaceGui/Frame/TextLabel bawaan Roblox. Panel hasil, highlight dan tween memakai API bawaan; tidak menambah assetId eksternal, pembelian, gambar, atau audio baru. Audio existing tetap dipakai. Sumber: src/PolishPackage02.luau dan src/DeliveryFeedback.client.luau.

## Polish03

Atap rumah/depot disusun ulang dari Part/WedgePart bawaan melalui src/RebuildStreets03.luau. Trim, jalan dan trotoar memakai primitive/material bawaan. Tidak menambah assetId/generator/pembelian atau script runtime. Atap generatif P01 lama disembunyikan setelah ditemukan masalah wedge; kanopi/facade tetap dipakai. Sumber generatif asli tetap di scoped backup.

## Polish05

Detail alamat/kotak pos, paving, parapet dan fondasi dibuat dari Part/SurfaceGui/material bawaan melalui src/ConnectNeighborhood05.luau. Tidak ada generator, assetId eksternal, pembelian atau audio baru.

## Polish06

HUD menggunakan GUI/font/tween bawaan. Papan arah menggunakan Part/SurfaceGui/material bawaan, tiga papan dua sisi. Tidak menambah gambar, assetId eksternal, audio atau pembelian. Sumber PolishHUD06.luau/Wayfinding06.luau dan dua script input/feedback.

## Polish07 — Creator Store, 7 November 2026

Hasil MCP search_asset dengan scope creator_store dan priceFilter free; ketiganya mengembalikan isFree=true dan priceCents=0. Tidak ada pembelian. Harga/ketersediaan adalah kondisi saat pencarian, bukan jaminan masa depan.

| Aset | Creator | ID / tautan | Pemakaian |
| --- | --- | --- | --- |
| Low Poly Tree | Abishpc | [4893246329](https://create.roblox.com/store/asset/4893246329) | 5pohon tinggi11,5;3MeshPart per pohon |
| Wooden Bench | thatpower29 | [111013476485423](https://create.roblox.com/store/asset/111013476485423) | 1bangku dekoratif |
| Mesh Wooden Fence | logoffkid | [8092188374](https://create.roblox.com/store/asset/8092188374) | 3segmen dekoratif |

Template bersih ServerStorage/PaketKilat_CreatorAssets07. Runtime Map/CreatorStore07. Source CreatorStorePass07.luau. Semua clone tanpa script, joint, constraint, package link/interaksi; anchored/noncollision. Bench tidak menambahkan sistem duduk. MeshId preloadSuccess (tree1278512125/1278519390/1278518815, bench102240183850853, fence6165177553). Audit struktur dan identitas creator bukan penetapan kepemilikan IP seluruh konten.

Ditolak/tidakdipakai:75862842734848 (XxEllaArrowBlastxX;6script danGUI/Camera/lighting; dihapus sebelumPlay);12549617200 (Remadex Development; pohon konifer, kurang cocok gaya). Tidak ada source script kandidat dijalankan. Lihat verification/creator-assets07.json dan polish07-audit.json.

## Polish08

Penunjuk jalan berupa16PartCylinder/Neon lokal, GUI/font bawaan. Tidak menambah CreatorStore asset, gambar, audio, pembelian, atau layananeksternal. AsetP07 dipertahankan. Source RouteGuide.client.luau/BuildRouteGuide08.luau.

## P09 dipulihkan / P10 — 9 November 2026

Semua sumber berikut diperiksa ulang dengan search_asset(scope=creator_store, priceFilter=free); isFree=true/priceCents0 pada saatpencarian. Tidak ada pembelian.

| Aset | Creator | Tautan | Pemakaian |
| --- | --- | --- | --- |
| Low Poly Street Lamp | FredrikAustra | [3302675003](https://create.roblox.com/store/asset/3302675003) | 4lampu; original6part/1light/0script, platealaspanjang dihapus,5part percopy |
| Low Poly Bush | ChickenNuggets2go | [7191673673](https://create.roblox.com/store/asset/7191673673) | 7pot dan10semaktaman;1mesh percopy |
| Low Poly Rocks | neervu | [14603612772](https://create.roblox.com/store/asset/14603612772) | 5grupbatutaman;1mesh percopy |
| Cardboard Box | NickiBreeki | [12084344112](https://create.roblox.com/store/asset/12084344112) | 4kardusdekoratif;1mesh percopy;1Camera asal dihapus |

Librarybersih ServerStorage/PaketKilat_CreatorAssets09/10. Clone Map/Landscape09/DepotParcels10 statis/noncollision tanpa script. Source LandscapeAssets09.luau dan DepotParcels10.luau. Audit struktur/metadatafree tidak menetapkan hakIPseluruhtekstur pihaklain atau menjamin performaHP. Geometry/texture preloadSuccess; bukti creator-assets10.json/polish10-audit.json. Harga/ketersediaan dapatberubah.
