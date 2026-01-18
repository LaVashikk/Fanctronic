class VecModeBuilder {
    particleMaker = null;
    name = null;
    color = null;

    handleHitFunc = null;
    removeEffectsFunc = null;

    constructor(name, color, handleFunc = null) {
        this.color = color
        this.name = name
        this.handleHitFunc = handleFunc

        this.particleMaker = entLib.FindByName(macros.format("@{}-projectile-spawn", name)) 

        local colorPoint = entLib.FindByName(macros.format("@{}-colorPoint", name))
        if(colorPoint) {
            colorPoint.SetOrigin(macros.StrToVec(color))
        } else {
            dev.error("No color point for {} ({})", name, color)
        }
    }

    function addHandleFunc(func) null
    function addRemoverFunc(func) null
    function cargoRemoveEffects(cargo) null

    function GetStatus() bool
    function GetName() string
    function GetColor() string
    
    function Shoot(startPos, endPos, caller) null
    function PlayParticle(particleName, originPos) pcapEnt

    function _createProjectileParticle() null
    function _tostring() return "VecModeBuilder: " + name
}


// Setters & Getters
function VecModeBuilder::addHandleFunc(func) {
    this.handleHitFunc = func
}

function VecModeBuilder::addRemoverFunc(func) {
    this.removeEffectsFunc = func
}

function VecModeBuilder::cargoRemoveEffects(cargo) { // todo: rename this
    this.removeEffectsFunc(cargo)
}

function VecModeBuilder::GetName() {
    return this.name
}

function VecModeBuilder::GetColor() {
    return this.color
}


// Something more interesting
function VecModeBuilder::Shoot(startPos, endPos, caller) {
    local eventName = UniqueString("activeProjectile")
    local particleEnt = this._createProjectileParticle()

    caller.EmitSound("VecLauncher.Fire")

    local projectile = LaunchedProjectile(particleEnt, eventName, this)
    local animationDuration = 0  

    /**
     * Recursively calculates the projectile's trajectory, handling portal translocations and surface reflections.
     * Traces the path through multiple iterations to simulate bounces and portal traversal until max recursion depth or a blocking entity is hit.
    */
    ::LAST_BALL_MODE = this
    for(local recursion = 0; recursion < RECURSION_DEPTH; recursion++) {
        local trace = TracePlus.PortalBbox(startPos, endPos, caller, ::TRACE_CONFIG)

        local terminateTrajectory = false
        local portalTraces = trace.GetAggregatedPortalEntryInfo()
        foreach(iter, portalTrace in portalTraces.iter()) {
            animationDuration += projectile.moveBetween(portalTrace.GetStartPos(), portalTrace.GetHitPos(), animationDuration)

            local hitEnt = portalTrace.GetEntityClassname()
            // Entity collision resolution:
            // - trigger_gravity: Acts as a solid obstacle, terminating the path.
            // - trigger_multiple: Functions as a fizzler/disintegration field.
            if(hitEnt == "trigger_gravity" || hitEnt == "prop_physics" || hitEnt == "trigger_multiple") {
                endPos = portalTrace.GetHitPos()
                terminateTrajectory = true
                break 
            }
        }
        if(terminateTrajectory || recursion == RECURSION_DEPTH - 1) break

        local surfaceNormal = trace.GetImpactNormal()
        local dirReflection = math.vector.reflect(trace.GetDir(), surfaceNormal)

        startPos = trace.GetHitPos() + surfaceNormal * 5
        local newEnd = trace.GetHitPos() + dirReflection * MAX_DISTANCE
        endPos = TracePlus.Cheap(startPos, newEnd).GetHitPos()
        
        particleEnt.EmitSoundEx("ParticleBall.Impact", 10, false, animationDuration, eventName)
    }

    projectile.SoftKill(animationDuration)

    //* Primary (or outdated, maybe) collision resolution logic for vecball-cube interactions
    // local hitFunc = function(endPos, handleHitFunc, particleEnt) {
    //     local cargo = entLib.FindByModelWithin("models/props/puzzlebox.mdl", endPos, 25)
    //     if(!cargo || !cargo.IsValid()) 
    //         return particleEnt.EmitSound("ParticleBall.Explosion")

    //     handleHitFunc(vecBox(cargo))
    // }
    // ScheduleEvent.Add(eventName, hitFunc, animationDuration, [endPos, handleHitFunc, particleEnt], this)

    return projectile
}

function VecModeBuilder::PlayParticle(particleName, originPos) {
    local particle = entLib.FindByName(macros.format("@{}-{}", this.name, particleName)) 

    particle.SetOrigin(originPos)
    EntFireByHandle(particle, "Stop")
    EntFireByHandle(particle, "Start", "", 0.01)

    return particle
}

function VecModeBuilder::_createProjectileParticle() {
    local prefix = macros.format("@{}-", this.name)

    entLib.FindByName(prefix + "projectile-spawn").SpawnEntity()
    local particle = entLib.FindByName(prefix + "projectile")

    particle.SetName(this.name)
    EntFireByHandle(particle, "Start")
    return particle
}



// Storage of all launched projectile
::projectileCount <- List()

// The object of the Projectile itself :>
::LaunchedProjectile <- class {
    particleEnt = null;
    eventName = null;
    modeBuilder = null;

    constructor(particleEnt, eventName, VecModeBuilder) {
        this.particleEnt = particleEnt
        this.eventName = eventName
        this.modeBuilder = VecModeBuilder

        // An optional functionality, created purely for the sake of optimization
        if(::projectileCount.len() > MAX_PROJECTILES_ON_MAP) {
            local oldestProjectile = ::projectileCount.first()
            if(oldestProjectile.IsValid()) oldestProjectile.Destroy()
            ::projectileCount.remove(0)
        }
        ::projectileCount.append(this)
    }

    function Destroy() {
        if(this.IsValid() == false) return
        ScheduleEvent.Cancel(this.eventName)
        this.particleEnt.Destroy()
    }

    function SoftKill(delay) {
        EntFireByHandle(particleEnt, "Stop", "", delay)
        EntFireByHandle(particleEnt, "kill", "", delay + 1)
    }

    function IsValid() {
        return ScheduleEvent.IsValid(this.eventName) && this.particleEnt.IsValid()
    }

    function moveBetween(startPos, endPos, delay = 0) {
        return animate.RT.PositionTransitionBySpeed(this.particleEnt, startPos, endPos, 
            PROJECTILE_SPEED, {eventName = this.eventName, globalDelay = delay}) // TODO: eventname opti
    }

    function GetName() {
        return this.modeBuilder.name
    }

    function GetOrigin() {
        return this.particleEnt.GetOrigin()
    }
}