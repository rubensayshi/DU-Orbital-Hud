function ToggleRadarPanel()
    if radarPanelID ~= nil and peris == 0 then
        system.destroyWidgetPanel(radarPanelID)
        radarPanelID = nil
        if perisPanelID ~= nil then
            system.destroyWidgetPanel(perisPanelID)
            perisPanelID = nil
        end
    else
        -- If radar is installed but no weapon, don't show periscope
        if peris == 1 then
            system.destroyWidgetPanel(radarPanelID)
            radarPanelID = nil
            _autoconf.displayCategoryPanel(radar, radar_size, "Periscope", "periscope")
            perisPanelID =  _autoconf.panels[_autoconf.panels_size]
        end
        placeRadar = true
        if radarPanelID == nil and placeRadar then
            _autoconf.displayCategoryPanel(radar, radar_size, "Radar", "radar")
            radarPanelID =  _autoconf.panels[_autoconf.panels_size]
            placeRadar = false
        end
        peris = 0
    end
end

function ToggleWidgets()
    if UnitHidden then
        unit.show()
        core.show()
        if atmofueltank_size > 0 then
            _autoconf.displayCategoryPanel(atmofueltank, atmofueltank_size, "Atmo Fuel", "fuel_container")
            fuelPanelID =  _autoconf.panels[_autoconf.panels_size]
        end
        if spacefueltank_size > 0 then
            _autoconf.displayCategoryPanel(spacefueltank, spacefueltank_size, "Space Fuel", "fuel_container")
            spacefuelPanelID =  _autoconf.panels[_autoconf.panels_size]
        end
        if rocketfueltank_size > 0 then
            _autoconf.displayCategoryPanel(rocketfueltank, rocketfueltank_size, "Rocket Fuel", "fuel_container")
            rocketfuelPanelID =  _autoconf.panels[_autoconf.panels_size]
        end
        UnitHidden = false
    else
        unit.hide()
        core.hide()
        if fuelPanelID ~= nil then
            system.destroyWidgetPanel(fuelPanelID)
            fuelPanelID = nil
        end
        if spacefuelPanelID ~= nil then
            system.destroyWidgetPanel(spacefuelPanelID)
            spacefuelPanelID = nil
        end
        if rocketfuelPanelID ~= nil then
            system.destroyWidgetPanel(rocketfuelPanelID)
            rocketfuelPanelID = nil
        end

        UnitHidden = true
    end
end

-- Interplanetary helper
function ShowInterplanetaryPanel()
    if panelInterplanetary == nil then
        panelInterplanetary = system.createWidgetPanel("Interplanetary Helper")
        interplanetaryHeader = system.createWidget(panelInterplanetary, "value")
        interplanetaryHeaderText = system.createData('{"label": "Target Planet", "value": "N/A", "unit":""}')
        system.addDataToWidget(interplanetaryHeaderText, interplanetaryHeader)
        widgetDistance = system.createWidget(panelInterplanetary, "value")
        widgetDistanceText = system.createData('{"label": "Distance", "value": "N/A", "unit":""}')
        system.addDataToWidget(widgetDistanceText, widgetDistance)
        widgetTravelTime = system.createWidget(panelInterplanetary, "value")
        widgetTravelTimeText = system.createData('{"label": "Travel Time", "value": "N/A", "unit":""}')
        system.addDataToWidget(widgetTravelTimeText, widgetTravelTime)
        widgetCurBrakeDistance = system.createWidget(panelInterplanetary, "value")
        widgetCurBrakeDistanceText = system.createData('{"label": "Cur Brake Distance", "value": "N/A", "unit":""}')
        if not InAtmo then system.addDataToWidget(widgetCurBrakeDistanceText, widgetCurBrakeDistance) end
        widgetCurBrakeTime = system.createWidget(panelInterplanetary, "value")
        widgetCurBrakeTimeText = system.createData('{"label": "Cur Brake Time", "value": "N/A", "unit":""}')
        if not InAtmo then system.addDataToWidget(widgetCurBrakeTimeText, widgetCurBrakeTime) end
        widgetMaxBrakeDistance = system.createWidget(panelInterplanetary, "value")
        widgetMaxBrakeDistanceText = system.createData('{"label": "Max Brake Distance", "value": "N/A", "unit":""}')
        if not InAtmo then system.addDataToWidget(widgetMaxBrakeDistanceText, widgetMaxBrakeDistance) end
        widgetMaxBrakeTime = system.createWidget(panelInterplanetary, "value")
        widgetMaxBrakeTimeText = system.createData('{"label": "Max Brake Time", "value": "N/A", "unit":""}')
        if not InAtmo then system.addDataToWidget(widgetMaxBrakeTimeText, widgetMaxBrakeTime) end
        widgetTrajectoryAltitude = system.createWidget(panelInterplanetary, "value")
        widgetTrajectoryAltitudeText = system.createData('{"label": "Projected Altitude", "value": "N/A", "unit":""}')
        if not InAtmo then system.addDataToWidget(widgetTrajectoryAltitudeText, widgetTrajectoryAltitude) end
    end
end

function toggleFollowMode()
    if Nav.control.isRemoteControlled() == 1 then
        FollowMode = not FollowMode
        if FollowMode then 
            Autopilot = false
            RetrogradeIsOn = false
            ProgradeIsOn = false
            AutoBrake = false
            if not AltitudeHold then
                OldAutoRoll = autoRoll
            end
            AltitudeHold = false
            AutoLanding = false
            AutoTakeoff = false
            OldGearExtended = gearExtended
            gearExtended = false
            Nav.control.retractLandingGears()
            Nav.axisCommandManager:setTargetGroundAltitude(500) -- Hard-set this for auto-follow
        else
            BrakeIsOn = true
            autoRoll = OldAutoRoll
            gearExtended = OldGearExtended
            if gearExtended then
                Nav.control.extendLandingGears()
                Nav.axisCommandManager:setTargetGroundAltitude(0)
            end
        end
    end
end

function AutopilotToggle()
    -- Toggle Autopilot, as long as the target isn't None
    if AutopilotTargetName ~= "None" and not Autopilot then
        Autopilot = true
        RetrogradeIsOn = false
        ProgradeIsOn = false
        AutopilotButtonHovered = false
        AutopilotRealigned = false
        FollowMode = false
        AltitudeHold = false
        AutoLanding = false
        AutoTakeoff = false
    else
        Autopilot = false
        AutopilotButtonHovered = false
        AutopilotRealigned = false
    end
end

