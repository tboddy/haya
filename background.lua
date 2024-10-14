return {

	loadWave = function(self)
		if g.wave <= 2 then self.cloudImage = love.graphics.newImage('res/sky1.png')
		elseif g.wave <= 5 then self.cloudImage = love.graphics.newImage('res/sky2.png')
		else self.cloudImage = love.graphics.newImage('res/sky3.png') end
	end,

	load = function(self)
		self.cloudPos = cpml.vec2.new(0, 0)
		self:loadWave()
		self.cloudSize = 128
	end,

	update = function(self)
		self.cloudPos.x = self.cloudPos.x - 1
		if self.cloudPos.x <= -self.cloudSize then self.cloudPos.x = self.cloudPos.x + self.cloudSize end
	end,

	draw = function(self)
		love.graphics.setColor(g.colors.shadow)
		love.graphics.rectangle('fill', 0, 0, g.width, g.height)
		g:resetColor()
		g:startStencil('half')
		for x = 1, 5 do
			for y = 1, 3 do
				love.graphics.draw(self.cloudImage, self.cloudPos.x + (x - 2) * self.cloudSize, self.cloudPos.y + (y - 2) * self.cloudSize)
			end
		end
		g:endStencil()
	end,

}



	-- startStencil('half')
	-- love.graphics.draw(img, player.x + gameX, player.y + gameY, 0, playerScale, playerScale, player.images.wing1:getWidth() / 2, player.images.wing1:getHeight() / 2)
	-- endStencil()