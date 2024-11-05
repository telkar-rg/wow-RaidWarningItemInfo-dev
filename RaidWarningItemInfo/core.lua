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
local strfind = strfind;
local gsub = gsub;
local strsub = strsub;
local strlen = strlen;
local strsplit = strsplit;
local strtrim = strtrim;
local tremove = tremove;
local tinsert = tinsert;
local wipe = wipe;

local GetAuctionItemClasses = GetAuctionItemClasses;
local GetItemInfo = GetItemInfo;
local GetLocale = GetLocale;


local txtChatPrefix = "|cFF66cccc" .. "RWII (" .. GetAddOnMetadata(ADDON_NAME, "Version") .. "):|r "
-- local txtErrorCache = "|cFFa0a0a0" .. "Item not in game cache" .. "|r"

local LOCALE = GetLocale();

local classColorString
-- for k, colorTable in pairs( RAID_CLASS_COLORS ) do
	-- print("-- CLASS COLOR:", colorTable["className"], colorTable["colorStr"])
	-- classColorString[ colorTable["className"] ] = colorTable["colorStr"]
-- end

local itemLinkPattern = "(\124c%x+\124Hitem:(%d+):%d*:%d*:%d*:%d*:%d*:%d*:%d*:%d*\124h%[.+%]\124h\124r)"
local itemTypeWeapon, itemTypeArmor, _, _, _, _, _, _, _, _, itemTypeMisc = GetAuctionItemClasses()

local _, _, _, _, _, _, itemTypeWeaponPolearms, _, _, itemTypeWeaponStaves, itemTypeWeaponFist, _, itemTypeWeaponDagger = GetAuctionItemSubClasses(1)
local itemTypeArmorMisc, itemTypeArmorCloth, itemTypeArmorLeather, itemTypeArmorMail, itemTypeArmorPlate = GetAuctionItemSubClasses(2)
local invTypeLocale = {
	[itemTypeWeapon] = itemTypeWeapon,
	[itemTypeArmor] = itemTypeArmor,
	[itemTypeMisc] = itemTypeMisc,
	[itemTypeWeaponPolearms] = itemTypeWeaponPolearms,
	[itemTypeWeaponStaves] = itemTypeWeaponStaves,
	[itemTypeWeaponFist] = itemTypeWeaponFist,
	[itemTypeWeaponDagger] = itemTypeWeaponDagger,
	[itemTypeArmorMisc] = itemTypeArmorMisc,
	[itemTypeArmorCloth] = itemTypeArmorCloth,
	[itemTypeArmorLeather] = itemTypeArmorLeather,
	[itemTypeArmorPlate] = itemTypeArmorPlate,
}
if LOCALE == "deDE" then
	invTypeLocale[itemTypeArmorMail] = "Kette"
end

local ttClasses = gsub(ITEM_CLASSES_ALLOWED, "%%s", "")
local ttClassesLen = strlen(ttClasses)

local ttOnEquip = ITEM_SPELL_TRIGGER_ONEQUIP
local ttOnEquipLen = strlen(ITEM_SPELL_TRIGGER_ONEQUIP)

local ttPlusStatPattern = "%+%d+ (.+)"

local ttPlusStats = {
	[ITEM_MOD_AGILITY_SHORT] = "Agi",
	[ITEM_MOD_INTELLECT_SHORT] = "Int",
	[ITEM_MOD_SPIRIT_SHORT] = "Spi",
	[ITEM_MOD_STRENGTH_SHORT] = "Str",
}
if LOCALE == "deDE" then
	ttPlusStats[ITEM_MOD_AGILITY_SHORT] = "Bewi"
	ttPlusStats[ITEM_MOD_SPIRIT_SHORT]  = "Wil"
end

