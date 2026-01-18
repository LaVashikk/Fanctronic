function initDispancer(mode) {
    local ballMode = projectileModes[(mode - 1) % projectileModes.len()]
    local dispancer = entLib.FromEntity(caller)
    local prefix = dispancer.GetNamePrefix()

    dispancer.SetUserData("veccolor", ballMode.GetColor())
    entLib.FindByName(prefix + "spotlight").SetColor(ballMode.GetColor())

    // Set particles
    local basePoint = entLib.FindByName(prefix + "dispenser_particle")
    local vecballPoint = entLib.FindByName(prefix + "dispenser_vecball")

    local colorPrefix = "@" + ballMode.GetName() + "-"

    entLib.FindByName(colorPrefix + "dispancer-spawn").SpawnEntity()
    local baseFX = entLib.FindByName(colorPrefix + "dispancer-base")
    local coreFX = entLib.FindByName(colorPrefix + "dispancer-core")
    local vecballFX = entLib.FindByName(colorPrefix + "dispancer-vecball")

        // Particle initialization
        baseFX.SetOrigin(basePoint.GetOrigin())
        coreFX.SetOrigin(basePoint.GetOrigin())
        vecballFX.SetOrigin(vecballPoint.GetOrigin())

        // baseFX.SetParent(basePoint)
        // coreFX.SetParent(basePoint)
        // vecballFX.SetParent(vecballPoint)

        baseFX.SetName(basePoint.GetName())
        coreFX.SetName(basePoint.GetName())
        vecballFX.SetName(vecballPoint.GetName())
}

function enableDispancer() {
    local dispancer = entLib.FromEntity(caller)
    local color = dispancer.GetUserData("veccolor")
    if(color == dispancer.GetColor()) return
    animate.ColorTransition(dispancer, dispancer.GetColor(), color, 0.15)
}

function disableDispancer() {
    local dispancer = entLib.FromEntity(caller)
    animate.ColorTransition(dispancer, dispancer.GetColor(), Vector(30, 30, 30), 0.15)
}

function touchDispancer(mode) {
    if((activator in vecgunOwners) == false) 
        return
    local vecgun = vecgunOwners[activator]
    vecgun.activateMode(mode, caller)
}