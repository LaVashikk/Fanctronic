local createHint = function(text, name = "hint") {
    local hint = HintInstructor(text, 10)
    hint.SetName(name)
    hint.SetEffects(1, 1, 1)
    return hint
}

// TODO comment
nearVecballDispenser <- VGameEvent("hint_near_vecball_dispenser_hint", 1)
nearVecballDispenser.AddAction(function(dispenser) : (createHint) {
    local hint = createHint("Approach the dispenser to receive a new vecball for your weapon", "@vechint_dispenser")
    hint.SetPositioning(0, dispenser.GetName())
    hint.Enable()
})


vecgunOverloaded <- VGameEvent("hint_vecgun_overloaded_hint", 1)
vecgunOverloaded.AddAction(function(_) : (createHint) {
    local hint = createHint("You can only carry 3 projectiles at a time. Use them before collecting more")
    hint.Enable()
})


canShootVecball <- VGameEvent("hint_can_shoot_vecball_hint", 1)
canShootVecball.AddAction(function(_) : (createHint) {
    local hint = createHint("You've acquired a vecball projectile. Use your vecgun to shoot it")
    hint.SetBind("+attack1")
    hint.Enable()
})



canSwitchVecball <- VGameEvent("hint_can_switch_vecball_hint", 1)
canSwitchVecball.AddAction(function(_) : (createHint) {
    local hint = createHint("You have multiple projectiles. Switch between them to use different abilities")
    hint.SetBind("+attack2")
    hint.Enable()
})



canActivateCube <- VGameEvent("hint_can_activate_cube_hint", 1)
canActivateCube.AddAction(function(cargo) : (createHint) {
    local hint = createHint("Use your vecball projectile to activate the cube.", "@vechint_cube")
    hint.SetPositioning(0, cargo.GetName())
    hint.SetBind("+attack1")
    hint.Enable()
})
