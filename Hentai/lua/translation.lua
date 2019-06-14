--[[translation-related functions]]--

-- pronoun system because english --
function pro(obj, pronoun)
	local objPlayer = obj:is_player()
	local objMale = getGender(obj) --custom function because monsters are also subjected to this
	
    if (pronoun == "he") then
		if (objPlayer) then
			return "you"
		else
			return (objMale and pronoun or "she")
		end
    end
	if (pronoun == "his") then
		if (objPlayer) then
			return "your"
		else
			return (objMale and pronoun or "her")
		end
    end
	if (pronoun == "him") then
		if (objPlayer) then
			return "you"
		else
			return (objMale and pronoun or "her")
		end
    end
	if (pronoun == "hers") then
		if (objPlayer) then
			return "yours"
		else
			return (objMale and "his" or pronoun)
		end
    end
	if (pronoun == "himself") then
		if (objPlayer) then
			return "yourself"
		else
			return (objMale and pronoun or "herself")
		end
    end
	
	return add_msg("*Pronoun error!*", H_COLOR.RED)
end

--(you)
function ActorName(obj, youWord, themWord)
	if (themWord == nil) then --in case second args is skipped to not cause an exception
		themWord = youWord
	end
	local out = obj:disp_name() --set actor name
	local word = YouWord(obj, youWord, themWord) --set action word for actor
	
	if (youWord == "'s") then --special case
		if (obj:is_player()) then
			out = "your"
			word = nil
		else
			return out..word
		end
	end
	
	if word then
		return out.." "..word
	else
		return out
	end
end

function YouWord(obj, youWord, themWord)
	return (obj:is_player() and youWord or themWord)
end

--create speech lines during super fun time
--DOESN'T WORK WITH MONSTERS REEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
function ActorSay(topic, partner)
	--with this function and say instruction we can use json snippets here, fuck yeah
	if topic == "<fun_stuff_accept>" or topic == "<fun_stuff_shy>" then -- exceptions
		if partner:has_trait(trait_id("VIRGIN")) then --special cases for chaste ones
			if partner.male then
				topic = "<fun_stuff_partner_mvirgin>"
			else
				topic = "<fun_stuff_partner_fvirgin>"
			end
		elseif player:has_trait(trait_id("VIRGIN")) then
			if player.male then
				topic = "<fun_stuff_player_mvirgin>"
			else
				topic = "<fun_stuff_player_fvirgin>"
			end
		end
	end
	
	--return add_msg(partner:disp_name()..": "..speech_texts[math.random(#speech_texts)])
	--woohoo I can make the character actually say things wowie!
	return partner:say(topic)
end

function getGender(obj)
	if (obj:is_monster()) then --special case for monsters because fuck you apparently, they don't have gender attributes
		local mtype = obj.type
		if (mtype:in_species(species_id("FEMALE"))) then
			return nil

		elseif (mtype:in_species(species_id("MALE"))) then
			return true
			
		elseif (mtype:in_species(species_id("HERM"))) then
			return nil --count herms/futas as females for now
			
		else
			return true --other monsters are males by default
			
		end
	else
		return obj.male
	end
end