local tt_stat_pattern_ARP   = gsub(ITEM_MOD_ARMOR_PENETRATION_RATING, '%%d', '%%d+')
local tt_stat_pattern_AP    = gsub(ITEM_MOD_ATTACK_POWER, '%%d', '%%d+')
local tt_stat_pattern_BLOCK_RATING = gsub(ITEM_MOD_BLOCK_RATING, '%%d', '%%d+')
local tt_stat_pattern_BLOCK_VALUE  = gsub(ITEM_MOD_BLOCK_VALUE, '%%d', '%%d+')
local tt_stat_pattern_CRIT  = gsub(ITEM_MOD_CRIT_RATING, '%%d', '%%d+')
local tt_stat_pattern_DEF   = gsub(ITEM_MOD_DEFENSE_SKILL_RATING, '%%d', '%%d+')
local tt_stat_pattern_DODGE = gsub(ITEM_MOD_DODGE_RATING, '%%d', '%%d+')
local tt_stat_pattern_EXP   = gsub(ITEM_MOD_EXPERTISE_RATING, '%%d', '%%d+')
local tt_stat_pattern_HASTE = gsub(ITEM_MOD_HASTE_RATING, '%%d', '%%d+')
local tt_stat_pattern_HIT   = gsub(ITEM_MOD_HIT_RATING, '%%d', '%%d+')
local tt_stat_pattern_PARRY = gsub(ITEM_MOD_PARRY_RATING, '%%d', '%%d+')
local tt_stat_pattern_SP    = gsub(ITEM_MOD_SPELL_POWER, '%%d', '%%d+')
local tt_stat_pattern_MP5   = gsub(ITEM_MOD_MANA_REGENERATION, '%%d', '%%d+')

local ttOnEquipPattern = {
   [tt_stat_pattern_ARP]   = "Arp",
   [tt_stat_pattern_AP]    = "AP",
   [tt_stat_pattern_BLOCK_RATING] = ITEM_MOD_BLOCK_RATING_SHORT,
   [tt_stat_pattern_BLOCK_VALUE]  = ITEM_MOD_BLOCK_VALUE_SHORT,
   [tt_stat_pattern_CRIT]  = "Crit",
   [tt_stat_pattern_DEF]   = "Def",
   [tt_stat_pattern_DODGE] = "Dodge",
   [tt_stat_pattern_EXP]   = "Exp",
   [tt_stat_pattern_HASTE] = "Haste",
   [tt_stat_pattern_HIT]   = "Hit",
   [tt_stat_pattern_PARRY] = "Parry",
   [tt_stat_pattern_SP]    = "SP",
   [tt_stat_pattern_MP5]   = "Mp5",
}
if LOCALE == "deDE" then
	ttOnEquipPattern[tt_stat_pattern_EXP]   = "WK"
	ttOnEquipPattern[tt_stat_pattern_HASTE] = "Tempo"
	ttOnEquipPattern[tt_stat_pattern_SP]    = "ZM"
end

