return {

	scale = 3,
	clock = 0,
	clockLimit = 65535,

	width = 320,
	height = 180,

	bossHealth = 0,
	bossMax = 0,

	wave = 0,
	waveClockTime = 90,
	score = 0,

	grid = 8,
	nextWaveClock = 0,

	tau = math.pi * 2,
	phi = 1.618,

	score = 0,
	highScore = 0,

	gameOver = false,
	wonGame = false,

	dt = 1,
	debug = '',

	started = false,

	gemCount = 0,

	colors = {
		black = hex.rgb('000000'),
		shadow = hex.rgb('191028'),
		white = hex.rgb('f5f4eb'),
		gray = hex.rgb('afaab9'),

		blue = hex.rgb('7664fe'),
		blueDark = hex.rgb('453e78'),
		blueLight = hex.rgb('9ec2e8'),

		red = hex.rgb('dc534b'),
		redDark = hex.rgb('833129'),
		redLight = hex.rgb('e18d79'),

		green = hex.rgb('46af45'),
		greenDark = hex.rgb('216c4b'),
		greenLight = hex.rgb('a1d685'),


		yellow = hex.rgb('d6b97b'),
		yellowDark = hex.rgb('e18d79'),
		yellowLight = hex.rgb('e9d8a1'),

		pink = hex.rgb('d365c8'),
		pinkDark = hex.rgb('dc534b'),
		pinkLight = hex.rgb('d6b97b'),

	},

	-- fogShader = love.graphics.newShader(g3d.shaderpath, 'res/fog.frag'),
	-- transparentShader = love.graphics.newShader(g3d.shaderpath, 'res/transparent.frag'),
	-- moreTransparentShader = love.graphics.newShader(g3d.shaderpath, 'res/moretransparent.frag'),
	-- lightShader = love.graphics.newShader(g3d.shaderpath, 'res/light.frag'),

	font = function(self)
		return love.graphics.newFont('res/font/dyna-gear-large.ttf', 16)
	end,

	smallFont = function(self)
		return love.graphics.newFont('res/font/ibara.ttf', 7)
	end,

	-- bigFont = function(self)
	-- 	return love.graphics.newFont('res/font/dyna-gear-large.ttf', 32)
	-- end,

	resetColor = function(self)
		love.graphics.setColor(hex.rgb('ffffff'))
	end,

	label = function(self, input, lX, y, lAlign, lLimit, big, color)
		local x = 0 if lX then x = lX end
		local align = 'left' if lAlign then align = lAlign end
		local limit = g.width if lLimit then limit = lLimit end
		love.graphics.setFont(big and self:bigFont() or self:font())
		love.graphics.setColor(self.colors.shadow)
		love.graphics.printf(input, x, y + 1, limit, align)
		love.graphics.setColor(color and color or self.colors.white)
		love.graphics.printf(input, x, y, limit, align)
		self:resetColor()
	end,

	masks = {
	  half = love.graphics.newImage('res/masks/half.png'),
	  quarter = love.graphics.newImage('res/masks/quarter.png')
	},

	maskShader = love.graphics.newShader([[	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
		if (Texel(texture, texture_coords).rgb == vec3(0.0)) {
			discard;
		}
		return vec4(1.0);
		}
		]]),

	currentStencil = false,
	setStencilMask = function()
	  love.graphics.setShader(g.maskShader)
	  love.graphics.draw(g.currentStencil, 0, 0)
	  return love.graphics.setShader()
	end,

	startStencil = function(self, mask)
		self.currentStencil = self.masks[mask]
		love.graphics.stencil(self.setStencilMask, 'replace', 1)
		love.graphics.setStencilTest('greater', 0)
	end,

	endStencil = function()
	  love.graphics.setStencilTest()
	end,

	sfx = function(sound)
		sound:stop()
		sound:play()
	end,

	saveScore = function()
		if g.score >= g.highScore then
			-- local data = {}
			-- data.score = g.score
			-- love.filesystem.write("score.txt", serialize(data))
			local file = love.filesystem.newFile('data.wad')
			file:open('w')
			file:write(g.score)
			file:close()
		end
	end,

	reset = function(self)
		self.started = false
		self.gameOver = false
		self.wonGame = false
		self.wave = 0
		self.nextWaveClock = 0
		self.score = 0

		hc.remove(player.collider)

		if boss.active then
			boss.active = false
			hc.remove(boss.collider)
		end

		if bomb.active then
			bomb.active = false
			hc.remove(bomb.collider)
		end

		for i = 1, bullets.count do
			if bullets.list[i].active then
				bullets.list[i].active = false
				hc.remove(bullets.list[i].collider)
			end
		end
		for i = 1, shield.count do
			if shield.list[i].active then
				shield.list[i].active = false
				hc.remove(shield.list[i].collider)
			end
		end

		love.load()
	end

}