--[[
    To Test villianSpecificSetup run the below command in the console
    lua getObjectFromGUID("67f336").call("villianSpecificSetup", params)
]] 

scenarioParameters = {
  basicSetup = "True",
  basicExpert = "True",
  villianName = "Green Goblin",
  mainSchemeName = "Main Scheme",
  includeStandard = "True"
}

local getFromBag = | params | getObjectFromGUID("330ff1").call("getFromBag", params)
local getFromDeck = | params | getObjectFromGUID("330ff1").call("getFromDeck", params)

function scenarioSpecificSetup(params)
  local encounterDeckGUID = params.encounterDeckGUID
  local expert = params.expert

  expert = "True"
  
  if expert == "True" then
    broadcastToAll("Remember to deal two encounter cards to each player at the start of the game")
  end
  broadcastToAll("Remember to put a goblin thrall minion into play for each player")
end