local tableTokenID = {
	[20928] = {"AQ40", 80},
	[20929] = {"AQ40", 80},
	[20930] = {"AQ40", 80},
	[20932] = {"AQ40", 80},
	[20933] = {"AQ40", 80},
	[29753] = {"T4", 120},
	[29754] = {"T4", 120},
	[29755] = {"T4", 120},
	[29756] = {"T4", 120},
	[29757] = {"T4", 120},
	[29758] = {"T4", 120},
	[29759] = {"T4", 120},
	[29760] = {"T4", 120},
	[29761] = {"T4", 120},
	[29762] = {"T4", 120},
	[29763] = {"T4", 120},
	[29764] = {"T4", 120},
	[29765] = {"T4", 120},
	[29766] = {"T4", 120},
	[29767] = {"T4", 120},
	[30236] = {"T5", 133},
	[30237] = {"T5", 133},
	[30238] = {"T5", 133},
	[30239] = {"T5", 133},
	[30240] = {"T5", 133},
	[30241] = {"T5", 133},
	[30242] = {"T5", 133},
	[30243] = {"T5", 133},
	[30244] = {"T5", 133},
	[30245] = {"T5", 133},
	[30246] = {"T5", 133},
	[30247] = {"T5", 133},
	[30248] = {"T5", 133},
	[30249] = {"T5", 133},
	[30250] = {"T5", 133},
	[31089] = {"T6", 146},
	[31090] = {"T6", 146},
	[31091] = {"T6", 146},
	[31092] = {"T6", 146},
	[31093] = {"T6", 146},
	[31094] = {"T6", 146},
	[31095] = {"T6", 146},
	[31096] = {"T6", 146},
	[31097] = {"T6", 146},
	[31098] = {"T6", 146},
	[31099] = {"T6", 146},
	[31100] = {"T6", 146},
	[31101] = {"T6", 146},
	[31102] = {"T6", 146},
	[31103] = {"T6", 146},
	[34848] = {"T6", 154},
	[34851] = {"T6", 154},
	[34852] = {"T6", 154},
	[34853] = {"T6", 154},
	[34854] = {"T6", 154},
	[34855] = {"T6", 154},
	[34856] = {"T6", 154},
	[34857] = {"T6", 154},
	[34858] = {"T6", 154},
	[40610] = {"T7", 200},
	[40611] = {"T7", 200},
	[40612] = {"T7", 200},
	[40613] = {"T7", 200},
	[40614] = {"T7", 200},
	[40615] = {"T7", 200},
	[40616] = {"T7", 200},
	[40617] = {"T7", 200},
	[40618] = {"T7", 200},
	[40619] = {"T7", 200},
	[40620] = {"T7", 200},
	[40621] = {"T7", 200},
	[40622] = {"T7", 200},
	[40623] = {"T7", 200},
	[40624] = {"T7", 200},
	[40625] = {"T7.5",   213},
	[40626] = {"T7.5",   213},
	[40627] = {"T7.5",   213},
	[40628] = {"T7.5",   213},
	[40629] = {"T7.5",   213},
	[40630] = {"T7.5",   213},
	[40631] = {"T7.5",   213},
	[40632] = {"T7.5",   213},
	[40633] = {"T7.5",   213},
	[40634] = {"T7.5",   213},
	[40635] = {"T7.5",   213},
	[40636] = {"T7.5",   213},
	[40637] = {"T7.5",   213},
	[40638] = {"T7.5",   213},
	[40639] = {"T7.5",   213},
	[45632] = {"T8.5",   226},
	[45633] = {"T8.5",   226},
	[45634] = {"T8.5",   226},
	[45635] = {"T8",     219},
	[45636] = {"T8",     219},
	[45637] = {"T8",     219},
	[45638] = {"T8.5",   226},
	[45639] = {"T8.5",   226},
	[45640] = {"T8.5",   226},
	[45641] = {"T8.5",   226},
	[45642] = {"T8.5",   226},
	[45643] = {"T8.5",   226},
	[45644] = {"T8",     219},
	[45645] = {"T8",     219},
	[45646] = {"T8",     219},
	[45647] = {"T8",     219},
	[45648] = {"T8",     219},
	[45649] = {"T8",     219},
	[45650] = {"T8",     219},
	[45651] = {"T8",     219},
	[45652] = {"T8",     219},
	[45653] = {"T8.5",   226},
	[45654] = {"T8.5",   226},
	[45655] = {"T8.5",   226},
	[45656] = {"T8.5",   226},
	[45657] = {"T8.5",   226},
	[45658] = {"T8.5",   226},
	[45659] = {"T8",     219},
	[45660] = {"T8",     219},
	[45661] = {"T8",     219},
	[47557] = {"T9.75",  258},
	[47558] = {"T9.75",  258},
	[47559] = {"T9.75",  258},
	[52025] = {"T10.5",  264},
	[52026] = {"T10.5",  264},
	[52027] = {"T10.5",  264},
	[52028] = {"T10.75", 277},
	[52029] = {"T10.75", 277},
	[52030] = {"T10.75", 277},
}

