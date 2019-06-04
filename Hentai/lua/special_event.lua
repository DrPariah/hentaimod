--[[山羊頭の悪魔のイベント]]--
function event_goathead_demon(monster)
	local someone = monster:attack_target()

	--相手がいなければ何もしない。
	if (someone == nil) then
		return
	end
	--姿がプレイヤーに見えていなければ何もしない。相手に姿を見せてから名乗りをあげないとただの変な奴だし。
	if not(player:sees(monster:pos())) then
		return
	end

	--イベント発生用の特殊攻撃を無効化する。
	monster:disable_special("EVENT_GOATHEAD_DEMON")

	--TALK
	if (player:get_value(EVENT_GOATHEAD_DEMON)  == "met") then
		--会ったフラグがある場合のセリフ。激おこ。
		game.popup("「・・・貴様は！おのれ、一体どれだけ我等の邪魔をすれば気が済むのだ！\r\n貴様だけは絶対に許さん！ただ嬲り殺すだけでは飽き足らぬ、地獄の底で永遠の責め苦を与えてやる！」")

	else
		--会ったフラグが無い場合のセリフ。
		game.popup("「これはこれは・・・何やら騒々しいとは思ったが、無関係の人間が現れるとは。\r\n英雄気取りか、好奇心に誘われたか・・・どちらにせよ愚か者には変わりあるまい。」")
		game.popup("「このサバトは我等悪魔が地上を手中に収めんが為の重要な儀。\r\n貴様が何者かは知らんが、邪魔されるわけにはいかぬ。\r\n貴様には此処で死んでもらう。」")

		if (player.male) then
			game.popup("「案ずるな。貴様の魂を奪った後は、我が配下の悪魔として生まれ変わらせてやろう！\r\nハーッハッハッ！」")
		else
			game.popup("「よくよく見れば中々の上玉、活力に満ちた肉体の持主よ。\r\nよろしい、貴様の魂を奪った後は、我がサバトの贄として存分に利用してやろう！\r\nハーッハッハッ！」")
		end

		--会ったフラグを立てる。
		player:set_value(EVENT_GOATHEAD_DEMON, "met")
	end

	--周囲にある魔法陣を起動する。
	local locs = get_around_locs(monster:pos(), 0, 10)
	for key, value in pairs(locs) do
		--DEBUG.add_msg("point.x:"..value.x)
		--DEBUG.add_msg("point.y:"..value.y)

		magic_circle_fire(value, 3, 30)
		magic_circle_summon(value, MON_ARCH_CUBI_LIST)
	end

	monster:mod_moves(-100)

end

--[[NPC"demonbeing_schoolgirl"を呼び出すイベント]]--
--[[
	NOTE:NPCを配置する場合、そのNPCにユニーク名称を付けなければ性別を固定することができない。
	しかしそうすると同一人物が複数存在する事になってしまう...そのため、「その人物に会った事があるかあるかどうか」をフラグとして管理し、
	会っていない場合はNPCを生成、既に会っている場合はモンスターを生成する仕様にする。
]]--
function event_demonbeing_schoolgirl(monster)

	--イベント発火地点を保持しておく。(ダミーモンスターを消すとnil参照で落ちるため)
	local tripoint = monster:pos()

	--なんかよくわからないけど、プレイヤーとの距離が離れすぎているとアボートするっぽい？ので、プレイヤーが近くにいない場合は処理を抜ける。
	local dist = game.distance(tripoint.x, tripoint.y, player:posx(), player:posy())		--line.cppを参照。
	if (dist > 10) then
		--DEBUG.add_msg("Out of range.")
		return
	end

	--ダミーモンスターは消す。
	g:remove_zombie(monster)

	if (player:get_value(EVENT_DEMONBEING_SCHOOLGIRL)  == "met") then
		--既に会ってる場合はモンスターを生成。
		local mon = game.create_monster(mtype_id("mon_corrupted_schoolgirl"), tripoint)

	else
		--まだ会ってない場合はNPCを生成。
		local npc_id = map:place_npc(tripoint.x, tripoint.y, npc_template_id("demonbeing_schoolgirl"))

		--会ったフラグを立てる。
		player:set_value(EVENT_DEMONBEING_SCHOOLGIRL, "met")
	end

end