function checkDamage()
    local percentDam = 0
    local color = 0
    local colorMod = [[]]
    local maxShipHP = eleTotalMaxHp
    local curShipHP = 0
    local voxelDam = 0
    local damagedElements = 0
    local disabledElements = 0
    for k in pairs(elementsID) do
        local hp = 0
        local mhp = 0
        mhp = eleMaxHp(elementsID[k])
        hp = eleHp(elementsID[k])
        curShipHP = curShipHP + hp
        if (hp == 0) then
            disabledElements = disabledElements +1
        elseif (hp < mhp) then 
            damagedElements = damagedElements +1 
        end
    end
    percentDam = mfloor((curShipHP * 100 / maxShipHP))
    voxelDam = math.ceil( 100*(constructMass() - updateMass()) / honeyCombMass)
    colorMod = percentDam*2.55
    color = [[rgb(]] .. 255-colorMod .. "," .. colorMod .. "," .. 0 .. [[)]]
    if voxelDam < 100 then 
        damageMessage = damageMessage.. [[
            <g class="text"><g font-size=18>
                <text x=50% y="1015" text-anchor="middle" style="fill:]] .. color .. [[">Structural Integrity: ]]..voxelDam..[[%</text>]]
    end
    if percentDam < 100 then
        damageMessage = damageMessage.. [[
            <g class="text"><g font-size=18>
                <text x=50% y="1035" text-anchor="middle" style="fill:]] .. color .. [[">Elemental Integrity: ]]..percentDam..[[%</text>]]
        if (disabledElements > 0) then 
            damageMessage = damageMessage..[[<text x=50% y="1055" text-anchor="middle" style="fill:red">Disabled Modules: ]]..disabledElements..[[ Damaged Modules: ]]..damagedElements..[[</text></g></g>]]
        elseif damagedElements > 0 then
            damageMessage = damageMessage..[[<text x=50% y="1055" text-anchor="middle" style="fill:]] .. color .. [[">Damaged Modules: ]]..damagedElements..[[</text>
            </g></g>]]
        end
    end
