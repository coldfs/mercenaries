

--  c function

--[[
function	TraceAI (string) end
function	MoveToOwner (id) end
function 	Move (id,x,y) end
function	Attack (id,id) end
function 	GetV (V_,id) end
function	GetActors () end
function	GetTick () end
function	GetMsg (id) end
function	GetResMsg (id) end
function	SkillObject (id,level,skill,target) end
function	SkillGround (id,level,skill,x,y) end
function	IsMonster (id) end -- id�� �����ΰ�? yes -> 1 no -> 0

--]]
-- TODO check inbuild IsMonster


--------------------------------------------
-- constants
--------------------------------------------
V_OWNER                           = 0 -- Owner ID
V_POSITION                        = 1
V_TYPE                            = 2
V_MOTION                          = 3
V_ATTACKRANGE                     = 4
V_TARGET                          = 5
V_SKILLATTACKRANGE                = 6
V_HOMUNTYPE                       = 7
V_HP                              = 8
V_SP                              = 9
V_MAXHP                           = 10
V_MAXSP                           = 11
V_MERTYPE                         = 12
V_POSITION_APPLY_SKILLATTACKRANGE = 13
V_SKILLATTACKRANGE_LEVEL          = 14
--------------------------------------------
-- state
--------------------------------------------
IDLE_ST                 = 0
FOLLOW_ST               = 1
CHASE_ST                = 2
ATTACK_ST               = 3
MOVE_CMD_ST             = 4
STOP_CMD_ST             = 5
ATTACK_OBJECT_CMD_ST    = 6
ATTACK_AREA_CMD_ST      = 7
PATROL_CMD_ST           = 8
HOLD_CMD_ST             = 9
SKILL_OBJECT_CMD_ST     = 10
SKILL_AREA_CMD_ST       = 11
FOLLOW_CMD_ST           = 12
--------------------------------------------
-- global variable
--------------------------------------------
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
--------------------------------------------
-- Homunculus type
--------------------------------------------
LIF             = 1
AMISTR          = 2
FILIR           = 3
VANILMIRTH      = 4
LIF2            = 5
AMISTR2         = 6
FILIR2          = 7
VANILMIRTH2     = 8
LIF_H           = 9
AMISTR_H        = 10
FILIR_H         = 11
VANILMIRTH_H    = 12
LIF_H2          = 13
AMISTR_H2       = 14
FILIR_H2        = 15
VANILMIRTH_H2   = 16
--------------------------------------------
-- Mercenaries
--------------------------------------------
ARCHER01    = 1
ARCHER02    = 2
ARCHER03    = 3
ARCHER04    = 4
ARCHER05    = 5
ARCHER06    = 6
ARCHER07    = 7
ARCHER08    = 8
ARCHER09    = 9
ARCHER10    = 10
LANCER01    = 11
LANCER02    = 12
LANCER03    = 13
LANCER04    = 14
LANCER05    = 15
LANCER06    = 16
LANCER07    = 17
LANCER08    = 18
LANCER09    = 19
LANCER10    = 20
SWORDMAN01  = 21
SWORDMAN02  = 22
SWORDMAN03  = 23
SWORDMAN04  = 24
SWORDMAN05  = 25
SWORDMAN06  = 26
SWORDMAN07  = 27
SWORDMAN08  = 28
SWORDMAN09  = 29
SWORDMAN10  = 30
--------------------------------------------
--Autoskill timeout counters
--------------------------------------------
QuickenTimeout          = 0
GuardTimeout            = 0
MagTimeout              = 0
SightTimeout            = 0
SOffensiveTimeout       = 0
SDefensiveTimeout       = 0
SOwnerBuffTimeout       = 0
SkillTimeout            = 0
ProvokeOwnerTimeout     = 0
ProvokeSelfTimeout      = 0
SacrificeTimeout        = 0
OffensiveOwnerTimeout   = 0
DefensiveOwnerTimeout   = 0
OtherOwnerTimeout       = 0
SteinWandTimeout        = 0
AutoSkillTimeout        = 0 --Cast time + delay timeout
AttackTimeout           = 0 --for AttackTimeLimit
AutoSkillCastTimeout    = 0 --Cast time timeout
TankHitTimeout          = 0
SkillObjectCMDTimeout   = 0
AshTimeout              = {0,0,0}
--------------------------------------------
-- Skills
--------------------------------------------
MS_BASH	         = 8201
MS_MAGNUM        = 8202
MS_BOWLINGBASH   = 8203
MS_PARRYING      = 8204
MS_REFLECTSHIELD = 8205
MS_BERSERK       = 8206
MA_DOUBLE        = 8207
MA_SHOWER        = 8208
MA_SKIDTRAP      = 8209
MA_LANDMINE      = 8210
MA_SANDMAN       = 8211
MA_FREEZINGTRAP  = 8212
MA_REMOVETRAP    = 8213
MA_CHARGEARROW   = 8214
MA_SHARPSHOOTING = 8215
ML_PIERCE        = 8216
ML_BRANDISH      = 8217
ML_SPIRALPIERCE  = 8218
ML_DEFENDER      = 8219
ML_AUTOGUARD     = 8220
ML_DEVOTION      = 8221
MER_MAGNIFICAT   = 8222
MER_QUICKEN      = 8223
MER_SIGHT        = 8224
MER_CRASH        = 8225
MER_REGAIN       = 8226
MER_TENDER       = 8227
MER_BENEDICTION  = 8228
MER_RECUPERATE   = 8229
MER_MENTALCURE   = 8230
MER_COMPRESS     = 8231
MER_PROVOKE      = 8232
MER_AUTOBERSERK  = 8233
MER_DECAGI       = 8234
MER_SCAPEGOAT    = 8235
MER_LEXDIVINA    = 8236
MER_ESTIMATION   = 8237
--------------------------------------------
-- Motions
--------------------------------------------
MOTION_STAND    = 0
MOTION_MOVE     = 1
MOTION_ATTACK   = 2
MOTION_DEAD     = 3
MOTION_ATTACK2  = 9
--------------------------------------------
-- Kill Steal Tactics
--------------------------------------------
KS_NEVER  = 0
KS_ALWAYS = 1
KS_POLITE = -1
--------------------------------------------
-- PVP/Friend Crap
--------------------------------------------
ALLY     = 13
KOS      = 12
ENEMY    = 11
NEUTRAL  = 10
RETAINER = 2
FRIEND   = 1
PKFRIEND = 3

