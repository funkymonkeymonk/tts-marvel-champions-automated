--[[
  To Test Run the below command in the console
  lua getObjectFromGUID("4b3af9").call("setup", {guid = "4b3af9"})
]]

tokenBagGUID = "b7675d"

scenarioParameters = {
  basicSetup = "False",
}

function scenarioSpecificSetup(params)
  local scenarioBagGUID = params.scenarioBagGUID
  local expert = params.expert

  local FLIPPED = { 180, 0, 0 }
  local SIDEWAYS = { 0, 90, 0 }
  local getFromBag = function(params)
    return getObjectFromGUID("330ff1").call("getFromBag", params)
  end
  local getFromDeck = function(params)
    return getObjectFromGUID("330ff1").call("getFromDeck", params)
  end

  log("Setting up The Wrecking Crew")
  local announce = "Constructing"
  if expert == "True" then
    announce = announce .. " expert"
  end
  announce = announce .. " Wrecking Crew encounter deck."
  broadcastToAll(announce)

  function layoutVillain (name, xOffset, scenarioBagGUID)
    local villianBagParams = { position = { xOffset, 2, 12 }, rotation = { 0, 0, 0 } }
    local villianParams = { position = { xOffset, 2, 4.5 }, rotation = { 0, 180, 0 } }
    local encounterParams = { position = { xOffset, 2, 10 }, rotation = FLIPPED }
    local sideSchemeParams = { position = { xOffset + 4.5, 2, 5 }, rotation = SIDEWAYS }
    local healthTrackerParams = { position = { xOffset, 4, 5.5 }, rotation = { 0, 0, 0 } }

    local villianBag = getFromBag({
      searchBy = "name",
      searchTerm = name,
      params = villianBagParams,
      guid = scenarioBagGUID
    })
    
    local healthTracker = getFromBag({
      searchBy = "name",
      searchTerm = "Health Tracker",
      params = healthTrackerParams,
      guid = tokenBagGUID
    })

    local villianBagGUID = villianBag.guid
    local villianSearch = name.." A"

    if expert == "True" then
      villianSearch = name .. " B"
    end

    function unpackBag()
      getFromBag({
        searchBy = "name",
        searchTerm = name.." Encounter Deck",
        params = encounterParams,
        guid = villianBagGUID
      })

      getFromBag({
        searchBy = "name",
        searchTerm = villianSearch,
        params = villianParams,
        guid = villianBagGUID
      })

      getFromBag({
        searchBy = "description",
        searchTerm = name.." Side Scheme",
        params = sideSchemeParams,
        guid = villianBagGUID
      })

      if name == "Wrecker" then
        healthTracker.setColorTint("Purple")
      elseif name =="Thunderball" then
        healthTracker.setColorTint("Green")
      elseif name =="Piledriver" then
        healthTracker.setColorTint("Red")
      elseif name =="Bulldozer" then
        healthTracker.setColorTint("Yellow")
      else
        healthTracker.setColorTint("Black")
      end

      Wait.frames(function()
        destroyObject(villianBag)
      end, 1)
    end

    Wait.frames(unpackBag, 1)
  end

  local mainSchemeParams = { position = {0,2,15}, rotation=SIDEWAYS }

  -- Build Decks
  getFromBag({
    searchBy = "name",
    searchTerm = "Breakout",
    params =  mainSchemeParams,
    guid = scenarioBagGUID
  })

  local threatBagParams = { position = { 5, 2, 15 }, rotation = { 0, 0, 0 } }
  getFromBag({
    searchBy = "name",
    searchTerm = "Threat",
    params = threatBagParams,
    guid = tokenBagGUID
  })

  layoutVillain("Wrecker", -16, scenarioBagGUID)
  layoutVillain("Thunderball", -7, scenarioBagGUID)
  layoutVillain("Piledriver", 2, scenarioBagGUID)
  layoutVillain("Bulldozer", 11, scenarioBagGUID)
end