end
function DrawCursorLine(newContent)
    local strokeColor = mfloor(utils.clamp((distance/(ResolutionWidth/4))*255,0,255))
    newContent[#newContent + 1] = stringf("<line x1='0' y1='0' x2='%fpx' y2='%fpx' style='stroke:rgb(%d,%d,%d);stroke-width:2;transform:translate(50%%, 50%%)' />",simulatedX, simulatedY, mfloor(PrimaryR+0.5) + strokeColor, mfloor(PrimaryG+0.5)-strokeColor, mfloor(PrimaryB+0.5)-strokeColor)
end

function ToggleAutoBrake()
    if AutopilotTargetPlanetName ~= "None" and brakeInput == 0 and not AutoBrake then
        AutoBrake = true
        Autopilot = false
        ProgradeIsOn = false
        RetrogradeIsOn = false
        FollowMode = false
        AltitudeHold = false
        AutoLanding = false
        AutoTakeoff = false
    else
        AutoBrake = false
    end
end

function getPitch(gravityDirection, forward, right)
    local horizontalForward = gravityDirection:cross(right):normalize_inplace() -- Cross forward?
    local pitch = math.acos(utils.clamp(horizontalForward:dot(-forward), -1, 1)) * constants.rad2deg -- acos?
    if horizontalForward:cross(-forward):dot(right) < 0 then pitch = -pitch end -- Cross right dot forward?
    return pitch
end

function saveVariables()
    if not dbHud then
        msgText = "No Databank Found, unable to save. You must have a Databank attached to ship prior to running the HUD autoconfigure" 
    elseif valuesAreSet then
        if doubleCheck then
            -- If any values are set, wipe them all
            for k,v in pairs(SaveableVariables) do
                dbHud.setStringValue(v,jencode(nil))
            end
            -- Including the auto vars
            ResetAutoVars = true
            for k,v in pairs(AutoVariables) do
                dbHud.setStringValue(v, jencode(nil))
            end
            msgText = "Databank wiped. Get out of the seat, set the savable variables, then re-enter seat and hit ALT-7 again"
            doubleCheck = false
            valuesAreSet = false
        else
            msgText = "Press ALT-7 again to confirm wipe"
            doubleCheck = true
        end
    else
        for k,v in pairs(SaveableVariables) do
            dbHud.setStringValue(v,jencode(_G[v]))
        end
        msgText = "Saved Variables to Datacore"
        ResetAutoVars = false
        valuesAreSet = true
    end
end

function ProgradeToggle()
    -- Toggle Progrades
    ProgradeIsOn = not ProgradeIsOn
    RetrogradeIsOn = false -- Don't let both be on
    Autopilot = false
    AltitudeHold = false
    AutoBrake = false
    FollowMode = false
    AutoLanding = false
    AutoTakeoff = false
    ProgradeButtonHovered = false
    local Progradestring = "Off"
    if ProgradeIsOn then
        Progradestring = "On"
    end
end

function RetrogradeToggle()
    -- Toggle Retrogrades
    RetrogradeIsOn = not RetrogradeIsOn
    ProgradeIsOn = false -- Don't let both be on
    Autopilot = false
    AltitudeHold = false
    AutoBrake = false
    FollowMode = false
    AutoLanding = false
    AutoTakeoff = false
    RetrogradeButtonHovered = false
    local Retrogradestring = "Off"
    if RetrogradeIsOn then
        Retrogradestring = "On"
    end
end

function BrakeToggle()
    -- Toggle brakes
    BrakeIsOn = not BrakeIsOn
    BrakeButtonHovered = false
    if BrakeIsOn and not AutoTakeoff then
        -- If they turn on brakes, disable a few things
        AltitudeHold = false
        AutoTakeoff = false
        AutoLanding = false -- If they tap it, we abort, that's the way it goes.
        -- We won't abort interplanetary because that would fuck everyone.
        ProgradeIsOn = false -- No reason to brake while facing prograde, but retrograde yes.
    elseif not AutoTakeoff then
        AutoLanding = false -- If they disable during an autoland that's braking, still need to stop autoland
        AltitudeHold = false -- And stop alt hold
    end
end

function CheckButtons()
    if BrakeButtonHovered then
        brakeToggle = not brakeToggle
    end
    if ProgradeButtonHovered then
        ProgradeToggle()
    end
    if RetrogradeButtonHovered then
        RetrogradeToggle()
    end

    if AutopilotButtonHovered then
        AutopilotToggle()
    end
    if TurnBurnButtonHovered then
        ToggleTurnBurn()
    end
    if LandingButtonHovered then
        if AutoLanding then
            AutoLanding = false
            -- Don't disable alt hold for auto land
        else
            if not AltitudeHold then
                ToggleAltitudeHold()
            end
            AutoTakeoff = false
            AutoLanding = true
            Nav.axisCommandManager:setThrottleCommand(axisCommandId.longitudinal, 0)
        end
    end
    if TakeoffButtonHovered then
        if AutoTakeoff then
            -- Turn it off, and also AltitudeHold cuz it's weird if you cancel and that's still going 
            AutoTakeoff = false
            if AltitudeHold then
                ToggleAltitudeHold()
            end
        else
            if not AltitudeHold then
                ToggleAltitudeHold()
            end
            AutoTakeoff = true
            HoldAltitude = core_altitude + AutoTakeoffAltitude
            gearExtended = false
            Nav.control.retractLandingGears()
            Nav.axisCommandManager:setTargetGroundAltitude(500) -- Hard set this for takeoff, you wouldn't use takeoff from a hangar
            BrakeIsOn = true
        end
    end
    if AltitudeHoldButtonHovered then
        ToggleAltitudeHold()
    end
    if FollowModeButtonHovered then
        toggleFollowMode()
    end
    BrakeButtonHovered = false         
    RetrogradeButtonHovered = false    
    ProgradeButtonHovered = false
    AutopilotButtonHovered = false
    TurnBurnButtonHovered = false
    FollowModeButtonHovered = false
    AltitudeHoldButtonHovered = false
    LandingButtonHovered = false
    TakeoffButtonHovered = false -- After checking, clear our flags.
end

function SetButtonContains()
    BrakeButtonHovered = Contains(simulatedX + ResolutionWidth/2, simulatedY + ResolutionHeight/2, ButtonBrakeX, ButtonBrakeY, ButtonBrakeWidth, ButtonBrakeHeight)
    ProgradeButtonHovered = Contains(simulatedX + ResolutionWidth/2, simulatedY + ResolutionHeight/2, ButtonProgradeX, ButtonProgradeY, ButtonProgradeWidth, ButtonProgradeHeight)
    RetrogradeButtonHovered = Contains(simulatedX + ResolutionWidth/2, simulatedY + ResolutionHeight/2, ButtonRetrogradeX, ButtonRetrogradeY, ButtonRetrogradeWidth, ButtonRetrogradeHeight)
    AutopilotButtonHovered = Contains(simulatedX + ResolutionWidth/2, simulatedY + ResolutionHeight/2, ButtonAutopilotX, ButtonAutopilotY, ButtonAutopilotWidth, ButtonAutopilotHeight)
    AltitudeHoldButtonHovered = Contains(simulatedX + ResolutionWidth/2, simulatedY + ResolutionHeight/2, ButtonAltitudeHoldX, ButtonAltitudeHoldY, ButtonAltitudeHoldWidth, ButtonAltitudeHoldHeight)
    TakeoffButtonHovered = Contains(simulatedX + ResolutionWidth/2, simulatedY + ResolutionHeight/2, ButtonTakeoffX, ButtonTakeoffY, ButtonTakeoffWidth, ButtonTakeoffHeight)
    LandingButtonHovered = Contains(simulatedX + ResolutionWidth/2, simulatedY + ResolutionHeight/2, ButtonLandingX, ButtonLandingY, ButtonLandingWidth, ButtonLandingHeight)
    TurnBurnButtonHovered = Contains(simulatedX + ResolutionWidth/2, simulatedY + ResolutionHeight/2, ButtonTurnBurnX, ButtonTurnBurnY, ButtonTurnBurnWidth, ButtonTurnBurnHeight)
    FollowModeButtonHovered = Contains(simulatedX + ResolutionWidth/2, simulatedY + ResolutionHeight/2, ButtonFollowModeX, ButtonFollowModeY, ButtonFollowModeWidth, ButtonFollowModeHeight)
    -- And... Check the map if it's up
    -- For now that's RC only
    if Nav.control.isRemoteControlled() == 1 and math.abs(simulatedX) < ResolutionWidth/2 and math.abs(simulatedY) < ResolutionHeight/2 then
        local count = 1
        local closestMatch = nil
        local distanceToClosest = nil
        for k,v in pairs(Atlas()[0]) do
            local x = v.center.x/MapXRatio -- 1.1
            local y = v.center.y/MapYRatio -- 1.4
            -- So our map is 30% from top, 25% from left, and it's 50% width
            -- Our simulatedX and Y are already offsets from center
            -- So if we move it down by 10% and scale it.  So fucking why doesn't it work
            
            local convertedX = simulatedX/2*1.1
            local convertedY = 1.4*((simulatedY/2)-ResolutionHeight/20)
            local dist = math.sqrt((x-convertedX)*(x-convertedX)+(y-convertedY)*(y-convertedY))
            if distanceToClosest == nil or dist < distanceToClosest then
                closestMatch = count
                distanceToClosest = dist
            end
            count = count + 1
        end
        if distanceToClosest < 30 then
            --AutopilotTargetIndex = closestMatch
            --UpdateAutopilotTarget()
        end
    end
end

function DrawButton(newContent, toggle, hover, x, y, w, h, activeColor, inactiveColor, activeText, inactiveText)
    newContent[#newContent + 1] = stringf("<rect rx='5' ry='5' x='%f' y='%f' width='%f' height='%f' fill='",x, y, w, h)
    if toggle then 
        newContent[#newContent + 1] = stringf("%s'", activeColor)
    else
        newContent[#newContent + 1] = inactiveColor
    end
    if hover then 
        newContent[#newContent + 1] = " style='stroke:white; stroke-width:2'"
    else
        newContent[#newContent + 1] = " style='stroke:black; stroke-width:1'"
    end    
    newContent[#newContent + 1] = "></rect>"
    newContent[#newContent + 1] = stringf("<text x='%f' y='%f' font-size='24' fill='", x + w/2, y + (h/2) + 5)
    if toggle then
        newContent[#newContent + 1] = "black"
    else
        newContent[#newContent + 1] = "white"
    end
    newContent[#newContent + 1] = "' text-anchor='middle' font-family='Montserrat'>"
    if toggle then 
        newContent[#newContent + 1] = stringf("%s</text>", activeText)
    else
        newContent[#newContent + 1] = stringf("%s</text>", inactiveText)
    end
end

function DrawButtons(newContent)
    local defaultColor = "rgb(0,18,133)'"
    local draw = DrawButton

    -- Brake button
    draw(newContent, brakeToggle, BrakeButtonHovered, ButtonBrakeX, ButtonBrakeY, ButtonBrakeWidth, ButtonBrakeHeight, "#CC0000", defaultColor, "Disable Brake Toggle", "Enable Brake Toggle")

    -- Prograde button
    draw(newContent, ProgradeIsOn, ProgradeButtonHovered, ButtonProgradeX, ButtonProgradeY, ButtonProgradeWidth, ButtonProgradeHeight, "#FFEECC", defaultColor, "Disable Prograde", "Align Prograde")

    -- Retrograde button
    draw(newContent, RetrogradeIsOn, RetrogradeButtonHovered, ButtonRetrogradeX, ButtonRetrogradeY, ButtonRetrogradeWidth, ButtonRetrogradeHeight, "#42006b", defaultColor, "Disable Retrograde", "Align Retrograde")

    -- Autopilot button
    draw(newContent, Autopilot, AutopilotButtonHovered, ButtonAutopilotX, ButtonAutopilotY, ButtonAutopilotWidth, ButtonAutopilotHeight, "red", defaultColor, "Disable Autopilot", stringf("Engage Autopilot: %s</text>",AutopilotTargetName))

    -- AltitudeHold button
    draw(newContent, AltitudeHold, AltitudeHoldButtonHovered, ButtonAltitudeHoldX, ButtonAltitudeHoldY, ButtonAltitudeHoldWidth, ButtonAltitudeHoldHeight, "#42006b", defaultColor, "Disable Altitude Hold", "Enable Altitude Hold")

    -- Takeoff button
    draw(newContent, AutoTakeoff, TakeoffButtonHovered, ButtonTakeoffX, ButtonTakeoffY, ButtonTakeoffWidth, ButtonTakeoffHeight, "#42006b", defaultColor, "Cancel Takeoff", "Begin Takeoff")

    -- Landing button
    draw(newContent, AutoLanding, LandingButtonHovered, ButtonLandingX, ButtonLandingY, ButtonLandingWidth, ButtonLandingHeight, "#42006b", defaultColor, "Cancel Landing", "Begin Landing")

    -- TurnBurn button
    draw(newContent, TurnBurn, TurnBurnButtonHovered, ButtonTurnBurnX, ButtonTurnBurnY, ButtonTurnBurnWidth, ButtonTurnBurnHeight, "#42006b", defaultColor, "Disable Turn&Burn", "Enable Turn&Burn")

    -- FollowMode button
    draw(newContent, FollowMode, FollowModeButtonHovered, ButtonFollowModeX, ButtonFollowModeY, ButtonFollowModeWidth, ButtonFollowModeHeight, "#42006b", defaultColor, "Disable Follow Mode", "Enable Follow Mode")
end

function DrawTank(newContent, updateTanks, x, nameSearchPrefix, nameReplacePrefix, tankTable, fuelTimeLeftTable, fuelPercentTable)                
    local tankID = 1
    local tankName = 2
    local tankMaxVol = 3
    local tankMassEmpty = 4
    local tankLastMass = 5
    local tankLastTime = 6

    local y1 = 350
    local y2 = 360
    if Nav.control.isRemoteControlled() == 1 then
        y1 = y1-50
        y2 = y2-50
    end

    if (#tankTable > 0) then
        for i = 1, #tankTable do
            if updateTanks or fuelTimeLeftTable[i] == nil or fuelPercentTable[i] == nil then
                local fuelMassMax = 0
                local fuelMassLast = 0
                local fuelMass = 0
                local fuelLastTime = 0
                local curTime = system.getTime()
                fuelMass = (core.getElementMassById(tankTable[i][tankID])-tankTable[i][tankMassEmpty])
                fuelMassMax = tankTable[i][tankMaxVol]
                fuelPercentTable[i] = mfloor(fuelMass*100/fuelMassMax)
                fuelMassLast = tankTable[i][tankLastMass]
                fuelLastTime = tankTable[i][tankLastTime]
                if fuelMassLast <= fuelMass then
                    fuelTimeLeftTable[i] = 0
                else
                    fuelTimeLeftTable[i] = mfloor(fuelMass / ((fuelMassLast - fuelMass) / (curTime - fuelLastTime)))
                end
                tankTable[i][tankLastMass] = fuelMass
                tankTable[i][tankLastTime] = curTime
            end
            local name = string.sub(tankTable[i][tankName], 1, 12)
            if name == nameSearchPrefix then 
                name = stringf("%s %d", nameReplacePrefix, i)
            end
            local fuelTimeDisplay
            if fuelTimeLeftTable[i] == 0 then 
                fuelTimeDisplay = "n/a" 
            else
                fuelTimeDisplay = FormatTimeString(fuelTimeLeftTable[i])
            end
            if fuelPercentTable[i] ~= nil then
                local colorMod = mfloor(fuelPercentTable[i]*2.55)
                local color = stringf("rgb(%d,%d,%d)", 255-colorMod, colorMod, 0)
                if ((fuelTimeDisplay ~= "n/a" and fuelTimeLeftTable[i] < 120) or fuelPercentTable[i] < 5) then
                    if updateTanks then 
                        if titlecol == rgbO then
                            titlecol = "rgb(255,0,0)"
                        else
                            titlecol = rgbO
                        end
                    end
                end
                newContent[#newContent + 1] = stringf([[
                    <g class="text">
                        <g font-size=11>
                            <text x=%d y="%d" text-anchor="start" style="fill:%s">%s</text>
                            <text x=%d y="%d" text-anchor="start" style="fill:%s">%d%% %s</text>
                        </g>
                    </g>]], x, y1, titlecol, name, x, y2, color, fuelPercentTable[i], fuelTimeDisplay)
                y1 = y1+30
                y2 = y2+30
            end
        end
    end
end

function HideInterplanetaryPanel()
    system.destroyWidgetPanel(panelInterplanetary)
    panelInterplanetary = nil
end

function ToggleTurnBurn()
    TurnBurn = not TurnBurn
end

function ToggleAltitudeHold()
        AltitudeHold = not AltitudeHold
        if AltitudeHold then
            AutoBrake = false
            Autopilot = false
            ProgradeIsOn = false
            RetrogradeIsOn = false
            if not FollowMode then
                OldAutoRoll = autoRoll
            end
            FollowMode = false
            AutoLanding = false
            autoRoll = true
            if (not gearExtended and not BrakeIsOn) or atmosphere() == 0 then -- Never autotakeoff in space
                AutoTakeoff = false
                HoldAltitude = core_altitude
                if Nav.axisCommandManager:getAxisCommandType(0) == 0 then
                    Nav.control.cancelCurrentControlMasterMode()
                end
            else
                AutoTakeoff = true
                HoldAltitude = core_altitude + AutoTakeoffAltitude
                gearExtended = false
                Nav.control.retractLandingGears()
                Nav.axisCommandManager:setTargetGroundAltitude(500)
                BrakeIsOn = true -- Engage brake for warmup
            end
        else
            autoRoll = OldAutoRoll
            AutoTakeoff = false
            AutoLanding = false
        end
end  

-- HUD - https://github.com/Rezoix/DU-hud with major modifications by Archeageo
function updateHud(newContent)

    local altitude = core_altitude
    local velocity = core.getVelocity()
    local speed = vec3(velocity):len()
    local worldV = vec3(core.getWorldVertical())
    local constrF = vec3(core.getConstructWorldOrientationForward())
    local constrR = vec3(core.getConstructWorldOrientationRight())
    local constrV = vec3(core.getConstructWorldOrientationUp())
    local pitch = getPitch(worldV, constrF, constrR)--180 - getRoll(worldV, constrR, constrF)
    local roll = getRoll(worldV, constrF, constrR) --getRoll(worldV, constrF, constrR)
    local originalRoll = roll
    local originalPitch = mfloor(pitch)
    local bottomText = "ROLL"
    local grav = core.getWorldGravity()
    local gravity = vec3(grav):len()
    local atmos = atmosphere()
    local throt = mfloor(unit.getThrottle())
    local spd = speed*3.6
    local flightValue = unit.getAxisCommandValue(0)
    local flightStyle = GetFlightStyle()
    rgbO = rgb
    rgbdimO = rgbdim
    rgbdimmerO = rgbdimmer
    if system.isViewLocked() == 0 and userControlScheme ~= "Keyboard" and Nav.control.isRemoteControlled() == 0 and not brightHud then
            rgb = [[rgb(]] .. mfloor(PrimaryR *0.4 + 0.5) .. "," .. mfloor(PrimaryG * 0.4 + 0.5) .. "," .. mfloor(PrimaryB * 0.3 + 0.5) .. [[)]]
            rgbdim = [[rgb(]] .. mfloor(PrimaryR *0.3 + 0.5) .. "," .. mfloor(PrimaryG * 0.3 + 0.5) .. "," .. mfloor(PrimaryB * 0.2 + 0.5) .. [[)]]
            rgbdimmer = [[rgb(]] .. mfloor(PrimaryR *0.2 + 0.5) .. "," .. mfloor(PrimaryG * 0.2 + 0.5) .. "," .. mfloor(PrimaryB * 0.1 + 0.5) .. [[)]]
    end

    if (atmos == 0) then
        if (speed > 5) then
            pitch = getRelativePitch(velocity)
            roll = getRelativeYaw(velocity)
        else
            pitch = 0
            roll = 0
        end
        bottomText = "YAW"
    end

    -- SVG START

    newContent[#newContent + 1] = stringf([[
    <head>
        <style>
            body {margin: 0}
            svg {position:absolute; top:0; left:0} 
            .majorLine {stroke:%s;stroke-width:3;fill:none;}
            .minorLine {stroke:%s;stroke-width:3;fill:none;}
            .text {fill:%s;font-family:Montserrat;font-weight:bold}
        </style>
    </head>
    <body>
        <svg height="100vh" width="100vw" viewBox="0 0 1920 1080">
        ]], rgbO, rgb, rgbdimmer)
    
    -- CRUISE/ODOMETER

    newContent[#newContent + 1] = LastOdometerOutput

    -- DAMAGE

    newContent[#newContent + 1] = damageMessage

    -- RADAR

    newContent[#newContent + 1] = radarMessage
    
    -- FUEL TANKS
    
    if (UpdateCount % FuelUpdateDelay == 0) then updateTanks = true end
    
    DrawTank(newContent, updateTanks, 1700, "Atmospheric ", "ATMO", atmoTanks, fuelTimeLeft, fuelPercent)
    DrawTank(newContent, updateTanks, 1800, "Space fuel t", "SPACE", spaceTanks, fuelTimeLeftS, fuelPercentS)
    DrawTank(newContent, updateTanks, 1600, "Rocket fuel ", "ROCKET", rocketTanks, fuelTimeLeftR, fuelPercentR)

    if updateTanks then
        updateTanks = false
        UpdateCount = 0
    end
    UpdateCount = UpdateCount + 1

    -- PRIMARY FLIGHT INSTRUMENTS

    DrawVerticalSpeed(newContent, altitude, atmos) -- Weird this is draw during remote control...?
    
    if Nav.control.isRemoteControlled() == 0 then     
        DrawThrottle(newContent, flightStyle, throt, flightValue)                   
        DrawPitchDisplay(newContent, pitch)
        -- Don't even draw this in freelook
        if rgb == rgbO then
            DrawArtificialHorizon(newContent, originalPitch, originalRoll, atmos)
        end
        DrawRollDisplay(newContent, roll, bottomText)
        DrawAltitudeDisplay(newContent, altitude, atmos)
    end   

    -- PRIMARY DATA DISPLAYS

    DrawSpeedGravityAtmosphere(newContent, spd, gravity, atmos)                          

    -- After the HUD, set RGB values back to undimmed even if view is unlocked
    rgb = rgbO
    rgbdim = rgbdimO
    rgbdimmer = rgbdimmerO
    DrawWarnings(newContent)                    
    DisplayOrbit(newContent)                
    newContent[#newContent + 1] = [[</svg>]]
    if screen_2 then
        local pos = vec3(core.getConstructWorldPos())
        local x = 960+pos.x/MapXRatio
        local y = 450+pos.y/MapYRatio
        screen_2.moveContent(YouAreHere, (x-80)/19.2, (y-80)/10.8)
    end
end

function DrawSpeedGravityAtmosphere(newContent, spd, gravity, atmos)
    local ys1 = 375
    local ys2 = 390
    local xg = 1200
    local yg1 = 710
    local yg2 = 720
    if Nav.control.isRemoteControlled() == 1 then
        ys1 = 60
        ys2 = 75
        xg = 1120
        yg1 = 55
        yg2 = 65
    else -- We only show atmo when not remote
        newContent[#newContent + 1] = stringf([[
            <text x="770" y="710" text-anchor="end">ATMOSPHERE</text>
            <text x="770" y="720" text-anchor="end">%.2f m</text>
        </g>]], atmos)
    end
    newContent[#newContent + 1] = stringf([[
        <g class="text">
            <g font-size=10>
                <text x="960" y="%d" text-anchor="middle" style="fill:%s">SPEED</text>
                <text x="960" y="%d" text-anchor="middle" style="fill:%s;font-size:14;">%d km/h</text>
                <text x="%d" y="%d" text-anchor="end">GRAVITY</text>
                <text x="%d" y="%d" text-anchor="end">%.2f m/s2</text>
            </g>
        </g>]], ys1, rgbO, ys2, rgbO, mfloor(spd), xg, yg1, xg, yg2, gravity)
end

function DrawOdometer(newContent, totalDistanceTrip, totalDistanceTravelled, flightStyle, flightTime)
    local maxBrake = jdecode(unit.getData()).maxBrake
    if maxBrake ~= nil then LastMaxBrake = maxBrake end
    maxThrust = Nav:maxForceForward()
    totalMass = constructMass()
    newContent[#newContent + 1] = [[<g class="majorLine">
            <path d="M 700 0 L 740 35 Q 960 55 1180 35 L 1220 0"/>
        </g>]]

    if Nav.control.isRemoteControlled() == 0 then
        newContent[#newContent + 1] = stringf([[
            <g class="text">
                <g font-size=15>
                    <text x="960" y="20" text-anchor="middle" style="fill:%s;font-size:10;">Trip Time: %s</text>
                    <text x="960" y="30" text-anchor="middle" style="fill:%s;font-size:10;">Total Time: %s</text>
                    <text x="740" y="20" text-anchor="start" style="fill:%s;font-size:10;">Trip: %.2f km</text>
                    <text x="740" y="30" text-anchor="start" style="fill:%s;font-size:10;">Lifetime: %.2f Mm</text>
                    <text x="1180" y="20" text-anchor="end" style="fill:%s;font-size:10;">Max Thrust: %.2f kN</text>
                    <text x="1180" y="30" text-anchor="end" style="fill:%s;font-size:10;">Max Brake: %.2f kN</text>
                    <text x="1180" y="10" text-anchor="end" style="fill:%s;font-size:10;">Mass: %.2f Tons</text>
                    <text x="960" y="360" text-anchor="middle" style="fill:%s">%s</text>
                </g>
            </g>]], rgbO, FormatTimeString(flightTime), rgbO, FormatTimeString(totalFlightTime), rgbO, totalDistanceTrip, rgbO, (totalDistanceTravelled/1000), rgbO, (maxThrust/1000), rgbO, (LastMaxBrake/1000), rgbO, (totalMass/1000), rgbO, flightStyle)
    else -- If remote controlled, draw stuff near the top so it's out of the way
        newContent[#newContent + 1] = stringf([[
            <g class="text">
                <g font-size=15>
                    <text x="960" y="33" text-anchor="middle" style="fill:%s">%s</text>
                </g>
            </g>]], rgbO, flightStyle)
    end
end

function DrawThrottle(newContent, flightStyle, throt, flightValue)
    newContent[#newContent + 1] = stringf([[
        <g class="minorLine">
            <path d="M 792 550 L 785 550 L 785 650 L 792 650"/>
        </g>
        <g>
            <polygon points="1138,540 1120,535 1120,545" style="fill:%s"/>
        </g>]], rgb)
    newContent[#newContent + 1] = stringf([[<g transform="translate(0 %d)">
        <polygon points="798,650 810,647 810,653" style="fill:%s;"/></g>]], (1-throt), rgbdim)

    local y1 = 665
    local y2 = 675
    if Nav.control.isRemoteControlled() == 1 then
        y1 = 55
        y2 = 65
    end

    if (flightStyle == "TRAVEL" or flightStyle == "AUTOPILOT") then
        newContent[#newContent + 1] = stringf([[
            <g class="text">
                <g font-size=10>
                    <text x="783" y="%d" text-anchor="start" style="fill:%s">THROT</text>
                    <text x="783" y="%d" text-anchor="start" style="fill:%s">%d%%</text>
                </g>
            </g>]], y1, rgbO, y2, rgbO, throt)
    else
            newContent[#newContent + 1] = stringf([[
            <g class="text">
                <g font-size=10>
                    <text x="783" y="%d" text-anchor="start" style="fill:%s">CRUISE</text>
                    <text x="783" y="%d" text-anchor="start" style="fill:%s">%d km/h</text>
                </g>
            </g>]], y1, rgbO, y2, rgbO, flightValue)
    end