STRING_FRIENDNAMES={}
STRING_FRIENDNAMES[ALLY]    = "ALLY"
STRING_FRIENDNAMES[FRIEND]  = "FRIEND"
STRING_FRIENDNAMES[RETAINER]= "RETAINER"
STRING_FRIENDNAMES[NEUTRAL] = "NEUTRAL"
STRING_FRIENDNAMES[ENEMY]   = "ENEMY"
STRING_FRIENDNAMES[KOS]     = "KOS"
--------------------------------------------
-- Mercenaries
--------------------------------------------
ARCHER01	= 1
ARCHER02	= 2
ARCHER03	= 3
ARCHER04	= 4
ARCHER05	= 5
ARCHER06	= 6
ARCHER07	= 7
ARCHER08	= 8
ARCHER09	= 9
ARCHER10	= 10
LANCER01	= 11
LANCER02	= 12
LANCER03	= 13
LANCER04	= 14
LANCER05	= 15
LANCER06	= 16
LANCER07	= 17
LANCER08	= 18
LANCER09	= 19
LANCER10	= 20
SWORDMAN01	= 21
SWORDMAN02	= 22
SWORDMAN03	= 23
SWORDMAN04	= 24
SWORDMAN05	= 25
SWORDMAN06	= 26
SWORDMAN07	= 27
SWORDMAN08	= 28
SWORDMAN09	= 29
SWORDMAN10	= 30
UNKNOWNMER	= 100 -- Not official designation. Returned by internal GetMerType() function when it cant determine the merc type.
WILDROSE	= 101 -- These are like this because the GetV(V_MERTYPE,MyID) returns 1 for all monster mercs, as well as lvl 1 archer mercs, so we define our own numbers for these.
DOPPLEMERC	= 102 -- Dopple or Egnigem (indistinguishable to the AI)
ALICE		= 103
MIMIC		= 104
DISGUISE	= 105
GMMALE		= 106
PENGINEER   = 107
ISIS		= 108
--------------------------------------------
-- Mercenaries skills
--------------------------------------------
SkillList={}
SkillList[ARCHER01]={}
SkillList[ARCHER02]={}
SkillList[ARCHER03]={}
SkillList[ARCHER04]={}
SkillList[ARCHER05]={}
SkillList[ARCHER06]={}
SkillList[ARCHER07]={}
SkillList[ARCHER08]={}
SkillList[ARCHER09]={}
SkillList[ARCHER10]={}
SkillList[LANCER01]={}
SkillList[LANCER02]={}
SkillList[LANCER03]={}
SkillList[LANCER04]={}
SkillList[LANCER05]={}
SkillList[LANCER06]={}
SkillList[LANCER07]={}
SkillList[LANCER08]={}
SkillList[LANCER09]={}
SkillList[LANCER10]={}
SkillList[SWORDMAN01]={}
SkillList[SWORDMAN02]={}
SkillList[SWORDMAN03]={}
SkillList[SWORDMAN04]={}
SkillList[SWORDMAN05]={}
SkillList[SWORDMAN06]={}
SkillList[SWORDMAN07]={}
SkillList[SWORDMAN08]={}
SkillList[SWORDMAN09]={}
SkillList[SWORDMAN10]={}
SkillList[UNKNOWNMER]={}
SkillList[WILDROSE]={}
SkillList[DOPPLEMERC]={}
SkillList[ALICE]={}
SkillList[MIMIC]={}
SkillList[DISGUISE]={}
SkillList[GMMALE]={}
SkillList[PENGINEER]={}
SkillList[ISIS]={}

