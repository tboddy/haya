local moveSpeed = 4
local moveSpeedNorm = moveSpeed * 0.707

local focusSpeed = 2.5
local focusSpeedNorm = focusSpeed * 0.707

local playerSize = 16
local playerOff = playerSize / 2

local boundsX, boundsW, boundsY, boundsH = playerOff, g.width - playerOff, playerOff, g.height - playerOff

local shotInterval = 10
local shotClock = shotInterval


return {

	bulletSound = love.audio.newSource('res/sfx/playershot.wav', 'static'),
	gameOverSound = love.audio.newSource('res/sfx/gameover.wav', 'static'),
	invulnerableClock = 0,

	loadWave = function(self)
		self.pos.x = self.init.x
		self.pos.y = self.init.y
		self.invulnerableClock = 0
	end,
	
	load = function(self)
		self.image = love.graphics.newImage('res/komachi.png')
		self.init = cpml.vec2.new(g.width / 5, g.height / 2)
		self.pos = cpml.vec2.new(self.init.x, self.init.y)
		self.vel = cpml.vec2.new(0, 0)
		self.off = 21
		self.collider = hc.circle(self.pos.x, self.pos.y, 0)
		self.collider.type = 'player'
		self.lives = 3
		self.bulletSound:setVolume(0.33)
		self.extends = 0
		self.didEnd = false
	end,

	movement = function(self)
		local speed, speedNorm = moveSpeed, moveSpeedNorm
		if love.keyboard.isDown('lshift') then
			speed = focusSpeed
			speedNorm = focusSpeedNorm
		end
		self.vel.x = 0
		self.vel.y = 0
		if love.keyboard.isDown('left') or love.keyboard.isDown('right') then
			if love.keyboard.isDown('up') then
				self.vel.y = -speedNorm
				if love.keyboard.isDown('left') then self.vel.x = -speedNorm
				else self.vel.x = speedNorm end
			elseif love.keyboard.isDown('down') then
				self.vel.y = speedNorm
				if love.keyboard.isDown('left') then self.vel.x = -speedNorm
				else self.vel.x = speedNorm end
			elseif love.keyboard.isDown('left') then
				self.vel.x = -speed
			elseif love.keyboard.isDown('right') then
				self.vel.x = speed end
		elseif love.keyboard.isDown('up') then self.vel.y = -speed
		elseif love.keyboard.isDown('down') then self.vel.y = speed end
	end,

	bounds = function(self)
		if self.pos.x < boundsX then self.pos.x = boundsX
		elseif self.pos.x > boundsW then self.pos.x = boundsW end
		if self.pos.y < boundsY then self.pos.y = boundsY
		elseif self.pos.y > boundsH then self.pos.y = boundsH end
	end,

	shoot = function(self)
		if love.keyboard.isDown('z') and shotClock >= shotInterval then
			shotClock = 0
		end
		if shotClock == 0 then
			g.sfx(self.bulletSound)
			bullets:spawn({
				x = self.pos.x + playerSize,
				y = self.pos.y,
				color = 'yellow',
				speed = 10,
				angle = 0,
				player = true
			})
		end
		shotClock = shotClock + 1
		if shotClock >= g.clockLimit then shotClock = shotInterval end
	end,

	hurt = function(self)
		explosions:spawn(self.pos, true)
		self.pos.x = self.init.x
		self.pos.y = self.init.y
		if player.lives > 0 then
			player.lives = player.lives - 1
			self.invulnerableClock = 60
			for i = 1, bullets.count do
				if bullets.list[i].active and not bullets.list[i].player and not bullets.list[i].explosion then
					bullets:kill(i)
				end
			end
		else
			g.gameOver = true
			boss.active = false
			g.saveScore()
			g.music:stop()
			g.sfx(self.gameOverSound)
		end
	end,

	extendBase = 2000000,

	update = function(self)
		if g.gameOver then
			if not love.keyboard.isDown('z') and not love.keyboard.isDown('x') and not self.didEnd then self.didEnd = true end
			if (love.keyboard.isDown('z') or love.keyboard.isDown('x')) and self.didEnd then g:reset() end
		elseif g.nextWaveClock == 0 and not g.gameOver then
			self:movement()
			self.pos.x = self.pos.x + self.vel.x
			self.pos.y = self.pos.y + self.vel.y
			self.collider:moveTo(self.pos.x, self.pos.y)
			self:bounds()
			self:shoot()
			if self.invulnerableClock > 0 then
				self.invulnerableClock = self.invulnerableClock - 1
			end
			if g.score > self.extendBase and self.extends == 0 then
				player.lives = player.lives + 1
				self.extends = 1
			elseif g.score > self.extendBase * 2 and self.extends == 1 then
				player.lives = player.lives + 1
				self.extends = 2
			elseif g.score > self.extendBase * 3 and self.extends == 2 then
				player.lives = player.lives + 1
				self.extends = 3
			elseif g.score > self.extendBase * 4 and self.extends == 3 then
				player.lives = player.lives + 1
				self.extends = 4
			elseif g.score > self.extendBase * 5 and self.extends == 4 then
				player.lives = player.lives + 1
				self.extends = 5
			end
		end
	end,

	draw = function(self)
		if g.nextWaveClock == 0 and not g.gameOver then

			if self.invulnerableClock == 0 or (self.invulnerableClock > 0 and self.invulnerableClock % 10 > 5) then
				love.graphics.draw(self.image, math.floor(self.pos.x - self.off), math.floor(self.pos.y - self.off))
				love.graphics.setColor(g.colors.greenDark)
				love.graphics.circle('fill', self.pos.x, self.pos.y, 4)
				love.graphics.setColor(g.colors.greenLight)
				love.graphics.circle('fill', self.pos.x, self.pos.y, 3)
				love.graphics.setColor(g.colors.white)
				love.graphics.circle('fill', self.pos.x, self.pos.y, 2)
				love.graphics.setColor(g.colors.shadow)
				love.graphics.circle('line', self.pos.x, self.pos.y, 4)
				g:resetColor()
			end
		end
	end

}