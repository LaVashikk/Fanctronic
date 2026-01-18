::allCargos <- {}

// The VecballHitController function is a **workaround** that allows the vecball to trigger interactions with the vecbox if a player brings the box within proximity during the vecball's flight. 
// This is necessary because the entire flight trajectory of the vecball is calculated at the moment of launch to conserve resources.
// This function does not use `entLib.FindByModelWithin()` simply because it is too expensive to check every entity every 8 frames, so all existing vecboxes are "cached" in allCargoes for the sake of optimization.
// Could this function have been avoided? Yes, it would have been possible to make vecball's flight dynamic, but that would have been expensive as it would have required checking every entity every frame again.
function VecballHitController() {    
    if(projectileCount.len() == 0) return 

    foreach(cargo, _ in allCargos) {
        if(!cargo.IsValid()) 
            continue

        vecCheck(cargo)
    }
}

::vecCheck <- function(cargo) {
    local cargoOrigin = cargo.GetOrigin()
    local CheckInNextFrame = false
    local shouldRemove = List()

    foreach(idx, projectile in projectileCount.iter()) {
        if(!projectile || !projectile.IsValid()) {
            shouldRemove.insert(0, idx)
            continue
        } 

        local distance = (projectile.GetOrigin() - cargoOrigin).Length()
        if(distance <= 48 && cargo.IsValid()) {
            projectile.modeBuilder.handleHitFunc(vecBox(cargo))
            projectile.Destroy()
            break
        }

        if(distance <= 128) {
            CheckInNextFrame = true
        }
    }

    if(shouldRemove) foreach(idx in shouldRemove.iter()) {
        projectileCount.remove(idx)
    }

    // If vecball is near the cargo, check the distance every frame. This is necessary to improve accuracy
    if(CheckInNextFrame && cargo.IsValid()) {
        local eventName = cargo.GetIndex() + "-hit-checker"
        if(ScheduleEvent.IsValid(eventName)) return

        ScheduleEvent.Add(eventName, function():(cargo) {vecCheck(cargo)}, FrameTime())
    }
}

// This function is used to update the cache of existing cargo (vecbox) entities.
function UpdateCargosList() { 
    for(local ent; ent = entLib.FindByModel("models/props/puzzlebox.mdl", ent);) {
        if(ent in allCargos) continue
        allCargos[ent] <- null
    }

    foreach(ent, _ in allCargos) {
        if(ent.IsValid() == false) 
            allCargos.rawdelete(ent)
    }
}

ScheduleEvent.AddInterval("global", UpdateCargosList, 0.5)
ScheduleEvent.AddInterval("global", VecballHitController, FrameTime() * 4, 1)