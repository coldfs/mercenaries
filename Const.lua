

--  c function

--[[
function	logProxy (string) end
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
function	IsMonster (id) end								-- id�� �����ΰ�? yes -> 1 no -> 0

--]]





-------------------------------------------------
-- constants
-------------------------------------------------


--------------------------------
V_OWNER				=	0		-- ������ ID			
V_POSITION			=	1		-- ��ü�� ��ġ 
V_TYPE				=	2		-- �̱��� 
V_MOTION			=	3		-- ���� 
V_ATTACKRANGE		=	4		-- ���� ���� ���� 
V_TARGET			=   5		-- ����, ��ų ��� ��ǥ�� ID 
V_SKILLATTACKRANGE	=	6		-- ��ų ��� ���� 
V_HOMUNTYPE			=   7		-- ȣ��Ŭ�罺 ����
V_HP				=	8		-- HP (ȣ��Ŭ�罺�� ���ο��Ը� ����)
V_SP				=	9		-- SP (ȣ��Ŭ�罺�� ���ο��Ը� ����)
V_MAXHP				=   10		-- �ִ� HP (ȣ��Ŭ�罺�� ���ο��Ը� ����)
V_MAXSP				=   11		-- �ִ� SP (ȣ��Ŭ�罺�� ���ο��Ը� ����)
V_MERTYPE		  =		12    -- �뺴 ����	
V_POSITION_APPLY_SKILLATTACKRANGE = 13	-- SkillAttackange�� ������ ��ġ
V_SKILLATTACKRANGE_LEVEL = 14	-- ���� �� SkillAttackange
---------------------------------	





--------------------------------------------
-- ȣ��Ŭ�罺 ���� 
--------------------------------------------

LIF				= 1
AMISTR			= 2
FILIR			= 3
VANILMIRTH		= 4
LIF2			= 5
AMISTR2			= 6
FILIR2			= 7
VANILMIRTH2		= 8
LIF_H			= 9
AMISTR_H		= 10
FILIR_H			= 11
VANILMIRTH_H	= 12
LIF_H2			= 13
AMISTR_H2		= 14
FILIR_H2		= 15
VANILMIRTH_H2	= 16

--------------------------------------------



--------------------------------------------
-- �뺴 ���� 
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
--------------------------------------------
--Autoskill timeout counters
QuickenTimeout			= 0
GuardTimeout			= 0
MagTimeout			= 0
SightTimeout			= 0
SOffensiveTimeout		= 0
SDefensiveTimeout		= 0
SOwnerBuffTimeout		= 0
SkillTimeout			= 0
ProvokeOwnerTimeout		= 0
ProvokeSelfTimeout		= 0
SacrificeTimeout		= 0
OffensiveOwnerTimeout	= 0
DefensiveOwnerTimeout	= 0
OtherOwnerTimeout		= 0
SteinWandTimeout		= 0
AutoSkillTimeout		= 0 --Cast time + delay timeout
AttackTimeout			= 0 --for AttackTimeLimit
AutoSkillCastTimeout	= 0 --Cast time timeout
TankHitTimeout			= 0
SkillObjectCMDTimeout   = 0
AshTimeout 				= {0,0,0}
--------------------------------------------
MS_BASH			= 8201
MS_MAGNUM		= 8202
MS_BOWLINGBASH		= 8203
MS_PARRYING		= 8204
MS_REFLECTSHIELD	= 8205
MS_BERSERK		= 8206
MA_DOUBLE		= 8207
MA_SHOWER		= 8208
MA_SKIDTRAP		= 8209
MA_LANDMINE		= 8210
MA_SANDMAN		= 8211
MA_FREEZINGTRAP		= 8212
MA_REMOVETRAP		= 8213
MA_CHARGEARROW		= 8214
MA_SHARPSHOOTING	= 8215
ML_PIERCE		= 8216
ML_BRANDISH		= 8217
ML_SPIRALPIERCE		= 8218
ML_DEFENDER		= 8219
ML_AUTOGUARD		= 8220
ML_DEVOTION		= 8221
MER_MAGNIFICAT		= 8222
MER_QUICKEN		= 8223
MER_SIGHT		= 8224
MER_CRASH		= 8225
MER_REGAIN		= 8226
MER_TENDER		= 8227
MER_BENEDICTION		= 8228
MER_RECUPERATE		= 8229
MER_MENTALCURE		= 8230
MER_COMPRESS		= 8231
MER_PROVOKE		= 8232
MER_AUTOBERSERK		= 8233
MER_DECAGI		= 8234
MER_SCAPEGOAT		= 8235
MER_LEXDIVINA		= 8236
MER_ESTIMATION		= 8237
--------------------------
MOTION_STAND	= 0
MOTION_MOVE		= 1
MOTION_ATTACK	= 2
MOTION_DEAD     = 3
MOTION_ATTACK2	= 9 
--------------------------


KS_NEVER=0
KS_ALWAYS=1
KS_POLITE=-1

---------------------------
-- PVP/Friend Crap
---------------------------

ALLY	= 13
KOS	= 12
ENEMY	= 11
NEUTRAL	= 10
RETAINER= 2
FRIEND	= 1
PKFRIEND = 3

STRING_FRIENDNAMES={}
STRING_FRIENDNAMES[ALLY]="ALLY"
STRING_FRIENDNAMES[FRIEND]="FRIEND"
STRING_FRIENDNAMES[RETAINER]="RETAINER"
STRING_FRIENDNAMES[NEUTRAL]="NEUTRAL"
STRING_FRIENDNAMES[ENEMY]="ENEMY"
STRING_FRIENDNAMES[KOS]="KOS"



--------------------------
-- command  
--------------------------
NONE_CMD			= 0
MOVE_CMD			= 1
STOP_CMD			= 2
ATTACK_OBJECT_CMD	= 3
ATTACK_AREA_CMD		= 4
PATROL_CMD			= 5
HOLD_CMD			= 6
SKILL_OBJECT_CMD	= 7
SKILL_AREA_CMD		= 8
FOLLOW_CMD			= 9
TACT_KS = 0
--------------------------



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

