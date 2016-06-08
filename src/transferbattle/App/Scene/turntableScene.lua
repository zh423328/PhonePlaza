-- ninePiece 
local CURRENT_MODULE_NAME = ...

require("socket")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

local turntableScene  = class("turntableScene", function()
    return display.newScene("turntableScene")
end)


--聊天控件
local talkWidget = require("common.Widget.TalkWidget")
local bankerItemView = import("..View.TransferBattleBankerItemView")

turntableScene.bg = "ys9zhang/u_game_table.jpg"
turntableScene.shineTag = 100

local ClientKernel = require("common.ClientKernel")

local MainUITag = 
{
    BgTag = 4,
    BtnSpinTag = 35,
    ImageChipsBgTag = 51,
    ItemTag2 = {tag = 6,isBigger = 0,name = "Dragon"},
    ItemTag3 = {tag = 7,isBigger = 0,name = "Tiger"},
    ItemTag4 = {tag = 8,isBigger = 0,name = "Suzaku"},
    ItemTag5 = {tag = 9,isBigger = 1,name = "Dragon"},
    ItemTag6 = {tag = 10,isBigger = 0,name = "Tiger"},
    ItemTag7 = {tag = 11,isBigger = 0,name = "Suzaku"},
    ItemTag8 = {tag = 12,isBigger = 0,name = "Basaltic"},
    ItemTag9 = {tag = 13,isBigger = 1,name = "Tiger"},
    ItemTag10 = {tag = 14,isBigger = 0,name = "Suzaku"},
    ItemTag11 = {tag = 15,isBigger = 0,name = "Basaltic"},
    ItemTag12 = {tag = 16,isBigger = 0,name = "Dragon"},
    ItemTag13 = {tag = 17,isBigger = 1,name = "Suzaku"},
    ItemTag14 = {tag = 18,isBigger = 0,name = "Basaltic"},
    ItemTag15 = {tag = 19,isBigger = 0,name = "Tiger"},
    ItemTag16 = {tag = 20,isBigger = 0,name = "Dragon"},
    ItemTag1 =  {tag = 21,isBigger = 1,name = "Basaltic"},
    PanelAreaTag = 89,
    LeftPanelTag = 38,
    BtnExitTag   = 39,
    BtnHistoryTag = 40,
    BtnPlayerListTag = 41,
    BtnApplyBankerTag  =45,
    BtnQiangBankerTag  = 69,
    BtnBankTag         = 71,
    ListViewBankerTag  =132,
    LabelTimeTag       = 330,

    imageBankerTag     = 44,
    TextBankerNickTag  = 46, --庄家昵称
    TextBankerScoreTag = 48, --庄家分数
    TextBankerWinTag   = 50,

    imagePlayerTag   = 63,
    TextPlayerNickTag =64, --玩家昵称
    TextPlayerScoreTag = 66,--玩家分数
    TextPlayerWinTag   = 68,

    imageLeftDownbgTag = 42,
    imageGameStateTag  = 43,
}

--神兽图片TAG
local UIShengShouTag = 
{
    ItemTag1 = {tag = 90,betType = 1},
    ItemTag2 = {tag = 94,betType = 2},
    ItemTag3 = {tag = 100,betType = 3},
    ItemTag4 = {tag = 97,betType = 4},
    ItemTag5 = {tag = 92,betType = 5},
    ItemTag6 = {tag = 96,betType = 6},
    ItemTag7 = {tag = 99,betType = 7},
    ItemTag8 = {tag = 98,betType = 8},
}

--这里面是直正的下注类型
local BetpolygonType = 
{
    BetBigBasaltic = 1,--玄武
    BetBigDragon = 2,--青龙
    BetBigSuzaku = 3,--朱雀
    BetBigTiger = 4,--白虎
    
    BetSmallBasaltic = 5,--小乌龟  
    BetSmallDragon = 6,--小青龙
    BetSmallSuzaku = 7,--小凤凰 
    BetSmallTiger = 8,--小白虎
}


local ScoreLableTag = 
{
    ItemTag1 = {tag = 101,betType = 5,score=0,isMySelf = false},
    ItemTag2 = {tag = 103,betType = 5,score=0,isMySelf = true},
    ItemTag3 = {tag = 106,betType = 6,score=0,isMySelf = false},
    ItemTag4 = {tag = 107,betType = 6,score=0,isMySelf = true},
    ItemTag5 = {tag = 110,betType = 2,score=0,isMySelf = false},
    ItemTag6 = {tag = 111,betType = 2,score=0,isMySelf = true},
    ItemTag7 = {tag = 114,betType = 1,score=0,isMySelf = false},
    ItemTag8 = {tag = 115,betType = 1,score=0,isMySelf = true},
    ItemTag9 = {tag = 118,betType = 3,score=0,isMySelf = false},
    ItemTag10 = {tag = 119,betType = 3,score=0,isMySelf = true},
    ItemTag11 = {tag = 122,betType = 4,score=0,isMySelf = false},
    ItemTag12 = {tag = 123,betType = 4,score=0,isMySelf = true},
    ItemTag13 = {tag = 126,betType = 8,score=0,isMySelf = false},
    ItemTag14 = {tag = 127,betType = 8,score=0,isMySelf = true},
    ItemTag15 = {tag = 130,betType = 7,score=0,isMySelf = false},
    ItemTag16 = {tag = 131,betType = 7,score=0,isMySelf = true},
}


local ImageAllChipsTag = 
{
    ItemTag1 = {tag = 52,power=1,index = 1},
    ItemTag2 = {tag = 54,power=10,index = 2},
    ItemTag3 = {tag = 56,power=50,index = 3},
    ItemTag4 = {tag = 58,power=100,index = 4},
    ItemTag5 = {tag = 60,power=500,index = 5},
    ItemTag6 = {tag = 62,power=1000,index = 6},
}


