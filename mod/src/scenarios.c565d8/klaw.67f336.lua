--[[
    To Test villianSpecificSetup run the below command in the console
    lua getObjectFromGUID("67f336").call("villianSpecificSetup", params)
]] 

scenarioParameters = {
  basicSetup = "True",
  basicExpert = "True",
  villianName = "Klaw",
  mainSchemeName = "Main Scheme",
  includeStandard = "True"
}

local getFromBag = | params | getObjectFromGUID("330ff1").call("getFromBag", params)
local getFromDeck = | params | getObjectFromGUID("330ff1").call("getFromDeck", params)

function scenarioSpecificSetup(params)
  local villianGUID = params.villianGUID
  local encounterDeckGUID = params.encounterDeckGUID
  local expert = params.expert

  local sideSchemeParams = { position = {10,0,6.4}, rotation={0,90,0} }
  getFromDeck({
    searchBy = "name",
    searchTerm = "Defense Network",
    params =  sideSchemeParams,
    guid = encounterDeckGUID
  })
  
  if expert == "True" then
    -- Put out Immortal Klaw
    local sideSchemeParams = { position = {15,0,10.4}, rotation={0,90,0} }
    getFromDeck({
      searchBy = "name",
      searchTerm = "Immortal Klaw",
      params =  sideSchemeParams,
      guid = encounterDeckGUID
    })
  end
end
