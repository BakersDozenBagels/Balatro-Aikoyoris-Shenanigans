SolitaireCard = Card:extend()
function SolitaireCard:init(X, Y, W, H, card, center, params)
    local c = Card.init(self, X, Y, W, H, card, center, params)
    if getmetatable(self) == SolitaireCard then 
        table.insert(G.I.CARD, self)
    end
    return c
end
function SolitaireCard:click()
    local c = Card.click(self)
    if self.area == AKYRS.SOL.stockCardArea then
        AKYRS.SOL.draw_from_stock_to_waste(1)
    end
    if self.akyrs_double_click_wait and self.akyrs_double_click_wait > 0 and self.ability.akyrs_part_of_solitaire and self.facing == "front" then
        self.following_cards = nil
        --print("double click detected")
        --self:akyrs_calculate_following_cards()
        --AKYRS.SOL.klondike_quick_stack(self)
        self.akyrs_double_click_wait = 0
    else
        self.akyrs_double_click_wait = 2
    end
    return c
end
function SolitaireCard:update(dt)
    local c = Card.update(self,dt)
    if self.akyrs_double_click_wait then
        if self.akyrs_double_click_wait == 0 then
            
        end
        self.akyrs_double_click_wait = math.max(0, self.akyrs_double_click_wait - 0.1)
    end
    return c
end

function SolitaireCard:drag(off)
    local c = Card.drag(self,off)
    self:akyrs_calculate_following_cards()

    return c
end

function SolitaireCard:stop_drag()
    local area = self.area
    for i, k in ipairs(G.CONTROLLER.collision_list) do
        if (k:is(CardArea)) then
            if k.config.akyrs_emplace_func and k.config.akyrs_emplace_func(k, self) then
                area = k
                break
            end
        end
        
        if (k:is(Card)) and false then
            if k.area and k.area.config.akyrs_emplace_func and k.area.config.akyrs_emplace_func(k.area, self) then
                area = k.area
                break
            end
        end
    end
    if area and area ~= self.area then
        AKYRS.draw_card(self.area, area, 1, 'up', nil, self ,0)
        area:align_cards()
    end
    if area then
        area:align_cards()
    end
    self:akyrs_bring_following_cards(area)
    local c = Card.stop_drag(self)
    return c
end

function Card:akyrs_calculate_following_cards(func)
    if self.area and not self.following_cards and self.area.config.akyrs_pile_drag then
        AKYRS.reset_cardarea_bundler(self.area)
        AKYRS.recalculate_cardarea_bundler(self.area, func)
    end

    if self.following_cards then
        for i,k in ipairs(self.following_cards) do
            k.akyrs_card_held = self
            k.T.x = self.T.x
            k.T.y = self.T.y + 0.5 * i
            k.is_being_pulled = true
            k.akyrs_stay_on_top = i
        end
        if self.area then
            self.area:align_cards()
        end
    end
end
function Card:akyrs_bring_following_cards(area)
    if self.following_cards then
        for i,k in ipairs(self.following_cards) do
            if k.akyrs_card_held and k.akyrs_card_held:is(Card) then
                k.akyrs_card_held.following_cards = nil
                k.akyrs_card_held.area:remove_card(k)
                k.akyrs_card_held.area:align_cards()
            end
            
            k.akyrs_stay_on_top = nil
            k.akyrs_card_held = nil
        
            if not k.area then k.area = area end
            if not AKYRS.is_in_table(area.cards,k) then
                AKYRS.simple_event_add(
                    function ()
                        area:emplace(k)
                        return true
                    end, 0
                )
            end
            k.following_cards = nil
            k.is_being_pulled = false
        end
        self.following_cards = nil
        
    end
end