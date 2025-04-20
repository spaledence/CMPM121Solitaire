require "vector"

PileClass = {}

function PileClass:new(x, y, pileType)
    local pile = {}
    local metadata = {__index = PileClass}
    setmetatable(pile, metadata)

    pile.position = Vector(x, y)
    pile.cards = {}
    -- pile types == "tableau", "foundation", "deck", "draw"
    pile.type = pileType

    if pileType == "tableau" then
        pile.cardSpacing = 25
    else
        pile.cardSpacing = 0
    end

    return pile
end

function PileClass:addCard(card)
    table.insert(self.cards, card)
    card.pile = self -- set a pile reference on card
end

function PileClass:removeCard(card)
    for i, c in ipairs(self.cards) do
        if c == card then
            table.remove(self.cards, i)
            card.pile = nil
            return
        end
    end
end

function PileClass:topCard()
    return self.cards[#self.cards]
end


function PileClass:draw()
    local drawStart = 1
    local drawEnd = #self.cards

    -- if is the draw pile, only draw the last 3 cards
    if self.type == "draw" then
        drawStart = math.max(1, #self.cards - 2)
    end

    -- include suits
    if self.type == "foundation" and #self.cards == 0 and self.suit then
        local symbolMap = {
            spades = "♠",
            hearts = "♥",
            clubs = "♣",
            diamonds = "♦"
        }

        --color coding
        local symbol = symbolMap[self.suit] or "?"
        local r, g, b = 0, 0, 0

        if self.suit == "hearts" or self.suit == "diamonds" then
            r, g, b = 1, 0, 0
        end

        love.graphics.setColor(r, g, b, 0.2) -- semi-transparent
        love.graphics.setFont(bigFont)
        love.graphics.printf(symbol, self.position.x, self.position.y + 20, 50, "center")
        love.graphics.setFont(font)
        love.graphics.setColor(1, 1, 1, 1)
    end

    -- draw cards in this pile
    for i = drawStart, drawEnd do
        local card = self.cards[i]
        local offsetX, offsetY = 0, 0

        if self.type == "tableau" then
            offsetY = (self.cardSpacing or 0) * (i - 1)
        elseif self.type == "draw" then
            offsetX = (i - drawStart) * 20
        end

        card.position = Vector(self.position.x + offsetX, self.position.y + offsetY)
        card:draw()
    end

    if #self.cards == 0 then
        love.graphics.setColor(1, 1, 1, 0.3)
        love.graphics.rectangle("line", self.position.x, self.position.y, 50, 70, 6, 6)
        love.graphics.setColor(1, 1, 1, 1)
    end
end


function PileClass:isMouseOver(x, y)
    local padding = 10
    local pileWidth = 50
    local pileHeight

    if self.type == "tableau" then
        pileHeight = (#self.cards > 0 and (self.cardSpacing * (#self.cards - 1) + 70)) or 70
    else
        -- Fixed height for foundation, draw, and deck piles
        pileHeight = 70
    end

    return x > self.position.x - padding and x < self.position.x + pileWidth + padding and
           y > self.position.y - padding and y < self.position.y + pileHeight + padding
end

function PileClass:canAcceptCard(card)
    if self.type == "tableau" then
        local top = self:topCard()

        --if the pile is empty, only K can be placed
        if not top then
            return card.rank == 13
        end

        -- must be one rank lower than top card
        if card.rank ~= top.rank - 1 then
            return false
        end

        -- must be opposite color
        local function isRed(suit)
            return suit == "hearts" or suit == "diamonds"
        end

        return isRed(card.suit) ~= isRed(top.suit)
    end

    if self.type == "foundation" then
        local top = self:topCard()

        -- if pile is empty only A can be placed
        if not top then
            return card.rank == 1
        end

        -- suit must match and must be exactly one higher
        return card.suit == top.suit and card.rank == top.rank + 1
    end

    return false
end