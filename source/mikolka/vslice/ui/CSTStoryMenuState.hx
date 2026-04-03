package mikolka.vslice.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import backend.Song;
import states.PlayState;
import states.LoadingState;

class CSTStoryMenuState extends MusicBeatState
{
	var bg:FlxSprite;
	var sideChess:FlxSprite;
	var sideChessLine:FlxSprite;
	var weekGrid:FlxSprite;
	
	var weekItems:FlxTypedGroup<FlxSprite>;
	var locks:FlxTypedGroup<FlxSprite>;
	var difficultySprites:FlxTypedGroup<FlxSprite>;
	var diffSelect:FlxSprite; 
	var upArrow:FlxSprite;
	var downArrow:FlxSprite;

	var curWeek:Int = 0;
	var curDifficulty:Int = 1; 
	
	var weekList:Array<String> = ['week1', 'week2', 'week3'];
	var diffList:Array<String> = ['diffEASY', 'diffNORMAL', 'diffHARD']; 

	override function create()
	{
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Custom Story Mode", null);
		#end

		persistentUpdate = persistentDraw = true;

		bg = new FlxSprite().loadGraphic(Paths.image('menuBG'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		sideChess = new FlxSprite().loadGraphic(Paths.image('customStory/sideChess', 'shared'));
		sideChess.x = FlxG.width - sideChess.width;
		sideChess.screenCenter(Y);
		add(sideChess);

		sideChessLine = new FlxSprite().loadGraphic(Paths.image('customStory/sideChessLine', 'shared'));
		sideChessLine.x = sideChess.x - 2; 
		sideChessLine.screenCenter(Y);
		add(sideChessLine);

		weekGrid = new FlxSprite(65, 0).loadGraphic(Paths.image('customStory/weekGrid', 'shared'));
		weekGrid.screenCenter(Y);
		add(weekGrid);

		weekItems = new FlxTypedGroup<FlxSprite>();
		add(weekItems);

		locks = new FlxTypedGroup<FlxSprite>();
		add(locks);

		for (i in 0...weekList.length)
		{
			// Weeks nach links geschoben (+135 statt +160)
			var week:FlxSprite = new FlxSprite(weekGrid.x + 120, weekGrid.y + 190 + (i * 165));
			week.loadGraphic(Paths.image('customStory/' + weekList[i], 'shared'));
			week.ID = i;
			week.antialiasing = ClientPrefs.data.antialiasing;
			weekItems.add(week);

			if (i < 2) {
				var lock:FlxSprite = new FlxSprite(week.x + 135, week.y - 12);
				lock.loadGraphic(Paths.image('customStory/storyLock', 'shared'));
				lock.ID = i;
				lock.scale.set(0.7, 0.7);
				lock.antialiasing = ClientPrefs.data.antialiasing;
				locks.add(lock);
			}
		}

		upArrow = new FlxSprite().loadGraphic(Paths.image('customStory/arrowUp', 'shared'));
		add(upArrow);

		downArrow = new FlxSprite().loadGraphic(Paths.image('customStory/arrowDown', 'shared'));
		add(downArrow);

		diffSelect = new FlxSprite(710, 480).loadGraphic(Paths.image('customStory/diffSELECT', 'shared'));
		diffSelect.antialiasing = ClientPrefs.data.antialiasing;
		add(diffSelect);

		difficultySprites = new FlxTypedGroup<FlxSprite>();
		add(difficultySprites);

		for (i in 0...diffList.length)
		{
			var diff:FlxSprite = new FlxSprite().loadGraphic(Paths.image('customStory/' + diffList[i], 'shared'));
			diff.ID = i;
			diff.visible = false;
			diff.antialiasing = ClientPrefs.data.antialiasing;
			diff.angle = -10; 

			diff.x = diffSelect.x + (diffSelect.width / 2) - (diff.width / 2);
			diff.y = diffSelect.y + (diffSelect.height / 2) - (diff.height / 2);

			diff.x -= 2;
			diff.y -= 5;

			difficultySprites.add(diff);
		}

		changeSelection();
		changeDiff();
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.UI_UP_P) changeSelection(-1);
		if (controls.UI_DOWN_P) changeSelection(1);
		if (controls.UI_LEFT_P) changeDiff(-1);
		if (controls.UI_RIGHT_P) changeDiff(1);

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if (controls.ACCEPT) selectWeek();

		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		if (change != 0) FlxG.sound.play(Paths.sound('scrollMenu'));
		curWeek = FlxMath.wrap(curWeek + change, 0, weekList.length - 1);

		for (item in weekItems.members) {
			item.alpha = (item.ID == curWeek) ? 1 : 0.35;
			if (item.ID == curWeek) {
				FlxTween.cancelTweensOf(item);
				item.scale.set(1.0, 1.0);
				FlxTween.tween(item.scale, {x: 1.15, y: 1.15}, 0.15, {ease: FlxEase.backOut});
			} else item.scale.set(1, 1);
		}

		for (lock in locks.members) {
			lock.alpha = (lock.ID == curWeek) ? 1 : 0.35;
			lock.x = weekItems.members[lock.ID].x + 155;
		}

		var currentItem = weekItems.members[curWeek];
		upArrow.x = currentItem.x + (currentItem.width / 2) - (upArrow.width / 2);
		upArrow.y = currentItem.y - 65;
		downArrow.x = upArrow.x;
		downArrow.y = currentItem.y + currentItem.height + 25;
		
		upArrow.scale.set(1.3, 1.3);
		FlxTween.tween(upArrow.scale, {x: 1, y: 1}, 0.2);
		downArrow.scale.set(1.3, 1.3);
		FlxTween.tween(downArrow.scale, {x: 1, y: 1}, 0.2);
	}

	function changeDiff(change:Int = 0)
	{
		if (change != 0) FlxG.sound.play(Paths.sound('scrollMenu'));
		curDifficulty = FlxMath.wrap(curDifficulty + change, 0, diffList.length - 1);

		for (diff in difficultySprites.members) {
			diff.visible = (diff.ID == curDifficulty);
			if (diff.visible) {
				diff.scale.set(0.8, 0.8);
				FlxTween.tween(diff.scale, {x: 1, y: 1}, 0.12, {ease: FlxEase.quadOut});
			}
		}
	}

	function selectWeek()
	{
		if (curWeek < 2) { 
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.camera.shake(0.005, 0.1);
			return;
		}

		FlxG.sound.play(Paths.sound('confirmMenu'));

		var diffSuffix = (curDifficulty == 0) ? '-easy' : (curDifficulty == 2 ? '-hard' : '');
		
		var songs:Array<String> = ['tutorial', 'bopeebo', 'fresh']; 
		var songName:String = songs[curWeek].toLowerCase();
		
		PlayState.storyPlaylist = [songName]; 
		PlayState.isStoryMode = true;
		PlayState.storyDifficulty = curDifficulty;
		
		try {
			PlayState.SONG = Song.loadFromJson(songName + diffSuffix, songName);
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;
			
			FlxTween.tween(weekItems.members[curWeek], {alpha: 0}, 0.12, {
				onComplete: function(twn:FlxTween) {
					LoadingState.loadAndSwitchState(new PlayState(), true);
				}
			});
		} catch(e:Dynamic) {
			trace("ERROR: JSON fehlt: " + songName + diffSuffix);
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
	}
}