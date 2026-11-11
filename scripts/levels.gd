extends RefCounted
## Alle Level als Text-Karten.
##
## Legende:
##   #  Wand            .  Boden          ~  schmaler Spalt (nur der Fuchs passt durch)
##   1  Start Fuchs     2  Start Bär      B  Kiste (nur der Bär kann sie schieben)
##   a  Ziel Fuchs      b  Ziel Bär
##   P  Druckplatte -> öffnet Tür D        Q  Druckplatte -> öffnet Tür E
##   D / E  Tür (offen, solange ihre Platte belegt ist: Figur oder Kiste)

const LEVELS := [
	{
		"name": "Hallo, ihr zwei",
		"hint": "Jeder muss auf sein Ziel: Fuchs auf das orange, Bär auf das braune Feld.",
		"map": [
			"#########",
			"#1.....2#",
			"#.......#",
			"#a.....b#",
			"#########",
		],
	},
	{
		"name": "Enger Spalt",
		"hint": "Der Bär ist zu breit für den Spalt. Der Fuchs ist es nicht.",
		"map": [
			"##########",
			"#1......2#",
			"#.......b#",
			"####~#####",
			"#a.......#",
			"##########",
		],
	},
	{
		"name": "Schwere Kiste",
		"hint": "Nur der Bär kann Kisten schieben. Eine Kiste auf der Platte hält die Tür offen.",
		"map": [
			"############",
			"#1.........#",
			"#.2.B...P.##",
			"#.........##",
			"######D#####",
			"#####a.b####",
			"############",
		],
	},
	{
		"name": "Platte halten",
		"hint": "Der Fuchs hält die Platte im Spalt. Danach geht der Bär durch die Tür.",
		"map": [
			"##############",
			"#1.......2.Db#",
			"#a...........#",
			"##~###########",
			"##P###########",
			"##############",
		],
	},
	{
		"name": "Das Finale",
		"hint": "Erst die Kiste, dann die Platte im Spalt. Zwei Türen, zwei Aufgaben.",
		"map": [
			"##############",
			"#1.......D.Eb#",
			"#a.2.B..P#####",
			"##~###########",
			"##Q###########",
			"##############",
		],
	},
]
