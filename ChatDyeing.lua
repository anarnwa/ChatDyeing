local friends = {}
--存储关键字
--注册事件
local function Event(event, handler)
    if _G.event == nil then
        _G.event = CreateFrame('Frame')
        _G.event.handler = {}
        _G.event.OnEvent = function(frame, event, ...)
            for key, handler in pairs(_G.event.handler[event]) do
                handler(...)
            end
        end
        _G.event:SetScript('OnEvent', _G.event.OnEvent)
    end
    if _G.event.handler[event] == nil then
        _G.event.handler[event] = {}
        _G.event:RegisterEvent(event)
    end
    table.insert(_G.event.handler[event], handler)
end
--获取目标职业
local function GetClass(name)
    if name then
        if UnitInRaid(name) or UnitInParty(name) or name == 'player' then
            local _, rsctekclass = UnitClass(name)
            if rsctekclass then
                rsctekclass = string.upper(rsctekclass)
                return rsctekclass
            end
        else
            return ''
        end
    end
end
--返回存储的角色职业
local function GetColor(name)
    if name then
        local realm = nil
        local _, localrealm = UnitFullName('player', true)

        if string.find(name, '%-') then
            realm = string.sub(name, string.find(name, '%-') + 1, -1)
        end

        if string.find(name, '%%') then
            name = string.sub(name, 1, string.find(name, '%%') - 1)
        end

        local color = GetClass(name)

        if color ~= '' then
            return color
        end
        if ChatDyeingSettings.chatdyeingonlyparty == true then
            return ''
        end
        for i in pairs(ChatDyeing) do
            if
                (name == ChatDyeing[i]['oname'] and (realm == '' or realm == nil) and
                    localrealm == ChatDyeing[i]['orealm'])
             then
                return ChatDyeing[i]['oclass']
            end
        end

        for i in pairs(ChatDyeing) do
            if (name == ChatDyeing[i]['oname'] and (realm == ChatDyeing[i]['orealm'] or realm == '' or realm == nil)) then
                return ChatDyeing[i]['oclass']
            end
        end
        return ''
    end
end
--获取字符串最后一个|c后的字符
local function substringend(str, k)
    local ts = string.reverse(str)
    k = string.reverse(k)
    _, i = string.find(ts, k)
    if i then
        m = string.len(ts) - i + 1
        return string.sub(str, m + 10, -1)
    end
    return '|r'
end
--为字符串添加颜色
local function addcolor(str1, tag, str2)
    local strmid = string.gsub(tag, '%%%-', '-')
    local str1end = substringend(string.lower(str1), '|cff')
    local stra, strb = string.find(str1end, '|r')
    if stra then
        pcall(
            function()
                strmid = '|c' .. RAID_CLASS_COLORS[GetColor(tag)].colorStr .. strmid .. '|r'
            end
        )
    --处理tag  将tag染色
    end
    local a, b = string.find(str2, tag)
    --查看后续还有没有tag
    if a then --如果有
        str2 = addcolor(string.sub(str2, 1, a - 1), tag, string.sub(str2, b + 1, -1))
    --对后续部分继续染色
    end
    return str1 .. strmid .. tostring(str2)
end
--过滤函数
local psfilter = function(_, event, msg, player, ...)
    if ChatDyeingSettings.chatdyeingopen == false then
        return false
    end
    if friends == {} then
        return false
    else
        local tag = ''
        for i = 1, #(friends) do
            tag = friends[i]
            a, b = string.find(msg, tag)
            if a then
                msg = addcolor(string.sub(msg, 1, a - 1), tag, string.sub(msg, b + 1, -1))
            end
        end
        for i = 1, #(friends) do
            tag = friends[i]
            if string.find(msg, '|Hplayer:.+' .. tag .. '|r|h%[.+' .. tag .. '|r%]|h') then
                msg =
                    string.gsub(
                    msg,
                    '|Hplayer:.+' .. tag .. '|r|h%[.+' .. tag .. '|r%]|h',
                    '[|c' .. RAID_CLASS_COLORS[GetColor(tag)].colorStr .. '|Hplayer:' .. tag .. '|h' .. tag .. '|h|r]'
                )
            end
        end
        return false, msg, player, ...
    end
end
--移除黑名单数据
local function removedisable()
    for i, j in ipairs(ChatDyeingDisable) do
        for k, v in ipairs(friends) do
            if j == v then
                table.remove(friends, k)
            end
        end
    end
end
--添加关键字
local function addfriends()
    friends = {}
    local name, realm = UnitFullName('player')
    for i in pairs(ChatDyeing) do
        table.insert(friends, ChatDyeing[i]['oname'] .. '%-' .. ChatDyeing[i]['orealm'])
        if ChatDyeingSettings.chatdyeingonlycomplete == false then
            table.insert(friends, ChatDyeing[i]['oname'])
        end
    end
    removedisable()
    local aa = {}
    for k, v in pairs(friends) do
        aa[v] = true
    end
    friends = {}
    for k, v in pairs(aa) do
        table.insert(friends, k)
    end
    table.sort(
        friends,
        function(a, b)
            if string.len(a) > string.len(b) then
                return true
            end
            if string.len(a) < string.len(b) then
                return false
            end
            return tostring(a) > tostring(b)
        end
    )
