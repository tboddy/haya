return {

	particleAngle = 0,
	sound1 = love.audio.newSource('res/sfx/explosion1.wav', 'static'),
	sound2 = love.audio.newSource('res/sfx/explosion2.wav', 'static'),

	spawn = function(self, pos, big)
		for i = 1, 6 do
			if i % 2 == 1 then
				self.particleAngle = math.random() * g.tau
			else
				self.particleAngle = self.particleAngle + math.pi
			end
			bullets:spawn({
				x = pos.x,
				y = pos.y,
				speed = 4,
				explosion = true,
				color = 'yellow',
				angle = self.particleAngle,
				opposite = big and true or false
			}, function(i)
				if bullets.list[i].clock == (bullets.list[i].opposite and 10 or 5) then
					bullets:kill(i)
				end
			end)
		end
	end
}