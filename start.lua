return {

	startSound = love.audio.newSource('res/sfx/startgame.wav', 'static'),
	helpSound = love.audio.newSource('res/sfx/menuselect.wav', 'static'),

	load = function(self)
		self.bgImage = love.graphics.newImage('res/startbg.png')
		self.logoImage = love.graphics.newImage('res/startlogo.png')
		self.bgSize = 64
		self.borderSize = 8
		self.helpActive = false
		self.helpPos = cpml.vec2.new(16, 12)
		self.helpSize = cpml.vec2.new(g.width - self.helpPos.x * 2, g.height - self.helpPos.y * 2)
		self.helpTextPos = cpml.vec2.new(self.helpPos.x + 18, self.helpPos.y + 15)
		self.helpTextDiff = 20
		self.pressing = true
		self.logoCount = 0.5
		if love.filesystem.getInfo('data.wad') then
			local file = love.filesystem.newFile('data.wad')
			file:open('r')
			g.highScore = tonumber(tostring(file:read()))
			file:close()
		end
		self.logoScale = 1
	end,

	drawBg = function(self)
		for x = 1, 5 do
			for y = 1, 3 do
				love.graphics.draw(self.bgImage, (x - 1) * self.bgSize, (y - 1) * self.bgSize)
			end
		end
	end,

	drawLogo = function(self)
		love.graphics.setColor(g.colors.shadow)
		love.graphics.draw(self.logoImage, g.width / 2, 60 + 1, 0, self.logoScale, self.logoScale, 126 / 2, 76 / 2)
		love.graphics.setColor(g.colors.blue)
		love.graphics.draw(self.logoImage, g.width / 2, 60, 0, self.logoScale, self.logoScale, 126 / 2, 76 / 2)
		g:resetColor()
	end,

	drawBorder = function(self)
		love.graphics.setColor(g.colors.shadow)
		g:startStencil('half')
		love.graphics.rectangle('fill', 0, 0, self.borderSize, g.height)
		love.graphics.rectangle('fill', g.width - self.borderSize, 0, self.borderSize, g.height)
		g:startStencil('quarter')
		love.graphics.rectangle('fill', self.borderSize, 0, self.borderSize * 2, g.height)
		love.graphics.rectangle('fill', g.width - self.borderSize * 3, 0, self.borderSize * 2, g.height)
		g:endStencil()
		g:resetColor()
	end,

	drawHelp = function(self)
		love.graphics.setColor(g.colors.shadow)
		g:startStencil('half')
		love.graphics.rectangle('fill', 0, 0, g.width, g.height)
		g:endStencil()
		love.graphics.rectangle('fill', self.helpPos.x, self.helpPos.y, self.helpSize.x, self.helpSize.y)
		love.graphics.setColor(g.colors.blueDark)
		love.graphics.rectangle('fill', self.helpPos.x + 1, self.helpPos.y + 1, self.helpSize.x - 2, self.helpSize.y - 2)
		love.graphics.setColor(g.colors.shadow)
		love.graphics.rectangle('fill', self.helpPos.x + 2, self.helpPos.y + 2, self.helpSize.x - 4, self.helpSize.y - 4)


		g:label('Use SHOT (Z) to destroy SHIELD.', self.helpTextPos.x, self.helpTextPos.y)
		g:label('    SHOT (Z)            SHIELD', self.helpTextPos.x, self.helpTextPos.y, nil, nil, nil, g.colors.yellowLight)

		g:label('Grab BOMB when it is ready...', self.helpTextPos.x, self.helpTextPos.y + self.helpTextDiff)
		g:label('     BOMB', self.helpTextPos.x, self.helpTextPos.y + self.helpTextDiff, nil, nil, nil, g.colors.yellowLight)

		g:label('  and shoot it (X) to kill BOSS.', self.helpTextPos.x, self.helpTextPos.y + self.helpTextDiff * 2)
		g:label('               (X)         BOSS', self.helpTextPos.x, self.helpTextPos.y + self.helpTextDiff * 2, nil, nil, nil, g.colors.yellowLight)

		g:label('ZONE will slow down bullets.', self.helpTextPos.x, self.helpTextPos.y + self.helpTextDiff * 3)
		g:label('ZONE', self.helpTextPos.x, self.helpTextPos.y + self.helpTextDiff * 3, nil, nil, nil, g.colors.yellowLight)

		g:label('Watch for BLAST every so often.', self.helpTextPos.x, self.helpTextPos.y + self.helpTextDiff * 4)
		g:label('          BLAST', self.helpTextPos.x, self.helpTextPos.y + self.helpTextDiff * 4, nil, nil, nil, g.colors.yellowLight)

		g:label('Z/X: Go back', 0, self.helpTextPos.y + self.helpTextDiff * 5.5, 'center')

		g:resetColor()
	end,

	update = function(self)

		self.logoScale = 1 + math.cos(self.logoCount) / 80
		self.logoCount = self.logoCount + 0.02

		if love.keyboard.isDown('z') and not self.pressing and not self.helpActive then
			g.started = true
			g.nextWaveClock = g.waveClockTime
			g.sfx(self.startSound)
			loadGame()
		elseif love.keyboard.isDown('x') and not self.pressing and not self.helpActive then
			self.pressing = true
			self.helpActive = true
			g.sfx(self.helpSound)
		elseif (love.keyboard.isDown('x') or love.keyboard.isDown('z')) and not self.pressing and self.helpActive then
			self.pressing = true
			self.helpActive = false
			g.sfx(self.helpSound)
		elseif not love.keyboard.isDown('x') and not love.keyboard.isDown('z') and self.pressing then
			self.pressing = false
		end

	end,

	draw = function(self)
		self:drawBg()
		-- else
			self:drawBorder()
			self:drawLogo()
			g:label('Z To Start', 0, 108, 'center')
			g:label('X For Help', 0, 108 + 20, 'center')
			g:label('2024 t.boddy', 0, g.height - 16 - 8, 'right', g.width - 8)
			g:label('High: ' .. g.highScore, 8, g.height - 16 - 8)
			-- g:label('2024 t.boddy', 0, g.height - 16 - 8, 'center', nil, nil, g.colors.blueLight)
		-- end
		if self.helpActive then self:drawHelp() end
	end

}