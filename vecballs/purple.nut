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
        // Если fizzlerMode существует, но он НЕ "purple" и НЕ равен previousMode,
        // то ничего не делаем.
        if (fizzlerMode && fizzlerMode.GetName() != "purple" && fizzlerMode != previousMode) {
            return
        }
    } else if (fizzlerMode && !isPurple) { // Выполнять только если это purple. Иначе -> выходим.
        return
    }

    local eventName = cargo.CBaseEntity
    ScheduleEvent.TryCancel(eventName)
    cargo.SetIgnoreBalls(false)

    // Теперь обрабатываем специфичную логику
    if (previousMode) {
        if (isPurple) {
            // Логика для Purple
            dev.info("process as purple")
            previousMode.cargoRemoveEffects(cargo)
            cargo.DeactivateMode()
            cargo.SetContext(previousMode.GetName(), 0)
            cargo.SetUserData("iWasDestroyedByFizzlerMode", null)
        } else {
            // Логика восстановления 
            // Сюда попадаем, если !fizzlerMode или fizzlerMode == previousMode
            if (fizzlerMode) dev.info("We have {}. process as def", fizzlerMode)
            cargo.ActivateMode(previousMode)
        }
    } else {
        cargo.DeactivateMode()
    }
})



projectileModes.append(purple)