package mikolka.vslice.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.util.FlxSpriteUtil;
import flixel.group.FlxGroup.FlxTypedGroup;
import mikolka.vslice.ui.mainmenu.DesktopMenuState;
import mikolka.compatibility.ui.MainMenuHooks;
import mikolka.compatibility.VsliceOptions;
import mikolka.vslice.ui.title.TitleState;
import mikolka.compatibility.ModsHelper;
import options.OptionsState;

import mikolka.vslice.ui.StoryMenuState;
import mikolka.vslice.freeplay.FreeplayState;
import states.CreditsState;

class MainMenuState extends MusicBeatState
{
	#if !LEGACY_PSYCH
	public static var psychEngineVersion:String = '1.0.4'; 
	#else
	public static var psychEngineVersion:String = '0.6.3'; 
	#end
	public static var pSliceVersion:String = '3.4.2';
	public static var funkinVersion:String = '0.7.6'; 

	var bg:FlxSprite;
	public var magenta:FlxSprite; 
	
	var hitboxes:FlxTypedGroup<FlxSprite>;
	var tvSprites:FlxTypedGroup<FlxSprite>;
	var lightupSprites:FlxTypedGroup<FlxSprite>;
	var textSprites:FlxTypedGroup<FlxSprite>;
	var iconSprites:FlxTypedGroup<FlxSprite>;

	var assetBasis:Array<String> = ['story_mode', 'freeplay', 'options', 'credits'];
	var stickerSubState:Bool;
	var curSelected:Int = -1;

	public function new(?stickers:Bool = false)
	{
		super();
		stickerSubState = stickers;
	}

	override function create()
	{
		if(stickerSubState) ModsHelper.clearStoredWithoutStickers();
		else CacheSystem.clearStoredMemory();
		CacheSystem.clearUnusedMemory();
		
		#if (debug && !LEGACY_PSYCH)
		FlxG.console.registerFunction("dumpCache",CacheSystem.cacheStatus); 
		FlxG.console.registerFunction("dumpSystem",backend.Native.buildSystemInfo);
		#end
		
		ModsHelper.resetActiveMods();

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("In the Menus", null);
		#end

		persistentUpdate = persistentDraw = true;
		FlxG.mouse.visible = true;

		bg = new FlxSprite().loadGraphic(Paths.image('menuBG'));
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		magenta = new FlxSprite().makeGraphic(1, 1, 0xFF000000);
		magenta.visible = false;
		add(magenta);

		var centerFrame = new FlxSprite().makeGraphic(400, 560, FlxColor.TRANSPARENT);
		FlxSpriteUtil.drawRect(centerFrame, 0, 0, 400, 560, FlxColor.TRANSPARENT, {thickness: 8, color: FlxColor.WHITE});
		centerFrame.screenCenter();
		add(centerFrame);

		hitboxes = new FlxTypedGroup<FlxSprite>();
		add(hitboxes);

		tvSprites = new FlxTypedGroup<FlxSprite>();
		add(tvSprites);

		// Text kommt VOR dem Lightup, damit der Leuchteffekt über dem Text liegt
		textSprites = new FlxTypedGroup<FlxSprite>();
		add(textSprites);

		lightupSprites = new FlxTypedGroup<FlxSprite>();
		add(lightupSprites); 

		iconSprites = new FlxTypedGroup<FlxSprite>();
		add(iconSprites); 

		createMenuItem(0, 0); 
		createMenuItem(1, 1); 
		createMenuItem(2, 2); 
		createMenuItem(3, 3); 

		var psychVer:FlxText = new FlxText(0, FlxG.height - 18, FlxG.width, "Psych Engine " + psychEngineVersion, 12);
		var fnfVer:FlxText = new FlxText(0, FlxG.height - 18, FlxG.width, 'v${funkinVersion} (P-slice ${pSliceVersion})', 12);

		psychVer.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		fnfVer.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		psychVer.scrollFactor.set();
		fnfVer.scrollFactor.set();
		add(psychVer);
		add(fnfVer);

		#if ACHIEVEMENTS_ALLOWED
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18)
			MainMenuHooks.unlockFriday();

