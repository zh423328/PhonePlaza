-- OxtbNew
--获取使用kernel类函数
local ClientKernel = require("common.ClientKernel")--外部公共库kernel
local GameKernel   = import("..Kernel.GameKernel")--内部公共库kernel
local oxui     = import("..Kernel.oxui")--辅助ui
local GameUser     = import("..View.Player")--玩家管理
local CardControl  = import("..View.CardControl")--用户牌管理
--local HeapCard     = import("..View.HeapCard")--牌堆管理
local PokerCard = import("..Kernel.PokerCard")
local GameLogic = import("..Kernel.GameLogic")--主逻辑

local settingUI = import("..View.SettingView")--主逻辑
local talkUI = import("..View.TalkWidget")--主逻辑

--声明游戏场景类
local OxtbNew  = class("OxtbNew", function() return display.newScene("OxtbNew")end)

local MAX_TIME = 10
local CMD_C_CallBanker = {}
local CMD_C_AddScore = {}
local CMD_C_CHANGE_CARD = {}
local CMD_C_OxCard = {}
--本类的构造函数
function OxtbNew:ctor(args)
    display.addSpriteFrames("oxtbnew/UIGameIng.plist","oxtbnew/UIGameIng.png")
    display.addSpriteFrames("oxtbnew/talkWidgetPlist.plist","oxtbnew/talkWidgetPlist.png")
    display.addSpriteFrames("oxtbnew/settingWidgetPlist.plist","oxtbnew/settingWidgetPlist.png")

    self.App=AppBaseInstanse.OxtbNewApp

    self:setNodeEventEnabled(true)
    self.gameState = OxtbNewDefine.SUB_S_GAME_START
    self.wBankerUser = nil
    self.handCardControl = {}
    self.timerCount = 0
    self.t_Start = nil
    self.t_Open = nil
    self.isTrust = false
    self.totalScoure = 0
    --创建gamekernel
    if args.gameClient then
        self.gameClient = args.gameClient
        self.ClientKernel = ClientKernel.new(self.gameClient,self.App.EventCenter)
        --声明conmand对象
        self.m_GameKernel=GameKernel.new(self.ClientKernel)

    end
    --设置游戏属性
    local gameAttribute =
        {
            wKindID=OxtbNewDefine.KIND_ID,
            wPlayerCount=OxtbNewDefine.GAME_PLAYER,
            dwClientVersion=OxtbNewDefine.VERSION_CLIENT,
            pszGameName=OxtbNewDefine.GAME_NAME,
        }
    self.m_GameKernel:getClientKernel():SetGameAttribute(gameAttribute)

    print("注册事件管理")
    self:RegistEventManager() --注册事件管理
    print("注册事件管理结束")
    self:InitUnits()          --加载资源
    self:FreeAllData()        --初始化数据
    self:ButtonMsg()          --控件消息
end

--初始化数据
function OxtbNew:FreeAllData()
    --首发牌用户
    self.HandCardCount={0,0}
    for i=1, OxtbNewDefine.GAME_PLAYER do
        self.handCardControl[i]:FreeControl()
    end

    local xspac = 200
    local yspac = 200
    local xx = display.cx + 200
    local xj = display.cx - 200
    self.handCardPos=
        {
            cc.p(display.cx-80,display.height -180),--1号位置 对家
            cc.p(xx-40,display.height -220),--2号位置 对家
            cc.p(xx +40,275),--3号位置 对家
            cc.p(display.cx-300,120),--4号位置 对家
            cc.p(xj-190,275),--5号位置 对家
            cc.p(xj-100,display.height -220),--6号位置 对家
        }
    self.wBankerUser = nil
    self.bUserOxCard = {}
    self.lTurnMaxScore = 0
    self.ismoveDisPach = true
    
    self.lUserMaxScore = {}
    self.pokerCards = {}
    self.pokerCount = 0
    self.wWinUser = 0 --记录上次赢得玩家
    self.cbPlayStatus = {} --所有玩家状态
    self.wViewChairID = {} --对应视图位置
    self.countindex = 0
    self.m_GameUser:FreeAllAddSouce()
    self.openView:hide()
    self.m_GameUser:FreeAllBanders()
end
--加载资源
function OxtbNew:InitUnits()

    --读取json 文件
    local node = oxui.getUIByName("oxtbnew/oxsixLayer.json")
    self.node  = node
    node:addTo(self)
    node:setContentSize(display.width,display.height)
    self.btnStart=oxui.getNodeByName(node,"btnStart")
    --退出按钮
    self.btnLeave=oxui.getNodeByName(node,"btnLeave")
    --托管按钮
    self.btnTrust=oxui.getNodeByName(node,"btnTrust")
    self.btnTrust:hide()
    --设置按钮
    self.btnSetting=oxui.getNodeByName(node,"btnSetting")
    --任务按钮
    self.btnTask=oxui.getNodeByName(node,"btnTask")
    self.btnTask:hide()
    self.Totalay=oxui.getNodeByName(node,"Totalay")
    self.TotaScoure=oxui.getNodeByName(self.Totalay,"TotaScoure")
    --托管
    --self.btnTrust=oxui.getNodeByName(node,"btnTrust")
    self.btnChangeDesk=oxui.getNodeByName(node,"btnChangeDesk") 
    --self.btnChangeDesk:hide()
    self.trustLayer=oxui.getNodeByName(node,"trustLayer")
    self.btnCloseTrust=oxui.getNodeByName(self.trustLayer,"btnCloseTrust")
    --任务按钮
    self.clock=oxui.getNodeByName(node,"clock")
    --时间
    self.lbltime=oxui.getNodeByName(node,"time")
    --名称
    self.lab=oxui.getNodeByName(node,"lab")
    --开牌视图
    self.openView=oxui.getNodeByName(node,"openView")
    self.btnOpen=oxui.getNodeByName(self.openView,"btnOpen")
    self.btnTip=oxui.getNodeByName(self.openView,"btnTip")
    self.btnChat = oxui.getNodeByName(node,"btnChat")
    --声明Player对象
    self.m_GameUser=GameUser.new(node,self.m_GameKernel)
    --加载牌的资源
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("Common/AnimationCard.ExportJson")

    -- --牌堆位置
    self.HeapPos=cc.p(display.cx,display.cy)
    --用户手牌的位置

    --初始化牌堆
    self:InitHeapCard()
    --初始化手牌
    self:InitHandCardControl() 
    
    require("plazacenter.widgets.GameHornMsgWidget").new(self)