end

-- Draw vertical speed indicator - Code by lisa-lionheart 
function DrawVerticalSpeed(newContent, altitude, atmos) 
    if (altitude < 200000 and atmos == 0 ) or (altitude and atmos > 0) then 
        local velocity = vec3(core.getWorldVelocity())
        local up = vec3(core.getWorldVertical()) * -1
        local vSpd = (velocity.x * up.x) + (velocity.y * up.y) + (velocity.z * up.z)
        local angle = 0       
        if math.abs(vSpd) > 1 then
            angle = 45 * math.log(math.abs(vSpd), 10)      
            if vSpd < 0 then
                angle = -angle
            end                                
        end
        newContent[#newContent + 1] =  stringf([[
            <g transform="translate(1525 250) scale(0.6)">
                <g font-size="14px" font-family="sans-serif" fill="%s">
                    <text x="31" y="-41">1000</text>
                    <text x="-10" y="-65">100</text>
                    <text x="-54" y="-45">10</text>
                    <text x="-73" y="3">O</text>
                    <text x="-56" y="52">-10</text>
                    <text x="-14" y="72">-100</text>
                    <text x="29" y="50">-1000</text>
                    <text x="85" y="0" font-size="20px" text-anchor="end" >%d m/s</text>
                </g>
                <g fill="none" stroke="%s" stroke-width="3px">
                    <path d="m-41 75 2.5-4.4m17 12 1.2-4.9m20 7.5v-10m-75-34 4.4-2.5m-12-17 4.9-1.2m17 40 7-7m-32-53h10m34-75 2.5 4.4m17-12 1.2 4.9m20-7.5v10m-75 34 4.4 2.5m-12 17 4.9 1.2m17-40 7 7m-32 53h10m116 75-2.5-4.4m-17 12-1.2-4.9m40-17-7-7m-12-128-2.5 4.4m-17-12-1.2 4.9m40 17-7 7"/>
                    <circle r="90" />
                </g>
                <path transform="rotate(%d)" fill="%s" d="m-0.094-7c-22 2.2-45 4.8-67 7 23 1.7 45 5.6 67 7 4.4-0.068 7.8-4.9 6.3-9.1-0.86-2.9-3.7-5-6.8-4.9z" />
            </g>
        ]], rgbO, mfloor(vSpd), rgbO, mfloor(angle), rgbO)
    end
