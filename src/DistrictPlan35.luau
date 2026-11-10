-- District35 authoring plan. Coordinates are in the existing DepotPad basis.
local P={
 Main={name="CivicCentre",x1=-138,x2=145,z1=151,z2=310},
 Quay={name="BrickQuay",x1=-445,x2=-163,z1=94,z2=306},
 CivicRoads={{-101,-83,144,282},{67,85,144,282},{-118,126,273,291}},
 QuayRoads={{-432,-414,114,286},{-194,-176,114,286},{-423,-185,105,123},{-423,-185,162,180},{-423,-185,220,238},{-423,-185,277,295}},
 BridgeRoad={-186,-124,135,153},BridgeWalk={-186,-124,131,157},
 Park={-62,48,202,266},
 Diagonal={a=Vector2.new(-185,114),b=Vector2.new(-423,286),roadHalf=9,walkHalf=13},
 Offices={
  {"CBD01","Menara Kilat",-38,184,38,26,66,0},
  {"CBD02","Kantor Media",36,184,36,26,52,0},
  {"CBD03","Bursa Kreatif",-120,226,26,34,46,-90},
  {"CBD04","Balai Layanan",116,230,34,30,58,90},
 },
 Shops={"Roti Kota","Kopi Kanal","Studio Kertas","Toko Kamera","Floris Jalan","Atelier Utara","Dapur Nusa","Buku Bata","Klinik Sehat","Kantor Arsitek","Kafe Sudut","Pasar Lokal","Rumah Desain","Kedai Pagi","Laundry Kota","Galeri Tepi Air","Toko Sepatu","Studio Musik","Farmasi Kota","Kantor Niaga","Toko Alat","Kedai Quay","Studio Foto","Kertas & Pena"},
 PocketGreens36={{-362,-318,185,215},{-291,-253,184,216},{-411,-378,239,270}},
 PavedLots36={{-351,-325,184,205},{-277,-255,195,218},{-410,-386,231,253}},
 CivicGreens36={{-79,-62,202,264},{48,63,202,264}},
}
return P
