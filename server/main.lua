if GetResourceState("rip_weed_plant") ~= 'missing' then
	if GetResourceState("ox_inventory") ~= 'missing' then
		exports.ox_inventory:RegisterShop('farmer', {
			name = 'Farmer Store',
			inventory = {
				{ name = 'water_can', price = 15 },
				{ name = 'fertilizer', price = 20 },
				{ name = 'plant_pot', price = 5 },
				{ name = 'empty_weed_bag', price = 1 },
				{ name = 'soil_bag', price = 15 },
				{ name = 'lighter', price = 10 },
			}
		})
		exports.ox_inventory:RegisterShop('seeds', {
			name = 'Seeds Dealer',
			inventory = {
				{ name = 'amnesia_seed', price = 1000 },
				{ name = 'purple_haze_seed', price = 2000 },
				{ name = 'super_silver_haze_seed', price = 1500 },
			}
		})
	elseif GetResourceState("qb-inventory") ~= 'missing' then
		local farmeritems = {
			{ name = 'water_can', amount = 500, price = 15 },
			{ name = 'fertilizer', amount = 500, price = 20 },
			{ name = 'plant_pot', amount = 500, price = 5 },
			{ name = 'empty_weed_bag', amount = 500, price = 1 },
			{ name = 'soil_bag', amount = 500, price = 15 },
			{ name = 'lighter', amount = 10, price = 10 },
		}
		local seedsitems = {
			{ name = 'amnesia_seed', amount = 50, price = 1000 },
			{ name = 'purple_haze_seed', amount = 10, price = 2000 },
			{ name = 'super_silver_haze_seed', amount = 10, price = 1500 },
		}
		exports['qb-inventory']:CreateShop({
			name = 'farmer',
			label = 'Farmer Store',
			slots = #farmeritems,
			items = farmeritems
		})
		exports['qb-inventory']:CreateShop({
			name = 'seeds',
			label = 'Seeds Dealer',
			slots = #seedsitems,
			items = seedsitems
		})
	end
end

RegisterNetEvent('rip_dialog:server:openShop', function(shop)
    local src = source
    exports['qb-inventory']:OpenShop(src, shop)
end)