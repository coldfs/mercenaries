
function IsMonster(v)
	
--TraceAI ("ATTACK_ "..tonumber(string.sub(tostring(v),5)))
if tonumber(string.sub(tostring(v),5))~=nil then
if (tonumber(string.sub(tostring(v),5)) > 10000) then
		return 1
	else
		return 0
	end
end
end

function IsPlayer(id)
	if (string.len(tostring(id)) < 8) then
		return 1
	else
		return 0
	end
end


function IsFriend(id)
	if (id==GetV(V_OWNER,MyID)) then
		return 1
	elseif (id~= MyID) then
		friendclass=MyFriends[id]
		if (friendclass==FRIEND or friendclass==RETAINER) then
			return 1
		end
	end
	return 0
end


function IsFriendOrSelf(id)
	if (id==GetV(V_OWNER,MyID) or id == MyID) then
		return 1
	else
		if (MyFriends[id]~=nil) then
			return 1	
		end
	end
	return 0
end



--#####################################
--### Targeting Routines start here ###
--#####################################
--[[
targets[actorid]=

MotionClass
-1 = Dead
0  = Stand
1  = Moving
2  = Flinch
3  = Attacking
4  = Skilling
5  = Casting
6  = Other

TargetClass
-2  = Non-friend player
-1  = Monster
0  = None
1  = Self
2  = Friend/Owner
]]--]]

function GetFriendTargets() -- returns list of targets of friends who are attacking
	local targets = {}
	for i,v in ipairs (GetActors()) do
		if (IsFriend(v) == 1) then
			motion=GetV(V_MOTION,v)
			target=GetV(V_TARGET,v)
			if (IsMonster(target)==1) then
				tact=GetTact(TACT_BASIC,target)
				if (FriendAttack[motion]==1 and tact > 0 and tact ~=9) then
					targets[target]={MotionClassLU[GetV(V_MOTION,target)],GetTargetClass(target),GetTact(TACT_BASIC,target),GetTact(TACT_CAST,target)}
					
				end
			end
		end
	end
	return targets
end
-- aggro arguments
-- 2 = snipe
-- 1 = aggro
-- 0 = nonaggro
-- -1 = tank
-- -2 = rescue


function	GetEnemyList (myid,aggro)
	local owner  = GetV(V_OWNER,myid)
	local enemys = {}
	if aggro==2 then
		sskill,slevel=GetSAtkSkill(MyID)
		oskill,olevel=GetAtkSkill(MyID)
		mskill,mlevel=GetMinionSkill(MyID)
	end
	TraceAI("GetEnemyList with aggro "..aggro)
	for k,v in pairs(Targets) do
		tact = GetTact(TACT_BASIC,k)
		casttact=GetTact(TACT_CAST,k)
		if tact==TACT_TANKMOB then
			if GetAggroCount() > AutoMobCount then
				tact = TACT_ATTACK_M
			else
				tact = TACT_TANK
			end
		end
		--TraceAI("Target"..k.." tact:"..tact.." Motion"..v[1].." TClass"..v[2])
		if (0 < tact and (tact < 5 or tact >9) and aggro==1 and (DoNotAttackMoving ~=1 or v[1]~=1) and (tact ~= 14 or AttackLastFullSP==0 or SPPercent(MyID)==100)) or  (tact > 9 and tact < 13 and aggro == 2 and k~=MyEnemy) or  (v[2]>0 and tact>0 and (tact~=9 or v[2]==1) and (v[1]==3 or casttact >= CAST_REACT) and aggro~=2 and (aggro > -1 or (aggro==-2 and IsRescueTarget(k)==1))) or (tact == -1 and aggro==-1 and v[2]~=1) then
			--TraceAI("Tactics say to attack:"..k)
			if (IsNotKS(myid,k)==1 and v[1] > -1) then
				--TraceAI("Is alive and not a KS")
				if aggro == 0 or (aggro~=2 and v[2]>0) then 
					if (GetMoveBounds() >= GetDistanceRect(owner,k)) then
						--TraceAI("Adding to target list: "..k)
						r={v[1],v[2],tact,casttact}
						enemys[k] = r
					--else 
					--	tempx,tempy=GetV(V_POSITION,owner)
					--	targx,targy=GetV(V_POSITION,k)
					--	TraceAI("target ignored "..k.." mypos "..tempx..","..tempy.." enemy "..targx..","..targy.." bounds "..GetMoveBounds().."dist "..GetDistanceRect(owner,k))
					end
				elseif aggro~=2 then
					if (GetAggroDist() >= GetDistanceA(owner,k)) then
						TraceAI("Adding to target list: "..k)
						r={v[1],v[2],tact,casttact}
						enemys[k] = r
					end
				else -- Sniping - so we need to check range on skill, instead of aggrodist
					dist = GetDistanceA(MyID,k)
					tact_skill_class=(GetTact(TACT_SKILLCLASS,k))
					if tact_skill_class==CLASS_MINION and mskill~=0 then
						if dist <= GetSkillInfo(mskill,2,mlevel) then
							r={v[1],v[2],tact,casttact}
							enemys[k] = r
						end
					elseif sskill~=0 and tact_skill_class~=CLASS_OLD then
						if dist <= GetSkillInfo(sskill,2,slevel) then
							r={v[1],v[2],tact,casttact}
							enemys[k] = r
						end
					elseif oskill~=0 and tact_skill_class~=CLASS_S then
						if dist <= GetSkillInfo(oskill,2,olevel) then
							r={v[1],v[2],tact,casttact}
							enemys[k] = r
						end
					end
				end
			end
		end
	end
	return enemys
