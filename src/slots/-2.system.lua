
do -- !DU: actionStart([option8])
    toggleFollowMode()
end -- !DU: end

do -- !DU: actionStart([option7])
    saveVariables()
end -- !DU: end

do -- !DU: actionStart([option6])
    ToggleAltitudeHold()
end -- !DU: end

do -- !DU: actionStart([option5])
    ToggleTurnBurn()
end -- !DU: end

do -- !DU: actionStart([option4])
    AutopilotToggle()
end -- !DU: end

do -- !DU: actionStop([brake])
    if not brakeToggle then 
        if BrakeIsOn then
            BrakeToggle()
        else
            BrakeIsOn = false -- Should never happen
        end
    end
end -- !DU: end

do -- !DU: actionStart([brake])
    if brakeToggle then 
        BrakeToggle()
    elseif not BrakeIsOn then
        BrakeToggle() -- Trigger the cancellations
    else
        BrakeIsOn = true -- Should never happen
    end
end -- !DU: end

do -- !DU: actionStart([warp])
    if warpdrive ~= nil then warpdrive.activateWarp() end
end -- !DU: end

do -- !DU: actionStart([antigravity])
    if antigrav ~= nil then 
        antigrav.toggle() 
    end
end -- !DU: end

do -- !DU: actionLoop([speeddown])
    if not HoldingCtrl then 
        Nav.axisCommandManager:updateCommandFromActionLoop(axisCommandId.longitudinal, -speedChangeSmall)
    end
end -- !DU: end

do -- !DU: actionStart([booster])
    --Nav:toggleBoosters()
    -- Dodgin's Don't Die Rocket Govenor - Cruise Control Edition
    isboosting = not isboosting
    if(isboosting) then unit.setEngineThrust('rocket_engine',1)
    else unit.setEngineThrust('rocket_engine',0)
    end
end -- !DU: end

do -- !DU: actionStart([speedup])
    if not HoldingCtrl then 
        Nav.axisCommandManager:updateCommandFromActionStart(axisCommandId.longitudinal, speedChangeLarge)
    else
        IncrementAutopilotTargetIndex()
    end
end -- !DU: end

do -- !DU: actionLoop([speedup])
    if not HoldingCtrl then 
        Nav.axisCommandManager:updateCommandFromActionLoop(axisCommandId.longitudinal, speedChangeSmall)
    end
end -- !DU: end

do -- !DU: actionStart([speeddown])
    if not HoldingCtrl then 
        Nav.axisCommandManager:updateCommandFromActionStart(axisCommandId.longitudinal, -speedChangeLarge)
    else
        DecrementAutopilotTargetIndex()
    end
end -- !DU: end

do -- !DU: actionStart([stopengines])
    Nav.axisCommandManager:resetCommand(axisCommandId.longitudinal)
end -- !DU: end

do -- !DU: actionStart([option9])
    if gyro ~= nil then
        gyro.toggle()
        GyroIsOn = gyro.getState() == 1
    end
end -- !DU: end

do -- !DU: actionStart([down])
    upAmount = upAmount - 1
    Nav.axisCommandManager:deactivateGroundEngineAltitudeStabilization()
    Nav.axisCommandManager:updateCommandFromActionStart(axisCommandId.vertical, -1.0)
end -- !DU: end

do -- !DU: actionStart([groundaltitudeup])
    OldButtonMod = HoldAltitudeButtonModifier
    if AltitudeHold then
        HoldAltitude = HoldAltitude + HoldAltitudeButtonModifier
    else
        Nav.axisCommandManager:updateTargetGroundAltitudeFromActionStart(1.0)
    end
end -- !DU: end

do -- !DU: actionStop([down])
    upAmount = upAmount + 1
    Nav.axisCommandManager:updateCommandFromActionStop(axisCommandId.vertical, 1.0)
    Nav.axisCommandManager:activateGroundEngineAltitudeStabilization(currentGroundAltitudeStabilization)
end -- !DU: end

do -- !DU: actionStop([groundaltitudeup])
    if AltitudeHold then
        HoldAltitudeButtonModifier = OldButtonMod
    end