end  
--初始化牌堆
function OxtbNew:InitHeapCard()
    --发牌张数
    self.DispatchCount={0,0}

    for i=1,OxtbNewDefine.GAME_PLAYER do
        table.insert(self.handCardControl,CardControl.new())
    end

    local xspac = 200
    local yspac = 200
    local xx = display.cx + 200
    local xj = display.cx - 200
    --卡牌位置
    self.handCardPos=
        {
            cc.p(display.cx-80,display.height -180),--1号位置 对家
            cc.p(xx-40,display.height -220),--2号位置 对家
            cc.p(xx +40,275),--3号位置 对家
            cc.p(display.cx-300,120),--4号位置 对家
            cc.p(xj-190,275),--5号位置 对家
            cc.p(xj-100,display.height -220),--6号位置 对家
        }
    --用户手牌的间距
    self.handCardDistance=
        {
            22,--0号位置 对家
            22,--0号位置 对家
            22,--0号位置 对家
            100,--1号位置 对家
            22,--0号位置 对家
            22,--0号位置 对家

        }
    --用户手牌的大小
    self.handCardScal=
        {
            0.6,--1号位置 对家
            0.6,--2号位置 对家
            0.6,--3号位置 对家
            0.8,--4号位置 对家
            0.6,--5号位置 对家
            0.6,--6号位置 对家
        }

end
--初始化手牌
function OxtbNew:InitHandCardControl()
    for i=1, OxtbNewDefine.GAME_PLAYER do
        self.handCardControl[i]:SetStartPos(self.handCardPos[i])
        self.handCardControl[i]:SetDistance(self.handCardDistance[i])
        --self.handCardControl[i]:SetScal(self.handCardScal[i])
        self.handCardControl[i]:addTo(self.node)
        --self.handCardControl[i]:zorder(100)
        if i == OxtbNewDefine.MYSELF_VIEW_ID then
            self.handCardControl[i]:SetShow(true)
            self.handCardControl[i]:SetCardTouchEnabled(true)
        else
            self.handCardControl[i]:SetShow(false)
            self.handCardControl[i]:SetCardTouchEnabled(false)
        end
    end
end

--开始发牌
function OxtbNew:StartDisPachCard()
    --发牌张数
    self:stopAllTimer()
    self.dispatchCardCount=0
    self.HandCardCount={0,0}
    if self.ismoveDisPach then
        self.ismoveDisPach = false
        self:moveDisPachCard()
    end
end

function OxtbNew:DisPatchOneCardEnd(evt)
    oxui.playSound("SEND_CARD",false,OxtbNewDefine.wav)
    self.pokerCount = self.pokerCount - 1
    if self.pokerCount == 0 then
        self:OnSendCardFinish()
    end
end

--控件消息
function OxtbNew:ButtonMsg()
    -------------------------------------------------
    --开始按钮事件
    -------------------------------------------------
    self.btnStart:onButtonClicked(function ()
        self.m_GameKernel:StartGame()
        --if self:IsNotLookonMode() then
        self:stopAllTimer()
        --end
        self.btnStart:hide()
    end)
    --开始按钮按下
    self.btnStart:onButtonPressed(function ()
        self:playScaleAnimation(true,self.btnStart)
    end)

    --开始按钮抬起
    self.btnStart:onButtonRelease(function ()
        self:playScaleAnimation(false,self.btnStart)
    end)
    -------------------------------------------------
    --离开按钮事件
    -------------------------------------------------
    self.btnLeave:onButtonClicked(function ()
        --self:stopTimer()
        self:Exit()
    end)
    --离开按钮按下
    self.btnLeave:onButtonPressed(function ()
        self:playScaleAnimation(true,self.btnLeave)
    end)

    --离开按钮抬起
    self.btnLeave:onButtonRelease(function ()
        self:playScaleAnimation(false,self.btnLeave)
    end)
    
    -------------------------------------------------
    --换桌按钮事件
    -------------------------------------------------

    self.btnChangeDesk:onButtonClicked(function ()
        self:FreeAllData()
        self.ClientKernel:quickChangeTable()
    end)
    --托管按钮按下
    self.btnChangeDesk:onButtonPressed(function ()
        self:playScaleAnimation(true,self.btnChangeDesk)
    end)

    --托管按钮抬起
    self.btnChangeDesk:onButtonRelease(function ()
        self:playScaleAnimation(false,self.btnChangeDesk)
    end)
    -------------------------------------------------
    --提示按钮事件
    -------------------------------------------------

    self.btnChat:onButtonClicked(function ()
        dump("提示")
        if not  self.isChat then
            self.isChat = true
            self.chatView = talkUI.new(self.ClientKernel)
            self.chatView:setPosition(cc.p(display.width - 408,56))
            self:addChild(self.chatView)
        else
            self.isChat= false
            self.chatView:removeFromParent()
            self.chatView= nil
        end

    end)
    --提示按钮按下
    self.btnChat:onButtonPressed(function ()
        self:playScaleAnimation(true,self.btnChat)

    end)

    --离开按钮抬起
    self.btnChat:onButtonRelease(function ()
        self:playScaleAnimation(false,self.btnChat)
    end)
    -------------------------------------------------
    --托管按钮事件
    -------------------------------------------------

    self.btnTrust:onButtonClicked(function ()
        dump("提示")
        self.isTrust = true
        self.trustLayer:show()
        self.btnTrust:hide()
    end)
    --托管按钮按下
    self.btnTrust:onButtonPressed(function ()
        self:playScaleAnimation(true,self.btnTrust)
    end)

    --托管按钮抬起
    self.btnTrust:onButtonRelease(function ()
        self:playScaleAnimation(false,self.btnTrust)
    end)
    --------------------------------------------------
    --托管按钮事件
    -------------------------------------------------
    self.btnCloseTrust:onButtonClicked(function ()
        dump("托管按钮事件")
        self.trustLayer:hide()
        self.isTrust = false
        self.btnTrust:show()
    end)
    --托管按钮按下
    self.btnCloseTrust:onButtonPressed(function ()
        self:playScaleAnimation(true,self.btnCloseTrust)
    end)

    --托管按钮抬起
    self.btnCloseTrust:onButtonRelease(function ()
        self:playScaleAnimation(false,self.btnCloseTrust)
    end)
    --------------------------------------------------
    --设置按钮事件
    -------------------------------------------------
    self.btnSetting:onButtonClicked(function ()
        dump("设置按钮事件")
        local settingView = settingUI.new()
        settingView:setPosition(cc.p(display.cx,display.cy))
        self:addChild(settingView)
    end)
    --设置按钮按下
    self.btnSetting:onButtonPressed(function ()
        self:playScaleAnimation(true,self.btnSetting)
    end)

    --设置按钮抬起
    self.btnSetting:onButtonRelease(function ()
        self:playScaleAnimation(false,self.btnSetting)
    end)
    --------------------------------------------------
    --任务按钮事件
    -------------------------------------------------
    self.btnTask:onButtonClicked(function ()
        dump("任务按钮事件")
    end)
    --任务按钮按下
    self.btnTask:onButtonPressed(function ()
        self:playScaleAnimation(true,self.btnTask)
    end)

    --任务按钮抬起
    self.btnTask:onButtonRelease(function ()
        self:playScaleAnimation(false,self.btnTask)
    end)
    --------------------------------------------------
    self.btnOpen:onButtonClicked(function ()
        self:sendOpenMsg()
        --self.openView:hide()
    end)
    
    self.btnOpen:onButtonPressed(function ()
        self:playScaleAnimation(true,self.btnOpen)
    end)

    --设置按钮抬起
    self.btnOpen:onButtonRelease(function ()
        self:playScaleAnimation(false,self.btnOpen)
    end)
    
    self.btnTip:onButtonPressed(function ()
        self:playScaleAnimation(true,self.btnTip)
    end)

    --设置按钮抬起
    self.btnTip:onButtonRelease(function ()
        self:playScaleAnimation(false,self.btnTip)
    end)
    
    self.btnTip:onButtonClicked(function ()
        local cardData = self.cbHandCardData[self:GetMeChairID()+1]
        
        local bCardValue,outCardData = GameLogic:GetCardType(cardData,OxtbNewDefine.MAXCOUNT) 
        if bCardValue > 0 then
            self.handCardControl[OxtbNewDefine.MYSELF_VIEW_ID]:SetShootCard(outCardData,3)
        else
            self.openView:hide()
            self:SetAnimCard(OxtbNewDefine.MYSELF_VIEW_ID,0)
            local bOX = 0
            CMD_C_OxCard = {bOX = bOX}
            self:send(OxtbNewDefine.SUB_C_OPEN_CARD,CMD_C_OxCard ,"CMD_C_OxCard")
        end
    end) 
