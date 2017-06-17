-----------------------------------------------------------------------------------------
--
-- game.lua
--
-----------------------------------------------------------------------------------------
module(..., package.seeall)

local dimension -- BETWEEN 5 AND 10
local preStartMenuGroup
local boardGroup
local board
local solution
local attempt
local isPlaying

function init()
    -- Build()
	initValues()
	initPreUI()
	initBoard()
end

function initValues()
	dimension = 7
	isPlaying = false
end

function initPreUI()
	preStartMenuGroup = display.newGroup()

	local midW = display.contentCenterX

	local startBtn=display.newRect(0,0,210,40)
	startBtn.x=midW
	startBtn.y=display.contentHeight-70
	startBtn:setFillColor(0.9,0.9,0.9)
	startBtn:addEventListener("tap",newPuzzle)
	preStartMenuGroup:insert(startBtn)
	
	local startText=display.newText("Start",0,0,native.systemFont,30)
	startText.x=midW
	startText.y=startBtn.y
	startText:setTextColor(0,0,0)
	preStartMenuGroup:insert(startText)


	local reduceBtn=display.newRect(0,0,100,40)
	reduceBtn.x=midW-55
	reduceBtn.y=display.contentHeight-130
	reduceBtn:setFillColor(0.8,0.5,0.5)
	reduceBtn:addEventListener("tap",reduceDimension)
	preStartMenuGroup:insert(reduceBtn)
	
	local reduceText=display.newText("Reduce",0,0,native.systemFont,25)
	reduceText.x=reduceBtn.x
	reduceText.y=reduceBtn.y
	reduceText:setTextColor(0,0,0)
	preStartMenuGroup:insert(reduceText)

	local addBtn=display.newRect(0,0,100,40)
	addBtn.x=midW+55
	addBtn.y=display.contentHeight-130
	addBtn:setFillColor(0.5,0.8,0.5)
	addBtn:addEventListener("tap",addDimension)
	preStartMenuGroup:insert(addBtn)
	
	local addText=display.newText("Add",0,0,native.systemFont,25)
	addText.x=addBtn.x
	addText.y=reduceBtn.y
	addText:setTextColor(0,0,0)
	preStartMenuGroup:insert(addText)

	local backBtn=display.newRect(0,0,120,100)
	backBtn.x=-20
	backBtn.y=display.contentHeight-100
	backBtn:setFillColor(0.4,0.4,0.4)
	backBtn:addEventListener("tap",menuCall)
	preStartMenuGroup:insert(backBtn)
	
	local backText=display.newText("Back",0,0,native.systemFont,15)
	backText.x=10
	backText.y=backBtn.y
	backText:setTextColor(0.7,0.7,0.7)
	preStartMenuGroup:insert(backText)

end

function newTile(x,y)

	local tileSize = 23

	local tile = display.newRect(0,0,tileSize,tileSize)
	tile.x=15	+((x-1)*(tileSize+1))
	tile.y=20	+((y-1)*(tileSize+1))
	tile.isTapped = false
	tile.isSolution = false
	tile.isGuide = false

	if y>3 then
		tile.y=tile.y+2
	end
	
	if x>3 then
		tile.x=tile.x+2
	end

	tile.label = display.newText("",0,0,native.systemFont,20)
	tile.label.x = tile.x
	tile.label.y = tile.y
	tile.label:setFillColor(0,0,0)

	tile.setText = function(self, message)
		self.label.text = message
		self.isGuide = true
	end

	tile.setSolution = function(self, value)
		self.isSolution = value
	end

	tile.reset = function(self)
		self.isSolution = false
		self.isTapped = false
		self.isGuide = false
		self.label.text = ""
	end

	tile.dispose = function(self)
		display.remove(self.label)
		display.remove(self)
	end

	tile.tap = function(self)
		if (isPlaying) then
			if not (self.isGuide) then
				self.isTapped = true
				if (self.isSolution) then
					self:setFillColor(0.5,0.8,0.5)
				else
					self:setFillColor(0.8,0.5,0.5)
				end
			end
		end
	end
	tile:addEventListener("tap",tile)

	return tile
end

