-- Local street-graph planner. Never moves characters or grants a stamp.
local M={}
local function projection(p,a,b)
 local delta=b-a local n=delta:Dot(delta)
 local t=n>.0001 and math.clamp((p-a):Dot(delta)/n,0,1)or 0
 return a+delta*t,t
end
function M.Plan(start,routes,extra,stations,visited,options)
 local segments={}
 local function append(path)
  for i=1,#path-1 do if(path[i+1]-path[i]).Magnitude>.02 then table.insert(segments,{path[i],path[i+1]})end end
 end
 for _,path in pairs(routes)do append(path)end
 for _,path in ipairs(extra or {})do append(path)end
 if #segments==0 then return nil end
 local nodes={}
 local function node(p)
  for i,v in ipairs(nodes)do if(v-p).Magnitude<.015 then return i end end
  table.insert(nodes,p)return #nodes
 end
 for _,edge in ipairs(segments)do node(edge[1])node(edge[2])end
 local function nearest(p)
  local at,distance
  for _,edge in ipairs(segments)do local q=projection(p,edge[1],edge[2]);local d=(p-q).Magnitude
   if not distance or d<distance then at,distance=q,d end
  end
  return at,distance
 end
 local at,join=nearest(start)local first=node(at)
 local candidates={}
 for _,station in ipairs(stations or {})do
  if not (visited or {})[station.id]then
   local q=nearest(station.position)
   local delta=station.position-q
   table.insert(candidates,{station=station,index=node(q),approach=Vector3.new(delta.X,0,delta.Z).Magnitude})
  end
 end
 if #candidates==0 then return nil end
 local goal,goalApproach
 if options and options.destination then
  local q=nearest(options.destination)goal=node(q)
  local d=options.destination-q goalApproach=Vector3.new(d.X,0,d.Z).Magnitude
 end
 local links={}
 for i=1,#nodes do links[i]={}end
 for _,edge in ipairs(segments)do
  local split={}
  for i,p in ipairs(nodes)do local q,t=projection(p,edge[1],edge[2]);if(p-q).Magnitude<.02 then table.insert(split,{index=i,t=t})end end
  table.sort(split,function(a,b)return a.t<b.t end)
  for i=1,#split-1 do
   local a,b=split[i].index,split[i+1].index local d=(nodes[a]-nodes[b]).Magnitude
   links[a][b]=d links[b][a]=d
  end
 end
 local function search(source)
  local distance,previous,done={[source]=0},{},{}
  for _=1,#nodes do
   local best
   for i,d in pairs(distance)do if not done[i]and(not best or d<distance[best])then best=i end end
   if not best then break end done[best]=true
   for nextIndex,cost in pairs(links[best])do
    local d=distance[best]+cost
    if not distance[nextIndex]or d<distance[nextIndex]then distance[nextIndex]=d previous[nextIndex]=best end
   end
  end
  return distance,previous
 end
 local distance,previous=search(first)
 local cache={}
 local function from(index)
  if not cache[index]then cache[index]=search(index)end
  return cache[index]
 end
 local chosen,bestScore
 for _,candidate in ipairs(candidates)do
  local d=distance[candidate.index]and(distance[candidate.index]+candidate.approach)
  if d and goal then
   local onward=from(candidate.index)
   local rest=onward[goal]and(onward[goal]+goalApproach)
   if math.min(options.needed or 1,#candidates)>1 then
    rest=nil
    for _,second in ipairs(candidates)do if second~=candidate and onward[second.index]then
     local tail=from(second.index)[goal]
     local cost=tail and onward[second.index]+2*second.approach+tail+goalApproach
     if cost and(not rest or cost<rest)then rest=cost end
    end end
   end
   d=rest and distance[candidate.index]+2*candidate.approach+rest
  end
  if d and(not chosen or d<bestScore-.01 or math.abs(d-bestScore)<.01 and candidate.station.id<chosen.station.id)then chosen,bestScore=candidate,d end
 end
 if not chosen then return nil end
 local reverse={}local cursor=chosen.index
 while cursor do table.insert(reverse,nodes[cursor]);if cursor==first then break end cursor=previous[cursor]end
 local path={}
 for i=#reverse,1,-1 do table.insert(path,reverse[i])end
 return {station=chosen.station,points=path,distance=join+distance[chosen.index]+chosen.approach,tourDistance=join+bestScore}
end
return M
