
------------- command process  ---------------------

function OnMOVE_CMD (x,y)

    logProxy ("OnMOVE_CMD-1")

    if ( x == MyDestX and y == MyDestY and MOTION_MOVE == GetV(V_MOTION,MyID)) then
        return -- ���� �̵����� �������� ���� ���̸� ó������ �ʴ´�.
    end

    local curX, curY = GetV (V_POSITION,MyID)
    if (math.abs(x-curX)+math.abs(y-curY) > 15) then        -- Destination more than 15 cells ahead
        List.pushleft (ResCmdList,{MOVE_CMD,x,y})           -- Push command to pool again
        x = math.floor((x+curX)/2)                          -- Move half way to destination
        y = math.floor((y+curY)/2)                          --
    end

    Move (MyID,x,y)

    MyState = MOVE_CMD_ST
    MyDestX = x
    MyDestY = y
    MyEnemy = 0
    MySkill = 0

end

function OnSTOP_CMD ()

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

function OnATTACK_OBJECT_CMD (id)

    logProxy ("OnATTACK_OBJECT_CMD")

    MySkill = 0
    MyEnemy = id
    MyState = CHASE_ST

end

function OnATTACK_AREA_CMD (x,y)

    logProxy ("OnATTACK_AREA_CMD")

    if (x ~= MyDestX or y ~= MyDestY or MOTION_MOVE ~= GetV(V_MOTION,MyID)) then
        Move (MyID,x,y)
    end
    MyDestX = x
    MyDestY = y
    MyEnemy = 0
    MyState = ATTACK_AREA_CMD_ST

end

function OnPATROL_CMD (x,y)

    logProxy ("OnPATROL_CMD")

    MyPatrolX , MyPatrolY = GetV (V_POSITION,MyID)
    MyDestX = x
    MyDestY = y
    Move (MyID,x,y)
    MyState = PATROL_CMD_ST

end

function OnHOLD_CMD ()

    logProxy ("OnHOLD_CMD")

    MyDestX = 0
    MyDestY = 0
    MyEnemy = 0
    MyState = HOLD_CMD_ST

end

function OnSKILL_OBJECT_CMD (level,skill,id)

    logProxy ("OnSKILL_OBJECT_CMD")

    MySkillLevel = level
    MySkill = skill
    MyEnemy = id
    MyState = CHASE_ST

end

function OnSKILL_AREA_CMD (level,skill,x,y)

    logProxy ("OnSKILL_AREA_CMD")

    Move (MyID,x,y)
    MyDestX = x
    MyDestY = y
    MySkillLevel = level
    MySkill = skill
    MyState = SKILL_AREA_CMD_ST

end

function OnFOLLOW_CMD ()

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