end

function OxtbNew:sendOpenMsg()
    local cardData = self.cbHandCardData[self:GetMeChairID()+1]
    local bOX = 0
    if GameLogic:GetOxCard(cardData,OxtbNewDefine.MAXCOUNT) then
        bOX = 1
    end
    print("open")
    CMD_C_OxCard = {bOX = bOX}
    self:send(OxtbNewDefine.SUB_C_OPEN_CARD,CMD_C_OxCard ,"CMD_C_OxCard")
end

function OxtbNew:sendAddSource()
    local score = {}
    score.lScore =  self.lTurnMaxScore
    self:send(OxtbNewDefine.SUB_C_ADD_SCORE,score ,"CMD_C_AddScore")
end



---------------[[以下是接收游戏服务端消息处理]]--------------
--场景
function OxtbNew:OnGameScenceMsg(evt)
    print("场景====++++++++++++++++++++++++++++++++++")
    --dump(evt.para);
    local unResolvedData = evt.para.unResolvedData
    local param = evt.para
    --    print("param.cbGameStatus" ..self.ClientKernel.cbGameStatus)
    --    print("elf:getMyStatus() = " .. self:getMyStatus())
    
    local gameStatus = self.ClientKernel.cbGameStatus
    if gameStatus==OxtbNewDefine.GS_TK_FREE then
        print("空闲状态")
        local statusInfo = self.ClientKernel:ParseStruct(unResolvedData.dataPtr,unResolvedData.size,"CMD_S_StatusFree")

        if self:getMyStatus() == US_SIT and self:getMyStatus() ~= US_PLAYING then
            local lCellScore = statusInfo.lCellScore
            if not self.t_Start then
                self.gameState = OxtbNewDefine.GS_TK_FREE
                self.timerCount = 10
                self.t_Start = oxui.schedule(function()self:updateState() end,OxtbNewDefine.TIME_INTERVAL,OxtbNewDefine.TIME_USER_START_GAME)
            end

            self.btnStart:show()
        end
        --叫庄状态
    elseif gameStatus==OxtbNewDefine.GS_TK_CALL then

       local statusInfo = self.ClientKernel:ParseStruct(unResolvedData.dataPtr,unResolvedData.size,"CMD_S_StatusCall")
        
        local mycbPlayStatus = statusInfo.cbPlayStatus 
        local m_wBankerUser=statusInfo.wBankerUser
        
        print("  游戏开始中-------000-----叫庄状态 ")
        self.btnStart:hide() 
        --更新状态
        for i=0,OxtbNewDefine.MAXCOUNT do
            self.wViewChairID[i] = self.m_GameKernel:SwitchViewChairID(i)
            self:setUserPlayingStatus(self.wViewChairID[i],mycbPlayStatus[i]) 
        end 
        --设置筹码
        --self:updateAddSourceView(ishow)
        
        if(self:IsNotLookonMode() and m_wBankerUser==self:GetMeChairID()) then 
            self.BankerView:show()
        end
        
        if m_wBankerUser == self:GetMeChairID() then
            if not self.t_Bander then
                self:stopAllTimer()
                self.gameState = OxtbNewDefine.SUB_S_CALL_BANKER
                self.timerCount = OxtbNewDefine.TIME_USER_CALL_BANKER
                self.t_Bander = oxui.schedule(function()
                    self:updateState()
                end ,
                OxtbNewDefine.TIME_INTERVAL,
                OxtbNewDefine.TIME_USER_CALL_BANKER)
            end
        else
            if not self.t_Bander then
                self:stopAllTimer()
                self.gameState = OxtbNewDefine.SUB_S_CALL_OTH
                self.timerCount = OxtbNewDefine.TIME_USER_CALL_BANKER
                self.t_Bander = oxui.schedule(function()
                    self:updateState()
                end ,
                OxtbNewDefine.TIME_INTERVAL,
                OxtbNewDefine.TIME_USER_CALL_BANKER)
            end
        end
        print("  游戏开始中-------000-----叫庄状态 ")
        --self.btnStart:hide()
    elseif gameStatus==OxtbNewDefine.GS_TK_SCORE then

        local statusInfo = self.ClientKernel:ParseStruct(unResolvedData.dataPtr,unResolvedData.size,"CMD_S_StatusScore")
        dump(statusInfo)
        print("下注-------000-----状态")
        local lTurnMaxScore = statusInfo.lTurnMaxScore
        local m_wBankerUser = statusInfo.wBankerUser  
        local m_lTableScore = statusInfo.lTableScore
        local mycbPlayStatus = statusInfo.cbPlayStatus 
        self.btnStart:hide() 
        --更新状态
        for i=0,OxtbNewDefine.MAXCOUNT do
            self.wViewChairID[i] = self.m_GameKernel:SwitchViewChairID(i)
            self:setUserPlayingStatus(self.wViewChairID[i],mycbPlayStatus[i])