end -- !DU: end

do -- !DU: actionLoop([groundaltitudeup])
    if AltitudeHold then
        HoldAltitude = HoldAltitude + HoldAltitudeButtonModifier
        HoldAltitudeButtonModifier = HoldAltitudeButtonModifier * 1.05
    else
        Nav.axisCommandManager:updateTargetGroundAltitudeFromActionLoop(1.0)
    end
end -- !DU: end

do -- !DU: actionStart([groundaltitudedown])
    OldButtonMod = HoldAltitudeButtonModifier
    if AltitudeHold then
        HoldAltitude = HoldAltitude - HoldAltitudeButtonModifier
    else
        Nav.axisCommandManager:updateTargetGroundAltitudeFromActionStart(-1.0)
    end
end -- !DU: end

do -- !DU: actionLoop([groundaltitudedown])
    if AltitudeHold then
        HoldAltitude = HoldAltitude - HoldAltitudeButtonModifier
        HoldAltitudeButtonModifier = HoldAltitudeButtonModifier * 1.05
    else
        Nav.axisCommandManager:updateTargetGroundAltitudeFromActionLoop(-1.0)
    end
end -- !DU: end

do -- !DU: actionStop([groundaltitudedown])
    if AltitudeHold then
        HoldAltitudeButtonModifier = OldButtonMod
    end
end -- !DU: end

do -- !DU: actionStart([option1])
    IncrementAutopilotTargetIndex()
end -- !DU: end

do -- !DU: actionStart([option2])
    DecrementAutopilotTargetIndex()
end -- !DU: end

do -- !DU: actionStart([option3])
    if hideHudOnToggleWidgets then
        if showHud then 
            showHud = false
        else 
            showHud = true
        end
    end
    ToggleWidgets()
end -- !DU: end

do -- !DU: flush()
    flush()
end -- !DU: end