end

-- format of return
-- enemys[n][1] = Motion Class
-- enemys[n][2] = Target Class
-- enemys[n][3] = tact
-- enemys[n][4] = casttact

function SelectEnemy(enemys,curenemy)
	local min_priority=-1
	local priority
	local min_dis = 100
	local dis
	--local min_aggro = -1
	--local aggro = 0
	local result=0
	local max_reachable=1
	--local min_mobcount=1
	--local mobcount=0
	if curenemy~=nil then -- it's an opportunistic attack
		local dist = GetDistanceA(MyID,curenemy)
		local aggrotemp=0
		if IsFriendOrSelf(GetV(V_TARGET,curenemy)) ==1 then
			aggrotemp=1
		end
		min_priority=convpriority(GetTact(TACT_BASIC,curenemy),aggrotemp)
		if dist < 3 then 
			return 0
		else
			min_dis = dist - 3
		end
	end
	for k,v in pairs(enemys) do
		local basepriority = v[3] -- basic tact
		if v[2]>0 and (v[1]==3 or v[4]>=CAST_REACT) then
			aggro=1
		else
			aggro=0
		end
		priority=convpriority(basepriority,aggro)
		--TraceAI(k.." "..basepriority.." "..priority)
		--elseif ((priority==2 or priority==5) and (v[1]==3 or v[4]>=CAST_REACT)) then
		--	aggro=-1
		--elseif then	
		--aggro = 1
		--else
		--	aggro=0
		--end
		dis = GetDistanceA (MyID,k)
		unreachable=Unreachable[k]
		if unreachable == nil then
			unreachable=0
		end
		
		--TraceAI(priority.."/"..min_priority.." "..dis.."/"..min_dis.." "..unreachable.."/"..max_reachable)
		if (unreachable <= max_reachable) then
			--if (aggro >= min_aggro) then
				if (priority > min_priority or (priority==min_priority and dis < min_dis)) then
					--if (dis < min_dis) then
						result = k
						min_dis = dis
						min_priority=priority
						--min_aggro=aggro
						max_reachable=unreachable
					--end
				end
			--end
		end
	end
	if max_reachable==1 then
		AllTargetUnreachable=1
	else 
		AllTargetUnreachable=0
	end
	--TraceAI("SelectEnemy returning target "..result)
	return result
end
function convpriority(base,agr)
	local priority
	if base > 9 and base < 13 then --Snipe modes are to be treated as attack
		base = base-8
	end
	if base == 13 then
		if agr == 1 then
			base = 7
		else 
			base = 2
		end
	end
	if base == 14 then
		base= 1
	end
	if base>6 and agr==1 then
		priority=base
	elseif base==4 or base==3 or base==15 then
		priority=base+1
		if agr==0 then 
			priority=priority-2
		end
	elseif (priority==5 and aggro==1) then 
		return 2
	elseif base==2 then
		return 1
	else
		return 0
	end
	return priority