--
--            if m_lTableScore[i+1]>0 then
--                self:setUserTableScore(self.wViewChairID[i],m_lTableScore[i+1]) 
--            end
        end
        --设置庄家
        self.m_GameUser:setBander(self.wViewChairID[m_wBankerUser]) 
        self.gameState = OxtbNewDefine.SUB_S_ADD_SCORE 
        if not self.t_Change then
            self:stopAllTimer()
            self.timerCount = OxtbNewDefine.TIME_USER_ADD_SCORE
            self.t_Change = oxui.schedule(function()
                self:updateState()
            end ,
            OxtbNewDefine.TIME_INTERVAL,
            OxtbNewDefine.TIME_USER_ADD_SCORE)
        end 
        --self.gameState = OxtbNewDefine.SUB_S_ADD_SCORE
    elseif gameStatus==OxtbNewDefine.GS_TK_PLAYING then
        local statusInfo = self.ClientKernel:ParseStruct(unResolvedData.dataPtr,unResolvedData.size,"CMD_S_StatusPlay")
        print("游戏-------000-----进行")
        self.lTurnMaxScore=statusInfo.lTurnMaxScore
        local wBankerUser=statusInfo.wBankerUser
        self.wBankerUser = wBankerUser
        local mycbPlayStatus = statusInfo.cbPlayStatus
        local m_lTableScore = statusInfo.lTableScore
        for i=0,OxtbNewDefine.GAME_PLAYER - 1 do
            self.wViewChairID[i] = self.m_GameKernel:SwitchViewChairID(i)
            self:setUserPlayingStatus(i,mycbPlayStatus[i+1])

--            if m_lTableScore[i+1]>0 then
--                self:setUserTableScore(self.wViewChairID[i],m_lTableScore[i+1])
--            end
        end
        self.btnStart:hide() 
        self.gameState = OxtbNewDefine.TIME_USER_OPEN_ING
        if not self.t_Open and self:IsNotLookonMode() then
            self:stopAllTimer()
            self.timerCount = OxtbNewDefine.TIME_USER_OPEN_ING
            self.t_Open = oxui.schedule(function()
                self:updateState()
            end ,
            OxtbNewDefine.TIME_INTERVAL,
            OxtbNewDefine.TIME_USER_OPEN_ING)
        end
    end
end

--退出
function OxtbNew:Exit() 
        if self.isTrust then
            local dataMsgBox =
                {
                    nodeParent=self,
                    msgboxType=MSGBOX_TYPE_OKCANCEL,
                    msgInfo="您当前正在托管，是否确定取消。",
                    callBack=function(ret)
                        if ret == MSGBOX_RETURN_OK then
                            oxui.removeAll()
                            self.m_GameUser:LeaveType()
                        end
                    end
                }
            local msgbox=require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        else
            if self:getMyStatus() == US_PLAYING then
                local dataMsgBox =
                    {
                        nodeParent=self,
                        msgboxType=MSGBOX_TYPE_OKCANCEL,
                        msgInfo="您当前正在游戏中，退出将会受到惩罚，是否确定退出？",
                        callBack=function(ret)
                            if ret == MSGBOX_RETURN_OK then
                                oxui.removeAll()
                                self.m_GameUser:LeaveType()
                            end
                        end
                    }
                local msgbox=require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
            else
                oxui.removeAll()
                self.m_GameUser:LeaveType()
            end
     end
end

function OxtbNew:OnSubPlayerOpen(evt)
    print("所有玩家都开完牌")
    self:stopAllTimer()
    local pPlayerOpen = evt.para
    local data = pPlayerOpen.cbCardData
    if pPlayerOpen.cbCardData then
        self:fntCardData(data)
    end
    if self.ismoveDisPach then
        self.ismoveDisPach = false
        self:moveDisPachCard()
    end
    local index = 1
    local t = 1
    for i=0,OxtbNewDefine.GAME_PLAYER do
        local wViewChairID=self.wViewChairID[i]
        if i~= self:GetMeChairID() then --self.cbPlayStatus[i]==OxtbNewDefine.USEX_PLAYING and 
            if self.cbHandCardData[i+1] and self.cbHandCardData[i+1][1] ~= 0 then
                dump(wViewChairID)
                dump(self.handCardControl[wViewChairID])
                dump(self.cbHandCardData[i+1])
                self.handCardControl[wViewChairID]:SetCardData(self.cbHandCardData[i+1],OxtbNewDefine.MAXCOUNT)
                local time = cc.DelayTime:create(t)
                t = t  + 1
                index = index + 1
                local fuc = cc.CallFunc:create(function()
                    self.handCardControl[wViewChairID]:SetShow(true) 
                    local cardData = self.cbHandCardData[i+1]
                    local num ,outCardData= GameLogic:GetCardType(cardData,OxtbNewDefine.MAXCOUNT)
                    if #outCardData == OxtbNewDefine.MAXCOUNT then
                        self:onOxEnable(false,i+1,outCardData)
                    else
                        self:onOxEnable(false,i+1,cardData)
                    end
                    
                    self:SetAnimCard(wViewChairID,num)
                end )
                self:runAction(cc.Sequence:create(time,fuc))
            end
        end
    end

    local d = cc.DelayTime:create(t)
    local c = cc.CallFunc:create(function()
        print("sendopenend")
        self:send(OxtbNewDefine.SUB_C_OPEN_END)
    end )
    self:runAction(cc.Sequence:create(d,c))
