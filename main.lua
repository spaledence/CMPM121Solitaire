-- Dale Spence
-- CMPM 121 - Solitaire
-- 4-11-25

io.stdout:setvbuf("no")

require "card"
require "grabber"
require "piles"

deckPile = nil
drawPile = nil

restartButton = {
    x = 860, -- right edge of 960px window
    y = 20,
    width = 80,
    height = 30,
    label = "Restart"
}

function drawThreeFromDeck()
    if #deckPile.cards == 0 then
        -- Reset from draw pile
        while #drawPile.cards > 0 do
            local card = table.remove(drawPile.cards)
            card.faceUp = false
            deckPile:addCard(card)
        end
        return
    end

    -- Draw 3 cards from deck
    for i = 1, 3 do
        if #deckPile.cards == 0 then break end
        local card = table.remove(deckPile.cards)
        card.faceUp = true
        drawPile:addCard(card)

        -- Reorder draw stack visually
        for j, c in ipairs(cardTable) do
            if c == card then table.remove(cardTable, j) break end
        end
        table.insert(cardTable, card)
    end
end

gameState = "menu"

function love.load()
    math.randomseed(os.time())
    for i = 1, 4 do math.random() end

    menuImage = love.graphics.newImage("solitaireCover.png")
    bigFont = love.graphics.newFont("DejaVuSans.ttf", 24)
    midBoldFont = love.graphics.newFont("DejaVuSans-Bold.ttf", 20)
    boldFont = love.graphics.newFont("DejaVuSans-Bold.ttf", 30)

    font = love.graphics.newFont("DejaVuSans.ttf", 14)
    love.graphics.setFont(font)

    love.window.setMode(960, 640)
    love.graphics.setBackgroundColor(0, 0.7, 0.2, 1)

    grabber = GrabberClass:new()
    cardTable = {}


    -- create deck
    local suits = {"hearts", "diamonds", "clubs", "spades"}
    local fullDeck = {}


    for _, suit in ipairs(suits) do
        for rank = 1, 13 do
            local card = CardClass:new(0, 0, suit, rank, false)
            table.insert(fullDeck, card)
        end
    end

    -- Fisher-Yates shuffle
    for i = #fullDeck, 2, -1 do
        local j = math.random(i)
        fullDeck[i], fullDeck[j] = fullDeck[j], fullDeck[i]
    end

    -- Create 7 tableau piles
    tableauPiles = {}
    for i = 1, 7 do
        local x = 60 + (i - 1) * 70
        local y = 150
        local pile = PileClass:new(x, y, "tableau")
        table.insert(tableauPiles, pile)
    end

    -- deal cards to tableau piles
    local deckIndex = 1
    for i = 1, 7 do
        for j = 1, i do
            local card = fullDeck[deckIndex]
            deckIndex = deckIndex + 1
            card.faceUp = (j == i) -- only the top card is face-up
            tableauPiles[i]:addCard(card)
            table.insert(cardTable, card) -- for update/draw + dragging
        end
    end

    deckPile = PileClass:new(60, 60, "deck")
    drawPile = PileClass:new(140, 60, "draw")

    local suits = {"spades", "hearts", "clubs", "diamonds"}

    foundationPiles = {}
    for i = 1, 4 do
        local x = 520 + (i - 1) * 70
        local y = 60
        local pile = PileClass:new(x, y, "foundation")
        pile.suit = suits[i] -- assign suit to each pile
        table.insert(foundationPiles, pile)
    end


    --save remaining undealt cards for use in deck pile later
    --add undealt cards to deck pile
    for i = deckIndex, #fullDeck do
        local card = fullDeck[i]
        card.faceUp = false
        deckPile:addCard(card)
        table.insert(cardTable, card)
    end

end


function love.update()
    if gameState ~= "playing" then
        local win = true
        for _, pile in ipairs(foundationPiles) do
            if #pile.cards < 13 then
                win = false
                break
            end
        end

        if win then
            gameState = "win"
        end
    end
    grabber:update()
    checkForMouseMoving()

    for _, card in ipairs(cardTable) do
        card:update()
    end

    if grabber.heldStack then
        for i, card in ipairs(grabber.heldStack) do
            card.position = Vector(
                grabber.currentMousePos.x,
                grabber.currentMousePos.y + (i - 1) * 20 -- stack offset
            )
        end
    end
end

function love.draw()
    if gameState == "menu" then
        if menuImage then
            local scaleX = 960 / menuImage:getWidth()
            local scaleY = 640 / menuImage:getHeight()
    
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(menuImage, 0, 0, 0, scaleX, scaleY)
        end
        love.graphics.setFont(boldFont)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf("KLONDIKE SOLITAIRE", 0, 20, 960, "center")
        love.graphics.setFont(midBoldFont)
        love.graphics.printf("Created by", 0, 100, 960, "center")
        love.graphics.printf("Dale Spence", 0, 120, 960, "center")
        love.graphics.printf("Click to Start", 0, 250, 960, "center")

        return -- prevent rest of draw() from running
    end


    if gameState == "win" then
        love.graphics.setFont(bigFont)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("YOU WIN!", 0, 200, 960, "center")
    
        love.graphics.setFont(font)
        love.graphics.printf("Click to return to main menu", 0, 280, 960, "center")
        return
    end



    deckPile:draw()
    drawPile:draw()

    for _, pile in ipairs(foundationPiles) do
        pile:draw()
    end
    -- Draw piles
    for _, pile in ipairs(tableauPiles) do
        pile:draw()
    end

    for _, card in ipairs(cardTable) do
        if not card.pile then
            card:draw()
        end
    end

    if grabber.heldStack then
        for _, card in ipairs(grabber.heldStack) do
            card:draw()
        end
    end

    -- Debug mouse position
    --love.graphics.setColor(1, 1, 1)
    --love.graphics.print("Mouse: " .. tostring(grabber.currentMousePos.x) .. ", " .. tostring(grabber.currentMousePos.y), 10, 10)

    love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    love.graphics.rectangle("fill", restartButton.x, restartButton.y, restartButton.width, restartButton.height, 6, 6)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(font)
    love.graphics.printf(restartButton.label, restartButton.x, restartButton.y + 8, restartButton.width, "center")
end

function checkForMouseMoving()
    if grabber.currentMousePos == nil then return end
    for _, card in ipairs(cardTable) do
        card:checkForMouseOver(grabber)
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        -- win to menu
        if gameState == "win" then
            gameState = "menu"
            return
        end

        -- menu to start
        if gameState == "menu" then
            gameState = "playing"
            love.load()
            return
        end
        -- playing
        if gameState == "playing" then
            if x > restartButton.x and x < restartButton.x + restartButton.width and
               y > restartButton.y and y < restartButton.y + restartButton.height then
                love.load()
                return
            end

            -- ✅ Deck pile click (draw cards)
            if deckPile and deckPile:isMouseOver(x, y) then
                print("Deck clicked!")
                drawThreeFromDeck()
            end
        end
    end
end