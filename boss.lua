local bossSize = 16

local shieldAngle, shieldInit
local shieldDiff, shieldMod, shieldGap = 16, math.pi / 8, 16

return {

	clock = 0,
	beatSound = love.audio.newSource('res/sfx/beatlevel.wav', 'static'),
	wonSound = love.audio.newSource('res/sfx/beatgame.wav', 'static'),

	loadShield = function(self)
		shieldInit = math.pi / 2 + math.pi / 16
		for i = 1, self.shieldLayers do
			shieldAngle = shieldInit
			for j = 1, 8 do
				shield:spawn(self.pos.x + math.cos(shieldAngle) * (shieldDiff + shieldGap * i), self.pos.y + math.sin(shieldAngle) * (shieldDiff + shieldGap * i))
				shieldAngle = shieldAngle + shieldMod
			end
		end
	end,

	loadWave = function(self)
		if g.wave <= 2 then self.shieldLayers = 4
		elseif g.wave <= 5 then self.shieldLayers = 5
		else self.shieldLayers = 6 end
		self.active = true
		self.clock = 0
		self.pos = cpml.vec2.new(g.width / 5 * 4, g.height / 2)
		self.collider = hc.circle(self.pos.x, self.pos.y, 16)
		self.collider.type = 'boss'
		self.angle = math.random() * 4 * math.pi / 2
		self.vel.x = math.cos(self.angle) * self.speed
		self.vel.y = math.sin(self.angle) * self.speed
		self.last.x = self.vel.x
		self.last.y = self.vel.y
		if g.wave <= 2 then self.image = love.graphics.newImage('res/eika.png')
		elseif g.wave <= 5 then self.image = love.graphics.newImage('res/urumi.png')
		else self.image = love.graphics.newImage('res/kutaka.png') end
		if g.wave == 3 or g.wave == 6 then
			g.music:stop()
			g.music = love.audio.newSource(g.wave == 3 and 'res/loop2.wav' or 'res/loop3.wav', 'static')
			g.music:setLooping(true)
			g.music:play()
		end
	end,

	load = function(self)
		self.pos = cpml.vec2.new(g.width / 5 * 4, g.height / 2)
		self.vel = cpml.vec2.new(0, 0)
		self.last = cpml.vec2.new(0, 0)
		self.off = 32
		self.speed = 1
		self.boundX = g.width / 4 * 3
		self.boundW = g.width - 40
		self.boundY = 40
		self.boundH = g.height - 40
		self.shotAngle = 0
		self.shotAngle2 = 0
		if g.wave > 0 then self:loadWave() end
		self.circleSize = 32
	end,

	updateNextWave = function(self)
		g.nextWaveClock = g.nextWaveClock - 1
		player:loadWave()
		if g.nextWaveClock <= 0 then
			g.wave = g.wave + 1
			background:loadWave()
			bomb:loadWave()
			self:loadWave()
		end
	end,


	eikaPatternOne = function(self)
		if self.clock % 90 >= 30 and self.clock % 20 == 0 then
			if player.invulnerableClock == 0 then g.sfx(bullets.sound2) end
			bullets:spawn({
				x = self.pos.x,
				y = self.pos.y,
				speed = 4,
				big = true,
				color = 'green',
				angle = math.pi - .2 + math.random() * .4
			}, function(j)
				if not bullets.list[j].flipped and bullets.list[j].pos.x < 8 then
					bullets.list[j].flipped = true
					bullets.list[j].vel.x = (bullets.list[j].vel.x * -1) * 0.67
					bullets.list[j].vel.y = bullets.list[j].vel.y * 0.67
					bullets.list[j].clock = 0
				elseif bullets.list[j].flipped then
					if bullets.list[j].clock % 15 == 0 then
						if player.invulnerableClock == 0 then g.sfx(bullets.sound1) end
						bullets:spawn({
							x = bullets.list[j].pos.x,
							y = bullets.list[j].pos.y,
							speed = 0.5,
							color = 'blue',
							angle = (bullets.list[j].clock % 30 == 0 and math.pi / 2 or math.pi / 2 * 3) - 1 + math.random() * 2
						}, function(h)
							if bullets.list[h].clock > 0 and bullets.list[h].clock % 10 == 0 and bullets.list[h].clock < 60 then
								bullets.list[h].vel.x = bullets.list[h].vel.x * 1.33;
								bullets.list[h].vel.y = bullets.list[h].vel.y * 1.33;
							end
						end)
					end
				end
			end)
		end
	end,

	eikaPatternTwo = function(self)
		if self.clock % 90 >= 30 and self.clock % 30 == 0 then
			if self.clock % 90 == 30 then
				self.shotAngle = math.random() * math.pi
				self.shotAngle2 = 0
			end
			if player.invulnerableClock == 0 then g.sfx(bullets.sound2) end
			for i = 1, 24 do
				bullets:spawn({
					x = self.pos.x,
					y = self.pos.y,
					speed = 4,
					big = true,
					color = 'green',
					angle = self.shotAngle + self.shotAngle2
				}, function(j)
					if bullets.list[j].clock == 45 then
						if player.invulnerableClock == 0 then g.sfx(bullets.sound1) end
						bullets:spawn({
							x = bullets.list[j].pos.x,
							y = bullets.list[j].pos.y,
							speed = 0.1,
							big = true,
							color = 'green',
							angle = bullets.list[j].angle
						}, function(h)
							if bullets.list[h].clock > 0 and bullets.list[h].clock % 10 == 0 and bullets.list[h].clock < 80 then
								bullets.list[h].vel.x = bullets.list[h].vel.x * 1.5;
								bullets.list[h].vel.y = bullets.list[h].vel.y * 1.5;
							end
						end)
					end
				end)
				self.shotAngle = self.shotAngle + g.tau / 24
			end
			self.shotAngle2 = self.shotAngle2 + 0.1
		end
	end,


	urumiPatternOne = function(self)
		if self.clock % 90 >= 30 and self.clock % 15 == 0 then
			if self.clock % 90 == 30 then
				self.shotAngle = math.random() * math.pi
				self.shotAngle2 = 0
			end
			if player.invulnerableClock == 0 then g.sfx(bullets.sound2) end
			for i = 1, 16 do
				bullets:spawn({
					x = self.pos.x,
					y = self.pos.y,
					speed = 4,
					big = true,
					color = 'red',
					angle = self.shotAngle + self.shotAngle2
				}, function(j)
					if bullets.list[j].clock % 10 == 0 and bullets.list[j].clock > 0 then
						if bullets.list[j].clock < 40 then
							bullets.list[j].vel.x = bullets.list[j].vel.x * 0.75;
							bullets.list[j].vel.y = bullets.list[j].vel.y * 0.75;
						elseif bullets.list[j].clock < 120 then
							bullets.list[j].size = bullets.list[j].size + 1
						end
					end
				end)
				self.shotAngle = self.shotAngle + g.tau / 16
			end
			self.shotAngle2 = self.shotAngle2 + math.random() * 0.15
		end
	end,

	urumiPatternTwo = function(self)
		if self.clock % 90 >= 30 then
			if self.clock % 4 == 0 then
				if player.invulnerableClock == 0 then g.sfx(bullets.sound1) end
				bullets:spawn({
					x = g.width,
					y = 16 + math.random() * (g.height - 32),
					speed = 3,
					color = 'blue',
					angle = math.pi - 0.1 + math.random() * 0.2
				})
			end
			if self.clock % 15 == 0 then
				self.shotAngle = math.atan2(player.pos.y - self.pos.y, player.pos.x - self.pos.x)
				if player.invulnerableClock == 0 then g.sfx(bullets.sound2) end
				for i = 1, 3 do
					bullets:spawn({
						x = self.pos.x,
						y = self.pos.y,
						speed = 4,
						big = true,
						color = 'red',
						angle = math.atan2(player.pos.y - self.pos.y, player.pos.x - self.pos.x) + (i - 2) * 0.5
					}, function(j)
						if bullets.list[j].clock % 10 == 0 and bullets.list[j].clock > 0 then
							if bullets.list[j].clock < 40 then
								bullets.list[j].vel.x = bullets.list[j].vel.x * 0.75;
								bullets.list[j].vel.y = bullets.list[j].vel.y * 0.75;
							elseif bullets.list[j].clock < 120 then
								bullets.list[j].size = bullets.list[j].size + 1
							end
						end
					end)
				end
			end
		end
	end,

	urumiPatternThree = function(self)
		if self.clock % 90 >= 30 and self.clock % 10 == 0 then
			if self.clock % 90 == 30 then
				self.shotAngle2 = 0
			end
			self.shotAngle = 0
			if player.invulnerableClock == 0 then g.sfx(bullets.sound1) end
			for i = 1, 5 do 
				bullets:spawn({
					x = self.pos.x,
					y = self.pos.y,
					speed = 3,
					color = 'red',
					angle = math.pi / 2 + self.shotAngle + self.shotAngle2
				}, function(j)
					if bullets.list[j].flipCount < 2 then
						if bullets.list[j].pos.y <= bullets.list[j].size or bullets.list[j].pos.y >= g.height - bullets.list[j].size then
							bullets.list[j].vel.y = bullets.list[j].vel.y * -1
							bullets.list[j].flipCount = bullets.list[j].flipCount + 1
						end
						if bullets.list[j].pos.x <= bullets.list[j].size or bullets.list[j].pos.x >= g.width - bullets.list[j].size then
							bullets.list[j].vel.x = bullets.list[j].vel.x * -1
							bullets.list[j].flipCount = bullets.list[j].flipCount + 1
						end
					end
				end)
				self.shotAngle = self.shotAngle - math.pi / 4
			end
			self.shotAngle2 =  self.shotAngle2 + (self.clock % 180 >= 90 and 0.1 or -0.1)
		end
	end,


	kutakaPatternOne = function(self)
		if self.clock % 90 >= 30 and self.clock % 5 == 0 then
			if self.clock % 15 == 0 then
				self.shotAngle = math.random() * g.tau
				self.shotAngle2 = self.shotAngle
			end
			if player.invulnerableClock == 0 then g.sfx(bullets[self.clock % 30 < 15 and 'sound1' or 'sound2']) end
			for i = 1, 20 do
				bullets:spawn({
					x = self.pos.x + math.cos(self.shotAngle2) * 24,
					y = self.pos.y + math.sin(self.shotAngle2) * 24,
					speed = 4,
					color = self.clock % 30 < 15 and 'green' or 'blue',
					angle = self.shotAngle,
					opposite = self.clock % 30 < 15
				}, function(j)
					if bullets.list[j].clock > 0 and bullets.list[j].clock % 10 == 0 then
						bullets.list[j].angle = bullets.list[j].angle - (bullets.list[j].opposite and 0.2 or -0.2)
						bullets.list[j].vel.x = math.cos(bullets.list[j].angle) * bullets.list[j].speed
						bullets.list[j].vel.y = math.sin(bullets.list[j].angle) * bullets.list[j].speed
					end
				end)
				self.shotAngle = self.shotAngle + g.tau / 20
			end
		end
	end,

	kutakaPatternTwo = function(self)
		if self.clock % 90 >= 30 and self.clock % 15 == 0 then
			if self.clock % 30 == 15 then
				if player.invulnerableClock == 0 then g.sfx(bullets.sound1) end
				for i = 1, 2 do
					bullets:spawn({
						x = self.pos.x,
						y = self.pos.y,
						speed = 3,
						big = true,
						color = 'blue',
						angle = math.pi + (i == 1 and 0.1 or -0.1)
					}, function(j)
						if bullets.list[j].pos.x <= 0 then
							if player.invulnerableClock == 0 then g.sfx(bullets.sound1) end
							for h = 1, 6 do
								bullets:spawn({
									x = bullets.list[j].pos.x,
									y = bullets.list[j].pos.y,
									speed = 1,
									color = 'blue',
									angle = math.pi * 1.5 + (math.pi / 7) * h
								}, function(k)
									if bullets.list[k].clock > 0 and bullets.list[k].clock % 10 == 0 and bullets.list[k].clock < 80 then 
										bullets.list[k].vel.x = bullets.list[k].vel.x * 1.1
										bullets.list[k].vel.y = bullets.list[k].vel.y * 1.1
									end
								end)
							end
							bullets:kill(j)
						end
					end)
				end
			end
			if player.invulnerableClock == 0 then g.sfx(bullets.sound2) end
			bullets:spawn({
				x = -8,
				y = 16 + math.random() * (g.height - 32),
				speed = 1,
				big = true,
				color = 'green',
				angle = -0.25 + math.random() * 0.5
			}, function(i)
				if bullets.list[i].clock > 0 and bullets.list[i].clock % 10 == 0 and bullets.list[i].clock < 60 then 
					bullets.list[i].vel.x = bullets.list[i].vel.x * 1.2
					bullets.list[i].vel.y = bullets.list[i].vel.y * 1.2
				end
			end)
		end
	end,

	kutakaPatternThree = function(self)
		if self.clock % 90 >= 30 and self.clock % 10 == 0 then
			self.shotAngle = math.random() * math.pi
			if player.invulnerableClock == 0 then g.sfx(bullets.sound2) end
			for i = 1, 24 do
				bullets:spawn({
					x = self.pos.x + math.cos(self.shotAngle + math.random() * 0.5) * 24,
					y = self.pos.y + math.sin(self.shotAngle + math.random() * 0.5) * 24,
					speed = i % 2 == 0 and 0.1 or 0.2,
					big = i % 2 == 0 and true or false,
					color = 'red',
					angle = self.shotAngle,
					opposite = self.clock % 30 >= 15
				}, function(j)
					if bullets.list[j].clock > 0 and bullets.list[j].clock % 10 == 0 then 
						if bullets.list[j].clock < 60 then
							bullets.list[j].speed = bullets.list[j].speed + 0.5
						else
							bullets.list[j].angle = bullets.list[j].angle + (bullets.list[j].opposite and 0.2 or -0.2)
						end
						bullets.list[j].vel.x = math.cos(bullets.list[j].angle) * bullets.list[j].speed
						bullets.list[j].vel.y = math.sin(bullets.list[j].angle) * bullets.list[j].speed
					end
				end)
				self.shotAngle = self.shotAngle + g.tau / 24
			end
		end
	end,

	blaster = function(self)
		if self.clock % 2 == 0 then
			if(self.clock % 30 == 0) then 
				self.shotAngle = math.atan2(player.pos.y - self.pos.y, player.pos.x - self.pos.x)
			end
			if player.invulnerableClock == 0 then g.sfx(bullets.sound3) end
			local mod, full
			if g.wave <= 2 then
				mod = 0.15
				full = 0.3
			elseif g.wave <= 5 then
				mod = 0.2
				full = 0.4
			else
				mod = 0.25
				full = 0.5
			end
			bullets:spawn({
				x = self.pos.x,
				y = self.pos.y,
				blaster = true,
				speed = 5,
				big = self.clock % 4 == 0 and true or false,
				color = 'pink',
				angle = self.shotAngle - mod + math.random() * full
			})
		end
	end,

	shoot = function(self)
		if self.clock % 540 < 360 then

			if g.wave == 1 then
				self:eikaPatternOne()
			elseif g.wave == 2 then
				self:eikaPatternTwo()

			elseif g.wave == 3 then
				self:urumiPatternOne()
			elseif g.wave == 4 then
				self:urumiPatternTwo()
			elseif g.wave == 5 then
				self:urumiPatternThree()

			elseif g.wave == 6 then
				self:kutakaPatternOne()
			elseif g.wave == 7 then
				self:kutakaPatternTwo()
			elseif g.wave == 8 then
				self:kutakaPatternThree()
			end

		elseif self.clock % 540 >= 450 and self.clock % 30 < 20 then
			self:blaster()
		end
	end,

	move = function(self)
		if self.clock % 90 == 0 then
			self.vel.x = self.last.x
			self.vel.y = self.last.y
		elseif self.clock % 90 == 30 then
			self.last.x = self.vel.x
			self.last.y = self.vel.y
			self.vel.x = 0
			self.vel.y = 0
		end
		self.pos.x = self.pos.x + self.vel.x
		self.pos.y = self.pos.y + self.vel.y
		self.collider:moveTo(self.pos.x, self.pos.y)
		if self.pos.x >= self.boundW or self.pos.x <= self.boundX then
			self.vel.x = self.vel.x * -1
		end
		if self.pos.y >= self.boundH or self.pos.y <= self.boundY then
			self.vel.y = self.vel.y * -1
		end
	end,

	hurt = function(self)
		for i = 1, shield.count do
			if shield.list[i].active then
				shield.list[i].active = false
				hc.remove(shield.list[i].collider)
			end
		end
		g.sfx(explosions.sound2)
		g.sfx(self.beatSound)
		self.active = false
		hc.remove(self.collider)
		g.score = g.score + 2500 * g.wave
		if self.clock < 2700 then g.score = (g.score + 2700 - self.clock) * 2 end
		if g.wave < 8 then g.nextWaveClock = g.waveClockTime
		else
			g.gameOver = true
			g.wonGame = true
			g.music:stop()
			g.sfx(self.wonSound)
			g.saveScore()
		end
	end,

	update = function(self)
		if self.active and g.nextWaveClock == 0 then

			if self.clock == 15 then self:loadShield() end

			if self.clock >= 90 then self:move() end
			if self.clock > 0 then self:shoot() end
			self.clock = self.clock + 1
			if self.clock >= g.clockLimit then self.clock = 0 end
		end
		if g.nextWaveClock > 0 then self:updateNextWave() end
	end,

	drawCircle = function(self)
		if self.active then
			g:startStencil('half')
			if g.wave <= 2 then
				love.graphics.setColor(g.colors.blueDark)
			elseif g.wave <= 5 then
				love.graphics.setColor(g.colors.greenDark)
			else
				love.graphics.setColor(g.colors.redDark)
			end
			love.graphics.circle('line', self.pos.x, self.pos.y, self.circleSize)
			love.graphics.circle('line', self.pos.x, self.pos.y, self.circleSize - 8)
			g:endStencil()
		end
	end,

	draw = function(self)
		if self.active and g.nextWaveClock == 0 then love.graphics.draw(self.image, math.floor(self.pos.x - self.off), math.floor(self.pos.y - self.off)) end
	end

}