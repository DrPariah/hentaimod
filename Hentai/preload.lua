require("./data/mods/Hentai/lua/util")
require("./data/mods/Hentai/lua/const")
require("./data/mods/Hentai/lua/activity")
require("./data/mods/Hentai/lua/monattack")
require("./data/mods/Hentai/lua/anthro")
require("./data/mods/Hentai/lua/special_event")

local is_love_sex			--愛のある行為かどうか

--[[monsterのspeciesが"CUBI"かどうか判定する]]--
function is_cubi(monster)
	DEBUG.add_msg("monster:"..monster:disp_name())

	local mtype = monster.type
	DEBUG.add_msg("mtype:"..mtype:nname())

	if (mtype:in_species(species_id("CUBI"))) then
		return true
	end

	return false
end

--[[貞操を失う処理]]--
function lost_virgin(me, is_good)

	if not(me:has_trait(trait_id("VIRGIN"))) then
		return
	end
	
	if (is_good) then
		add_msg(me:disp_name().." has lost "..pro(me, "his").." Chastity!", H_COLOR.LIGHT_GREEN)
	else
		add_msg(me:disp_name().." has been robbed of "..pro(me, "his").." Chastity!", H_COLOR.RED)
	end

	me:unset_mutation(trait_id("VIRGIN"))

end

--[[妊娠判定]]--
function preg_roll(mother)
	--TODO:need more improve

	local preg_chance = PREG_CHANCE

	--発情中なら基礎妊娠確立を+500
	if (mother:has_effect(efftype_id("estrus"))) then
		preg_chance = preg_chance + 500
	end
	--避妊中なら最終的な妊娠確立を/100
	if (mother:has_effect(efftype_id("contraception"))) then
		preg_chance = preg_chance / 100
	end

	DEBUG.add_msg("preg_chance:"..preg_chance)

	if (math.random(100) <= preg_chance) then
		return true
	else
		return false
	end
end

--[[避妊具のiuse処理]]--
function iuse_yiff(item, active)

	--隣接するキャラクタを選択、取得する。
	local center = player:pos()
	local selected_x, selected_y = game.choose_adjacent("Choose the target direction.", center.x, center.y)
	local selected_point = tripoint(selected_x, selected_y, center.z)

	local someone = g:critter_at(selected_point)

	if (someone == nil) then
		game.add_msg("There is no one in that direction.")
		return
	end

	DEBUG.add_msg(someone:disp_name())

	if (someone:is_monster()) then
		if (someone:has_effect(efftype_id("pet"))) then
			if (game.query_yn("Do you want to enjoy yourself with "..someone:disp_name().."?")) then
				--TODO:monsterが相手の場合の処理を考えてない
				do_sex(nil, item)
			else
				return
			end
		else
			game.add_msg("Stop that.")
			return
		end

	elseif (someone:is_player()) then
		if (game.query_yn("Use it on yourself?")) then
			do_sex(nil, item)
		else
			return
		end

	elseif (someone:is_npc()) then
		--HACK:変数someoneはCritterクラスなのでnpcクラスを再取得してやる
		--local partner = g:npc_at(someone:pos())
		local partner = game.get_npc_at(someone:pos())
		DEBUG.add_msg("id:"..partner:getID())

		local menu = game.create_uimenu()
		local choice = -1

		--パートナーに対して*交渉*を行う。
		menu.title = "Choose Action"

		menu:addentry("Never mind.")									--choice 0
		menu:addentry("How about we have fun together?")							--choice 1

		menu:query(true)
		choice = menu.selected

		if (choice == 0) then
			return

		elseif (choice == 1) then
			local is_accept
			is_accept, item = is_accept_u(partner, item)

			if (is_accept) then
				do_sex(partner, item)
			end

		else
			return
		end

	else
		game.add_msg("ERROR!")
		return
	end


	return
end