local allPolygon = 
{
   area1 = { betType = 1,ploygon = { 
                                        {x = display.cx + 114 ,y = display.cy + 202 },
                                        {x = display.cx + 121 ,y = display.cy +102 },
                                        {x = display.cx + 305,y = display.cy +102},
                                        {x = display.cx + 216, y =display.cy + 175},
                                   },
           },
   area2 = { betType = 2,ploygon =  {
                                        {x = display.cx + 121 ,y = display.cy - 115 },
                                        {x = display.cx + 121 ,y = display.cy - 205 },
                                        {x = display.cx + 211,y = display.cy - 183},
                                        {x = display.cx + 274, y =display.cy - 115},
                                    },
           } ,
   area3 = { betType = 3,ploygon =  {
                                        {x = display.cx - 61 ,y = display.cy - 117 },
                                        {x = display.cx + 12 ,y = display.cy - 183 },
                                        {x = display.cx + 92,y = display.cy - 205},
                                        {x = display.cx + 92, y =display.cy - 115},
                                    },
            },
   area4 = { betType = 4,ploygon = {
                                        {x = display.cx +4 ,y = display.cy + 178 },
                                        {x = display.cx - 65 ,y = display.cy+ 104 },
                                        {x = display.cx + 102,y = display.cy + 104},
                                        {x = display.cx + 102, y =display.cy + 200},
                                    },
            },
   area5 = { betType = 5,ploygon =  {
                                        {x = display.cx + 121 ,y = display.cy + 118 },
                                        {x = display.cx + 121  ,y = display.cy + 58},
                                        {x = display.cx +  175,y = display.cy - 4},
                                        {x = display.cx + 312, y =display.cy - 4},
                                        {x = display.cx + 292, y =display.cy +102},
                                    },
           },
   area6 = { betType = 6,ploygon = {
                                        {x = display.cx + 175 ,y = display.cy - 10 },
                                        {x = display.cx + 114  ,y = display.cy - 74},
                                        {x = display.cx +  121,y = display.cy - 115},
                                        {x = display.cx + 278, y =display.cy - 115},
                                        {x = display.cx + 312, y =display.cy -10 },
                                    },
            },
   area7 = { betType = 7,ploygon =  {
                                        {x = display.cx - 93 ,y = display.cy - 10 },
                                        {x = display.cx - 83  ,y = display.cy - 78},
                                        {x = display.cx - 57  ,y = display.cy - 114},
                                        {x = display.cx +  93,y = display.cy - 114},
                                        {x = display.cx + 102, y =display.cy - 74},
                                        {x = display.cx + 40, y =display.cy -10 },
                                    },
            },
   area8 =  { betType = 8,ploygon = {
                                        {x = display.cx - 69 ,y = display.cy + 114 },
                                        {x = display.cx -87  ,y = display.cy + 8},
                                        {x = display.cx +  42,y = display.cy + 8},
                                        {x = display.cx + 94, y =display.cy + 67},
                                        {x = display.cx + 94, y =display.cy + 114},
                                    },
            },
}

--小乌龟区域
local minBasalticPolygon = {
    {{x = display.cx +4 ,y = display.cy + 178 },{x = display.cx - 65 ,y = display.cy  + 104 },{x = display.cx + 102,y = display.cy + 104},{x = display.cx + 102, y =display.cy + 200}},
}
--小凤凰区域
local minSuzakuPolygon = {
    {{x = display.cx - 61 ,y = display.cy - 117 },{x = display.cx + 12 ,y = display.cy - 183 },{x = display.cx + 92,y = display.cy - 205},{x = display.cx + 92, y =display.cy - 115}},
}
--小老虎区域 
local minTigerPolygon = {
    {{x = display.cx + 121 ,y = display.cy - 115 },{x = display.cx + 121 ,y = display.cy - 205 },{x = display.cx + 211,y = display.cy - 183},{x = display.cx + 274, y =display.cy - 115}},
}
--小白龙区域 
local minDragonPolygon = {
    {{x = display.cx + 114 ,y = display.cy + 202 },{x = display.cx + 121 ,y = display.cy +102 },{x = display.cx + 305,y = display.cy +102},{x = display.cx + 216, y =display.cy + 175}},
}
--玄武区域
local maxBasalticPolygon = {
    {{x = display.cx - 69 ,y = display.cy + 114 },{x = display.cx -87  ,y = display.cy + 8},{x = display.cx +  42,y = display.cy + 8},{x = display.cx + 94, y =display.cy + 67},{x = display.cx + 94, y =display.cy + 114}},
}
--朱雀区域
local maxSuzakuPolygon = {
    {{x = display.cx - 93 ,y = display.cy + 3 },{x = display.cx - 66  ,y = display.cy + 105},{x = display.cx +  93,y = display.cy - 111},{x = display.cx + 93, y =display.cy - 70},{x = display.cx + 40, y =display.cy -9 }},
}
--白虎区域
local maxTigerPolygon = {
    {{x = display.cx + 175 ,y = display.cy - 10 },{x = display.cx + 114  ,y = display.cy - 74},{x = display.cx +  121,y = display.cy - 115},{x = display.cx + 278, y =display.cy - 115},{x = display.cx + 312, y =display.cy -10 }},
}
--青龙区域
local maxDragonPolygon = {
    {{x = display.cx + 121 ,y = display.cy + 118 },{x = display.cx + 121  ,y = display.cy + 58},{x = display.cx +  175,y = display.cy - 4},{x = display.cx + 312, y =display.cy - 4},{x = display.cx + 292, y =display.cy +102 }},
}

function turntableScene:ctor(args)
	print("turntableScene:ctor")
	self:setNodeEventEnabled(true)
	if args.gameClient then
		self.gameClient = args.gameClient
		self.serviceClient = ClientKernel.new(self.gameClient,AppBaseInstanse.TurntableApp.notificationCenter)
		
		self.workflow = import("..Controller.TurntableWorkflow", CURRENT_MODULE_NAME).new(self)
		
		self.ResponseHandler = import("..Command.TurntableResponseHandler", CURRENT_MODULE_NAME).new(self.gameClient)
	end

    math.randomseed(os.time())

	self:loadUI()

    cc.Director:getInstance():getTextureCache():addImage("transferbattle/Big_Basaltic_Animal.png")
    cc.Director:getInstance():getTextureCache():addImage("transferbattle/Big_Dragon_Animal.png")
    cc.Director:getInstance():getTextureCache():addImage("transferbattle/Big_Suzaku_Animal.png")
    cc.Director:getInstance():getTextureCache():addImage("transferbattle/Big_Tiger_Animal.png")
    cc.Director:getInstance():getTextureCache():addImage("transferbattle/Small_Basaltic_Animal.png")
    cc.Director:getInstance():getTextureCache():addImage("transferbattle/Small_Dragon_Animal.png")
    cc.Director:getInstance():getTextureCache():addImage("transferbattle/Small_Suzaku_Animal.png")
    cc.Director:getInstance():getTextureCache():addImage("transferbattle/Small_Tiger_Animal.png")

    --愈加载音效
    self:loadSoundRes()
    self.timeLeft = 0
    self.betPower = 0
end

--加载声音资源
function turntableScene:loadSoundRes()
    --[[audio.preloadSound("transferbattle/audio/roll.mp3")
    audio.preloadSound("transferbattle/audio/gamestart.mp3")
    audio.preloadSound("transferbattle/audio/gameend.mp3")
    audio.preloadSound("transferbattle/audio/addgold.mp3")
    audio.preloadSound("transferbattle/audio/endlose.mp3")
    audio.preloadSound("transferbattle/audio/endwin.mp3")
    audio.preloadSound("transferbattle/audio/pleasebet.mp3")]]
end

function turntableScene:onCleanup()
    print("turntableScene:onCleanup")
    -- 这个schedule必须释放掉
    if self.schedulerId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerId)
        self.schedulerId = nil
    end

    self.workflow:cleanup()
    self.workflow = nil 

    cc.Director:getInstance():getTextureCache():removeTextureForKey("transferbattle/bg.jpg") 
    --释放大图
    cc.Director:getInstance():getTextureCache():removeTextureForKey("transferbattle/Big_Basaltic_Animal.png")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("transferbattle/Big_Dragon_Animal.png")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("transferbattle/Big_Suzaku_Animal.png")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("transferbattle/Big_Tiger_Animal.png")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("transferbattle/Small_Basaltic_Animal.png")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("transferbattle/Small_Dragon_Animal.png")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("transferbattle/Small_Suzaku_Animal.png")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("transferbattle/Small_Tiger_Animal.png")

    --移除结束动画
    cc.Director:getInstance():getTextureCache():removeTextureForKey("transferbattle/End_Big_Basaltic_A.png")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("transferbattle/End_Big_Dragon_A.png")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("transferbattle/End_Big_Suzaku_A.png")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("transferbattle/End_Big_Tiger_A.png")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("transferbattle/End_Small_Basaltic_A.png")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("transferbattle/End_Small_Dragon_A.png")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("transferbattle/End_Small_Suzaku_A.png")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("transferbattle/End_Small_Tiger_A.png")

    -- 释放音效资源
    self:unloadSoundRes()
    self.serviceClient:cleanup() 
