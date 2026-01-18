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

        // todo to eng: Таблица не может хранить числа в ключах, поэтому используем массив. 
        // Так как нельзя дважды активировтаь один режим - мы храним в индексе только сам диспенсер
        this.usedDispancer = array(vecballCount, null)

        EventListener.Notify("vecgun_powered_on", player)
    }

    function Shoot() null
    function activateMode(idx) null
    function deactivateMode(idx) null
    function SetMode(idx) null
    function resetModes() null
    function switchMode() null
    function GetBuilder() null
}


function VectronicGun::Shoot() {
    if(this.currentMode == null) 
        return EventListener.Notify("vecgun_no_projectile", this.owner)
    if(Time() < this.lastShoot + vecgunShootDelay)
        return EventListener.Notify("vecgun_recharge")

    local start = this.owner.EyePosition() 
    local end = start + this.owner.EyeForwardVector() * maxDistance
    local projectile = this.GetBuilder().Shoot(start, end, this.owner)

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
        this.usedDispancer[idx] = dispancer
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
    
    // todo to eng: Запущенные шары этого режима дезентегрируются.
    local name = projectileModes[idx].GetName()
    local needToRemove = List()
    foreach(idx, ball in this.activeProjectiles.iter()) {
        if(ball.IsValid() == false) { // Garbage collector
            needToRemove.insert(0, idx) 
            continue
        }
        if(ball.GetName() == name) {
            needToRemove.insert(0, idx) 
            ball.Destroy()
        }
    }

    foreach(idx in needToRemove.iter()) {
        this.activeProjectiles.remove(idx)
    }

    // restore dispancer
    EntFireByHandle(this.usedDispancer[idx], "FireUser1")
}

function VectronicGun::SetMode(idx) {
    this.currentMode = idx
    // TODO viewmodel logic, add events here
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
        EntFireByHandle(dispancer, "FireUser1")
    }
    
    this.owner.EmitSound("Weapon_VecGun.Fizzle") // todo: add event here
}

function VectronicGun::switchMode() {
    if(this.currentMode == null)
        return EventListener.Notify("vecgun_no_projectile", this.owner)

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
        else return EventListener.Notify("vecgun_no_alternate_projectile", this.owner)
    }
    
    // TODO
    this.currentMode = nextMode
    this.owner.EmitSound("Weapon_Vecgun.Change")
    EventListener.Notify("vecgun_mode_switched", nextMode)
}

function VectronicGun::GetBuilder() {
    return projectileModes[this.currentMode]
}