--[[パートナーが行為を受け入れてくれるかどうかの判定]]--
function is_accept_u(partner, device)
	local is_accept = false

	local willing

	--行為に対するパートナーの積極性・好感度・恐怖度をそれぞれ取得。
	willing = get_willing(partner)

	if (willing > 50) then
		if (is_love_sex) then
			game.popup("Your partner has responded with a great joy.")

			--愛がある場合のみ[積極性]％の確立でゴムなしの行為を提案してくる。
			if (math.random(100) <= willing) then
				--TODO:仮にも万人の目に留まる可能性のあるゲームなのだから、本番行為を匂わすメッセージを軽々しく出すのは慎むべき。少なくともオプションで選択できるようにすべき。　と俺の理性が言ってる
				if (game.query_yn("Seems like "..partner:get_name().." wants to enjoy it raw without the contraception.  Accept?")) then
					device = nil
				end
			end

		else
			game.popup(partner:get_name().." is so terrified of you that "..pro(partner, "he").." will follow your word without a question...")
		end
		is_accept = true

	elseif (willing > 25) then
		if (is_love_sex) then
			game.popup("Your partner has agreed, albeit looking somewhat embarrassed.")
		else
			game.popup(partner:get_name().." is too afraid to refuse you...")
		end

		is_accept = true
	elseif (willing > 0) then
		game.popup("You got turned down politely.")
	else
		game.popup("You were met with a rough refusal.")
	end

	return is_accept, device
end

--[[行為に対するパートナーの積極性を取得する]]--
--TODO:いい感じに積極性の範囲を考える。
--ステータスALL8の@が初期シェルターNPCに話しかけた場合、player:talk_skill()は16, player:intimidation()は10を返す。
function get_willing(partner)
	DEBUG.add_msg("partner:"..partner:get_name())

	--パートナーが敵なら絶対に失敗する。
	if (partner:is_enemy()) then
		return -999, 0, 0
	end

	local willing

	--==プレイヤーに対する好感度・恐怖度を取得する。==--

	--プレイヤーに対する好感の第一印象を取得する。イケメンや話術Skillが高いやつはモテる。
	local trust = player:talk_skill()

	--プレイヤーに対する恐怖感の第一印象を取得する。筋肉教や人を喰うようなやつはコワい。
	local fear = player:intimidation()

	DEBUG.add_msg("trust:"..trust)
	DEBUG.add_msg("fear:"..fear)

	--パートナーの持つ印象度を計算。超適当--
	local opinion = partner.op_of_u
	DEBUG.add_msg("opinion:"..opinion.value)

	--(信頼 * 2) + 価値 - (怒り / 2)を好感度にプラス。
	trust = trust + (opinion.trust * 2) + opinion.value - (opinion.anger / 2)
	--(恐怖 * 2) + (恩義 / 2)を恐怖感にプラス。
	fear = fear + (opinion.fear * 2) + (opinion.owed / 2)

	DEBUG.add_msg("trust_op:"..trust)
	DEBUG.add_msg("fear_op:"..fear)

	--==特質やステータス異常に応じてさらに計算
	--状態異常"drunk"があるならtrustをちょっとだけ上げ、fearをちょっとだけ下げる。倍率は適当
	if (partner:has_effect(efftype_id("drunk"))) then
		trust = trust * 1.2
		fear = fear * 0.8
	end

	--状態異常"estrus"があるならtrust3倍、fear1/3。倍率は適当
	if (partner:has_effect(efftype_id("estrus"))) then
		trust = trust * 3.0
		fear = fear / 3
	end

	--その積極性は好感からか？あるいは恐怖からか？高い方を採用する。
	if (trust >= fear) then
		willing = trust
		is_love_sex = true
	else
		willing = fear
		is_love_sex = false
	end

	--状態異常"corrupt"があるなら強度 * 5をwillingにプラス。倍率は適当
	if (partner:has_effect(efftype_id("corrupt"))) then
		local intensity = partner:get_effect_int(efftype_id("corrupt"))
		willing = willing + intensity * 5
	end

	--特性"VIRGIN"があるならwillingを-30。
	if (partner:has_trait(trait_id("VIRGIN"))) then
		willing = willing - 30
	end

	DEBUG.add_msg("willing:"..willing)

	return willing

end