end

function DrawPitchDisplay(newContent, pitch)
    -- PITCH DISPLAY
    local pitchC = mfloor(pitch)
    local len = 0
    for i = mfloor(pitchC-25-pitchC%5+0.5),mfloor(pitchC+25+pitchC%5+0.5),5 do
        if (i%10==0) then
            num = i
            if (num > 180) then
                num = -180 + (num-180)
            elseif (num < -180) then
                num = 180 + (num+180)
            end
            newContent[#newContent + 1] = stringf([[
                <g transform="translate(0 %f)">
                    <text x="1180" y="540" style="fill:%s;text-anchor:start;font-size:12;font-family:Montserrat;font-weight:bold">%d</text></g>]], (-i*5 + pitch*5 + 5), rgbdim, num)
        end
        if (i%10==0) then
            len = 30
        elseif (i%5==0) then
            len = 20
        else
            len = 7
        end
        newContent[#newContent + 1] = stringf([[
            <g transform="translate(0 %f)">
                <line x1="%d" y1="540" x2="1140" y2="540"style="stroke:%s;stroke-width:2"/></g>]], (-i*5 + pitch*5), (1140+len), rgbdim)
    end
    newContent[#newContent + 1] = stringf([[
        <g class="text">
            <g font-size=10>
                <text x="1180" y="380" text-anchor="end" style="fill:%s">PITCH</text>
                <text x="1180" y="390" text-anchor="end" style="fill:%s">%d deg</text>
            </g>
        </g>
    ]], rgbdimmerO, rgbdimmerO, pitchC)
