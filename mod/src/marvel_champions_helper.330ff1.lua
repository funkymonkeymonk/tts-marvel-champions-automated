--[[ Lua code. See documentation: http://berserk-games.com/knowledgebase/scripting/ --]]

--[[
  TODO: ? Fix risky business and norman osbourne flipped side
  TODO: Clean up encounter builder
  TODO: UI Beautification
  TODO: Figure out how to manage special hero and villian setups
  TODO: Automate villian and hero life and threat counter setup
  TODO: Create a default "Villian playmat"
  TODO: ? Automate dealing out encounter cards
  TODO: ? Automate discarding encounter cards
  TODO: ? Create encounter card locations for each player
  TODO: Default hero decks from the packs
  TODO: Default scenarios with default modular encounters
  TODO: Multiple modular encounters
  TODO: Change out tokens for stylized counters
  TODO: Custom keyboard bindings for increase/decrease villian health
  TODO: Custom keyboard bindings for increase/decrease main scheme threat
  TODO: Refactor for less global variables
  TODO: Include manual deck creation
  TODO: Include import from text
  TODO: Do proper sorting and searching instead of brute force for loops
  TODO: Figure out how to better modularize this code
  TODO: Resize playmats to all be the same size
  TODO: Better table image 
]]

-- Testing flags
flags = {
  --setTestingDeckIds = true,
  --heroSpawnTesting = true,
  -- encounterSpawnTesting = true,
  ui = {
    -- main = true,
    -- hero = true,
    -- encounter = true,
    -- player = true,
  }
}

function onLoad()
  --[[ print('onLoad!') --]]
  init()

  -- MarvelDB Constants
  apiURL="https://marvelcdb.com/api/"
  publicDeckURL=apiURL .. "public/decklist/"
  privateDeckURL=apiURL .. "public/deck/"
  cardURL=apiURL .. "public/card/"

  -- GUIDs
  -- Do I want to put these bags inside a top level bag? I don't know.
  scriptContainerGUID = "330ff1"
  herosBagGUID = "2b6eb2"
  playmatBagGUID = "734df4"
  encountersBagGUID = "2b9868"
  scenariosBagGUID = "c565d8"
  modularEncountersBagGUID = "684df1"
  tokenBagGUID = "b7675d"

  -- Key Positions
  -- Position in X Y Z
  -- X = Left/Right
  -- Y = Above/Below the table 
  -- Z = Up/Down table

  -- Global rotations
  FLIPPED = {180,0,0}
  SIDEWAYS = {0,90,0}

  -- Globals
  privateDeck = true
  scenario = ""
  modularEncounter = ""
  includeStandard = "True"
  includeExpert = "False"
  defaultPlaymatName = "Marvel Champions"
  playerCount = 1
  playerColors = {"Blue", "Red", "Yellow", "Green"}

  -- Create Interface
  uiBuilder.makeUI()
  uiBuilder.uiToggleButton()
  if flags.heroSpawnTesting then buildHeroDeckClicked(Player["Blue"]) end
  if flags.encounterSpawnTesting then buildEncounterDeckClicked(Player["Blue"]) end
end

-- Logging and Error Handling Function
function onTimeout(action, timeoutTime)
  print("TIMEOUT: "..action.." did not complete within "..timeout.." seconds")
end

-- Bag Management Functions
function getBagName(bagGUID)
  return getObjectFromGUID(bagGUID).getName()
end

function getBagContents(bagGUID)
  local bag = getObjectFromGUID(bagGUID)
  return bag.getObjects()
end

--[[
  TODO: Deprecate all usages and move to parameterized version
]]
function getFromBagOld(name, cloneParams, bagGUID)
  local bag = getObjectFromGUID(bagGUID)
  local bagContents = bag.getObjects()

  if (bagContents != nil) then
  for k,v in pairs(bagContents) do
  if (v.name == name) then
  bagObjectParameters = {
  position = {0,0,60}
  , rotation = self.getRotation()
  , guid = v.guid
  , smooth = false
  }

  local bagItem = bag.takeObject(bagObjectParameters)
  local cloneItem = bagItem.clone(cloneParams)
  bag.putObject(bagItem)
  log(name .. ' loaded')
  return cloneItem
  end
  end
  end

  print(name.." not found in bag")
end

function getRandomFromBag(bagGUID)
  bag = getObjectFromGUID(bagGUID)
  bag.shuffle()
  return getBagContents(bagGUID)[1].name
end

function getFromBag(params)
  local searchBy = params.searchBy
  local searchTerm =  params.searchTerm
  local cloneParams = params.params
  local bagGUID = params.guid
  local bag = getObjectFromGUID(bagGUID)
  local bagContents = bag.getObjects()

  log("Searching for " .. searchTerm .. " by " .. searchBy)

  if (bagContents != nil) then
  for k,v in pairs(bagContents) do
  if (v[searchBy] == searchTerm) then
  bagObjectParameters = {
  position = {0,0,60}
  , rotation = self.getRotation()
  , guid = v.guid
  , smooth = false
  }

  local bagItem = bag.takeObject(bagObjectParameters)
  local cloneItem = bagItem.clone(cloneParams)
  bag.putObject(bagItem)
  log(searchTerm .. ' loaded')
  return cloneItem
  end
  end
  end

  print(searchTerm.." not found in bag")
end

function getFromDeck(params)
  local searchBy = params.searchBy
  local searchTerm =  params.searchTerm
  local cloneParams = params.params
  local bagGUID = params.guid
  local bag = getObjectFromGUID(bagGUID)
  local bagContents = bag.getObjects()

  log("Searching for " .. searchTerm .. " by " .. searchBy)

  if (bagContents != nil) then
  for k,v in pairs(bagContents) do
  if (v[searchBy] == searchTerm) then
  cloneParams.guid = v.guid

  local bagItem = bag.takeObject(cloneParams)
  log(searchTerm .. ' retrieved')
  return bagItem
  end
  end
  end

  print(searchTerm.." not found in bag")
end

-- MavelDB Functions
function getDeckFromDB()
  if privateDeck then deckURL = privateDeckURL
  else deckURL = publicDeckURL
  end

  if (flags.setTestingDeckIds) then
    deckURL = publicDeckURL
    deckID = 449
  end

  if not deckID then
    print("Deck ID can not be empty")
    return
  end

  log(deckURL)
  log(deckID)
  WebRequest.get(deckURL .. deckID, self, 'deckReadCallback')
end

function deckReadCallback(req)
  log("Deck Response Received")
  -- Result check..
  if req.is_done and not req.is_error then
    if string.find(req.text, "<!DOCTYPE html>") then
      broadcastToAll("Private deck "..deckID.." is not shared", {0.5,0.5,0.5})
      return
    end
    JsonDeckRes = JSON.decode(req.text)
  else
    print (req.error)
    return
  end

  if (JsonDeckRes == nil)
  then
    broadcastToAll("Deck not found!", {0.5,0.5,0.5})
    return
  else
    print("Found decklist: "..JsonDeckRes.name)
  end
  -- Count number of cards in decklist
  numSlots=0
  for cardid,number in
  pairs(JsonDeckRes.slots)
  do
    numSlots = numSlots + 1
  end

  -- Save card id, number in table and request card info from MarvelDB
  local totalCards = 0
  for cardID,number in pairs(JsonDeckRes.slots)
  do
    local row = {}
    row.cardName = ""
    row.cardCount = number
    cardList[cardID] = row
    WebRequest.get(cardURL .. cardID, self, 'cardReadCallback')
    totalCards = totalCards + number
  end
end

function cardReadCallback(req)
  -- Result check..
  if req.is_done and not req.is_error
  then
    -- Find unicode before using JSON.decode since it doesnt handle hex UTF-16
    local tmpText = string.gsub(req.text,"\\u(%w%w%w%w)", convertHexToDec)
    JsonCardRes = JSON.decode(tmpText)
  else
    print(req.error)
    return
  end

  -- Update card name in table
  if(JsonCardRes.xp == nil or JsonCardRes.xp == 0)
  then
    cardList[JsonCardRes.code].cardName = JsonCardRes.real_name
  else
    cardList[JsonCardRes.code].cardName = JsonCardRes.real_name .. " (" .. JsonCardRes.xp .. ")"
  end

  doneSlots = doneSlots + 1
end

-- Deck Construction Functions
function init()
  -- Initialize Variable
  cardList = {}
  doneSlots = 0
end

-- Helpers to be moved
-- This is the start of hacking together a promise wrapper
-- I kinda hate myself for this but the callback hell is starting to get to me.

function markAsFinished(waitfor, caller)
  waitfor[caller] = true
end

function allFinished(waitfor)
  local result = true
  for _, v in pairs(waitfor) do
    if not v then result = false end
  end
  return result
end

-- ENCOUNTER FUNCTIONS
function basicSetup(params)
  local scenarioBagGUID = params.scenarioBagGUID
  local scenarioBag = getObjectFromGUID(scenarioBagGUID)
  local expert = params.expert
  local modularEncounters = params.modularEncounters
  local villianName = params.villianName
  local mainSchemeName =params.mainSchemeName
  local includeStandard = params.includeStandard

  -- Spend some effort to make this sound epic
  local announce = "Constructing"
  if expert == "True" then announce = announce .. " expert" end
  if modularEncounters != nil then
  announce = announce .. " " .. villianName .. " encounter deck with " .. modularEncounters
  else
  announce = announce .. " " .. villianName .. " encounter deck."
  end

  broadcastToAll(announce)

  -- Delete this once there is a better way of managing state
  function putOutTokens()
  local villianHealthTrackerParams = { position = {3,0,13.25}, rotation={0,0,0}}
  getFromBag({
  searchBy = "name",
  searchTerm = "Health Tracker",
  params =  villianHealthTrackerParams,
  guid = tokenBagGUID
  })

  local threatBagParams = { position = {11.25,0,14.5}, rotation={0,0,0}}
  getFromBag({
  searchBy = "name",
  searchTerm = "Threat",
  params =  threatBagParams,
  guid = tokenBagGUID
  })

  local accelerationBagParams = { position = {8.5,0,14.5}, rotation={0,0,0}}
  getFromBag({
  searchBy = "name",
  searchTerm = "Acceleration",
  params =  accelerationBagParams,
  guid = tokenBagGUID
  })
  end

  local waitfor = {}

  -- Put out the encounter deck
  waitfor.encounterDeck = false
  local encounterDeckParams = {
  position = {-3,0,9.5}
  , rotation = {180,0,0}
  , callback_function = || markAsFinished(waitfor, "encounterDeck")
  }
  params.encounterDeckGUID = getFromBag({
  searchBy = "name",
  searchTerm = "Encounter Deck",
  params =  encounterDeckParams,
  guid = scenarioBagGUID
  }).guid

  -- Put Out the Main Scheme
  waitfor.mainScheme = false
  local mainSchemeParams = {
  position = {10,0,10.4}
  , rotation={0,90,180}
  , callback_function = || markAsFinished(waitfor, "mainScheme")
  }
  params.mainSchemeGUID = getFromBag({
  searchBy = "name",
  searchTerm = mainSchemeName,
  params =  mainSchemeParams,
  guid = scenarioBagGUID
  }).guid

  -- Put Out the Villian
  waitfor.villian = false
  local villianParams = {
  position = {3,0,9.5}
  , callback_function = || markAsFinished(waitfor, "villian")
  }
  params.villianGUID = getFromBag({
  searchBy = "name",
  searchTerm = villianName,
  params =  villianParams,
  guid = scenarioBagGUID
  }).guid

  putOutTokens() -- Remove this once a good villian and scenario board is created

  if includeStandard == "True" then
  getFromBag({
  searchBy = "name",
  searchTerm = "Standard",
  params = encounterDeckParams,
  guid = encountersBagGUID
  })
  end

  if expert == "True" then
  getFromBag({
  searchBy = "name",
  searchTerm = "Expert",
  params = encounterDeckParams,
  guid = encountersBagGUID
  })
  end

  if modularEnfcounters != nil then
  local modularEncounterName = modularEncounters
  getFromBag({
  searchBy = "name",
  searchTerm = modularEncounterName,
  params = encounterDeckParams,
  guid = modularEncountersBagGUID
  })
  end

  if params.basicExpert == "True" then
  Wait.condition(
  || basicExpert(params),
  || allFinished(waitfor),
  3,
  || error("Timeout spawning encounter: "..dump(params))
  )
  else
  Wait.condition(
  || scenarioBag.call("scenarioSpecificSetup", params),
  || allFinished(waitfor),
  3,
  || error("Timeout spawning encounter: "..dump(params))
  )
  end
end

function basicExpert(params)
  local scenarioBagGUID = params.scenarioBagGUID
  local scenarioBag = getObjectFromGUID(scenarioBagGUID)

  local villianGUID = params.villianGUID
  local villianName = params.villianName
  local expert = params.expert

  if expert == "True" then
    -- Remove Villian I
    local trashParams = { position = {-1000,0,-1000} }
    destroyObject(
            getFromDeck({
              searchBy = "name",
              searchTerm = villianName .. " I",
              params =  trashParams,
              guid = villianGUID
            })
    )

  else
    -- Remove Villian III
    local trashParams = { position = {-1000,0,-1000} }
    destroyObject(
            getFromDeck({
              searchBy = "name",
              searchTerm = villianName .. " III",
              params =  trashParams,
              guid = villianGUID
            })
    )
  end

  scenarioBag.call("scenarioSpecificSetup", params)
end

function externalSetup(scenarioBag)
  local params = scenarioBag.getTable("scenarioParameters")
  params.scenarioBagGUID = scenarioBag.guid

  if includeExpert == "True" then params.expert = "True" end
  if modularEncounter != nil then params.modularEncounters = modularEncounter end

  if params.basicSetup == "True" then
  params = basicSetup(params)
  else
  scenarioBag.call("scenarioSpecificSetup", params)
  end
end

function buildEncounterDeckClicked()
  local callback = externalSetup

  if scenario == "Random" then scenario = getRandomFromBag(scenariosBagGUID) end
  if modularEncounter == "Random" then modularEncounter = getRandomFromBag(modularEncountersBagGUID) end

  local scenarioBagParams = {
    position = {-10,0,15}
  , callback_function = callback
  }
  getFromBagOld(scenario, scenarioBagParams, scenariosBagGUID)
  UI.hide("encounterPanel")
end

-- HERO FUNCTIONS
function setupHero(heroBag)
  -- Positions
  local heroCardOffset = {7.9,1,-1.75}
  local heroCardParams = {
    position = positioning:LocalPos(heroBag, heroCardOffset),
    rotation = FLIPPED
  }

  local obligationOffset = {0,1,-9}
  local obligationParams = {
    position = positioning:LocalPos(heroBag, obligationOffset)
  }

  local nemesisOffset = {4.5,1,8.5}
  local nemesisParams = {
    position = positioning:LocalPos(heroBag, nemesisOffset),
    rotation = SIDEWAYS
  }

  local heroBagOffset = {-9,1,-8.5}
  --[[
  TODO: Put Hero name on card by moving to description based tagging
  ]]
  getFromBagOld("Hero", heroCardParams, heroBag.getGUID())
  getFromBagOld("Obligation", obligationParams, heroBag.getGUID())
  getFromBagOld("Nemesis", nemesisParams, heroBag.getGUID())
  heroBag.translate(heroBagOffset)
end

function buildHeroDeckClicked(player)
  -- Reset
  init()
  UI.hide("heroPanel")

  local activePlayerColors = {}

  for i = 1, playerCount, 1 do
    activePlayerColors[#activePlayerColors+1] = playerColors[i]
  end

  if not has_value(activePlayerColors, player.color) then
    broadcastToAll("Please take a seat at the table before building your deck "..player.steam_name)
    return false
  end

  print("Setting up playspace for "..player.steam_name)
  -- Get The Deck Information while setting up the playspace
  getDeckFromDB()
  -- Positions
  local playerPos = player.getHandTransform().position
  local playmatOffset = {0,-3.5,11.75}
  local playmatParams = { position = positioning.Vect_Sum(playerPos, playmatOffset)}

  tokenParams = |i| { position = positioning.Vect_Sum(playerPos, {-0.5 + i * 2.5, -3.6, 3.25}), rotation = {0,0,0}}

  local objs = {}
  -- Get Playspace Items
  local playmat = getFromBagOld(defaultPlaymatName, playmatParams, playmatBagGUID)
  table.insert(objs, playmat)
  table.insert(objs, getFromBagOld("Damage", tokenParams(0), tokenBagGUID))
  table.insert(objs, getFromBagOld("Generic", tokenParams(1), tokenBagGUID))
  table.insert(objs, getFromBagOld("Tough", tokenParams(2), tokenBagGUID))
  table.insert(objs, getFromBagOld("Stunned", tokenParams(3), tokenBagGUID))
  table.insert(objs, getFromBagOld("Confused", tokenParams(4), tokenBagGUID))

  for k,v in pairs(objs) do v.setLock(true) end

  -- Wait for playmat to spawn before spawning things on top of it
  local playmatTimeout = 60
  Wait.condition(
  || spawnHealthTracker(player),
  || not playmat.spawning,
  timeout,
  || onTimeout("spawning playmat", playmatTimeout)
  )

  local marvelcdbTimeout = 300
  Wait.condition(
  || createDeck(playmat),
  || doneSlots == numSlots and not playmat.spawning,
  timeout,
  || onTimeout("Getting deck from MarvelCDB", marvelcdbTimeout)
  )
end

-- UNCATEGORIZED FUNCTIONS
function searchForCard(cardName, subName, cardCount, cardpool, destPos)
  allCards = cardpool.getObjects()
  for k,v in pairs(allCards) do
    if (v.name == cardName)
    then
      if(subName == nil or v.description == subName)
      then
        cardpool.takeObject({
          position = {10, 0, 20},
          callback = 'cardTaken',
          callback_owner=self,
          index = v.index,
          smooth = false,
          params = { cardName=cardName, cardCount=cardCount, destPos=destPos }
        })
        print('Added '.. cardCount .. ' of ' .. cardName)
        return
      end
    end
  end
  broadcastToAll("Card not found: "..cardName, {0.5,0.5,0.5})
end

function cardTaken(card, params)
  if (card.getName() == params.cardName) then
    card.setPosition(params.destPos)
    card.setRotation(FLIPPED)

    -- Duplicate for each copy beyond the first
    for i=1,params.cardCount-1,1 do
      local cloneParams = { position=params.destPos, rotation=FLIPPED}
      card.clone(cloneParams)
    end
  else
    print('Wrong card: ' .. card.getName())
    tmpDeck.putObject(card)
  end
end


function createDeck(playmat)
  -- Positions
  local cloneParams = { position = {0,0,50} }

  local heroBagOffset = {0,0,0}
  local heroBagParams = {
    position = positioning:LocalPos(playmat, heroBagOffset),
    callback_function = setupHero
  }

  local heroDeckOffset = {-6.55,1,-5.3}
  local heroDeckPos = positioning:LocalPos(playmat, heroDeckOffset)

  -- Unpack Hero Bag
  getFromBagOld(JsonDeckRes.investigator_name, heroBagParams, herosBagGUID)

  -- Setup deck
  local cardpool = getFromBagOld("CardPool", cloneParams, herosBagGUID)

  for k,v in pairs(cardList) do
    searchForCard(v.cardName, v.subName, v.cardCount, cardpool, heroDeckPos)
  end

  cardpool.destruct()
end

function spawnHealthTracker(player)
  -- Positions
  local playerPos = player.getHandTransform().position
  local healthOffset = {-7.92, -3.6, 16.95}
  local healthParams = { position = positioning.Vect_Sum(playerPos, healthOffset), rotation = {0,0,0}}

  local healthTracker = getFromBagOld("Health Tracker", healthParams, tokenBagGUID)
  -- healthTracker.setLock(true)
  healthTracker.setColorTint(player.color)
end

-- Player And Table Setup
-- Taken directly from FlexTableControl
function changeTableScale(width, depth)
  local tableHeightOffset = -9

  -- GUIDS for table parts
  local obj_leg1 = getObjectFromGUID("afc863")
  local obj_leg2 = getObjectFromGUID("c8edca")
  local obj_leg3 = getObjectFromGUID("393bf7")
  local obj_leg4 = getObjectFromGUID("12c65e")
  local obj_surface = getObjectFromGUID("4ee1f2")
  local obj_side_top = getObjectFromGUID("35b95f")
  local obj_side_bot = getObjectFromGUID("f938a2")
  local obj_side_lef = getObjectFromGUID("9f95fd")
  local obj_side_rig = getObjectFromGUID("5af8f2")

  --Scaling factors used to translate scale to position offset
  local width2pos = (width-1) * 18
  local depth2pos = (depth-1) * 18

  --Resizing table elements
  obj_side_top.setScale({width, 1, 1})
  obj_side_bot.setScale({width, 1, 1})
  obj_side_lef.setScale({depth, 1, 1})
  obj_side_rig.setScale({depth, 1, 1})
  obj_surface.setScale({width, 1, depth})

  --Moving table elements to accomodate new scale
  obj_side_lef.setPosition({-width2pos,tableHeightOffset,0})
  obj_side_rig.setPosition({ width2pos,tableHeightOffset,0})
  obj_side_top.setPosition({0,tableHeightOffset, depth2pos})
  obj_side_bot.setPosition({0,tableHeightOffset,-depth2pos})
  obj_leg1.setPosition({-width2pos,tableHeightOffset,-depth2pos})
  obj_leg2.setPosition({-width2pos,tableHeightOffset, depth2pos})
  obj_leg3.setPosition({ width2pos,tableHeightOffset, depth2pos})
  obj_leg4.setPosition({ width2pos,tableHeightOffset,-depth2pos})
end

function setHandPosition(color, position)
  local xVal = position

  Player[color].setHandTransform({
    position = { ["x"] = xVal, ["y"] = 5, ["z"] = -20 },
    scale = { x=9, y=5.4, z=3.1}
  })
end

function hideHand(color, position)
  -- Clean up the magic numbershere.
  -- Maybe use the table or a dynamic reference
  local xVal = 20 + (position-1) * 6

  Player[color].setHandTransform({
    position = { ["x"] = xVal, ["y"] = 5, ["z"] = 20 },
    scale = { x=1, y=1, z=1}
  })
end

function setPlayerPositions(playerCount)
  local evenPlayerPositions = {11, -11, 33, -33}
  local oddPlayerPositions = { 0, 22, -22 }
  local playerPositions = {}

  if (playerCount % 2 == 0) then
    playerPositions = evenPlayerPositions
  else
    playerPositions = oddPlayerPositions
  end

  for i, color in pairs(playerColors) do
    if i > tonumber(playerCount) then
      hideHand(color, i)
    else
      setHandPosition(color, playerPositions[i])
    end
  end
end

function setPlayers()
  UI.hide("playerPanel")
  print("Resetting the table for "..playerCount.." players.")
  local tableWidth = 0.5 + playerCount * 0.5
  changeTableScale(tableWidth,1)
  setPlayerPositions(playerCount)
end

--[[ UI Functions ]]--

-- UI Component Functions
uif = {
  cell = function(contents, colSpan)
    colSpan = colSpan or 1

    return {
      tag="Cell"
    , attributes={
        columnSpan=colSpan
      }
    , children=contents
    }
  end,

  row = function(cells)
    return {
      tag="Row",
      attributes={},
      children=cells
    }
  end,

  option = function(value)
    return {
      tag="Option"
    , value=value
    }
  end,

  toggle = function(value, onValueChanged, isOn, textColor)
    isOn = isOn or false
    textColor = textColor or "orange"

    return {
      tag = "Toggle"
    , value = value
    , attributes = {
        onValueChanged = scriptContainerGUID .. "/" .. onValueChanged
      , textColor = textColor
      , fontSize = 16
      , isOn = isOn
      }
    }
  end
}

-- UI Helper Functions
function toggleHidden(uiElement)
  local active = UI.getAttribute(uiElement, "active")

  log(UI.getAttribute(uiElement, "id") .. " changed to " .. active)

  -- Despite using boolean values, the attribute is a string so I have to use string matching.
  if active == "true" then
    UI.hide(uiElement)
  else
    UI.show(uiElement)
  end
end

function generateOptionsFromBagContents(bagGUID, setter, includeRandom)
  log("Getting options from bag " .. getBagName(bagGUID))
  local first = true
  local options = {}
  local bagContents = getBagContents(bagGUID)

  if (bagContents != nil) then
  if includeRandom then
  table.insert(options, uif.option("Random"))
  setter("", "Random")
  first = false
  end
  for k,v in pairs(bagContents) do
  table.insert(options, uif.option(v.name))
  if first then
  setter("", v.name)
  first = false
  end
  end
  else
  print("Error: Bag " .. getBagName(bagGUID) .. "should not be empty")
  end
  return options
end

-- Main UI Helpers
function heroButtonClicked()
  log("Hero button clicked")
  UI.hide("encounterPanel")
  UI.hide("playerPanel")
  toggleHidden("heroPanel")
end

function encounterButtonClicked()
  log("Scenario button clicked")
  UI.hide("heroPanel")
  UI.hide("playerPanel")
  toggleHidden("encounterPanel")
end

function playerButtonClicked()
  log("Scenario button clicked")
  UI.hide("heroPanel")
  UI.hide("encounterPanel")
  toggleHidden("playerPanel")
end

function toggleUI()
  toggleHidden("marvelUILayout")
end

-- Scripting Button Helpers
function onScriptingButtonDown(index, color)
  local action = {
    [1]  = heroButtonClicked,
    [2]  = encounterButtonClicked,
    [3]  = toggleUI,
    [4]  = playerButtonClicked,
    [5]  = function () end,
    [6]  = function () end,
    [7]  = function () end,
    [8]  = function () end,
    [9]  = function () end,
    [10] = function () end,
  }

  action[index]()
end

uiBuilder = {
  -- Make the Main UI
  makeUI = function()
    log("Building UI")
    local marvelUI = {}

    table.insert(marvelUI, sidebar:make())
    table.insert(marvelUI, heroPanel:make())
    table.insert(marvelUI, encounterPanel:make())
    table.insert(marvelUI, playerPanel:make())

    UI.setXmlTable(marvelUI)
  end,

  uiToggleButton = function()
    tile = getObjectFromGUID(scriptContainerGUID)
    self.createButton({
      click_function="toggleUI", function_owner=self,
      position={0,0,0}, rotation={0,0,0}, height=950, width=700,
      tooltip="Click to show/hide Marvel UI"
    })
  end
}

sidebar = {
  make = function(self)
    local sidebarLayout = {
      tag="VerticalLayout",
      attributes={
        id="marvelUILayout"
      , rectAlignment="MiddleRight"
      , height=100
      , width=100
      , color="rgba(0,0,0,0.7)"
      , active= flags.ui.main or false
      },
      children={}
    }

    local playerButton = {
      tag="Button",
      attributes={
        onClick=scriptContainerGUID .. "/playerButtonClicked",
        fontSize=12,
      },
      value="Players",
    }

    local heroButton = {
      tag="Button",
      attributes={
        onClick=scriptContainerGUID .. "/heroButtonClicked",
        fontSize=12,
      },
      value="Hero Builder",
    }

    local encounterButton = {
      tag="Button",
      attributes={
        onClick=scriptContainerGUID .. "/encounterButtonClicked",
        fontSize=12,
      },
      value="Encounter Builder",
    }

    local closeButton = {
      tag="Button",
      attributes={
        onClick=scriptContainerGUID .. "/toggleUI"
      , tooltip="You can also toggle the UI by clicking the \nMarvel Champions Helper Tile on the table."
      , fontSize=12
      },
      value="Close Marvel UI",
    }

    table.insert(sidebarLayout.children, playerButton)
    table.insert(sidebarLayout.children, heroButton)
    table.insert(sidebarLayout.children, encounterButton)
    table.insert(sidebarLayout.children, closeButton)

    return sidebarLayout
  end
}

-- Player Panel Helper
function setPlayerCount(player, option, id)
  playerCount = option
end

-- Player Panel Assets
playerPanel = {
  headerRow = function()
    local header = {
      tag="Text",
      value="Players",
      attributes={
        resizeTextForBestFit=true
      , color="white"
      }
    }

    return uif.row({
      uif.cell(header,2)
    })
  end,

  countRow = function()
    local label = {
      tag="Text",
      value="Player Count",
      attributes={
        resizeTextForBestFit=true
      , color="white"
      }
    }

    local dropdown = {
      tag="Dropdown"
    , attributes={
        onValueChanged=scriptContainerGUID .. "/setPlayerCount"
      }
    , children={uif.option(1),uif.option(2),uif.option(3),uif.option(4)}
    }

    return uif.row({
      uif.cell(label)
    , uif.cell(dropdown)
    })
  end,

  buttonRow = function()
    local button = {
      tag="Button",
      attributes={
        onClick=scriptContainerGUID .. "/setPlayers",
        fontSize=12,
      },
      value="Set Players",
    }

    return uif.row({
      uif.cell(button, 2)
    })
  end,

  make = function(self)
    log("Building Player Panel")

    local panel = {
      tag="Panel",
      attributes={
        id="playerPanel"
      , width = "30%"
      , height = "40%"
      , active = flags.ui.player or false
      },
      children={}
    }

    local panelLayout = {
      tag="TableLayout",
      attributes={
        color="rgba(0,0,0,0.7)",
      },
      children={}
    }

    table.insert(panelLayout.children, self.headerRow())
    table.insert(panelLayout.children, self.countRow())
    table.insert(panelLayout.children, self.buttonRow())
    table.insert(panel.children, panelLayout)

    return panel
  end
}

-- Hero Panel Helpers
function publicPrivateClicked(player, option, id)
  privateDeck = not privateDeck
  if privateDeck == true then
    UI.setAttribute(id, "text", "Private Deck")
  else
    UI.setAttribute(id, "text", "Public Deck")
  end

  log("privateDeck changed to: " .. tostring(privateDeck))
end

function deckIdInputTyped(player, input_value, id)
  deckID = input_value
end

function setPlaymat(player, option, id)
  playmat = option
end

heroPanel = {
  headerRow = function()
    local header = {
      tag="Text",
      value="Hero Builder",
      attributes={
        resizeTextForBestFit=true
      , color="blue"
      }
    }

    return uif.row({
      uif.cell(header,2)
    })
  end,

  marvelDBRow = function()
    -- Textbox for deckID
    local deckIdInput = {
      tag = "InputField"
    , attributes = {
        id = "deckIdInput"
      , placeholder = "Deck ID"
      , tooltip = [[
          *****PLEASE USE A PRIVATE DECK IF JUST FOR TTS TO AVOID FLOODING MARVELDB PUBLIC DECK LISTS!*****
          Input deck ID from MarvelDB URL of the published version of the deck
          Example: For the URL 'https://marvelcdb.com/decklist/view/449/wakanda-forever-and-ever-and-ever-and-ever-an-1.0', you should input '449'
          ]]
      , onValueChanged = scriptContainerGUID .. "/" .. "deckIdInputTyped"
      }
    }

    -- Toggle for public/private
    local publicPrivateToggle = {
      tag = "Button"
    , attributes = {
        id = "publicPrivateButton"
      , text = "Private Deck"
      , tooltip = "Click to toggle Private/Public deck ID"
      , onClick = scriptContainerGUID .. "/" .. "publicPrivateClicked"
      , textColor = textColor
      , fontSize = 16
      , isOn = "True"
      }
    }

    return uif.row({
      uif.cell(deckIdInput),
      uif.cell(publicPrivateToggle)
    })
  end,

  buttonRow = function()
    local button = {
      tag="Button",
      attributes={
        onClick=scriptContainerGUID .. "/buildHeroDeckClicked",
        fontSize=12,
      },
      value="Build Hero Deck",
    }

    return uif.row({
      uif.cell(button, 2)
    })
  end,

  make = function(self)
    log("Building Hero Panel")

    local panel = {
      tag="Panel",
      attributes={
        id="heroPanel"
      , width = "30%"
      , height = "40%"
      , active = flags.ui.hero or false
      },
      children={}
    }

    local panelLayout = {
      tag="TableLayout",
      attributes={
        color="rgba(0,0,0,0.7)",
      },
      children={}
    }

    table.insert(panelLayout.children, self.headerRow())
    table.insert(panelLayout.children, self.marvelDBRow())
    table.insert(panelLayout.children, self.buttonRow())
    table.insert(panel.children, panelLayout)

    return panel
  end
}

-- Encounter Panel Helpers
function setScenario(player, option, id)
  scenario = option
end

function setModularEncounter(player, option, id)
  modularEncounter = option
end

function setStandard(player, option, id)
  log("Standard changed to: " .. option)
  includeStandard = option
end

function setExpert(player, option, id)
  log("Expert changed to: " .. option)
  includeExpert = option
end

-- Encounter Panel Assets
encounterPanel = {
  headerRow = function()
    local header = {
      tag="Text",
      value="Encounter Builder",
      attributes={
        resizeTextForBestFit=true
      , color="orange"
      }
    }

    return uif.row({
      uif.cell(header,2)
    })
  end,

  scenarioRow = function()
    local label = {
      tag="Text",
      value="Scenario",
      attributes={
        resizeTextForBestFit=true
      , color="orange"
      }
    }

    local dropdown = {
      tag="Dropdown"
    , attributes={
        onValueChanged=scriptContainerGUID .. "/setScenario"
      }
    , children=generateOptionsFromBagContents(scenariosBagGUID, setScenario, true)
    }

    return uif.row({
      uif.cell(label)
    , uif.cell(dropdown)
    })
  end,

  modularEncounterRow = function()
    local label = {
      tag="Text",
      value="Modular Encounter",
      attributes={
        resizeTextForBestFit=true
      , color="orange"
      }
    }

    local dropdown = {
      tag="Dropdown"
    , attributes={
        onValueChanged=scriptContainerGUID .. "/setModularEncounter"
      }
    , children=generateOptionsFromBagContents(modularEncountersBagGUID, setModularEncounter, true)
    }

    return uif.row({
      uif.cell(label)
    , uif.cell(dropdown)
    })
  end,

  optionsRow = function()
    return uif.row({
      uif.cell(uif.toggle("Include Expert Encounter Set", "setExpert", includeExpert), 2)
    })
  end,

  buttonRow = function()
    local button = {
      tag="Button",
      attributes={
        onClick=scriptContainerGUID .. "/buildEncounterDeckClicked",
        fontSize=12,
      },
      value="Build Encounter Deck",
    }

    return uif.row({
      uif.cell(button, 2)
    })
  end,

  make = function(self)
    log("Building Encounter Panel")

    local panel = {
      tag="Panel",
      attributes={
        id="encounterPanel"
      , width = "30%"
      , height = "40%"
      , active =  flags.ui.encounter or false
      },
      children={}
    }

    local panelLayout = {
      tag="TableLayout",
      attributes={
        color="rgba(0,0,0,0.7)",
      },
      children={}
    }

    table.insert(panelLayout.children, self.headerRow())
    table.insert(panelLayout.children, self.scenarioRow())
    table.insert(panelLayout.children, self.modularEncounterRow())
    table.insert(panelLayout.children, self.optionsRow())
    table.insert(panelLayout.children, self.buttonRow())
    table.insert(panel.children, panelLayout)

    return panel
  end
}

--[[ Helper Functions ]]--
-- Check to see if value is in table
function has_value(table, val)
  for index, value in ipairs(table) do
    if value == val then return true end
  end

  return false
end

-- Dump table to string for debugging with no external library
-- From https://stackoverflow.com/questions/9168058/how-to-dump-a-table-to-console
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

-- Function to convert utf-16 hex to actual character since JSON.decode doesn't seem to handle utf-16 hex very well..
function convertHexToDec(a)
  return string.char(tonumber(a,16))
end

--[[ The onUpdate event is called once per frame. --]]
function onUpdate ()
  --[[ print('onUpdate loop!') --]]
end

-- From Dzikakulka's positioning script
positioning = {
  -- Return position "position" in "object"'s frame of reference
  -- (most likely the only function you want to directly access)
  LocalPos = function(self, object, position)
    local rot = object.getRotation()
    local lPos = {position[1], position[2], position[3]}

    -- Z-X-Y extrinsic
    local zRot = self.RotMatrix('z', rot['z'])
    lPos = self.RotateVector(zRot, lPos)
    local xRot = self.RotMatrix('x', rot['x'])
    lPos = self.RotateVector(xRot, lPos)
    local yRot = self.RotMatrix('y', rot['y'])
    lPos = self.RotateVector(yRot, lPos)

    return positioning.Vect_Sum(lPos, object.getPosition())
  end,

  -- Build rotation matrix
  -- 1st table = 1st row, 2nd table = 2nd row etc
  RotMatrix = function(axis, angDeg)
    local ang = math.rad(angDeg)
    local cs = math.cos
    local sn = math.sin

    if axis == 'x' then
      return {
        { 1,        0,             0 },
        { 0,   cs(ang),   -1*sn(ang) },
        { 0,   sn(ang),      cs(ang) }
      }
    elseif axis == 'y' then
      return {
        {    cs(ang),   0,   sn(ang) },
        {          0,   1,         0 },
        { -1*sn(ang),   0,   cs(ang) }
      }
    elseif axis == 'z' then
      return {
        { cs(ang),   -1*sn(ang),   0 },
        { sn(ang),      cs(ang),   0 },
        { 0,                  0,   1 }
      }
    end
  end,

  -- Apply given rotation matrix on given vector
  -- (multiply matrix and column vector)
  RotateVector = function(rotMat, vect)
    local out = {0, 0, 0}
    for i=1,3,1 do
      for j=1,3,1 do
        out[i] = out[i] + rotMat[i][j]*vect[j]
      end
    end
    return out
  end,

  -- Sum of two vectors (of any size)
  Vect_Sum = function(vec1, vec2)
    local out = {}
    local k = 1
    while vec1[k] ~= nil and vec2[k] ~= nil do
      out[k] = vec1[k] + vec2[k]
      k = k+1
    end
    return out
  end
}

