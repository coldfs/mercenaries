
require "AI_sakray\\USER_AI\\Const"
require "AI_sakray\\USER_AI\\Util"	
require "AI_sakray\\USER_AI\\MyFunc"
require "AI_sakray\\USER_AI\\A_Plants"
dofile( "AI_sakray\\USER_AI\\A_Friends.lua")

-----------------------------
-- state
-----------------------------
IDLE_ST					= 0
FOLLOW_ST				= 1
CHASE_ST				= 2
ATTACK_ST				= 3
MOVE_CMD_ST				= 4
STOP_CMD_ST				= 5
ATTACK_OBJECT_CMD_ST			= 6
ATTACK_AREA_CMD_ST			= 7
PATROL_CMD_ST				= 8
HOLD_CMD_ST				= 9
SKILL_OBJECT_CMD_ST			= 10
SKILL_AREA_CMD_ST			= 11
FOLLOW_CMD_ST				= 12
----------------------------


------------------------------------------
-- global variable
------------------------------------------
MyState				= IDLE_ST	-- ������ ���´� �޽�
MyEnemy				= 0		-- �� id
MyDestX				= 0		-- ������ x
MyDestY				= 0		-- ������ y
MyPatrolX			= 0		-- ���� ������ x
MyPatrolY			= 0		-- ���� ������ y
ResCmdList			= List.new()	-- ���� ��ɾ� ����Ʈ 
MyID				= 0		-- �뺴 id
MySkill				= 0		-- �뺴�� ��ų
MySkillLevel		= 0		-- �뺴�� ��ų ����
MYTickTime		= 0
------------------------------------------


------------- command process  ---------------------

function	OnMOVE_CMD (x,y)
	
	logProxy ("OnMOVE_CMD-1")

	if ( x == MyDestX and y == MyDestY and MOTION_MOVE == GetV(V_MOTION,MyID)) then
		return		-- ���� �̵����� �������� ���� ���̸� ó������ �ʴ´�. 
	end

	local curX, curY = GetV (V_POSITION,MyID)
	if (math.abs(x-curX)+math.abs(y-curY) > 15) then		-- �������� ���� �Ÿ� �̻��̸� (�������� �հŸ��� ó������ �ʱ� ������)
		List.pushleft (ResCmdList,{MOVE_CMD,x,y})			-- ���� ���������� �̵��� �����Ѵ�. 	
		x = math.floor((x+curX)/2)							-- �߰��������� ���� �̵��Ѵ�.  
		y = math.floor((y+curY)/2)							-- 
	end

	Move (MyID,x,y)	
	
	MyState = MOVE_CMD_ST
	MyDestX = x
	MyDestY = y
	MyEnemy = 0
	MySkill = 0

end



function	OnSTOP_CMD ()

	logProxy ("OnSTOP_CMD")

	if (GetV(V_MOTION,MyID) ~= MOTION_STAND) then
		Move (MyID,GetV(V_POSITION,MyID))
	end
	MyState = IDLE_ST
	MyDestX = 0
	MyDestY = 0
	MyEnemy = 0
	MySkill = 0

end



function	OnATTACK_OBJECT_CMD (id)

	logProxy ("OnATTACK_OBJECT_CMD")

	MySkill = 0
	MyEnemy = id
	MyState = CHASE_ST

end



function	OnATTACK_AREA_CMD (x,y)

	logProxy ("OnATTACK_AREA_CMD")

	if (x ~= MyDestX or y ~= MyDestY or MOTION_MOVE ~= GetV(V_MOTION,MyID)) then
		Move (MyID,x,y)	
	end
	MyDestX = x
	MyDestY = y
	MyEnemy = 0
	MyState = ATTACK_AREA_CMD_ST
	
end



function	OnPATROL_CMD (x,y)

	logProxy ("OnPATROL_CMD")

	MyPatrolX , MyPatrolY = GetV (V_POSITION,MyID)
	MyDestX = x
	MyDestY = y
	Move (MyID,x,y)
	MyState = PATROL_CMD_ST

end



function	OnHOLD_CMD ()

	logProxy ("OnHOLD_CMD")

	MyDestX = 0
	MyDestY = 0
	MyEnemy = 0
	MyState = HOLD_CMD_ST

end



function	OnSKILL_OBJECT_CMD (level,skill,id)

	logProxy ("OnSKILL_OBJECT_CMD")

	MySkillLevel = level
	MySkill = skill
	MyEnemy = id
	MyState = CHASE_ST

end



function	OnSKILL_AREA_CMD (level,skill,x,y)

	logProxy ("OnSKILL_AREA_CMD")

	Move (MyID,x,y)
	MyDestX = x
	MyDestY = y
	MySkillLevel = level
	MySkill = skill
	MyState = SKILL_AREA_CMD_ST
	
end