end


--#########################
--### GetSkill functions###
--#########################

function GetSAtkSkill(myid)
	local skill = 0
	local level = 0
	if (IsHomun(myid)==1) then
		htype=GetV(V_HOMUNTYPE,myid)
		if htype > 47 then -- it's a Homun S
			if htype==EIRA and UseEiraEraseCutter==1 then
				skill=MH_ERASER_CUTTER
				if EiraEraseCutterLevel==nil then
					level=4
				else
					level=EiraEraseCutterLevel
				end
			elseif htype==BAYERI and UseBayeriStahlHorn==1 then
				skill=MH_STAHL_HORN
				if BayeriStahlHornLevel==nil then
					level=5
				else
					level=BayeriStahlHornLevel
				end
			elseif htype==SERA and UseSeraParalyze==1 then
				skill=MH_NEEDLE_OF_PARALYZE
				if SeraParalyzeLevel==nil then
					level=5
				else
					level=SeraParalyzeLevel
				end
			elseif htype==ELEANOR and UseEleanorSonicClaw==1 and ( EleanorMode==0 or EleanorDoNotSwitchMode==1 ) then
				skill=MH_SONIC_CRAW
				if EleanorSonicClawLevel==nil then
					level=5
				else
					level=EleanorSonicClawLevel
				end
			elseif htype==ELEANOR and UseEleanorTinderBreaker==1 and EleanorMode==1 then
				skill=MH_TINDER_BREAKER
				if EleanorTinderBreakerLevel==nil then
					level=5
				else
					level=EleanorTinderBreakerLevel
				end
			end
		end
		if level ~=0 then
			return skill,level
		end
	end
	return 0,0
end

function GetComboSkill(myid)
	local skill = 0
	local level = 0
	if (IsHomun(myid)==1) then
		htype=GetV(V_HOMUNTYPE,myid)
		if htype==ELEANOR then
			if EleanorMode==0 or EleanorDoNotSwitchMode==1 then
				if ComboSCTimeout > GetTick() and MySpheres >= AutoComboSpheres then
					skill=MH_SILVERVEIN_RUSH
					if EleanorSilverveinLevel==nil then
						level=5
					else
						level=EleanorSilverveinLevel
					end
				elseif ComboSVTimeout > GetTick()  then
					skill=MH_MIDNIGHT_FRENZY
					if EleanorMidnightLevel==nil then
						level=5
					else
						level=EleanorMidnightLevel
					end
				end
			end
		end
		if level ~=0 then
			return skill,level
		end
	end
	return 0,0
end

function GetGrappleSkill(myid)
	local skill = 0
	local level = 0
	if (IsHomun(myid)==1) then
		htype=GetV(V_HOMUNTYPE,myid)
		if htype==ELEANOR and MySpheres >= AutoComboSpheres then
			if EleanorMode==1 or EleanorDoNotSwitchMode==1 then
				if ComboSCTimeout > GetTick() then
					if MySpheres >= AutoComboSpheres -1 then
						skill=MH_CBC
						if EleanorCBCLevel==nil then
							level=5
						else
							level=EleanorCBCLevel
						end
					end
				elseif ComboSVTimeout > GetTick() then
					if MySpheres >= AutoComboSpheres -1 then
						skill=MH_EQC
						if EleanorEQCLevel==nil then
							level=5
						else
							level=EleanorEQCLevel
						end
					end
				elseif MySpheres >= AutoComboSpheres then
					skill=MH_TINDER_BREAKER
					if EleanorTinderBreakerLevel==nil then
						level=5
					else
						level=EleanorTinderBreakerLevel
					end				
				end
			end
		end
		if level ~=0 then
			return skill,level
		end
	end
	return 0,0
end

