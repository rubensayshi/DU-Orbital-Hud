
function UpdateAutopilotTarget()
    -- So the indices are weird.  I think we need to do a pairs
    if AutopilotTargetIndex == 0 then
        AutopilotTargetName = "None"
        AutopilotTargetPlanet = nil
        return true
    end
    local count = 0
    for k,v in pairs(Atlas()[0]) do
        count = count + 1
        if count == AutopilotTargetIndex then
            AutopilotTargetName = v.name
            AutopilotTargetPlanet = galaxyReference[0][k]
            AutopilotTargetCoords = vec3(AutopilotTargetPlanet.center) -- Aim center until we align
            -- Determine the end speed
            _, AutopilotEndSpeed = kepPlanet:escapeAndOrbitalSpeed(AutopilotTargetOrbit)
            --AutopilotEndSpeed = 0
            --AutopilotPlanetGravity = AutopilotTargetPlanet:getGravity(AutopilotTargetPlanet.center + vec3({1,0,0}) * AutopilotTargetOrbit):len() -- Any direction, at our orbit height
            AutopilotPlanetGravity = 0 -- This is inaccurate unless we integrate and we're not doing that.  
            AutopilotAccelerating = false
            AutopilotBraking = false
            AutopilotCruising = false 
            Autoilot = false
            AutopilotRealigned = false
            AutopilotStatus = "Aligning"
            return true
        end
    end
    return false
end

function IncrementAutopilotTargetIndex()
    AutopilotTargetIndex = AutopilotTargetIndex + 1
    if AutopilotTargetIndex >  tablelength(Atlas()[0]) then 
        AutopilotTargetIndex = 0
    end
    UpdateAutopilotTarget()
end

function DecrementAutopilotTargetIndex()
    AutopilotTargetIndex = AutopilotTargetIndex - 1
    if AutopilotTargetIndex < 0 then 
        AutopilotTargetIndex = tablelength(Atlas()[0])
    end
    UpdateAutopilotTarget()
end

function GetAutopilotTravelTime()
    AutopilotDistance = (AutopilotTargetPlanet.center - vec3(core.getConstructWorldPos())):len()
    local velocity = core.getWorldVelocity() 
    local accelDistance, accelTime = Kinematic.computeDistanceAndTime(vec3(velocity):len(),
        MaxGameVelocity, -- From currently velocity to max
        constructMass(),
        Nav:maxForceForward(),
        warmup, -- T50?  Assume none, negligible for this
        0) -- Brake thrust, none for this
    -- accelDistance now has the amount of distance for which we will be accelerating
    -- Then we need the distance we'd brake from full speed
    -- Note that for some nearby moons etc, it may never reach full speed though.
    local brakeDistance, brakeTime
    if not TurnBurn then 
        brakeDistance, brakeTime = GetAutopilotBrakeDistanceAndTime(MaxGameVelocity)
    else
        brakeDistance, brakeTime = GetAutopilotTBBrakeDistanceAndTime(MaxGameVelocity)
    end
    local curBrakeDistance, curBrakeTime
    if not TurnBurn then 
        curBrakeDistance, curBrakeTime = GetAutopilotBrakeDistanceAndTime(vec3(velocity):len())
    else
        curBrakeDistance, curBrakeTime = GetAutopilotTBBrakeDistanceAndTime(vec3(velocity):len())
    end
    local cruiseDistance = 0
    local cruiseTime = 0
    -- So, time is in seconds
    -- If cruising or braking, use real cruise/brake values
    if brakeDistance + accelDistance < AutopilotDistance then 
        -- Add any remaining distance
        cruiseDistance = AutopilotDistance - (brakeDistance + accelDistance)
        cruiseTime = Kinematic.computeTravelTime(8333.0556, 0, cruiseDistance)
    else
        local accelRatio = (AutopilotDistance - brakeDistance)/accelDistance
        accelDistance = AutopilotDistance - brakeDistance -- Accel until we brake
        accelTime = accelTime * accelRatio
    end
    if AutopilotBraking then
        return curBrakeTime
    elseif AutopilotCruising then
        return cruiseTime + curBrakeTime
    else -- If not cruising or braking, assume we'll get to max speed
        return accelTime + brakeTime + cruiseTime
    end
end

function GetAutopilotBrakeDistanceAndTime(speed)
    -- If we're in atmo, just return some 0's or LastMaxBrake, whatever's bigger
    -- So we don't do unnecessary API calls when atmo brakes don't tell us what we want
    if atmosphere() == 0 then
        local maxBrake = jdecode(unit.getData()).maxBrake
        if maxBrake ~= nil then
            LastMaxBrake = maxBrake
            return Kinematic.computeDistanceAndTime(speed, AutopilotEndSpeed, constructMass(), 0, 0, maxBrake - (AutopilotPlanetGravity * constructMass()))
        else
            return Kinematic.computeDistanceAndTime(speed, AutopilotEndSpeed, constructMass(), 0, 0, LastMaxBrake - (AutopilotPlanetGravity * constructMass()))
        end
    else
        if LastMaxBrake and LastMaxBrake > 0 then
            return Kinematic.computeDistanceAndTime(speed, AutopilotEndSpeed, constructMass(), 0, 0, LastMaxBrake - (AutopilotPlanetGravity * constructMass()))
        else
            return 0,0
        end
    end
end

function GetAutopilotTBBrakeDistanceAndTime(speed) -- Uses thrust and a configured T50
    local maxBrake = jdecode(unit.getData()).maxBrake
    if maxBrake ~= nil then
        LastMaxBrake = maxBrake
        return Kinematic.computeDistanceAndTime(speed, AutopilotEndSpeed, constructMass(), Nav:maxForceForward(), warmup, maxBrake - (AutopilotPlanetGravity * constructMass()))
    else
        return Kinematic.computeDistanceAndTime(speed, AutopilotEndSpeed, constructMass(), Nav:maxForceForward(), warmup, LastMaxBrake - (AutopilotPlanetGravity * constructMass()))
    end
end