end

function turntableScene:unloadSoundRes()
    --[[ccexp.AudioEngine:unloadEffect("transferbattle/audio/roll.mp3")
    ccexp.AudioEngine:unloadEffect("transferbattle/audio/gamestart.mp3")
    ccexp.AudioEngine:unloadEffect("transferbattle/audio/gameend.mp3")
    ccexp.AudioEngine:unloadEffect("transferbattle/audio/addgold.mp3")
    ccexp.AudioEngine:unloadEffect("transferbattle/audio/endlose.mp3")
    ccexp.AudioEngine:unloadEffect("transferbattle/audio/endwin.mp3")
    ccexp.AudioEngine:unloadEffect("transferbattle/audio/pleasebet.mp3")]]
end

function turntableScene:getCurClientKernel()
    return self.serviceClient
end

function turntableScene:onEnter()
    self.timeInterVal = 0
	self.ResponseHandler:registerPlayHandlers()
    if not self.schedulerId then
        self.schedulerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self.refreshCountDownTime), 1 , false)
    end
    self:loadSoundRes()
    --播放背景音乐
    --[[if SessionManager:sharedManager():getEffectOn() then
        ccexp.AudioEngine:play2d("transferbattle/audio/bground.mp3", true)
    end]]
    SoundManager:playMusicBackground("transferbattle/audio/bground.mp3", true)
end

function turntableScene:onExit()
	self.ResponseHandler:unregisterPlayHandlers()
    SoundManager:stopMusicBackground()
end

function turntableScene:refreshCountDownTime()
    self.timeInterVal = self.timeInterVal + 1 
    --一分钟对时
    if self.timeInterVal == 60 then
        self.sTimeNow = {
            wHour = tonumber(os.date("%H")),
            wMin = tonumber(os.date("%M")),
        }
        self.timeInterVal = 0
    end
    if self.sTimeNow.wMin <= 0 then
        self.lableTime:setString(string.format("%02d:%02d",self.sTimeNow.wHour-1,59))
    else
        self.lableTime:setString(string.format("%02d:%02d",self.sTimeNow.wHour,self.sTimeNow.wMin))
    end

    if self.timeLeft > 0 then
        if not self.labelTimeLeft:isVisible() then
           self.labelTimeLeft:setVisible(true)
        end
        self.labelTimeLeft:setString(tostring(self.timeLeft))
        self.timeLeft = self.timeLeft  - 1

        if self.isBettingFlag and self.gameState ~= GAME_STATE_BETWILLOVER and self.timeLeft <=5 then
            self:setGameState(GAME_STATE_BETWILLOVER)
            self.gameState = GAME_STATE_BETWILLOVER
        end
    else
        self.labelTimeLeft:setVisible(false)
        self.gameState = -1
    end
end

function turntableScene:createSpriteFrame(path,duration,col,row,frameW,frameH)
    local frames = {}
    local isReload = false
    local pTexture =  cc.Director:getInstance():getTextureCache():getTextureForKey(path)
    if pTexture then
        isReload = true
    end
    for i = 1, col do
        for j = 1, row do 
            local  frame = nil
            if isReload then
                frame= cc.SpriteFrame:createWithTexture(pTexture,cc.rect((j-1)*frameW,0,frameW,frameW))
            else
                frame = cc.SpriteFrame:create(path,cc.rect((j-1)*frameW,0,frameW,frameH))
            end
            if frame then
                table.insert(frames,frame)
            end
        end
    end
  
    local anima = cc.Animation:createWithSpriteFrames(frames,duration)
    return cc.Animate:create(anima)
end


function turntableScene:loadUI()
    local curBg = ccui.ImageView:create():addTo(self)
    curBg:loadTexture("transferbattle/bg.jpg",0)
    curBg:setPosition(cc.p(display.cx,display.cy))
    curBg:scale(display.height/curBg:getContentSize().height)
	--加载JSON
    self.mainWidget = GameUtil:widgetFromCocostudioFile("transferbattle/gameScene"):addTo(self)
    self.mainWidget:setTouchEnabled(true)
    self.mainWidget:addTouchEventListener(handler(self,self.panelOnTouched))
    self.bg = self.mainWidget:getChildByTag(MainUITag.BgTag)

    self.panelShengshou = self.mainWidget:getChildByTag(MainUITag.PanelAreaTag)
    --local btnSpin  = self.mainWidget:getChildByTag(MainUITag.BtnSpinTag)
    --btnSpin:addTouchEventListener(handler(self, self.onClickSpin))

    for k,v in pairs(MainUITag) do
        if type(v) == "table" then
            local  itemBg = self.bg:getChildByTag(v.tag)
            local shine_image = ccui.ImageView:create()
            local path = ""
            if v.isBigger == 1 then
                path = string.format("transferbattle/Light_Big_%s.png",v.name)
            else
                path = string.format("transferbattle/Light_Small_%s.png",v.name)
            end
            shine_image:setVisible(false)
            shine_image:loadTexture(path,0)
            shine_image:setPosition(cc.p(shine_image:getContentSize().width/2,shine_image:getContentSize().height/2))
            itemBg:addChild(shine_image, itemBg:getLocalZOrder()+1,turntableScene.shineTag)
        end
    end

    self:resetScoreLable()
    --给下注按钮绑定事件
    self.chipsBg = self.mainWidget:getChildByTag(MainUITag.ImageChipsBgTag)
    for i ,j in pairs(ImageAllChipsTag) do
        local imageChips = self.chipsBg:getChildByTag(j.tag)
        imageChips:addTouchEventListener(handler(self, self.onClickBet))
        if not self.shine_bet and j.tag == 52 then
            self.shine_bet = ccui.ImageView:create():addTo(self.chipsBg)
            self.shine_bet:setEnabled(false)
            self.shine_bet:loadTexture("transferbattle/bet_light.png",0)
            self.shine_bet:setPosition(cc.p(imageChips:getPositionX(),imageChips:getPositionY()))
            self.shine_bet:setVisible(false)
        end
    end
    --筹码ICON
    self.iconBet = ccui.ImageView:create():addTo(self)
    self.iconBet:loadTexture("transferbattle/image_chips1.png",0)
    self.iconBet:setScale(0.5)
    self.iconBet:setPosition(cc.p(-100,-100))
    --倒计时label
    self.labelTimeLeft = cc.LabelAtlas:_create("0","ys9zhang/u_game_num_card.png",17,24,string.byte("0")):addTo(self.bg)
    self.labelTimeLeft:setAnchorPoint(cc.p(0.5,0.5))
    self.labelTimeLeft:setPosition(cc.p(self.bg:getContentSize().width/2 - 2  ,self.bg:getContentSize().height/2 - 4))
    self.labelTimeLeft:setVisible(false)

    --初始庄家列表区域
    self:initBankerPanle()

    local bankerBg = self.mainWidget:getChildByTag(MainUITag.imageBankerTag)
    self.textBankerNick = bankerBg:getChildByTag(MainUITag.TextBankerNickTag)
    self.textBankerNick:setString("")
    self.textBankerScore = bankerBg:getChildByTag(MainUITag.TextBankerScoreTag)
    self.textBankerScore:setString("0")
    self.textBankerWin = bankerBg:getChildByTag(MainUITag.TextBankerWinTag)
    self.textBankerWin:setString("0")

    local playerBg = self.mainWidget:getChildByTag(MainUITag.imagePlayerTag)
    self.textPlayerNick = playerBg:getChildByTag(MainUITag.TextPlayerNickTag)
    self.textPlayerNick:setString("")
    self.textPlayerScore = playerBg:getChildByTag(MainUITag.TextPlayerScoreTag)
    self.textPlayerScore:setString("0")
    self.textPlayerWin = playerBg:getChildByTag(MainUITag.TextPlayerWinTag)
    self.textPlayerWin:setString("0")

    local leftDownBg = self.mainWidget:getChildByTag(MainUITag.imageLeftDownbgTag)
    self.imageGameState = leftDownBg:getChildByTag(MainUITag.imageGameStateTag)
