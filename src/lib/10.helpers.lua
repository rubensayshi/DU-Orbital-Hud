
function Contains(mousex, mousey, x, y, width, height) 
    if mousex > x and mousex < (x + width) and mousey > y and mousey < (y + height) then
        return true
    else
        return false
    end
end


function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return mfloor(num * mult + 0.5) / mult
end

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function getDistanceDisplayString(distance)
    local su = distance > 100000
    local result = ""
    if su then
        -- Convert to SU
        result = round(distance/1000/200,1) .. " SU"
    elseif distance < 1000 then
        result = round(distance,1) .. " M"
    else
        -- Convert to KM
        result = round(distance/1000,1) .. " KM"
    end

    return result
end

function getDistanceDisplayString2(distance)
    local su = distance > 100000
    local result = ""
    if su then
        -- Convert to SU
        result = round(distance/1000/200,2) .. " SU"
    elseif distance < 1000 then
        result = round(distance,2) .. " M"
    else
        -- Convert to KM
        result = round(distance/1000,2) .. " KM"
    end

    return result
end

function getSpeedDisplayString(speed) -- TODO: Allow options, for now just do kph
    return mfloor(round(speed*3.6,0)+0.5) .. " km/h" -- And generally it's not accurate enough to not twitch unless we round 0
end

function FormatTimeString(seconds)
    local hours = mfloor(seconds/3600)
    local minutes = mfloor(seconds/60%60)
    local seconds = mfloor(seconds%60)
    if seconds < 0 or hours < 0 or minutes < 0 then
        return "0s"
    end
    if hours > 0 then 
        return hours .. "h " .. minutes .. "m " .. seconds .. "s"
    elseif minutes > 0 then
        return minutes .. "m " ..seconds.."s"
    else
        return seconds.."s"
    end
end