function GetAtkSkill(myid)
	local skill = 0
	local level = 0
	if (IsHomun(myid)==1) then
		htype=GetV(V_HOMUNTYPE,myid)
		if htype < 17 then
			homuntype=modulo(GetV(V_HOMUNTYPE,myid),4)
		else
			homuntype=modulo(OldHomunType,4)
		end
		if (homuntype==0) then -- It's a vani!
			skill=HVAN_CAPRICE
			if GetTick() < AutoSkillCooldown[skill] then
				level=0
				skill=0
			elseif (VanCapriceLevel==nil) then
				level=5
			else
				level=VanCapriceLevel
			end
		elseif	(homuntype==3) then -- It's a filer!
			skill=HFLI_MOON
			if GetTick() < AutoSkillCooldown[skill] then
				level=0
				skill=0
			elseif (FilerMoonlightLevel==nil) then
				level=5
			else
				level=FilerMoonlightLevel
			end
		end		
		if level ~=0 then
			return skill,level
		end
	else
		for i,v in ipairs(AtkSkillList) do
			level = SkillList[MercType][v]
			if level ~= nil then
				skill=v
				return skill,level
			end
		end
	end
	return 0,0
end

function GetPushbackSkill(myid)
	if (IsHomun(myid)==1) then
		return 0,0
	else
		for i,v in ipairs(PushSkillList) do
			level = SkillList[MercType][v]
			if level ~= nil then
				skill=v
				return skill,level
			end
		end
	end
	return 0,0
end


function GetDebuffSkill(myid)
	if (IsHomun(myid)==1) then
		if GetV(V_HOMUNTYPE,MyID)==EIRA and UseEiraSilentBreeze==1 then
			skill=MH_SILENT_BREEZE
			if EiraSilentBreezeLevel==nil then
				level=5
			else
				level=EiraSilentBreezeLevel
			end
			return skill,level
		elseif GetV(V_HOMUNTYPE,MyID)==DIETER and UseDieterVolcanicAsh==1 then
			skill=MH_VOLCANIC_ASH
			level=5
			local t = GetTick()
			if (AshTimeout[1] < t or AshTimeout[2] < t or AshTimeout[3] < t) then
				return skill,level
			else 
				return 0,0
			end
		end
	else
		for i,v in ipairs(DebuffSkillList) do
			level = SkillList[MercType][v]
			if level ~= nil then
				skill=v
				return skill,level
			end
		end
	end
	return 0,0
end

function GetMinionSkill(myid)
	local level,skill=0,0
	if (IsHomun(myid)==1) then
		if GetV(V_HOMUNTYPE,MyID)==SERA and UseSeraCallLegion==1 then
			skill=MH_SUMMON_LEGION
			TraceAI("GetMinionSkill"..skill)
			if SeraCallLegionLevel == nil then
				level=5
			elseif SeraCallLegionLevel < 1 then
				skill,level=0,0
			elseif SeraCallLegionLevel > 5 then
				level=5
			else
				level=SeraCallLegionLevel
			end
			TraceAI("GetMinionSkill "..skill..level)
			if AutoSkillCooldown[skill]~=nil then
				if GetTick() < AutoSkillCooldown[skill] then -- in cooldown
					level=0
					skill=0
				end
			end
			return skill,level
		end
	end
	return 0,0
end

function GetProvokeSkill(myid)
	if (IsHomun(myid)==1) then
		return 0,0
	else
		level=SkillList[MercType][MER_PROVOKE]
		if level ~=nil then
			return MER_PROVOKE,level
		end
	end
	return 0,0
end

function GetSacrificeSkill(myid)
	level=SkillList[MercType][ML_DEVOTION]
	if level ~=nil then
		return ML_DEVOTION,level
	end
	return 0,0
end

function GetMobSkill(myid)
	local skill = 0
	local level = 0
	if (IsHomun(myid)==1) then
	
		htype=GetV(V_HOMUNTYPE,MyID)
		if htype <17 then
			skill=0
		else -- it's a homun s
			if htype==EIRA and UseEiraXenoSlasher==1 then
				skill=MH_XENO_SLASHER
				if EiraXenoSlasherLevel==nil then
					level=4
				else
					level=EiraXenoSlasherLevel
				end
			elseif htype==BAYERI and UseBayeriHailegeStar==1 then
				skill=MH_HEILIGE_STANGE
				if BayeriHailegeStarLevel==nil then
					level=5
				else
					level=BayeriHailegeStarLevel
				end
			elseif htype==SERA and UseSeraPoisonMist==1 and PoisonMistMode==0 then
				skill=MH_POISON_MIST
				if SeraPoisonMistLevel==nil then
					level=5
				else
					level=SeraPoisonMistLevel
				end
			elseif htype==DIETER and UseDieterLavaSlide==1 and LavaSlideMode==0 then
				skill=MH_LAVA_SLIDE
				if DieterLavaSlideLevel==nil then
					level=5
				else
					level=DieterLavaSlideLevel
				end
			end 
			if AutoSkillCooldown[skill]~=nil then
				if GetTick() < AutoSkillCooldown[skill] then -- in cooldown
					level=0
					skill=0
				end
			end
		end
		return skill,level
	else -- SO MUCH EASIER WHEN LEVEL ISN'T SELECTABLE!!!!
		for i,v in ipairs(MobSkillList) do
			level = SkillList[MercType][v]
			if level ~= nil then
				skill=v
				return skill,level
			end
		end
	end
	return 0,0