end

function turntableScene:refreshPlayerInfo()
    local  userInfo = self.serviceClient:SearchUserByChairID(self.workflow:getMyChairID())
    if userInfo then
        self.textPlayerNick:setString(userInfo.szNickName)
        self.initPlayerScore = userInfo.lScore
        self.textPlayerScore:setString(string.formatnumberthousands(userInfo.lScore))
        self.textPlayerWin:setString("0")

        if not self.workflow:isCanApplyBanker(userInfo.lScore) then
            self.btnApplyBanker:setEnabled(false)
            self.btnApplyBanker:loadTextureNormal("transferbattle/btn_applyBanker_an.png",0)
        else
            self.btnApplyBanker:setEnabled(true)
            self.btnApplyBanker:loadTextureNormal("transferbattle/btn_beDealer1.png",0)
            self.btnApplyBanker:loadTexturePressed("transferbattle/btn_beDealer.png",0)
        end

        --抢庄按钮变灰
        self.btnQiangBanker:setEnabled(false)
        self.btnQiangBanker:loadTextureNormal("transferbattle/btn_qiangbank_an.png",0)
    end
end

function turntableScene:setGameState(state)
    if state == GAME_STATE_FREE then
        self.imageGameState:setVisible(false)
    else
        self.imageGameState:stopAllActions()
        self.imageGameState:setVisible(true)
        self.imageGameState:loadTexture(string.format("transferbattle/image_status%d.png",state),0)
        
        local delay = cc.DelayTime:create(10)
        local callBack = cc.CallFunc:create(handler(self, self.onDispear))
        self.imageGameState:runAction(cc.Sequence:create(delay, callBack))
    end
end

function turntableScene:onDispear(pSender)
    self.imageGameState:setVisible(false)
end

function turntableScene:initBankerPanle()
    local leftbg = self.mainWidget:getChildByTag(MainUITag.LeftPanelTag)
    local  btnExit =  leftbg:getChildByTag(MainUITag.BtnExitTag)
    btnExit:addTouchEventListener(handler(self, self.onClickExit))

    local  btnHistory =  self.mainWidget:getChildByTag(MainUITag.BtnHistoryTag)
    btnHistory:addTouchEventListener(handler(self, self.onClickHistory))

    local  btnPlayerlist =  self.mainWidget:getChildByTag(MainUITag.BtnPlayerListTag)
    btnPlayerlist:addTouchEventListener(handler(self, self.onClickPlayerlist))

    self.btnQiangBanker = self.mainWidget:getChildByTag(MainUITag.BtnQiangBankerTag)
    self.btnQiangBanker:addTouchEventListener(handler(self, self.onClickQiangBanker))
    self.btnQiangBanker:setEnabled(false)
    self.btnQiangBanker:loadTextureNormal("transferbattle/btn_qiangbank_an.png",0)

    local btnBank = self.mainWidget:getChildByTag(MainUITag.BtnBankTag)
    btnBank:addTouchEventListener(handler(self, self.onClickBank))

    self.btnApplyBanker =  leftbg:getChildByTag(MainUITag.BtnApplyBankerTag)
    self.btnApplyBanker:addTouchEventListener(handler(self, self.onClickApplyBanker))

    self.bankerListView = leftbg:getChildByTag(MainUITag.ListViewBankerTag)
    self.bankerListView:removeAllItems()

    self.lableTime = leftbg:getChildByTag(MainUITag.LabelTimeTag)

    --当前时间
    self.sTimeNow = {
            wHour = tonumber(os.date("%H")),
            wMin = tonumber(os.date("%M")),
    }
    self.lableTime:setString(string.format("%02d:%02d",self.sTimeNow.wHour,self.sTimeNow.wMin))
end

function turntableScene:onClickExit(pSender,touchType)
    if touchType == TOUCH_EVENT_ENDED  then
        if not self.workflow:isPlaying() then
            if self.serviceClient.exitGameApp then
                self.serviceClient:exitGameApp()
            else
                self.workflow:sendStandUpRequest()
                cc.Director:getInstance():popToRootScene() 
            end
        else
            local dataMsgBox = {
                nodeParent=self,
                msgboxType=MSGBOX_TYPE_OKCANCEL,
                msgInfo="游戏进行中，如您已押注，强退将被扣分，确认要强退吗？",
                callBack=function(ret)
                    if ret == MSGBOX_RETURN_OK then
                        if self.serviceClient.exitGameApp then
                            self.serviceClient:exitGameApp()
                        else
                            self.workflow:sendStandUpRequest()
                            cc.Director:getInstance():popToRootScene() 
                        end
                    end
                end
            }
            require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        end
    end
end

--点击历史记录
function turntableScene:onClickHistory(pSender,touchType)
    if touchType == TOUCH_EVENT_ENDED  then
        local recordView = import("..View.TransferBattleRecordView", CURRENT_MODULE_NAME).new(self.workflow)
        recordView:setPosition(cc.p(display.cx,display.cy))
        self:addChild(recordView)
    end
end

--点击玩家列表
function turntableScene:onClickPlayerlist(pSender,touchType)
    if touchType == TOUCH_EVENT_ENDED  then
        local playerListView = import("..View.TransferBattlePlayerListView", CURRENT_MODULE_NAME).new(self.workflow)
        playerListView:setPosition(cc.p(display.cx,display.cy))
        self:addChild(playerListView)
    end
end

function turntableScene:onClickApplyBanker(pSender,touchType)
    if touchType == TOUCH_EVENT_ENDED  then
        if not self.workflow:checkInBankerList() then
            self.workflow:sendApplyBankerRequest()
        else
            self.workflow:sendCancelBankerRequest()
        end
    end
end

function turntableScene:onClickQiangBanker(pSender,touchType)
    if touchType == TOUCH_EVENT_ENDED  then
        if self.workflow:getCurBankerUserId() == self.workflow:getMyChairID() then
            --to do弹出提示已经是庄家,
            local dataMsgBox = {
                nodeParent=self,
                msgboxType=MSGBOX_TYPE_OK,
                msgInfo="您已经是最高位置了，请不要抢过头哦！"
            }
            require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        else 
            self.workflow:sendQiangBankerRequest()
        end
    end
