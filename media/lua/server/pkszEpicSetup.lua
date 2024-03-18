pkszEpicSetup = {}
if isClient() then return end

pkszEpicSetup.ready = function()

	pkszEpic.nameList = {}

	local nameFile = pkszEpicFileExist(pkszEpic.baseDir.."/"..pkszEpic.nameListFileName)
	pkszEpic.logger("pkszEpic File check "..pkszEpic.baseDir.."/"..pkszEpic.nameListFileName,false)

	if not nameFile then
		local names = pkszEpicNameFileDeploy()
		pkszEpicDataSetupForText(names)
		pkszEpic.logger("pkszEpic / Name list file Installed",true)
	else
		pkszEpic.logger("pkszEpic / Name file loaded",true)
		pkszEpicDataSetupForFile(nameFile)
		nameFile:close()
	end

end

function pkszEpicFileExist(filename)
	local file = getFileReader(filename, false);
	if not file then
		return nil
	else
		return file
	end
end

function pkszEpicDataSetupForFile(file)

	local tag = nil

    while true do repeat
		local line = file:readLine()
		if line == nil then
			file:close()
			return
		end
		line = string.gsub(line, "^ +(.+) +$", "%1", 1)
		if line == "" or string.sub(line, 1, 2) == "--" then break end

		if string.sub(line, 1, 1) == "[" then
			if string.sub(line, 2, 6) == "item:" then
				tag = string.match(line, "item:([%s%d%w%.%_%=%'%,]+)")
				pkszEpic.nameList[tag] = {}
			else
				tag = string.match(line, "(%w+)")
				pkszEpic.nameList[tag] = {}
			end
			-- print("tag ",tag)
		else
			if tag then
				table.insert(pkszEpic.nameList[tag],line)
			end
		end

    until true end

end

function pkszEpicDataSetupForText(names)

	local rec = pkszEpic.StrSplit(names,"\n")
	local tag = nil
	for key,value in pairs(rec) do
		local line = value
		line = string.gsub(line, "^ +(.+) +$", "%1", 1)
		if line == "" or string.sub(line, 1, 2) == "--" then line = nil end
		if line then
			if string.sub(line, 1, 1) == "[" then
				if string.sub(line, 2, 6) == "item:" then
					tag = string.match(line, "item:([%s%d%w%.%_%=%'%,]+)")
					pkszEpic.nameList[tag] = {}
				else
					tag = string.match(line, "(%w+)")
					pkszEpic.nameList[tag] = {}
				end
			else
				if tag then
					table.insert(pkszEpic.nameList[tag],line)
				end
			end
		end
	end

end

function pkszEpicNameFileDeploy()

	local names = pkszEpicGetDefaultNames()
	local fileName = pkszEpic.baseDir.."/"..pkszEpic.nameListFileName
	pkszEpicFileWriter(fileName,names)

	return names
end

function pkszEpicFileWriter(fn,text)

	if not text then return end
	if not fn then return end

	local dataFile = getFileWriter(fn, true, false);
	if dataFile then
		dataFile:write(text);
		dataFile:close();
	else
		pkszEpic.logger(" pkszEpic - server : File Writer Error "..filename,true)
	end
end


------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
-- This is the default setting
-- please edit the files in the USER folder
-- please edit the files in the USER folder
-- please edit the files in the USER folder
-- thank you
------------------------------------------------------------
------------------------------------------------------------

function pkszEpicGetDefaultNames()

	local result = nil