function	OnFOLLOW_CMD ()

	-- ������� �����¿� �޽Ļ��¸� ���� ��ȯ��Ų��. 
	if (MyState ~= FOLLOW_CMD_ST) then
		MoveToOwner (MyID)
		MyState = FOLLOW_CMD_ST
		MyDestX, MyDestY = GetV (V_POSITION,GetV(V_OWNER,MyID))
		MyEnemy = 0 
		MySkill = 0
		logProxy ("OnFOLLOW_CMD")
	else
		MyState = IDLE_ST
		MyEnemy = 0 
		MySkill = 0
		logProxy ("FOLLOW_CMD_ST --> IDLE_ST")
	end

end



function	ProcessCommand (msg)

	if		(msg[1] == MOVE_CMD) then
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




-------------- state process  --------------------


function	OnIDLE_ST ()
	
	logProxy ("OnIDLE_ST")

	local cmd = List.popleft(ResCmdList)
	if (cmd ~= nil) then	
	logProxy ("OnIDLE_ST - end")
		ProcessCommand (cmd)	-- ���� ��ɾ� ó�� 
		return 
	end

	local	object = GetOwnerEnemy (MyID)
	if (object ~= 0) then							-- MYOWNER_ATTACKED_IN
		MyState = CHASE_ST
		MyEnemy = object
		logProxy ("IDLE_ST -> CHASE_ST : MYOWNER_ATTACKED_IN")
		return 
	end

	object = GetMyEnemy (MyID)
	if (object ~= 0) then							-- ATTACKED_IN
		MyState = CHASE_ST
		MyEnemy = object
		logProxy ("IDLE_ST -> CHASE_ST : ATTACKED_IN")
		return
	end

	local distance = GetDistanceFromOwner(MyID)
	logProxy ("distance " ..distance )
	if ( distance > 3 or distance == -1) then		-- MYOWNER_OUTSIGNT_IN
		MyState = FOLLOW_ST
		logProxy ("IDLE_ST -> FOLLOW_ST")
		return
	end

end



function	OnFOLLOW_ST ()

	logProxy ("OnFOLLOW_ST")

	if (GetDistanceFromOwner(MyID) <= 3) then		--  DESTINATION_ARRIVED_IN 
		MyState = IDLE_ST
		logProxy ("FOLLOW_ST -> IDLW_ST - 1")
		return
	elseif (GetV(V_MOTION,MyID) == MOTION_STAND) then
		MoveToOwner (MyID)
		logProxy ("FOLLOW_ST -> FOLLOW_ST")
		return
	end

end



function	OnCHASE_ST ()

	logProxy ("OnCHASE_ST")

	if (true == IsOutOfSight(MyID,MyEnemy)) then	-- ENEMY_OUTSIGHT_IN
		MyState = IDLE_ST
		MyEnemy = 0
		MyDestX, MyDestY = 0,0
		logProxy ("CHASE_ST -> IDLE_ST : ENEMY_OUTSIGHT_IN")
		return
	end

	if (true == IsInAttackSight(MyID,MyEnemy)) then  -- ENEMY_INATTACKSIGHT_IN
		MyState = ATTACK_ST
		logProxy ("CHASE_ST -> ATTACK_ST : ENEMY_INATTACKSIGHT_IN")
		return
	end

	local x, y = GetV (V_POSITION_APPLY_SKILLATTACKRANGE, MyEnemy, MySkill, MySkillLevel)
	if (MyDestX ~= x or MyDestY ~= y) then			-- DESTCHANGED_IN
		MyDestX, MyDestY = GetV (V_POSITION_APPLY_SKILLATTACKRANGE, MyEnemy, MySkill, MySkillLevel)
		Move (MyID,MyDestX,MyDestY)
		logProxy ("CHASE_ST -> CHASE_ST : DESTCHANGED_IN")
		return
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
	elseif targettarget > 0 and IsMonster(targettarget)~=1 and Actors[targettarget]==1 then
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