SkillList[SWORDMAN01][MS_BASH]=1
SkillList[SWORDMAN05][MS_BASH]=5
SkillList[SWORDMAN07][MS_BASH]=10
SkillList[SWORDMAN10][MS_BASH]=10
SkillList[WILDROSE][MS_BASH]=5
SkillList[DOPPLEMERC][MS_BASH]=5
SkillList[MIMIC][MS_BASH]=5
SkillList[LANCER01][ML_PIERCE]=1
SkillList[LANCER03][ML_PIERCE]=2
SkillList[LANCER05][ML_PIERCE]=5
SkillList[LANCER08][ML_PIERCE]=10
SkillList[LANCER10][ML_SPIRALPIERCE]=5
SkillList[ARCHER01][MA_DOUBLE]=2
SkillList[ARCHER05][MA_DOUBLE]=5
SkillList[ARCHER06][MA_DOUBLE]=7
SkillList[ARCHER09][MA_DOUBLE]=10
SkillList[ARCHER10][MA_SHARPSHOOTING]=5
SkillList[ARCHER03][MA_CHARGEARROW]=1
SkillList[ARCHER06][MA_SKIDTRAP]=3
SkillList[ARCHER09][MA_CHARGEARROW]=1
SkillList[ARCHER10][MA_CHARGEARROW]=1
SkillList[ARCHER05][MER_PROVOKE]=1
SkillList[ARCHER06][MER_DECAGI]=1
SkillList[ARCHER07][MA_FREEZINGTRAP]=2
SkillList[ARCHER08][MA_SANDMAN]=3
SkillList[SWORDMAN01][MER_DECAGI]=1
SkillList[SWORDMAN02][MER_PROVOKE]=5
SkillList[SWORDMAN04][MER_CRASH]=1
SkillList[SWORDMAN05][MER_CRASH]=4
SkillList[SWORDMAN06][MER_DECAGI]=3
SkillList[SWORDMAN09][MER_CRASH]=3
SkillList[LANCER02][MER_LEXDIVINA]=1
SkillList[LANCER04][MER_CRASH]=1
SkillList[LANCER08][MER_PROVOKE]=5
SkillList[DISGUISE][MER_LEXDIVINA]=3
SkillList[ALICE][MER_PROVOKE]=5
SkillList[LANCER03][ML_DEVOTION]=1
SkillList[LANCER07][ML_DEVOTION]=1
SkillList[LANCER10][ML_DEVOTION]=3
SkillList[DOPPLEMERC][ML_DEVOTION]=3
SkillList[ARCHER02][MA_SHOWER]=2
SkillList[ARCHER07][MA_SHOWER]=10
SkillList[LANCER02][ML_BRANDISH]=2
SkillList[LANCER06][ML_BRANDISH]=5
SkillList[LANCER09][ML_BRANDISH]=10
SkillList[SWORDMAN02][MS_MAGNUM]=3
SkillList[SWORDMAN04][MS_MAGNUM]=5
SkillList[SWORDMAN08][MS_BOWLINGBASH]=5
SkillList[SWORDMAN09][MS_BOWLINGBASH]=8
SkillList[SWORDMAN10][MS_BOWLINGBASH]=10
SkillList[ALICE][ML_BRANDISH]=5
SkillList[ARCHER03][MER_QUICKEN]=1
SkillList[ARCHER08][MER_QUICKEN]=2
SkillList[ARCHER10][MER_QUICKEN]=5
SkillList[SWORDMAN03][MER_QUICKEN]=1
SkillList[SWORDMAN06][MER_QUICKEN]=5
SkillList[SWORDMAN08][MER_QUICKEN]=10
SkillList[SWORDMAN10][MER_QUICKEN]=10
SkillList[LANCER06][MER_QUICKEN]=2
SkillList[LANCER10][MER_QUICKEN]=5
SkillList[DOPPLEMERC][MER_QUICKEN]=5
SkillList[DISGUISE][MER_QUICKEN]=2
SkillList[LANCER05][ML_AUTOGUARD]=3
SkillList[LANCER09][ML_AUTOGUARD]=7
SkillList[LANCER10][ML_AUTOGUARD]=10
SkillList[MIMIC][ML_AUTOGUARD]=5
SkillList[SWORDMAN08][MS_PARRYING]=4
SkillList[GMMALE][MER_KYRIE]=5
SkillList[GMMALE][MER_BLESSING]=5
SkillList[GMMALE][MER_INCAGI]=5
SkillList[PENGINEER][MER_BLESSING]=5
SkillList[ISIS][MS_BASH]=10
--------------------------------------------
-- command
--------------------------------------------
NONE_CMD            = 0
MOVE_CMD            = 1
STOP_CMD            = 2
ATTACK_OBJECT_CMD   = 3
ATTACK_AREA_CMD     = 4
PATROL_CMD          = 5
HOLD_CMD            = 6
SKILL_OBJECT_CMD    = 7
SKILL_AREA_CMD      = 8
FOLLOW_CMD          = 9
--------------------------------------------

TACT_KS = 0

--[[ ��ɾ� ����

MOVE_CMD
	{��ɹ�ȣ,X��ǥ,Y��ǥ}
	  
STOP_CMD
	{��ɹ�ȣ}

ATTACK_OBJECT_CMD
	{��ɹ�ȣ,��ǥID}

ATTACK_AREA_CMD	
	{��ɹ�ȣ,X��ǥ,Y��ǥ}

PATROL_CMD	
	{��ɹ�ȣ,X��ǥ,Y��ǥ}
	
HOLD_CMD
	{��ɹ�ȣ}

SKILL_OBJECT_CMD
	{��ɹ�ȣ,���÷���,����,��ǥID}

SKILL_AREA_CMD
	{��ɹ�ȣ,���÷���,����,X��ǥ,Y��ǥ}

FOLLOW_CMD
	{��ɹ�ȣ}
--]]

