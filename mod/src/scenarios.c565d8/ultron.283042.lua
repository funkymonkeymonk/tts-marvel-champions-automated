--[[
    To Test villianSpecificSetup run the below command in the console
    lua getObjectFromGUID("330ff1").call("externalSetup", getObjectFromGUID("283042"))
]] 

scenarioParameters = {
  basicSetup = "True",
  basicExpert = "True",
  villianName = "Ultron",
  mainSchemeName = "Main Scheme",
  includeStandard = "True"
}

local getFromBag = | params | getObjectFromGUID("330ff1").call("getFromBag", params)
local getFromDeck = | params | getObjectFromGUID("330ff1").call("getFromDeck", params)

function scenarioSpecificSetup(params)
  local villianGUID = params.villianGUID
  local encounterDeckGUID = params.encounterDeckGUID
  local expert = params.expert
  local scenarioBagGUID = params.scenarioBagGUID

  local environmentParams = { position = {-10,3,3.4} }
  getFromBag({
    searchBy = "name",
    searchTerm = "Ultron Drones",
    params =  environmentParams,
    guid = scenarioBagGUID
  })

  broadcastToAll("Remember the 'When Revealed' effect of the main scheme")
end
