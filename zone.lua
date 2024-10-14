return {

	load = function(self)
		self.pos = cpml.vec2.new(72, 0)
		self.size = cpml.vec2.new(44, g.height)
		self.triangleSize = 16
		self.triangleOff = 8
	end,

	update = function(self)
	end,

	draw = function(self)
		g:startStencil('half')
		if g.wave <= 2 then
			love.graphics.setColor(g.colors.blueDark)
		elseif g.wave <= 5 then
			love.graphics.setColor(g.colors.greenDark)
		else
			love.graphics.setColor(g.colors.redDark)
		end
		love.graphics.rectangle('fill', self.pos.x + self.triangleOff, self.pos.y, self.size.x - self.triangleOff, self.size.y)
		for i = 1, 15 do
			love.graphics.polygon('fill',
				self.pos.x + self.triangleOff, self.pos.y + (i - 1) * self.triangleSize - 6,
				self.pos.x + self.triangleOff, self.pos.y + (i - 1) * self.triangleSize + self.triangleSize - 6,
				self.pos.x, self.pos.y +  (i - 1) * self.triangleSize + self.triangleOff - 6)
		end
		g:endStencil()
		g:resetColor()


		love.graphics.setColor(g.colors.shadow)
		g:startStencil('half')
		love.graphics.rectangle('fill', 0, 0, g.width, 4)
		love.graphics.rectangle('fill', 0, g.height - 3, g.width, 4)
		g:startStencil('quarter')
		love.graphics.rectangle('fill', 0, 4, g.width, 4)
		love.graphics.rectangle('fill', 0, g.height - 7, g.width, 4)
		g:resetColor()
		g:endStencil()
	end

}