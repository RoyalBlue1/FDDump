global function logFDt
global function fdLogPlayerDeath
global function fdLogWaveContains
global function fdLogWaveComplete
global function fdLogWaveRestarting
global function fdLogPingMinimap
global function fdLogWaveStarting
global function fdLogUpdateWaveInfo
global function fdLogDropPod
global function fdLogPos
global function fdLogDeath
global function fdLogShieldDome
global function fdLogPropDynamic
global function fdLogTraceVolume
global function fdLogNewEntity
global function fdLogNewTitan
global function fdLogNewHuman
global function fdLogUncapturedEnt
global function fdLogMoney
global function fdLogTeamScore
global function PrintWeapon
global function fdDumpInit
global function LogNewEntity

void function logFDt(float time, ... )
{
	if ( vargc <= 0 )
		return

	var msg = "FDMessage " + time + " "
	for ( int i = 0; i < vargc; i++ )
		msg = (msg + " " + vargv[i])

	printl( msg )//TODO Replace with Rexx pipe
}

void function quitGameinSeconds(float seconds){
    wait seconds
    GetLocalClientPlayer().ClientCommand("quit")
}
void function fdLogPlayerDeath(float time)
{
    logFDt(time,"PlayerDeath")
}
void function fdLogWaveContains(int waveNum,string type,int count,float time)
{
    logFDt(time,"WaveContains waveNum:",waveNum,"type:",type,"count:",count)
}
void function fdLogWaveComplete(float time)
{
    logFDt(time,"WaveComplete")
    thread quitGameinSeconds(0.1)
}
void function fdLogWaveRestarting(float time)
{
    logFDt(time,"WaveRestart")
}
void function fdLogPingMinimap(float x,float y,float duration,float spreadRadius,float ringRadius,int colorIndex,float time)
{
    logFDt(time,"PingMinimap pos:",x,y,"duration:",duration,"spread:",spreadRadius,"ringRadius:",ringRadius,"color:",colorIndex)
}
void function fdLogWaveStarting(int currentWave,float time)
{
    logFDt(time,"WaveStarting wave:",currentWave)
}
void function fdLogUpdateWaveInfo(int waveNum,string difficultyString,string waveStatus,string levelName,float time)
{
    logFDt(time,"UpdateWaveInfo waveNum:",waveNum,"difficultyString:",difficultyString,"waveString:",waveStatus,"levelName:",levelName)
}
void function fdLogDropPod(int id,vector pos,float time)
{
    logFDt(time,"NewDropPod id:",id,"pos:",pos)
    
}
void function fdLogPos(int id,vector pos,vector ang,float time)
{
    logFDt(time,"PosUpdate id:",id,"pos:",pos,"ang:",ang)
}
void function fdLogDeath(int id,float time)
{
    logFDt(time,"Death id:",id)
}
void function fdLogShieldDome(vector pos,float time)
{
    
    logFDt(time,"NewDomeEntity pos:",pos)
}
void function fdLogPropDynamic(vector pos,asset model,float time)
{
    
    logFDt(time,"NewPropDynamic pos:",pos,"model:",model)
}
void function fdLogTraceVolume(int id,vector pos,string KVs,float time)
{
	
    logFDt(time,"TraceBlocker ",id,"pos:",pos)
    logFDt(time,"KVsOfEntity entID:",id,KVs)
}
void function fdLogNewEntity(int id,string className,string target,var signifier,asset model,vector pos,vector ang,string KVs,float time)
{
    
    logFDt(time,"NewEntity id:",id,"class:",className,"target:",target,"signifier:",signifier,"model:",model ,"pos:",pos,"ang:",ang)
	logFDt(time,"KVsOfEntity entID:",id,KVs)
}
void function fdLogNewTitan(int id,string target,asset model,int team,vector pos,vector ang,string KVs,float time)
{   
    
    logFDt(time,"NewEntityTitan id:",id,"target:",target,"model:",model,"team:",team,"pos:",pos,"ang:",ang)
	logFDt(time,"KVsOfEntity entID:",id,KVs)
}
void function fdLogNewHuman(int id,var signifier,asset model,vector pos,vector ang,string KVs,float time)
{
    logFDt(time,"NewEntityHuman id:",id,"signifier:",signifier,"model:",model,"pos:",pos,"ang:",ang)
	logFDt(time,"KVsOfEntity entID:",id,KVs)
}
void function fdLogUncapturedEnt(int id,string className,string target,var signifier,asset model,vector pos,vector ang,string KVs,float time)
{
    logFDt(time,"NewUncapturedEntity id:",id,"class:",className,"target:",target,"signifier:",signifier,"model:",model ,"pos:",pos,"ang:",ang)
    logFDt(time,"KVsOfEntity entID:",id,KVs)
}
void function fdLogMoney(int money,int money256,float time)
{
    logFDt(time,"PlayerMoney money:",(money + (money256 * 256)) )
}
void function fdLogTeamScore(int score,int score256,float time)
{
     logFDt(time,"TeamScore score:",(score + ( 256 * score256 )) )  
}
void function PrintWeapon(entity weapon,float time)
{   
    
    if(!IsValid(weapon))
        return
	entity entParent = weapon.GetParent()
	if(IsValid(entParent))
		logFDt(time,"NewWeapon entID:",entParent.GetEntIndex(),"weaponName:",weapon.GetWeaponClassName())
    else
        logFDt(time,"NewWeapon weaponName:",weapon.GetWeaponClassName())
}


