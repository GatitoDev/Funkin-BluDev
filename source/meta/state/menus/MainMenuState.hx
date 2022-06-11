package meta.state.menus;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import meta.Controls.Control;
import meta.MusicBeat.MusicBeatState;
import meta.data.Song.SwagSong;
import meta.data.dependency.Discord;

using StringTools;

/**
	This is the main menu state! Not a lot is going to change about it so it'll remain similar to the original, but I do want to condense some code and such.
	Get as expressive as you can with this, create your own menu!
**/
class MainMenuState extends MusicBeatState
{
	var menuItems:FlxTypedGroup<FlxSprite>;
	var curSelected:Float = 0;

	var bg:FlxSprite; // the background has been separated for more control
	var magenta:FlxSprite;
	var camFollow:FlxObject;

	// private var SONG = PlayState.SONG;
	public static var SONG:SwagSong;

	// don't take this away
	var floor:FlxSprite;
	var laptop:FlxSprite;
	var moon:FlxSprite;

	// versionShit
	var versionShit:FlxText;

	var optionShit:Array<String> = [
		'story mode',
		'freeplay', 
		'options'
	];
	var canSnap:Array<Float> = [];

	// the create 'state'
	override function create()
	{
		super.create();

		// set the transitions to the previously set ones
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		// make sure the music is playing
		ForeverTools.resetMenuMusic();

		#if !html5
		Discord.changePresence('MENU SCREEN', 'Main Menu');
		#end

		// uh
		persistentUpdate = persistentDraw = true;

		// background
		bg = new FlxSprite(-85);
		bg.loadGraphic(Paths.image('menus/emptyop/bg'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		floor = new FlxSprite(0, 0); // does not take this into account
		floor.loadGraphic(Paths.image('menus/emptyop/floor'));
		floor.scrollFactor.x = 0;
		floor.scrollFactor.y = 0.35;
		floor.setGraphicSize(Std.int(floor.width * 0.4));
		floor.updateHitbox();
		floor.screenCenter();
		floor.antialiasing = true; // yes
		
		// The position
		//floor.x = 350;
		floor.y = 350;
		add(floor);

		laptop = new FlxSprite(0, 0); // does not take this into account
		laptop.loadGraphic(Paths.image('menus/emptyop/laptop'));
		laptop.scrollFactor.x = 0;
		laptop.scrollFactor.y = 0.35;
		laptop.setGraphicSize(Std.int(laptop.width * 0.4));
		laptop.updateHitbox();
		laptop.screenCenter();
		laptop.antialiasing = true; // yes
		laptop.x = 400;
		laptop.y = 95;

		moon = new FlxSprite(0, 0); // does not take this into account
		moon.loadGraphic(Paths.image('menus/emptyop/moon'));
		moon.scrollFactor.x = 0;
		moon.scrollFactor.y = 0.35;
		moon.setGraphicSize(Std.int(moon.width * 0.4));
		moon.updateHitbox();
		moon.screenCenter();
		moon.antialiasing = true; // yes
		moon.x = 600;
		moon.y = 98;

		add(laptop);
		add(moon);

		FlxTween.tween(laptop, {y: laptop.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		FlxTween.tween(moon, {y: moon.y + 53}, 0.8, {ease: FlxEase.quadInOut, type: PINGPONG});

		/* // I don't think there is a need to use this?
		magenta = new FlxSprite(-85).loadGraphic(Paths.image('menus/base/menuDesat'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.18;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFF433894;
		add(magenta);
		*/

		// add the camera
		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		// add the menu items
		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		// create the menu items themselves
		var tex = Paths.getSparrowAtlas('menus/base/title/FNF_main_menu_assets');

		// loop through the menu options
		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 80 + (i * 160));
			menuItem.frames = tex;
			// add the animations in a cool way (real
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			canSnap[i] = -1;
			// set the id
			menuItem.ID = i;
			// menuItem.alpha = 0;

			menuItem.x = 35; // Actual position

			// actually add the item
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
			menuItem.setGraphicSize(Std.int(menuItem.width * 0.8));
			menuItem.updateHitbox();

			/*
				FlxTween.tween(menuItem, {alpha: 1, x: ((FlxG.width / 2) - (menuItem.width / 2))}, 0.35, {
					ease: FlxEase.smootherStepInOut,
					onComplete: function(tween:FlxTween)
					{
						canSnap[i] = 0;
					}
			});*/
		}

		// set the camera to actually follow the camera object that was created before
		var camLerp = Main.framerateAdjust(0.10);
		FlxG.camera.follow(camFollow, null, camLerp);

		updateSelection();

		// from the base game lol

		versionShit = new FlxText(5, FlxG.height - 24, 0, "Forever Engine v " + Main.gameVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		// I want to sleep?
		var creditsShit:FlxText = new FlxText(5, FlxG.height - 42, 0, "@" + Main.creditsG, 12);
		creditsShit.scrollFactor.set();
		creditsShit.setFormat("VCR OSD Mono", 18, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		// add(creditsShit);

		// FlxTween.tween(versionShit, {y: FlxG.height - 20}, 1, {ease: FlxEase.elasticInOut});

		//
	}

	// var colorTest:Float = 0;
	var selectedSomethin:Bool = false;
	var counterControl:Float = 0;

	override function update(elapsed:Float)
	{
		// colorTest += 0.125;
		// bg.color = FlxColor.fromHSB(colorTest, 100, 100, 0.5);

		var up = controls.UI_UP;
		var down = controls.UI_DOWN;
		var up_p = controls.UI_UP_P;
		var down_p = controls.UI_DOWN_P;
		var controlArray:Array<Bool> = [up, down, up_p, down_p];

		if ((controlArray.contains(true)) && (!selectedSomethin))
		{
			for (i in 0...controlArray.length)
			{
				// here we check which keys are pressed
				if (controlArray[i] == true)
				{
					// if single press
					if (i > 1)
					{
						// up is 2 and down is 3
						// paaaaaiiiiiiinnnnn
						if (i == 2)
							curSelected--;
						else if (i == 3)
							curSelected++;

						FlxG.sound.play(Paths.sound('scrollMenu'));
					}
					/* idk something about it isn't working yet I'll rewrite it later
						else
						{
							// paaaaaaaiiiiiiiinnnn
							var curDir:Int = 0;
							if (i == 0)
								curDir = -1;
							else if (i == 1)
								curDir = 1;

							if (counterControl < 2)
								counterControl += 0.05;

							if (counterControl >= 1)
							{
								curSelected += (curDir * (counterControl / 24));
								if (curSelected % 1 == 0)
									FlxG.sound.play(Paths.sound('scrollMenu'));
							}
					}*/

					if (curSelected < 0)
						curSelected = optionShit.length - 1;
					else if (curSelected >= optionShit.length)
						curSelected = 0;
				}
				//
			}
		}
		else
		{
			// reset variables
			counterControl = 0;
		}

		if ((controls.ACCEPT) && (!selectedSomethin))
		{
			//
			selectedSomethin = true;
			FlxG.sound.play(Paths.sound('confirmMenu'));

			// FlxFlicker.flicker(magenta, 0.8, 0.1, false);
			FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.2}, 0.5, {ease: FlxEase.quadOut});
			
			FlxTween.tween(floor, {y: 1280}, 2, {ease: FlxEase.quadIn});
			FlxTween.tween(laptop, {y: 1280}, 2, {ease: FlxEase.quadIn});
			FlxTween.tween(moon, {y: 1280}, 2, {ease: FlxEase.quadIn});

			menuItems.forEach(function(spr:FlxSprite)
			{
				new FlxTimer().start(0.1, function(tmr:FlxTimer)
				{
					FlxTween.tween(spr, {x: 400}, 0.5, {ease: FlxEase.circIn});
					//spr.x = 350;
				});
			});

			menuItems.forEach(function(spr:FlxSprite)
			{
				if (curSelected != spr.ID)
				{
					FlxTween.tween(spr, {x: -1280}, 1.5, {ease: FlxEase.quadIn});
					new FlxTimer().start(1.5, function(tmr:FlxTimer)
					{
						spr.x = -1280;
					});
					
					FlxTween.tween(spr, {alpha: 0, x: FlxG.width * 2}, 0.4, {
						ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween)
						{
							spr.kill();
						}
					});
				}
				else
				{
					FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
					{
						var daChoice:String = optionShit[Math.floor(curSelected)];

						switch (daChoice)
						{
							case 'story mode':
								Main.switchState(this, new StoryMenuState());
							case 'freeplay':
								Main.switchState(this, new FreeplayState());
							case 'options':
								transIn = FlxTransitionableState.defaultTransIn;
								transOut = FlxTransitionableState.defaultTransOut;
								Main.switchState(this, new OptionsMenuState());
						}
					});
				}
			});
		}

		if (Math.floor(curSelected) != lastCurSelected)
			updateSelection();

		super.update(elapsed);

		menuItems.forEach(function(menuItem:FlxSprite)
		{
			// menuItem.x = 35;
		});
	}

	var lastCurSelected:Int = 0;

	private function updateSelection()
	{
		// reset all selections
		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();
		});

		// set the sprites and all of the current selection
		camFollow.setPosition(menuItems.members[Math.floor(curSelected)].getGraphicMidpoint().x,
			menuItems.members[Math.floor(curSelected)].getGraphicMidpoint().y);

		if (menuItems.members[Math.floor(curSelected)].animation.curAnim.name == 'idle')
			menuItems.members[Math.floor(curSelected)].animation.play('selected');

		menuItems.members[Math.floor(curSelected)].updateHitbox();

		lastCurSelected = Math.floor(curSelected);
	}
}
