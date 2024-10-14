hc = require 'lib.HC'
tick = require 'lib.tick'
cpml = require 'cpml'
maid64 = require 'lib.maid'
hex = require 'lib.hex'

g = require 'globals'
background = require 'background'
chrome = require 'chrome'
explosions = require 'explosions'
bullets = require 'bullets'
shield = require 'shield'
zone = require 'zone'
bomb = require 'bomb'
boss = require 'boss'
player = require 'player'
start = require 'start'

function loadGame()
	background:load()
	bullets:load()
	shield:load()
	zone:load()
	bomb:load()
	boss:load()
	player:load()
	g.music = love.audio.newSource('res/loop1.wav', 'static')
	g.music:setLooping(true)
	g.music:play()
end

function updateGame()
	background:update()
	boss:update()
	shield:update()
	zone:update()
	player:update()
	bomb:update()
	bullets:update()
	g.clock = g.clock + 1
	if g.clock >= g.clockLimit then g.clock = 0 end
end

function drawGame()
	background:draw()
	zone:draw()
	shield:draw()
	player:draw()
	bomb:draw()
	bullets:draw()
	boss:draw()
	chrome:draw()
end

function love.load()
	love.graphics.setBackgroundColor(g.colors.black)
	tick.framerate = 60
	love.window.setTitle('haya')
	local windowConfig = {
		vsync = false,
		minwidth = g.width / 2,
		minheight = g.height / 2,
		resizable = true
	}
	love.window.setMode(g.width * g.scale, g.height * g.scale, windowConfig)
	maid64.setup(g.width, g.height)
	love.graphics.setDefaultFilter('nearest')
	love.graphics.setLineStyle('rough')
	love.graphics.setLineWidth(1)
	-- loadGame()
	start:load()
end

function love.update(dt)
	g.dt = dt
	if g.started then updateGame()
	else start:update() end
end

function love.keypressed(k)
	if k == 'escape' then love.event.push('quit') end
end


function love.resize(width, height)
	maid64.resize(width, height)
end

function love.draw()
	maid64.start()
	if g.started then drawGame()
	else start:draw() end
	maid64.finish()
end