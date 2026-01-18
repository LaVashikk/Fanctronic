local ballshotsModes = {}

function setBallshoot(mode) : (ballshotsModes) {
    caller = entLib.FromEntity(caller)
    local vecball = projectileModes[mode - 1]

    local name = caller.GetNamePrefix() + "*"
    animate.ColorTransition(name, caller.GetColor(), vecball.GetColor(), 0.5)
    ballshotsModes[caller] <- vecball

    if(caller.GetUserData("particle"))
        caller.GetUserData("particle").Destroy()
    
    local colorPrefix = "@" + vecball.GetName() + "-"
    entLib.FindByName(colorPrefix + "ballshot-spawn").SpawnEntity()
    local baseFX = entLib.FindByName(colorPrefix + "ballshot-base")
    baseFX.SetUniqueName()
    baseFX.SetOrigin(caller.GetOrigin() + caller.GetForwardVector() * 30)
    caller.SetUserData("particle", baseFX)
}


function BallShoot() : (ballshotsModes) {
    caller = entLib.FromEntity(caller)
    local vecball = ballshotsModes[caller]

    local start = caller.GetOrigin() + caller.GetForwardVector() * 30
    local end = start + caller.GetForwardVector() * maxDistance

    vecball.Shoot(start, end, caller)

    // Sprite animate // todo
    local sprite = caller.GetNamePrefix() + "sprite"
    animate.RT.AlphaTransition(sprite, 50, 255, 0.1, {eventName=UniqueString()})
    animate.RT.AlphaTransition(sprite, 255, 50, 0.7, {eventName=UniqueString(), globalDelay = 0.15})

    local shotter = caller.GetNamePrefix() + "*"
    local color = macros.StrToVec(caller.GetColor())
    local newColor = math.vector.clamp(color * 0.5, 0, 255)
    animate.RT.ColorTransition(shotter, color, newColor, 0.1. {eventName=UniqueString()})
    animate.RT.ColorTransition(shotter, newColor, color, 0.7, {eventName=UniqueString(), globalDelay = 0.35})
}