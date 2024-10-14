local bulletSize, bulletSizeBig, bulletSizeSmall = 4, 8, 2

local shieldCheck = g.width / 2

local shieldDist
local shieldCollide = 8

return {
	count = 512,
	list = {},

	spawn = function(self, spawner, updater)
		i = -1
		for j = 1, self.count do if i == -1 and not self.list[j].active then i = j break end end
		if i > -1 and ((g.nextWaveClock == 0 and player.invulnerableClock == 0) or spawner.player or spawner.explosion) then
			self.list[i].active = true
			self.list[i].pos.x = spawner.x
			self.list[i].pos.y = spawner.y
			self.list[i].vel.x = math.cos(spawner.angle) * spawner.speed
			self.list[i].vel.y = math.sin(spawner.angle) * spawner.speed
			self.list[i].color = g.colors[spawner.color]
			self.list[i].colorLight = g.colors[spawner.color .. 'Light']
			self.list[i].player = spawner.player and true or false
			self.list[i].collider = hc.circle(spawner.x, spawner.y, (spawner.big and bulletSizeBig or bulletSize) - 1)
			self.list[i].updater = updater and updater or false
			self.list[i].clock = 0
			self.list[i].speed = spawner.speed
			self.list[i].flipped = false
			self.list[i].big = spawner.big and true or false
			self.list[i].explosion = spawner.explosion and true or false
			self.list[i].angle = spawner.angle and spawner.angle or false
			self.list[i].size = (spawner.explosion and math.random() < 0.5) and bulletSizeSmall or (spawner.big and bulletSizeBig or bulletSize)
			self.list[i].flipCount = 0
			self.list[i].opposite = spawner.opposite and true or false
			self.list[i].blaster = spawner.blaster and true or false
			self.list[i].inZone = false
		end
	end,

	kill = function(self, i)
		self.list[i].active = false
		hc.remove(self.list[i].collider)
		-- self.list[i].collider = false
	end,

	load = function(self)
		self.sound1 = love.audio.newSource('res/sfx/bullet1.wav', 'static')
		self.sound2 = love.audio.newSource('res/sfx/bullet2.wav', 'static')
		self.sound3 = love.audio.newSource('res/sfx/bullet3.wav', 'static')
		for i = 1, self.count do
			self.list[i] = {
				active = false,
				pos = cpml.vec2.new(0, 0),
				vel = cpml.vec2.new(0, 0),
				color = '',
				colorLight = ''
			}
		end
	end,

	bounds = function(self, i)
		if self.list[i].pos.x > g.width + self.list[i].size or self.list[i].pos.x < -self.list[i].size or
			self.list[i].pos.y > g.height + self.list[i].size or self.list[i].pos.y < -self.list[i].size then
			self:kill(i)
		end
	end,

	collide = function(self, i)
		for collider in pairs(hc.collisions(self.list[i].collider)) do
			if self.list[i].player and collider.type == 'shield' then
				shield:hurt(collider.index)
				self:kill(i)
			elseif self.list[i].player and self.list[i].big and collider.type == 'boss' then
				boss:hurt(collider.index)
				self:kill(i)
			elseif not self.list[i].player and not self.list[i].explosion and collider.type == 'player' then
				player:hurt()
				self:kill(i)
			end

		end
	end,

	update = function(self)
		for i = 1, self.count do
			if self.list[i].active then
				if not self.list[i].player and not self.list[i].explosion and not self.list[i].blaster then
					self.list[i].inZone = self.list[i].pos.x < zone.pos.x + zone.size.x and self.list[i].pos.x > zone.pos.x
				end
				self.list[i].pos.x = self.list[i].pos.x + self.list[i].vel.x * (self.list[i].inZone and 0.5 or 1)
				self.list[i].pos.y = self.list[i].pos.y + self.list[i].vel.y * (self.list[i].inZone and 0.5 or 1)
				self.list[i].collider:moveTo(self.list[i].pos.x, self.list[i].pos.y)
				self:bounds(i)
				-- if self.list[i].player then self:collideWithShield(i) end
				if not g.gameOver then self:collide(i) end
				if self.list[i].updater then self.list[i].updater(i) end
				self.list[i].clock = self.list[i].clock + 1
			end
		end
	end,

	draw = function(self)
		for i = 1, self.count do
			if self.list[i].active then
				if self.list[i].explosion or self.list[i].player then g:startStencil('half') end
				if g.clock % 8 < 4 then
					love.graphics.setColor(self.list[i].colorLight)
					love.graphics.circle('fill', self.list[i].pos.x, self.list[i].pos.y, self.list[i].size)
					love.graphics.setColor(self.list[i].color)
					love.graphics.circle('fill', self.list[i].pos.x, self.list[i].pos.y, self.list[i].size - 2)
					love.graphics.setColor(g.colors.white)
					love.graphics.circle('line', self.list[i].pos.x, self.list[i].pos.y, self.list[i].size)
				else
					love.graphics.setColor(self.list[i].color)
					love.graphics.circle('fill', self.list[i].pos.x, self.list[i].pos.y, self.list[i].size)
					love.graphics.setColor(self.list[i].colorLight)
					love.graphics.circle('line', self.list[i].pos.x, self.list[i].pos.y, self.list[i].size)
				end
				if self.list[i].explosion or self.list[i].player then g:endStencil() end
				if g.nextWaveClock > 0 and not self.list[i].explosion then self:kill(i)
				elseif g.gameOver and not self.list[i].explosion and not self.list[i].player then self:kill(i) end
			end
		end
		g.resetColor()
	end

}