local green = VecModeBuilder("green", "172 235 174")
green.addHandleFunc(function(cargo) {
    if(cargo.ShouldIgnore()) {
        return cargo.EmitSound("ParticleBall.Explosion")
    }
    
    // toggle
    if(cargo.GetModeName() == "green") {
        return cargo.DeactivateMode()
    }

    cargo.ResetModeForce()
    cargo.ActivateMode(this)
    cargo.CreateGhost()
})

green.addRemoverFunc(function(cargo) {
    local ghost = cargo.GetGhost()
    if(ghost && ghost.IsValid()) {
        animate.AlphaTransition(ghost, 255, 0, 0.15)
        ghost.Destroy(0.2)
    }
})

projectileModes.append(green)