end
--游戏结束
function OxtbNew:OnSubGameOver(evt)
    local pGameEnd = evt.para
    dump(pGameEnd)
    print("游戏结束")
    self.wWinUser = pGameEnd.wWinUser or 0  
    self:stopAllTimer()
    
    function callFuck()
        local v = self:getChildByName("AnimationWin")
        if v then
            v:removeFromParent()
        end
        local v = self:getChildByName("AnimationLose")
        if v then
            v:removeFromParent()
        end
        dump(self.isTrust)
        if self.isTrust == false then
            self.gameState = OxtbNewDefine.GS_TK_FREE
            if not self.t_Start then
                self.timerCount = OxtbNewDefine.TIME_USER_START_GAME
                self.t_Start = oxui.schedule(function(t) self:updateState(OxtbNewDefine.TIME_USER_START_GAME - t) end ,OxtbNewDefine.TIME_INTERVAL,OxtbNewDefine.TIME_USER_START_GAME)
            end 
            self.btnStart:show() 
        end
    end
    
    if self:IsNotLookonMode() then
        if pGameEnd.lGameScore[self:GetMeChairID()+1] > 0 then
            oxui.playSound("GAME_WIN",false,OxtbNewDefine.m4a)
            local armature = oxui.playAnimation(self,1000,"AnimationGameEnd",0,false)
            armature:setName("AnimationWin")
            armature:setPosition(display.cx,display.cy)
            local ani = armature:getAnimation() 
            ani:setMovementEventCallFunc(function() callFuck() end)
        else
            oxui.playSound("GAME_LOST",false,OxtbNewDefine.m4a)
            local armature = oxui.playAnimation(self,1000,"AnimationGameEnd",1,false)
            armature:setName("AnimationLose")
            armature:setPosition(display.cx,display.cy)
            local ani = armature:getAnimation()
            ani:setMovementEventCallFunc(function() callFuck() end)
        end
    else
        self.gameState = OxtbNewDefine.GS_TK_FREE
        if not self.t_Start then
            self.timerCount = OxtbNewDefine.TIME_USER_START_GAME
            self.t_Start = oxui.schedule(function(t) self:updateState(OxtbNewDefine.TIME_USER_START_GAME - t) end ,OxtbNewDefine.TIME_INTERVAL,OxtbNewDefine.TIME_USER_START_GAME)
        end 
        self.btnStart:show()
    end
    
    self.totalScoure = self.totalScoure + pGameEnd.lGameScore[self:GetMeChairID()+1]
    self.TotaScoure:setString(oxui.BMString(self.totalScoure))
    --设置积分
    for  i=1,OxtbNewDefine.GAME_PLAYER do
        local souce = pGameEnd.lGameScore[i]
        if souce >= 0 then
            self.m_GameUser:ShowScore(self.wViewChairID[i-1],souce,true)
        else
            self.m_GameUser:ShowScore(self.wViewChairID[i-1],souce,false)
        end
    end
    
    

   
    self:FreeAllData()
  
    if self.isTrust then
        self:stopAllTimer()
        self.btnStart:hide()
        self.clock:hide()
        self.m_GameKernel:StartGame()
    end
end

function OxtbNew:stopAllTimer()
    self.clock:hide()
    --print("self.gamestage".. self.gameState)
    if self.t_Start then
        oxui.stop(self.t_Start)
        self.t_Start = nil
    end

    if self.t_Open then
        oxui.stop(self.t_Open)
        self.t_Open = nil
    end
end


--游戏开始
function OxtbNew:OnSubGameStart(evt)
    print("游戏开始")
    local user = evt.para
    dump(user)
    self.lTurnMaxScore=user.lTurnMaxScore
    self.wBankerUser=user.wBankerUser
    self:sendAddSource()
    oxui.playSound("GAME_START",false,OxtbNewDefine.m4a) 
    local armature = oxui.playAnimation(self,nil,"AnimationBeginGame",0,false)
    armature:setName("AnimationBeginGame")
    armature:setPosition(display.cx,display.cy)
    local ani = armature:getAnimation()
    ani:setMovementEventCallFunc(function(arm, eventType, movmentID)
        local v = self:getChildByName("AnimationBeginGame")
        if v then
            v:removeFromParent()
        end
    end)
    for i=1, OxtbNewDefine.GAME_PLAYER do
        if not self.m_GameUser.sixHeros[i-1] then
            self.wViewChairID[i-1] = self.m_GameKernel:SwitchViewChairID(i-1)
            self.cbPlayStatus[i-1] = OxtbNewDefine.USEX_NULL
        else
            self.wViewChairID[i-1] = self.m_GameKernel:SwitchViewChairID(i-1)
            self.cbPlayStatus[i-1]= OxtbNewDefine.USEX_PLAYING
        end
    end
    --    local m_lScoreTax=user.lScoreTax
    --
    --    local ViewID=self.m_GameKernel:SwitchViewChairID(self.wBankerUser)
    --    if self:IsNotLookonMode() and  self.lTurnMaxScore > 0 and user.wBankerUser ~= self:GetMeChairID() and self.cbPlayStatus[self.wBankerUser] == OxtbNewDefine.USEX_PLAYING then
    --        self.lUserMaxScore = {}
    --        local souce = self.lTurnMaxScore
    --        for i=1,4 do
    --            self.lUserMaxScore[i]= math.floor(souce)
    --            souce = souce / 2
    --        end
    --        self.addSourceView:show()
    --        self:updateAddSourceView(self.lUserMaxScore,true)
    --        print("进入加注")
    --    else
    --        print("开始游戏不满足")
    --    end
    --    oxui.playSound("GAME_START",false,OxtbNewDefine.m4a)
    --    if self.clock:isVisible() then
    --        self:stopAllTimer()
    --    end

    --self.m_GameUser:setBander(ViewID)
