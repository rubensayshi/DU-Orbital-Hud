function flush()
    local torqueFactor = 2 -- Force factor applied to reach rotationSpeed<br>(higher value may be unstable)<br>Valid values: Superior or equal to 0.01

    -- validate params
    pitchSpeedFactor = math.max(pitchSpeedFactor, 0.01)
    yawSpeedFactor = math.max(yawSpeedFactor, 0.01)
    rollSpeedFactor = math.max(rollSpeedFactor, 0.01)
    torqueFactor = math.max(torqueFactor, 0.01)
    brakeSpeedFactor = math.max(brakeSpeedFactor, 0.01)
    brakeFlatFactor = math.max(brakeFlatFactor, 0.01)
    autoRollFactor = math.max(autoRollFactor, 0.01)
    turnAssistFactor = math.max(turnAssistFactor, 0.01)

    -- final inputs
    local finalPitchInput = pitchInput + pitchInput2 + system.getControlDeviceForwardInput()
    local finalRollInput = rollInput + rollInput2 + system.getControlDeviceYawInput()
    local finalYawInput = (yawInput + yawInput2) - system.getControlDeviceLeftRightInput()
    local finalBrakeInput = brakeInput

    -- Axis
    local worldVertical = vec3(core.getWorldVertical()) -- along gravity
    local constructUp = vec3(core.getConstructWorldOrientationUp())
    local constructForward = vec3(core.getConstructWorldOrientationForward())
    local constructRight = vec3(core.getConstructWorldOrientationRight())
    local constructVelocity = vec3(core.getWorldVelocity())
    local constructVelocityDir = vec3(core.getWorldVelocity()):normalize()
    local currentRollDeg = getRoll(worldVertical, constructForward, constructRight)
    local currentRollDegAbs = math.abs(currentRollDeg)
    local currentRollDegSign = utils.sign(currentRollDeg)

    -- Rotation
    local constructAngularVelocity = vec3(core.getWorldAngularVelocity())
    local targetAngularVelocity = finalPitchInput * pitchSpeedFactor * constructRight
                                    + finalRollInput * rollSpeedFactor * constructForward
                                    + finalYawInput * yawSpeedFactor * constructUp

    -- In atmosphere?
    if worldVertical:len() > 0.01 and unit.getAtmosphereDensity() > 0.0 then
        local autoRollRollThreshold = 1.0
        -- autoRoll on AND currentRollDeg is big enough AND player is not rolling
        if autoRoll == true and currentRollDegAbs > autoRollRollThreshold and finalRollInput == 0 then
            local targetRollDeg = utils.clamp(0,currentRollDegAbs-30, currentRollDegAbs+30);  -- we go back to 0 within a certain limit
            if (rollPID == nil) then
                rollPID = pid.new(autoRollFactor * 0.01, 0, autoRollFactor * 0.1) -- magic number tweaked to have a default factor in the 1-10 range
            end
            rollPID:inject(targetRollDeg - currentRollDeg)
            local autoRollInput = rollPID:get()

            targetAngularVelocity = targetAngularVelocity + autoRollInput * constructForward
        end
        local turnAssistRollThreshold = 20.0
        -- turnAssist AND currentRollDeg is big enough AND player is not pitching or yawing
        if turnAssist == true and currentRollDegAbs > turnAssistRollThreshold and finalPitchInput == 0 and finalYawInput == 0 then
            local rollToPitchFactor = turnAssistFactor * 0.1 -- magic number tweaked to have a default factor in the 1-10 range
            local rollToYawFactor = turnAssistFactor * 0.025 -- magic number tweaked to have a default factor in the 1-10 range

            -- rescale (turnAssistRollThreshold -> 180) to (0 -> 180)
            local rescaleRollDegAbs = ((currentRollDegAbs - turnAssistRollThreshold) / (180 - turnAssistRollThreshold)) * 180
            local rollVerticalRatio = 0
            if rescaleRollDegAbs < 90 then
                rollVerticalRatio = rescaleRollDegAbs / 90
            elseif rescaleRollDegAbs < 180 then
                rollVerticalRatio = (180 - rescaleRollDegAbs) / 90
            end

            rollVerticalRatio = rollVerticalRatio * rollVerticalRatio

            local turnAssistYawInput = - currentRollDegSign * rollToYawFactor * (1.0 - rollVerticalRatio)
            local turnAssistPitchInput = rollToPitchFactor * rollVerticalRatio

            targetAngularVelocity = targetAngularVelocity
                                + turnAssistPitchInput * constructRight
                                + turnAssistYawInput * constructUp
        end
    end

    -- Engine commands
    local keepCollinearity = 1 -- for easier reading
    local dontKeepCollinearity = 0 -- for easier reading
    local tolerancePercentToSkipOtherPriorities = 1 -- if we are within this tolerance (in%), we don't go to the next priorities

    -- Rotation
    local angularAcceleration = torqueFactor * (targetAngularVelocity - constructAngularVelocity)
    local airAcceleration = vec3(core.getWorldAirFrictionAngularAcceleration())
    angularAcceleration = angularAcceleration - airAcceleration -- Try to compensate air friction
    Nav:setEngineTorqueCommand('torque', angularAcceleration, keepCollinearity, 'airfoil', '', '', tolerancePercentToSkipOtherPriorities)

    -- Brakes
    local brakeAcceleration = -finalBrakeInput * (brakeSpeedFactor * constructVelocity + brakeFlatFactor * constructVelocityDir)
    Nav:setEngineForceCommand('brake', brakeAcceleration)

    -- AutoNavigation regroups all the axis command by 'TargetSpeed'
    local autoNavigationEngineTags = ''
    local autoNavigationAcceleration = vec3()
    local autoNavigationUseBrake = false

    -- Longitudinal Translation
    local longitudinalEngineTags = 'thrust analog longitudinal'
    local longitudinalCommandType = Nav.axisCommandManager:getAxisCommandType(axisCommandId.longitudinal)
    if (longitudinalCommandType == axisCommandType.byThrottle) then
        local longitudinalAcceleration = Nav.axisCommandManager:composeAxisAccelerationFromThrottle(longitudinalEngineTags,axisCommandId.longitudinal)
        Nav:setEngineForceCommand(longitudinalEngineTags, longitudinalAcceleration, keepCollinearity)
    elseif  (longitudinalCommandType == axisCommandType.byTargetSpeed) then
        local longitudinalAcceleration = Nav.axisCommandManager:composeAxisAccelerationFromTargetSpeed(axisCommandId.longitudinal)
        autoNavigationEngineTags = autoNavigationEngineTags .. ' , ' .. longitudinalEngineTags
        autoNavigationAcceleration = autoNavigationAcceleration + longitudinalAcceleration
        if (Nav.axisCommandManager:getTargetSpeed(axisCommandId.longitudinal) == 0 or -- we want to stop
            Nav.axisCommandManager:getCurrentToTargetDeltaSpeed(axisCommandId.longitudinal) < - Nav.axisCommandManager:getTargetSpeedCurrentStep(axisCommandId.longitudinal) * 0.5) -- if the longitudinal velocity would need some braking
        then
            autoNavigationUseBrake = true
        end

    end

    -- Lateral Translation
    local lateralStrafeEngineTags = 'thrust analog lateral'
    local lateralCommandType = Nav.axisCommandManager:getAxisCommandType(axisCommandId.lateral)
    if (lateralCommandType == axisCommandType.byThrottle) then
        local lateralStrafeAcceleration =  Nav.axisCommandManager:composeAxisAccelerationFromThrottle(lateralStrafeEngineTags,axisCommandId.lateral)
        Nav:setEngineForceCommand(lateralStrafeEngineTags, lateralStrafeAcceleration, keepCollinearity)
    elseif  (lateralCommandType == axisCommandType.byTargetSpeed) then
        local lateralAcceleration = Nav.axisCommandManager:composeAxisAccelerationFromTargetSpeed(axisCommandId.lateral)
        autoNavigationEngineTags = autoNavigationEngineTags .. ' , ' .. lateralStrafeEngineTags
        autoNavigationAcceleration = autoNavigationAcceleration + lateralAcceleration
    end

    -- Vertical Translation
    local verticalStrafeEngineTags = 'thrust analog vertical'
    local verticalCommandType = Nav.axisCommandManager:getAxisCommandType(axisCommandId.vertical)
    if (verticalCommandType == axisCommandType.byThrottle) then
        local verticalStrafeAcceleration = Nav.axisCommandManager:composeAxisAccelerationFromThrottle(verticalStrafeEngineTags,axisCommandId.vertical)
        if upAmount ~= 0 or AutoLanding then
            Nav:setEngineForceCommand(verticalStrafeEngineTags, verticalStrafeAcceleration, keepCollinearity, 'airfoil', 'ground', '', tolerancePercentToSkipOtherPriorities)
        else
            Nav:setEngineForceCommand(verticalStrafeEngineTags, vec3(), keepCollinearity)
        end
    elseif  (verticalCommandType == axisCommandType.byTargetSpeed) then
        local verticalAcceleration = Nav.axisCommandManager:composeAxisAccelerationFromTargetSpeed(axisCommandId.vertical)
        autoNavigationEngineTags = autoNavigationEngineTags .. ' , ' .. verticalStrafeEngineTags
        autoNavigationAcceleration = autoNavigationAcceleration + verticalAcceleration
    end

    -- Auto Navigation (Cruise Control)
    if (autoNavigationAcceleration:len() > constants.epsilon) then
        if (brakeInput ~= 0 or autoNavigationUseBrake or math.abs(constructVelocityDir:dot(constructForward)) < 0.95)  -- if the velocity is not properly aligned with the forward
        then
            autoNavigationEngineTags = autoNavigationEngineTags .. ', brake'
        end
        Nav:setEngineForceCommand(autoNavigationEngineTags, autoNavigationAcceleration, dontKeepCollinearity, '', '', '', tolerancePercentToSkipOtherPriorities)
    end

    -- Rockets
    Nav:setBoosterCommand('rocket_engine')
    -- Dodgin's Don't Die Rocket Govenor - Cruise Control Edition
    speed = vec3(core.getVelocity()):len() 
    cc_speed = Nav.axisCommandManager:getTargetSpeed(axisCommandId.longitudinal)                
    if Nav.axisCommandManager:getAxisCommandType(0) == 1 and (speed * 3.6 > cc_speed) then 
            unit.setEngineThrust('rocket_engine',0)                
    elseif(isboosting) then 
            unit.setEngineThrust('rocket_engine',1)                
    end
end    