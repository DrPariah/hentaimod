--[[ペットのNPC化に関する処理系統]]--

ANTHRO = {
	--[[定数系]]--

	--[[ペットのNPC化時に表示する性別選択リスト]]--
	ANTHRO_PET_SEX_SUFFIX_LIST = {
		TITLE = "ところで、このペットの性別は？",
		LIST_ITEM = {
			{"オスです。", "_male"},
			{"メスです。", "_female"}
		}
	},

	--[[ペットのNPC化時に表示する変化系統]]--
	ANTHRO_PET_PATTERN = {
		--[[犬系]]--
		CANINE = {
			--[[オスメスの性別選択を行うかどうか]]--
			HAS_SEX_SUFFIX = true,
			--[[容姿の選択リストのタイトル]]--
			TITLE = "外見の好みは？",
			--[[容姿の選択リスト]]--
			PERSONAL_LIST = {
				{"ほぼ人間", "anthro_canine_morehuman"},
				{"半々程度", "anthro_canine_half"},
				{"ほぼ動物", "anthro_canine_lesshuman"}
			}
		},
		--[[猫系]]--
		FELINE = {
			HAS_SEX_SUFFIX = true,
			TITLE = "外見の好みは？",
			PERSONAL_LIST = {
				{"ほぼ人間", "anthro_feline_morehuman"},
				{"半々程度", "anthro_feline_half"},
				{"ほぼ動物", "anthro_feline_lesshuman"}
			}
		},
		--[[熊系]]--
		URSINE = {
			HAS_SEX_SUFFIX = true,
			TITLE = "外見の好みは？",
			PERSONAL_LIST = {
				{"ほぼ人間", "anthro_ursine_morehuman"},
				{"半々程度", "anthro_ursine_half"},
				{"ほぼ動物", "anthro_ursine_lesshuman"}
			}
		},
		--[[サキュバス系]]--
		SUCCUBI = {
			HAS_SEX_SUFFIX = false,
			TITLE = "外見の好みは？",
			PERSONAL_LIST = {
				{"ほぼ人間", "anthro_succubi_morehuman"},
				{"わりと悪魔", "anthro_succubi_lesshuman"}
			}
		},
		--[[インキュバス系]]--
		INCUBI = {
			HAS_SEX_SUFFIX = false,
			TITLE = "外見の好みは？",
			PERSONAL_LIST = {
				{"ほぼ人間", "anthro_incubi_morehuman"},
				{"わりと悪魔", "anthro_incubi_lesshuman"}
			}
		}
	}

}



--[[メイン処理]]--
ANTHRO.main = function(monster, selected_point)
	--TODO:リストメニューの選択がちょっとやっつけになっちゃってるのでそのうち見直す

	--NPC化の変化系統を取得する。
	local anthro_pet_pattern = ANTHRO.get_anthro_pet_pattern(monster)

	--リストが無ければ（変化先がなければ）キャンセル。
	if (anthro_pet_pattern == nil) then
		game.add_msg("この生物をNPC化する事はできません。")
		return
	end

	if not(game.query_yn("一度NPC化すると、二度と元の姿には戻せません。本当によろしいですか？")) then
		return
	end

	local npc_temp_id = ANTHRO.get_npc_temp_id(anthro_pet_pattern)

	--monsterを削除し、NPCを追加する。
	--NOTE:monsterの所持品にアイテムを追加することはできても取得することができないので、ペットに預けていたアイテムがすべて消えてしまう。
	g:remove_zombie(monster)		--こんなFunction名だけどゾンビじゃなくても消せる。

	local npc_id = map:place_npc(selected_point.x, selected_point.y, npc_template_id(npc_temp_id))
	DEBUG.add_msg("npc_id:"..npc_id)

	--TODO:本当はこの場でNPCの名前を変更したりしたいんだけど無理なので名前の巻物を与えてお茶をにごす
	local scroll = item("scroll_of_naming", 1)
	map:add_item(player:pos(), scroll)
	add_msg("あなたの足元に何かが転がってきた。", H_COLOR.GREEN)

	return

end

