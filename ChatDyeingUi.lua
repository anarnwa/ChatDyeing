local function CreateUIFrames()
    if MainFrame ~= nil then
        MainFrame:Show()
        return
    end
    MainFrame = CreateFrame("Frame", "chatdyeing", UIParent, "PortraitFrameTemplate")
    MainFrame:SetFrameStrata("DIALOG")
    MainFrame:SetWidth(500)
    MainFrame:SetHeight(300)
    MainFrame:SetPoint("CENTER", UIParent)
    MainFrame:SetMovable(true)
    MainFrame:EnableMouse(true)
    MainFrame:RegisterForDrag("LeftButton", "RightButton")
    MainFrame:SetClampedToScreen(true)
    MainFrame.title = _G["chatdyeingTitleText"]
    MainFrame.title:SetText("chatdyeing")
    MainFrame:SetScript("OnMouseDown",
        function(self)
            self:StartMoving()
            self.isMoving = true
        end)
    
    MainFrame:SetScript("OnMouseUp",
        function(self)
            if self.isMoving then
                self:StopMovingOrSizing()
                self.isMoving = false
            end
        end)
    
    MainFrame:SetScript("OnShow",
        function(self)
            if GIL_SyncOK == false then
                SyncIgnoreList()
            end
        end)
    
    local icon = MainFrame:CreateTexture("$parentIcon", "OVERLAY", nil, -8)
    --图标
    icon:SetSize(60, 60)
    icon:SetPoint("TOPLEFT", -5, 7)
    icon:SetTexture("Interface\\FriendsFrame\\Battlenet-Portrait")
    --标题
    Text = MainFrame:CreateFontString("FontString", "OVERLAY", "GameFontNormalLarge")
    Text:SetPoint("TOPLEFT", MainFrame, "TOPLEFT", 20, -25)
    Text:SetWidth(200)
    Text:SetText("ChatDyeing设置")
    --是否开启插件
    Button = CreateFrame("CheckButton", "chatdyeingopened", MainFrame, "UICheckButtonTemplate")
    Button:SetPoint("TOPLEFT", Text, "BOTTOMLEFT", 30, -10)
    _G[Button:GetName() .. "Text"]:SetText("开启插件")
    _G[Button:GetName() .. "Text"]:SetFontObject("GameFontHighlight")
    Button:SetChecked(ChatDyeingSettings.chatdyeingopen == true)
    Button:SetScript("OnClick", function(self)ChatDyeingSettings.chatdyeingopen = (self:GetChecked() or false) end)
    --只过滤小队或团队成员
    Button = CreateFrame("CheckButton", "chatdyeingonlyparty", MainFrame, "UICheckButtonTemplate")
    Button:SetPoint("TOPLEFT", Text, "BOTTOMLEFT", 30, -50)
    _G[Button:GetName() .. "Text"]:SetText("只过滤小队或团队成员")
    _G[Button:GetName() .. "Text"]:SetFontObject("GameFontHighlight")
    Button:SetChecked(ChatDyeingSettings.chatdyeingonlyparty == true)
    Button:SetScript("OnClick", function(self)ChatDyeingSettings.chatdyeingonlyparty = (self:GetChecked() or false) end)
    --忽略不完整的姓名
    Button = CreateFrame("CheckButton", "chatdyeingonlycomplete", MainFrame, "UICheckButtonTemplate")
    Button:SetPoint("TOPLEFT", Text, "BOTTOMLEFT", 30, -90)
    _G[Button:GetName() .. "Text"]:SetText("只为完整姓名-服务器进行染色(变更地图或重载后生效)")
    _G[Button:GetName() .. "Text"]:SetFontObject("GameFontHighlight")
    Button:SetChecked(ChatDyeingSettings.chatdyeingonlycomplete == true)
    Button:SetScript("OnClick", function(self)ChatDyeingSettings.chatdyeingonlycomplete = (self:GetChecked() or false) end)
    --停止记录新数据
    Button = CreateFrame("CheckButton", "chatdyeingstoprecording", MainFrame, "UICheckButtonTemplate")
    Button:SetPoint("TOPLEFT", Text, "BOTTOMLEFT", 30, -130)
    _G[Button:GetName() .. "Text"]:SetText("停止记录新数据")
    _G[Button:GetName() .. "Text"]:SetFontObject("GameFontHighlight")
    Button:SetChecked(ChatDyeingSettings.chatdyeingstoprecording == true)
    Button:SetScript("OnClick", function(self)ChatDyeingSettings.chatdyeingstoprecording = (self:GetChecked() or false) end)
    --清空记录
    Button = CreateFrame("Button", "chatdyeingcleanrecord", MainFrame, "UIPanelButtonTemplate")
    Button:SetSize(120, 30)
    Button:SetNormalFontObject("GameFontNormalSmall")
    Button:SetText("清空已记录数据")
    Button:SetPoint("TOPLEFT", Text, "BOTTOMLEFT", 30, -200)
    Button:SetScript("OnClick", function(self)ChatDyeing = {} end)
    --显示窗口
    MainFrame:Show()
end

function SlashCmdList.ChatDyeing(msg)
    CreateUIFrames()
end

SLASH_ChatDyeing1 = "/cd"
SLASH_ChatDyeing2 = "/chatdyeing"
