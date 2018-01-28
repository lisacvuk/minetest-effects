effects_api = {}

effects_api.registered_effects = {}

effects_api.register_effect = function(definition)
	local name = definition.name
	
	if not effects_api.registered_effects[name] then
		effects_api.registered_effects[name] = definition
	end
end

effects_api.give_effect_to_player = function(effect_n, name)
	local player = minetest.get_player_by_name(name)
	local effect = effects_api.registered_effects[effect_n]
	local current_effects = minetest.deserialize(player:get_attribute("effects_api:effects")) or {}
	
	current_effects[effect.name] = effect.duration

	player:set_attribute("effects_api:effects", minetest.serialize(current_effects))
end
effects_api.remove_effect_to_player = function(effect_n, name)
    local player = minetest.get_player_by_name(name)
	local effect = effects_api.registered_effects[effect_n]
	local current_effects = minetest.deserialize(player:get_attribute("effects_api:effects")) 
    current_effects[effect_n] = nil
    player:set_attribute("effects_api:effects", minetest.serialize(current_effects))
end
effects_api.register_effect({
	name = "test",
    duration = 10,
	on_loop = function(name, duration, dtime)
		minetest.chat_send_all("Duration: " .. duration)
        return duration - dtime
	end
})
minetest.register_globalstep(function(dtime)
	for _,player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local current_effects = minetest.deserialize(player:get_attribute("effects_api:effects"))
		--minetest.chat_send_all(dump(current_effects))
		for effect_name,effect in pairs(current_effects) do
            --print(dump(current_effects))
            local new_duration = effects_api.registered_effects[effect_name].on_loop(name, effect, dtime)
            if new_duration < 0 then
                effects_api.remove_effect_to_player(effect_name, name)
                return
            else
                current_effects[effect_name] = new_duration
            end
		end
        player:set_attribute("effects_api:effects", minetest.serialize(current_effects))
	end
end)
minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	effects_api.give_effect_to_player("test", name)
end)