function initBoard()
	display.remove(boardGroup)
	boardGroup = display.newGroup()

	board = {}
	for x=1,dimension+3 do
		board[x] = {}
		for y=1,dimension+3 do
			
			local curtile=newTile(x,y)
			
			if x<4 and y<4 then
				curtile:dispose()
			else
				board[x][y] = curtile
				boardGroup:insert(board[x][y])
			end
		end
	end
end

function deleteBoard()
	for x = 1, table.maxn(board) do
		for y = 1, table.maxn(board) do
			if (board[x][y]) then
				board[x][y]:dispose()
			end
		end
	end
	display.remove(boardGroup)
end

function deleteEverything()
	deleteBoard()
	display.remove(preStartMenuGroup)
end

function menuCall()
	deleteEverything()
	local menu = require("menu")
	menu.start()
end

function addDimension()
	dimension = dimension+1
	if (dimension > 10) then
		dimension = 10
	end
	initBoard()
end

function reduceDimension()
	dimension = dimension-1
	if (dimension < 5) then
		dimension = 5
	end
	initBoard()
end

function resetBoard()
	for x = 1, table.maxn(board) do
		for y = 1, table.maxn(board) do
			if (board[x][y]) then
				board[x][y]:reset()
			end
		end
	end
end

function newPuzzle()
	resetBoard()
	display.remove(preStartMenuGroup)
	isPlaying = true

	grid = {}

	for x=1, dimension do 
		grid[x] = {}
		for y=1, dimension do
			grid[x][y]=(math.random(0,1)==1)
		end
	end
	
	-- REMOVE EXTRA CHUNKS
	for x = 1, dimension do
		local chunks = 0
		local inChunk = false
		for y = 1, dimension do
			if (grid[x][y] ~= inChunk) then
				if (not inChunk and chunks < 3) then
					chunks = chunks+1
					inChunk = true
				elseif (not inChunk) then
					grid[x][y] = not grid[x][y]
				else
					inChunk = false
				end
			end
		end
	end
	
	for y = 1, dimension do
		local chunks = 0
		local inChunk = false
		for x = 1, dimension do
			if (grid[x][y] ~= inChunk) then
				if (not inChunk and chunks < 3) then
					chunks = chunks+1
					inChunk = true
				elseif (not inChunk) then
					grid[x][y] = not grid[x][y]
				else
					inChunk = false
				end
			end
		end
	end

	-- TELL TILES
	for x = 1, dimension do
		for y = 1, dimension do
			board[x+3][y+3]:setSolution(grid[x][y])
		end
	end

	-- DO CHUNK COUNT
	for x = 1, dimension do
		local chunkCount = {0,0,0,0}
		local thisChunk = 1
		local inChunk = false
		for y = 1, dimension do
			if (grid[x][y]) then
				inChunk = true
				chunkCount[thisChunk] = chunkCount[thisChunk] + 1
			else
				if (inChunk) then
					inChunk = not inChunk
					thisChunk = thisChunk+1
				end
			end
		end

		if (chunkCount[thisChunk] == 4) then
			thisChunk = thisChunk - 1
		end

		for i = 3-(thisChunk-1), 1, -1 do
			if (chunkCount[4-i] ~= 0) then
				board[x+3][i]:setText(chunkCount[4-i])
			end
		end
	end

	for y = 1, dimension do
		local chunkCount = {0,0,0,0}
		local thisChunk = 1
		local inChunk = false
		for x = 1, dimension do
			if (grid[x][y]) then
				inChunk = true
				chunkCount[thisChunk] = chunkCount[thisChunk] + 1
			else
				if (inChunk) then
					inChunk = not inChunk
					thisChunk = thisChunk+1
				end
			end
		end

		if (chunkCount[thisChunk] == 4) then
			thisChunk = thisChunk - 1
		end

		for i = 3-(thisChunk-1), 1, -1 do
			if (chunkCount[4-i] ~= 0) then
				board[i][y+3]:setText(chunkCount[4-i])
			end
		end
	end

end

function Check()
	local finish=true
	for x=4,dimension+3 do
		for y=4,dimension+3 do
			if tapped[x][y]==false and grid[x][y]==1 then
				finish=false
			end
		end
	end
	if finish==true then
		-- print "DONE"
		timer.performWithDelay(5000,New)
	end
end

