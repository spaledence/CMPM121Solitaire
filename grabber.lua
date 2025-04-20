require "vector"

GrabberClass = {}

function GrabberClass:new()
    local grabber = {}
    local metadata = {__index = GrabberClass}
    setmetatable(grabber, metadata)

    grabber.previousMousePos = nil
    grabber.currentMousePos = nil
    grabber.grabPos = nil
    grabber.heldObject = nil

    return grabber
end

function GrabberClass:update()
    self.currentMousePos = Vector(
        love.mouse.getX(),
        love.mouse.getY()
    )

    -- follow mouse 
    if self.heldObject then
        self.heldObject.position = self.currentMousePos - Vector(
            self.heldObject.size.x / 2,
            self.heldObject.size.y / 2
        )
    end

    -- onclick
    if love.mouse.isDown(1) and self.grabPos == nil then
        self:grab()
    end

    -- onRelease
    if not love.mouse.isDown(1) and self.grabPos ~= nil then
        self:release()
    end
end

function GrabberClass:grab()
    local grabbed = false

    -- allow grabbing a stack from tableau piles
    for _, pile in ipairs(tableauPiles) do
        for i = 1, #pile.cards do
            local card = pile.cards[i]

            if card.faceUp then
                local mx, my = self.currentMousePos.x, self.currentMousePos.y
                local cardBottom = card.position.y + card.size.y
                local isMouseOver = mx > card.position.x and mx < card.position.x + card.size.x and
                                    my > card.position.y and my < cardBottom

                if isMouseOver then
                    -- Grab this card and everything above it
                    self.heldStack = {}

                    for j = i, #pile.cards do
                        table.insert(self.heldStack, pile.cards[j])
                        pile.cards[j].state = CARD_STATE.GRABBED
                    end

                    self.heldObject = card
                    self.originalPile = pile
                    self.grabPos = self.currentMousePos

                    -- Remove grabbed cards from the pile
                    for j = #pile.cards, i, -1 do
                        table.remove(pile.cards, j)
                    end

                    grabbed = true
                    break
                end
            end
        end
        if grabbed then break end
    end

    -- allow grab top card from draw pile (only top card)
    if not grabbed and #drawPile.cards > 0 then
        local top = drawPile:topCard()
        if top and top.faceUp then
            local mx, my = self.currentMousePos.x, self.currentMousePos.y
            local isMouseOver = mx > top.position.x and mx < top.position.x + top.size.x and
                                my > top.position.y and my < top.position.y + top.size.y

            if isMouseOver then
                self.heldObject = top
                self.heldStack = {top}
                self.originalPile = drawPile
                self.grabPos = self.currentMousePos
                top.state = CARD_STATE.GRABBED

                table.remove(drawPile.cards, #drawPile.cards)
            end
        end
    end

    -- allow grab top card from foundation piles
    if not grabbed then
        for _, pile in ipairs(foundationPiles) do
            local top = pile:topCard()
            if top and top.faceUp then
                local mx, my = self.currentMousePos.x, self.currentMousePos.y
                local isMouseOver = mx > top.position.x and mx < top.position.x + top.size.x and
                                    my > top.position.y and my < top.position.y + top.size.y

                if isMouseOver then
                    self.heldObject = top
                    self.heldStack = {top}
                    self.originalPile = pile
                    self.grabPos = self.currentMousePos
                    top.state = CARD_STATE.GRABBED

                    pile:removeCard(top)
                    break
                end
            end
        end
    end


end


function GrabberClass:release()

    if not self.heldObject or not self.heldStack then
        self.grabPos = nil
        self.originalPile = nil
        return
    end

    local droppedOnPile = nil
    local allPiles = {}

    -- Combine tableau and foundation piles
    for _, p in ipairs(tableauPiles) do table.insert(allPiles, p) end
    for _, p in ipairs(foundationPiles) do table.insert(allPiles, p) end

    --use bottom card in stack to check placement
    for _, pile in ipairs(allPiles) do
        if pile:isMouseOver(self.currentMousePos.x, self.currentMousePos.y)
            and pile:canAcceptCard(self.heldObject) then
            droppedOnPile = pile
            break
        end
    end

    -- check, then add entire stack to new pile
    if droppedOnPile then
        for _, card in ipairs(self.heldStack) do
            droppedOnPile:addCard(card)
            card.state = CARD_STATE.IDLE
        end

        -- if empty, flip top card in original tableau pile 
        if self.originalPile and self.originalPile.type == "tableau" then
            local top = self.originalPile:topCard()
            if top and not top.faceUp then
                top.faceUp = true
            end
        end

        -- bring top card to front
        for i, c in ipairs(cardTable) do
            if c == self.heldObject then
                table.remove(cardTable, i)
                break
            end
        end
        table.insert(cardTable, self.heldObject)

    else
        -- bad drop! return stack to pile
        for _, card in ipairs(self.heldStack) do
            self.originalPile:addCard(card)
            card.state = CARD_STATE.IDLE
        end
    end

    -- 🔄 Reset grabber state
    self.heldObject = nil
    self.heldStack = nil
    self.originalPile = nil
    self.grabPos = nil
end