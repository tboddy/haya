local shieldSize = 8
-- local shieldImage = love.graphics.newImage('res/yin.png')
local shieldSpeed = 0.2

return {

	count = 128,
	list = {},
	color = '',

	spawn = function(self, x, y)
		i = -1
		for j = 1, self.count do if i == -1 and not self.list[j].active then i = j break end end
		if i > -1 then
			self.list[i].active = true
			self.list[i].pos.x = x
			self.list[i].pos.y = y
			self.list[i].collider = hc.circle(x, y, shieldSize - 1)
			self.list[i].collider.type = 'shield'
			self.list[i].collider.index = i
			-- self.list[i].health = 1
			self.list[i].health = 3
			self.list[i].clock = math.random(0, 30)
		end
	end,

	hurt = function(self, i)
		explosions:spawn(self.list[i].pos)
		self.list[i].health = self.list[i].health - 1
		g.score = g.score + 155
		if self.list[i].health == 0 then
			g.score = g.score + 1000 + (g.width - math.floor(-math.atan2(self.list[i].pos.y - player.pos.y, self.list[i].pos.x - player.pos.x) * 100))
			self.list[i].active = false
			hc.remove(self.list[i].collider)
			g.sfx(explosions.sound1)
		end
	end,

	load = function(self)
		for i = 1, self.count do
			self.list[i] = {
				active = false,
				pos = cpml.vec2.new(0, 0)
			}
		end
	end,

	move = function(self, i)
		if boss.clock >= 90 then
			self.list[i].pos.x = self.list[i].pos.x + boss.vel.x
			self.list[i].pos.y = self.list[i].pos.y + boss.vel.y
		end
		self.list[i].collider:moveTo(self.list[i].pos.x, self.list[i].pos.y)
	end,

	update = function(self)
		if g.nextWaveClock == 0 and not g.gameOver then
			for i = 1, self.count do
				if self.list[i].active then
					if g.clock % 60 >= self.list[i].clock and g.clock % 60 < self.list[i].clock + 30 then
						self.list[i].pos.y = self.list[i].pos.y + shieldSpeed
					else
						self.list[i].pos.y = self.list[i].pos.y - shieldSpeed
					end
					self:move(i)
					if g.nextWaveClock > 0 then
						self.list[i].active = false
						hc.remove(self.list[i].collider)
					end
				end
			end
		end
	end,

	draw = function(self)
		if g.nextWaveClock == 0 and not g.gameOver then
			boss:drawCircle()
			g:resetColor()
			for i = 1, self.count do
				if self.list[i].active then
					self.color = self.list[i].health == 3 and 'blue' or (self.list[i].health == 2 and 'green' or 'red')
					love.graphics.setColor(g.colors[self.color .. 'Dark'])
					love.graphics.circle('fill', self.list[i].pos.x, self.list[i].pos.y, shieldSize)
					love.graphics.setColor(g.colors[self.color])
					g:startStencil('half')
					love.graphics.circle('fill', self.list[i].pos.x, self.list[i].pos.y, shieldSize - 3)
					g:endStencil()
					love.graphics.setColor(g.colors.shadow)
					love.graphics.circle('line', self.list[i].pos.x, self.list[i].pos.y, shieldSize)
				end
			end
			g.resetColor()
		end
	end,

}