local entity_id = GetUpdatedEntityID()
local x, y, rot, scale_x = EntityGetTransform(entity_id)
if scale_x < 0 then
  x = x - 46
else
  x = x + 46
end
y = y - 14
local hammer = EntityLoad("mods/anvil_of_destiny/files/entities/hammer_animation/hammer_animation.xml", x, y)
EntitySetTransform(hammer, x, y, 0, scale_x, 1)
EntityKill(entity_id)
