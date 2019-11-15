dofile("data/scripts/lib/utilities.lua")
dofile("data/scripts/gun/gun_enums.lua")
dofile("mods/anvil_of_destiny/files/scripts/wand_utils.lua")
dofile("mods/anvil_of_destiny/files/scripts/wand_buff.lua")
dofile("mods/anvil_of_destiny/files/entities/anvil/anvil.lua")
dofile("mods/anvil_of_destiny/config.lua")
dofile("mods/anvil_of_destiny/files/scripts/utils.lua")
dofile("mods/anvil_of_destiny/lib/StringStore/stringstore.lua")
dofile("mods/anvil_of_destiny/lib/StringStore/noitavariablestore.lua")
-- dofile("data/scripts/lib/coroutines.lua")

function init_state()
  local entity_id = GetUpdatedEntityID()
  local STATE_STORE = stringstore.open_store(stringstore.noita.variable_storage_components(entity_id))
  if g_collider_ticks == nil then
    g_collider_ticks = {}
  end
  if g_collider_ticks[entity_id] == nil then
    g_collider_ticks[entity_id] = 0
  end
  if STATE_STORE.wands_sacrificed == nil then
    STATE_STORE.wands_sacrificed = 0
    STATE_STORE.tablets_sacrificed = 0
    STATE_STORE.first_wand_tag = nil
    STATE_STORE.second_wand_tag = nil
  end
end

function get_state()
  local entity_id = GetUpdatedEntityID()
  local STATE_STORE = stringstore.open_store(stringstore.noita.variable_storage_components(entity_id))
  return STATE_STORE
end

function collision_trigger(colliding_entity_id)
  local entity_id = GetUpdatedEntityID()
  init_state()
  g_collider_ticks[entity_id] = g_collider_ticks[entity_id] + 1
  -- while something is colliding, do our own custom "collision" check 10 times per second, to get ALL items instead of just one
  if g_collider_ticks[entity_id] % 6 == 0 then
    local x, y = EntityGetTransform(entity_id)
    local wands = EntityGetInRadiusWithTag(x, y - 30, 30, "wand")
    for i, v in ipairs(wands) do
      -- Check if wand is dropped on the floor
      if EntityGetParent(v) == 0 then
        get_state().wands_sacrificed = get_state().wands_sacrificed + 1
        local tag = hide_wand(v)
        if get_state().wands_sacrificed == 1 then
          get_state().first_wand_tag = tag
        else
          get_state().second_wand_tag = tag
        end
        
        if get_state().tablets_sacrificed <= 1 and get_state().wands_sacrificed == 1 then
          EntitySetComponentsWithTagEnabled(entity_id, "emitter1", true)
          GamePlaySound("mods/anvil_of_destiny/fmod/Build/Desktop/my_mod_audio.snd", "snd_mod/jingle", x, y)
        elseif get_state().tablets_sacrificed == 2 and get_state().wands_sacrificed == 1 then
          EntitySetComponentsWithTagEnabled(entity_id, "emitter2_powered", true)
          path_two(entity_id, x, y)
        elseif get_state().wands_sacrificed == 2 then
          EntitySetComponentsWithTagEnabled(entity_id, "emitter2", true)
          path_one(entity_id, x, y)
        end
      end
    end

    local tablets = EntityGetInRadiusWithTag(x, y - 30, 30, "tablet")
    for i, v in ipairs(tablets) do
      if EntityGetParent(v) == 0 then
        if get_state().tablets_sacrificed < 2 then
          EntityKill(v)
          get_state().tablets_sacrificed = get_state().tablets_sacrificed + 1
          GamePlaySound("mods/anvil_of_destiny/fmod/Build/Desktop/my_mod_audio.snd", "snd_mod/jingle", x, y)
        end
        if get_state().tablets_sacrificed == 1 then
          EntitySetComponentsWithTagEnabled(entity_id, "emitter_base_powered_up", true)
        elseif get_state().tablets_sacrificed == 2 then
          if get_state().wands_sacrificed == 0 then
            EntitySetComponentsWithTagEnabled(entity_id, "emitter1_powered", true)
          else
            EntitySetComponentsWithTagEnabled(entity_id, "emitter1", false)
            EntitySetComponentsWithTagEnabled(entity_id, "emitter1_powered", true)
            EntitySetComponentsWithTagEnabled(entity_id, "emitter2_powered", true)
            path_two(entity_id, x, y)
          end
        elseif get_state().tablets_sacrificed == 3 then
          -- TODO: Explode!?
        end
      end
    end
  end
