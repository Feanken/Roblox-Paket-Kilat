-- Curated decorative residents; structural positions follow the current map.
local P={DesktopSlots=8,MobileSlots=5,Radius=135,SelectionInterval=.75,DesktopStep=1/20,MobileStep=1/12,Residents={}}
local function walk(id,district,a,c,index,prop)
 table.insert(P.Residents,{Id=id,District=district,Mode="Walk",A=Vector2.new(a[1],a[2]),B=Vector2.new(c[1],c[2]),Style=index,Prop=prop,Speed=2.8,Dwell=2.4,Phase=index*7.1})
end
local function stay(id,district,x,z,yaw,mode,index,prop)
 table.insert(P.Residents,{Id=id,District=district,Mode=mode,A=Vector2.new(x,z),Yaw=yaw,Style=index,Prop=prop,Phase=index*7.1})
end
walk("PesisirWalker","OldTown",{-66,-19.2},{-34,-19.2},1,"Bag")
stay("GardenReader","OldTown",-54,-5,65,"Read",2,"Book")
walk("OldShopVisitor","OldTown",{-82,40.5},{-36,40.5},3,"Bag")
stay("MarketShopper","OldTown",78,122,0,"Idle",4,"Bag")
walk("CivicPromenade","CivicCentre",{0,204},{0,264},5)
walk("CivicGardenWalk","CivicCentre",{-58,232},{-33,232},6,"Book")
walk("BoulevardVisitor","CivicCentre",{-60,293},{49,293},7,"Bag")
walk("OfficeWestWalker","CivicCentre",{-81,173},{-81,221},8)
walk("OfficeEastWalker","CivicCentre",{87,202},{87,262},9,"Bag")
stay("ParkReader","CivicCentre",22,243,70,"Read",10,"Book")
walk("QuayShopper","BrickQuay",{-402,125.2},{-277,125.2},11,"Bag")
walk("QuayBookshopVisitor","BrickQuay",{-405,182.2},{-354,182.2},12,"Book")
walk("QuayEastVisitor","BrickQuay",{-246,182.2},{-204,182.2},13,"Bag")
walk("QuayNorthWalker","BrickQuay",{-326,240.3},{-204,240.3},14)
walk("CanalWalker","BrickQuay",{-174.8,187},{-174.8,215},15,"Bag")
stay("CafeGuest","BrickQuay",-349.2,201,-90,"Sit",16,"Cup")
stay("RecordCafeGuest","BrickQuay",-408.7,251,-90,"Sit",17,"Cup")
stay("FlorisVisitor","BrickQuay",-276,212,0,"Drink",18,"Cup")
return P
