function dump(o)
  if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
        if type(k) ~= 'number' then k = '"'..k..'"' end
        s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
  else
      return tostring(o)
  end
end

function onRandomize()
  local playerList = getSeatedPlayers()
  local firstPlayer = playerList[ math.random( #playerList ) ]
  broadcastToAll("First player is "..Player[firstPlayer].steam_name)
end
