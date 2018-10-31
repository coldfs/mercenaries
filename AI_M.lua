
require "AI_sakray\\USER_AI\\Const"
require "AI_sakray\\USER_AI\\Util"
require "AI_sakray\\USER_AI\\MyFunc"
require "AI_sakray\\USER_AI\\Commands"
require "AI_sakray\\USER_AI\\States"
require "AI_sakray\\USER_AI\\Spell"
require "AI_sakray\\USER_AI\\A_Plants"
require "AI_sakray\\USER_AI\\A_Friends.lua"

function AI(myid)

	MyID = myid
	-- command
	local msg  = GetMsg (myid)
	-- reserved command
	local rmsg = GetResMsg (myid)

	--MYTickTime	= MYTickTime+1
	--QuickenTimeout = GetTick()
	--logProxy ("MYTickTime "..MYTickTime)
	--logProxy ("MyState "..MyState)

	-- Choose spell (Active and Passive)
	Spel_on_self(myid)

	if msg[1] == NONE_CMD then
		if rmsg[1] ~= NONE_CMD then
			if List.size(ResCmdList) < 10 then
				List.pushright (ResCmdList,rmsg) -- ���� ��� ����
			end
		end
	else
		List.clear (ResCmdList)	-- ���ο� ����� �ԷµǸ� ���� ��ɵ��� �����Ѵ�.
		ProcessCommand (msg)	-- ��ɾ� ó��
	end

	--No active commands - let do something, depending on current state
	ProcessState()

end

function ProcessState()
	if (MyState == IDLE_ST) then
		OnIDLE_ST ()
	elseif (MyState == CHASE_ST) then
		OnCHASE_ST ()
	elseif (MyState == ATTACK_ST) then
		OnATTACK_ST ()
	elseif (MyState == FOLLOW_ST) then
		OnFOLLOW_ST ()
	elseif (MyState == MOVE_CMD_ST) then
		OnMOVE_CMD_ST ()
	elseif (MyState == STOP_CMD_ST) then
		OnSTOP_CMD_ST ()
	elseif (MyState == ATTACK_OBJECT_CMD_ST) then
		OnATTACK_OBJECT_CMD_ST ()
	elseif (MyState == ATTACK_AREA_CMD_ST) then
		OnATTACK_AREA_CMD_ST ()
	elseif (MyState == PATROL_CMD_ST) then
		OnPATROL_CMD_ST ()
	elseif (MyState == HOLD_CMD_ST) then
		OnHOLD_CMD_ST ()
	elseif (MyState == SKILL_OBJECT_CMD_ST) then
		OnSKILL_OBJECT_CMD_ST ()
	elseif (MyState == SKILL_AREA_CMD_ST) then
		OnSKILL_AREA_CMD_ST ()
	elseif (MyState == FOLLOW_CMD_ST) then
		OnFOLLOW_CMD_ST ()
	end
end

function ProcessCommand (msg)
	if(msg[1] == MOVE_CMD) then
		OnMOVE_CMD (msg[2],msg[3])
		logProxy ("MOVE_CMD")
	elseif	(msg[1] == STOP_CMD) then
		OnSTOP_CMD ()
		logProxy ("STOP_CMD")
	elseif	(msg[1] == ATTACK_OBJECT_CMD) then
		OnATTACK_OBJECT_CMD (msg[2])
		logProxy ("ATTACK_OBJECT_CMD")
	elseif	(msg[1] == ATTACK_AREA_CMD) then
		OnATTACK_AREA_CMD (msg[2],msg[3])
		logProxy ("ATTACK_AREA_CMD")
	elseif	(msg[1] == PATROL_CMD) then
		OnPATROL_CMD (msg[2],msg[3])
		logProxy ("PATROL_CMD")
	elseif	(msg[1] == HOLD_CMD) then
		OnHOLD_CMD ()
		logProxy ("HOLD_CMD")
	elseif	(msg[1] == SKILL_OBJECT_CMD) then
		OnSKILL_OBJECT_CMD (msg[2],msg[3],msg[4],msg[5])
		logProxy ("SKILL_OBJECT_CMD")
	elseif	(msg[1] == SKILL_AREA_CMD) then
		OnSKILL_AREA_CMD (msg[2],msg[3],msg[4],msg[5])
		logProxy ("SKILL_AREA_CMD")
	elseif	(msg[1] == FOLLOW_CMD) then
		OnFOLLOW_CMD ()
		logProxy ("FOLLOW_CMD")
	end
end

function IsNotKS(myid,target)
	--logProxy("Checking for KS:"..target)
	local targettarget=GetV(V_TARGET,target)
	local motion=GetV(V_MOTION,target)
	local tactks=KS_NEVER --GetTact(TACT_KS,target)
	if (target==MyEnemy and BypassKSProtect==1) then --If owner has told homun to attack explicity, let it.
		return 1
	end
	if target==nil then
		logProxy("IsNotKS")
	end
	if (IsPlayer(target)==1) then
		--logProxy("PVP - not KS")
		return 1
	elseif (IsFriend(targettarget)==1 or targettarget==myid) then
		--logProxy("Not KS - "..target.." fighting friend: "..targettarget)
		return 1
	elseif ((tactks==KS_POLITE or DoNotAttackMoving ==1) and motion==MOTION_MOVE) then
		return 0
	elseif (tactks==KS_ALWAYS) then
		--logProxy("It's an FFA monster, not a KS")
		return 1
	elseif targettarget > 0 and IsMonster(targettarget)~=1  then
		--logProxy("Is KS - "..target.." attacking player "..targettarget.." motion "..motion)
		return 0
	else
		--logProxy("Not Targeted - seeing if anyone is targeting it")
		local actors = GetActors()
		for i,v in ipairs(actors) do
			if (IsMonster(v)~=1 and IsFriendOrSelf(v)==0) then
				if (GetV(V_TARGET,v) == target and (v > 100000 or KSMercHomun ~=1)) then
					--logProxy("Is KS - "..target.." is targeted by "..v)
					return 0
				end
			end
		end
	--logProxy("Not KS - "..target.." is not targeted by any other player.")
	return 1
	end