--[[気持ちいいことの処理]]--
function do_sex(partner, device)

	local pseudo_device

	--pseudo_device = device	--NOTE:ここで受け取るdeviceはたぶんポインタ？なのでそのままグローバルにぶっこむとアクティビティ終了処理にて正しく読み取れない。
								--     ので新しいitemに変換しておく
	if not(device == nil) then
		pseudo_device = item(device)
	else
		pseudo_device = nil
	end

	--行為にかかるターン数を算出。プレイヤーの耐久力(筋力)が多いほどフィニッシュまでの時間が長い。
	local turn_cost = SEX_BASE_TURN * player.str_cur

	--最大ターン数を超えた場合は調整する。でないと成長modとかで筋肉教になった@さんは死ぬまでやってしまうので...
	if (turn_cost > SEX_MAX_TURN) then
		turn_cost = SEX_MAX_TURN
	end

	DEBUG.add_msg("turn_cost:"..turn_cost)

	--行為による意欲ボーナスを算出。

	--単純にプレイヤーかパートナーの器用さで大きい方。単純すぎ？
	local fun_base = player.dex_cur
	if not(partner == nil) then
		if (player.dex_cur < partner.dex_cur) then
			fun_base = partner.dex_cur
		end
	end

	DEBUG.add_msg("fun_base:"..fun_base)

	local sex_fun_bonus
	sex_fun_bonus = fun_base / 2

	--行為のアクティビティ開始。
	SEX.init(sex_fun_bonus, partner, pseudo_device, is_love_sex)
	player:assign_activity(activity_id("ACT_SEX"), turn_cost * player:get_speed() + 1000, 0, 0, "")	--ターン数*プレイヤーの速度にすることで時間ちょうどのmovecostを求められる

	game.add_msg("<color_pink>*Wait a moment please...*</color>")

	--パートナーがいる場合のみ貞操を失う。
	if not(partner == nil) then
		lost_virgin(player, true)
		lost_virgin(partner, true)
	end
end

--[[降魔のチョーカーのiuse処理]]--
function iuse_pet_cubi(item, active)
	--隣接するキャラクタを選択、取得する。
	local center = player:pos()
	local selected_x, selected_y = game.choose_adjacent("Choose the target direction.", center.x, center.y)
	local selected_point = tripoint(selected_x, selected_y, center.z)

	local monster = game.get_monster_at(selected_point)

	if (monster == nil) then
		game.add_msg("That's impossible.")
		return
	end

	if not(is_cubi(monster)) then
		game.add_msg("You can only use this on a Demon.")
		return
	end

	if (monster.friendly == -1) then
		game.add_msg("Target is already your Pet.")
		return
	end

	if (monster.friendly > 0) then
		game.add_msg("You manage to take "..monster:disp_name().." by surprise and put on a choker on "..pro(monster, "him").."!")

		monster.friendly = -1
		monster:add_effect(efftype_id("pet"), game.get_time_duration(1), "num_bp", true)
		monster:disable_special("WIFE_U")

		game.add_msg(monster:disp_name().." has become your Pet!")

		--プレイヤーの所持品からアイテムを取り除き、モンスターに渡す。
		if (player:has_item(item)) then
			monster:add_item(item)
			player:i_rem(item)
		end
	else
		game.add_msg("You try to put a choker on "..monster:disp_name()..", however "..pro(monster, "he").." resisted the attempt.  Perhaps if "..pro(monster, "he").." wasn't so alert you could've caught "..pro(monster, "him").." off guard...")
	end

end

--[[性転換の霊薬のiuse処理]]--
function iuse_ts_elixir(item, active)

	DEBUG.add_msg("--TRANS--")

	--TODO:LUA拡張iuse処理にてアイテムの使用者を取得する方法を考える
	local target = player

	DEBUG.add_msg(target:disp_name())

	--使用者が妊娠中なら効果は無い。行き場所が無くなっちゃうので
	if (target:has_effect(efftype_id("fertilize")) or target:has_effect(efftype_id("pregnantcy"))) then
		game.add_msg(target:disp_name().." drank the medicine but it had no effect.")

		if (player:has_item(item)) then
			player:i_rem(item)
		end

		return
	end

	target:mod_pain(math.random(200))
	--do we assume (((target))) is (you) for now?
	if (target.male) then
		target.male = false
		add_msg("A sharp pain assails your groin!  You quickly reach down for it without thinking, only to find out that something important that once belonged to you is no longer there!", H_COLOR.YELLOW)
		add_msg(target:disp_name().." is now a woman!", H_COLOR.GREEN)
	else
		target.male = true
		add_msg("A sharp pain assails your groin!  You quickly reach down for it without thinking, only to find out that something that doesn't belong to you is growing there!", H_COLOR.YELLOW)
		add_msg(target:disp_name().." is now a man!", H_COLOR.GREEN)
	end

	if (player:has_item(item)) then
		player:i_rem(item)
	end

	return
end