end

function turntableScene:onClickBank(pSender,touchType)
    if touchType == TOUCH_EVENT_ENDED  then
        local bankView = import("..View.TransferBattleBankView", CURRENT_MODULE_NAME).new(self.workflow)
        bankView:setPosition(cc.p(display.cx,display.cy))
        self:addChild(bankView)
    end
end


function turntableScene:onClickBet(pSender,touchType)
    if touchType == TOUCH_EVENT_ENDED  then
        self.betPower = 0
        local  curTag = pSender:getTag()
        for k ,v in pairs(ImageAllChipsTag) do
            if v.tag == curTag then
                self.shine_bet:setPosition(cc.p(pSender:getPositionX(),pSender:getPositionY()))
                self.shine_bet:setVisible(true)
                self.betPower = v.power
                self.betIndex = v.index
                break
            end
        end
        self.iconBet:loadTexture(string.format("transferbattle/image_chips%d.png",self.betIndex))
        print("betpower = "..self.betPower)
    end
end

function turntableScene:resetScoreLable()
    for k ,v in pairs(ScoreLableTag) do
        local labelChips = self.panelShengshou:getChildByTag(v.tag)
        v.score = 0
        labelChips:setString(tostring(v.score))
        labelChips:setVisible(false)
    end
end

--刷新庄家列表
function turntableScene:updatBankerList(bankerIds)
    self.bankerListView:removeAllItems()
    for i=0,#bankerIds do
        local info = {}
        local userInfo = self.serviceClient:SearchUserByChairID(bankerIds[i])
        if userInfo then
            info.id = i
            info.score = userInfo.lScore
            info.nick  = userInfo.szNickName
            info.chairId = bankerIds[i]
            local  bankItem = bankerItemView.new(info)
            self.bankerListView:pushBackCustomItem(bankItem)
        end
    end
end

--[[function turntableScene:updatBankerList(bankerIds)
    self.bankerListView:removeAllItems()
    for i=1,bankerIds:count() do
        local info = {}
        local wChairID = bankerIds:objectAtIndex(i-1)
        local userInfo = self.serviceClient:SearchUserByChairID(wChairID:getValue())
        if userInfo then
            info.id = i
            info.score = userInfo.lScore
            info.nick  = userInfo.szNickName
            info.chairId = bankerIds[i]
            local  bankItem = bankerItemView.new(info)
            self.bankerListView:pushBackCustomItem(bankItem)
        end
    end
end]]

--刷新当前庄家信息
function turntableScene:refreshBankerInfo()
    local  userInfo = self.serviceClient:SearchUserByChairID(self.workflow:getCurBankerUserId())
    if userInfo then
        self.textBankerNick:setString(userInfo.szNickName)
        self.initBankScore = userInfo.lScore
        self.textBankerScore:setString(string.formatnumberthousands(userInfo.lScore))
        self.textBankerWin:setString("0")
    end
    --如果当前庄家是自已,抢庄按钮变灰
    if self.workflow:getCurBankerUserId() == self.workflow:getMyChairID() then
        self.btnApplyBanker:setEnabled(false)
        self.btnApplyBanker:loadTextureNormal("transferbattle/btn_cancelbanker_an.png")
    end
end

function turntableScene:updateTotalChipsInfo( chipsInfo )
    --区别是不是自已下的注
    local  isMySelf = false
    if SessionManager:sharedManager():getEffectOn() then
        --ccexp.AudioEngine:play2d("transferbattle/audio/addgold.mp3", false)
        if not self.prePlaytime or socket.gettime() - self.prePlaytime >=0.1 then
            self.prePlaytime = socket.gettime()
            SoundManager:playMusicEffect("transferbattle/audio/addgold.mp3", false)
        end
    end
    if self.serviceClient.userAttribute.wChairID == chipsInfo.wChairID then
        --print("updateTotalChipsInfo isMySelf")
        isMySelf = true
    end
    for k ,v in pairs(ScoreLableTag) do
        if type(v) == "table" and v.betType == chipsInfo.cbJettonArea and v.isMySelf == isMySelf then
            local labelChips = self.panelShengshou:getChildByTag(v.tag)
            v.score = v.score + chipsInfo.lJettonScore
            labelChips:setString(tostring(v.score))
            labelChips:setVisible(true)
        end
    end
end

function turntableScene:panelOnTouched( sender, touchType)
    --不在下注时间内 不作处理
    if not self.isBettingFlag then
        return
    end
    if touchType == TOUCH_EVENT_BEGAN then
        self.betType = -1
        local winPos = sender:getTouchBeganPosition()
        print(string.format("touchtype = %d ,x = %d ,y = %d",touchType,winPos.x,winPos.y))
        for k ,v in pairs(allPolygon) do
            self.betType = -1
            if type(v) =="table" and v.betType and v.ploygon then
                local inside = GameUtil:InsidePolygon(v.ploygon,winPos)
                if inside == true then
                    self.betType = v.betType
                    break
                end
            end
        end
        if self.betType ~= -1 then
            if self.betPower <= 0 and not self.hasShowTipFlag then
                self.hasShowTipFlag = true
                local dataMsgBox = {
                    nodeParent=self,
                    msgboxType=MSGBOX_TYPE_OK,
                    msgInfo="请先选择下注金额！",
                    callBack=function(ret)
                        if ret == MSGBOX_RETURN_OK then
                            self.hasShowTipFlag = false
                        end    
                    end
                }
                require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
                return
            end  
            self.selectImage = self:getSelectItemByType(self.betType)
            self.selectImage:loadTexture(string.format("transferbattle/Bet_light_%d.png",self.betType),0)
            --下注的筹码
            self.iconBet:setVisible(true)
            self.iconBet:setPosition(cc.p(winPos.x,winPos.y))
            
        end
    elseif touchType == TOUCH_EVENT_ENDED then
        self.betType = -1
        local winPos = sender:getTouchEndPosition()
        --print(string.format("touchtype = %d ,x = %d ,y = %d",touchType,winPos.x,winPos.y))
        for k ,v in pairs(allPolygon) do
            self.betType = -1
            if type(v) =="table" and v.betType and v.ploygon then
                local inside = GameUtil:InsidePolygon(v.ploygon,winPos)
                if inside == true then
                    self.betType = v.betType
                    break
                end
            end
        end
        if self.betType ~=-1 then
            print(string.format("betType = %d",self.betType))
            self.selectImage = self:getSelectItemByType(self.betType)
            self.selectImage:loadTexture(string.format("transferbattle/Bet_%d.png",self.betType),0)  
            --发送下注消息
            if self.betPower > 0 then
                self.workflow:placeBet(self:getRealBetArea(),self.betPower*10000)
                if self.iconBet then
                    self.iconBet:setVisible(false)
                end
            end
        end
    elseif TOUCH_EVENT_MOVED == touchType  then
        local winPos = sender:getTouchMovePosition()
        local isInsideOne = false
        for k ,v in pairs(allPolygon) do
            if type(v) =="table" and v.betType and v.ploygon then
                local inside = GameUtil:InsidePolygon(v.ploygon,winPos)
                if inside == true then
                    if self.betPower <= 0 and not self.hasShowTipFlag then
                        self.hasShowTipFlag = true
                        local dataMsgBox = {
                            nodeParent=self,
                            msgboxType=MSGBOX_TYPE_OK,
                            msgInfo="请先选择下注金额！",
                            callBack=function(ret)
                                if ret == MSGBOX_RETURN_OK then
                                    self.hasShowTipFlag = false
                                end   
                            end
                        }
                        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
                        return
                    end  
                    isInsideOne  = true
                    if self.betType ~= -1 then
                        --之前的选中图片变灰
                        self.selectImage = self:getSelectItemByType(self.betType)
                        self.selectImage:loadTexture(string.format("transferbattle/Bet_%d.png",self.betType),0)  
                    end
                    --切换到当前选中
                    self.betType = v.betType
                    self.selectImage = self:getSelectItemByType(self.betType)
                    self.selectImage:loadTexture(string.format("transferbattle/Bet_light_%d.png",self.betType),0)
                    
                    
                    self.iconBet:setVisible(true)
                    self.iconBet:setPosition(cc.p(winPos.x,winPos.y))
                    break
                end
            end
        end
        --移动不是下注区域处理
        if not isInsideOne then
           if self.betType ~= -1 then
                --之前的选中图片变灰
                self.selectImage = self:getSelectItemByType(self.betType)
                self.selectImage:loadTexture(string.format("transferbattle/Bet_%d.png",self.betType),0) 
                self.betType = -1 
                if self.iconBet then
                    self.iconBet:setVisible(false)
                end
            end 
        end
    end