end


function	GetQuickenSkill(myid)
	local level = 0
	local skill = 0
	if (IsHomun(myid)==1) then
		htype=GetV(V_HOMUNTYPE,myid)
		if htype < 17 then
			homuntype=modulo(GetV(V_HOMUNTYPE,myid),4)
		else
			homuntype=modulo(OldHomunType,4)
		end
		if (homuntype==1) then -- It's a lif!
			skill=HLIF_CHANGE
			level=3
		elseif	(homuntype==3) then -- It's a filer!
			skill=HFLI_FLEET
			if (FilirFlitLevel==nil) then
				level=5
			else
				level=FilirFlitLevel
			end
		elseif  (homuntype==2) then --it's an amistr
			skill=HAMI_BLOODLUST
			level=3
		end
	else
		level=SkillList[MercType][MER_QUICKEN]
		if level ~=nil then
			skill=MER_QUICKEN
		end
	end
	if AutoSkillCooldown[skill]~=nil then
		if GetTick() < AutoSkillCooldown[skill] then -- in cooldown
			level=0
			skill=0
		end
	end
	return skill,level
end

function	GetSOffensiveSkill(myid)
	local level = 0
	local skill = 0
	local skillopt = 0
	if (IsHomun(myid)==1) then
		htype=GetV(V_HOMUNTYPE,myid)
		if (htype==BAYERI and UseBayeriAngriffModus~=0) then
			skill=MH_ANGRIFFS_MODUS
			level = 5
			skillopt=UseBayeriAngriffModus
		elseif	(htype==DIETER and UseDieterMagmaFlow~=0) then
			skill=MH_MAGMA_FLOW
			level = 5
			skillopt=UseDieterMagmaFlow
		end
		return skill,level,skillopt
	else
		level=SkillList[MercType][MER_BLESSING]
		if level~=nil then
			skill=MER_BLESSING
		else
			level=0
		end
		return skill,level,UseBlessingSelf
	end
end

function	GetSDefensiveSkill(myid)
	local level = 0
	local skill = 0
	local skillopt=0
	if (IsHomun(myid)==1) then
		htype=GetV(V_HOMUNTYPE,myid)
		if (htype==BAYERI and UseBayeriGoldenPherze~=0) then
			skill=MH_GOLDENE_FERSE
			level = 5
			skillopt=UseBayeriGoldenPherze
		elseif	(htype==DIETER and UseDieterGraniticArmor~=0) then
			skill=MH_GRANITIC_ARMOR
			level = 5
			skillopt=UseDieterGraniticArmor
		end
		return skill,level,skillopt
	else
		level=SkillList[MercType][MER_KYRIE]
		if level~=nil then
			skill=MER_KYRIE
		else
			level=0
		end
		return skill,level,UseKyrieSelf
	end
	return 0,0,0
end

function	GetSOwnerBuffSkill(myid)
	local level = 0
	local skill = 0
	local skillopt = 0
	if (IsHomun(myid)==1) then
		htype=GetV(V_HOMUNTYPE,myid)
		if (htype==EIRA and UseEiraOveredBoost~=0) then
			skill=MH_OVERED_BOOST
			level = 5
			skillopt=UseEiraOveredBoost
		elseif	(htype==DIETER and UseDieterPyroclastic~=0) then
			skill=MH_PYROCLASTIC
			level = 5
			skillopt=UseDieterPyroclastic
		end
		return skill,level,skillopt
	else
		level=SkillList[MercType][MER_INCAGI]
		if level~=nil then
			skill=MER_INCAGI
		else
			level=0
		end
		return skill,level,UseIncAgiSelf
	end
	return 0,0,0
