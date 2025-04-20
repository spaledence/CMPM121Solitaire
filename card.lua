require "vector"

CardClass = {}

CARD_STATE = {
    IDLE = 0,
    MOUSE_OVER = 1,
    GRABBED = 2
}

function CardClass:new(xPos, yPos, suit, rank, faceUp)
    local card = {}
    local metadata = {__index = CardClass}
    setmetatable(card, metadata)

    card.position = Vector(xPos, yPos)
    card.size = Vector(50, 70)
    card.state = CARD_STATE.IDLE

    card.pile = nil
    card.suit = suit
    card.rank = rank
    card.faceUp = faceUp or false


    return card
end

function CardClass:update()

end

function CardClass:draw()

    if self.state ~= CARD_STATE.IDLE then
        love.graphics.setColor(0, 0, 0, 0.8) --shadow for hovered cards 
        local offset = 4 * (self.state == CARD_STATE.GRABBED and 2 or 1)
        love.graphics.rectangle("fill", self.position.x + offset, self.position.y + offset, self.size.x, self.size.y, 6, 6)
    end

    --love.graphics.setColor(1, 1, 1, 1)
    --love.graphics.rectangle("fill", self.position.x, self.position.y, self.size.x, self.size.y, 6, 6)
    --love.graphics.print(tostring(self.state), self.position.x + 20, self.position.y - 20)


    if self.faceUp then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", self.position.x, self.position.y, self.size.x, self.size.y, 6, 6)

        if self.suit == "hearts" or self.suit == "diamonds" then
            love.graphics.setColor(1, 0, 0) -- red
        else
            love.graphics.setColor(0, 0, 0) -- black
        end
        
        love.graphics.print(self:getCardLabel(), self.position.x + 8, self.position.y + 8)
    else
        -- facedown cards are gray
        love.graphics.setColor(0.3, 0.3, 0.3, 1)
        love.graphics.rectangle("fill", self.position.x, self.position.y, self.size.x, self.size.y, 6, 6)
    end

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", self.position.x, self.position.y, self.size.x, self.size.y, 6, 6)

    -- state label above the card for debugging and identifying hover
    --love.graphics.setColor(1, 1, 1, 1)
    --love.graphics.print(tostring(self.state), self.position.x + 20, self.position.y - 20)
end

function CardClass:getCardLabel()
    local ranks = {"A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"}
    local symbols = {
        hearts = "♥", diamonds = "♦",
        spades = "♠", clubs = "♣"
    }
    return ranks[self.rank] .. symbols[self.suit]
end

function CardClass:checkForMouseOver(grabber)
    if self.state == CARD_STATE.GRABBED then
        return
    end

    local mousePos = grabber.currentMousePos
    local isMouseOver = 
        mousePos.x > self.position.x and
        mousePos.x < self.position.x + self.size.x and
        mousePos.y > self.position.y and
        mousePos.y < self.position.y + self.size.y

    self.state = isMouseOver and CARD_STATE.MOUSE_OVER or CARD_STATE.IDLE
end
