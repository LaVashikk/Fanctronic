class VectronicGun {
    owner = null;

    currentMode = null;
    availablesModes = null;
    activeProjectiles = null;
    usedDispancer = null;

    lastShoot = 0;

    constructor(player) {
        if(player.GetClassname() != "player") 
            return null
         
        local vecballCount = projectileModes.len()

        this.availablesModes = array(vecballCount, false)
        this.activeProjectiles = List()
        
        this.owner = entLib.FromEntity(player);

        this.usedDispancer = List()
        for(local i = 0; i < vecballCount; i++) {
            this.usedDispancer.append(List())
        }

        EventListener.Notify("vecgun_powered_on", player)
    }

    function Shoot() null
    function activateMode(idx) null
    function deactivateMode(idx) null
    function SetMode(idx) null
    function resetModes() null
    function switchMode() null
    function GetBall() null
}


function VectronicGun::Shoot() {
    if(this.currentMode == null) 
        return EventListener.Notify("vecgun_no_projectile")
    if(Time() < this.lastShoot + vecgunShootDelay)
        return EventListener.Notify("vecgun_recharge")

    local start = this.owner.EyePosition() 
    local end = start + this.owner.EyeForwardVector() * maxDistance
    local projectile = this.GetBall().Shoot(start, end, this.owner)

    this.activeProjectiles.append(projectile)
    this.lastShoot = Time()

    EventListener.Notify("vecgun_projectile_launched", this.currentMode)
}

function VectronicGun::activateMode(idx, dispancer = null) {
    idx = (idx - 1) % this.availablesModes.len() 
    if(this.availablesModes[idx]) 
        return dev.info("[" + owner + "] This mode has already been activated: " + idx)
    
    this.availablesModes[idx] = true
    this.SetMode(idx)
    this.owner.EmitSound("Weapon_VecGun.Upgrade")
    EventListener.Notify("vecgun_mode_activated", idx)

    if(dispancer) {
        EntFireByHandle(dispancer, "FireUser2")
        this.usedDispancer[idx].append(dispancer)
    }
}

function VectronicGun::deactivateMode(idx) {
    idx -= 1

    if(availablesModes[idx] == false)
        return dev.info("[" + owner + "] This mode has already been deactivated: " + idx)

    this.availablesModes[idx] = false
    if(this.currentMode == idx) 
        this.switchMode()
    
    EventListener.Notify("vecgun_mode_deactivated", idx)
    
    local type = projectileModes[idx].GetType()
    for(local idx = 0; idx < this.activeProjectiles.len(); idx++) { // TODO Oh no, junk code :<
        local ball = this.activeProjectiles[idx]
        if(ball.IsValid() == false) {
            this.activeProjectiles.remove(idx)
            idx--
            continue
        }

        if(ball.GetType() == type) {
            ball.Destroy()
            this.activeProjectiles.remove(idx)
            idx--
        }
    }

    local dispancers = this.usedDispancer[idx]
    foreach(dispancer in dispancers){
        EntFireByHandle(dispancer, "FireUser1")
    }
    dispancers.clear()
}

function VectronicGun::SetMode(idx) {
    this.currentMode = idx
    // TODO viewmodel logic
}

function VectronicGun::resetModes() {
    if(this.currentMode == null)
        return

    this.currentMode = null

    for(local idx; idx < this.availablesModes; idx++) {
        availablesModes[idx] = false
    }

    foreach(projectile in this.activeProjectiles.iter()){
        projectile.Destroy()
    }
    this.activeProjectiles.clear()

    foreach(dispancers in this.usedDispancer){
        foreach(dispancer in dispancers){
            EntFireByHandle(dispancer, "FireUser1")
        }
        dispancers.clear()
    }
    
    this.owner.EmitSound("Weapon_VecGun.Fizzle")
}

function VectronicGun::switchMode() {
    if(this.currentMode == null)
        return EventListener.Notify("vecgun_no_projectile")

    local startIndex = this.currentMode
    local nextMode = null
    local len = this.availablesModes.len()

    for (local i = 1; i < len; i++) {
        local index = (startIndex + i) % len
        if (this.availablesModes[index]) {
            nextMode = index
            break
        }
    }
    if(nextMode == null) {
        if(this.availablesModes[startIndex] == false) {
            return this.currentMode = null
        }
        else return EventListener.Notify("vecgun_no_alternate_projectile")
    }
    
    // TODO
    this.currentMode = nextMode
    this.owner.EmitSound("Weapon_Vecgun.Change")
    EventListener.Notify("vecgun_mode_switched", nextMode)
}

function VectronicGun::GetBall() {
    return projectileModes[this.currentMode]
}