end

--根据客户端神兽图片索引转换成直接下注区域类型
function turntableScene:getRealBetArea()
    if self.betType == 1 then
        return BetpolygonType.BetSmallDragon
    elseif self.betType == 2 then
        return BetpolygonType.BetSmallTiger
    elseif self.betType == 3 then
        return BetpolygonType.BetSmallSuzaku
    elseif self.betType == 4 then
        return BetpolygonType.BetSmallBasaltic
    elseif self.betType == 5 then
        return BetpolygonType.BetBigDragon
    elseif self.betType == 6 then
        return BetpolygonType.BetBigTiger
    elseif self.betType == 7 then
        return BetpolygonType.BetBigSuzaku
    elseif self.betType == 8 then
        return BetpolygonType.BetBigBasaltic
    end
end

function turntableScene:getSelectItemByType( betType )
   for k ,v in pairs(UIShengShouTag)do
       if type(v) == "table" and v.tag and v.betType == betType then
           return self.panelShengshou:getChildByTag(v.tag)
       end
   end
end

function turntableScene:onClickSpin(pSender,touchType)
  if touchType == TOUCH_EVENT_BEGAN then
        GameUtil:playScaleAnimation(true, pSender)
    else
        GameUtil:playScaleAnimation(false, pSender)
    end

    if touchType == TOUCH_EVENT_ENDED then
        self:startSpin()
    end  
end

--收到场景消息处理
function turntableScene:receiveSceneMessagePro(statusInfo,isFreeStatus)
    --恢复下注区域
    self.timeLeft = statusInfo.cbTimeLeave
    self.initBankScore = statusInfo.lBankerScore
    self.initPlayerScore = statusInfo.lUserMaxScore
    --游戏状态下处理
    if not isFreeStatus then
        self.isBettingFlag = true
        for k ,v in pairs(ScoreLableTag) do
            for i=2,9 do
                local curBetType = i-1
                if v.betType == curBetType and v.isMySelf == false then
                    local labelChips = self.panelShengshou:getChildByTag(v.tag)
                    v.score = v.score + statusInfo.lAllJettonScore[i]
                    labelChips:setString(tostring(v.score))
                    labelChips:setVisible(true)
                elseif v.betType == curBetType and v.isMySelf == true then
                    if statusInfo.lUserJettonScore[i] > 0 then
                        local labelChips = self.panelShengshou:getChildByTag(v.tag)
                        v.score = v.score + statusInfo.lUserJettonScore[i]
                        labelChips:setString(tostring(v.score))
                        labelChips:setVisible(true)
                    end
                end
            end
        end
        if statusInfo.cbTimeLeave > 5 then
            self:setGameState(GAME_STATE_BET)
        else
            self:setGameState(GAME_STATE_BETWILLOVER)
        end
        --庄家输赢信息
        self.roundInfo = {}
        self.roundInfo.lBankerScore = statusInfo.lEndBankerScore
        self.roundInfo.lUserScore =statusInfo.lEndUserScore

        --闪烁
        if statusInfo.cbTableCard >0 then
            if statusInfo.cbTableCard == 1 then
                self.blinkIndex = 21 
            else
                self.blinkIndex = statusInfo.cbTableCard + 4
            end
            self:reInitRoundScene()
        end
    else
        self.isBettingFlag = false
        self:setGameState(GAME_STATE_FREE)
    end

    --恢复的时候自已是庄家，都不可点击
    if self.workflow:getCurBankerUserId() == self.workflow:getMyChairID() then
        self:resetOpreateBet(false)
    else
        self:resetOpreateBet(self.isBettingFlag)
    end
    
end

function turntableScene:reInitRoundScene()
    if self.timeLeft >= 6 then
        local isFromScene = true
        self:dealBlinkEffect(isFromScene)
    else
        local  itemBg = self.bg:getChildByTag(self.blinkIndex)
        
        if not self.tmp_shine_image then
            self.tmp_shine_image = ccui.ImageView:create():addTo(self.bg)
        end
        
        local attr = self:getAttributeByIndex(self.blinkIndex)
        if self:isBigger(self.blinkIndex) then
            path = string.format("transferbattle/Light_Big_%s.png",attr.name)
        else
            path = string.format("transferbattle/Light_Small_%s.png",attr.name)
        end
        self.tmp_shine_image:loadTexture(path,0)
        self.tmp_shine_image:setVisible(true)
        --self.tmp_shine_image:setPosition(cc.p(itemBg:getContentSize().width/2,itemBg:getContentSize().height/2))
        self.tmp_shine_image:setPosition(cc.p(itemBg:getPositionX(),itemBg:getPositionY()))
        self.tmp_shine_image:setLocalZOrder(itemBg:getLocalZOrder()+1)

        local blink = cc.Blink:create(3600, 4000)
        self.tmp_shine_image:runAction(blink)
    end
end

--收到开始下注的消息
function turntableScene:receiveGameStartPro(startInfo)
    --正在下注
    self.isBettingFlag = true
    self.timeLeft = startInfo.cbTimeLeave

    --置设置按钮为可操作状态
    if self.workflow:getCurBankerUserId() == self.workflow:getMyChairID() then
        self:resetOpreateBet(false)
    else
        self:resetOpreateBet(true)
    end
    self:setGameState(GAME_STATE_BET)
end

function turntableScene:resetOpreateBet(isEnable)
    local  userInfo = self.serviceClient:SearchUserByChairID(self.workflow:getMyChairID())
    for i ,j in pairs(ImageAllChipsTag) do
        local imageChips = self.chipsBg:getChildByTag(j.tag)
        if isEnable and j.power*10000 <= userInfo.lScore then
            imageChips:setEnabled(true)
            imageChips:loadTexture(string.format("transferbattle/image_chips%d.png",j.index))
        else
            imageChips:setEnabled(false)
            imageChips:loadTexture(string.format("transferbattle/image_chips%d_an.png",j.index))
        end
    end
   