end
--存储信息
local function addfilterlist()
    if ChatDyeingSettings.chatdyeingstoprecording then
        return
    end
    local name, realm = UnitFullName('player')
    ChatDyeing[name .. '-' .. realm] = {
        oname = name,
        oclass = GetClass('player'),
        orealm = realm
    }
    if IsInRaid() then
        rnum = GetNumGroupMembers()
        for i = 1, rnum - 1 do
            local name1 = GetUnitName('raid' .. i, true)
            local realm1 = string.gsub(name1, '.+%-', '')
            name1 = string.gsub(name1, '%-' .. realm1, '')
            if realm1 == '' or realm1 == nil or realm1 == name1 then
                realm1 = realm
            end
            ChatDyeing[name1 .. '-' .. realm1] = {
                oname = name1,
                oclass = GetClass(name1),
                orealm = realm1
            }
        end
    else
        if IsInGroup() then
            rnum = GetNumGroupMembers()
            for i = 1, rnum - 1 do
                local name1 = GetUnitName('party' .. i, true)
                local realm1 = string.gsub(name1, '.+%-', '')
                name1 = string.gsub(name1, '%-' .. realm1, '')
                if realm1 == '' or realm1 == nil or realm1 == name1 then
                    realm1 = realm
                end
                ChatDyeing[name1 .. '-' .. realm1] = {
                    oname = name1,
                    oclass = GetClass(name1),
                    orealm = realm1
                }
            end
        end
    end
end
--过滤频道
local function ADDfilter()
    ChatFrame_AddMessageEventFilter('CHAT_MSG_ACHIEVEMENT', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_AFK', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_BG_SYSTEM_ALLIANCE', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_BG_SYSTEM_HORDE', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_BG_SYSTEM_NEUTRAL', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_BN', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_BN_INLINE_TOAST_ALERT', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_BN_INLINE_TOAST_BROADCAST', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_BN_INLINE_TOAST_BROADCAST_INFORM', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_BN_INLINE_TOAST_CONVERSATION', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_BN_WHISPER', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_BN_WHISPER_INFORM', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_BN_WHISPER_PLAYER_OFFLINE', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_CHANNEL', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_CHANNEL_JOIN', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_CHANNEL_LEAVE', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_CHANNEL_LIST', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_CHANNEL_NOTICE', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_CHANNEL_NOTICE_USER', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_COMBAT_FACTION_CHANGE', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_COMBAT_HONOR_GAIN', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_COMBAT_MISC_INFO', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_COMBAT_XP_GAIN', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_COMMUNITIES_CHANNEL', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_CURRENCY', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_DND', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_EMOTE', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_FILTERED', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_GUILD', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_GUILD_ACHIEVEMENT', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_GUILD_ITEM_LOOTED', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_IGNORED', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_INSTANCE_CHAT', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_INSTANCE_CHAT_LEADER', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_LOOT', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_MONEY', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_MONSTER_EMOTE', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_MONSTER_PARTY', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_MONSTER_SAY', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_MONSTER_WHISPER', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_MONSTER_YELL', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_OFFICER', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_OPENING', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_PARTY', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_PARTY_LEADER', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_PET_BATTLE_COMBAT_LOG', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_PET_BATTLE_INFO', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_PET_INFO', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_RAID', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_RAID_BOSS_EMOTE', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_RAID_BOSS_WHISPER', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_RAID_LEADER', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_RAID_WARNING', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_RESTRICTED', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_SAY', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_SKILL', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_SYSTEM', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_TARGETICONS', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_TEXT_EMOTE', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_TRADESKILLS', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_WHISPER', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_WHISPER_INFORM', psfilter)
    ChatFrame_AddMessageEventFilter('CHAT_MSG_YELL', psfilter)
end
--玩家登陆事件
Event(
    'PLAYER_LOGIN',
    function()
        ADDfilter() --添加频道
    end
)
--队伍更新
Event(
    'GROUP_ROSTER_UPDATE',
    function()
        addfilterlist() --更新数据表
        addfriends() --根据数据表更新过滤器
    end
)
--插件加载事件
Event(
    'ADDON_LOADED',
    function()
        if not ChatDyeing then
            ChatDyeing = {}
        end
        if not ChatDyeingSettings then
            ChatDyeingSettings = {}
        end
        if not ChatDyeingDisable then
            ChatDyeingDisable = {}
        end
        if not ChatDyeingSettings.chatdyeingopen then
            ChatDyeingSettings.chatdyeingopen = true
        end
        if not ChatDyeingSettings.chatdyeingonlyparty then
            ChatDyeingSettings.chatdyeingonlyparty = false
        end
        if not ChatDyeingSettings.chatdyeingonlycomplete then
            ChatDyeingSettings.chatdyeingonlycomplete = false
        end
        if not ChatDyeingSettings.chatdyeingstoprecording then
            ChatDyeingSettings.chatdyeingstoprecording = false
        end
    end
)
