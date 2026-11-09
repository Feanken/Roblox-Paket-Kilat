-- Script sementara di ServerScriptService. Memutus satu klien Studio untuk uji PlayerRemoving nyata.
local Players=game:GetService("Players")
local D=require(game.ServerScriptService.PaketKilat.DeliveryService)
local E=require(game.ServerScriptService.PaketKilat.EconomyService)
local L=require(game.ServerScriptService.PaketKilat.PlayerLifecycle)
local player=Players:GetPlayers()[1]
local o=assert(D.orders[player.UserId],"Exit test needs active order")
local package,connection=o.package,o.promptConnection
local session=E.sessions[player.UserId]
local before=session.coins
local observer
observer=Players.PlayerRemoving:Connect(function(leaving)
	if leaving~=player then return end
	task.defer(function()
		local report={
			mode="Actual PlayerRemoving via Kick in local Studio Play",
			coinsBefore=before,coinsBeforeDiscard=session.coins,
			orderRemoved=D.orders[player.UserId]==nil,
			requestCacheRemoved=D.requests[player.UserId]==nil,
			sessionRemoved=E.sessions[player.UserId]==nil,
			lifecycleBindingsRemoved=L.bindings[player]==nil,
			packageRemoved=package.Parent==nil,
			packageConnectionRemoved=not connection.Connected,
			activePackages=#workspace.PaketKilat.ActivePackages:GetChildren(),
		}
		report.pass=report.orderRemoved and report.requestCacheRemoved and report.sessionRemoved and report.lifecycleBindingsRemoved and report.packageRemoved and report.packageConnectionRemoved and report.activePackages==0 and before==session.coins
		local v=Instance.new("StringValue")
		v.Name,v.Value,v.Parent="Stage2ExitReport",game.HttpService:JSONEncode(report),workspace
		print("[PaketKilat STAGE2 EXIT]",v.Value)
		observer:Disconnect()
	end)
end)
task.delay(1,function() player:Kick("Uji keluar sesi prototipe Paket Kilat (T09).") end)
