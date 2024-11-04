local ADDON_NAME, private = ...

local select = select;
local unpack = unpack;
local next = next;
local pairs = pairs;
local ipairs = ipairs;
local tonumber = tonumber;
local tostring = tostring;
local format = format;
local strmatch = strmatch;
local gsub = gsub;
local strsub = strsub;
local tremove = tremove;
local tinsert = tinsert;
local wipe = wipe;


-- /* api's */
local UnitName = UnitName;
local UnitLevel = UnitLevel;
local UnitFactionGroup = UnitFactionGroup;
local PlaySoundFile = PlaySoundFile;
local GetSpellInfo = GetSpellInfo;
local GetItemInfo = GetItemInfo;
local GetUnitName = GetUnitName;
local GetBattlefieldScore = GetBattlefieldScore;
local GetNumBattlefieldScores = GetNumBattlefieldScores;
local GetBattlefieldWinner = GetBattlefieldWinner;
local GetMoneyString = GetMoneyString;
local GameTooltip = GameTooltip;
local playerFaction = UnitFactionGroup("player");
local playerWinner = PLAYER_FACTION_GROUP[playerFaction];
local playerName = UnitName("player");
local GetAmountBattlefieldBonus = private.GetAmountBattlefieldBonus;