result = [[-- "--" is can be used as a comment out
--
-- Name generator setting
-- Never use "[" in name words.
--
-- head : Attached to the beginning with probability. Can be used for all items
-- any : Used for all item names
-- weapon ,cloth ,bag ,watch: Only used for this categories
-- itemID : Only used for specific items
-- 
-- Game restart is required for edited names to take effect
-- 
[head]
12th
15th
16th
17th
18th
Age of
Best for
Destiny of
End of
Escape From
Grandma's
Grandpa's
King of
Legendary
Lessons of
My first
Peace of
Rhythm of
Song of
The Lord of the
The Sacred
The Silence
TimeLeape
Wrath of
WWII
----------------------
[any]
Project
Aardwolf
Adamantite
Adoff
Agrod
Aldan
Alone
Amanogawa
Ambition
Ambrose
Ancient
Angel
Anger
Antique
Arachne
Arcanum
Arched
Arctic
Argent
Ashes
Atuned
Awkward
Awoken
Azurewrath
Ballista
Barxus
Beast
Beastie
Becoming
Best
Betrayer
Bird
Blaise
Blaze
Blight's
Blunderbust
Bond
Boomer
Bountiful
Brendan
Bride
Brigade
Brilliant
Buffalo 
Cadogan
Caedmon
Candleblow
Capncrunch
Captain's
Cargeiros
Cassandra
Cat
Cataclysm
ch-best
Chambers
Chedu
Chief
Chieftain
Children
Chromarage
Claddani
Cleansing
Clinging
Clutch
Collarbone
Conspiracy
Corbin
Country
Courier
Cross
Cry
Cul-de-sac
Cupcake
Curse
Damnation
Dancing
Darkmore
Dawn
DayZ
decimation
Defiler
Deflector
Deserted
Desires
Destiny's
Devine
Diana
Dictator
Diligent
Discovering
Disturbance
Diva
Divide
Divinity
DLS
Dog
Doubt
Dragon
Dramatic
Dreams
Dubhtach
Dunkelherz
Ebonhart
Edalin
Elegant
Elkington
Elvish
Elysium
Enchanting
Ender
Engraved
Enlightened
Espada
Eternal
Eternity
Evening
Facebook
Faceless
Fairy
Faith
Faithkeeper
Falcon
Falkenhorst
Familiar
Fancy
Fate
Father
Favourite
Feeling
Finding
Flimsy
Force
Forged
Forgotten
Fragile
Friend
Frost
Fuji
Fury
Fusion
Future
Garden
Generous
Geometry
Gibbs
Gift
Glorious
Gmork
Golden
Goose
Grace
Gram
Grave
Grendel
Grey
Grimlight
Grimmwood
Grimshaw
Guard's
Guardian
Gurim
Hailstorm
Hallowed
Hallowgrave
Hatred
hayacocco
Heart
Heater
Hell's
Heller
Hellshade
Hemlock
Hickman
Hitchcock
Hollow
Homage
Hope
Hot
Hunters
Hurst
Ignoring
Ikuta-rarao
Incarnated
Infinite
Infinity
Infused
Instagram
Investigation
Irk
Ironwood
Jade
Jeremiah
Joyful
Juanita
Kakashi
Kamui
KEN
King
Kiss
Krueger
Laceration
Lady
Laike
Lannister
Lash
Last
Lazy
Legacy
Liberty
Lich
Licks
Life
Light
Little
Lone
Lonely
Lord
Lorennion
Loss
Loveless
Lovely
Lowery
Loyal
Lucifer
Ludegi
Luella
Lunatic
Lycidas
Macbeth
Madship
Mage's
Mark
Mastery
Matthews
Meadow
Megamimi
Memory
Mercenary
Merle
Mind
Misery's
Misfortune's
Mist
Modern
Moment
Moon
Moriarty
Morte
Mother
Muffalo
Musuka
Mystique
Mythological
Naewarin
Nakanishi
Namidame
Natrix
Nature
Nazka
Nebelstein
Nebelwald
Nemesis
Night
Nightfall
Nightmare
Nighttime
Nissan
Noble
Noxious
Numb
Nyx
Oath
Ocean
Omen
Origami
Orion
Orpheus
Osiris
Ourselves
Passage
Passion
Patricia
Payne
Perseus
Phoebe
Phoeniz
Piety
Pinch
Pinky
Playful
Plight
Poetry
Pokie
Portal Storm
Possessed
Prayer
Prideful
Project
Promise
Protector
Purify
Queen
Quvra
Rabenschwarz
Rain
Rainbow
Randy
Rapids
Ravager
Ravenhurst
Rebel
Recruit's
Regret
Reindeer
Renovated
Response
Restored
Retirement
Rhyme
Rick's
Rider
Rising
Roaming
Romance
Rose 
Rosenstern
Runed
Rusty
Safety
Sailing
Samebaga
Samon
Scarlet
Sculptor
Secrets
Seeker
Sepulchral
Serano
Serene
Shadow
Shards
Sheep
Shot
Silent
Silver
Singed
Singing
Siren's
Skyfall
Slynt
Smooth
Snitch
Snow
Soaring
Son
Sorceress
Sorrow
Sorrowful
Sphere
Spire
Spiritual
Sproutwit
Stakeout
Star
Stormrider
Stormy
Story
Study
Sturmwind
Sukiyaki
Sumi
Summer
Sunscreen
Sweetie
Swift
Takeru
Tale
Talon
Teal
Teardrop
Technology
Temptation
Tender
Thorn
TikTok
Tilzugo
Timmy
Trainee's
Travis
Treasure
Tremor
Trickster
Trickster's
Trollope
Tryfs
Tweak
Twilight
Twilight's
Twitter
Typhoon
Ulfred
Ultimate
Uncovering
Unknown
Upperclass
Valentine
Vanquisher
Velasir
Vengeful
Vesperal
Vidahmf
Viking
Vindication
Vizualization
Vlad
Voiceless
Void
Vortex
Wandering
Warden
Wexford
Whisper
Willis
Willowbell
Wind
Windlass
Windsong
Wisdom
Wit
Wolf
Wraithborne
Wulfhardt
Xorin
Yosh 
Zealous
Zodiac
----------------------
[weapon]
Zomboid
Abomination
Abyssal
Aello
Agony
Allegiance
Amnesty
Annihilation
Arrowsong
Assassin
B&W
Bane
Banished
Berserk
Blackened
Blackout
Blade
Bloodfury
Bloodmark
Bloodrage
Bloodvenom
Bloody
Bluster
Bon Voyage
Bone
Bonecarvin
Bonescraper
Boomboom
Boomstick
Boon
Braindead
Breaker
Bringer
Bristleblitz
Broken
Brown bear
Brutality
Brutalizer
Burp
Calamity
Cannibal
Catastrophe
Champion
Claw
Cobra
Cometfall
Conqueror
Corroded
Crimson
Crusader
Crush
Cunning
Curved
Cutting
Dead
Death
Decapitator
Demon
Demonic
Desolation
Destiny's
Destroyer
Disaster
Doom
Dragon's
Dragonmaw
Draughtbane
Dreadful
Dreamhunter
Edge
Eerie
Enchanted
Eomod
Epilogue
Escape
Euthanasia
Everalda
Evil
Executioner
Faithful
Fang
Fear
Fearful
Fierce
Flame
Fling
Foe
ForgetMeNot
Forsaken
Frankenlove
Frenzied
Frigg's
Gaze
Ghost
Ghostbane
Ghostkeeper
Goodfellow
Gravesoul
Greso
Grieving
Grim
Hades
Harpy
Harvester
Hateful
Hatred's
Headhunter
Heartless
Heaven
Heirloom
Honor's
Hopeless
Hysteria
Illuminax
Infamous
Izanagi
Izanami
Jandarn
Judged
Judgement
Jugular
Kin
Knightly
Kojiro
Kurogane
Lestrange
Lightning
Lockheed
Lucia
Lumus
Lynch
Madness
Maelstrom
Magnificent
Malice
Malignant
Meat
Messenger
Might
Misty
Mithril
Moonlit
Moonshadow
Mourning
Musashi
Nameless
Nanami
Narcissa
Nethersbane
Nightbreaker
Nighttime
Northrop
Oathkeeper
Ogre
Olivia
Panther
Peacekeeper
Phantom
Phobia
Photon
Piercer
Pledge
Polished
Precision
Pride's
Punishment
Quickstrike
Quiet
Rage
Rapture
Raytheon
Razor
Reaper
Reason
Recurve
Redemption
Reign
Reincarnated
Remembering
Remorse
Retribution
Retribution Token
Rhapsody
Rigormortis
Roaring
Saints
Samurai
Scream
Shadow's
Shadowfall
Shard
Shatterer
Shooting Star
Sigh
Silberbach
Sizzle
Skeeter
Skullforge
Slayer
Slicer
Snapper
Sorrow's
Soul
Spark
Spectral
Spell
Spine
Spite
Spitfire
Sting
Storm
Stormbringer
strike
Stryker
Sunflare
Supremacy
Terror
Thirsting
Thunder
Thunder's
Thundercall
Timber wolf
Tiw's
tooth
Trickster
Tukuyomi
Undead
Unholy
Unicorn
Valentina
Valkyrie
Vanquisher
Vehement
Velika
Velvet
Vengeance
Vengeful
Venom
Vision
Volatile
Volcanic
Vulture
War
Warden
Warlord
Warmonger
Warning
Wartime
Whirlwind
Wicked
Widowmaker
Wind-Forged
Woden's
Woeful
Wrathful
Wretched
Xar
Zombie
----------------------
[cloth]
Knox
Adidas
agnes b
ALBA ROSA
ANGEL BLUE
Anta
Armani
Bohemia Interactive
Bosideng
Bottega Veneta
Bulgari
Burberry
Calvin Klein
Cartier
CECIL McBEE
Celine
Chanel
Chow Tai Fook
Coach
COMME des GARCONS
DAISY LOVERS
Dior
Dunhill
Facepunch Studios
Fila
Forever21
Gamepires
GAP
Givenchy
Gucci
GUESS
H&M
Hermes
ISSEY MIYAKE
JUNYA WATANABE
Knox
Lacoste
Lao Feng Xiang
Levi's
Li Ning
LIZ LISA
Loewe
Louis Vuitton
Lululemon
Michael Kors
Moncler
New Balance
Nike
Old Navy
Pandora
Pou Chen
Prada
Primark/Penney's
Puma
Quicksilver
Ralph Lauren
Ray-Ban
Saint Laurent
Shimamura
Skechers
STUSSY
TAG Heuer
Techland
The Fun Pimps
The North Face
Tommy Hilfiger
Under Armour
UNDERCOVER
UNIQLO
Valve
Van Cleef&Arpels
VANS
Victoria's Secret
Visvim
Vivienne Westwood
Yohji yamamoto
Zara
----------------------
[watch]
Audemars Piguet
Bamford
Baume & Mercier
Blancpain
Breguet
Breitling
Bremont
Bvlgari
Cartier
Chopard
Corum
Frederique Constant
Girard-Perregaux
Harry Winston
Hublot
IWC Schaffhausen
Jaeger-LeCoultre
Longines
Louis Vuitton
Maurice Lacroix
MeisterSinger
Montblanc
Nomos Glashutte
Nordgreen
Omega
Panerai
Patek Philippe
Piaget
Rolex
Tag Heuer
Tiffany & Co.
Tudor
Ulysse Nardin
Vacheron Constantin
Van Cleef & Arpels
Verdure Watches
Vincero
Zenith
----------------------
[bag]
The Indie Stone
Adidas
Anta
Armani
Bosideng
Bottega Veneta
Bulgari
Burberry
Calvin Klein
Cartier
Celine
Chanel
Chow Tai Fook
Coach
Dior
Dunhill
Fila
Givenchy
Gucci
GUESS
H&M
Hermes
JILL STUART
Knox
Lao Feng Xiang
Levi's
Li Ning
Loewe
Louis Vuitton
Lululemon
Michael Kors
Moncler
New Balance
Nike
Old Navy
Omega
Pandora
Pou Chen
Prada
Primark / Penney's
Puma
Ralph Lauren
Ray-Ban
Rolex
Shimamura
Skechers
Steam
TAG Heuer
The North Face
Tiffany
Tommy Hilfiger
Under Armour
UNIQLO
Van Cleef & Arpels
Victoria's Secret
Yves Saint Laurent
Zara
----------------------
[item:Base.Katana]
Akabane
Bizen-Osahune
Horikawa-Kunihiro
Hotaru-Maru
Ishikiri-Maru
Jyuzu-Maru Tsunetugu
Khotetsu
Kunihiro
Kunimitsu
Kuniyuki
Masamune
Mitsutada
Mitsuyo
Miyairi-Yukihira
Mumei-Uchigatana
Muramasa
Nagamitsu
Nobukuni
Norimune
Rai-Kunitoshi
Sadamune
Sanjyo-Munechika
Sukezane
Sumitani-Masamine
Takahashi-Sadatsugu
Tousirou
Yoshifusa
Yoshimitsu
Yoshioka
Yoshiyuki
Zigane-Maru
]]

	return result
end