end

function DrawAltitudeDisplay(newContent, altitude, atmos)
    if (altitude < 200000 and atmos == 0 ) or (altitude and atmos > 0) then    
        newContent[#newContent + 1] = stringf([[
        <g>
            <polygon points="782,540 800,535 800,545" style="fill:%s"/>
        </g>
        <g class="text">
        <g font-size=10>
            <text x="770" y="380" text-anchor="end" style="fill:%s">ALTITUDE</text>
            <text x="770" y="390" text-anchor="end" style="fill:%s">%d m</text>
            ]], rgb, rgbdimmerO, rgbdimmerO, mfloor(altitude))

        newContent[#newContent + 1] = stringf([[
            <text x="770" y="710" text-anchor="end">ATMOSPHERE</text>
            <text x="770" y="720" text-anchor="end">%.2f m</text>
        </g>
        </g>]], atmos)

            -- Many thanks to Nistus on Discord for his assistance with the altimeter.
        local altC = mfloor((altitude)/10)
        local num = 0
        local len = 0
        for i = mfloor(altC-25-altC%5+0.5),mfloor(altC+25+altC%5+0.5),5 do
            if (i%10==0) then
                num = i*10
                newContent[#newContent + 1] = stringf([[<g transform="translate(0 %f)">
                    <text x="745" y="540" style="fill:%s;text-anchor:end;font-size:12;font-family:Montserrat;font-weight:bold">%d</text></g>]], (-i*5 + altitude*.5+5), rgbdim, num)
            end
            len = 5
            if (i%10==0) then
                len = 30
            elseif (i%5==0) then
                len = 15
            end
            newContent[#newContent + 1] = stringf([[
                <g transform="translate(0 %f)">
                <line x1="%d" y1="540" x2="780" y2="540"style="stroke:%s;stroke-width:2"/></g>]], (-i*5 + altitude*.5), (780-len), rgbdimmer)
        end
    end
end