end

--加注结果
function OxtbNew:OnSubAddScore(evt)
    print("加注结果11111")
    local p = evt.para -- lAddScoreCount --加注数目
    dump(p)
    local ViewID=self.m_GameKernel:SwitchViewChairID(p.wAddScoreUser)
    print("ViewID 。。 " .. ViewID)
    -- if ViewID == OxtbNewDefine.MYSELF_VIEW_ID and self:IsNotLookonMode() then
    --     --self.gameState = OxtbNewDefine.SUB_S_ADD_SCORE
    --     --self:stopAllTimer()
    --     self:updateAddSourceView(nil,false)
    --     print("加注时器")
    -- end

    -- local wAddScoreUser=p.wAddScoreUser
    -- local wViewChairID=self.wViewChairID[wAddScoreUser]
    -- self:setUserTableScore(ViewID,p.lAddScoreCount)
    -- if self.cbPlayStatus[p.wAddScoreUser]==OxtbNewDefine.USEX_PLAYING then
    --     self:OnUserAddScore(wViewChairID,p.lAddScoreCount,false)
    -- end
    -- print("加注数目"  .. p.lAddScoreCount )
    -- oxui.playSound("ADD_SCORE" ,false, OxtbNewDefine.wav)

end

function OxtbNew:OnUserAddScore(id)
--移动筹码
--m_GoldMove.SetAddScore(wChairID,lTableScore,m_JetonStartPos[wChairID]);
end
--加注显示
function OxtbNew:updateAddScore(scrs)

end
--用户强退
function OxtbNew:OnSubPlayerExit(evt)
    print("用户强退1111")
    --dump(evt.para);
end
--发牌消息
function OxtbNew:OnSubSendCard(evt)
    print("发牌消息111")
    local pSendCard = evt.para
    local wMeChiarID=self:GetMeChairID()
    local wViewChairID=self.wViewChairID[wMeChiarID]
    self.MeCard = pSendCard.cbCardData
 
            self:dealCardRes(self.MeCard) 
end

--用户叫庄
function OxtbNew:OnSubCallBanker(evt)
    local p = evt.para
    local ViewID=self.m_GameKernel:SwitchViewChairID(p.wCallBanker)
    dump(p)
    print("叫庄")
    if p.bFirstTimes ==1 then
        local armature = oxui.playAnimation(self,nil,"AnimationBeginGame",0,false)
        armature:setName("AnimationBeginGame")
        armature:setPosition(display.cx,display.cy)
        local ani = armature:getAnimation()
        ani:setMovementEventCallFunc(function(arm, eventType, movmentID)
            local v = self:getChildByName("AnimationBeginGame")
            if v then
                v:removeFromParent()
                for i=1, OxtbNewDefine.GAME_PLAYER do
                    if not self.m_GameUser.sixHeros[i-1] then
                        self.wViewChairID[i-1] = self.m_GameKernel:SwitchViewChairID(i-1)
                        self.cbPlayStatus[i-1] = OxtbNewDefine.USEX_NULL
                    else
                        self.wViewChairID[i-1] = self.m_GameKernel:SwitchViewChairID(i-1)
                        self.cbPlayStatus[i-1]= OxtbNewDefine.USEX_PLAYING
                        --                     if self.wViewChairID[i-1] then
                        --                         self.m_GameUser:setSZName(self.wViewChairID[i-1],self.m_GameUser.sixHeros[i-1].szNickName)
                        --                     end
                    end
                end
            end
        end)
    end

    -- print("p.wCallBanker = ".. p.wCallBanker)
    -- print("self:GetMeChairID() ".. self:GetMeChairID())
    -- self:stopAllTimer()
    -- if p.wCallBanker == self:GetMeChairID() and self:IsNotLookonMode()  then
    --     self.BankerView:show()
    -- end
    -- local wViewID = self.wViewChairID[p.wCallBanker]
    -- if p.wCallBanker== self:GetMeChairID() then
    --     if not self.t_Bander then
    --         self:stopAllTimer()
    --         self.gameState = OxtbNewDefine.SUB_S_CALL_BANKER
    --         self.timerCount = OxtbNewDefine.TIME_USER_CALL_BANKER
    --         self.t_Bander = oxui.schedule(function()
    --             self:updateState()
    --         end ,
    --         OxtbNewDefine.TIME_INTERVAL,
    --         OxtbNewDefine.TIME_USER_CALL_BANKER)
    --     end
    -- else
    --     if not self.t_Bander then
    --         self:stopAllTimer()
    --         self.gameState = OxtbNewDefine.SUB_S_CALL_OTH
    --         self.timerCount = OxtbNewDefine.TIME_USER_CALL_BANKER
    --         self.t_Bander = oxui.schedule(function()
    --             self:updateState()
    --         end ,
    --         OxtbNewDefine.TIME_INTERVAL,
    --         OxtbNewDefine.TIME_USER_CALL_BANKER)
    --     end
    -- end

end
--发送基数
function OxtbNew:OnSubGameBase(evt)
    print("发送基数111")
    --dump(evt.para);
end
--摊牌
function OxtbNew:OnSubOpenCard(evt)
    print("所有人换牌完成 摊牌")
    local wChairID= self:GetMeChairID()

    if not self:IsNotLookonMode() then
        self.handCardControl[OxtbNewDefine.MYSELF_VIEW_ID]:SetPositively(true)
    end 
    if not self:IsNotLookonMode() then
        print("摊派过滤了")
        return
    end
    
    if self.cbHandCardData[wChairID+1] and self.cbHandCardData[wChairID+1][1] >0 then
   
    end


    if(self.cbPlayStatus[wChairID]==OxtbNewDefine.USEX_PLAYING) then
        self.openView:show()
    end

