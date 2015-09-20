MenuScene = Core.class(Sprite)

--[[

	params = {
		
		isSoundEnabled - flag for sound managment
		
	}

--]]

function MenuScene:init(params)

	if params ~= nil then
		if params.isSoundEnabled ~= nil and type (params.isSoundEnabled) == "boolean" then
			self.isSoundEnabled = params.isSoundEnabled
		else
			self.isSoundEnabled = true
		end
	else
		self.isSoundEnabled = true
	end

	self.logo = Bitmap.new(Texture.new("assets/images/logo.png"))
	self.logo:setAnchorPoint(0.5, 0.5)
	self.logo:setScale(conf.LOGO_SCALE, conf.LOGO_SCALE)
	self.logo:setPosition(conf.WIDTH / 2, conf.HEIGHT / 4)
	
	self.level_width = conf.WIDTH

	self.land = Land.new{
		level = self,
		speed = conf.LAND_SPEED,
		scale = conf.LAND_SCALE,
		level_height = conf.HEIGHT,
		level_width = conf.WIDTH,
	}
	
	self.bg   = Background.new{
		level = self,
		speed = conf.BG_SPEED,
		level_height = conf.HEIGHT,
		level_width = conf.WIDTH,
		raw_scale = conf.HEIGHT - self.land.land_height
	}
		
	local rate = Bitmap.new(Texture.new("assets/images/button_rate.png"))
	rate:setAnchorPoint(0.5, 0.5)
	rate:setScale(conf.BUTTON_RATE_SCALE, conf.BUTTON_RATE_SCALE)
	
	self.rate_button = Button.new(rate)
	self.rate_button:setPosition(conf.WIDTH / 2, conf.HEIGHT / 4 + self.rate_button:getHeight() * 2)
	
	self.rate_button:addEventListener("click", function() 
		-- @TODO: open browser and go to the market place
	end)
	
	
	local bottom_button_pos_y  = conf.HEIGHT * 4 / 6
	
	local play = Bitmap.new(Texture.new("assets/images/replay.png"))
	play:setAnchorPoint(0.5, 0.5)
	play:setScale(conf.REPLAY_SCALE, conf.REPLAY_SCALE)

	self.play_button = Button.new(play)
	self.play_button:setPosition(conf.WIDTH / 2 - play:getWidth() / 2, bottom_button_pos_y)
	
	self.play_button:addEventListener("click", function() 
		sceneManager:changeScene("level", conf.TRANSITION_TIME,  SceneManager.fade, easing.inOutQuadratic, {
			userData = {
				isSoundEnabled = self.isSoundEnabled
			}
		
		})
	end)
	
	
	local score = Bitmap.new(Texture.new("assets/images/button_score.png"))
	score:setAnchorPoint(0.5, 0.5)
	score:setScale(conf.BUTTON_SCORE_SCALE, conf.BUTTON_SCORE_SCALE)
	
	self.score_button = Button.new(score)
	self.score_button:setPosition(conf.WIDTH / 2 + score:getWidth() / 2, bottom_button_pos_y)
	
	self.score_button:addEventListener("click", function() 
		-- @TODO: load best score from server and open Scoreboard scene
	end)
	
	
	self.bird = Bird.new{
		level = self,
		pos_x = conf.WIDTH / 2,
		pos_y = conf.HEIGHT / 2,
		level_height = conf.HEIGHT,
		speed = conf.BIRD_SPEED
	}
	
	
	self.on = Bitmap.new(Texture.new("assets/images/sound_on.png"))
	self.on:setAnchorPoint(0.5, 0.5)
	self.on:setScale(conf.SOUND_ON_OFF_SCALE, conf.SOUND_ON_OFF_SCALE)
	
	self.off = Bitmap.new(Texture.new("assets/images/sound_off.png"))
	self.off:setAnchorPoint(0.5, 0.5)
	self.off:setScale(conf.SOUND_ON_OFF_SCALE, conf.SOUND_ON_OFF_SCALE)
	
	self.sound_button = nil	
	if self.isSoundEnabled then
		self.sound_button = Button.new(self.on)
	else
		self.sound_button = Button.new(self.off)
	end
	
	self.sound_button:setPosition(conf.WIDTH / 2, 80)
	
	self.sound_button:addEventListener("click", function() 
		if self.isSoundEnabled then
			self.isSoundEnabled = false
			self.sound_button:removeChild(self.sound_button.sprite)
			self.sound_button.sprite = self.off
			self.sound_button:addChild(self.off)
		else
			self.isSoundEnabled = true
			self.sound_button:removeChild(self.sound_button.sprite)
			self.sound_button.sprite = self.on
			self.sound_button:addChild(self.on)
		end
	end)
	

	self:addChild(self.land)
	self:addChild(self.bg)
	self:addChild(self.logo)
	self:addChild(self.rate_button)
	self:addChild(self.score_button)
	self:addChild(self.play_button)
	self:addChild(self.sound_button)
	self:addChild(self.bird)
	
	self:addEventListener(Event.KEY_DOWN, self.onKeyDown, self)
	
end

function MenuScene:onKeyDown(event)
	if event.keyCode == KeyCode.BACK then 
		if application:getDeviceInfo() == "Android" then
			application:exit()
		end
	end
end