package mikolka.vslice;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import StringTools;

import backend.Paths;
import backend.Song;
import backend.MusicBeatState; 
import mikolka.vslice.ui.MainMenuState;
import states.PlayState;
import states.LoadingState;

class CustomFreeplayState extends MusicBeatState
{
	var bg:FlxSprite;
	var tablet:FlxSprite;
	var tabletLight:FlxSprite;
	
	var songGrid:FlxSprite;
	var songText:FlxText;
	var playIcon:FlxSprite;
	
	var songsList:Array<String> = ['Tutorial', 'Bopeebo', 'Fresh', 'Dad Battle'];
	var curSelected:Int = 0;

	var textMatchAngle:Float = -13;

	override function create()
	{
		super.create();
		FlxG.mouse.visible = true;

		bg = new FlxSprite().loadGraphic(Paths.image('customFreeplay/freeplayBG', 'shared'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		tablet = new FlxSprite().loadGraphic(Paths.image('customFreeplay/tablet', 'shared'));
		tablet.screenCenter();
		tablet.antialiasing = ClientPrefs.data.antialiasing;
		add(tablet);

		songGrid = new FlxSprite().loadGraphic(Paths.image('customFreeplay/songNameGrid', 'shared'));
		songGrid.antialiasing = ClientPrefs.data.antialiasing;
		songGrid.angle = 0; 
		songGrid.screenCenter();
		songGrid.x += 15; 
		songGrid.y -= 35;
		add(songGrid);

		songText = new FlxText(0, 0, songGrid.width, "", 32);
		songText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.BLACK, CENTER);
		songText.angle = textMatchAngle;
		add(songText);

		playIcon = new FlxSprite().loadGraphic(Paths.image('customFreeplay/play', 'shared'));
		playIcon.antialiasing = ClientPrefs.data.antialiasing;
		playIcon.angle = textMatchAngle;
		add(playIcon);

		tabletLight = new FlxSprite().loadGraphic(Paths.image('customFreeplay/tabletLight', 'shared'));
		tabletLight.screenCenter();
		tabletLight.blend = openfl.display.BlendMode.ADD;
		add(tabletLight);

		changeSelection(0);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		songText.x = songGrid.x;
		songText.y = songGrid.y + (songGrid.height / 2) - (songText.height / 2) + 5;

		// Play Icon näher an das Grid geschoben (-8 statt -20)
		playIcon.x = songGrid.x - playIcon.width - 8;
		playIcon.y = songGrid.y + (songGrid.height / 2) - (playIcon.height / 2) + 25;

		if (controls.UI_LEFT_P || controls.UI_UP_P) changeSelection(-1);
		if (controls.UI_RIGHT_P || controls.UI_DOWN_P) changeSelection(1);

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}
		
		if (controls.ACCEPT) selectSong();
	}
	
	function changeSelection(change:Int = 0)
	{
		if (change != 0) FlxG.sound.play(Paths.sound('scrollMenu'));
		curSelected = FlxMath.wrap(curSelected + change, 0, songsList.length - 1);
		
		songText.text = songsList[curSelected].toUpperCase();

		songGrid.scale.set(1.03, 1.03);
		FlxTween.cancelTweensOf(songGrid.scale);
		FlxTween.tween(songGrid.scale, {x: 1, y: 1}, 0.1);
	}
	
	function selectSong()
	{
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