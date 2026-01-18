local red = VecModeBuilder("red", "255 80 20")
red.addHandleFunc(function(cargo) {
    if(cargo.ShouldIgnore()) {
        return cargo.EmitSound("ParticleBall.Explosion")
    }
        
    cargo.DeactivateMode()
    cargo.ActivateMode(this)
    cargo.Dissolve()
})

red.addRemoverFunc(function(_) {})

projectileModes.append(red)