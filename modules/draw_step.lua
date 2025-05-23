
if SMODS.DrawStep then
    
    SMODS.DrawStep{
        key = "extras",
        order = 50,
        func = function (card, layer)
            AKYRS.aikoyori_draw_extras(card,layer)
        end,
        conditions = { vortex = false, facing = 'front' },
    }
    local old_draw_step_front = SMODS.DrawSteps.front.func
    SMODS.DrawStep:take_ownership('front', {
      func = function(self, layer)
        if not self.is_null then
            old_draw_step_front(self,layer)
        else
            self.children.front = nil
        end
      end,
    })
end