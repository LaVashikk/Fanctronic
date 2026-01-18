local purple = VecModeBuilder("purple", "154 141 233")
purple.addHandleFunc(function(cargo) {
    // For toggle-mode:
    if(cargo.GetModeName() == "purple") {
        return cargo.ResetModeForce()
    }

    cargo.SetUserData("previousMode", cargo.GetMode())

    local thisColor = this.GetColor()
    local activateColor = cargo.GetColor()
    local eventName = cargo.CBaseEntity

    local action = function(cargo, thisColor, activateColor, eventName) {
        animate.RT.ColorTransition(cargo, thisColor, activateColor, 2.5, {eventName = eventName})
        animate.RT.ColorTransition(cargo, activateColor, thisColor, 1, {eventName = eventName, globalDelay = 2.5})
    }
    ScheduleEvent.AddInterval(eventName, action, 3.5, 1, [cargo, thisColor, activateColor, eventName])
    
    cargo.ActivateMode(this)
    cargo.SetIgnoreBalls(true)
})

// purple.addRemoverFunc(function(cargo) {    
//     local previousMode = cargo.GetUserData("previousMode")

//     if(previousMode) {
//         dev.info("previousMode={}", previousMode)
//         local fizzlerMode = cargo.GetUserData("iWasDestroyedByFizzlerMode")
//         if(!fizzlerMode) {
//             local eventName = cargo.CBaseEntity
//             ScheduleEvent.TryCancel(eventName)
//             cargo.SetIgnoreBalls(false)
//             return cargo.ActivateMode(previousMode)
//         }

//         dev.info("We have {}. previousMode={}", fizzlerMode,previousMode)
//         if(fizzlerMode.GetName() == "purple") {
//             dev.info("process as purple")
//             local eventName = cargo.CBaseEntity
//             ScheduleEvent.TryCancel(eventName)
//             cargo.SetIgnoreBalls(false)
//             previousMode.cargoRemoveEffects(cargo)
//             cargo.DeactivateMode()
//             cargo.SetContext(previousMode.GetName(), 0)
//             cargo.SetUserData("iWasDestroyedByFizzlerMode", null)
//         } else if(fizzlerMode == previousMode ) {
//             dev.info("process as def")
//             local eventName = cargo.CBaseEntity
//             ScheduleEvent.TryCancel(eventName)
//             cargo.SetIgnoreBalls(false)
//             cargo.ActivateMode(previousMode)
//         } else {
//             // nothing
//         }
//     } else {
//         local eventName = cargo.CBaseEntity
//         ScheduleEvent.TryCancel(eventName)
//         cargo.SetIgnoreBalls(false)
//         cargo.DeactivateMode()
//     }
// })

purple.addRemoverFunc(function(cargo) {    
    local previousMode = cargo.GetUserData("previousMode")
    local fizzlerMode = cargo.GetUserData("iWasDestroyedByFizzlerMode")
    local isPurple = (fizzlerMode && fizzlerMode.GetName() == "purple")

    if (previousMode) {
        // If fizzlerMode exists but is NEITHER "purple" NOR equal to previousMode,
        // we abort operation.
        if (fizzlerMode && fizzlerMode.GetName() != "purple" && fizzlerMode != previousMode) {
            return
        }
    } else if (fizzlerMode && !isPurple) { // Execute only if it's purple. Otherwise -> abort.
        return
    }

    local eventName = cargo.CBaseEntity
    ScheduleEvent.TryCancel(eventName)
    cargo.SetIgnoreBalls(false)

    // Proceeding with mode-specific logic
    if (previousMode) {
        if (isPurple) {
            // Logic for Purple
            dev.info("process as purple")
            previousMode.cargoRemoveEffects(cargo)
            cargo.DeactivateMode()
            cargo.SetContext(previousMode.GetName(), 0)
            cargo.SetUserData("iWasDestroyedByFizzlerMode", null)
        } else {
            // Restoration Logic 
            // We land here if !fizzlerMode or fizzlerMode == previousMode
            if (fizzlerMode) dev.info("We have {}. process as def", fizzlerMode)
            cargo.ActivateMode(previousMode)
        }
    } else {
        cargo.DeactivateMode()
    }
})



projectileModes.append(purple)