function DrawArtificialHorizon(newContent, originalPitch, originalRoll, atmos)
    --** CIRCLE ALTIMETER  - Base Code from Discord @Rainsome = Youtube CaptainKilmar** 
    local horizonRadius = circleRad -- Aliased global
    if horizonRadius > 0 and unit.getClosestPlanetInfluence() > 0 then
        if originalPitch > 90 and atmos == 0 then
            originalPitch = 90-(originalPitch-90)
        elseif originalPitch < -90 and atmos == 0 then
            originalPitch = -90 - (originalPitch+90)
        end
        newContent[#newContent + 1] = stringf([[
            <circle r="%f" cx="960" cy="540" opacity="0.1" fill="#0083cb" stroke="black" stroke-width="2"/>
                <clipPath id="cut"><circle r="%f" cx="960" cy="540"/></clipPath>
                <rect x="%f" y="%f" height="%f" width="%f" opacity="0.3" fill="#6b5835" clip-path="url(#cut)" transform="rotate(%f 960 540)"/>]], horizonRadius, (horizonRadius-1), (960-horizonRadius), (540 + horizonRadius*(originalPitch/90)),(horizonRadius*2), (horizonRadius*2), (-1*originalRoll))
        
    end
end

function DrawRollDisplay(newContent, roll, bottomText)
    local rollC = mfloor(roll)
    newContent[#newContent + 1] = stringf([[
        <g class="text">
        <g font-size=10>
        <text x="960" y="688" text-anchor="middle" style="fill:%s">%s</text>
        <text x="960" y="698" text-anchor="middle" style="fill:%s">%d deg</text>]],rgbdimmerO, bottomText, rgbdimmerO, mfloor(roll))
    newContent[#newContent + 1] = stringf([[<g>
        <polygon points="960,725 955,707 965,707" style="fill:%s"/>
        </g>]], rgb)

    local sign = 0
    local num = 0
    local len = 0
    for i = mfloor(rollC-30-rollC%5+0.5),mfloor(rollC+30+rollC%5+0.5),5 do
        if (i%10==0) then
            sign = i/math.abs(i)
            if i == 0 then
                sign = 0
            end
            num = math.abs(i)
            if (num > 180) then
                num = 180 + (180-num) 
            end
            newContent[#newContent + 1] = stringf([[<g transform="rotate(%f,960,460)">
                <text x="960" y="760" style="fill:%s;text-anchor:middle;font-size:12;font-family:Montserrat;font-weight:bold">%d</text></g>]], (i - roll), rgbdim, mfloor(sign*num+0.5))
            end
        len = 5
        if (i%10==0) then
            len = 15
        elseif (i%5==0) then
            len = 10
        end
        newContent[#newContent + 1] = stringf([[<g transform="rotate(%f,960,460)">
            <line x1="960" y1="730" x2="960" y2="%d" style="stroke:%s;stroke-width:2"/></g>]], (i - roll), (730+len), rgbdimmer)
    end
end