--[[名前の巻物のiuse処理]]--
function iuse_naming_npc(item, active)

	DEBUG.add_msg("--NAMING--")

	--隣接するキャラクタを選択、取得する。
	local center = player:pos()
	local selected_x, selected_y = game.choose_adjacent("Choose the target direction.", center.x, center.y)
	local selected_point = tripoint(selected_x, selected_y, center.z)

	--local someone = g:npc_at(selected_point)
	local someone = game.get_npc_at(selected_point)

	if (someone == nil) then
		game.add_msg("There is no one in that direction.")
		return
	end
	if not(someone:is_npc()) then
		game.add_msg("You can only use this on NPC.")
		return
	end

	DEBUG.add_msg("someone:"..someone:disp_name())

	--入力ウィンドウを表示し、入力された内容を取得する。
	local newname = game.string_input_popup("Input a new name.", 0, "")
	if (newname == "") then
		game.add_msg("Name input canceled.")
		return
	end
	DEBUG.add_msg("newname:"..newname)

	--show old name -> new name type of thing
	local oldname = someone.name
	someone.name = newname
	game.add_msg(oldname.." has been given a new name: "..newname..".")

	if (player:has_item(item)) then
		player:i_rem(item)
	end

	return
end

--[[血清(人間)のiuse処理]]--
function iuse_anthromorph(item, active)

	DEBUG.add_msg("--ANTHRO--")

	--隣接するキャラクタを選択、取得する。
	local center = player:pos()
	local selected_x, selected_y = game.choose_adjacent("Choose the target direction.", center.x, center.y)
	local selected_point = tripoint(selected_x, selected_y, center.z)

	local monster = game.get_monster_at(selected_point)

	if (monster == nil) then
		game.add_msg("There is no one in that direction.")
		return
	end
	if not(monster:is_monster()) then
		game.add_msg("That's impossible.")
		return
	end
	if (monster.friendly > -1) then
		game.add_msg("You can only use this on a Pet.")
		return
	end

	ANTHRO.main(monster, selected_point)

	if (player:has_item(item)) then
		player:i_rem(item)
	end

	player:mod_moves(-200)

	return
end

--[[アーティファクト生成のiuse処理]]--
function iuse_spawn_artifact(item, active)

	DEBUG.add_msg("--SPAWN_ARTIFACT-- start")

	map:spawn_artifact(player:pos())

	game.add_msg("For a moment you were seized with a strange feeling as if the world just got distorted.")

	if (player:has_item(item)) then
		player:i_rem(item)
	end

	player:mod_moves(-100)

	DEBUG.add_msg("--SPAWN_ARTIFACT-- end")

	return
end

function on_preload()
	-- 乱数の初期化
	math.randomseed(os.time())

	--[[iuse処理の追加]]--
	--game.register_iuse("IUSE_YIFF", iuse_hoge)
	game.register_iuse("IUSE_YIFF", iuse_yiff)
	game.register_iuse("IUSE_PET_CUBI", iuse_pet_cubi)
	game.register_iuse("IUSE_TS_ELIXIR", iuse_ts_elixir)
	game.register_iuse("IUSE_NAMING_NPC", iuse_naming_npc)
	game.register_iuse("IUSE_ANTHROPOMORPH", iuse_anthromorph)
	game.register_iuse("IUSE_SPAWN_ARTIFACT", iuse_spawn_artifact)

	--[[activity処理の追加]]--
	--game.register_activity_do_turn("ACT_SEX", SEX.act_sex_do_turn)
	--game.register_activity_finish("ACT_SEX", SEX.act_sex_finish)

	--[[モンスター特殊攻撃の追加]]--
	game.register_monattack("VULGAR_SPEECH", matk_vulgar_speech)
	game.register_monattack("SEDUCE", matk_seduce)
	game.register_monattack("THROW_KISS", matk_tkiss)
	game.register_monattack("STRIP_U", matk_stripu)
	game.register_monattack("WIFE_U", matk_wifeu)
	game.register_monattack("LOVE_FLAME", matk_loveflame)
	game.register_monattack("EXPOSE", matk_expose)
	game.register_monattack("MAGIC_SUCCUBI_SOMNO", matk_magic_succubi_somnophilia)
	game.register_monattack("MAGIC_GOATHEAD_DEMON", matk_magic_goathead_demon)

	--[[ここは特別なイベント処理をモンスター特殊攻撃で擬似的に発火させる処理の追加]]
	game.register_monattack("EVENT_GOATHEAD_DEMON", event_goathead_demon)
	game.register_monattack("EVENT_DEMONBEING_SCHOOLGIRL", event_demonbeing_schoolgirl)
end

on_preload()