function	OnATTACK_ST ()

	logProxy ("OnATTACK_ST")

	
	if (true == IsOutOfSight(MyID,MyEnemy)) then	-- ENEMY_OUTSIGHT_IN
		MyState = IDLE_ST
		logProxy ("ATTACK_ST -> IDLE_ST -- ENEMY_OUTSIGHT_IN")
		return 
	end

	if (MOTION_DEAD == GetV(V_MOTION,MyEnemy)) then   -- ENEMY_DEAD_IN
		MyState = IDLE_ST
		logProxy ("ATTACK_ST -> IDLE_ST -- ENEMY_DEAD_IN")
		return
	end

	if(IsNotKS(MyID,MyEnemy)==0) then
		local reason=GetKSReason(MyID,MyEnemy)
		logProxy ("CHASE_ST -> IDLE_ST : Enemy is taken "..reason)
		MyState = IDLE_ST
		MyEnemy = 0
		EnemyPosX = {0,0,0,0,0,0,0,0,0,0}
		EnemyPosY = {0,0,0,0,0,0,0,0,0,0}
		MyDestX, MyDestY = 0,0
		ChaseGiveUpCount=0
		--if (FastChangeCount < FastChangeLimit and FastChange_C2I == 1) then
		--	FastChangeCount = FastChangeCount+1
			return OnIDLE_ST()
		--end
	end

		
	if (false == IsInAttackSight(MyID,MyEnemy)) then  -- ENEMY_OUTATTACKSIGHT_IN
		MyState = CHASE_ST
		MyDestX, MyDestY = GetV(V_POSITION_APPLY_SKILLATTACKRANGE, MyEnemy, MySkill, MySkillLevel)
		Move (MyID,MyDestX,MyDestY)
		logProxy ("ATTACK_ST -> CHASE_ST  : ENEMY_OUTATTACKSIGHT_IN")
		return
	end
	if (MySkill == 0) then
		logProxy ("Attack")
		logThis("Now attacking " ..MyEnemy)
		Attack (MyID,MyEnemy)
	else
		SkillObject(MyID,MySkillLevel,MySkill,MyEnemy)
		AutoSkillTimeout = GetTick()+15
	--	if (1 == SkillObject(MyID,MySkillLevel,MySkill,MyEnemy)) then
	--		MyEnemy = 0
	--	end
		
		MySkill = 0
	end
	--logProxy ("ATTACK_ "..MyEnemy)
	logProxy ("ATTACK_ST -> ATTACK_ST  : ENERGY_RECHARGED_IN")
	return


end



function	OnMOVE_CMD_ST ()

	logProxy ("OnMOVE_CMD_ST")

	local x, y = GetV (V_POSITION,MyID)
	if (x == MyDestX and y == MyDestY) then				-- DESTINATION_ARRIVED_IN
		MyState = IDLE_ST
	end
end



function OnSTOP_CMD_ST ()


end



function OnATTACK_OBJECT_CMD_ST ()

	
end



function OnATTACK_AREA_CMD_ST ()

	logProxy ("OnATTACK_AREA_CMD_ST")

	local	object = GetOwnerEnemy (MyID)
	if (object == 0) then							
		object = GetMyEnemy (MyID) 
	end

	if (object ~= 0) then							-- MYOWNER_ATTACKED_IN or ATTACKED_IN
		MyState = CHASE_ST
		MyEnemy = object
		return
	end

	local x , y = GetV (V_POSITION,MyID)
	if (x == MyDestX and y == MyDestY) then			-- DESTARRIVED_IN
			MyState = IDLE_ST
	end

end



function OnPATROL_CMD_ST ()

	logProxy ("OnPATROL_CMD_ST")

	local	object = GetOwnerEnemy (MyID)
	if (object == 0) then							
		object = GetMyEnemy (MyID) 
	end

	if (object ~= 0) then							-- MYOWNER_ATTACKED_IN or ATTACKED_IN
		MyState = CHASE_ST
		MyEnemy = object
		logProxy ("PATROL_CMD_ST -> CHASE_ST : ATTACKED_IN")
		return
	end

	local x , y = GetV (V_POSITION,MyID)
	if (x == MyDestX and y == MyDestY) then			-- DESTARRIVED_IN
		MyDestX = MyPatrolX
		MyDestY = MyPatrolY
		MyPatrolX = x
		MyPatrolY = y
		Move (MyID,MyDestX,MyDestY)
	end

end



function OnHOLD_CMD_ST ()

	logProxy ("OnHOLD_CMD_ST")
	
	if (MyEnemy ~= 0) then
		local d = GetDistance(MyEnemy,MyID)
		if (d ~= -1 and d <= GetV(V_ATTACKRANGE,MyID)) then
				Attack (MyID,MyEnemy)
		else
			MyEnemy = 0
		end
		return
	end


	local	object = GetOwnerEnemy (MyID)
	if (object == 0) then							
		object = GetMyEnemy (MyID)
		if (object == 0) then						
			return
		end
	end

	MyEnemy = object

end



function OnSKILL_OBJECT_CMD_ST ()
	
end




function OnSKILL_AREA_CMD_ST ()

	logProxy ("OnSKILL_AREA_CMD_ST")

	local x , y = GetV (V_POSITION,MyID)
	if (GetDistance(x,y,MyDestX,MyDestY) <= GetV(V_SKILLATTACKRANGE_LEVEL, MyID, MySkill, MySkillLevel)) then	-- DESTARRIVED_IN
		SkillGround (MyID,MySkillLevel,MySkill,MyDestX,MyDestY)
		MyState = IDLE_ST
		MySkill = 0
	end

end