		#if MODS_ALLOWED
		MainMenuHooks.reloadAchievements();
		#end
		#end

		super.create();
		
		changeItem(-1); 
	}

	function createMenuItem(corner:Int, id:Int)
	{
		var tv = new FlxSprite().loadGraphic(Paths.image('mainMenu/tv_' + assetBasis[id]));
		var paddingX:Float = -20;
		var paddingY:Float = -20;

		switch(corner) {
			case 0: tv.setPosition(paddingX, paddingY);
			case 1: tv.setPosition(FlxG.width - tv.width - paddingX, paddingY);
			case 2: tv.setPosition(paddingX, FlxG.height - tv.height - paddingY);
			case 3: tv.setPosition(FlxG.width - tv.width - paddingX, FlxG.height - tv.height - paddingY);
		}
		tvSprites.add(tv);

		var hbWidth:Int = 350;
		var hbHeight:Int = 300;
		var hitbox = new FlxSprite();
		switch(corner) {
			case 0: hitbox.makeGraphic(hbWidth, hbHeight, FlxColor.TRANSPARENT); hitbox.setPosition(0, 0);
			case 1: hitbox.makeGraphic(hbWidth, hbHeight, FlxColor.TRANSPARENT); hitbox.setPosition(FlxG.width - hbWidth, 0);
			case 2: hitbox.makeGraphic(hbWidth, hbHeight, FlxColor.TRANSPARENT); hitbox.setPosition(0, FlxG.height - hbHeight);
			case 3: hitbox.makeGraphic(hbWidth, hbHeight, FlxColor.TRANSPARENT); hitbox.setPosition(FlxG.width - hbWidth, FlxG.height - hbHeight);
		}
		hitboxes.add(hitbox);

		// Text permanent im Fernseher zentriert
		var text = new FlxSprite().loadGraphic(Paths.image('mainMenu/' + assetBasis[id]));
		text.x = tv.x + (tv.width - text.width) / 2;
		text.y = tv.y + (tv.height - text.height) / 2;
		textSprites.add(text);

		var lightup = new FlxSprite(tv.x, tv.y).loadGraphic(Paths.image('mainMenu/lightup_' + assetBasis[id]));
		lightupSprites.add(lightup);

		var icon = new FlxSprite().loadGraphic(Paths.image('mainMenu/icon_' + assetBasis[id]));
		icon.updateHitbox();
		icon.screenCenter(); // Mittig im ganzen Screen
		iconSprites.add(icon);
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * elapsed;

		var hoveredId:Int = -1;

		for (i in 0...hitboxes.length)
		{
			if (FlxG.mouse.overlaps(hitboxes.members[i]))
			{
				hoveredId = i;
				
				if (FlxG.mouse.justPressed)
				{
					selectMenu(i);
				}
			}
		}

		if (hoveredId != curSelected)
		{
			changeItem(hoveredId);
		}

		super.update(elapsed);
	}

	function changeItem(newId:Int)
	{
		curSelected = newId;

		for (i in 0...tvSprites.length)
		{
			var isSelected = (i == curSelected);
			
			// Nur noch Leuchten und Icon werden ein-/ausgeblendet
			lightupSprites.members[i].visible = isSelected;
			iconSprites.members[i].visible = isSelected;
			
			// Text bleibt immer sichtbar, wird hier nicht mehr verändert
		}
	}

	function selectMenu(id:Int)
	{
		switch(id)
		{
			case 0: MusicBeatState.switchState(new CSTStoryMenuState());
			case 1: MusicBeatState.switchState(new FreeplayState());
			case 2: goToOptions();
			case 3: MusicBeatState.switchState(new CreditsState());
		}
	}

	function goToOptions()
	{
		MusicBeatState.switchState(new OptionsState());
		#if !LEGACY_PSYCH OptionsState.onPlayState = false; #end
		if (PlayState.SONG != null)
		{
			PlayState.SONG.arrowSkin = null;
			PlayState.SONG.splashSkin = null;
			#if !LEGACY_PSYCH PlayState.stageUI = 'normal'; #end
		}
	}
}