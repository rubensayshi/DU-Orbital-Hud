-- function localizations
local mfloor = math.floor
local stringf = string.format
local jdecode = json.decode
local jencode = json.encode
local eleMaxHp = core.getElementMaxHitPointsById
local atmosphere = unit.getAtmosphereDensity
local eleHp = core.getElementHitPointsById
local eleType = core.getElementTypeById
local constructMass = core.getConstructMass

do -- !DU: start()
    -- category panel display helpers
    _autoconf = {}
    _autoconf.panels = {}
    _autoconf.panels_size = 0
    _autoconf.displayCategoryPanel = function(elements, size, title, type, widgetPerData)
        widgetPerData = widgetPerData or false -- default to one widget for all data
        if size > 0 then
            local panel = system.createWidgetPanel(title)
            local widget
            if not widgetPerData then
                widget = system.createWidget(panel, type)
            end
            for i = 1, size do
                if widgetPerData then
                    widget = system.createWidget(panel, type)
                end
                system.addDataToWidget(elements[i].getDataId(), widget)
            end
            _autoconf.panels_size = _autoconf.panels_size + 1
            _autoconf.panels[_autoconf.panels_size] = panel
        end
    end
    _autoconf.hideCategoryPanels = function()
        for i=1,_autoconf.panels_size do
            system.destroyWidgetPanel(_autoconf.panels[i])
        end
    end
    -- Proxy array to access auto-plugged slots programmatically

    radar = {}
    radar[1] = radar_1
    radar_size = 1

    weapon = {}
    weapon_size = 0

    door = {}
    door_size = 0

    forcefield = {}
    forcefield_size = 0

    atmofueltank = {}
    atmofueltank[1] = atmofueltank_1
    atmofueltank_size = 1

    spacefueltank = {}
    spacefueltank[1] = spacefueltank_1
    spacefueltank_size = 1

    rocketfueltank = {}
    rocketfueltank_size = 0
    -- End of auto-generated code
    Nav = Navigator.new(system, core, unit)
    Nav.axisCommandManager:setupCustomTargetSpeedRanges(axisCommandId.longitudinal, {1000, 5000, 10000, 20000, 30000})

    -- GLOBAL VARIABLES SECTION, IF NOT USED OUTSIDE UNIT.START, MAKE IT LOCAL
    LastMaxBrake = 0
    mousePitchFactor = 1 -- Mouse control only
    mouseYawFactor = 1 -- Mouse control only
    hasGear = false
    pitchInput = 07
    rollInput = 0
    yawInput = 0
    brakeInput = 0
    pitchInput2 = 0
    rollInput2 = 0
    yawInput2 = 0
    BrakeIsOn = false
    RetrogradeIsOn = false             
    ProgradeIsOn = false             
    AutoBrake = false
    Autopilot = false
    FollowMode = false
    TurnBurn = false
    AltitudeHold = false
    AutoLanding = false
    AutoTakeoff = false
    HoldAltitude = 1000 -- In case something goes wrong, give this a decent start value
    AutopilotAccelerating = false
    AutopilotBraking = false
    AutopilotCruising = false 
    AutopilotRealigned = false
    AutopilotEndSpeed = 0
    AutopilotStatus = "Aligning"
    simulatedX = 0
    simulatedY = 0
    HoldingCtrl = false
    PrevViewLock = 1
    PreviousYawAmount = 0
    PreviousPitchAmount = 0
    msgText = "empty"
    msgTimer = 3
    targetGroundAltitude = nil -- So it can tell if one loaded or not
    gearExtended = nil
    LastEccentricity = 1
    HoldAltitudeButtonModifier = 5
    isBoosting = false -- Dodgin's Don't Die Rocket Govenor - Cruise Control Edition
    distance = 0
    brakeDistance, brakeTime = 0
    maxBrakeDistance, maxBrakeTime = 0
    hasGear = false
    hasDB = false
    hasSpaceRadar = false
    hasAtmoRadar = false
    damageMessage = [[]]
    radarMessage = [[]]
    LastOdometerOutput = ""
    peris = 0
    BrakeButtonHovered = false         
    RetrogradeButtonHovered = false    
    ProgradeButtonHovered = false
    AutopilotButtonHovered = false
    TurnBurnButtonHovered = false
    FollowModeButtonHovered = false
    AltitudeHoldButtonHovered = false
    LandingButtonHovered = false
    TakeoffButtonHovered = false
    AutopilotTargetIndex = 0
    AutopilotTargetName = "None"
    AutopilotTargetPlanet = nil
    AutopilotPlanetGravity = 0
    UnitHidden = true
    ResetAutoVars = false
    totalDistanceTravelled = 0.0
    totalDistanceTrip = 0
    lastTravelTime = system.getTime()
    totalMass = 0
    core_altitude = core.getAltitude()
    elementsID = core.getElementIdList() 
    -- Do not save these, they contain elementID's which can change.
    atmoTanks = {}
    spaceTanks = {}
    rocketTanks = {}
    eleTotalMaxHp = 0
    flightTime = 0
    totalFlightTime = 0

    -- updateHud() variables
    rgb = [[rgb(]] .. mfloor(PrimaryR+0.5) .. "," .. mfloor(PrimaryG+0.5) .. "," .. mfloor(PrimaryB+0.5) .. [[)]]
    rgbdim = [[rgb(]] .. mfloor(PrimaryR *0.9 + 0.5) .. "," .. mfloor(PrimaryG * 0.9 + 0.5) .. "," .. mfloor(PrimaryB * 0.9 + 0.5) .. [[)]]
    rgbdimmer = [[rgb(]] .. mfloor(PrimaryR *0.8 + 0.5) .. "," .. mfloor(PrimaryG * 0.8 + 0.5) .. "," .. mfloor(PrimaryB * 0.8 + 0.5) .. [[)]]
    UpdateCount = 0
    titlecolR = rgb
    titlecol = rgb
    titlecolS = rgb
    fuelTimeLeftR = {}
    fuelPercentR = {}
    FuelUpdateDelay = mfloor(1/apTickRate)*2
    fuelTimeLeftS = {}
    fuelPercentS = {}
    fuelTimeLeft = {}
    fuelPercent = {}
    updateTanks = false
    honeyCombMass = 0
    upAmount = 0

    -- LOCAL VARIABLES, USERS DO NOT CHANGE
    local AutopilotStrength = 1 -- How strongly autopilot tries to point at a target
    local alignmentTolerance = 0.001 -- How closely it must align to a planet before accelerating to it
    local ResolutionWidth = 2560
    local ResolutionHeight = 1440
    local ButtonBrakeWidth = 260             -- Size and positioning for brake button
    local ButtonBrakeHeight = 50             -- Size and positioning for brake button
    local ButtonBrakeX = ResolutionWidth/2 - ButtonBrakeWidth/2         -- Size and positioning for brake button
    local ButtonBrakeY = ResolutionHeight/2 - ButtonBrakeHeight + 400   -- Size and positioning for brake button
    local ButtonProgradeWidth = 260          -- Size and positioning for prograde button
    local ButtonProgradeHeight = 50          -- Size and positioning for prograde button       
    local ButtonProgradeX = ResolutionWidth/2 - ButtonProgradeWidth/2 - ButtonBrakeWidth - 50   -- Size and positioning for prograde button
    local ButtonProgradeY = ResolutionHeight/2 - ButtonProgradeHeight + 380                     -- Size and positioning for prograde button
    local ButtonRetrogradeWidth = 260        -- Size and positioning for retrograde button
    local ButtonRetrogradeHeight = 50        -- Size and positioning for retrograde button       
    local ButtonRetrogradeX = ResolutionWidth/2 - ButtonRetrogradeWidth/2 + ButtonBrakeWidth + 50   -- Size and positioning for retrograde button
    local ButtonRetrogradeY = ResolutionHeight/2 - ButtonRetrogradeHeight + 380                     -- Size and positioning for retrograde button
    local ButtonAutopilotWidth = 600 -- Size and positioning for autopilot button
    local ButtonAutopilotHeight = 60 -- Size and positioning for autopilot button
    local ButtonAutopilotX = ResolutionWidth/2 - ButtonAutopilotWidth/2
    local ButtonAutopilotY = ResolutionHeight/2 - ButtonAutopilotHeight/2 - 400
    local ButtonTurnBurnWidth = 300 -- Size and positioning for TurnBurn button
    local ButtonTurnBurnHeight = 60 -- Size and positioning for TurnBurn button
    local ButtonTurnBurnX = 10
    local ButtonTurnBurnY = ResolutionHeight/2  - 300
    local ButtonAltitudeHoldWidth = 300 -- Size and positioning for AltitudeHold button
    local ButtonAltitudeHoldHeight = 60 -- Size and positioning for AltitudeHold button
    local ButtonAltitudeHoldX = ButtonTurnBurnX + ButtonTurnBurnWidth + 20
    local ButtonAltitudeHoldY = ButtonTurnBurnY
    local ButtonLandingWidth = 300 -- Size and positioning for Landing button
    local ButtonLandingHeight = 60 -- Size and positioning for Landing button
    local ButtonLandingX = ButtonTurnBurnX
    local ButtonLandingY = ButtonTurnBurnY + ButtonTurnBurnHeight + 20
    local ButtonTakeoffWidth = 300 -- Size and positioning for Takeoff button
    local ButtonTakeoffHeight = 60 -- Size and positioning for Takeoff button
    local ButtonTakeoffX = ButtonTurnBurnX + ButtonTurnBurnWidth + 20
    local ButtonTakeoffY = ButtonLandingY
    local ButtonFollowModeWidth = 300 -- Size and positioning for FollowMode button
    local ButtonFollowModeHeight = 60 -- Size and positioning for FollowMode button
    local ButtonFollowModeX = ButtonTurnBurnX
    local ButtonFollowModeY = ButtonTakeoffY + ButtonTakeoffHeight + 20
    local minAtlasX = nil
    local maxAtlasX = nil
    local minAtlasY = nil
    local maxAtlasY = nil
    local valuesAreSet = false
    local doubleCheck = false

    -- VARIABLES TO BE SAVED GO HERE
    SaveableVariables = 
    {
        "userControlScheme", 
        "AutopilotTargetOrbit",
        "apTickRate",
        "brakeToggle",
        "freeLookToggle",
        "turnAssist",
        "PrimaryR",
        "PrimaryG",
        "PrimaryB",
        "warmup",
        "DeadZone",
        "circleRad",
        "MouseXSensitivity",
        "MouseYSensitivity",
        "MaxGameVelocity",
        "showHud",
        "autoRoll",
        "pitchSpeedFactor",
        "yawSpeedFactor",
        "rollSpeedFactor",
        "brakeSpeedFactor",
        "brakeFlatFactor",
        "autoRollFactor",
        "turnAssistFactor",
        "torqueFactor",
        "AutoTakeoffAltitude",
        "TargetHoverHeight",
        "AutopilotInterplanetaryThrottle",
        "hideHudOnToggleWidgets",
        "DampingMultiplier",
        "fuelTankOptimization",
        "RemoteFreeze",
        "speedChangeLarge",
        "speedChangeSmall",
        "brightHud"
    }
    AutoVariables = 
    {
        "OldAutoRoll",
        "hasGear",
        "BrakeIsOn",
        "RetrogradeIsOn",             
        "ProgradeIsOn",             
        "AutoBrake",
        "Autopilot",
        "FollowMode",
        "TurnBurn",
        "AltitudeHold",
        "AutoLanding",
        "AutoTakeoff",
        "HoldAltitude",
        "AutopilotAccelerating",
        "AutopilotBraking",
        "AutopilotCruising", 
        "AutopilotRealigned",
        "AutopilotEndSpeed",
        "AutopilotStatus",
        "AutopilotPlanetGravity",
        "PrevViewLock",
        "AutopilotTargetName",
        "AutopilotTargetPlanet",
        "AutopilotTargetCoords",
        "AutopilotTargetIndex",
        "gearExtended",
        "targetGroundAltitude",
        "totalDistanceTravelled",
        "honeyCombMass",
        "totalFlightTime"
    }

    -- BEGIN CONDITIONAL CHECKS DURING STARTUP
    -- Load Saved Variables
    if dbHud then
        local hasKey = dbHud.hasKey
        for k,v in pairs(SaveableVariables) do
            if hasKey(v) then
                local result = jdecode(dbHud.getStringValue(v))
                if result ~= nil then
                system.print(v.." "..dbHud.getStringValue(v))
                _G[v] = result
                    valuesAreSet = true
                end
            end
        end
        for k,v in pairs(AutoVariables) do
            if hasKey(v) then
                local result = jdecode(dbHud.getStringValue(v))
                if result ~= nil then
                system.print(v.." "..dbHud.getStringValue(v))
                _G[v] = result
                end
            end
        end
        if valuesAreSet then
            msgText = "Loaded Saved Variables (see Lua Chat Tab for list)"
        else
            msgText = "No Saved Variables Found - Use Alt-7 to save your LUA parameters"
        end
    else
        msgText = "No databank found"
    end
    if(honeyCombMass == 0) then honeyCombMass = constructMass() - updateMass() end
    for k in pairs(elementsID) do
        local name = eleType(elementsID[k])
        if (name == "landing gear") then 
            hasGear = true
        end
        eleTotalMaxHp = eleTotalMaxHp + eleMaxHp(elementsID[k])
        if (name == "atmospheric fuel-tank" or name == "space fuel-tank" or name == "rocket fuel-tank" ) then
            local hp = eleMaxHp(elementsID[k])
            local mass = core.getElementMassById(elementsID[k])
            local curMass = 0
            local curTime = system.getTime()
            if (name == "atmospheric fuel-tank") then 
                local vanillaMaxVolume = 400
                local massEmpty = 35.03
                if hp > 10000 then 
                    vanillaMaxVolume = 51200 -- volume in kg of L tank
                    massEmpty = 5480
                elseif hp > 1300 then
                    vanillaMaxVolume =  6400 -- volume in kg of M
                    massEmpty = 988.67
                elseif hp > 150 then
                    vanillaMaxVolume = 1600 --- volume in kg small
                    massEmpty = 182.67
                end
                curMass = mass - massEmpty
                if curMass > vanillaMaxVolume then 
                    vanillaMaxVolume = curMass
                end
                if fuelTankOptimization > 0 then 
                    vanillaMaxVolume = vanillaMaxVolume + (vanillaMaxVolume*fuelTankOptimization)
                end
                atmoTanks[#atmoTanks + 1] = {elementsID[k], core.getElementNameById(elementsID[k]), vanillaMaxVolume, massEmpty, curMass, curTime}
            end
            if (name == "rocket fuel-tank") then 
                local vanillaMaxVolume = 320
                local massEmpty = 173.42
                if hp > 65000 then 
                    vanillaMaxVolume = 40000 -- volume in kg of L tank
                    massEmpty = 25740
                elseif hp > 6000 then
                    vanillaMaxVolume =  5120 -- volume in kg of M
                    massEmpty = 4720
                elseif hp > 700 then
                    vanillaMaxVolume = 640 --- volume in kg small
                    massEmpty = 886.72
                end
                curMass = mass - massEmpty
                if curMass > vanillaMaxVolume then 
                    vanillaMaxVolume = curMass
                end
                if fuelTankOptimization > 0 then 
                    vanillaMaxVolume = vanillaMaxVolume + (vanillaMaxVolume*fuelTankOptimization)
                end
               rocketTanks[#rocketTanks + 1] = {elementsID[k], core.getElementNameById(elementsID[k]), vanillaMaxVolume, massEmpty, curMass, curTime}
            end
            if (name == "space fuel-tank") then 
                local vanillaMaxVolume = 2400
                local massEmpty = 187.67
                if hp > 10000 then 
                    vanillaMaxVolume = 76800 -- volume in kg of L tank
                    massEmpty = 5480
                elseif hp > 1300 then
                    vanillaMaxVolume =  9600 -- volume in kg of M
                    massEmpty = 988.67
                end
                curMass = mass - massEmpty
                if curMass > vanillaMaxVolume then 
                    vanillaMaxVolume = curMass
                end
                if fuelTankOptimization > 0 then 
                    vanillaMaxVolume = vanillaMaxVolume + (vanillaMaxVolume*fuelTankOptimization)
                end
                spaceTanks[#spaceTanks + 1] = {elementsID[k], core.getElementNameById(elementsID[k]), vanillaMaxVolume, massEmpty, curMass, curTime}
            end
        end
    end

    if gyro ~= nil then
        GyroIsOn = gyro.getState() == 1
    end

    if userControlScheme ~= "Keyboard" then
        system.lockView(1)
    else
        system.lockView(0)
    end
    if atmosphere() > 0 then
        BrakeIsOn = true
    end  
    if radar_1 then
        if eleType(radar_1.getId()) == "Space Radar" then
            hasSpaceRadar = true
        else
            hasAtmoRadar = true
        end
    end
    -- Close door and retract ramp if available
    if door then
        for _,v in pairs(door) do
            v.deactivate()
        end
    end
    if forcefield then
        for _,v in pairs(forcefield) do
            v.deactivate()
        end
    end
    _autoconf.displayCategoryPanel(weapon, weapon_size, "Weapons", "weapon", true)
    if antigrav ~= nil then antigrav.show() end
    if warpdrive ~= nil then warpdrive.show() end
    -- unfreeze the player if he is remote controlling the construct
    if Nav.control.isRemoteControlled() == 1 and RemoteFreeze then
        system.freeze(1)
    else
        system.freeze(0)
    end
    if targetGroundAltitude ~= nil then
        Nav.axisCommandManager:setTargetGroundAltitude(targetGroundAltitude)
    end
    if hasGear then
        if gearExtended == nil then
            gearExtended = (Nav.control.isAnyLandingGearExtended() == 1) -- make sure it's a lua boolean
            if gearExtended then
                Nav.control.extendLandingGears()
            else
                Nav.control.retractLandingGears()
            end
        end
        if targetGroundAltitude == nil then
            if gearExtended then
                Nav.axisCommandManager:setTargetGroundAltitude(0)
            else
                Nav.axisCommandManager:setTargetGroundAltitude(TargetHoverHeight)
            end
        end
    elseif targetGroundAltitude == nil then
        if atmosphere() == 0 then
            gearExtended = false
            Nav.axisCommandManager:setTargetGroundAltitude(TargetHoverHeight)
        else
            gearExtended = true -- Show warning message and set behavior
            Nav.axisCommandManager:setTargetGroundAltitude(0)
        end
    end
    if atmosphere() > 0 and not dbHud and (gearExtended or not hasGear) then
        BrakeIsOn = true
    end

    unit.hide()
    unit.setTimer("apTick", apTickRate)
    unit.setTimer("oneSecond", 1)

    system.showScreen(1)

    InAtmo = (atmosphere() > 0)
    Animating = false
    Animated = false

    -- That was a lot of work with dirty strings and json.  Clean up
    collectgarbage("collect")
end -- !DU: end

do -- !DU: stop()
    _autoconf.hideCategoryPanels()
    if antigrav ~= nil then antigrav.hide() end
    if warpdrive ~= nil then warpdrive.hide() end
    core.hide()
    Nav.control.switchOffHeadlights()
    -- Open door and extend ramp if available
    local atmo = unit.getAtmosphereDensity()
    if door and (atmo > 0 or (atmo == 0 and core_altitude < 10000)) then
        for _,v in pairs(door) do
            v.activate()
        end
    end
    if forcefield and (atmo > 0 or (atmo == 0 and core_altitude < 10000)) then
        for _,v in pairs(forcefield) do
            v.activate()
        end
    end
    -- Save autovariables
    if dbHud then
        if not ResetAutoVars then
            for k,v in pairs(AutoVariables) do
                dbHud.setStringValue(v,json.encode(_G[v]))
            end
        end
    end
    if button then
        button.activate()
    end
end -- !DU: end

do -- !DU: tick([animateTick])
    Animated = true
    Animating = false
    simulatedX = 0
    simulatedY = 0
    unit.stopTimer("animateTick")
end -- !DU: end

do -- !DU: tick([oneSecond])
    -- Timer for evaluation every 1 second
    checkDamage()
    updateDistance()
    if (radar_1 and #radar_1.getEntries() > 0) then
        local target
        target = radar_1.getData():find('identifiedConstructs":%[%]')
        if target == nil and perisPanelID == nil then
            peris = 1
            ToggleRadarPanel()
        end
        if target ~= nil and perisPanelID ~= nil then
            ToggleRadarPanel()
        end
        if radarPanelID == nil then
            ToggleRadarPanel()
        end

        local radarContacts = #radar_1.getEntries()
        radarMessage = string.format([[<g class="text"><g font-size=14><text x="1770" y="330" text-anchor="middle" style="fill:%s">Radar: %i contacts</text></g></g>]],rgbO,radarContacts)
    elseif radar_1 then
        local data
        data = radar_1.getData():find('worksInEnvironment":false')
        if data then
            radarMessage =  string.format([[<g class="text"><g font-size=14><text x="1770" y="330" text-anchor="middle" style="fill:%s">Radar: Jammed</text></g></g>]],rgbO)
        else
            radarMessage =  string.format([[<g class="text"><g font-size=14><text x="1770" y="330" text-anchor="middle" style="fill:%s">Radar: No Contacts</text></g></g>]],rgbO)
        end
        if radarPanelID ~= nil then
            peris = 0
            ToggleRadarPanel()
        end
    end 

    -- Update odometer output string
    local newContent = {}
    local flightStyle = GetFlightStyle()
    DrawOdometer(newContent, totalDistanceTrip, totalDistanceTravelled, flightStyle, flightTime)       
    LastOdometerOutput = table.concat(newContent, "")
end -- !DU: end

do -- !DU: tick([msgTick])
    -- This is used to clear a message on screen after a short period of time and then stop itself
        DisplayMessage(newContent, "empty")
        msgText = "empty"
        unit.stopTimer("msgTick")
        msgTimer = 3
end -- !DU: end

do -- !DU: tick([apTick])
    -- NO USER CHANGES
    yawInput2 = 0
    rollInput2 = 0
    pitchInput2 = 0
    LastApsDiff = -1
    local velocity = vec3(core.getWorldVelocity())
    local velMag = vec3(velocity):len()
    local sys = galaxyReference[0]
    planet = sys:closestBody(core.getConstructWorldPos())
    kepPlanet = Kep(planet)
    orbit = kepPlanet:orbitalParameters(core.getConstructWorldPos(), velocity)
    local deltaX = system.getMouseDeltaX()
    local deltaY = system.getMouseDeltaY()
    targetGroundAltitude = Nav:getTargetGroundAltitude()
    local TrajectoryAlignmentStrength = 0.002 -- How strongly AP tries to align your velocity vector to the target when not in orbit
    if BrakeIsOn then
        brakeInput = 1
    else
        brakeInput = 0
    end
    core_altitude = core.getAltitude()
    if core_altitude == 0 then
        core_altitude = (vec3(core.getConstructWorldPos())-planet.center):len()-planet.radius
    end

    if AutopilotTargetName ~= "None" then

        ShowInterplanetaryPanel()
        system.updateData(interplanetaryHeaderText, '{"label": "Target", "value": "' .. AutopilotTargetName .. '", "unit":""}')
        travelTime = GetAutopilotTravelTime() -- This also sets AutopilotDistance so we don't have to calc it again
        distance = AutopilotDistance
        if not TurnBurn then 
            brakeDistance, brakeTime = GetAutopilotBrakeDistanceAndTime(velMag)
            maxBrakeDistance, maxBrakeTime = GetAutopilotBrakeDistanceAndTime(MaxGameVelocity)
        else
            brakeDistance, brakeTime = GetAutopilotTBBrakeDistanceAndTime(velMag)
            maxBrakeDistance, maxBrakeTime = GetAutopilotTBBrakeDistanceAndTime(MaxGameVelocity)
        end
        system.updateData(widgetDistanceText, '{"label": "Distance", "value": "' .. getDistanceDisplayString(distance) .. '", "unit":""}')
        system.updateData(widgetTravelTimeText, '{"label": "Travel Time", "value": "' .. FormatTimeString(travelTime) .. '", "unit":""}')
        system.updateData(widgetCurBrakeDistanceText, '{"label": "Cur Brake Distance", "value": "' .. getDistanceDisplayString(brakeDistance) .. '", "unit":""}')
        system.updateData(widgetCurBrakeTimeText, '{"label": "Cur Brake Time", "value": "' .. FormatTimeString(brakeTime) .. '", "unit":""}')
        system.updateData(widgetMaxBrakeDistanceText, '{"label": "Max Brake Distance", "value": "' .. getDistanceDisplayString(maxBrakeDistance) .. '", "unit":""}')
        system.updateData(widgetMaxBrakeTimeText, '{"label": "Max Brake Time", "value": "' .. FormatTimeString(maxBrakeTime) .. '", "unit":""}')
        if unit.getAtmosphereDensity() > 0 and not InAtmo then
            system.removeDataFromWidget(widgetMaxBrakeTimeText, widgetMaxBrakeTime)
            system.removeDataFromWidget(widgetMaxBrakeDistanceText, widgetMaxBrakeDistance)
            system.removeDataFromWidget(widgetCurBrakeTimeText, widgetCurBrakeTime)
            system.removeDataFromWidget(widgetCurBrakeDistanceText, widgetCurBrakeDistance)
            system.removeDataFromWidget(widgetTrajectoryAltitudeText, widgetTrajectoryAltitude)
            InAtmo = true
        elseif unit.getAtmosphereDensity() == 0 and InAtmo then
            system.addDataToWidget(widgetMaxBrakeTimeText, widgetMaxBrakeTime)
            system.addDataToWidget(widgetMaxBrakeDistanceText, widgetMaxBrakeDistance)
            system.addDataToWidget(widgetCurBrakeTimeText, widgetCurBrakeTime)
            system.addDataToWidget(widgetCurBrakeDistanceText, widgetCurBrakeDistance)
            system.addDataToWidget(widgetTrajectoryAltitudeText, widgetTrajectoryAltitude)
            InAtmo = false
        end
    else
        HideInterplanetaryPanel()
    end

    local newContent = {}
    if showHud then
        updateHud(newContent) -- sets up Content for us
    else
        newContent[#newContent + 1] = [[<head>
            <style>
                body {margin: 0}
                svg {display:block; position: absolute; top:0; left:0}
                text {font-family:Montserrat;font-weight:bold}
            </style>
            <body>
                <svg height="100vh" width="100vw" viewbox="0 0 1920 1080">]]
        DisplayOrbit(newContent)
        DrawWarnings(newContent)
    end
    newContent[#newContent + 1] = [[<svg width="100vw" height="100vh" style="position:absolute;top:0;left:0"  viewBox="0 0 2560 1440">]]
    if msgText ~= "empty" then 
        DisplayMessage(newContent, msgText)
    end
    if Nav.control.isRemoteControlled() == 0 and userControlScheme == "Virtual Joystick" then
        DrawDeadZone(newContent)
    end

    if Nav.control.isRemoteControlled() == 1 and screen_1 and screen_1.getMouseY() ~= -1 then
        simulatedX = screen_1.getMouseX()*2560
        simulatedY = screen_1.getMouseY()*1440
        SetButtonContains()
        DrawButtons(newContent)
        if screen_1.getMouseState() == 1 then
            CheckButtons()
        end
        newContent[#newContent + 1] = string.format("<circle stroke='white' cx='calc(50%% + %fpx)' cy='calc(50%% + %fpx)' r='5'/>", simulatedX, simulatedY)
    elseif system.isViewLocked() == 0 then
        if Nav.control.isRemoteControlled() == 1 and HoldingCtrl then
            if not Animating then
                simulatedX = simulatedX + deltaX
                simulatedY = simulatedY + deltaY
            end
            SetButtonContains()
            DrawButtons(newContent)

            -- If they're remote, it's kinda weird to be 'looking' everywhere while you use the mouse
            -- We need to add a body with a background color
            if not Animating and not Animated then
                local collapsedContent = table.concat(newContent, "")
                newContent = {}
                newContent[#newContent + 1] = "<style>@keyframes test { from { opacity: 0; } to { opacity: 1; } }  body { animation-name: test; animation-duration: 0.5s; }</style><body><svg width='100%' height='100%' position='absolute' top='0' left='0'><rect width='100%' height='100%' x='0' y='0' position='absolute' style='fill:rgb(6,5,26);'/></svg><svg width='50%' height='50%' style='position:absolute;top:30%;left:25%' viewbox='0 0 1920 1080'>"
                newContent[#newContent + 1] = GalaxyMapHTML
                newContent[#newContent + 1] = collapsedContent
                newContent[#newContent + 1] = "</body>"
                Animating = true
                newContent[#newContent + 1] = [[</svg></body>]] -- Uh what.. okay...
                unit.setTimer("animateTick",0.5)
                local content = table.concat(newContent, "")
                system.setScreen(content)
            elseif Animated then
                local collapsedContent = table.concat(newContent, "")
                newContent = {}
                newContent[#newContent + 1] = "<body style='background-color:rgb(6,5,26)'><svg width='50%' height='50%' style='position:absolute;top:30%;left:25%' viewbox='0 0 1920 1080'>"
                newContent[#newContent + 1] = GalaxyMapHTML
                newContent[#newContent + 1] = collapsedContent
                newContent[#newContent + 1] = "</body>"
            end
            
            if not Animating then
                newContent[#newContent + 1] = string.format("<circle stroke='white' cx='calc(50%% + %fpx)' cy='calc(50%% + %fpx)' r='5'/>", simulatedX, simulatedY)
            end
        else
            CheckButtons()
            simulatedX = 0
            simulatedY = 0 -- Reset after they do view things, and don't keep sending inputs while unlocked view
            -- Except of course autopilot, which is later.
        end
    else
        simulatedX = simulatedX + deltaX
        simulatedY = simulatedY + deltaY
        distance = math.sqrt(simulatedX*simulatedX + simulatedY*simulatedY)
        if not HoldingCtrl and Nav.control.isRemoteControlled() == 0 then -- Draw deadzone circle if it's navigating
            if userControlScheme == "Virtual Joystick" then -- Virtual Joystick
                -- Do navigation things
                
                if simulatedX > 0 and simulatedX > DeadZone then
                    yawInput2 = yawInput2 - (simulatedX - DeadZone) * MouseXSensitivity
                elseif simulatedX < 0 and simulatedX < (DeadZone * -1) then
                    yawInput2 = yawInput2 - (simulatedX + DeadZone) * MouseXSensitivity
                else
                    yawInput2 = 0
                end
            
                if simulatedY > 0 and simulatedY > DeadZone then
                    pitchInput2 = pitchInput2 - (simulatedY - DeadZone) * MouseYSensitivity
                elseif simulatedY < 0 and simulatedY < (DeadZone * -1) then
                    pitchInput2 = pitchInput2 - (simulatedY + DeadZone) * MouseYSensitivity
                else
                     pitchInput2 = 0
                end
            elseif userControlScheme == "Mouse" then -- Mouse Direct
                simulatedX = 0
                simulatedY = 0
                --pitchInput2 = pitchInput2 - deltaY * mousePitchFactor
                --yawInput2 = yawInput2 - deltaX * mouseYawFactor
                -- So... this is weird.  
                -- It's doing some odd things and giving us some weird values. 
                
                -- utils.smoothstep(progress, low, high)*2-1
                pitchInput2 = (-utils.smoothstep(deltaY, -100, 100) + 0.5)*2*mousePitchFactor
                yawInput2 = (-utils.smoothstep(deltaX, -100, 100) + 0.5)*2*mouseYawFactor
            else -- Keyboard mode
                simulatedX = 0
                simulatedY = 0
                -- Don't touch anything, they have it with kb only.  
            end



            -- Right so.  We can't detect a mouse click.  That's stupid.  
            -- We have two options.  1. Use mouse wheel movement as a click, or 2. If you're hovered over a button and let go of Ctrl, it's a click
            -- I think 2 is a much smoother solution.  Even if we later want to have them input some coords
            -- We'd have to hook 0-9 in their events, and they'd have to point at the target, so it wouldn't be while this screen is open
            
            -- What that means is, if we get here, check our hovers.  If one of them is active, trigger the thing and deactivate the hover
            CheckButtons()
            
            
            if distance > DeadZone then -- Draw a line to the cursor from the screen center
                -- Note that because SVG lines fucking suck, we have to do a translate and they can't use calc in their params
                DrawCursorLine(newContent)
            end
        else
            -- Ctrl is being held, draw buttons.
            -- Brake toggle, face prograde, face retrograde (for now)
            -- We've got some vars setup in Start for them to make this easier to work with
            SetButtonContains()
            DrawButtons(newContent)
            
        end
        -- Cursor always on top, draw it last
        newContent[#newContent + 1] = string.format("<circle stroke='white' cx='calc(50%% + %fpx)' cy='calc(50%% + %fpx)' r='5'/>", simulatedX, simulatedY)

    end
    newContent[#newContent + 1] = [[</svg></body>]]
    local content = table.concat(newContent, "")
    if content ~= LastContent then
        --if Nav.control.isRemoteControlled() == 1 and screen_1 then -- Once the screens are fixed we can do this.
        --    screen_1.setHTML(content) -- But also this is disgusting and the resolution's terrible.  We're doing something wrong.
        --else
        if not Animating then
            system.setScreen(content)
        end
        --end
    end
    LastContent = content
    if AutoBrake and AutopilotTargetPlanetName ~= "None" and (vec3(core.getConstructWorldPos())-vec3(AutopilotTargetPlanet.center)):len() <= brakeDistance then
        brakeInput = 1
        if planet.name == AutopilotTargetPlanet.name and orbit.apoapsis ~= nil and orbit.eccentricity < 1 then
                -- We're increasing eccentricity by braking, time to stop
                brakeInput = 0
                AutoBrake = false
        end
    end
    if ProgradeIsOn then 
        if velMag > MinAutopilotSpeed then -- Help with div by 0 errors and careening into terrain at low speed
                AlignToWorldVector(vec3(velocity))
        end
    end
    if RetrogradeIsOn then 
        if velMag > MinAutopilotSpeed then -- Help with div by 0 errors and careening into terrain at low speed
                AlignToWorldVector(-(vec3(velocity)))
        end
    end
    if Autopilot and unit.getAtmosphereDensity() == 0 then
        -- Planetary autopilot engaged, we are out of atmo, and it has a target
        -- Do it.  
        -- And tbh we should calc the brakeDistance live too, and of course it's also in meters
        local brakeDistance, brakeTime
        if not TurnBurn then
            brakeDistance, brakeTime = GetAutopilotBrakeDistanceAndTime(velMag)
        else
            brakeDistance, brakeTime = GetAutopilotTBBrakeDistanceAndTime(velMag)
        end
        brakeDistance = brakeDistance 
        brakeTime = brakeTime -- * 1.05 -- Padding?
        -- Maybe instead of pointing at our vector, we point at our vector + how far off our velocity vector is
        -- This is gonna be hard to get the negatives right.
        -- If we're still in orbit, don't do anything, that velocity will suck
        local targetCoords = AutopilotTargetCoords
        if orbit.apoapsis == nil and velMag > 300 and AutopilotAccelerating then
            -- Get the angle between forward and velocity
            -- Get the magnitude for each of yaw and pitch
            -- Consider a right triangle, with side a being distance to our target
            -- get side b, where have the angle.  Do this once for each of yaw and pitch
            -- The result of each of those would then be multiplied by something to make them vectors...
            
            
            -- Okay another idea.
            -- Normalize forward and velocity, then get the ratio of normvelocity:velocity
            -- And scale forward back up by that amount.  Then take forward-velocity, the 
            
            
            -- No no.
            -- Okay so, first, when we realign, we store shipright and shipup, just for this
            -- Get the difference between ship forward and normalized worldvel
            -- Get the components in each of the stored shipright and shipup directions
            -- Get the ratio of velocity to normalized velocity and scale up that component (Hey this is just velmag btw)
            -- Add that component * shipright or shipup
            local velVectorOffset = (vec3(AutopilotTargetCoords) - vec3(core.getConstructWorldPos())):normalize() - vec3(velocity):normalize()
            local pitchComponent = getMagnitudeInDirection(velVectorOffset, AutopilotShipUp)
            local yawComponent = getMagnitudeInDirection(velVectorOffset, AutopilotShipRight)
            local leftAmount = -yawComponent * AutopilotDistance * velMag*TrajectoryAlignmentStrength
            local downAmount = -pitchComponent * AutopilotDistance * velMag*TrajectoryAlignmentStrength
            targetCoords = AutopilotTargetCoords + (-leftAmount * vec3(AutopilotShipRight)) + (-downAmount * vec3(AutopilotShipUp))
        end
        -- If we're here, sadly, we really need to calc the distance every update (or tick)
        AutopilotDistance = (vec3(targetCoords) - vec3(core.getConstructWorldPos())):len()
        system.updateData(widgetDistanceText, '{"label": "Distance", "value": "' .. getDistanceDisplayString(AutopilotDistance) .. '", "unit":""}')
        local aligned = true  -- It shouldn't be used if the following condition isn't met, but just in case
            
        local projectedAltitude = (AutopilotTargetPlanet.center - (vec3(core.getConstructWorldPos()) + (vec3(velocity):normalize() * AutopilotDistance))):len() - AutopilotTargetPlanet.radius
        system.updateData(widgetTrajectoryAltitudeText, '{"label": "Projected Altitude", "value": "' .. getDistanceDisplayString(projectedAltitude) .. '", "unit":""}')

        if not AutopilotCruising and not AutopilotBraking then
            aligned = AlignToWorldVector((targetCoords-vec3(core.getConstructWorldPos())):normalize())
        elseif TurnBurn then
            aligned = AlignToWorldVector(-vec3(velocity):normalize())
        end
        if AutopilotAccelerating then
            if not aligned then
                AutopilotStatus = "Adjusting Trajectory"
            else
                AutopilotStatus = "Accelerating"
            end
            
            if vec3(core.getVelocity()):len() >= MaxGameVelocity then -- This is 29999 kph
                AutopilotAccelerating = false
                AutopilotStatus = "Cruising"
                AutopilotCruising = true
                Nav.axisCommandManager:setThrottleCommand(axisCommandId.longitudinal, 0)
            end
            -- Check if accel needs to stop for braking
            if AutopilotDistance <= brakeDistance then
                AutopilotAccelerating = false
                AutopilotStatus = "Braking"
                AutopilotBraking = true
                Nav.axisCommandManager:setThrottleCommand(axisCommandId.longitudinal, 0)
            end
        elseif AutopilotBraking then
            BrakeIsOn = true
            brakeInput = 1
            if TurnBurn then
                Nav.axisCommandManager:setThrottleCommand(axisCommandId.longitudinal, 100) -- This stays 100 to not mess up our calculations
            end
            -- Check if an orbit has been established and cut brakes and disable autopilot if so
            
            -- We'll try <0.9 instead of <1 so that we don't end up in a barely-orbit where touching the controls will make it an escape orbit
            -- Though we could probably keep going until it starts getting more eccentric, so we'd maybe have a circular orbit
            
            if orbit.periapsis ~= nil and orbit.eccentricity < 1 then
                AutopilotStatus = "Circularizing"
                -- Keep going until the apoapsis and periapsis start getting further apart
                -- Rather than: orbit.periapsis ~= nil and orbit.periapsis.altitude < ((vec3(planet.center) - vec3(core.getConstructWorldPos())):len() - planet.radius)-1000
                --local apsDiff = math.abs(orbit.apoapsis.altitude - orbit.periapsis.altitude)
                --if LastApsDiff ~= -1 and apsDiff > LastApsDiff then 
                if orbit.eccentricity > LastEccentricity or (orbit.apoapsis.altitude < AutopilotTargetOrbit and orbit.periapsis.altitude < AutopilotTargetOrbit) then
                    --LastApsDiff = -1
                    BrakeIsOn = false
                    AutopilotBraking = false
                    Autopilot = false
                    AutopilotStatus = "Aligning" -- Disable autopilot and reset
                    -- TODO: This is being added to newContent *after* we already drew the screen, so it'll never get displayed
                    DisplayMessage(newContent, "Autopilot completed, orbit established")
                    brakeInput = 0
                    Nav.axisCommandManager:setThrottleCommand(axisCommandId.longitudinal, 0)
                end
                LastApsDiff = apsDiff
            end
        elseif AutopilotCruising then
            if AutopilotDistance <= brakeDistance then
                AutopilotAccelerating = false
                AutopilotStatus = "Braking"
                AutopilotBraking = true
            end
        else
            -- It's engaged but hasn't started accelerating yet.
            if aligned then
                    -- Re-align to 200km from our aligned right                    
                    if not AutopilotRealigned then -- Removed radius from this because it makes our readouts look inaccurate?
                        AutopilotTargetCoords = vec3(AutopilotTargetPlanet.center) + ((AutopilotTargetOrbit + AutopilotTargetPlanet.radius) * vec3(core.getConstructWorldOrientationRight()))
                        AutopilotRealigned = true
                        AutopilotShipUp = core.getConstructWorldOrientationUp()
                        AutopilotShipRight = core.getConstructWorldOrientationRight()
                    elseif aligned then
                        AutopilotAccelerating = true
                        AutopilotStatus = "Accelerating"
                        -- Set throttle to max
                        Nav.axisCommandManager:setThrottleCommand(axisCommandId.longitudinal, AutopilotInterplanetaryThrottle)
                end
            end
            -- If it's not aligned yet, don't try to burn yet.
        end
    end
    if FollowMode then
        -- User is assumed to be outside the construct
        autoRoll = true -- Let Nav handle that while we're here
        local targetPitch = 0
        -- Keep brake engaged at all times unless: 
            -- Ship is aligned with the target on yaw (roll and pitch are locked to 0)
            -- and ship's speed is below like 5-10m/s
        local pos = vec3(core.getConstructWorldPos()) + vec3(unit.getMasterPlayerRelativePosition()) -- Is this related to core forward or nah?
        local distancePos = (pos-vec3(core.getConstructWorldPos()))
        --local distance = distancePos:len()
        -- Distance needs to be calculated using only construct forward and right
        local distanceForward = vec3(distancePos):project_on(vec3(core.getConstructWorldOrientationForward())):len()
        local distanceRight = vec3(distancePos):project_on(vec3(core.getConstructWorldOrientationRight())):len()
        --local distanceDown = vec3(distancePos):project_on(-vec3(core.getConstructWorldOrientationRight())):len()
        local distance = math.sqrt(distanceForward*distanceForward+distanceRight*distanceRight)
        AlignToWorldVector(distancePos:normalize())
        local targetDistance = 40
        --local onShip = false
        --if distanceDown < 1 then 
        --    onShip = true
        --end
        local nearby = (distance < targetDistance)
        local maxSpeed = 100 -- Over 300kph max, but, it scales down as it approaches
        if onShip then
            maxSpeed = 300
        end
        local targetSpeed = utils.clamp((distance-targetDistance)/2,10,maxSpeed)
        pitchInput2 = 0
        local aligned = (math.abs(yawInput2) < 0.1)
        if (aligned and velMag < targetSpeed and not nearby) then -- or (not BrakeIsOn and onShip) then
            --if not onShip then -- Don't mess with brake if they're on ship
                BrakeIsOn = false
            --end
            targetPitch = -10
        else
            --if not onShip then
                BrakeIsOn = true
            --end
            targetPitch = 0
        end
        local constrF = vec3(core.getConstructWorldOrientationForward())
        local constrR = vec3(core.getConstructWorldOrientationRight())
        local worldV = vec3(core.getWorldVertical())
        local pitch = getPitch(worldV, constrF, constrR)
        local autoPitchThreshold = 1.0
        -- Copied from autoroll let's hope this is how a PID works... 
        if math.abs(targetPitch - pitch) > autoPitchThreshold then
            if (pitchPID == nil) then
                pitchPID = pid.new(2 * 0.01, 0, 2 * 0.1) -- magic number tweaked to have a default factor in the 1-10 range
            end
            pitchPID:inject(targetPitch - pitch)
            local autoPitchInput = pitchPID:get()

            pitchInput2 = autoPitchInput
        end
    end
    if AltitudeHold then
        -- HoldAltitude is the alt we want to hold at
        local altitude = core_altitude
        -- Dampen this.
        local altDiff = HoldAltitude - altitude
        local MaxPitch = 20
        -- This may be better to smooth evenly regardless of HoldAltitude.  Let's say, 2km scaling?  Should be very smooth for atmo
        -- Even better if we smooth based on their velocity
        local minmax = 500 + velMag
        local targetPitch = (utils.smoothstep(altDiff, -minmax, minmax) - 0.5)*2*MaxPitch 
        -- The clamp should now be redundant
        --local targetPitch = utils.clamp(altDiff,-20,20) -- Clamp to reasonable values
        -- Align it prograde but keep whatever pitch inputs they gave us before, and ignore pitch input from alignment.
        -- So, you know, just yaw.
        local oldInput = pitchInput2
        if velMag > MinAutopilotSpeed then
            AlignToWorldVector(vec3(velocity))
        end
        pitchInput2 = oldInput
          
        if AutoLanding then
            targetPitch = -10 -- Some flat, easy value.
            local groundDistance
            if Nav.axisCommandManager:getAxisCommandType(0) == 1 then
                Nav.control.cancelCurrentControlMasterMode()
            end
            Nav.axisCommandManager:setTargetGroundAltitude(500)
            Nav.axisCommandManager:activateGroundEngineAltitudeStabilization(500)
            if vBooster then
                groundDistance = vBooster.distance()
            elseif hover then
                groundDistance = hover.distance()
            end
            if groundDistance > -1 then
                upAmount = 1
                targetPitch = 10
                BrakeIsOn = true
                if velMag < 20 then
                    targetPitch = 0
                end
                if velMag < 1 then
                    AutoLanding = false
                    AltitudeHold = false
                    gearExtended = true
                    Nav.control.extendLandingGears()
                    Nav.axisCommandManager:setTargetGroundAltitude(0)
                    upAmount = 0
                end
            end
        elseif AutoTakeoff then
            if targetPitch < 10 then
                AutoTakeoff = false -- No longer in ascent
            end
        end
        local constrF = vec3(core.getConstructWorldOrientationForward())
        local constrR = vec3(core.getConstructWorldOrientationRight())
        local worldV = vec3(core.getWorldVertical())
        local pitch = getPitch(worldV, constrF, constrR)
        local autoPitchThreshold = 0.1
        -- Copied from autoroll let's hope this is how a PID works... 
        if math.abs(targetPitch - pitch) > autoPitchThreshold then
            if (pitchPID == nil) then -- Changed from 2 to 8 to tighten it up around the target
                pitchPID = pid.new(8 * 0.01, 0, 8 * 0.1) -- magic number tweaked to have a default factor in the 1-10 range
            end
            pitchPID:inject(targetPitch - pitch)
            local autoPitchInput = pitchPID:get()
            pitchInput2 = pitchInput2 + autoPitchInput
        end
    end
    LastEccentricity = orbit.eccentricity
end -- !DU: end