--[[NPC化の変化系統を取得する]]--
ANTHRO.get_anthro_pet_pattern = function(monster)

	local anthro_pet_pattern = nil

	local mtype = monster.type
	DEBUG.add_msg("mtype:"..mtype:nname())


	--"DOGFOOD"フラグを持つmonsterであれば犬系変化リスト。	この条件だと犬以外で"DOGFOOD"フラグを持つmonster（別modの野良メイドとか）でも対象になってしまう。...まあそれはそれで良し
	if (mtype:has_flag("DOGFOOD")) then
		DEBUG.add_msg("-->ANTHRO_CANINE")
		anthro_pet_pattern = ANTHRO.ANTHRO_PET_PATTERN.CANINE

	--"CATFOOD"フラグを持つmonsterであれば猫系変化リスト。
	elseif (mtype:has_flag("CATFOOD")) then
		DEBUG.add_msg("-->ANTHRO_FELINE")
		anthro_pet_pattern = ANTHRO.ANTHRO_PET_PATTERN.FELINE

	--monsterのidが"mon_bear_cub"か"mon_bear"なら熊系変化リスト。
	elseif (mtype.id == mtype_id("mon_bear_cub") or mtype.id == mtype_id("mon_bear")) then
		DEBUG.add_msg("-->ANTHRO_URSINE")
		anthro_pet_pattern = ANTHRO.ANTHRO_PET_PATTERN.URSINE

	--monsterの種族が"CUBI"の場合
	elseif (mtype:in_species(species_id("CUBI"))) then
		DEBUG.add_msg("-->ANTHRO_CUBI")

		if (mtype:in_species(species_id("FEMALE"))) then
			--種族が"FEMALE"ならサキュバス系変化リスト。
			DEBUG.add_msg("  -->...is FEMALE.")
			anthro_pet_pattern = ANTHRO.ANTHRO_PET_PATTERN.SUCCUBI

		elseif (mtype:in_species(species_id("MALE"))) then
			--種族が"MALE"ならインキュバス系変化リスト。
			DEBUG.add_msg("  -->...is MALE.")
			anthro_pet_pattern = ANTHRO.ANTHRO_PET_PATTERN.INCUBI

		else
			--その他なら...その他ってなんだ？
			DEBUG.add_msg("  -->...is WHAT?")
		end

	end


	return anthro_pet_pattern
end

--[[NPC化の変化系統パターンから変化対象のNPCのtemplateIDを取得する]]--
ANTHRO.get_npc_temp_id = function(anthro_pet_pattern)

	local pet_sex_suffix
	--変化系統パターンにてペットの性別選択の指定がある場合は選択する
	if (anthro_pet_pattern.HAS_SEX_SUFFIX) then
		pet_sex_suffix = ANTHRO.get_sex_suffix()
	else
		pet_sex_suffix = ""
	end

	local anthro_menu_list = anthro_pet_pattern.PERSONAL_LIST

	--容姿の選択リストからnpc_template_idを取得する。
	local menu = game.create_uimenu()
	menu.title = anthro_pet_pattern.TITLE

	for key, value in pairs(anthro_menu_list) do
		menu:addentry(value[1])
	end

	menu:query(true)
	choice = menu.selected

	--さっき取得したペット性別接尾語をつけておく。
	--あまりいい方法じゃないな...しかしmap:place_npcはid単位でしか指定できないのでこうでもしないと選択式にできない。定義するnpc_temp_idもn*2に増えてしまう...しかし性別の選択方式だけは絶対に譲れないジレンマ。せめてNPC生成後にLUAで干渉できれば...
	local npc_temp_id = anthro_menu_list[choice+1][2]..pet_sex_suffix
	DEBUG.add_msg("npc_temp_id:"..npc_temp_id)

	return npc_temp_id
end

ANTHRO.get_sex_suffix = function()

	--ペットの性別を選択する。
	local menu_suffix = game.create_uimenu()
	local choice = -1
	menu_suffix.title = ANTHRO.ANTHRO_PET_SEX_SUFFIX_LIST.TITLE

	for key, value in pairs(ANTHRO.ANTHRO_PET_SEX_SUFFIX_LIST.LIST_ITEM) do
		menu_suffix:addentry(value[1])
	end

	menu_suffix:query(true)
	choice = menu_suffix.selected

	local pet_sex_suffix = ANTHRO.ANTHRO_PET_SEX_SUFFIX_LIST.LIST_ITEM[choice+1][2]
	DEBUG.add_msg("pet_sex_suffix:"..pet_sex_suffix)

	return pet_sex_suffix

end
