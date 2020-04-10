--[[
  To Test Run the below command in the console
  lua getObjectFromGUID("4b3af9").call("setup", {guid = "4b3af9"})
]] 

scenarioParameters = {
  basicSetup = "False",
}

function scenarioSpecificSetup(params)
  local scenarioBagGUID = params.scenarioBagGUID
  local expert = params.expert

  local FLIPPED = {180,0,0}
  local SIDEWAYS = {0,90,0}
  local getFromBag = | params | getObjectFromGUID("330ff1").call("getFromBag", params)
  local getFromDeck = | params | getObjectFromGUID("330ff1").call("getFromDeck", params)

  log("Setting up The Wrecking Crew")
  local announce = "Constructing"
  if expert == "True" then announce = announce .. " expert" end
  announce = announce .. " Wrecking Crew encounter deck."
  broadcastToAll(announce)

  function layoutVillian (name, xOffset, scenarioBagGUID)
    local villianParams = { position = {xOffset,0,5}, rotation={0,180,0}}
    local encounterParams = { position = {xOffset,0,10}, rotation=FLIPPED}
    local sideSchemeParams = { position = {xOffset + 4.5,0,5}, rotation=SIDEWAYS }
    getFromBag({
      searchBy = "name",
      searchTerm = name.." Encounter Deck",
      params = encounterParams,
      guid = scenarioBagGUID
    })

    local villianSearch = name.." A"
    
    if expert == "True" then
      villianSearch = name.." B" 
    end
    
    getFromBag({
      searchBy = "name",
      searchTerm = villianSearch,
      params = villianParams,
      guid = scenarioBagGUID
    })
    
    getFromBag({
      searchBy = "description",
      searchTerm = name.." Side Scheme",
      params = sideSchemeParams,
      guid = scenarioBagGUID
    })
  end

  local mainSchemeParams = { position = {0,0,15}, rotation=SIDEWAYS }

  -- Build Decks
  getFromBag({
    searchBy = "name",
    searchTerm = "Breakout",
    params =  mainSchemeParams,
    guid = scenarioBagGUID
  })
  
  layoutVillian("Wrecker", -16, scenarioBagGUID)
  layoutVillian("Thunderball", -7, scenarioBagGUID)
  layoutVillian("Piledriver", 2, scenarioBagGUID)
  layoutVillian("Bulldozer", 11, scenarioBagGUID)
end
