package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxSprite;

class BossModeOverSubstate extends MusicBeatSubstate
{
	//i randomly put this together, the code is a mess

	public function new(x:Float, y:Float)
	{
	super();
	var bossmodeend:FlxSprite = new FlxSprite(0, 0);
	bossmodeend.frames = Paths.getSparrowAtlas('bossmodeend');
	bossmodeend.animation.addByPrefix('idle', 'deitiesIntro', 20, false);
	//bossmodeend.animation.play('idle');
	bossmodeend.scrollFactor.set(0, 0);
	bossmodeend.scale.set(2.4, 2.4);

	add(bossmodeend);
	//bossmodeend.cameras = [camHUD];
	bossmodeend.antialiasing = true;
	bossmodeend.screenCenter();
	//super();

	//Conductor.songPosition = 0;
	//FlxG.sound.play(Paths.sound('deitiesaudio'), 1, false, null, true, function()
	//{

	//});
	new FlxTimer().start(1, function(cutsceneTime:FlxTimer)
	{
		FlxG.sound.play(Paths.sound('bossmodeendsounds'), 1, false, null, true, function()
		{
		});
		bossmodeend.animation.play('idle');
	});	
	new FlxTimer().start(11, function(deadTime:FlxTimer)
	{
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
				FlxG.switchState(new StoryMenuState());
			else
				FlxG.switchState(new FreeplayState());
	});									
	//var bf:Boyfriend;
	//var camFollow:FlxObject;

	//var stageSuffix:String = "";
	}
}
