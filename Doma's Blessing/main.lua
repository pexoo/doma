local firemod = RegisterMod("Doma's Blessing", 1.0);
local fire = Isaac.GetItemIdByName("Doma's Blessing");
local hasitem = false;
local enemy;
local enemytype;
local enemyvariant;
local range = 35;
local damage = true;
local FireCostume = Isaac.GetCostumeIdByPath("gfx/characters/full_head.anm2")
local firedamage = 1

--EID
if not __eidItemDescriptions then
	__eidItemDescriptions = {};
end
__eidItemDescriptions[fire] =
"+1 damage, fire tears and fire immunity.#Enemies that hurt you will burn until they die.#Does not work on bosses.";

--DAMAGE UP

function firemod:EvaluateCache(player, cacheFlags)
	if cacheFlags & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE then
		local itemCount = player:GetCollectibleNum(fire)
		local damageToAdd = firedamage * itemCount
		player.Damage = player.Damage + damageToAdd
	end
end

--FIRE TEARS

function firemod:OnEvaluateTearFlags(player, flag)
	if player:HasCollectible(fire) then
		player.TearFlags = player.TearFlags | TearFlags.TEAR_BURN
	end
end

--ENDLESS FIRE

function firemod:update()
	local player = Isaac.GetPlayer(0)
	local currentLevel = Game():GetLevel()
	local currentRoom = currentLevel:GetCurrentRoom()
	
	if damage then
		local doma = Game():GetLevel():GetStage() * 6
		local entities = Isaac.GetRoomEntities()
		for ent = 1, #entities do
			local entity = entities[ent]
			if entity.Type == enemytype and entity.Variant == enemyvariant then
				if entity.Position.X > player.Position.X - range and entity.Position.X < player.Position.X + range then
					if entity.Position.Y > player.Position.Y - range and entity.Position.Y < player.Position.Y + range then
						entity:AddBurn(EntityRef(player), 1000000000000, doma)
						break
					end
				end
			end
		end
		damage = false
	end
end


--FIRE IMMUNITY

function firemod:takingDamage(target, amount, flag, source, num)
	local player = Isaac.GetPlayer(0)
	if flag == DamageFlag.DAMAGE_FIRE and player:HasCollectible(fire) then
		return false
	else
		if player:HasCollectible(fire) then
			if target.Type == EntityType.ENTITY_PLAYER then
				if source.Type > 9 then
					if source.Entity ~= nil then
						if source.Entity:IsVulnerableEnemy() then
							enemytype = source.Type
							enemyvariant = source.Variant
							damage = true
						end
					end
				end
			end
		end
	end
end


--CALLBACKS

firemod:AddCallback(ModCallbacks.MC_POST_UPDATE, firemod.update);
firemod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, firemod.takingDamage)
firemod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, firemod.EvaluateCache)
firemod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, firemod.OnEvaluateTearFlags, CacheFlag.CACHE_TEARFLAG)