do -- !DU: start()
    function DisplayMessage(newContent, displayText)
        if displayText ~= "empty" then
            newContent[#newContent + 1] = string.format("<text x='50%%' y='355' font-size='40' fill='red' text-anchor='middle' font-family='Montserrat' style='font-weight:normal'>%s</text>", displayText)
        end
        if msgTimer ~= 0 then 
            unit.setTimer("msgTick", msgTimer)
            msgTimer = 0
        end     
    end

    function updateDistance()
        local curTime = system.getTime()
        local velocity = vec3(core.getWorldVelocity())
        local spd = vec3(velocity):len()
        local elapsedTime = curTime - lastTravelTime
        if(spd > 1.38889) then
            spd = spd / 1000
            local newDistance = spd * (curTime - lastTravelTime)
            totalDistanceTravelled = totalDistanceTravelled + newDistance
            totalDistanceTrip = totalDistanceTrip + newDistance
        end
        flightTime = flightTime + elapsedTime
        totalFlightTime = totalFlightTime + elapsedTime
        lastTravelTime = curTime
    end

    function updateMass()
        local totMass = 0
        for k in pairs(elementsID) do
            totMass = totMass + core.getElementMassById(elementsID[k])
        end
        return totMass
    end
end -- !DU: end

do -- !DU: update()
    Nav:update()
end -- !DU: end

do -- !DU: actionStart([gear])
    gearExtended = not gearExtended
    if gearExtended then
        if AltitudeHold and (vBooster or hover) and unit.getAtmosphereDensity() > 0 then -- If they extend while holding and we can get distance, land
            AutoTakeoff = false
            AutoLanding = true -- But never land from space of course
            gearExtended = false -- Don't actually do it
            Nav.axisCommandManager:setThrottleCommand(axisCommandId.longitudinal, 0)
        else
            Nav.control.extendLandingGears()
            Nav.axisCommandManager:setTargetGroundAltitude(0)
        end
    else
        Nav.control.retractLandingGears()
        Nav.axisCommandManager:setTargetGroundAltitude(TargetHoverHeight)
    end
end -- !DU: end

do -- !DU: actionStop([forward])
    pitchInput = pitchInput + 1
end -- !DU: end

do -- !DU: actionStart([light])
    if Nav.control.isAnyHeadlightSwitchedOn() == 1 then
        Nav.control.switchOffHeadlights()
    else
        Nav.control.switchOnHeadlights()
    end
end -- !DU: end

do -- !DU: actionStart([forward])
    pitchInput = pitchInput - 1
end -- !DU: end

do -- !DU: actionStart([backward])
    pitchInput = pitchInput + 1
end -- !DU: end

do -- !DU: actionStop([backward])
    pitchInput = pitchInput - 1
end -- !DU: end

do -- !DU: actionStart([right])
    rollInput = rollInput + 1
end -- !DU: end

do -- !DU: actionStart([left])
    rollInput = rollInput - 1
end -- !DU: end

do -- !DU: actionStop([left])
    rollInput = rollInput + 1
end -- !DU: end

do -- !DU: actionStart([yawright])
    yawInput = yawInput - 1
end -- !DU: end

do -- !DU: actionStop([yawright])
    yawInput = yawInput + 1
end -- !DU: end

do -- !DU: actionStop([right])
    rollInput = rollInput - 1
end -- !DU: end

do -- !DU: actionStart([straferight])
    Nav.axisCommandManager:updateCommandFromActionStart(axisCommandId.lateral, 1.0)
end -- !DU: end

do -- !DU: actionStop([yawleft])
    yawInput = yawInput - 1
end -- !DU: end

do -- !DU: actionStart([yawleft])
    yawInput = yawInput + 1
end -- !DU: end

do -- !DU: actionStop([straferight])
    Nav.axisCommandManager:updateCommandFromActionStop(axisCommandId.lateral, -1.0)
end -- !DU: end

do -- !DU: actionStart([strafeleft])
    Nav.axisCommandManager:updateCommandFromActionStart(axisCommandId.lateral, -1.0)
end -- !DU: end

do -- !DU: actionStop([strafeleft])
    Nav.axisCommandManager:updateCommandFromActionStop(axisCommandId.lateral, 1.0)
end -- !DU: end

do -- !DU: actionStop([up])
    upAmount = upAmount - 1
    Nav.axisCommandManager:updateCommandFromActionStop(axisCommandId.vertical, -1.0)
    Nav.axisCommandManager:activateGroundEngineAltitudeStabilization(currentGroundAltitudeStabilization)
end -- !DU: end

do -- !DU: actionStart([up])
    upAmount = upAmount + 1
    Nav.axisCommandManager:deactivateGroundEngineAltitudeStabilization()
    Nav.axisCommandManager:updateCommandFromActionStart(axisCommandId.vertical, 1.0)
end -- !DU: end

do -- !DU: actionStart([lalt])
    if Nav.control.isRemoteControlled() == 0 and freeLookToggle then
        if system.isViewLocked() == 1 then
            system.lockView(0)
        else
            system.lockView(1)
        end
    elseif Nav.control.isRemoteControlled() == 0 and not freeLookToggle and userControlScheme == "Keyboard" then
        system.lockView(1)
    end
end -- !DU: end

do -- !DU: actionStop([lalt])
    if Nav.control.isRemoteControlled() == 0 and not freeLookToggle and userControlScheme == "Keyboard" then
        system.lockView(0)
    end
end -- !DU: end

do -- !DU: actionStop([lshift])
    if system.isViewLocked() == 1 then
        HoldingCtrl = false
        simulatedX = 0
        simulatedY = 0 -- Reset for steering purposes
        system.lockView(PrevViewLock)
    elseif Nav.control.isRemoteControlled() == 1 and ShiftShowsRemoteButtons then
        HoldingCtrl = false
        Animated = false
        Animating = false
    end
end -- !DU: end

do -- !DU: actionStart([lshift])
    if system.isViewLocked() == 1 then
        HoldingCtrl = true
        PrevViewLock = system.isViewLocked()
        system.lockView(1)
    elseif Nav.control.isRemoteControlled() == 1 and ShiftShowsRemoteButtons then
        HoldingCtrl = true
        Animated = false
        Animating = false
    end
end -- !DU: end