end

--收到空闲消息处理
function  turntableScene:receiveGameFreePro(freeInfo)
    --todo 倒计时重新计时
    self.timeLeft = freeInfo.cbTimeLeave
    self:resetTurnTableInfo()
    self:setGameState(GAME_STATE_FREE)
end

--收到开牌消息处理
function turntableScene:receiveRoundOverMessage(roundInfo)
    self.isBettingFlag = false
    --清除 上一局下注金额
    self.betPower = 0
    if self.iconBet and self.iconBet:isVisible() then
        self.iconBet:setVisible(false)
    end

    if self.shine_bet and self.shine_bet:isVisible() then
        self.shine_bet:setVisible(false)
    end

    if self.selectImage then
        self.selectImage:loadTexture(string.format("transferbattle/Bet_%d.png",self.betType),0)
    end

    self.timeLeft = roundInfo.cbTimeLeave
    self:resetOpreateBet(false)
    --保存结算信息
    self.roundInfo = roundInfo
    local needSplashAll = false
    if roundInfo.cbTableCard  == 1 or roundInfo.cbTableCard  == 5 or roundInfo.cbTableCard  == 9 or roundInfo.cbTableCard  == 13 then
         needSplashAll = true
    end
    
    self.tableCardIndex = roundInfo.cbTableCard
    self.arriveCount = 0
    if needSplashAll then
        if SessionManager:sharedManager():getEffectOn() then
            --ccexp.AudioEngine:play2d("transferbattle/audio/bigwin.mp3", false)
            for i=1,3 do
                scheduler.performWithDelayGlobal(function ()
                    SoundManager:playMusicEffect("transferbattle/audio/bigwin.mp3", false)
                end, (i-1)*0.5+0.3)
            end
        end
        for i = 1,16 do
            local  index = i+5
            local  itemBg = self.bg:getChildByTag(index)
            local shine_image = itemBg:getChildByTag(turntableScene.shineTag)
            shine_image:setVisible(true)
            shine_image:setOpacity(255)
            if self:isBigger(index) then
                local attr = self:getAttributeByIndex(index)
                path = string.format("transferbattle/Big_%s.png",attr.name)
                itemBg:loadTexture(path,0)
                local attr = self:getAttributeByIndex(index)
                shine_image:loadTexture(string.format("transferbattle/Light_Big_%s.png",attr.name),0)     
            end
            local blink = cc.Blink:create(1.5, 3)
            local call = cc.CallFunc:create(handler(self, self.goToSpin))
            shine_image:runAction(cc.Sequence:create(blink,call))
        end
    else
        if SessionManager:sharedManager():getEffectOn() then
            --ccexp.AudioEngine:play2d("transferbattle/audio/gameend.mp3", false)
            SoundManager:playMusicEffect("transferbattle/audio/gameend.mp3", false)
        end
        self:startSpin(self.tableCardIndex)
    end
end

function turntableScene:goToSpin(pSender)
    pSender:setVisible(false)
    self.arriveCount = self.arriveCount + 1
    print("goToSpin count = "..self.arriveCount)
    if self.arriveCount == 16 then
        self:startSpin(self.tableCardIndex)
        self.arriveCount = 0
    end
end

function turntableScene:startSpin(cardIndex)
    self.spining = true
    --服务端索引是从青龙开始为1 
    self.stopIndex  = 48 + cardIndex - 1
    self.curIndex = 0
    self.delaytime = 0
    self.hasShowIndex = 0
    while self.spining do
        for i = 1,16 do
            local  index = i+5
            print("index = "..index)
            local  itemBg = self.bg:getChildByTag(index)
            local shine_image = itemBg:getChildByTag(turntableScene.shineTag)
            local path = ""
            if self:isBigger(index) then
                local attr = self:getAttributeByIndex(index)
                path = string.format("transferbattle/Big_%s1.png",attr.name)
                itemBg:loadTexture(path,0)
                shine_image:loadTexture(string.format("transferbattle/Light_Big_%s1.png",attr.name),0)     
            end
          
            local actionArray = {}
            local _dt = cc.DelayTime:create(self.delaytime)
            table.insert(actionArray,_dt)
            local _show = cc.CallFunc:create(handler(self, self.show))
            if self.curIndex > 4 and self.curIndex <=  self.stopIndex - 15  then
                self.delaytime = self.delaytime + 0.05
            elseif self.stopIndex - self.curIndex < 15 then
                self.delaytime = self.delaytime + 0.18 + 3*(10-(self.stopIndex - self.curIndex))/100
            else 
                self.delaytime = self.delaytime + 0.18 --0.14
            end
            --print(string.format("self.curIndex = %d, self.delaytime = %f",self.curIndex,self.delaytime))
            table.insert(actionArray,_show)
            local fadeOut = cc.FadeOut:create(0)
            --table.insert(actionArray,fadeOut)
            local anima = cc.CallFunc:create(handler(self, self.displayAnimation))
            local spaw  = cc.Spawn:create(fadeOut,anima)
            table.insert(actionArray,spaw)
            --table.insert(actionArray,anima)
            shine_image:runAction(cc.Sequence:create(actionArray))

            self.curIndex = self.curIndex + 1
            --print(" self.curIndex = ".. self.curIndex)
            if self.curIndex == self.stopIndex then
                print("spin over")
                self.blinkIndex = index
                self.spining = false
                break
            end 
        end
    end

end

function turntableScene:show(pSender)
    print("turntableScene:show")
    pSender:setVisible(true)
    pSender:setOpacity(255)
    self.hasShowIndex =  self.hasShowIndex + 1
    print(" self.hasShowIndex = ".. self.hasShowIndex)
    if self.hasShowIndex == self.stopIndex then
       self:dealBlinkEffect(false)
    end
end

--播放闪烁动画
function turntableScene:dealBlinkEffect(isFromScene)
    local  itemBg = self.bg:getChildByTag(self.blinkIndex)
    if not self.tmp_shine_image then
        self.tmp_shine_image = ccui.ImageView:create():addTo(self.bg)
    end

    local attr = self:getAttributeByIndex(self.blinkIndex)
    if self:isBigger(self.blinkIndex) then
        path = string.format("transferbattle/Light_Big_%s.png",attr.name)
    else
        path = string.format("transferbattle/Light_Small_%s.png",attr.name)
    end
    self.tmp_shine_image:loadTexture(path,0)
    self.tmp_shine_image:setPosition(cc.p(itemBg:getPositionX(),itemBg:getPositionY()))
    self.tmp_shine_image:setLocalZOrder(itemBg:getLocalZOrder()+1)
    self.tmp_shine_image:setVisible(true)

    local blink = cc.Blink:create(3600, 4000)
    self.tmp_shine_image:runAction(blink)

    local delayTime = 0.5
    if isFromScene then
        delayTime = 2
    end
    local _dt = cc.DelayTime:create(delayTime)
    local anima = cc.CallFunc:create(handler(self, self.displayOverAnimation))
    self:runAction(cc.Sequence:create(_dt,anima))
end