local tableU10HM = {
	[45293] = 1,
	[45300] = 1,
	[45295] = 1,
	[45297] = 1,
	[45296] = 1,
	[45869] = 1,
	[45867] = 1,
	[45871] = 1,
	[45868] = 1,
	[45870] = 1,
	[45455] = 1,
	[45447] = 1,
	[45456] = 1,
	[45449] = 1,
	[45448] = 1,
	[46042] = 1,
	[46045] = 1,
	[46050] = 1,
	[46043] = 1,
	[46049] = 1,
	[46044] = 1,
	[46037] = 1,
	[46039] = 1,
	[46041] = 1,
	[46047] = 1,
	[46040] = 1,
	[46048] = 1,
	[46046] = 1,
	[46038] = 1,
	[46051] = 1,
	[45888] = 1,
	[45876] = 1,
	[45886] = 1,
	[45887] = 1,
	[45877] = 1,
	[45928] = 1,
	[45933] = 1,
	[45931] = 1,
	[45929] = 1,
	[45930] = 1,
	[45943] = 1,
	[45945] = 1,
	[45946] = 1,
	[45947] = 1,
	[45294] = 1,
	[45993] = 1,
	[45989] = 1,
	[45982] = 1,
	[45988] = 1,
	[45990] = 1,
	[46032] = 1,
	[46034] = 1,
	[46036] = 1,
	[46035] = 1,
	[46033] = 1,
	[46068] = 1,
	[46095] = 1,
	[46096] = 1,
	[46097] = 1,
	[46067] = 1,
	[46312] = 1,
}



