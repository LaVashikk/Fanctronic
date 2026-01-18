// IncludeScript("Fanctronic/pcapture-lib")
IncludeScript("PCapture-Lib/SRC/PCapture-Lib.nut") // TODO: 4.0 CR

IncludeScript("Fanctronic/projectile")
IncludeScript("Fanctronic/hit-controller")
IncludeScript("Fanctronic/vecballs/main")
IncludeScript("Fanctronic/vecgun")

IncludeScript("Fanctronic/event-controller/GameEvents")
IncludeScript("Fanctronic/event-controller/hintevents")

IncludeScript("Fanctronic/gameplay-elements/vecbox")
IncludeScript("Fanctronic/gameplay-elements/dispenser")
IncludeScript("Fanctronic/gameplay-elements/ballshot")
IncludeScript("Fanctronic/gameplay-elements/fizzler")


// Const
const maxDistance = 3000
const projectileSpeed = 16.6 // units per frame
const recursionDepth = 4
const maxProjectilesOnMap = 10
const vecgunShootDelay = 0

::LastBallMode <- -1
::TraceConfig <- TracePlus.Settings.new()
TraceConfig.SetPriorityClasses(ArrayEx("trigger_gravity"))
TraceConfig.SetIgnoredModels(ArrayEx("portal_emitter"))
TraceConfig.SetCollisionFilter(function(ent) {
    if(ent.GetClassname() != "trigger_multiple") 
        return false

    local vecballIdx = projectileModes.search(LastBallMode) + 1
    return ent.GetHealth() == vecballIdx || ent.GetHealth() == 999 // 999: it's a white fizzler
})


// TODO COMMENT
::vecgunOwners <- {}

function giveVecGun(player) { // todo
    if(player in vecgunOwners) 
        return dev.warning(player + " already has vecgun.")
    
    local vecgun = VectronicGun(player)
    vecgunOwners[player] <- vecgun

    local gameui = entLib.CreateByClassname("game_ui", {FieldOfView = -1});
    gameui.ConnectOutputEx("PressedAttack", function() : (vecgun) {
        vecgun.Shoot()
    })
    gameui.ConnectOutputEx("PressedAttack2", function() : (vecgun) {
        vecgun.switchMode()
    })

    EntFireByHandle(gameui, "Activate", "", 0, player)
}


// DEV CODE FOR FUN!
for(local player; player = Entities.FindByClassname(player, "player");) {
    giveVecGun(player)
}

// Sound Precache
IncludeScript("Fanctronic/precache")
SendToConsole("sv_alternateticks 0")