function DrawWarnings(newContent)
    if unit.isMouseControlActivated() == 1 then
        newContent[#newContent + 1] = "<text x='960' y='550' font-size='26' font-weight='bold' fill='red' text-anchor='middle' font-family='Bank'>Warning: Invalid Control Scheme Detected</text>"
        newContent[#newContent + 1] = "<text x='960' y='600' font-size='26' font-weight='bold' fill='red' text-anchor='middle' font-family='Bank'>Keyboard Scheme must be selected</text>"
        newContent[#newContent + 1] = "<text x='960' y='650' font-size='26' font-weight='bold' fill='red' text-anchor='middle' font-family='Bank'>Set your preferred scheme in Lua Parameters instead</text>"
    end
    local warningX = 960
    local brakeY = 860
    local gearY = 900
    local hoverY = 930
    local apY = 225
    local turnBurnY = 150
    local gyroY = 960
    if Nav.control.isRemoteControlled() == 1 then
        brakeY = 135
        gearY = 155
        hoverY = 175
        apY = 115
        turnBurnY = 95
    end
    if BrakeIsOn then
        newContent[#newContent + 1] = stringf("<text x='%d' y='%d' font-size='26' font-weight='bold' fill='red' text-anchor='middle' font-family='Bank'>Brake Engaged</text>",warningX, brakeY)
    end
    if GyroIsOn then
        newContent[#newContent + 1] = stringf("<text x='%d' y='%d' font-size='26' font-weight='bold' fill='red' text-anchor='middle' font-family='Bank'>Gyro Enabled</text>",warningX, gyroY)
    end
    if gearExtended then
        if hasGear then 
            newContent[#newContent + 1] = stringf("<text x='%d' y='%d' font-size='24' fill='orange' text-anchor='middle' font-family='Bank'>Gear Extended</text>", warningX, gearY)
        else
            newContent[#newContent + 1] = stringf("<text x='%d' y='%d' font-size='26' font-weight='bold' fill='red' text-anchor='middle' font-family='Bank'>Landed (G: Takeoff)</text>", warningX, gearY)
        end
        newContent[#newContent + 1] = stringf("<text x='%d' y='%d' font-size='24' fill='orange' text-anchor='middle' font-family='Bank'>Hover Height: %s</text>", warningX, hoverY, getDistanceDisplayString(Nav:getTargetGroundAltitude()))
    end
    if AutoBrake and AutopilotTargetPlanetName ~= "None" then
        if brakeInput == 0 then
            newContent[#newContent + 1] = stringf("<text x='%d' y='%d' font-size='26' font-weight='bold' fill='orange' text-anchor='middle' font-family='Bank'>Auto-Braking when within %s of %s</text>", warningX, apY, getDistanceDisplayString(maxBrakeDistance), AutopilotTargetPlanet.name)
        else
            newContent[#newContent + 1] = stringf("<text x='%d' y='%d' font-size='26' font-weight='bold' fill='orange' text-anchor='middle' font-family='Bank'>Auto-Braking until eccentricity: %f begins to increase</text>",warningX, apY, round(orbit.eccentricity,2))
        end
    elseif Autopilot and AutopilotTargetPlanetName ~= "None" then
        newContent[#newContent + 1] = stringf("<text x='%d' y='%d' font-size='26' font-weight='bold' fill='orange' text-anchor='middle' font-family='Bank'>Autopilot %s</text>",warningX, apY, AutopilotStatus)
    elseif FollowMode then
        newContent[#newContent + 1] = stringf("<text x='%d' y='%d' font-size='26' font-weight='bold' fill='orange' text-anchor='middle' font-family='Bank'>Follow Mode Engaged</text>", warningX, apY)
    elseif AltitudeHold then
        if AutoLanding then
            newContent[#newContent + 1] = stringf("<text x='%d' y='%d' font-size='26' font-weight='bold' fill='red' text-anchor='middle' font-family='Bank'>Auto-Landing</text>", warningX, apY)
        elseif AutoTakeoff then
            newContent[#newContent + 1] = stringf("<text x='%d' y='%d' font-size='26' font-weight='bold' fill='orange' text-anchor='middle' font-family='Bank'>Ascent to %s</text>",warningX, apY, getDistanceDisplayString(HoldAltitude))
            if BrakeIsOn then
                newContent[#newContent + 1] = stringf("<text x='%d' y='%d' font-size='28' fill='darkred' text-anchor='middle' font-family='Bank'>Throttle Up and Disengage Brake For Takeoff</text>", warningX, apY + 50)
            end
        else
            newContent[#newContent + 1] = stringf("<text x='%d' y='%d' font-size='26' font-weight='bold' fill='orange' text-anchor='middle' font-family='Bank'>Altitude Hold: %s</text>", warningX, apY, getDistanceDisplayString2(HoldAltitude))
        end
    end
    if TurnBurn then
        newContent[#newContent + 1] = stringf("<text x='%d' y='%d' font-size='26' font-weight='bold' fill='darkred' text-anchor='middle' font-family='Bank'>Turn & Burn Braking</text>", warningX, turnBurnY)
    end
end

function DisplayOrbit(newContent)
    if orbit ~= nil and atmosphere() < 0.2 and planet ~= nil then
        -- If orbits are up, let's try drawing a mockup
        local orbitMapX = 75
        local orbitMapY = 0
        local orbitMapSize = 250 -- Always square
        local pad = 4
        orbitMapY = orbitMapY + pad                        
        local orbitInfoYOffset = 15
        local x = orbitMapX + orbitMapSize + orbitMapX/2 + pad
        local y = orbitMapY + orbitMapSize/2 + 5 + pad
        
        local rx, ry, scale, xOffset
        rx = orbitMapSize/4
        xOffset = 0
        
        -- Draw a darkened box around it to keep it visible
        newContent[#newContent + 1] = stringf('<rect width="%f" height="%d" rx="10" ry="10" x="%d" y="%d" style="fill:rgb(0,0,100);stroke-width:4;stroke:white;fill-opacity:0.3;" />', orbitMapSize+orbitMapX*2, orbitMapSize+orbitMapY, pad, pad)

        if orbit.periapsis ~= nil and orbit.apoapsis ~= nil then
            scale = (orbit.apoapsis.altitude + orbit.periapsis.altitude + planet.radius*2)/(rx*2)
            ry = (planet.radius + orbit.periapsis.altitude + (orbit.apoapsis.altitude - orbit.periapsis.altitude)/2)/scale * (1-orbit.eccentricity)
            xOffset = rx - orbit.periapsis.altitude/scale - planet.radius/scale
            
            local ellipseColor = rgbdim
            if orbit.periapsis.altitude <= 0 then
                ellipseColor = 'red'
            end
            newContent[#newContent + 1] = stringf('<ellipse cx="%f" cy="%f" rx="%f" ry="%f" style="fill:none;stroke:%s;stroke-width:2" />', orbitMapX + orbitMapSize/2 + xOffset + pad, orbitMapY + orbitMapSize/2 + pad, rx, ry, ellipseColor)
            newContent[#newContent + 1] = stringf('<circle cx="%f" cy="%f" r="%f" stroke="white" stroke-width="3" fill="blue" />', orbitMapX + orbitMapSize/2 + pad, orbitMapY + orbitMapSize/2 + pad, planet.radius/scale) 
        end
        
        if orbit.apoapsis ~= nil then
            newContent[#newContent + 1] = stringf([[<line x1="%f" y1="%f" x2="%f" y2="%f"style="stroke:%s;opacity:0.3;stroke-width:3"/>]],x - 35, y-5, orbitMapX + orbitMapSize/2 + rx + xOffset, y-5, rgbdim)
            newContent[#newContent + 1] = stringf("<text x='%f' y='%f' font-size='14' fill=%s text-anchor='middle' font-family='Montserrat'>Apoapsis</text>", x, y, rgb)
            y  = y + orbitInfoYOffset
            newContent[#newContent + 1] = stringf("<text x='%f' y='%f' font-size='12' fill=%s text-anchor='middle' font-family='Montserrat'>%s</text>", x, y, rgbdimmer,  getDistanceDisplayString(orbit.apoapsis.altitude))
            y  = y + orbitInfoYOffset
            newContent[#newContent + 1] = stringf("<text x='%f' y='%f' font-size='12' fill=%s text-anchor='middle' font-family='Montserrat'>%s</text>", x, y, rgbdimmer, FormatTimeString(orbit.timeToApoapsis))
            y  = y + orbitInfoYOffset
            newContent[#newContent + 1] = stringf("<text x='%f' y='%f' font-size='12' fill=%s text-anchor='middle' font-family='Montserrat'>%s</text>", x, y, rgbdimmer, getSpeedDisplayString(orbit.apoapsis.speed))
        end
        
        y = orbitMapY + orbitMapSize/2 + 5 + pad
        x = orbitMapX - orbitMapX/2+10 + pad
        
        if orbit.periapsis ~= nil then
            newContent[#newContent + 1] = stringf("<text x='%f' y='%f' font-size='14' fill=%s text-anchor='middle' font-family='Montserrat'>Periapsis</text>", x, y, rgb)
            newContent[#newContent + 1] = stringf([[<line x1="%f" y1="%f" x2="%f" y2="%f"style="stroke:%s;opacity:0.3;stroke-width:3"/>]], x + 35, y-5, orbitMapX + orbitMapSize/2 - rx + xOffset, y-5, rgbdim)
            y  = y + orbitInfoYOffset
            newContent[#newContent + 1] = stringf("<text x='%f' y='%f' font-size='12' fill=%s text-anchor='middle' font-family='Montserrat'>%s</text>", x, y, rgbdimmer, getDistanceDisplayString(orbit.periapsis.altitude))
            y  = y + orbitInfoYOffset
            newContent[#newContent + 1] = stringf("<text x='%f' y='%f' font-size='12' fill=%s text-anchor='middle' font-family='Montserrat'>%s</text>", x, y, rgbdimmer, FormatTimeString(orbit.timeToPeriapsis))
            y  = y + orbitInfoYOffset
            newContent[#newContent + 1] = stringf("<text x='%f' y='%f' font-size='12' fill=%s text-anchor='middle' font-family='Montserrat'>%s</text>", x, y, rgbdimmer, getSpeedDisplayString(orbit.periapsis.speed))
            
        end
        
        -- Add a label for the planet
        newContent[#newContent + 1] = stringf("<text x='%f' y='%d' font-size='18' fill=%s text-anchor='middle' font-family='Montserrat'>%s</text>", orbitMapX + orbitMapSize/2 + pad, 20 + pad, rgb, planet.name)

        if orbit.period ~= nil and orbit.periapsis ~= nil and orbit.apoapsis ~= nil then
            local apsisRatio = (orbit.timeToApoapsis/orbit.period) * 2 * math.pi
            -- x = xr * cos(t)
            -- y = yr * sin(t)
            local shipX = rx * math.cos(apsisRatio)
            local shipY = ry * math.sin(apsisRatio)
            
            newContent[#newContent + 1] = stringf('<circle cx="%f" cy="%f" r="5" stroke="white" stroke-width="3" fill="white" />', orbitMapX + orbitMapSize/2 + shipX + xOffset + pad, orbitMapY + orbitMapSize/2 + shipY + pad)
        end
        -- Once we have all that, we should probably rotate the entire thing so that the ship is always at the bottom so you can see AP and PE move?
        
    end
end

function GetFlightStyle()
    local flightType = Nav.axisCommandManager:getAxisCommandType(0)
    local flightStyle = "TRAVEL"
    if (flightType == 1) then
        flightStyle = "CRUISE"
    end
    if Autopilot then
        flightStyle = "AUTOPILOT"
    end
    return flightStyle
end