void function fdDumpInit(){
    if(!IsPlayingDemo())
        thread logNetworkVariables();
    
}

void function logNetworkVariables(){
    if(!IsNewThread())
        return

    while(true){
        fdLogMoney(GetGlobalNetInt("FD_money"),GetGlobalNetInt("FD_money256"),Time())
        fdLogTeamScore(GetGlobalNetInt( "FD_wavePoints" ) ,GetGlobalNetInt( "FD_wavePoints256" ) ,Time())
        wait 1
    }
}



void function LogNewEntity(entity ent){
	if(!IsValid(ent))
	{
		return
	}
    float time = Time()
	WaitFrame()
	switch(ent.GetSignifierName())
	{
		
		case"trace_volume":
            fdLogTraceVolume(ent.GetEntIndex(),ent.GetOrigin(),getKVString(ent),time)
            
		case"prop_dynamic":
			switch(ent.GetModelName())
			{
				case$"models/fx/xo_shield.mdl":
					fdLogShieldDome(ent.GetOrigin(),time)
					return
				case$"models/vehicle/droppod_fireteam/droppod_fireteam.mdl":
					fdLogDropPod(ent.GetEntIndex(),ent.GetOrigin(),time)
                    thread TrackEntity_threaded(ent)
					return
			}
			fdLogPropDynamic(ent.GetOrigin(),ent.GetModelName(),time)
			return
		case"npc_drone":
		case"npc_frag_drone":
		case"npc_super_spectre":
			//generic entity
            fdLogNewEntity(ent.GetEntIndex(),ent.GetClassName(),ent.GetTargetName(),ent.GetSignifierName(),ent.GetModelName(),ent.GetOrigin(),ent.GetAngles(),getKVString(ent),time)
            thread TrackNPC_threaded(ent)
			return
		case"npc_titan":
			//titan entity
			fdLogNewTitan(ent.GetEntIndex(),ent.GetTargetName(),ent.GetModelName(),ent.GetTeam(),ent.GetOrigin(),ent.GetAngles(),getKVString(ent),time)
            thread TrackNPC_threaded(ent)
			return
		case"npc_spectre":
		case"npc_soldier":
		case"npc_stalker":
			//human sized entity with variation
			fdLogNewHuman(ent.GetEntIndex(),ent.GetSignifierName(),ent.GetModelName(),ent.GetOrigin(),ent.GetAngles(),getKVString(ent),time)
            thread TrackNPC_threaded(ent)
			return
		case"weaponx":
			//log new weapon
            WaitFrame()
			PrintWeapon(ent,time) 
			return
		case"titan_soul":
		case"info_hardpoint":
		case"viewmodel":
		case"item_titan_battery":
		case"env_tonemap_controller":
		case"predicted_first_person_proxy":
		case"worldspawn":
		case"sky_camera":
		case"env_entity_dissolver": //all of those are hits to the harvester
		case"grenade_frag": // player grenades
		case"player":
		case"first_person_proxy":
		case"titan_cockpit":
		case"npc_turret_sentry":
		case"prop_physics":
		case"prop_script":
			return
	}
	
	
	
}



