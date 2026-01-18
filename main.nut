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
const MAX_DISTANCE = 3000
const PROJECTILE_SPEED = 16.6 // units per frame
const RECURSION_DEPTH = 4
const MAX_PROJECTILES_ON_MAP = 10
const VECGUN_SHOOT_DELAY = 0

::LAST_BALL_MODE <- -1
::TRACE_CONFIG <- TracePlus.Settings.new()
TRACE_CONFIG.SetPriorityClasses(ArrayEx("trigger_gravity"))
TRACE_CONFIG.SetIgnoredModels(ArrayEx("portal_emitter"))
TRACE_CONFIG.SetCollisionFilter(function(ent) {
    if(ent.GetClassname() != "trigger_multiple") 
        return false

    local vecballIdx = projectileModes.search(::LAST_BALL_MODE) + 1
    return ent.GetHealth() == vecballIdx || ent.GetHealth() == 999 // 999: it's a white fizzler
})


// TODO COMMENT
::VECGUN_OWNERS <- {}

function giveVecGun(player) { // todo
    if(player in ::VECGUN_OWNERS) 
        return dev.warning(player + " already has vecgun.")
    
    local vecgun = VectronicGun(player)
    ::VECGUN_OWNERS[player] <- vecgun

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
