local topCheck = 40

return {

	load = function()
	end,

	update = function()
	end,

	drawScore = function()
		if g.score > 0 then g:label(g.score, 4, 4) end
	end,

	drawPlayer = function(self)
		g:label('Player x' .. player.lives, 0, 4, 'center')
	end,

	drawBomb = function(self)
		if g.nextWaveClock == 0 then
			if bomb.armed then
				g:label('Bomb Armed', 0, 4, 'right', g.width - 4)
			elseif bomb.timeLeft == 0 then
				g:label('Bomb Ready', 0, 4, 'right', g.width - 4)
			else
				g:label('Bomb in ' .. (bomb.timeLeft > 9 and '' or '0') .. bomb.timeLeft, 0, 4, 'right', g.width - 4)
			end
		end
	end,

	drawGameOver = function(self)
		g:label(g.wonGame and 'Game Beat! Thank You!' or 'Game Over', 0, 16 * 4.5, 'center')
		g:label('Z/X To Menu', 0, 16 * 4.5 + 20, 'center')
		if g.score > g.highScore then
			g:label('New High Score! ' .. g.score, 0, 16 * 4.5 + 20 + 20, 'center')
		end
	end,

	drawNextWave = function(self)
		g:label(g.wave == 0 and 'Game Start' or 'Wave Finish!', 0, 16 * 4.5, 'center')
		g:label('Next Wave: ' .. (g.wave + 1), 0, 16 * 4.5 + 20, 'center')
	end,

	draw = function(self)
		if player.pos.y < topCheck then g:startStencil('half') end
		self:drawScore()
		self:drawPlayer()
		self:drawBomb()
		if player.pos.y < topCheck then g:endStencil() end
		if g.gameOver then self:drawGameOver()
		elseif g.nextWaveClock > 30 then self:drawNextWave() end
	end

}