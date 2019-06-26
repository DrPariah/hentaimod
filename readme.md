## What is this?

Translation of the Japanese mod for Cataclysm: Dark Days Ahead, along with couple of additions.

## What's in this mod?

- Have *fun* with NPCs! You can be either in love, or do it by fear.
- Be forced to have *fun* with lewd monsters whether you want it or not!
- New dungeons to explore with new vicious traps!
- Corruption system and corruption game over from having *too much fun*!
- Functional pregnancy system as a product of your love, with ways to prevent it!
- Couple of new traits that will help you to define your character better!
- Some new items, including a male analog of the vibe, allowing you to *relax*!
- Want to change your gender or NPC's name? You can do that with an item!
- Demonic invasion and lots of Demons lusting after your flesh!
- You can find the leader behind the invasion and kick his ass!
- A class that starts with their own personal pet! You can even have a pet succubus!
- Human mutagens allowing you to transform some mutants and pets into human!
- Pets can be fully animal, have animal-like features or be fully human, depending on their individual settings!

## Branches:
- **Japanese** is publicly available japanese version, mostly for merging.
- **Master** is for the stable D version.
- **LUAEX** is for [luaex version][3]. It's the (mostly) latest experimental version with lua support.
- **LUAEX_dev** is mostly broken and full of wip edits (in case you want to help or just curious).
- **LUAEX_日本人** - 日本人向け。これを使ってください (LUAEX only)  

Switch to the desired branch and download from there. LUAEX among other things also adds new features such as:
- Memorial log entries
- Sound effect
- Forces transformed pet NPCs to spawn regardless of settings
- Randomized appearance for transformed pets

## Installation:

Drop the "hentai" folder into your mod folder. Do not rename the hentai folder, or it will break its scripts.  
If you wish to rename the folder anyway, edit preload.lua and edit the paths in the beginning of the file. Make sure to keep the UTF8 encoding.  
This mod requires LUA support so it probably won't work on latest experimental build (Keviiiiiiiiiiii--).

## Mod specifics
- Added dialogue lines, description lines.
- Added bio massager and scroll tile sprites.
- Improved sensual attack description, now they can pat your head, play with your tail or wings, or (gasp) even hold hands.
- Added some new effects.
- Things I haven't tested after translation: pregnancy, breeding season traits. If those don't function properly then it's probably on me.

## Source:

[Search for hentai_mod][1].

According to the license, this mod can be freely modified and distributed.

## FAQ:
#### Is this an adult mod?
- Not really, according to the author. As he says, it's about R-15. The translation avoids being too explicit when possible. 
- Tiles might be a little lewd though.
- Use it on your own risk.
#### I found a bug!
- This mod might be buggy. Translation probably contributed to that too. You can report translation problems, but the game-breaking bugs caused by original code can be out of my expertise.
- This mod was made for CDDA 0.C-8204 version so that's that.
- There's a lot of incomplete TODO's in this mod and it can use some code refactoring.
#### I transformed my pet, but it disappeared!
- Make sure to set ``Static NPC`` to ``on`` and their spawn to ``always``.
- LUAEX version can spawn them regardless of settings.
#### I visited the animal shelter, but I can't complete the request!
- It's confusing, but make sure you're at the animal *shelter* and not the pound.
#### How do I *have fun*?
- Use condom on an NPC.
#### Where can I find unused contraceptives?
- Mainly in the bedrooms inside houses. Demons might also carry it on them.
#### Can all monsters *have fun* with you?
- No, only Demons and corrupted humans from corrupted school.
- None of the vanilla monsters were modified.
#### When I wanted to *have fun*, I was refused...
- You will be refused unless you have a sufficient amount of favor or fear with an NPC.
- Favor depends on: Intelligence, Beauty, Speak skill, Trust.
- Fear depends on: Strength, Ugliness, carrying a gun in the conversation.
- But don't worry, no matter how unsightly you may be, the balance is set in such way that completing couple of requests will make any NPC accept you with open arms.
- Please be gentle with the girls who are still holding onto their chastities. Not that I'm forcing you though.
#### I got pregnant!
- Congratulations. Please give birth to a healthy baby.
- No, you cannot abort the baby. You monster.
#### Where are all the Demons?
- They should be mostly lurking innawoods and plains. The chance is increased when it's close to nighttime.
- Since they're hostile to Zombies, you won't see them in the city all that much.
#### I wanna *have fun* with Demons!
- It may trigger when your character is incapacitated (grabbed, webbed, put to sleep, etc...) or when they decide to use a *special attack* on you.
- There might be those who won't do it with you at all. Such is life.
- There's also a problem where monsters who attacked you first will not use other special attacks, so for example they will proceed undressing you all the time instead of doing something else. But a new monster might push you down immediately now that you're naked.
#### No one's *doing it* with me no matter what! I can't *have fun*! I didn't play this game to experience reality!
- Take
- off
- your
- panties
#### I'm a man/woman, and yet incubi/succubi are still after me!
- Gender is a social construct, did you know that?
- But seriously, it's just the way it's made. Besides demons most likely can change their sex at will, so they probably just don't care.
#### I can still obtain chest-size traits even as a man!
- Now this is really just game limitations.
- Think of it like having handsome well-sized pecs or lovely swellings or ugly manboobs.
#### I don't dig meme-y Demon names
- Well it's either that, or really technical terms that you will have to google.
#### Why can't this mod be more lewd?!?!?!?!
- Author was really worried about sensible western ~~gaijin pigs~~ people ree'ing at him and Mr Kevin personally banning him for life or something.
- So let's not risk it.
- Unless you want to be the hero. Just sayin'.
#### I want to toggle off this and that, how do I do that?
- Consider reading through original documentation (untranslated), author wanted to make the experience customizable but he lacks the means to do so.
#### Where's my %insert degenerate fetish name here%?
- I dunno, why won't you make it yourself? No scat though, [Kevin said so himself][2].
#### REEE THIS MOD IS OFFENDING ME BECAUSE I'M A LITTLE PUSSY AND YOU MUST CATER TO ME
- Cry me a river.
#### I want to expand this mod and add this and that!
- By all means, please do.
- Keep in mind that if something isn't right inside lua files, then it tends to just fail silently. As in, it will reach the problematic line, try to execute it and then stop right there, no log, no crash, nothing. This can cause certain speech lines or effects or attacks to never appear for example. It will infuriate you to no end.
- Check TODO's in the code if you want to contribute but don't know where to start.

[1]: https://www.axfc.net/u/search.pl?search_str=hentai&id_start=&id_end=&extv=&size_min=&size_min_si=2&size_max=&size_max_si=2&dl_min=&dl_max=&date_start=&date_end=&num=&sort_type=uid&sort_m=DESC&md5=&sha1=
[2]:https://discourse.cataclysmdda.org/t/fms-frequently-made-suggestions/9764
[3]:https://github.com/lispcoc/Cataclysm-DDA-luaex/releases/