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
function lost_virgin(me, is_good, p)

	if not(me:has_trait(trait_id("VIRGIN"))) then
		return
	end

	if (is_good) then 
	--willing sex
		add_msg(me:disp_name().."は貞操を失いました！", H_COLOR.LIGHT_GREEN)
		--modded
		
		--moodlet
		-- 20 for one of a time event should be okay right?
		-- at first I thought making this pc only, but apparently npc can feel happy too so I'll let it slide
		me:add_morale(morale_type("morale_deflower_good"), 20, 0, DAYS(3), HOURS(12))
	else 
	-- rape
		add_msg(me:disp_name().."は貞操を奪われました！", H_COLOR.RED)
		
		me:add_morale(morale_type("morale_deflower_bad"), -20, 0, DAYS(3), HOURS(12))
	end
	
	--process pain, mostly female deflowering specifics
	deflower_pain(me, is_good)
	
	if me:is_player() then -- add entry for the graveyard log
		player:add_memorial_log( "貞操を"..p:disp_name().."に失った", "貞操を"..p:disp_name().."に失った" )
	end
	if p:is_player() then
		player:add_memorial_log( me:disp_name().."の貞操を取った", me:disp_name().."の貞操を取った" )
	end

	me:unset_mutation(trait_id("VIRGIN"))
end

function deflower_pain(me, is_good)
	if (getGender(me) == true) then -- currently female only
		--todo: implement male on male pain for obvious reasons? (lennyface) but then who is the taker? and do we separate anal/penile virginities? questions, questions...
		return
	end

	local deal_pain
	if (is_good) then
		deal_pain = 5
		
		if me:is_player() then
			add_msg("ちょっとだけ痛かった。", H_COLOR.LIGHT_GREEN)
		else
			add_msg(me:disp_name().."は少し不快にうずくまった。", H_COLOR.LIGHT_GREEN)
		end
	else
		deal_pain = 15
		
		if me:is_player() then
			add_msg("痛い！！", H_COLOR.RED)
		else
			add_msg(me:disp_name().."は鋭い痛みからうめき声を上げました！", H_COLOR.RED)
		end
	end

	me:mod_pain( deal_pain ) --apparently this can cause you to stop in the middle of it at will (with safe mode?)
	--groan sfx
	groan(me)
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
	local selected_point = pointAt()
	
	if (selected_point == nil) then
		return
	end

	local someone = g:critter_at(selected_point)

	if (someone == nil) then
		game.add_msg("その方向には誰もいない。")
		return
	end

	DEBUG.add_msg(someone:disp_name())
	
	--todo - same sex partners (female) will be required to have a dildo of some sort which will increase the fun amount by tiers (vibrator < strapon < double-headed dildo), dildo and strapons are non-battery items and can be stand-alone, but less satisfying without a partner, while vibrator is less suited for double use so it gets a penalty; note -  check for item: player:has_item
	--strapon item will need a new iuse, perhaps even mod vibrator iuse to gender restrict them
	--partners that both have dicks (e.g males or herms) will give you a choice as to who will be the dom and who's sub (the classic 受け-攻め type)

	if (someone:is_monster()) then
		if (someone:has_effect(efftype_id("pet"))) then
			if (game.query_yn(someone:disp_name().."と楽しみますか？")) then
				--TODO:monsterが相手の場合の処理を考えてない
				do_sex(nil, item)
			else
				return
			end
		else
			game.add_msg("やめてください。")
			return
		end

	elseif (someone:is_player()) then
		if (game.query_yn("自分に対して使いますか？")) then
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
		menu.title = "行動を選択"

		menu:addentry("何でもない。")									--choice 0
		menu:addentry("気持ちいいことしない？")							--choice 1

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
			game.popup("大喜びで応じてくれました。")

			--愛がある場合のみ[積極性]％の確立でゴムなしの行為を提案してくる。
			if (math.random(100) <= willing) then
				--TODO:仮にも万人の目に留まる可能性のあるゲームなのだから、本番行為を匂わすメッセージを軽々しく出すのは慎むべき。少なくともオプションで選択できるようにすべき。　と俺の理性が言ってる
				if (game.query_yn(partner:get_name().."は避妊具を使わずに楽しみたいようです。受け入れますか？")) then
					device = nil
				end
			end

		else
			game.popup(partner:get_name().."はあなたへの強い恐怖心により完全に服従しています...")
		end
		is_accept = true

	elseif (willing > 25) then
		if (is_love_sex) then
			game.popup("少し恥ずかしがりながらも応じてくれました。")
		else
			game.popup(partner:get_name().."はあなたへ抱く恐怖心のせいで拒否することができませんでした...")
		end

		is_accept = true
	elseif (willing > 0) then
		game.popup("やんわりと断られました。")
	else
		game.popup("激しく拒否されました。")
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
	local turnHold = turn_cost * player:get_speed() + 1000 --ターン数*プレイヤーの速度にすることで時間ちょうどのmovecostを求められる
	player:assign_activity(activity_id("ACT_SEX"), turnHold, 0, 0, "")
	game.sfx_play_activity_sound( "plmove", player.male and "fatigue_m_high" or "fatigue_f_high", game.sfx_get_heard_volume( player:pos() ) )
	if not(partner == nil) then
		partner:mod_moves(-turnHold) --hold the partner in place in case they're not followers so they won't run away
	end
	
	add_msg("*しばらくおまちください*", H_COLOR.PINK)

	--パートナーがいる場合のみ貞操を失う。
	if not(partner == nil) then
		lost_virgin(player, true, partner)
		lost_virgin(partner, is_love_sex, player) --if done by fear, obviously that's not willing
	end
