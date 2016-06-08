--
-- Author: tjl
-- Date: 2016-03-22 16:37:08
--
local TransferBattlePlayerItemView = class("TransferBattlePlayerItemView", function( )
	return ccui.Layout:create()
end)

--[[
{
	--info用户信息结构体
}
--]]
function TransferBattlePlayerItemView:ctor( info )
	if info then
		self.data = info
		self:setContentSize(cc.size(532,30))
		self:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2 ))

		--nick
		local nickLabel = ccui.Text:create()
		nickLabel:setFontSize(14)
		nickLabel:setString(tostring(info.szNickName))
		if info.isMySelf then
			nickLabel:setColor(cc.c3b(255, 255, 0))
		else
			nickLabel:setColor(cc.c3b(230, 254, 255))
		end
		nickLabel:setAnchorPoint(cc.p(0,0.5))
		nickLabel:setPosition(cc.p(15, self:getContentSize().height/2))
		self:addChild(nickLabel)
		
		-- score
		self.scoreLabel = ccui.Text:create()
		self.scoreLabel:setFontSize(14)
		if info.isMySelf then
			self.scoreLabel:setColor(cc.c3b(255, 255, 0))
		else
			self.scoreLabel:setColor(cc.c3b(230, 254, 255))
		end
		self.scoreLabel:setAnchorPoint(cc.p(0.5,0.5))
		self.scoreLabel:setString(string.formatnumberthousands(info.lScore))
		self.scoreLabel:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2))
		self:addChild(self.scoreLabel)

		--winorlose
		self.winOrloseLabel = ccui.Text:create()
		self.winOrloseLabel:setFontSize(14)
		if info.isMySelf then
			self.winOrloseLabel:setColor(cc.c3b(255, 255, 0))
		else
			self.winOrloseLabel:setColor(cc.c3b(230, 254, 255))
		end
		self.winOrloseLabel:setAnchorPoint(cc.p(0.5,0.5))
		self.winOrloseLabel:setString(string.formatnumberthousands( self.data.lScore - self.data.initScore))
		self.winOrloseLabel:setPosition(cc.p(self:getContentSize().width/2+170, self:getContentSize().height/2))
		self:addChild(self.winOrloseLabel)

		--下划线
		local down_line = ccui.ImageView:create()
		down_line:loadTexture("transferbattle/image_line.png",0)
		down_line:setPosition(cc.p(self:getContentSize().width/2,down_line:getContentSize().height/2))
		self:addChild(down_line)

	end
end

function TransferBattlePlayerItemView:getData()
	return self.data
end

--刷新数据
function TransferBattlePlayerItemView:refreshData(userInfo)
	print("PlayerItemView refreshData"..userInfo.lScore)
	self.scoreLabel:setString(string.formatnumberthousands(userInfo.lScore))
	self.winOrloseLabel:setString(string.formatnumberthousands( userInfo.lScore - userInfo.initScore))
	print("PlayerItemView refreshData222")
end

return TransferBattlePlayerItemView