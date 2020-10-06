function getMagnitudeInDirection(vector, direction)
    --return vec3(vector):project_on(vec3(direction)):len()
    vector = vec3(vector)
    direction = vec3(direction):normalize()
    local result = vector*direction -- To preserve sign, just add them I guess
    return result.x + result.y + result.z
end

function getRelativeYaw(velocity) 
    velocity = vec3(velocity)
    return math.deg(math.atan(velocity.y, velocity.x)) - 90
end

function AlignToWorldVector(vector, tolerance)
    -- Sets inputs to attempt to point at the autopilot target
    -- Meant to be called from Update or Tick repeatedly
    if tolerance == nil then
        tolerance = alignmentTolerance
    end
    vector = vec3(vector):normalize()
    local targetVec = (vec3(core.getConstructWorldOrientationForward()) - vector)
    local yawAmount = -getMagnitudeInDirection(targetVec, core.getConstructWorldOrientationRight()) * AutopilotStrength
    local pitchAmount = -getMagnitudeInDirection(targetVec, core.getConstructWorldOrientationUp()) * AutopilotStrength

    yawInput2 = yawInput2 - (yawAmount + (yawAmount - PreviousYawAmount) * DampingMultiplier)
    pitchInput2 = pitchInput2 + (pitchAmount + (pitchAmount - PreviousPitchAmount) * DampingMultiplier)
    PreviousYawAmount = yawAmount
    PreviousPitchAmount = pitchAmount
    -- Return true or false depending on whether or not we're aligned
    if math.abs(yawAmount) < tolerance and math.abs(pitchAmount) < tolerance then
        return true
    end
    return false
end

function getRelativePitch(velocity) 
    velocity = vec3(velocity)
    local pitch = -math.deg(math.atan(velocity.y, velocity.z)) + 180
    -- This is 0-360 where 0 is straight up
    pitch = pitch - 90
    -- So now 0 is straight, but we can now get angles up to 420
    if pitch < 0 then
       pitch = 360 + pitch 
    end 
    -- Now, if it's greater than 180, say 190, make it go to like -170
    if pitch > 180 then
       pitch = -180 + (pitch-180) 
    end
    -- And it's backwards.  
    return -pitch
end
