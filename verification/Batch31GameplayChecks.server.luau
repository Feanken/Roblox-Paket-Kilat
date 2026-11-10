local E=require(game.ServerScriptService.PaketKilat.EconomyService)local D=require(game.ServerScriptService.PaketKilat.DeliveryService)
local p=game.Players:GetPlayers()[1]or game.Players.PlayerAdded:Wait()
repeat task.wait(.1)until E.Has(p)and p.Character and p.Character:FindFirstChild('HumanoidRootPart')
assert(game.GameId==0 and E.Snapshot(p).storageMode=='StudioMemory')
local lastId,lastDest,oldOffer
local function move(at)
 p.Character:PivotTo(CFrame.new(at))p.Character.HumanoidRootPart.Anchored=true
 local o=D.orders[p.UserId]if o then o.previousPosition,o.previousVelocity,o.previousSampleAt=nil,nil,nil end
end
local function depot()move(workspace.PaketKilat.Map.DepotPad.CFrame:PointToWorldSpace(Vector3.new(0,4,2)))end
local function req(action,id,dest)
 for _=1,20 do local ok,code=D.Handle(p,action,id,dest,action=='Deliver'and 3 or 2)if code~='RateLimited'then return ok,code end task.wait(.25)end
 error('request retry exhausted')
end
local function read(extra)
 local s=D.Snapshot(p)return game.HttpService:JSONEncode({extra=extra,status=s.status,batch=s.batch,coins=s.coins,history=#s.recentDeliveries,result=s.lastResult,sourceId=s.sourceId,packageType=s.packageType,packages=#workspace.PaketKilat.ActivePackages:GetChildren()})
end
local fn=Instance.new('BindableFunction')fn.Name='TemporaryBatch31Harness'fn.Parent=game.ServerStorage
fn.OnInvoke=function(action,value)
 if action=='start'then
  if D.orders[p.UserId]then D.Cancel(p,'Cancelled')end depot()
  local offer=E.PeekBatchOffers(p)[value or 1]oldOffer=offer.id
  local ok,code=req('AcceptBatch',offer.id)assert(ok,code)
 elseif action=='step'then
  local o=D.orders[p.UserId]assert(o)
  if value then o.condition=value end
  o.startedAt=workspace:GetServerTimeNow()-5
  local target=workspace.PaketKilat.Map[o.destinationId].DestinationPoint
  move(target.Position+Vector3.new(0,3,0))lastId,lastDest=o.orderId,o.destinationId
  local ok,code=req('Deliver',lastId,lastDest)assert(ok,code)
 elseif action=='replay'then
  local coins=E.Snapshot(p).coins local index=D.Snapshot(p).batch and D.Snapshot(p).batch.index
  local ok,code=req('Deliver',lastId,lastDest)assert(not ok)
  assert(E.Snapshot(p).coins==coins)assert(not index or D.Snapshot(p).batch.index==index)
  return read({code=code,replaySafe=true})
 elseif action=='wrong'then
  local o=D.orders[p.UserId]local wrong=o.destinationId=='Rumah01'and'Rumah02'or'Rumah01'
  local ok,code=req('Deliver',o.orderId,wrong)assert(not ok and code=='WrongDestination',code)
  return read({code=code})
 elseif action=='recover'then
  local o=D.orders[p.UserId]local ok,code=req('Drop',o.orderId)assert(ok,code)
  ok,code=req('Recover',o.orderId)assert(ok,code)
  move(o.package.Position+Vector3.new(0,3,0))
  ok,code=req('Pickup',o.orderId)assert(ok,code)
 elseif action=='cancel'then
  local o=D.orders[p.UserId]local coins=E.Snapshot(p).coins
  local ok,code=req('CancelBatch',o.orderId)assert(ok,code)
  assert(not D.batches[p.UserId]and not D.orders[p.UserId]and E.Snapshot(p).coins==coins)
 elseif action=='stale'then
  depot()local ok,code=req('AcceptBatch',oldOffer)assert(not ok and code=='OfferExpired',code)
  return read({code=code})
 elseif action=='overflow'then
  local o=D.orders[p.UserId]local profile=E.sessions[p.UserId].profile local coins=profile.coins
  local count=profile.deliveryCount local history=#E.sessions[p.UserId].history
  profile.coins=999999999
  move(workspace.PaketKilat.Map[o.destinationId].DestinationPoint.Position+Vector3.new(0,3,0))
  local ok,code=req('Deliver',o.orderId,o.destinationId)
  assert(not ok and code=='EconomyLimit',code)assert(o.status=='Carrying'and not o.completionLocked and D.batches[p.UserId].index==1)
  assert(profile.deliveryCount==count and #E.sessions[p.UserId].history==history)profile.coins=coins
  return read({code=code,atomic=true})
 elseif action=='ordinary'then
  if D.orders[p.UserId]then D.Cancel(p,'Cancelled')end depot()
  local ok,code=req('AcceptJob',E.PeekOffers(p)[1].id)assert(ok,code)
 elseif action=='priority'then
  if D.orders[p.UserId]then D.Cancel(p,'Cancelled')end depot()
  local ok,code=req('AcceptJob',E.PeekOffers(p)[4].id)assert(ok,code)
 elseif action=='relay'then
  local offer=D.Snapshot(p).relayOffer assert(offer)move(offer.pickupPosition+Vector3.new(0,3,0))
  local ok,code=req('AcceptRelay',offer.id)assert(ok,code)
 elseif action=='death'then
  p.Character.Humanoid.Health=0
 elseif action=='read'then
 else error('unknown action')end
 return read(action)
end
workspace:SetAttribute('Batch31Ready',true)