end

function OxtbNew:OnSubEndOpen(evt)
    print("开牌")
    local p = evt.para
    --dump(evt)
    local wChairID = self:GetMeChairID()
    local myViewID = self.wViewChairID[wChairID]
    local wID=p.wPlayerID
    if not self:IsNotLookonMode() then
        return
    end
    if self:IsCurrentUser(wID) then
        self.handCardControl[myViewID]:SetCardTouchEnabled(false)
        oxui.playSound("OPEN_CARD",false,OxtbNewDefine.wav)
    end

    if wID == self:GetMeChairID() then
        self.openView:hide()
        local cardData = self.cbHandCardData[self:GetMeChairID()+1] 
        local bCardValue,outCardData = GameLogic:GetCardType(cardData,OxtbNewDefine.MAXCOUNT) 
        if bCardValue > 0 then
            self:SetAnimCard(OxtbNewDefine.MYSELF_VIEW_ID,bCardValue)
            if #outCardData == 5 then
                self:onOxEnable(true,wID+1,outCardData)
            else
                self:onOxEnable(true,wID+1,cardData)
            end 
        else
            self:SetAnimCard(OxtbNewDefine.MYSELF_VIEW_ID,0)
        end
    end
end

function OxtbNew:SetAnimCard(wViewChairID,number)
   
    print("wViewChairID= %d, number= %d",wViewChairID,number)
    
    if number == false then
        number = 0
    end
    
    --local armature
    if not self.handCardControl[wViewChairID]:getChildByName("AnimationOxType") then
        local armature = oxui.playAnimation(self.handCardControl[wViewChairID],200,"AnimationOxType",number,false)
        armature:setName("AnimationOxType")
        armature:setScale(0.6)
        if  number and number > 0 then
            armature:setColor(cc.c3b(223,214,1,255))
        end

        local posx
        if wViewChairID == OxtbNewDefine.MYSELF_VIEW_ID then
            posx = self.handCardPos[wViewChairID].x - 180
        else
            posx = self.handCardPos[wViewChairID].x -60
        end

        local posy = self.handCardPos[wViewChairID].y - 20
        armature:setPosition(posx,posy)
    end


    if number then
        oxui.playSound("ox" .. number,false,OxtbNewDefine.m4a)
    end

    if number == 0 and wViewChairID == OxtbNewDefine.MYSELF_VIEW_ID then
        self.handCardControl[OxtbNewDefine.MYSELF_VIEW_ID]:setUnSelected()
    end


end
--场景进入
function OxtbNew:onEnter()
    SoundManager:playMusicBackground(oxui.ogg .. "ox_backbround.m4a", true)
    
    local game = (0 ~= bit._and(self.ClientKernel.serverAttribute.dwServerRule, SR_FORFEND_GAME_CHAT))
    local room = (0 ~= bit._and(self.ClientKernel.serverAttribute.dwServerRule, SR_FORFEND_ROOM_CHAT))
    if game or room then
        self.btnChat:hide()
    else
        self.btnChat:show()
    end
end
--场景销毁
function OxtbNew:onExit()
    print("退出了11")
    SoundManager:stopMusicBackground()
    self.ClientKernel:removeListenersByTable(self.GameeventHandles) 
end
function OxtbNew:onCleanup()
    print("场景销毁11")    
     oxui.removeArmatureFileInfo("AnimationBeginGame")
    oxui.removeArmatureFileInfo("AnimationGameEnd")
    oxui.removeArmatureFileInfo("AnimationOxType")
    ccs.ArmatureDataManager:destroyInstance() 
    display.removeSpriteFramesWithFile("oxtbnew/UIGameIng.plist","oxtbnew/UIGameIng.png")
    display.removeSpriteFramesWithFile("oxtbnew/talkWidgetPlist.plist","oxtbnew/talkWidgetPlist.png")
    display.removeSpriteFramesWithFile("oxtbnew/settingWidgetPlist.plist","oxtbnew/settingWidgetPlist.png")
    display.removeSpriteFrameByImageName("oxtbnew/u_game_table.jpg")
    display.removeSpriteFrameByImageName("oxtbnew/bg_tbnew_logo.png") 
    self.m_GameUser:OnFreeInterface()
    self.m_GameKernel:OnFreeInterface()
    self.ClientKernel:cleanup()
end
--事件管理
function OxtbNew:RegistEventManager()

    --游戏类操作消息
    local eventListeners = eventListeners or {}
    eventListeners[OxtbNewDefine.GAME_SCENCE] = handler(self, self.OnGameScenceMsg)-- 场景的消息
    eventListeners[OxtbNewDefine.GAME_START] = handler(self, self.OnSubGameStart)  -- 游戏开始
    eventListeners[OxtbNewDefine.GAME_ADD_SCORE] = handler(self, self.OnSubAddScore)-- 加注结果
    eventListeners[OxtbNewDefine.GAME_PLAYER_EXIT] = handler(self, self.OnSubPlayerExit)-- 玩家退出
    eventListeners[OxtbNewDefine.GAME_SEND_CARD] = handler(self, self.OnSubSendCard) -- 发牌消息
    eventListeners[OxtbNewDefine.GAME_CALL_BANKER] = handler(self, self.OnSubCallBanker)--用户叫庄
    eventListeners[OxtbNewDefine.GAME_BASE] = handler(self, self.OnSubGameBase)--发送基数
    eventListeners[OxtbNewDefine.GAME_OPEN] = handler(self, self.OnSubOpenCard)--开牌
    eventListeners[OxtbNewDefine.GAME_OPEN_CARD] = handler(self, self.OnSubEndOpen)
    eventListeners[OxtbNewDefine.GAME_PLAYER_OPEN] = handler(self, self.OnSubPlayerOpen)

    --eventListeners["GF_USER_CHAT"] = handler(self, self.ChatCallBack)
    eventListeners[OxtbNewDefine.GAME_OVER] = handler(self, self.OnSubGameOver) --结束
    self.GameeventHandles = self.ClientKernel:addEventListenersByTable( eventListeners )
end

