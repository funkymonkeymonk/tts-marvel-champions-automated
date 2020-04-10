--[[
    To Test villianSpecificSetup run the below command in the console
    lua getObjectFromGUID("0b86f0").call("villianSpecificSetup", params)
]] 

scenarioParameters = {
  basicSetup = "True",
  basicExpert = "True",
  villianName = "Rhino",
  mainSchemeName = "The Break-In!",
  includeStandard = "True",
  villianSpecificSetup = villianSpecificSetup
}

local getFromBag = | params | getObjectFromGUID("330ff1").call("getFromBag", params)
local getFromDeck = | params | getObjectFromGUID("330ff1").call("getFromDeck", params)

function scenarioSpecificSetup(params)
  local villianGUID = params.villianGUID
  local encounterDeckGUID = params.encounterDeckGUID
  local expert = params.expert
  
  if expert == "True" then
    -- Put out Breakin & Takin
    local sideSchemeParams = { position = {10,0,6.4}, rotation={0,90,0} }
    getFromDeck({
      searchBy = "name",
      searchTerm = "Breakin & Takin",
      params =  sideSchemeParams,
      guid = encounterDeckGUID
    })
  end
end
