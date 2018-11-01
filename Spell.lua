function recastQuicken(myid) -- Or possible other self/buff skills
    MercType = GetMerType(myid);
    logThis('Found merchant with type: '..MercType)
    level=SkillList[MercType][MER_QUICKEN]
    if level ~=nil then
        skill=MER_QUICKEN
        -- Прошлый квикен кончился, если есть СП - нужно рекастануть.
        if QuickenTimeout - GetTick () > 60*60 and SP_H > 18 then
            QuickenTimeout = GetTick ()
            SkillObject (myid , level , MER_QUICKEN , myid)
        end

    end
end

function setAttackSkill(myid)
    MercType = GetMerType(myid);
    SP_H = GetV (V_SP, myid)

    -- MA_DOUBLE
    DoubleLevel = SkillList[MercType][MA_DOUBLE]
    if DoubleLevel ~=nil then
        if SP_H > 12 then
            MySkill = MA_DOUBLE
            MySkillLevel = DoubleLevel
        end
        return
    end

    -- MS_BASH
    BashLevel = SkillList[MercType][MS_BASH]
    if BashLevel ~=nil then
        -- TODO deal with sp level
        if (SP_H > 20) then
            MySkill = MS_BASH
            MySkillLevel = BashLevel
        end
        return
    end

end

function Spel_on_self(myid)

    -- logFullInfo (myid, "Merchant Info")
    -- Current SP level
    SP_H = GetV (V_SP,myid)

    -- Merch Type
    Vid_M = GetV (V_MERTYPE ,  myid)
    mhp = GetV(V_MAXHP,myid)
    msp = GetV(V_MAXSP,myid)

    logThis("Vid_M "..Vid_M)
    logThis("mhp "..mhp)
    logThis("msp "..msp)
    logProxy ("Spel_on_self ")
    logProxy ("Vid_M "..Vid_M)

    -- ������
    if Vid_M >0 and Vid_M<11 then
        -- Disguse have same id as bower
        if Vid_M == 1 then -- 1rd Grade Bowman Mercenary OR Disguise
            if (mhp >= 7500 and 10000 >= mhp and msp >= 180 and msp < 220 ) then -- looks like a disguise!
                -- TODO here we can determine disgaise by maxHp AND maxSP
                --if QuickenTimeout - GetTick () > 30*60 and SP_H > 13 then
                if QuickenTimeout - GetTick () > 60*60 and SP_H > 18 then
                    QuickenTimeout = GetTick ()
                    MySkillLevel = 2
                    SkillObject (myid , MySkillLevel , MER_QUICKEN , myid)
                end
            else
                if SP_H > 12 then
                    MySkill = MA_DOUBLE
                    MySkillLevel = 2
                end
            end

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