end

function GetKSReason(myid,target)
	--logProxy("Checking for KS:"..target)
	local targettarget=GetV(V_TARGET,target)
	local motion=GetV(V_MOTION,target)
	local tactks=KS_NEVER --GetTact(TACT_KS,target)
	if (target==MyEnemy and BypassKSProtect==1) then --If owner has told homun to attack explicity, let it.
		return "KS Protect bypassed"
	end
	if target==nil then
		logProxy("IsNotKS")
	end
	if (IsPlayer(target)==1) then
		--logProxy("PVP - not KS")
		return "PVP, not KS"
	elseif ((tactks==KS_POLITE or DoNotAttackMoving ==1) and motion==MOTION_MOVE) then
		return "KS polite aka DoNotAttackMoving"
	elseif (IsFriend(targettarget)==1 or targettarget==myid) then
		--logProxy("Not KS - "..target.." fighting friend: "..targettarget)
		return "Not KS - enemy attacking "..targettarget
	elseif (tactks==KS_ALWAYS) then
		--logProxy("It's an FFA monster, not a KS")
		return "FFA monster"
	elseif targettarget > 0 and IsMonster(targettarget)~=1 then --and Actors[targettarget]==1 then
		--logProxy("Is KS - "..target.." attacking player "..targettarget.." motion "..motion)
		if MyFriends[targettarget]~=nil then
			return "KS - enemy is attacking "..targettarget.." MyFriends: "..MyFriends[targettarget]
		else
			return "KS - enemy is attacking "..targettarget
		end
	else
		--logProxy("Not Targeted - seeing if anyone is targeting it")
		local actors = GetActors()
		for i,v in ipairs(actors) do
			if (IsMonster(v)~=1 and IsFriendOrSelf(v)==0) then
				if (GetV(V_TARGET,v) == target and (v > 100000 or KSMercHomun ~=1)) then
					--logProxy("Is KS - "..target.." is targeted by "..v)
					if MyFriends[v]~=nil then
						return "KS - enemy attacked by "..v.." MyFriends: "..MyFriends[v]
					else
						return "KS - enemy attacked by "..v
					end
				end
			end
		end
	--logProxy("Not KS - "..target.." is not targeted by any other player.")
	return "not KS, not targeted by anything"
	end
end

function	GetOwnerEnemy (myid)
	local result = 0
	local owner  = GetV (V_OWNER,myid)
	local actors = GetActors ()
	local enemys = {}
	local index = 1
	local target
	logProxy ("GetOwnerEnemy")
	for i,v in ipairs(actors) do
		--logProxy ("Get"..i.."also"..v)
		--logProxy ("owner -"..owner.."myid -"..myid)
		if (v ~= owner and v ~= myid) then
			target = GetV (V_TARGET,v)
			logProxy ("target "..target)
			if (target == owner) then
				if (IsMonster(v) == 1) then
					enemys[index] = v
					index = index+1
				else
					local motion = GetV(V_MOTION,i)
					if (motion == MOTION_ATTACK or motion == MOTION_ATTACK2) then
						enemys[index] = v
						index = index+1
					end
				end
			else
				if (IsMonster(v) == 1) then
					enemys[index] = v
					index = index+1
				else
					local motion = GetV(V_MOTION,i)
					if (motion == MOTION_ATTACK or motion == MOTION_ATTACK2) then
						enemys[index] = v
						index = index+1
					end
				end

			end
		end
	end

	local min_dis = 100
	local dis
	for i,v in ipairs(enemys) do
		dis = GetDistance2 (myid,v)
		if (dis < min_dis) then
			result = v
			min_dis = dis
		end
	end
	
	return result
end

function	GetMyEnemy (myid)
	local result = 0
	local type = GetV (V_MERTYPE,myid)
	
	if (type >= ARCHER01 and type <= SWORDMAN10) then
		result = GetMyEnemyA (myid)
	else
		result = GetMyEnemyB (myid)
	end

	return result
end


-------------------------------------------
--  �񼱰��� GetMyEnemy
-------------------------------------------
function	GetMyEnemyA (myid)
	local result = 0
	local owner  = GetV (V_OWNER,myid)
	local actors = GetActors ()
	local enemys = {}
	local index = 1
	local target
	for i,v in ipairs(actors) do
		if (v ~= owner and v ~= myid) then
			target = GetV (V_TARGET,v)
			logProxy ("target "..target)

			if (target == myid) then
				enemys[index] = v
				index = index+1
			end
		end
	end

	local min_dis = 100
	local dis
	for i,v in ipairs(enemys) do
		dis = GetDistance2 (myid,v)
		if (dis < min_dis) then
			result = v
			min_dis = dis
		end
	end

	return result
end

-------------------------------------------
--  ������ GetMyEnemy
-------------------------------------------
function	GetMyEnemyB (myid)
	local result = 0
	local owner  = GetV (V_OWNER,myid)
	local actors = GetActors ()
	local enemys = {}
	local index = 1
	local type
	for i,v in ipairs(actors) do
		if (v ~= owner and v ~= myid) then
			if (1 == IsMonster(v))	then
				enemys[index] = v
				index = index+1
			end
		end
	end

	local min_dis = 100
	local dis
	for i,v in ipairs(enemys) do
		dis = GetDistance2 (myid,v)
		if (dis < min_dis) then
			result = v
			min_dis = dis
		end
	end

	logProxy ("target "..result)

	return result
end