end
-- Two wands
function path_one(entity_id, x, y)
  local shuffle = false
  if config_can_generate_shuffle_wands then
    if Random() < 0.5 then
      shuffle = true
    end
  end
  local stored_wand_id1 = EntityGetWithTag(get_state().first_wand_tag)[1]
  local stored_wand_id2 = EntityGetWithTag(get_state().second_wand_tag)[1]
  local success, new_wand_id = pcall(function()
    -- TODO: Add permaspell count and shuffle parameter
    local buff_amount = config_regular_wand_buff_percent / 100
    return combine_two_wands(stored_wand_id1, stored_wand_id2, buff_amount, x, y)
  end)
  if not success then
    -- If the call was not successful, new_wand_id contains the error message
    print(new_wand_id)
  end
  EntityKill(stored_wand_id1)
  EntityKill(stored_wand_id2)
  local always_cast_spells_count = wand_get_attached_spells_count(new_wand_id)
  if get_state().tablets_sacrificed == 1 and always_cast_spells_count == 0 then
    local level = wand_compute_level(new_wand_id)
    local random_action = get_random_action(level, 1, 1, 1, x + y)
    wand_add_spell(new_wand_id, random_action, true)
  end
  wand_restore_to_unpicked_state(new_wand_id, x, y)
  finish(entity_id, x, y)
end
-- 2 Tablet + 1 Wand
function path_two(entity_id, x, y)
  buff_stored_wand_and_respawn_it(entity_id, x, y)
  finish(entity_id, x, y)
end
-- Happens in path_two, buff a wand by a lot
function buff_stored_wand_and_respawn_it(entity_id, x, y)
  local stored_wand_id = EntityGetWithTag(get_state().first_wand_tag)[1]
  local success, new_wand_id = pcall(function()
    local buff_amount = config_improved_wand_buff_percent / 100
    return wand_buff(stored_wand_id, buff_amount, nil, x, y)
  end)
  if not success then
    -- If the call was not successful, new_wand_id contains the error message
    print(new_wand_id)
  end
  
	local props = wand_get_properties(stored_wand_id)
	-- Increase slots by 1 for each 4 slots
	local capacity_old = props.gun_config.deck_capacity
	props.gun_config.deck_capacity = props.gun_config.deck_capacity + math.ceil(props.gun_config.deck_capacity / 4)
	-- Limit capacity to 26 or the old capacity, we don't want to reduce the capacity in case the wand already had more slots to begin with
	props.gun_config.deck_capacity = math.min(math.max(26, capacity_old), props.gun_config.deck_capacity)
	wand_set_properties(stored_wand_id, props)

  EntityRemoveTag(stored_wand_id, get_state().first_wand_tag)
  wand_restore_to_unpicked_state(stored_wand_id, x, y)
end
-- Play fanfare and make anvil un-reusable
function finish(entity_id, x, y)
  -- TODO: Dont remove collision trigger but instead luacomp?
  GameScreenshake(20, x, y)
  GamePrintImportant("A gift from the gods", "")
  GamePlaySound("mods/anvil_of_destiny/fmod/Build/Desktop/my_mod_audio.snd", "snd_mod/fanfare", x, y)
  edit_component(entity_id, "AudioLoopComponent", function(comp, vars)
    EntityRemoveComponent(entity_id, comp)
  end)
  edit_all_components(entity_id, "CollisionTriggerComponent", function(comp, vars)
    EntityRemoveComponent(entity_id, comp)
  end)
end
-- "Hides" a wand by removing it's visible components and add a unique tag to it, so we can later retrieve it with EntityGetWithTag
-- Returns the tag added
function hide_wand(wand_id)
  -- teleport the wand 200 pixels above the anvil, and disable all components that make it visible
  local anvil_id = GetUpdatedEntityID()
  local x, y = EntityGetTransform(wand_id)
  -- Add a tag to the wand so we can get it anytime, even after a game relaunch
  local unique_tag = generate_unique_id(8, x, y)
  EntityAddTag(wand_id, unique_tag)
  EntitySetTransform(wand_id, x, y - 200)
  -- Disable physics to keep it floating
  edit_component(wand_id, "SimplePhysicsComponent", function(comp, vars)
    EntitySetComponentIsEnabled(wand_id, comp, false)
  end)
  edit_component(wand_id, "ItemComponent", function(comp, vars)
    EntitySetComponentIsEnabled(wand_id, comp, false)
  end)
  edit_component(wand_id, "SpriteComponent", function(comp, vars)
    EntitySetComponentIsEnabled(wand_id, comp, false)
  end)
  edit_component(wand_id, "LightComponent", function(comp, vars)
    EntitySetComponentIsEnabled(wand_id, comp, false)
  end)
  return unique_tag
end
