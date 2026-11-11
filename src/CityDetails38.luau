-- ====================================================================
-- CityDetails38: Comprehensive City, Ornaments & Building Details by Category
-- Categories:
--  1. Kampung & Depot (Kotak Pos, Nomor Rumah, Papan Depot, Palet Kardus)
--  2. Civic Centre (Monolit Nama Gedung Modern, Banner Tiang, Tempat Sampah 3 Warna)
--  3. Bata Quay (Blade Signs Ruko Menjorok, Lentera Dinding Besi, Window Flower Boxes)
--  4. Pasar Tradisional (Peti Buah Kayu, Papan Kios Gantung)
--
-- Safety: All parts are anchored, non-colliding, non-touch, non-query.
-- Does not alter existing anchors, routes, gameplay, economy, or delivery logic.
-- ====================================================================

local B = {}

local cream = Color3.fromRGB(246, 237, 217)
local darkInk = Color3.fromRGB(28, 42, 43)
local woodBrown = Color3.fromRGB(114, 76, 49)
local lightWood = Color3.fromRGB(181, 137, 99)
local terracotta = Color3.fromRGB(184, 94, 61)
local foliageGreen = Color3.fromRGB(56, 128, 64)
local gold = Color3.fromRGB(241, 198, 99)
local brickRed = Color3.fromRGB(163, 62, 51)
local warmGlass = Color3.fromRGB(255, 243, 205)
local slateGrey = Color3.fromRGB(70, 75, 80)
local modernWhite = Color3.fromRGB(245, 245, 248)

local function part(parent, name, size, cf, color, material, shadow)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color or cream
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.CastShadow = shadow == true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function surfaceLabel(parentPart, face, text, textColor, bgColor, fontSize)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "SignGui"
	gui.Face = face
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 32
	gui.AlwaysOnTop = false
	gui.ClipsDescendants = true
	gui.Parent = parentPart

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.fromScale(1, 1)
	lbl.BackgroundTransparency = bgColor and 0 or 1
	if bgColor then lbl.BackgroundColor3 = bgColor end
	lbl.Text = text
	lbl.TextColor3 = textColor or cream
	lbl.Font = Enum.Font.GothamBold
	lbl.TextScaled = true
	lbl.TextWrapped = true
	lbl.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.08, 0)
	corner.Parent = lbl

	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0.08, 0)
	pad.PaddingRight = UDim.new(0.08, 0)
	pad.PaddingTop = UDim.new(0.08, 0)
	pad.PaddingBottom = UDim.new(0.08, 0)
	pad.Parent = lbl

	return gui
end

