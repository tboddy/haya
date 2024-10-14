return {

	timeLeft = 10,
	active = false,

	appearSound = love.audio.newSource('res/sfx/startgame.wav', 'static'),
	collectSound = love.audio.newSource('res/sfx/beatlevel.wav', 'static'),

	loadWave = function(self)
		self.pos = cpml.vec2.new(40, g.height / 2)
		self.count = 0.5
		self.armed = false
		self.active = false
		if g.wave <= 2 then self.timeLeft = 10
		elseif g.wave <= 5 then self.timeLeft = 15
		else self.timeLeft = 20 end
	end,

	load = function(self)
		self.size = 8
		self:loadWave()
		self.init = self.pos.y
	end,

	collect = function(self)
		for collider in pairs(hc.collisions(self.collider)) do
			if collider.type == 'player' then
				self.active = false
				self.armed = true
				hc.remove(self.collider)
				g.sfx(self.collectSound)
				-- self.collider = false
			end
		end
	end,

	update = function(self)
		if g.nextWaveClock == 0 and not g.gameOver then
			if self.armed then
				if love.keyboard.isDown('x') then
					g.sfx(player.bulletSound)
					bullets:spawn({
						x = player.pos.x + 16,
						y = player.pos.y,
						color = 'yellow',
						speed = 4,
						big = true,
						angle = 0,
						player = true
					})
					self.armed = false
					self.timeLeft = 10
				end
			else
				if g.clock > 0 and g.clock % 60 == 0 and self.timeLeft > 0 then
					self.timeLeft = self.timeLeft - 1
					if self.timeLeft == 0 then
						self.active = true
						self.count = 0.5
						self.collider = hc.circle(self.pos.x, self.pos.y, self.size + 4)
						self.collider.type = 'bomb'
						g.sfx(self.appearSound)
					end
				end
				if self.active then
					self.pos.y = self.init + math.sin(self.count) * 4
					self.count = self.count + 0.05
					self.collider:moveTo(self.pos.x, self.pos.y)
					self:collect()
				end
			end
		end
	end,

	draw = function(self)
		if self.active and g.nextWaveClock == 0 and not g.gameOver then
			love.graphics.setColor(g.clock % 20 < 10 and g.colors.shadow or g.colors.pink)
			love.graphics.circle('fill', self.pos.x, self.pos.y, self.size + 1)
			love.graphics.setColor(g.colors.yellowDark)
			love.graphics.circle('fill', self.pos.x, self.pos.y, self.size)
			love.graphics.setColor(g.colors.yellow)
			love.graphics.circle('fill', self.pos.x, self.pos.y, self.size - 2)
			love.graphics.setColor(g.colors.yellowLight)
			g:startStencil('half')
			love.graphics.circle('fill', self.pos.x, self.pos.y, self.size - 4)
			g:endStencil()
			g:resetColor()
			love.graphics.setFont(g:smallFont())
			love.graphics.setColor(g.colors.shadow)
			love.graphics.print('B', self.pos.x - 3, self.pos.y - 4)
			love.graphics.setColor(g.colors.white)
			love.graphics.print('B', self.pos.x - 3, self.pos.y - 3)
		end
	end

}