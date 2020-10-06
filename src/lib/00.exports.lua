-- USER DEFINABLE GLOBAL AND LOCAL VARIABLES THAT SAVE
AutopilotTargetOrbit = 100000 --export: How far you want the orbit to be from the planet in m.  200,000 = 1SU
warmup = 32 --export: How long it takes your engines to warmup.  Basic Space Engines, from XS to XL: 0.25,1,4,16,32
PrimaryR = 130 --export: Primary HUD color
PrimaryG = 224 --export: Primary HUD color
PrimaryB = 255 --export: Primary HUD color
userControlScheme = "Keyboard" --export: Set to "Virtual Joystick", "Mouse", or "Keyboard"
freeLookToggle = true --export: Set to false for default free look behavior.
brakeToggle = true --export: Set to false to use hold to brake vice toggle brake.
apTickRate = 0.0166667 --export: Set the Tick Rate for your HUD.  0.016667 is effectively 60 fps and the default value. 0.03333333 is 30 fps.  The bigger the number the less often the autopilot and hud updates but may help peformance on slower machings.
MaxGameVelocity = 8333.05 --export: Max speed for your autopilot in m/s, do not go above 8333.055 (30000 km/hr), use 6944.4444 for 25000km/hr
AutoTakeoffAltitude = 1000 --export: How high above your starting position AutoTakeoff tries to put you
DeadZone = 50 --export: Number of pixels of deadzone at the center of the screen
MouseYSensitivity = 0.003 --export:1 For virtual joystick only
MouseXSensitivity = 0.003 --export: For virtual joystick only
circleRad = 99 --export: The size of the artifical horizon circle, set to 0 to remove.
autoRoll = false --export: [Only in atmosphere]<br>When the pilot stops rolling,  flight model will try to get back to horizontal (no roll)
showHud = true --export: Uncheck to hide the HUD and only use autopilot features via ALT+# keys.
hideHudOnToggleWidgets = true --export: Uncheck to keep showing HUD when you toggle on the widgets via ALT+3.
fuelTankOptimization = 0 --export: For accurate fuel levels, set this to the fuel tank optimization level * 0.05 (so level 1 = 0.05, level 5 = 0.25) of the person who placed the tank. This will be 0 for most people for now.
RemoteFreeze = false --export: Whether or not to freeze you when using a remote controller.  Breaks some things, only freeze on surfboards
pitchSpeedFactor = 0.8 --export: For keyboard control
yawSpeedFactor =  1 --export: For keyboard control
rollSpeedFactor = 1.5 --export: This factor will increase/decrease the player input along the roll axis<br>(higher value may be unstable)<br>Valid values: Superior or equal to 0.01
brakeSpeedFactor = 3 --export: When braking, this factor will increase the brake force by brakeSpeedFactor * velocity<br>Valid values: Superior or equal to 0.01
brakeFlatFactor = 1 --export: When braking, this factor will increase the brake force by a flat brakeFlatFactor * velocity direction><br>(higher value may be unstable)<br>Valid values: Superior or equal to 0.01
autoRollFactor = 2 --export: [Only in atmosphere]<br>When autoRoll is engaged, this factor will increase to strength of the roll back to 0<br>Valid values: Superior or equal to 0.01
turnAssist = true --export: [Only in atmosphere]<br>When the pilot is rolling, the flight model will try to add yaw and pitch to make the construct turn better<br>The flight model will start by adding more yaw the more horizontal the construct is and more pitch the more vertical it is
turnAssistFactor = 2 --export: [Only in atmosphere]<br>This factor will increase/decrease the turnAssist effect<br>(higher value may be unstable)<br>Valid values: Superior or equal to 0.01
TargetHoverHeight = 50 --export: Hover height when retracting landing gear
AutopilotInterplanetaryThrottle = 100 --export: How much throttle, in percent, you want it to use when autopiloting to another planet
ShiftShowsRemoteButtons = true --export: Whether or not pressing Shift in remote controller mode shows you the buttons (otherwise no access to them)
DampingMultiplier = 40 --export: How strongly autopilot dampens when nearing the correct orientation
speedChangeLarge = 5 --export: The speed change that occurs when you tap speed up/down, default is 5 (25% throttle change). 
speedChangeSmall = 1 --export: the speed change that occurs while you hold speed up/down, default is 1 (5% throttle change).
brightHud = false --export: Enable to prevent hud dimming when in freelook.