function OnFOLLOW_CMD_ST ()

	logProxy ("OnFOLLOW_CMD_ST")

	local ownerX, ownerY, myX, myY
	ownerX, ownerY = GetV (V_POSITION,GetV(V_OWNER,MyID)) -- ����
	myX, myY = GetV (V_POSITION,MyID)					  -- �� 
	
	local d = GetDistance (ownerX,ownerY,myX,myY)

	if ( d <= 3) then									  -- 3�� ���� �Ÿ��� 
		return 
	end

	local motion = GetV (V_MOTION,MyID)
	if (motion == MOTION_MOVE) then                       -- �̵���
		d = GetDistance (ownerX, ownerY, MyDestX, MyDestY)
		if ( d > 3) then                                  -- ������ ���� ?
			MoveToOwner (MyID)
			MyDestX = ownerX
			MyDestY = ownerY
			return
		end
	else                                                  -- �ٸ� ���� 
		MoveToOwner (MyID)
		MyDestX = ownerX
		MyDestY = ownerY
		return
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

function Spel_on_self(myid)

	-- ������� ������� �� ������ 
	SP_H = GetV (V_SP,myid)

	-- ��� ��
	Vid_M= GetV (V_MERTYPE ,  myid)
	--logThis("Vid_M"..Vid_M)
	logProxy ("Spel_on_self ")
	logProxy ("Vid_M "..Vid_M)

	-- ������
	if Vid_M >0 and Vid_M<11 then
		-- Disguse have same id as bower 
		if Vid_M == 1 then
			-- if SP_H > 12 then	
			-- 	MySkill = MA_DOUBLE
			-- 	MySkillLevel = 2
			-- end
		
		elseif Vid_M == 3 then	-- Nami - 3rd Grade Bowman Mercenary 
			-- MER_QUICKEN lv.1
			logProxy ("QuickenTimeout "..QuickenTimeout )
			if QuickenTimeout - GetTick () > 30*60 and SP_H > 13 then
				QuickenTimeout = GetTick ()
				MySkillLevel = 1
				SkillObject (myid , MySkillLevel , MER_QUICKEN , myid)
				logProxy ("QuickenTimeout ")
	
			end	
		elseif Vid_M == 4 then-- Elfin - 4th Grade Bowman Mercenary 
		elseif Vid_M == 6 then-- Elfin - 6th Grade Bowman Mercenary
            if SP_H > 12 then
                MySkill = MA_DOUBLE
                MySkillLevel = 7
            end
		elseif Vid_M == 8 then-- Hiyori - 8th Grade Bowman Mercenary 
 			-- MER_QUICKEN lv.2
		elseif Vid_M == 10 then-- Hiyori - 8th Grade Bowman Mercenary 
 			-- MER_QUICKEN lv.5
		end
	--��������
	elseif Vid_M >10 and Vid_M<21 then



	--������
	elseif Vid_M >20 and Vid_M<31 then
		if Vid_M == 21 then
			if SP_H > 8 then	
				MySkill = MS_BASH
				MySkillLevel =1
			end
		elseif Vid_M == 22 then	-- Nami - 3rd Grade Bowman Mercenary 
			-- MER_QUICKEN lv.1
			if  GetTick () -QuickenTimeout > 30*60 and SP_H > 13 then
				QuickenTimeout = GetTick ()
				SkillObject (myid , 1 , MER_QUICKEN , myid)
			end	
		elseif Vid_M == 25 then	-- Ryan - �������-������ ������ ������

			if SP_H > 20 then	
				MySkill = MS_BASH
				MySkillLevel =5
			end
		elseif Vid_M == 27 then	-- Ryan - �������-������ ������ ������

			if (SP_H > 20)and(GetTick() >= AutoSkillTimeout) then	
				MySkill = MS_BASH
				MySkillLevel =10
			end
		elseif Vid_M == 28 then	-- Ryan - �������-������ ������ ������

			if  GetTick () -QuickenTimeout > 30*60 and SP_H > 13 then
				QuickenTimeout = GetTick ()
				SkillObject (myid , 1 , MER_QUICKEN , myid)
			end	

		elseif Vid_M == 29 then	-- Ryan - �������-������ ������ ������

		--	if (SP_H > 20)and(GetTick() >= AutoSkillTimeout) then	
		--		MySkill = MER_CRASH
		--		MySkillLevel =3
		--	end



		end

end
end

function AI(myid)

	MyID = myid
	local msg	= GetMsg (myid)			-- command
	local rmsg	= GetResMsg (myid)		-- reserved command
	--MYTickTime	= MYTickTime+1
	
	--QuickenTimeout = GetTick()
	--logProxy ("MYTickTime "..MYTickTime)
	--logProxy ("MyState "..MyState)

	-- ���� ��������� ����� �� ������� ���� �� ����
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

		
	-- ���� ó�� 
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