end

--[[降魔のチョーカーのiuse処理]]--
function iuse_pet_cubi(item, active)
	--隣接するキャラクタを選択、取得する。
	local selected_point = pointAt()
	
	if (selected_point == nil) then
		return
	end

	local monster = game.get_monster_at(selected_point)

	if (monster == nil) then
		game.add_msg("それは無理だ。")
		return
	end

	if not(is_cubi(monster)) then
		game.add_msg("使える対象は夢魔だけです。")
		return
	end

	if (monster.friendly == -1) then
		game.add_msg("既にあなたの仲間です。")
		return
	end

	if (monster.friendly > 0) then
		game.add_msg(monster:disp_name().."の気が緩んだ一瞬の隙をついて、チョーカーを身につけさせました！")

		monster.friendly = -1
		monster:add_effect(efftype_id("pet"), game.get_time_duration(1), "num_bp", true)
		monster:disable_special("WIFE_U")

		game.add_msg(monster:disp_name().."はあなたの仲間になった！")

		--プレイヤーの所持品からアイテムを取り除き、モンスターに渡す。
		if (player:has_item(item)) then
			monster:add_item(item)
			player:i_rem(item)
		end
	else
		game.add_msg("チョーカーを"..monster:disp_name().."の首につけようとしましたが、抵抗されました。気の緩んだ隙ならばあるいは...")
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
		game.add_msg("薬を飲み干しましたが、何も効果はありませんでした。")

		if (player:has_item(item)) then
			player:i_rem(item)
		end

		return
	end

	target:mod_pain(math.random(200))
	
	--groan sfx
	groan(target)
	
	if (target.male) then
		target.male = false
		add_msg("下半身を襲った激痛に思わず手をやると、そこにあるはずのものがありませんでした！", H_COLOR.YELLOW)
		add_msg(target:disp_name().."は今や女性です！", H_COLOR.GREEN)
	else
		target.male = true
		add_msg("下半身を襲った激痛に思わず手をやると、そこには無いはずのものがありました！", H_COLOR.YELLOW)
		add_msg(target:disp_name().."は今や男性です！", H_COLOR.GREEN)
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
	local selected_point = pointAt()
	
	if (selected_point == nil) then
		return
	end

	--local someone = g:npc_at(selected_point)
	local someone = game.get_npc_at(selected_point)

	if (someone == nil) then
		game.add_msg("その方向には誰もいない。")
		return
	end
	if not(someone:is_npc()) then
		game.add_msg("使える対象はNPCのみです。")
		return
	end

	DEBUG.add_msg("someone:"..someone:disp_name())

	--入力ウィンドウを表示し、入力された内容を取得する。
	local newname = game.string_input_popup("新しい名前を入力してください。", 0, "")
	if (newname == "") then
		game.add_msg("キャンセルしました。")
		return
	end
	DEBUG.add_msg("newname:"..newname)

	someone.name = newname
	game.add_msg("『"..newname.."』と命名しました。")

	if (player:has_item(item)) then
		player:i_rem(item)
	end

	return
end

--[[血清(人間)のiuse処理]]--
function iuse_anthromorph(item, active)

	DEBUG.add_msg("--ANTHRO--")

	--隣接するキャラクタを選択、取得する。
	local selected_point = pointAt()
	
	if (selected_point == nil) then
		return
	end

	local monster = game.get_monster_at(selected_point)

	if (monster == nil) then
		game.add_msg("その方向には誰もいない。")
		return
	end
	if not(monster:is_monster()) then
		game.add_msg("それは無理だ。")
		return
	end
	if (monster.friendly > -1) then
		game.add_msg("ペット以外に使う事はできません。")
		return
	end

	local result = ANTHRO.main(monster, selected_point)

	if result ~= nil then
		if (player:has_item(item)) then
			player:i_rem(item)
		end
	end
	
	player:mod_moves(-200)

	return
end

--[[アーティファクト生成のiuse処理]]--
function iuse_spawn_artifact(item, active)

	DEBUG.add_msg("--SPAWN_ARTIFACT-- start")

	map:spawn_artifact(player:pos())

	game.add_msg("一瞬、世界が歪んだような奇妙な感覚がしました。")

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