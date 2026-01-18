local blue = VecModeBuilder("blue", "135 213 212") // 143 229 226
blue.addHandleFunc(function(cargo) {
    dev.info("[{}] ACTIVATED", Time())
    if(cargo.ShouldIgnore()) {
        return cargo.EmitSound("ParticleBall.Explosion")
    }

    // toggle this mode
    if(cargo.GetModeName() == "blue") {
        return cargo.DeactivateMode()
    }
        
    cargo.ResetModeForce()
    cargo.ActivateMode(this)
    cargo.SetLevitation(true)
})

blue.addRemoverFunc(function(cargo) {
    dev.info("[{}] DE-ACTIVATED", Time())

    cargo.SetLevitation(false)
})

projectileModes.append(blue)