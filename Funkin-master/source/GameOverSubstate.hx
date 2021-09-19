package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;
	public static var undisturbedRJ:Bool = false;
	var stageSuffix:String = "";

	public function new(x:Float, y:Float)
	{
		var daStage = PlayState.curStage;
		var daBf:String = '';
		switch (daStage)
		{
			case 'school':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			case 'schoolEvil':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			case 'mystage':
				daBf = 'purpbf';
			case 'finalbattle':
				daBf = 'rj';
			case 'bossmodestage':
				daBf = 'purpbf';
			case 'bonus':
				if (undisturbedRJ == true){
					daBf = 'rj';
				}	
				else{
				daBf = 'baserj';
				}
			default:
				daBf = 'bf';
		}

		

		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, daBf);
		if(daBf == 'rj'){
			bf.setGraphicSize(Std.int(bf.width * 3));
			bf.screenCenter(X);
			bf.screenCenter(Y);
		}
		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		if(daStage == 'bonus'){
			if (undisturbedRJ == true){
				FlxG.sound.play(Paths.sound('rjdefeatsound'));
			}
			else{
				FlxG.sound.play(Paths.sound('rj_vanish'));
			}
		}
		else if(daStage == 'finalbattle'){
		FlxG.sound.play(Paths.sound('rjdefeatsound'));
		}
		else{
		FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));
		}
		Conductor.changeBPM(100);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		var daStage = PlayState.curStage;
		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
				FlxG.switchState(new StoryMenuState());
			else
				FlxG.switchState(new FreeplayState());
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			if(daStage == 'mystage' || daStage == 'finalbattle' || daStage == 'bossmodestage' || daStage == 'bonus'){
				FlxG.sound.playMusic(Paths.music('gameOverCalamity'));
			}
			else{
				FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
			}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		var daStage = PlayState.curStage;
		if (!isEnding)
		{
			
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			if(daStage == 'mystage' || daStage == 'finalbattle' || daStage == 'bossmodestage' || daStage == 'bonus'){
				FlxG.sound.play(Paths.music('gameOverEndCalamity'));
			}
			else{
			FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));
			}
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}
