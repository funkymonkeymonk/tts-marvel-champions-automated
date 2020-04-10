--[[
    To Test villianSpecificSetup run the below command in the console
    lua getObjectFromGUID("67f336").call("villianSpecificSetup", params)
]] 

scenarioParameters = {
  basicSetup = "True",
  basicExpert = "True",
  villianName = "Norman Osborn/Green Goblin",
  mainSchemeName = "Main Scheme",
  includeStandard = "True"
}

local getFromBag = | params | getObjectFromGUID("330ff1").call("getFromBag", params)
local getFromDeck = | params | getObjectFromGUID("330ff1").call("getFromDeck", params)

function scenarioSpecificSetup(params)
  local villianGUID = params.villianGUID
  local encounterDeckGUID = params.encounterDeckGUID
  local expert = params.expert
  local villianName = params.villianName
  local scenarioBagGUID = params.scenarioBagGUID

  local environmentParams = { position = {-10,3,3.4} }
  getFromBag({
    searchBy = "name",
    searchTerm = "Criminal Enterprise/State of Madness",
    params =  environmentParams,
    guid = scenarioBagGUID
  })

  broadcastToAll("Remember to put starting infamy counters on Criminal Enterprise")
end
