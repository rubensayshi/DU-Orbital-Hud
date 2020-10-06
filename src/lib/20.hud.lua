function DrawDeadZone(newContent)
    if system.isViewLocked() == 0 then
        newContent[#newContent + 1] = stringf("<circle cx='50%%' cy='50%%' r='%d' stroke=rgb(%d,%d,%d) stroke-width='2' fill='none' />",DeadZone, mfloor(PrimaryR*0.3), mfloor(PrimaryG*0.3), mfloor(PrimaryB*0.3))
    else
        newContent[#newContent + 1] = stringf("<circle cx='50%%' cy='50%%' r='%d' stroke=rgb(%d,%d,%d) stroke-width='2' fill='none' />",DeadZone, mfloor(PrimaryR*0.8), mfloor(PrimaryG*0.8), mfloor(PrimaryB*0.8))
    end
end