string function getKVString(entity ent)
{
	array<string> knownKVs = 
	[
		"parent",
        "visibilityFlags",
        "gamemode",
        "Zipline",
        "modelskin",
        "path",
        "alwaysAlert",
        "physdamagescale",
        "ZiplineSagHeight",
        "movedirection",
        "resetTime",
        "PassDamageToParent",
        "renderColor",
        "height",
        "solid",
        "scr",
        "physicsmode",
        "spawnflags",
        "Subdiv",
        "defenseActive",
        "secondaryWeaponName",
        "scriptedAnimForceInterrupt",
        "stop",
        "damageTitans",
        "physDamageScale",
        "animReact",
        "fxtime",
        "CollideWithOwner",
        "cpoint",
        "triggerFilterTeamMilitia",
        "GrenadeWeaponName",
        "fogdistoffset",
        "hintString",
        "squadname",
        "ZiplineMoveSpeedScale",
        "AccuracyMultiplier",
        "crashOnDeath",
        "TextureScale",
        "face",
        "disableshadows",
        "disengageEnemyDist",
        "foghalfdisttop",
        "startActivated",
        "strength",
        "RopeMaterial",
        "lifetime",
        "collisionGroup",
        "frequency",
        "deploy",
        "targetname",
        "radius",
        "starts",
        "MoveSpeed",
        "playActivateAnims",
        "static",
        "TeamNum",
        "powerUpType",
        "noSoul",
        "healthEvalMultiplier",
        "minhealthdmg",
        "shutoff",
        "WaitSignal",
        "grenadeWeaponName",
        "airAcceleration",
        "rendercolor",
        "carrying",
        "drop",
        "color",
        "origin",
        "duration",
        "hover",
        "usable",
        "WaitFlag",
        "not",
        "ignoreGamemode",
        "weaponsettings",
        "toggleFlagWhenHacked",
        "bullet",
        "TurretRange",
        "startOpen",
        "npc",
        "disabledHintString",
        "inertiaScale",
        "SpawnAsPhysicsMover",
        "linkedEntsArePushers",
        "custom",
        "rotation",
        "start",
        "message",
        "alwaysalert",
        "soundGroup",
        "singleUse",
        "gravity",
        "desiredSpeed",
        "dissolvetype",
        "channel",
        "ZiplineSagEnable",
        "animIdle",
        "leveled",
        "useAngles",
        "allowShoot",
        "rendermode",
        "fan",
        "airSpeed",
        "enable",
        "killCount",
        "rendercolorFriendly",
        "model",
        "DisableBoneFollowers",
        "text",
        "NextKey",
        "scripted",
        "teamnumber",
        "damagePilots",
        "dangling",
        "editorclass",
        "script",
        "contents",
        "fadein",
        "damageSourceId",
        "scriptDamageType",
        "useDeployAnim",
        "triggerFilterTeamIMC",
        "damage",
        "PositionInterpolator",
        "flag",
        "hotspot",
        "framerate",
        "skin",
        "save",
        "additionalequipment",
        "skip",
        "modelscale",
        "SetFlag",
        "minangle",
        "enabled",
        "amplitude",
        "DoGamepadRumble",
        "VisibilityFlags",
        "fogztop",
        "playEndCap",
        "EnemyAccuracyMultiplier",
        "triggerFilterPlayer",
        "physics",
        "HDRColorScale",
        "holdtime",
        "Width",
        "max",
        "change",
        "health",
        "fogzbottom",
        "SendSignal",
        "trigger",
        "allowshoot",
        "weaponProficency",
        "Type",
        "nodamageforces",
        "fadedist",
        "disable",
        "width",
        "lastMissFastPlayerTime",
        "fogdensity",
        "deathScriptFuncName",
        "msg",
        "rotate",
        "leveledplaced",
        "use",
        "sound",
        "body",
        "FieldOfViewAlert",
        "accuracyMultiplier",
        "motionActivated",
        "TextureScroll",
        "TitanType",
        "startDisconnected",
        "fadeout",
        "settings",
        "CollisionGroup",
        "tempJob",
        "ZiplineAutoDetachDistance",
        "LaserTarget",
        "LinkedJobsOnly",
        "hardpointGroup",
        "triggerFilterNonCharacter",
        "Slack",
        "job",
        "FieldOfView",
        "doScheduleChangeSignal",
        "triggerFilterNpc",
        "ease",
        "angles",
        "startdark",
        "teleport",
        "scale",
        "GlowProxySize",
        "spawnFlags",
        "foghalfdistbottom",
        "soundName",
        "multiUseDelay",
        "renderamt",
        "magnitude",
        "forceVisibleInPhaseShift",
        "player",
        "move",
        "WeaponProficiency",
        "VisiblityFlags",
        "clear",
        "physicsBattery",
        "ProficiencyAdjust",
        "onground",
        "follow",
        "forceontosky",
        "electricEffect",
        "unlink",
        "triggerTarget",
        "lastSuppressionTime",

	]

	string ret 
	foreach(string key in knownKVs)
	{
		if(ent.HasKey(key))
		{
			ret += ";"+key + ":" + ent.GetValueForKey(key) 
		}
	}
	return ret
}

void function TrackNPC_threaded(entity ent)
{	
	if( !IsNewThread())
		return
	if(!IsValid(ent))
		return
	
	int EntID = ent.GetEntIndex()
	
	while(IsAlive(ent))
	{
		fdLogPos(EntID,ent.GetOrigin(),ent.GetAngles(),Time())
		
		WaitFrame()
	}
	fdLogDeath(EntID,Time())
}

void function TrackEntity_threaded(entity ent)
{	
	if( !IsNewThread())
		return
	if(!IsValid(ent))
		return
	
	int EntID = ent.GetEntIndex()
	
	while(IsValid(ent))
	{
		fdLogPos(EntID,ent.GetOrigin(),ent.GetAngles(),Time())
		
		WaitFrame()
	}
	fdLogDeath(EntID,Time()) //death equals removal for not alive tracked entitys
}