--播放结算动画
function turntableScene:displayOverAnimation()
    if not self.overEffectNode then
        self.overEffectNode = cc.Node:create():addTo(self.bg)
        self.overEffectNode:setPosition(cc.p(self.bg:getContentSize().width/2,self.bg:getContentSize().height/2))
    else
        self.overEffectNode:removeAllChildren()
        self.overEffectNode:setVisible(true)
    end
    --旋转背景
    local overBg =  ccui.ImageView:create():addTo(self.overEffectNode)
    overBg:loadTexture("transferbattle/End_Dial.png",0)
    overBg:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.3,60)))

    local Imageanima = ccui.ImageView:create():addTo(self.overEffectNode)
    local attr = self:getAttributeByIndex(self.blinkIndex)
    if self:isBigger(self.blinkIndex) then
        path = string.format("transferbattle/End_Big_%s.png",attr.name)
    else
        path = string.format("transferbattle/End_Small_%s.png",attr.name)
    end
    Imageanima:loadTexture(path,0)

    --两次渐隐
    local actions = {}
    local _fadeout1 = cc.FadeOut:create(3)
    table.insert(actions,_fadeout1)
    local call1 = cc.CallFunc:create(handler(self, self.animaShowAgain))
    table.insert(actions,call1)
    local _fadeout2 = cc.FadeOut:create(3)
    table.insert(actions,_fadeout2)
    local call2 = cc.CallFunc:create(handler(self, self.displayFinish))
    table.insert(actions,call2)

    Imageanima:runAction(cc.Sequence:create(actions))
end

function turntableScene:animaShowAgain(pSender)
    pSender:setOpacity(255)
end

--显示庄家和本家输赢文本信息
function turntableScene:displayFinish(pSender)
    print("displayFinish")
    --庄家信息
    local textDeal = ccui.Text:create():addTo(self.overEffectNode)
    textDeal:setFontSize(25)
    textDeal:setString("庄家:"..self.roundInfo.lBankerScore)
    --自已信息
    local textMySelf = ccui.Text:create():addTo(self.overEffectNode)
    textMySelf:setPosition(cc.p(textDeal:getPositionX(),textDeal:getPositionY()- textDeal:getContentSize().height))
    textMySelf:setFontSize(25) 
    textMySelf:setString("本家:"..self.roundInfo.lUserScore)

    if self.roundInfo.lUserScore ~= 0 then
        if self.roundInfo.lUserScore > 0 then
            if SessionManager:sharedManager():getEffectOn() then
                --ccexp.AudioEngine:play2d("transferbattle/audio/endwin.mp3", false)
                SoundManager:playMusicEffect("transferbattle/audio/endwin.mp3", false)
            end
        elseif self.roundInfo.lUserScore < 0 then
            if SessionManager:sharedManager():getEffectOn() then
                --ccexp.AudioEngine:play2d("transferbattle/audio/endlost.mp3", false)
                SoundManager:playMusicEffect("transferbattle/audio/endlost.mp3", false)
            end
        end
    end
    --添加最新开出来的记录项
    self.workflow:addRecordIem(self.tableCardIndex)
end

--刷新庄家列表中的项
function turntableScene:refreshBankerItemInfo(userItem)
    for k ,item in pairs(self.bankerListView:getItems()) do
        if item:getMyChairID() == userItem.wChairID then
            item:refreshData(userItem)
        end
    end

    --更新相关庄家,自已相关信息
    if userItem.wChairID == self.workflow:getCurBankerUserId() then
        self.textBankerScore:setString(string.formatnumberthousands(userItem.lScore))
        self.textBankerWin:setString(string.formatnumberthousands(userItem.lScore - self.initBankScore))
    elseif userItem.wChairID == self.workflow:getMyChairID() then
        self.textPlayerScore:setString(string.formatnumberthousands(userItem.lScore))
        self.textPlayerWin:setString(string.formatnumberthousands(userItem.lScore - self.initPlayerScore))
        
        --不在庄家列表
        if not self.workflow:checkInBankerList() then
            --是否能申请庄家
            if not self.workflow:isCanApplyBanker(userItem.lScore) then
                self.btnApplyBanker:setEnabled(false)
                self.btnApplyBanker:loadTextureNormal("transferbattle/btn_applyBanker_an.png",0)
                --to to不能抢庄
            else
                self.btnApplyBanker:setEnabled(true)
                self.btnApplyBanker:loadTextureNormal("transferbattle/btn_beDealer1.png",0)
                self.btnApplyBanker:loadTexturePressed("transferbattle/btn_beDealer.png",0)
            end 
        end
    end
end

function turntableScene:refreshApplyBankerState(state)
    --不在庄家列表里
    if not state then 
        self.btnApplyBanker:loadTextureNormal("transferbattle/btn_beDealer1.png",0)
        self.btnApplyBanker:loadTexturePressed("transferbattle/btn_beDealer.png",0)

        --抢庄按钮变灰
        self.btnQiangBanker:setEnabled(false)
        self.btnQiangBanker:loadTextureNormal("transferbattle/btn_qiangbank_an.png",0)
    else
        self.btnApplyBanker:loadTextureNormal("transferbattle/btn_downBanker1.png",0)
        self.btnApplyBanker:loadTexturePressed("transferbattle/btn_downBanker.png",0)

        --抢庄按钮变亮
        self.btnQiangBanker:setEnabled(true)
        self.btnQiangBanker:loadTextureNormal("transferbattle/btn_qiangBanker1.png",0)
        self.btnQiangBanker:loadTexturePressed("transferbattle/btn_qiangBanker.png",0)
    end
end

--重置下注信息
function turntableScene:resetTurnTableInfo()
    if self.overEffectNode then
        self.overEffectNode:setVisible(false)
    end
    self:resetScoreLable()

    if self.tmp_shine_image then
        print("reset shine_image")
        self.tmp_shine_image:stopAllActions()
        self.tmp_shine_image:setVisible(false)
    end
end

function turntableScene:displayAnimation(pSender)
    local itemBg = pSender:getParent()
    local  effectNode= cc.Sprite:create()
    if SessionManager:sharedManager():getEffectOn() then
        scheduler.performWithDelayGlobal(function ()
           --ccexp.AudioEngine:play2d("transferbattle/audio/roll.mp3", false)
           SoundManager:playMusicEffect("transferbattle/audio/roll.mp3", false)
        end, 0.1)
        --SoundManager:playMusicEffect("transferbattle/audio/roll.mp3", false)
    end
    effectNode:setPosition(cc.p(itemBg:getContentSize().width/2,itemBg:getContentSize().height/2))
    itemBg:addChild(effectNode, itemBg:getLocalZOrder()+2)
    local attr = self:getAttributeByIndex(itemBg:getTag())
    local path = ""
    if attr.isBigger  == 1 then
        path = string.format("transferbattle/Big_%s_Animal.png",attr.name)  
    else
        path = string.format("transferbattle/Small_%s_Animal.png",attr.name)
    end
    local effect = self:createSpriteFrame(path,0.06,1,20,112,112)
    local rs = cc.RemoveSelf:create()
    effectNode:runAction(cc.Sequence:create(effect,rs))
end

function turntableScene:isBigger(index )
    local isBigger  = false
    if index == 9 or index ==13 or index == 17  or index ==21  then
        isBigger = true
    end
    return isBigger
end

function turntableScene:getAttributeByIndex( index )
    for k ,v in pairs(MainUITag) do
        if type(v) == "table" and v.name and v.tag == index then
            return v
        end
    end
    print("getAttributeByIndex nil index = "..index)
    return nil
end

return turntableScene