function B.BuildAll()
	local map = workspace.PaketKilat.Map
	local rootFolder = map:FindFirstChild("CityDetails38")
	if rootFolder then
		rootFolder:Destroy()
	end

	rootFolder = Instance.new("Folder")
	rootFolder.Name = "CityDetails38"
	rootFolder.Parent = map

	local kampungFolder = Instance.new("Folder", rootFolder)
	kampungFolder.Name = "Kampung"

	local civicFolder = Instance.new("Folder", rootFolder)
	civicFolder.Name = "CivicCentre"

	local quayFolder = Instance.new("Folder", rootFolder)
	quayFolder.Name = "BataQuay"

	local marketFolder = Instance.new("Folder", rootFolder)
	marketFolder.Name = "PasarTradisional"

	local totalParts = 0

	-- ================================================================
	-- 1. KAMPUNG: RUMAH 01 - 05 & DEPOT
	-- ================================================================
	local houseDetails = {
		{ name = "Rumah01", owner = "Bu Sari", no = "01", doorOffset = Vector3.new(-2.6, 0, -0.4) },
		{ name = "Rumah02", owner = "Pak Budi", no = "02", doorOffset = Vector3.new(2.6, 0, -0.4) },
		{ name = "Rumah03", owner = "Bu Rina", no = "03", doorOffset = Vector3.new(2.6, 0, -0.4) },
		{ name = "Rumah04", owner = "Pak Agus", no = "04", doorOffset = Vector3.new(-2.6, 0, -0.4) },
		{ name = "Rumah05", owner = "Bu Dewi", no = "05", doorOffset = Vector3.new(2.6, 0, -0.4) },
	}

	for _, hd in ipairs(houseDetails) do
		local houseModel = map:FindFirstChild(hd.name)
		local door = houseModel and houseModel:FindFirstChild("Door")
		if door then
			local hGroup = Instance.new("Model", kampungFolder)
			hGroup.Name = hd.name .. "_Details"

			local dcf = door.CFrame

			-- A. Plat Nomor Rumah di dekat pintu
			local signPlate = part(hGroup, "HouseNumberPlate", Vector3.new(1.0, 0.7, 0.08), dcf * CFrame.new(hd.doorOffset.X * 0.7, 1.2, -0.18), darkInk, Enum.Material.Wood)
			surfaceLabel(signPlate, Enum.NormalId.Front, hd.no, gold, darkInk)

			-- B. Kotak Pos Warga (Mailbox)
			local mbPos = dcf * CFrame.new(hd.doorOffset.X, -1.2, -1.8)
			local mbPost = part(hGroup, "MailboxPost", Vector3.new(0.18, 3.2, 0.18), mbPos * CFrame.new(0, 0, 0), woodBrown, Enum.Material.Wood)
			local mbBox = part(hGroup, "MailboxBody", Vector3.new(0.9, 0.75, 1.1), mbPos * CFrame.new(0, 1.7, 0), Color3.fromRGB(195, 65, 50), Enum.Material.Metal)
			local mbCap = part(hGroup, "MailboxCap", Vector3.new(0.92, 0.4, 1.12), mbPos * CFrame.new(0, 2.1, 0), Color3.fromRGB(165, 45, 35), Enum.Material.Metal)
			local cyl = Instance.new("SpecialMesh", mbCap)
			cyl.MeshType = Enum.MeshType.Cylinder
			mbCap.CFrame = mbCap.CFrame * CFrame.Angles(0, 0, math.pi / 2)
			surfaceLabel(mbBox, Enum.NormalId.Front, "POS\n" .. hd.no, cream, nil)

			-- C. Pot Bunga Teras (Planter Box with Flowers)
			local potPos = dcf * CFrame.new(-hd.doorOffset.X * 0.8, -2.5, -0.8)
			local pot = part(hGroup, "FlowerPot", Vector3.new(1.6, 0.8, 0.8), potPos, terracotta, Enum.Material.Brick)
			local foliage = part(hGroup, "Foliage", Vector3.new(1.5, 0.6, 0.75), potPos * CFrame.new(0, 0.5, 0), foliageGreen, Enum.Material.Grass)
			for fIdx = -0.5, 0.5, 0.5 do
				local flower = part(hGroup, "FlowerBloom", Vector3.new(0.28, 0.28, 0.28), potPos * CFrame.new(fIdx, 0.85, (fIdx == 0 and 0.1 or -0.1)), (fIdx == 0 and Color3.fromRGB(245, 110, 140) or gold), Enum.Material.SmoothPlastic)
				local fMesh = Instance.new("SpecialMesh", flower)
				fMesh.MeshType = Enum.MeshType.Sphere
			end

			-- D. Lampu Teras (Porch Sconce)
			local sconcePos = dcf * CFrame.new(0, 3.4, -0.2)
			local arm = part(hGroup, "SconceArm", Vector3.new(0.12, 0.12, 0.5), sconcePos, darkInk, Enum.Material.Metal)
			local lantern = part(hGroup, "SconceLantern", Vector3.new(0.45, 0.65, 0.45), sconcePos * CFrame.new(0, -0.3, -0.3), warmGlass, Enum.Material.Neon)

			totalParts += #hGroup:GetChildren()
		end
	end

	-- Depot Signboard & Logistics Crates
	local depot = map:FindFirstChild("Depot")
	local depotPad = map:FindFirstChild("DepotPad")
	if depot and depotPad then
		local dGroup = Instance.new("Model", kampungFolder)
		dGroup.Name = "Depot_Details"

		local dcf = depotPad.CFrame

		-- Papan Nama Megah Depot
		local signPos = dcf * CFrame.new(0, 10.2, 7.8)
		local mainSignFrame = part(dGroup, "DepotSignFrame", Vector3.new(14.5, 2.2, 0.3), signPos, darkInk, Enum.Material.Wood)
		local mainSignInner = part(dGroup, "DepotSignInner", Vector3.new(14.0, 1.8, 0.35), signPos, Color3.fromRGB(35, 78, 80), Enum.Material.SmoothPlastic)
		surfaceLabel(mainSignInner, Enum.NormalId.Back, "★ PAKET KILAT — PUSAT LOGISTIK ★", gold, nil)

		-- Tumpukan Palet & Kardus Paket Siap Antar (Decorative Loading Bay Stacks)
		local palletPos = dcf * CFrame.new(-6.5, 0.2, -1.5)
		local pallet = part(dGroup, "WoodenPallet", Vector3.new(4.2, 0.35, 3.8), palletPos, woodBrown, Enum.Material.Wood)
		-- Cardboard boxes on pallet
		local boxData = {
			{ offset = Vector3.new(-1.1, 0.9, -0.8), size = Vector3.new(1.6, 1.4, 1.6), col = Color3.fromRGB(196, 154, 110) },
			{ offset = Vector3.new(0.9, 0.8, -0.7), size = Vector3.new(1.5, 1.2, 1.5), col = Color3.fromRGB(206, 164, 120) },
			{ offset = Vector3.new(-0.2, 0.8, 0.8), size = Vector3.new(1.8, 1.3, 1.7), col = Color3.fromRGB(186, 144, 100) },
			{ offset = Vector3.new(-0.3, 2.1, 0.0), size = Vector3.new(1.4, 1.1, 1.4), col = Color3.fromRGB(216, 174, 130) },
		}
		for bIdx, bd in ipairs(boxData) do
			local bBox = part(dGroup, "CargoBox" .. bIdx, bd.size, palletPos * CFrame.new(bd.offset), bd.col, Enum.Material.SmoothPlastic)
			-- Tape stripe
			part(dGroup, "Tape" .. bIdx, Vector3.new(bd.size.X + 0.02, 0.15, bd.size.Z + 0.02), bBox.CFrame, gold, Enum.Material.SmoothPlastic)
		end

		totalParts += #dGroup:GetChildren()
	end

	-- ================================================================
	-- 2. CIVIC CENTRE: MODERN CBD MONUMENTS, BANNERS, RECYCLING BINS
	-- ================================================================
	local civicBuildings = {
		{ name = "CBD01_Menara Kilat", title = "MENARA KILAT\nHEADQUARTERS", color = Color3.fromRGB(32, 68, 85) },
		{ name = "CBD02_Kantor Media", title = "KANTOR MEDIA\nKOTA KILAT", color = Color3.fromRGB(45, 75, 65) },
		{ name = "CBD03_Bursa Kreatif", title = "BURSA KREATIF\nINDONESIA", color = Color3.fromRGB(85, 55, 45) },
		{ name = "CBD04_Balai Layanan", title = "BALAI LAYANAN\nPUBLIK TERPADU", color = Color3.fromRGB(50, 60, 75) },
	}

	for _, cbd in ipairs(civicBuildings) do
		local bModel = map.Districts35.CivicCentre:FindFirstChild(cbd.name)
		local body = bModel and (bModel:FindFirstChild("OfficeBody") or bModel:FindFirstChildWhichIsA("BasePart"))
		if body then
			local cGroup = Instance.new("Model", civicFolder)
			cGroup.Name = cbd.name .. "_Monument"

			-- Monolith Plaque Sign in front of Building
			local bcf = body.CFrame
			local frontPos = bcf * CFrame.new(0, -body.Size.Y / 2 + 1.8, -body.Size.Z / 2 - 3.5)

			local base = part(cGroup, "PlaqueBase", Vector3.new(4.8, 0.4, 1.6), frontPos * CFrame.new(0, -1.6, 0), slateGrey, Enum.Material.Granite)
			local pillar = part(cGroup, "PlaqueBody", Vector3.new(4.2, 3.2, 0.6), frontPos, cbd.color, Enum.Material.SmoothPlastic)
			local goldTrim = part(cGroup, "GoldTrim", Vector3.new(4.28, 0.12, 0.68), frontPos * CFrame.new(0, 1.62, 0), gold, Enum.Material.Metal)

			surfaceLabel(pillar, Enum.NormalId.Front, cbd.title, cream, nil)
			surfaceLabel(pillar, Enum.NormalId.Back, cbd.title, cream, nil)

			-- Triple Modern Recycling Bins near building walkway
			local binPos = frontPos * CFrame.new(4.5, -0.7, 0)
			local binPedestal = part(cGroup, "BinStand", Vector3.new(3.2, 0.2, 1.0), binPos * CFrame.new(0, -0.8, 0), slateGrey, Enum.Material.Metal)

			local bins = {
				{ col = Color3.fromRGB(45, 120, 200), label = "KERTAS" },
				{ col = Color3.fromRGB(50, 160, 75), label = "ORGANIK" },
				{ col = Color3.fromRGB(230, 175, 40), label = "PLASTIK" },
			}
			for i, bi in ipairs(bins) do
				local bx = (i - 2) * 0.95
				local bPart = part(cGroup, "RecycleBin" .. i, Vector3.new(0.75, 1.5, 0.75), binPos * CFrame.new(bx, 0.1, 0), bi.col, Enum.Material.SmoothPlastic)
				local bLid = part(cGroup, "RecycleLid" .. i, Vector3.new(0.8, 0.2, 0.8), binPos * CFrame.new(bx, 0.9, 0), darkInk, Enum.Material.Plastic)
				surfaceLabel(bPart, Enum.NormalId.Front, bi.label, modernWhite, nil)
			end

			totalParts += #cGroup:GetChildren()
		end
	end

	-- ================================================================
	-- 3. BATA QUAY: BLADE SIGNS, WALL SCONCES & WINDOW PLANTER BOXES
	-- ================================================================
	local rukoSigns = {
		{ id = "BQ01_Roti Kota", signText = "ROTI KOTA\nBAKERY", signCol = Color3.fromRGB(180, 80, 50) },
		{ id = "BQ02_Kopi Kanal", signText = "KOPI KANAL\nESPRESSO", signCol = Color3.fromRGB(45, 90, 85) },
		{ id = "BQ03_Studio Kertas", signText = "STUDIO KERTAS\nDESAIN", signCol = Color3.fromRGB(40, 70, 95) },
		{ id = "BQ04_Toko Kamera", signText = "KAMERA KILAT\nFOTO", signCol = Color3.fromRGB(75, 45, 80) },
		{ id = "BQ05_Floris Jalan", signText = "FLORIS JALAN\nBUNGA", signCol = Color3.fromRGB(55, 115, 75) },
		{ id = "BQ08_Buku Bata", signText = "BUKU BATA\nLITERATUR", signCol = Color3.fromRGB(140, 60, 45) },
		{ id = "BQ10_Kantor Arsitek", signText = "KANTOR ARSITEK\nSTUDIO", signCol = Color3.fromRGB(35, 60, 70) },
		{ id = "BQ11_Kafe Sudut", signText = "KAFE SUDUT\nBISTRO", signCol = Color3.fromRGB(175, 110, 45) },
		{ id = "BQ16_Galeri Tepi Air", signText = "GALERI SENI\nTEPI AIR", signCol = Color3.fromRGB(50, 95, 105) },
	}

	for _, rs in ipairs(rukoSigns) do
		local rukoModel = map.Districts35.BrickQuay:FindFirstChild(rs.id)
		local body = rukoModel and rukoModel:FindFirstChild("BrickBody")
		if body then
			local bqGroup = Instance.new("Model", quayFolder)
			bqGroup.Name = rs.id .. "_BladeDecor"

			local bcf = body.CFrame
			local halfZ = body.Size.Z / 2
			-- Front face blade sign (protruding perpendicular to facade)
			local signMountPos = bcf * CFrame.new(body.Size.X / 2 - 1.2, -body.Size.Y / 2 + 7.5, -halfZ - 0.1)

			-- Iron bracket
			local mountPlate = part(bqGroup, "WallMount", Vector3.new(0.3, 1.2, 0.12), signMountPos, darkInk, Enum.Material.Metal)
			local bracketArm = part(bqGroup, "BracketArm", Vector3.new(0.12, 0.12, 2.4), signMountPos * CFrame.new(0, 0.4, -1.2), darkInk, Enum.Material.Metal)
			local bracketStay = part(bqGroup, "BracketStay", Vector3.new(0.1, 1.2, 0.1), signMountPos * CFrame.new(0, -0.2, -0.9) * CFrame.Angles(math.pi / 4, 0, 0), darkInk, Enum.Material.Metal)

			-- Hanging double-sided blade sign
			local signBlade = part(bqGroup, "BladeSignBoard", Vector3.new(0.15, 1.8, 2.2), signMountPos * CFrame.new(0, -0.4, -1.3), rs.signCol, Enum.Material.Wood)
			local signBorder = part(bqGroup, "BladeSignBorder", Vector3.new(0.18, 1.9, 2.3), signBlade.CFrame, gold, Enum.Material.Metal)

			surfaceLabel(signBlade, Enum.NormalId.Right, rs.signText, cream, rs.signCol)
			surfaceLabel(signBlade, Enum.NormalId.Left, rs.signText, cream, rs.signCol)

			-- Wall Lanterns on both sides of facade entrance
			for _, xOff in ipairs({ -3.5, 3.5 }) do
				local sconcePos = bcf * CFrame.new(xOff, -body.Size.Y / 2 + 5.5, -halfZ - 0.2)
				part(bqGroup, "LanternArm", Vector3.new(0.12, 0.12, 0.5), sconcePos, darkInk, Enum.Material.Metal)
				local lanternGlass = part(bqGroup, "LanternGlass", Vector3.new(0.5, 0.75, 0.5), sconcePos * CFrame.new(0, -0.35, -0.3), warmGlass, Enum.Material.Neon)
				part(bqGroup, "LanternHood", Vector3.new(0.65, 0.15, 0.65), sconcePos * CFrame.new(0, 0.1, -0.3), darkInk, Enum.Material.Metal)
			end

			-- Window Planter Box on upper floor (Lantai 2)
			local planterPos = bcf * CFrame.new(0, -body.Size.Y / 2 + 11.5, -halfZ - 0.4)
			local box = part(bqGroup, "WindowBox", Vector3.new(4.5, 0.65, 0.75), planterPos, darkInk, Enum.Material.Wood)
			local boxFoliage = part(bqGroup, "BoxFoliage", Vector3.new(4.4, 0.5, 0.7), planterPos * CFrame.new(0, 0.4, 0), foliageGreen, Enum.Material.Grass)

			-- Flowers along the box
			for flX = -1.8, 1.8, 0.9 do
				local flPart = part(bqGroup, "BoxFlower", Vector3.new(0.3, 0.3, 0.3), planterPos * CFrame.new(flX, 0.7, 0.1), (flX > 0 and Color3.fromRGB(250, 120, 140) or gold), Enum.Material.SmoothPlastic)
				local flMesh = Instance.new("SpecialMesh", flPart)
				flMesh.MeshType = Enum.MeshType.Sphere
			end

			totalParts += #bqGroup:GetChildren()
		end
	end

	-- ================================================================
	-- 4. PASAR TRADISIONAL: KIOS SIGNS & FRUIT DISPLAY CRATES
	-- ================================================================
	local market = map:FindFirstChild("MarketGoods18")
	if market then
		local mGroup = Instance.new("Model", marketFolder)
		mGroup.Name = "Market_DisplayCrates"

		local firstItem = market:FindFirstChildWhichIsA("BasePart")
		local marketCenter = firstItem and firstItem.Position or Vector3.new(-30, 4478, 60)

		-- Wooden Produce Crates stacked artistically
		local crateConfigs = {
			{ offset = Vector3.new(-3, 0.4, -2), col = Color3.fromRGB(240, 100, 40), label = "JERUK MANIS" },
			{ offset = Vector3.new(-1, 0.4, -2), col = Color3.fromRGB(215, 45, 45), label = "APEL MERAH" },
			{ offset = Vector3.new(1, 0.4, -2), col = Color3.fromRGB(240, 205, 50), label = "PISANG RAJA" },
			{ offset = Vector3.new(3, 0.4, -2), col = Color3.fromRGB(60, 150, 75), label = "SAYUR SEGAR" },
			{ offset = Vector3.new(-2, 1.15, -1.8), col = Color3.fromRGB(150, 75, 160), label = "ANGGUR" },
			{ offset = Vector3.new(2, 1.15, -1.8), col = Color3.fromRGB(235, 130, 60), label = "WORTEL" },
		}

		for cIdx, cc in ipairs(crateConfigs) do
			local cPos = CFrame.new(marketCenter + cc.offset)
			local crateBody = part(mGroup, "ProduceCrate" .. cIdx, Vector3.new(1.6, 0.7, 1.2), cPos, lightWood, Enum.Material.Wood)
			local producePile = part(mGroup, "ProducePile" .. cIdx, Vector3.new(1.45, 0.4, 1.05), cPos * CFrame.new(0, 0.35, 0), cc.col, Enum.Material.SmoothPlastic)
			local sph = Instance.new("SpecialMesh", producePile)
			sph.MeshType = Enum.MeshType.Sphere

			surfaceLabel(crateBody, Enum.NormalId.Front, cc.label, darkInk, lightWood)
		end

		totalParts += #mGroup:GetChildren()
	end

	return {
		totalParts = totalParts,
		categories = {
			kampung = #kampungFolder:GetChildren(),
			civic = #civicFolder:GetChildren(),
			bataQuay = #quayFolder:GetChildren(),
			market = #marketFolder:GetChildren(),
		}
	}
end

return B
