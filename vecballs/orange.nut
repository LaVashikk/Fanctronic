local orange = VecModeBuilder("orange", "255 80 20")
orange.addHandleFunc(function(cargo) {
    return cargo.EmitSound("ParticleBall.Explosion")
    
})

orange.addRemoverFunc(function(_) {})

projectileModes.append(orange)