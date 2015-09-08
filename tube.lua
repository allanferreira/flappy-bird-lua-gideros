Tube = Core.class(Sprite)

function Tube:init(level)
	
	self.level = level
	self.paused = true
	
	self.pipe_texture = Texture.new("assets/images/pipe.png")
	self.pipe_down_texture = Texture.new("assets/images/pipe-down.png")
	self.pipe_up_texture = Texture.new("assets/images/pipe-up.png")
		
	self.speed = conf.TUBE_SPEED
	self.stage_width = conf.WIDTH
	self.stage_height = conf.HEIGHT
	self.offset = conf.TUBE_OFFSET
	
	self.pipe_width = conf.PIPE_SCALE * self.pipe_texture:getWidth()
	self.pipe_up_and_down_width = conf.PIPE_END_SCALE * self.pipe_down_texture:getWidth()
	self.pipe_up_and_down_height = conf.PIPE_END_SCALE * self.pipe_down_texture:getHeight()
	
	self.cur_position = self.stage_width
	
	self.pipe__top, self.pipe__bottom = self:getRandomTubeHeights()
	
	self.pipes_up = {}
	self.pipes_down = {}
	
	self.body_up, self.body_down = nil, nil
	
	--------------
	
	self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
	
end

function Tube:onEnterFrame(event)
	
	if not self.paused then
		if self.cur_position then

			-- if tubes hided from screen
			if self.cur_position > - self.pipe_up_and_down_width / 2 then
				self.cur_position = self.cur_position - self.speed
				
				if self.body_up and self.body_down then
					self.body_up:setPosition(self.cur_position, (self.pipe__top + self.pipe_up_and_down_height) / 2)
					local bottom_height = self.stage_height - self.pipe__bottom + self.pipe_up_and_down_height
					self.body_down:setPosition(self.cur_position, self.pipe__bottom + bottom_height / 2)
				else
					self:setPipesBodies()
					self:createBody()
				end
			else
				self.cur_position = self.stage_width + self.pipe_up_and_down_width / 2
				
				for i = 1, #self.pipes_up do
					self:removeChild(self.pipes_up[i])
				end
				for i = 1, #self.pipes_down do
					self:removeChild(self.pipes_down[i])
				end
				
				self:removeChild(self.pipe_down)
				self:removeChild(self.pipe_up)
				
				self.pipes_up, self.pipes_down = {}, {}
				self.pipe__top, self.pipe__bottom = self:getRandomTubeHeights()
				
				self:setPipesBodies()
				
				-- @TODO: how to check if last cell is not our tube
				table.remove(self.level.bodies)
				table.remove(self.level.bodies)
				
				--self:createBody()
				
			end
		
			self:draw()
		end
	end
	
end

function Tube:draw()

	self.pipe_down:setPosition(self.cur_position, self.pipe__top)
	self.pipe_up:setPosition  (self.cur_position, self.pipe__bottom)
	
	for i = 1, self.pipe__top - 1 do
		self.pipes_up[i]:setPosition(self.cur_position, i)
		self:addChild(self.pipes_up[i])
	end
	
	local down_pipes_length = math.floor(self.pipe__bottom + self.pipe_up_and_down_height )
	
	for i = 1, down_pipes_length - 1 do
		self.pipes_down[i]:setPosition(self.cur_position, i + down_pipes_length - 1)
		self:addChild(self.pipes_down[i])
	end
	
	self:addChild(self.pipe_down)
	self:addChild(self.pipe_up)
	
end

function Tube:getRandomTubeHeights()

	local up = math.random(self.stage_height * 0.15, self.stage_height * 0.5) 
	local down = up + self.offset
	return up, down
	
end

function Tube:setPipesBodies()

	for i = 1, self.pipe__top - 1 do
		self.pipes_up[i] = Bitmap.new(self.pipe_texture)
		self.pipes_up[i]:setAnchorPoint(0.5, 0)
		self.pipes_up[i]:setScale(conf.PIPE_SCALE)
	end
	
	local down_pipes_length = math.floor(self.pipe__bottom + self.pipe_up_and_down_height)
	
	for i = 1, down_pipes_length - 1 do
		self.pipes_down[i] = Bitmap.new(self.pipe_texture)
		self.pipes_down[i]:setAnchorPoint(0.5, 0)
		self.pipes_down[i]:setScale(conf.PIPE_SCALE)
	end
	
	
	self.pipe_up = Bitmap.new(self.pipe_up_texture)
	self.pipe_down = Bitmap.new(self.pipe_down_texture)
	
	self.pipe_down:setAnchorPoint(0.5, 0)
	self.pipe_up:setAnchorPoint(0.5, 0)
	
	self.pipe_down:setScale(conf.PIPE_END_SCALE, conf.PIPE_END_SCALE)
	self.pipe_up:setScale(conf.PIPE_END_SCALE, conf.PIPE_END_SCALE)
	
end

function Tube:createBody()

	local body_up = self.level.world:createBody {
		type = b2.STATIC_BODY
	}
	
	local poly_up = b2.PolygonShape.new()
	
	poly_up:setAsBox(self.pipe_up_and_down_width/2, (self.pipe__top + self.pipe_up_and_down_height) / 2)
	
	body_up:setPosition(self.cur_position, (self.pipe__top + self.pipe_up_and_down_height) / 2)
	body_up:setAngle(math.rad(self:getRotation()))
		
	local fixture_up = body_up:createFixture {
		shape = poly_up, 
		density = 1.0, 
		friction = 0.1, 
		restitution = 0.2
	}
	
	body_up.type = "wall"
	self.body_up = body_up
	body_up.object = self
	
	table.insert(self.level.bodies, body_up)
	
	--------------
	
	local body_down = self.level.world:createBody {
		type = b2.STATIC_BODY
	}
	
	local poly_down = b2.PolygonShape.new()
	
	local bottom_height = self.stage_height - self.pipe__bottom + self.pipe_up_and_down_height
	poly_down:setAsBox(self.pipe_up_and_down_width/2, bottom_height / 2)
	
	body_down:setPosition(self.cur_position, self.pipe__bottom + bottom_height / 2)
	body_down:setAngle(math.rad(self:getRotation()))
		
	local fixture_down = body_down:createFixture {
		shape = poly_down, 
		density = 1.0, 
		friction = 0.1, 
		restitution = 0.2
	}
	
	body_down.type = "wall"
	self.body_down = body_down
	body_down.object = self
	
	table.insert(self.level.bodies, body_down)
	
end