end

function GetSightOrAoE(myid)
	local level = 0
	local skill = 0
	local skillopt = 0
	if (IsHomun(myid)==1) then
		htype=GetV(V_HOMUNTYPE,myid)
		if	(htype==DIETER and UseDieterLavaSlide==1 and LavaSlideMode~=0) then
			skill=MH_LAVA_SLIDE
			level = 5
			skillopt=LavaSlideMode
		elseif (htype==SERA and PoisonMistMode~=0 and UseSeraPoisonMist==1) then
			skill=MH_POISON_MIST
			level = 5
			skillopt=PoisonMistMode
		end
	else
		if MercType==2 then
			skill=MER_SIGHT
			level=1
			skillopt=UseAutoSight
		end
	end
	if AutoSkillCooldown[skill]~=nil then
		if GetTick() < AutoSkillCooldown[skill] then -- in cooldown
			level=0
			skill=skill
		end
	end
	return skill,level,skillopt
end
function	GetGuardSkill(myid)
	local level = 0
	local skill = 0
	if (IsHomun(myid)==1) then
		htype=GetV(V_HOMUNTYPE,myid)
		if htype < 17 then
			homuntype=modulo(GetV(V_HOMUNTYPE,myid),4)
		else
			homuntype=modulo(OldHomunType,4)
		end
		if (homuntype==1) then -- It's a lif!
			skill=HLIF_AVOID
			if (LifEscapeLevel==nil) then
				level=5
			else
				level=LifEscapeLevel
			end
		elseif (homuntype==2) then -- It's an amistr!
			skill=HAMI_DEFENCE
			if (AmiBulwarkLevel==nil) then
				level=5
			else
				level=AmiBulwarkLevel
			end
		elseif (homuntype==3) then -- It's an filir!
			skill=HFLI_SPEED
			if (FilirAccelLevel==nil) then
				level=5
			else
				level=FilirAccelLevel
			end
		end
		return skill,level
	else
		for i,v in ipairs(GuardSkillList) do
			level = SkillList[MercType][v]
			if level ~= nil then
				skill=v
				return skill,level
			end
		end
	end
	return 0,0
end

function	GetOffensiveOwnerSkill(myid)
	local level = 0
	local skill = 0
	local skillopt = 0
	if (IsHomun(myid)==1) then
		return 0,0,0
	else
		level=SkillList[MercType][MER_BLESSING]
		if level~=nil then
			skill=MER_BLESSING
		else
			level=0
		end
		return skill,level,UseBlessingOwner
	end
end
function	GetDefensiveOwnerSkill(myid)
	local level = 0
	local skill = 0
	local skillopt = 0
	if (IsHomun(myid)==1) then
		if GetV(V_HOMUNTYPE,MyID)==SERA and UseSeraPainkiller~=0 then
			level=5
			return MH_PAIN_KILLER,level,UseSeraPainkiller
		else
			return 0,0,0
		end
	else
		level=SkillList[MercType][MER_KYRIE]
		if level~=nil then
			skill=MER_KYRIE
		else
			level=0
		end
		return skill,level,UseKyrieOwner
	end
end
function	GetOtherOwnerSkill(myid)
	local level = 0
	local skill = 0
	local skillopt = 0
	if (IsHomun(myid)==1) then
		return 0,0,0
	else
		level=SkillList[MercType][MER_INCAGI]
		if level~=nil then
			skill=MER_INCAGI
		else
			level=0
		end
		return skill,level,UseIncAgiOwner
	end
end



