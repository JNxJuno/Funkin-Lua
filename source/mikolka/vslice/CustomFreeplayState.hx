package mikolka.vslice;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.util.FlxSpriteUtil;
import StringTools;
import Date;

import backend.Paths;
import backend.Song;
import backend.MusicBeatState; 
import mikolka.vslice.ui.MainMenuState;
import states.PlayState;
import states.LoadingState;

class CustomFreeplayState extends MusicBeatState
{
	var bg:FlxSprite;
	var clockText:FlxText;
	var signalText:FlxText;
	var msgBox:FlxSprite;
	var msgText:FlxText;

	var blueBoxes:FlxTypedGroup<FlxSprite>;
	var songBoxes:FlxTypedGroup<FlxSprite>;
	var statusIcons:FlxTypedGroup<FlxSprite>; 
	var songsGroup:FlxTypedGroup<FlxText>;
	
	var songsList:Array<String> = ['Tutorial', 'Bopeebo', 'Fresh', 'Dad Battle', 'Spookeez', 'South'];
	var curSelected:Int = 0;

	var customFont:String = "Phantomuff Difficult Font.ttf";

	override function create()
	{
		super.create();
		FlxG.mouse.visible = true;

		bg = new FlxSprite().loadGraphic(Paths.image('customFreeplay/freeplayBG', 'shared'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.screenCenter();
		add(bg);

		// Oben Rechts UI
		signalText = new FlxText(FlxG.width - 100, 20, 0, "WLAN", 28);
		signalText.setFormat(Paths.font(customFont), 28, FlxColor.WHITE, RIGHT);
		add(signalText);

		clockText = new FlxText(FlxG.width - 220, 20, 100, "00:00", 28);
		clockText.setFormat(Paths.font(customFont), 28, FlxColor.WHITE, RIGHT);
		add(clockText);

		msgBox = new FlxSprite(FlxG.width - 320, 100); 
		msgBox.makeGraphic(300, 40, FlxColor.TRANSPARENT);
		FlxSpriteUtil.drawRoundRect(msgBox, 0, 0, 300, 40, 15, 15, FlxColor.WHITE);
		add(msgBox);

		msgText = new FlxText(msgBox.x, 0, msgBox.width, "hi from Lua Team :)", 18);
		msgText.setFormat(Paths.font(customFont), 18, FlxColor.BLACK, CENTER);
		msgText.y = msgBox.y + (msgBox.height / 2) - (msgText.height / 2);
		add(msgText);

		// Gruppen
		blueBoxes = new FlxTypedGroup<FlxSprite>();
		add(blueBoxes);

		songBoxes = new FlxTypedGroup<FlxSprite>();
		add(songBoxes);

		statusIcons = new FlxTypedGroup<FlxSprite>();
		add(statusIcons);
		
		songsGroup = new FlxTypedGroup<FlxText>();
		add(songsGroup);

		for (i in 0...songsList.length) {
			var blueBox = new FlxSprite(0, 0).loadGraphic(Paths.image('customFreeplay/songNameGridBlue', 'shared'));
			blueBox.antialiasing = ClientPrefs.data.antialiasing;
			blueBox.alpha = 0; 
			blueBox.ID = i;
			blueBoxes.add(blueBox);

			var box = new FlxSprite(0, 0).loadGraphic(Paths.image('customFreeplay/songNameGrid', 'shared'));
			box.antialiasing = ClientPrefs.data.antialiasing;
			box.ID = i;
			songBoxes.add(box);

			var icon = new FlxSprite(0, 0).loadGraphic(Paths.image('customFreeplay/play', 'shared'));
			icon.antialiasing = ClientPrefs.data.antialiasing;
			icon.ID = i;
			statusIcons.add(icon);

			var txt = new FlxText(0, 0, box.width, songsList[i], 36);
			txt.setFormat(Paths.font("FridayNightFunkin-Regular.ttf"), 36, FlxColor.WHITE, LEFT);
			txt.ID = i;
			songsGroup.add(txt);
		}

		changeSelection(0);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		var now = Date.now();
		clockText.text = StringTools.lpad(Std.string(now.getHours()), "0", 2) + ":" + 
						 StringTools.lpad(Std.string(now.getMinutes()), "0", 2);

		var lerpVal = FlxMath.bound(elapsed * 12, 0, 1);

		for (i in 0...songsList.length) {
			var blueBox = blueBoxes.members[i];
			var box = songBoxes.members[i];
			var txt = songsGroup.members[i];
			var icon = statusIcons.members[i];

			// VERTIKALE LISTE (Abstand 130)
			var targetY = (FlxG.height / 2) + (i - curSelected) * 130 - 50;
			
			// Nur die weiße Box interpoliert flüssig auf der Y-Achse
			box.y = FlxMath.lerp(box.y, targetY, lerpVal);

			// Blauer Schatten klebt hart an der weißen Box (nach links und unten versetzt)
			blueBox.x = box.x - 6;
			blueBox.y = box.y + 38;

			if (i == curSelected) {
				box.x = FlxMath.lerp(box.x, 180, lerpVal); // Geht leicht nach rechts
				box.alpha = 1;
				blueBox.alpha = 1; // Schatten an
				txt.alpha = 1;
				icon.alpha = 1;
				
				txt.scale.set(1.15, 1.15);
				// Text weicht nach links aus, um Platz fürs Icon zu machen
				txt.x = box.x + 80; 
			} else {
				box.x = FlxMath.lerp(box.x, 80, lerpVal);
				box.alpha = 0.5;
				blueBox.alpha = 0; // Schatten aus
				txt.alpha = 0.5;
				icon.alpha = 0.5;
				
				txt.scale.set(1.0, 1.0);
				// Text normal zentrierter
				txt.x = box.x + 40; 
			}
			
			// Text und Icon kleben hart auf der Y-Achse
			txt.y = box.y + (box.height / 2) - (txt.height / 2);
			
			// Icon fest auf der RECHTEN Seite
			icon.x = box.x + box.width - icon.width + 30;
			icon.y = box.y + (box.height / 2) - (icon.height / 2) ;
		}

		if (controls.UI_UP_P) changeSelection(-1);
		if (controls.UI_DOWN_P) changeSelection(1);
		if (controls.BACK) MusicBeatState.switchState(new MainMenuState());
		if (controls.ACCEPT) selectSong();
	}

	function changeSelection(change:Int = 0) {
		if (change != 0) FlxG.sound.play(Paths.sound('scrollMenu'));
		curSelected = FlxMath.wrap(curSelected + change, 0, songsList.length - 1);
		
		for (i in 0...statusIcons.length) {
			var icon = statusIcons.members[i];
			if (i == curSelected) {
				icon.loadGraphic(Paths.image('customFreeplay/pause', 'shared'));
			} else {
				icon.loadGraphic(Paths.image('customFreeplay/play', 'shared'));
			}
		}
	}

	function selectSong() {
		var songFormat:String = StringTools.replace(songsList[curSelected].toLowerCase(), " ", "-");
		try {
			PlayState.SONG = Song.loadFromJson(songFormat, songFormat);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = 1;
			LoadingState.loadAndSwitchState(new PlayState());
		} catch(e:Dynamic) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
	}
}