--定义按钮缩放动画函数
function OxtbNew:playScaleAnimation(less, pSender)
    local  scale = less and 0.9 or 1
    pSender:runAction(cc.ScaleTo:create(0.2,scale))
end

function OxtbNew:updateState()
    self.timerCount = self.timerCount - 1
    self.clock:show()
    if  self.timerCount <= 0 then
        if self.gameState == OxtbNewDefine.GS_TK_FREE and self:getMyStatus() ~= US_READY then
            self.m_GameUser:LeaveType()
        end
        
        if self.gameState == OxtbNewDefine.SUB_S_OPEN_CARD then
            self:sendOpenMsg()
--            self.clock:hide()
--            self.openView:hide()
        end
        self:stopAllTimer()
        return
    end
    
    if self.isTrust then
        self:sendOpenMsg()
        self.clock:hide()
    end

    if self.gameState == OxtbNewDefine.GS_TK_FREE then
        self.lab:setString("等待玩家准备:" ..  self.timerCount)
    elseif self.gameState == OxtbNewDefine.SUB_S_OPEN_CARD then
        self.lab:setString("等待他人开牌:" ..  self.timerCount)
    elseif self.gameState == OxtbNewDefine.TIME_USER_OPEN_ING then
        self.lab:setString("开牌:" ..  self.timerCount)   
    end
end

function OxtbNew:fntCardData(para)
    local data = para
    dump(data)
    self.cbHandCardData = {}
    local ix = 1
    local  iy = 1
    for key, var in ipairs(data) do
        if not self.cbHandCardData[ix] then
            self.cbHandCardData[ix] = {}
        end

        self.cbHandCardData[ix][iy] = var

        if key % OxtbNewDefine.MAXCOUNT == 0 then
            ix = ix + 1
            iy = 1
        else
            iy = iy + 1
        end
    end
    dump(self.cbHandCardData)
end

function OxtbNew:dealCardRes(data)
    local index = 1
    self:fntCardData(data)
    self:StartDisPachCard()
end

function OxtbNew:dispatchUserCard(wChairID,cbCardData)
    local wViewChairID=self.wViewChairID[wChairID]
    local poker
    if wChairID == self:GetMeChairID() then
        poker = self.handCardControl[wViewChairID]:AddOneCard(cbCardData,true)
        self.handCardControl[wViewChairID]:SetCardTouchEnabled(true)
    else
        poker = self.handCardControl[wViewChairID]:AddOneCard(cbCardData,false)
    end
    self.pokerCount = self.pokerCount + 1
    return poker
end

function OxtbNew:moveDisPachCard() 
    local winUser = self.wWinUser or 0
    local index = 0
    for j=winUser ,winUser + OxtbNewDefine.GAME_PLAYER -1 do
        local w= j%OxtbNewDefine.GAME_PLAYER
        if self.cbPlayStatus[w] == OxtbNewDefine.USEX_PLAYING then
            local wViewChairID = self.wViewChairID[w]
            for i=1,OxtbNewDefine.MAXCOUNT  do
                local poker
                if w == self:GetMeChairID() then
                    if self.cbHandCardData[w+1][i] ~= 0 then
                        poker = self:dispatchUserCard(w,self.cbHandCardData[w+1][i])
                    end
                else
                    poker = self:dispatchUserCard(w,1)
                end
                local DelyTime=0.05*index
                local posStart = self.HeapPos
                local posEnd = self.handCardPos[wViewChairID]
                posEnd.x= posEnd.x + self.handCardDistance[wViewChairID]
                --决定牌大小
                local Scale=self.handCardScal[wViewChairID]
                local args=
                    {
                        startPos=posStart , --起始位置
                        endPos =posEnd,     --结束位置
                        delay=DelyTime,
                        scal=Scale,
                        moveEndHandler= handler(self,self.DisPatchOneCardEnd),--结束回调处理
                    }
                poker:doCardAnimation(args)
                --end,DelyTime,1)
                index = index + 1
            end
        end
    end
end


--发牌完成
function OxtbNew:OnSendCardFinish()
    local wMeChairID=self:GetMeChairID()
    if self:IsNotLookonMode()then
        self.openView:show()
        self.handCardControl[OxtbNewDefine.MYSELF_VIEW_ID]:SetShow(true)
    end
    if not self.t_Open then
        self:stopAllTimer()
        self.gameState = OxtbNewDefine.SUB_S_OPEN_CARD
        self.timerCount = OxtbNewDefine.TIME_USER_OPEN_CARD
        self.t_Open = oxui.schedule(function () self:updateState()end ,
            OxtbNewDefine.TIME_INTERVAL,OxtbNewDefine.TIME_USER_OPEN_CARD)
    end
end

function OxtbNew:IsNotLookonMode()
    local state
    if self:getMyStatus() == US_PLAYING then
        state = true
    else
        state = false
    end
    return state
end

function OxtbNew:getMyStatus()
    return self.m_GameUser.myHero.cbUserStatus
end

function OxtbNew:GetMeChairID()
    return self.m_GameUser.myHero.wChairID
end

function OxtbNew:IsCurrentUser(wCurrentUser)
    if self:IsNotLookonMode() and  wCurrentUser == self:GetMeChairID() then
        return true
    end
    return false
end

function OxtbNew:send(type,data,name)
    self.ClientKernel:requestCommand(MDM_GF_GAME,type,data ,name)
end

function OxtbNew:setUserPlayingStatus(wChairID,statu)
    print("wChairID" .. wChairID)
    if wChairID <= OxtbNewDefine.GAME_PLAYER then
        self.cbPlayStatus[wChairID]=statu
    else
        print("设置状态出错了 。。 " .. wChairID)
    end

    --dump(self.cbPlayStatus)
end


function OxtbNew:onOxEnable(isShoot,wchairid,outCardData)
    local cbCardData = self.cbHandCardData[wchairid]
    local shoot= isShoot
    local myControl = self.handCardControl[self.wViewChairID[wchairid-1]]
    
    if outCardData then
        myControl:SetCardData(outCardData)
        myControl:SetShow(true) 
    end
    
    if isShoot then
        myControl:SetShootOX()
    end 
end

return OxtbNew