
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

        -- logFullInfo (MyEnemy, "Current enemy")

        Attack (MyID,MyEnemy)
    else
        -- logFullInfo (MyEnemy, "Current skill target")
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

    if (object ~= 0) then -- MYOWNER_ATTACKED_IN or ATTACKED_IN
        MyState = CHASE_ST
        MyEnemy = object
        logProxy ("PATROL_CMD_ST -> CHASE_ST : ATTACKED_IN")
        return
    end

    local x , y = GetV (V_POSITION,MyID)
    if (x == MyDestX and y == MyDestY) then -- DESTARRIVED_IN
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