function GetHealingSkill(myid)
	local level = 0
	local skill = 0
	if (IsHomun(myid)==1) then
		htype=GetV(V_HOMUNTYPE,myid)
		if htype < 17 then --if it's not a homun S just run it through modulo. 
			homuntype=modulo(GetV(V_HOMUNTYPE,myid),4)
		else --If it's a homun S, get the OldHomunType
			if homuntype == EIRA and HealOwnerBreeze == 1 then --Handling for Eira silent breeze
				skill=MH_SILENT_BREEZE
				if GetTick() < AutoSkillCooldown[skill] then
					level=0
				else
					level=5
				end
				return skill,level
			end
			homuntype=modulo(OldHomunType,4)
		end
		if (homuntype==1) then -- It's a lif
			skill=HLIF_HEAL
			if GetTick() < AutoSkillCooldown[skill] then
				level=0
			elseif (LifHealLevel==nil) then
				level=5
			else
				level=LifHealLevel
			end
		elseif homuntype==0 then -- It's a vani
			skill=HVAN_CHAOTIC
			if GetTick() < AutoSkillCooldown[skill] then
				level=0
			elseif (VaniChaoticLevel==nil) then
				level=3
			else
				level=VaniChaoticLevel
			end
		end
	else
		--currently no merc healing skills
	end
	return skill,level
end

function GetSnipeSkill(myid)
	return GetAtkSkill(myid)
end

function GetTargetedSkills(myid)
	s,l=GetAtkSkill(myid)
	Mainatk={MAIN_ATK,s,l}
	s,l=GetSAtkSkill(myid)
	Satk={S_ATK,s,l}
	s,l=GetComboSkill(myid)
	ComboAtk={COMBO_ATK,s,l}
	s,l=GetGrappleSkill(myid)
	GrappleAtk={GRAPPLE_ATK,s,l}
	s,l=GetMobSkill(myid)
	Mobatk={MOB_ATK,s,l}
	s,l=GetDebuffSkill(myid)
	Debuffatk={DEBUFF_ATK,s,l}
	s,l=GetMinionSkill(myid)
	Minionatk={MINION_ATK,s,l}
	result={Mainatk,Satk,ComboAtk,GrappleAtk,Mobatk,Debuffatk,Minionatk}
	return result
end

function GetSkillInfo(skill,info,level)
	if skill~=nil and info~=nil then
		if SkillInfo[skill]~=nil then
			local t=SkillInfo[skill][info]
			if t~=nil then
				if level ==nil and type(t)=="table" then
					----logappend("AAI_ERROR","Attempted to call GetSkillInfo() with only 2 arguments "..skill.." "..info)
					if type(t)~="table" and t~=nil then
						return t
					else
						return -1
					end
				elseif type(t)~="table" then
					return t
				elseif SkillInfo[skill][info][level]~=nil then
					return SkillInfo[skill][info][level]
				else
					--logappend("AAI_ERROR","GetSkillInfo(): No skill info type "..info.." found for this level "..FormatSkill(skill,level))
					if info==2 then
						local r=0
						if (_VERSION=="Lua 5.1") then
							r=GetV(V_SKILLATTACKRANGE_LEVEL,MyID,skill,level)
						else
							r=GetV(V_SKILLATTACKRANGE,MyID,skill)
						end
						----logappend("AAI_ERROR","GetSkillInfo(): Range for unknown skill requested, returning builtin value"..r.." "..skill)
						return r
					elseif SkillInfo[skill][info][1]~= nil then
						return SkillInfo[skill][info][1]
					else
						return 0
					end
				end
			else
				------logappend("AAI_ERROR","GetSkillInfo(): No skill info type "..info.." found for this skill "..FormatSkill(skill,level).." called by ")
				if info==2 then
					------logappend("AAI_ERROR","GetSkillInfo(): Range for unknown skill requested, returning builtin value"..GetV(V_SKILLATTACKRANGE,MyID,skill))
					return GetV(V_SKILLATTACKRANGE,MyID,skill)
				elseif info==7 then
					return 1
				else
					return 0
				end
			end
		else
			------logappend("AAI_ERROR","GetSkillInfo(): No skill info found for this skill "..FormatSkill(skill,level).." info type requested "..info)
			if info==2 then
				------logappend("AAI_ERROR","GetSkillInfo(): Range for unknown skill requested, returning builtin value"..GetV(V_SKILLATTACKRANGE,MyID,skill))
				return GetV(V_SKILLATTACKRANGE,MyID,skill)
			elseif info==7 then
				return 1
			else
				return 0
			end
		end
	else
		if skill==nil then
			skill="nil"
		end
		if level==nil then
			level="nil"
		end
		if info==nil then
			info="nil"
		end
		------logappend("AAI_ERROR","GetSkillInfo(): Invalid arguments - skill="..skill.." level="..level.." info="..info)
		return 0
	end
end