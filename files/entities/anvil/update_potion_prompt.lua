local entity_id = GetUpdatedEntityID()
local x,y = EntityGetTransform(entity_id)
dofile_once("mods/anvil_of_destiny/files/entities/anvil/anvil.lua")
local potion_bonuses = dofile_once("mods/anvil_of_destiny/files/entities/anvil/potion_bonuses.lua")

local players = EntityGetInRadiusWithTag(x, y, 11, "player_unit")


if #players > 0 then
    player = players[1]

    local anvil_id
    for i, entity in ipairs(EntityGetInRadius(x, y, 50)) do --look for associated Anvil of Destiny
        if EntityGetName(entity) == "anvil_of_destiny" then
            anvil_id = entity
            break
        end
    end
    if anvil_id == nil then print("mah fuckin' anvil-") EntityKill(entity_id) end --kill self if anvil is fake

    interact_comp = EntityGetComponent(entity_id, "InteractableComponent")
    if interact_comp == nil then return end

    local function get_material_from_matinv(target)
        local material_sucker_component = EntityGetFirstComponentIncludingDisabled(target, "MaterialSuckerComponent")
        local material_inventory_component = EntityGetFirstComponentIncludingDisabled(target, "MaterialInventoryComponent")
        if material_sucker_component and material_inventory_component then
            local material_name, material_amount = nil,0
            for material_id, amount in pairs(ComponentGetValue2(material_inventory_component, "count_per_material_type")) do
                if amount > math.max(800, material_amount) then
                    material = CellFactory_GetName(material_id - 1)
                    if is_valid_anvil_input(anvil_id, "potion", material) then
                        material_name = material
                        material_amount = amount
                    end
                end
            end
            return material_name
        end
    end


    local held_material_is_valid

    local potion_material
    local inventory_component = EntityGetFirstComponent(player, "Inventory2Component")
    if inventory_component ~= nil then

        local active_item = ComponentGetValueInt(inventory_component, "mActiveItem") --check held item
        if active_item ~= nil then
            potion_material = get_material_from_matinv(active_item)
            if potion_material ~= nil then held_material_is_valid = true end
        end

        if potion_material == nil then --if held item does not have valid material
            for index, inventory_quick in ipairs(EntityGetAllChildren(player) or {}) do
                if EntityGetName(inventory_quick) ~= "inventory_quick" then goto skip_entity end
                for index, item in ipairs(EntityGetAllChildren(inventory_quick) or {}) do
                    if item == active_item then goto skip_item end
                    potion_material = get_material_from_matinv(item)
                    if potion_material ~= nil then break end
                    ::skip_item::
                end
                do break end --break cuz we found our inventory_quick
                ::skip_entity::
            end
        end
    end



    local text
    if held_material_is_valid then
        if potion_bonuses[potion_material].custom_inspect then
            text = potion_bonuses[potion_material].custom_inspect() or "nil"
        else
            text = "$ui_AoD_interact_holding_potion"
        end
    elseif potion_material then
        text = "$ui_AoD_interact_has_potion"
    else
        text = ""
    end
    ComponentSetValue2(interact_comp[1], "ui_text", text)
end