local ORIG_ChatFrame_MessageEventHandler = ChatFrame_MessageEventHandler;
function ChatFrame_MessageEventHandler(self, event, ...)
	
	if not classColorString then
		classColorString = {}
		for k, colorTable in pairs( RAID_CLASS_COLORS ) do
			print("-- CLASS COLOR:", colorTable["className"], colorTable["colorStr"])
			classColorString[ colorTable["className"] ] = colorTable["colorStr"]
		end
	end
	
	if event ~= "CHAT_MSG_RAID_WARNING" then
		ORIG_ChatFrame_MessageEventHandler(self, event, ...);
		return
	else
		local itemLink, itemID = strmatch(arg1, itemLinkPattern)
		if not itemID then 
			ORIG_ChatFrame_MessageEventHandler(self, event, ... );
			return
		end
		itemID = tonumber(itemID)
		if not itemID then 
			ORIG_ChatFrame_MessageEventHandler(self, event, ... );
			return
		end
		
		local itemName, itemLink, itemRarity, itemLevel, _, itemType, itemSubType, _, itemEquipLoc = GetItemInfo(itemID) 
		if not itemName then -- Item not in Cache
			-- msg = txtChatPrefix .. txtErrorCache
			-- msg = arg1 .. "\n" ..
			-- ORIG_ChatFrame_MessageEventHandler(self, event, msg, select(2,...) );
			ORIG_ChatFrame_MessageEventHandler(self, event, ... );
			return
		end
		if itemRarity and (itemRarity < 3 or itemRarity > 5) then 
			ORIG_ChatFrame_MessageEventHandler(self, event, ... );
			return
		end -- rare epic legendary
		if not(itemType == itemTypeWeapon or itemType == itemTypeArmor or itemType == itemTypeMisc) then 
			ORIG_ChatFrame_MessageEventHandler(self, event, ... );
			return
		end -- must be weapon/ armor/ Token
		-- if itemEquipLoc == "INVTYPE_TRINKET" then -- dont care for trinkets
			-- ORIG_ChatFrame_MessageEventHandler(self, event, ... );
			-- return
		-- end
		
		
		local itemStatTable = {}
		local ttStat
		local outLevel, outBOE, outHC, outHM, outType, outStats, outClasses
		
		
		local knownToken = tableTokenID[itemID]
		if knownToken then
			outType  = "|cffFFFFFF" .. knownToken[1] .. "|r"
			outLevel = "|cFFFFFF7F" .. knownToken[2] .. "|r"
		end
		
		if (itemType == itemTypeWeapon or itemType == itemTypeArmor) then
			outLevel = "|cFFFFFF7F" .. itemLevel .. "|r"
			
			if itemLevel == 239 or tableU10HM[itemID] then
				outHM = "|cff1eff00".."HM".."|r"
			end
		
			if itemEquipLoc == "INVTYPE_RELIC" then
				outType = "|cffFFFFFF" .. INVTYPE_RELIC..": "..itemSubType .. "|r"
			elseif itemEquipLoc == "INVTYPE_FINGER" then
				outType = "|cffFFFFFF" .. INVTYPE_FINGER .. "|r"
			elseif itemEquipLoc == "INVTYPE_NECK" then
				outType = "|cffFFFFFF" .. INVTYPE_NECK .. "|r"
			elseif itemEquipLoc == "INVTYPE_CLOAK" then
				outType = "|cffFFFFFF" .. INVTYPE_CLOAK .. "|r"
			elseif itemEquipLoc == "INVTYPE_THROWN" then
				outType = "|cffFFFFFF" .. INVTYPE_THROWN .. "|r"
			elseif itemEquipLoc == "INVTYPE_HOLDABLE" then
				outType = "|cffFFFFFF" .. INVTYPE_WEAPONOFFHAND .. "|r"
			elseif itemEquipLoc == "INVTYPE_TRINKET" then
				outType = "|cffFFFFFF" .. INVTYPE_TRINKET .. "|r"
			end
		end
		
		-- ################################
		RaidWarningItemInfo_TooltipHidden:SetOwner(UIParent, "ANCHOR_NONE")
		RaidWarningItemInfo_TooltipHidden:ClearLines()
		RaidWarningItemInfo_TooltipHidden:SetHyperlink(itemLink)
		
		for i=1,RaidWarningItemInfo_TooltipHidden:NumLines() do 
			local txtL = getglobal("RaidWarningItemInfo_TooltipHidden".."TextLeft" ..i):GetText()
			local txtR = getglobal("RaidWarningItemInfo_TooltipHidden".."TextRight"..i):GetText()
			if not txtL or txtL==" " then break end
			
			if not outBOE and txtL == ITEM_BIND_ON_EQUIP then 
				outBOE = "|cff4090ff".."BOE".."|r"
			end
			if not outHC and txtL == ITEM_HEROIC then 
				outHC = "|cff1eff00".."HC".."|r"
			end
			if not outHC and txtL == ITEM_HEROIC then 
				outHC = "|cff1eff00".."HC".."|r"
			end
			
			if not outClasses then
				if strsub(txtL,1,ttClassesLen) == ttClasses then
					outClasses = strsub(txtL,ttClassesLen+1)
					local tc = { strsplit(",", outClasses) }
					local outClasses2 = {}
					if #tc > 0 then
						for _, cName in pairs(tc) do
							cName = strtrim(cName)
							if not classColorString[cName] then 
								wipe(outClasses2)
								outClasses2 = nil
								break 
							end
							cName = "|c" .. classColorString[cName] .. cName .. "|r"
							tinsert(outClasses2, cName)
						end
					end
					if outClasses2 then
						outClasses = "{ " .. strjoin(" ", tostringall( unpack(outClasses2) )) .. " }"
						wipe(outClasses2)
						outClasses2=nil
					end
				end
			end
			
			if not knownToken then
				if not outType and txtR then
					if itemEquipLoc == "INVTYPE_WEAPON" then
						if (itemSubType == itemTypeWeaponDagger or itemSubType == itemTypeWeaponFist) then
							outType = "|cffFFFFFF" .. txtR .. "|r"
						else
							outType = "|cffFFFFFF" .. "1H".."-"..txtR .. "|r"
						end
					elseif itemEquipLoc == "INVTYPE_WEAPONMAINHAND" then
						outType = "|cffFFFFFF" .. "MH".."-"..txtR .. "|r"
					elseif itemEquipLoc == "INVTYPE_WEAPONOFFHAND" then
						outType = "|cffFFFFFF" .. "OH".."-"..txtR .. "|r"
					elseif itemEquipLoc == "INVTYPE_SHIELD" then
						outType = "|cffFFFFFF" .. txtR .. "|r"
						
					elseif itemEquipLoc == "INVTYPE_2HWEAPON" then
						if (itemSubType == itemTypeWeaponPolearms or itemSubType == itemTypeWeaponStaves) then
							outType = "|cffFFFFFF" .. txtR .. "|r"
						else
							outType = "|cffFFFFFF" .. "2H".."-"..txtR .. "|r"
						end
						
					elseif itemEquipLoc == "INVTYPE_RANGED" or itemEquipLoc == "INVTYPE_RANGEDRIGHT" then
						outType = "|cffFFFFFF" .. txtR .. "|r"
						
					else
						if invTypeLocale[txtR] then 
							outType = "|cffFFFFFF" .. invTypeLocale[txtR]..": "..txtL .. "|r"
						else
							outType = "|cffFFFFFF" .. txtR..": "..txtL .. "|r"
						end
					end
				end
				
				if (itemType == itemTypeWeapon or itemType == itemTypeArmor) and itemEquipLoc ~= "INVTYPE_TRINKET" then
					if strsub(txtL,1,1) == "+" then
						ttStat = strmatch(txtL, ttPlusStatPattern)
						if ttStat then
							ttStat = ttPlusStats[ttStat]
							if ttStat then
								tinsert(itemStatTable, ttStat)
							end
						end
					end
					
					if strsub(txtL,1,ttOnEquipLen) == ttOnEquip then
						for p,q in pairs(ttOnEquipPattern) do
							if strfind(txtL, p) then
								tinsert(itemStatTable, q)
							end
						end
					end
				end
				
			end
			
			-- print("--", txtL, ":", txtR)
		end
		RaidWarningItemInfo_TooltipHidden:Hide()
		-- ################################
		
		
		local msg = txtChatPrefix
		
		if outLevel then
			msg = msg .. outLevel
		end
		if outBOE then
			msg = msg..", " .. outBOE
		end
		if outHM then
			msg = msg..", " .. outHM
		end
		if outHC then
			msg = msg..", " .. outHC
		end
		if outType then
			msg = msg..", " .. outType
		end
		if outClasses then
			msg = msg..", " .. outClasses
		end
		if #itemStatTable > 0 then
			msg = msg..", " .. "|cff80FF80" .. strjoin(", ", tostringall( unpack(itemStatTable) )) .. "|r"
		end
		wipe(itemStatTable)
		
		
		-- print("-|-", strjoin("; ", tostringall(arg1,arg11)))
		-- msg = txtChatPrefix .. strjoin("; ", tostringall(itemLevel, "\nitemType", itemType, "\nitemSubType", itemSubType, "\nitemEquipLoc", itemEquipLoc))
		
		-- print("-|-", strjoin("; ", tostringall(itemLevel, "\nitemType", itemType, "\nitemSubType", itemSubType, "\nitemEquipLoc", itemEquipLoc)) )
		
		msg = arg1 .. "\n" .. msg
		-- msg = msg .. " -- " .. itemEquipLoc
		if not outLevel then
			ORIG_ChatFrame_MessageEventHandler(self, event, ... );
			return
		end
		
		ORIG_ChatFrame_MessageEventHandler(self, event, msg, select(2,...) );
	end
end