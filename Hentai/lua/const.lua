--[[定数]]--


--[[文字のハイライト色パターン]]--
H_COLOR = {
	BLACK		= "black",
	WHITE		= "white",
	LIGHT_GRAY	= "light_gray",
	DARK_GRAY	= "dark_gray",
	RED			= "red",
	GREEN		= "green",
	BLUE		= "blue",
	CYAN		= "cyan",
	MAGENTA		= "magenta",
	BROWN		= "brown",
	LIGHT_RED	= "light_red",
	LIGHT_GREEN	= "light_green",
	LIGHT_BLUE	= "light_blue",
	LIGHT_CYAN	= "light_cyan",
	PINK		= "pink",
	YELLOW		= "yellow"
}

--[[*気持ちいいこと*中に表示されるテキスト]]--
MOVINGDOING_TEXTS = {
	"*パコパコ*",
	"『はぁはぁ』",
	"『きくぅ』",
	"『るん♪』",
	"『うふふ♪』",
	"『ねうねう♪』"
}

--[[レイダー的な敵キャラ会話のテキスト]]--
VULGAR_SPEECH_TEXTS = {
	--ターゲットを発見した時
	TARGET_ACQUIRE = {
		--[[露骨なパロディネタはいちおう自粛。
			"「地獄だ、やあ！」",
		]]--
		"「バア！」",
		"「何だ！？」",
		"「おい、敵だ！」",
		"「ハッ！見つけたぞ！」",
		"「ヒャッハー！」",
		"「頭ぁねじ切ってオモチャにしてやるぜぇ！」",
		"「ヒャッハー！新鮮なオモチャだぁ！」",
		"「ヒャッハー！新鮮な肉だぁ！」",
		"「今日は人間の肉で宴だ！」",
		"「レイプ・タァァァイム！」",
		"(狂気に満ちた笑い声)",
		"「HELL YEAH!」",
		"「地獄だ、イェア！」"
	},
	--ターゲットと交戦中
	TARGET_ENGAGE = {
		--[[露骨なパロディネタはいちおう自粛。
			"「殺しは初めてじゃないんだよ、新米！」",
			"「何百回とやってきた！そうすれば変わるだろう！？」",
			"「自分を制して、悪に徹しろ！」",
		]]--
		"「ヒャッハー！」",
		"「怖いか、えぇ？」",
		"「来いよ、おら！」",
		"「血だ！血だ！血だぁ！」",
		"「血を見せろぉ！」",
		"「犯してから殺すかぁ？殺してから犯すかぁ？...どぉぉぉっちでもいいなぁぁ！」",
		"「犯して、殺して、また犯してやるよぉ！」",
		"「助けてやってもいいぜぇ？...お前で遊び終わったらなぁ！」",
		"(狂気に満ちた笑い声)",
		"(唸り声)",
		"「くたばれ！」",
		"「このクソ...」",
		"「まだ死なねぇのか！？」",
		"「なんで死なねぇんだ！？」",
		"「殺しは初めてじゃないんだよ、ルーキー！」",
		"「人間として生きられないなら、悪魔として生きるほかねぇんだ！」"
	},
	--ターゲットを見失った時
	TARGET_LOST = {
		"(舌打ちの音)",
		"「逃げ足の速いヤツだ...」",
		"「出てこいよぉ、すぐに殺してやるからさぁ！」",
		"「隠れてないで出てこい！」",
		"「気をつけろ、まだそのへんに隠れてやがるぞ...」",
		"「逃げんじゃねーよ！」",
		"「くそっ、どこ行きやがった？」"
	}
}

--[[profession"一人と一匹"スタート時のペット選択リストまとめ]]--
PROF_PET_LIST = {
	TITLE = "あなたのペットは...",
	LIST_ITEM = {
		{
			ENTRY = "イヌだ！",
			PET_ID = "mon_dog",
			BONUS_ITEM = {"pet_carrier", "dog_whistle"}
		},
		{
			ENTRY = "ネコだ！",
			PET_ID = "mon_cat",
			BONUS_ITEM = {"pet_carrier", "can_tuna"}
		},
		{
			ENTRY = "クマだ！",
			PET_ID = "mon_bear_cub",
			BONUS_ITEM = {}
		},
		{
			ENTRY = "サキュバスだ！",
			PET_ID = "mon_succubi",
			BONUS_ITEM = {"holy_choker"}
		}
	}
}

--[[アークCUBIのmonster_idリスト。主に上位敵の召喚用に使う。]]--
MON_ARCH_CUBI_LIST = {
	"mon_succubi_sadist",
	"mon_succubi_somnophilia",
	"mon_succubi_exhibitionism",
	"mon_succubi_lactophilia",
	"mon_incubi_sthenolagnia",
	"mon_incubi_phalloplas",
	"mon_incubi_hoplophilia"
}


SEX_MORALE_TYPE		= morale_type("morale_sex_good")	--*気持ちいいこと*の意欲タイプ
SEX_BASE_TURN		= 100		--行為1wait当たりに掛かる基準ターン数(1ターン = 約6秒)。100=10分。
SEX_MAX_TURN		= 1800		--行為全体に掛かる最大ターン数。1800=3時間。
SEX_FUN_DURATION	= 600		--行為による意欲がどの程度長続きするかのtime_duration。
SEX_FUN_DECAY_START	= 150		--行為による意欲が冷め始めるまでのtime_duration。

D_GOM_BREAK_CHANCE	= 50		--あぶない方の避妊具が使用時に破損する確率(%)。

PREG_CHANCE = 10				--基礎妊娠確立(%)。
DEFAULT_PREG_SPEED_RATIO = 1	--孕んだ子供の成長スピード比率。


DEFAULT_NPC_NAME = "ﾄﾑ"		--NPC新規生成時のデフォルト名。みんな大好きトム。


EFF_SPELL_CHARGE_INT_FACTOR = 30	--モンスター攻撃の魔法詠唱にかかるint_dur_factor。


--[[set_valueの値設定に使う名称]]--
EVENT_GOATHEAD_DEMON = "event_goathead_demon"				--モンスター"mon_goathead_demon"との会話イベントを発生させたかどうか
EVENT_DEMONBEING_SCHOOLGIRL = "event_demonbeing_schoolgirl"	--npc"demonbeing_schoolgirl"を発生させたかどうか
CREAMPIE_SEED_TYPE = "creampie_seed_type"					--注がれた種の種族を保持する。あなたがパパになるんですよ？
