::dev["customPrint"] <- function(msg) printl("Fanctronic: " + msg)

// TODO comment
local noAlternateBalls = VGameEvent("vecgun_powered_on")
noAlternateBalls.AddAction(function(player) {
    dev.customPrint(player + " got a vecgun")
})


// TODO comment
local newModeActivated = VGameEvent("vecgun_mode_activated")
newModeActivated.AddAction(function(modeIdx) {
    dev.customPrint("A new mode has been activated: " + (modeIdx + 1))
})


// TODO comment
local modeDeactivated = VGameEvent("vecgun_mode_deactivated")
modeDeactivated.AddAction(function(modeIdx) {
    dev.customPrint("A mode has been deactivated: " + (modeIdx + 1))
})


// TODO comment
local vecgunFired = VGameEvent("vecgun_projectile_launched")
vecgunFired.AddAction(function(modeIdx) {
    
})


// TODO comment
local noProjectileAvailable = VGameEvent("vecgun_no_projectile")
noProjectileAvailable.AddAction(function(_) {
    dev.customPrint("No projectile")  // todo change to viewmodel
})


// TODO comment
local reCharge = VGameEvent("vecgun_recharge")
reCharge.AddAction(function(_) {
    dev.customPrint("Recharging now...")  // todo change to HUD? Sound? Idk
})


// TODO comment
local modeSwitched = VGameEvent("vecgun_mode_switched")
modeSwitched.AddAction(function(modeIdx) {
    dev.customPrint("Set " + (modeIdx + 1) + " mode") // todo change to viewmodel
})


// TODO comment
local noAlternateBalls = VGameEvent("vecgun_no_alternate_projectile")
noAlternateBalls.AddAction(function(_) {
    dev.customPrint("No other projectile")  // todo change to viewmodel
})

