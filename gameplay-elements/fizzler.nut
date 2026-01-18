local _playerFizzle = function(modeIdx) {
    if((activator in ::VECGUN_OWNERS) == false) 
        return
    local vecgun = ::VECGUN_OWNERS[activator]        
    vecgun.deactivateMode(modeIdx)
}

local _cubeFizzle = function(cargo) {
    if(cargo.GetMode() == null) return
    cargo.DeactivateMode()
    cargo.EmitSound("VecBox.ClearShield")
}


function vecFizzle(modeIdx = null) : (_playerFizzle, _cubeFizzle) {
    if(modeIdx == null)
        modeIdx = caller.GetHealth()
    if(modeIdx == 999) {
        return vecFizzleAll()
    }
        
    if(activator.GetClassname() == "player") 
        return _playerFizzle(modeIdx)

    local cargo = vecBox(activator)
    cargo.SetUserData("iWasDestroyedByFizzlerMode", projectileModes[modeIdx-1])
    dev.info("new fizzled cargo {} ({}). mode: {}", cargo, cargo.GetModeName(), modeIdx)
    if(cargo.GetModeName() == "purple") { //! hard-code
        return cargo.GetMode().cargoRemoveEffects(cargo)
    }
    if(cargo.GetMode() == projectileModes[modeIdx-1]) {
        _cubeFizzle(cargo)
    }    
}


function vecFizzleAll() : (_cubeFizzle) {
    if(activator.GetClassname() == "player") 
        if(activator in ::VECGUN_OWNERS)
            return ::VECGUN_OWNERS[activator].resetModes()

    local cargo = vecBox(activator)
    if(cargo.GetModeName() == "purple") { //! hard-code
        return cargo.GetMode().cargoRemoveEffects(cargo)
    }

    _cubeFizzle(cargo)
}