package;
//hey, just wanted to leave this message here and say that i worked pretty hard on this. feel free to use anything i added here for this mod to help make yours, but please credit me somewhere in the code if you do, thats all i ask - 3RJ
#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	var halloweenLevel:Bool = false;

	

	private var vocals:FlxSound;

	private var dad:Character;
	private var gf:Character;
	private var allseer:Character;
	//dont think about this allseer thing too much, its nothing
	private var boyfriend:Boyfriend;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var bossModeHealth:Int = 5;
	private var bossModeHits:Int = 0;
	private var bossModeMisses:Int = 0;
	private var combo:Int = 0;

	private var healthBarBG:FlxSprite;
	private var healthBarBGShard:FlxSprite;
	private var vsbg:FlxSprite;
	private var vs:FlxSprite;
	private var hearts:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var VSIconP1:HealthIcon;
	private var VSIconP2:HealthIcon;
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;
	//var spaceBlk = true;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;
	var spaceblk:FlxSprite;
	var rjAnim:FlxSprite;
	var rjEndAnim:FlxSprite;
	var gfTP:FlxSprite;
	var flame:FlxSprite;
	var credits:FlxSprite;
	var shardAbility:FlxSprite;
	var immortalityIcon:FlxSprite;
	var immortalityIconReady:FlxSprite;
	var antiPause:FlxSprite;
	var deitiesbg:FlxSprite;
	var sky:FlxSprite;
	var bgfront:FlxSprite;
	var bgback:FlxSprite;
	var caveFront:FlxSprite;
	var deitiestransition:FlxSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var immortalityReady:Bool = true;
	var talking:Bool = true;
	var songScore:Int = 0;
	var scoreTxt:FlxText;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	var inCutscene:Bool = false;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var songLength:Float = 0;
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	override public function create()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		switch (SONG.song.toLowerCase())
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go \nthrough ME first!"
				];
			case 'fresh':
				dialogue = ["Not too shabby boy.", ""];
			case 'dadbattle':
				dialogue = [
					"gah you think you're hot stuff?",
					"If you can beat me here...",
					"Only then I will even CONSIDER letting you\ndate my daughter!"
				];
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('thorns/thornsDialogue'));
			case 'prismatic':
				dialogue = CoolUtil.coolTextFile(Paths.txt('prismatic/prismaticDialogue'));
			case 'no-newton':
				dialogue = CoolUtil.coolTextFile(Paths.txt('no-newton/no-newtonDialogue'));
			case 'calamity':
				dialogue = CoolUtil.coolTextFile(Paths.txt('calamity/calamityDialogue'));
			case 'resurrection':
				dialogue = CoolUtil.coolTextFile(Paths.txt('resurrection/resurrectionDialogue'));
			case 'undisturbed':
				dialogue = CoolUtil.coolTextFile(Paths.txt('undisturbed/undisturbedDialogue'));
		}

		#if desktop
		// Making difficulty text for Discord Rich Presence.
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
		}

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		#end

		switch (SONG.song.toLowerCase())
		{
                        case 'spookeez' | 'monster' | 'south': 
                        {
                                curStage = 'spooky';
	                          halloweenLevel = true;

		                  var hallowTex = Paths.getSparrowAtlas('halloween_bg');

	                          halloweenBG = new FlxSprite(-200, -100);
		                  halloweenBG.frames = hallowTex;
	                          halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
	                          halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
	                          halloweenBG.animation.play('idle');
	                          halloweenBG.antialiasing = true;
	                          add(halloweenBG);

		                  isHalloween = true;
		          }
		          case 'pico' | 'blammed' | 'philly': 
                        {
		                  curStage = 'philly';

		                  var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky'));
		                  bg.scrollFactor.set(0.1, 0.1);
		                  add(bg);

	                          var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city'));
		                  city.scrollFactor.set(0.3, 0.3);
		                  city.setGraphicSize(Std.int(city.width * 0.85));
		                  city.updateHitbox();
		                  add(city);

		                  phillyCityLights = new FlxTypedGroup<FlxSprite>();
		                  add(phillyCityLights);

		                  for (i in 0...5)
		                  {
		                          var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i));
		                          light.scrollFactor.set(0.3, 0.3);
		                          light.visible = false;
		                          light.setGraphicSize(Std.int(light.width * 0.85));
		                          light.updateHitbox();
		                          light.antialiasing = true;
		                          phillyCityLights.add(light);
		                  }

		                  var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain'));
		                  add(streetBehind);

	                          phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train'));
		                  add(phillyTrain);

		                  trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
		                  FlxG.sound.list.add(trainSound);

		                  // var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

		                  var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street'));
	                          add(street);
		          }
		          case 'milf' | 'satin-panties' | 'high':
		          {
		                  curStage = 'limo';
		                  defaultCamZoom = 0.90;

		                  var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset'));
		                  skyBG.scrollFactor.set(0.1, 0.1);
		                  add(skyBG);

		                  var bgLimo:FlxSprite = new FlxSprite(-200, 480);
		                  bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo');
		                  bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
		                  bgLimo.animation.play('drive');
		                  bgLimo.scrollFactor.set(0.4, 0.4);
		                  add(bgLimo);

		                  grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
		                  add(grpLimoDancers);

		                  for (i in 0...5)
		                  {
		                          var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
		                          dancer.scrollFactor.set(0.4, 0.4);
		                          grpLimoDancers.add(dancer);
		                  }

		                  var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay'));
		                  overlayShit.alpha = 0.5;
		                  // add(overlayShit);

		                  // var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

		                  // FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

		                  // overlayShit.shader = shaderBullshit;

		                  var limoTex = Paths.getSparrowAtlas('limo/limoDrive');

		                  limo = new FlxSprite(-120, 550);
		                  limo.frames = limoTex;
		                  limo.animation.addByPrefix('drive', "Limo stage", 24);
		                  limo.animation.play('drive');
		                  limo.antialiasing = true;

		                  fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol'));
		                  // add(limo);
		          }
		          case 'cocoa' | 'eggnog':
		          {
	                          curStage = 'mall';

		                  defaultCamZoom = 0.80;

		                  var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.2, 0.2);
		                  bg.active = false;
		                  bg.setGraphicSize(Std.int(bg.width * 0.8));
		                  bg.updateHitbox();
		                  add(bg);

		                  upperBoppers = new FlxSprite(-240, -90);
		                  upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop');
		                  upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
		                  upperBoppers.antialiasing = true;
		                  upperBoppers.scrollFactor.set(0.33, 0.33);
		                  upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
		                  upperBoppers.updateHitbox();
		                  add(upperBoppers);

		                  var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator'));
		                  bgEscalator.antialiasing = true;
		                  bgEscalator.scrollFactor.set(0.3, 0.3);
		                  bgEscalator.active = false;
		                  bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
		                  bgEscalator.updateHitbox();
		                  add(bgEscalator);

		                  var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree'));
		                  tree.antialiasing = true;
		                  tree.scrollFactor.set(0.40, 0.40);
		                  add(tree);

		                  bottomBoppers = new FlxSprite(-300, 140);
		                  bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop');
		                  bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
		                  bottomBoppers.antialiasing = true;
	                          bottomBoppers.scrollFactor.set(0.9, 0.9);
	                          bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
		                  bottomBoppers.updateHitbox();
		                  add(bottomBoppers);

		                  var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow'));
		                  fgSnow.active = false;
		                  fgSnow.antialiasing = true;
		                  add(fgSnow);

		                  santa = new FlxSprite(-840, 150);
		                  santa.frames = Paths.getSparrowAtlas('christmas/santa');
		                  santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
		                  santa.antialiasing = true;
		                  add(santa);
		          }
		          case 'winter-horrorland':
		          {
		                  curStage = 'mallEvil';
		                  var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.2, 0.2);
		                  bg.active = false;
		                  bg.setGraphicSize(Std.int(bg.width * 0.8));
		                  bg.updateHitbox();
		                  add(bg);

		                  var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree'));
		                  evilTree.antialiasing = true;
		                  evilTree.scrollFactor.set(0.2, 0.2);
		                  add(evilTree);

		                  var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow"));
	                          evilSnow.antialiasing = true;
		                  add(evilSnow);
                        }
		          case 'senpai' | 'roses':
		          {
		                  curStage = 'school';

		                  // defaultCamZoom = 0.9;

		                  var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky'));
		                  bgSky.scrollFactor.set(0.1, 0.1);
		                  add(bgSky);

		                  var repositionShit = -200;

		                  var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool'));
		                  bgSchool.scrollFactor.set(0.6, 0.90);
		                  add(bgSchool);

		                  var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet'));
		                  bgStreet.scrollFactor.set(0.95, 0.95);
		                  add(bgStreet);

		                  var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack'));
		                  fgTrees.scrollFactor.set(0.9, 0.9);
		                  add(fgTrees);

		                  var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
		                  var treetex = Paths.getPackerAtlas('weeb/weebTrees');
		                  bgTrees.frames = treetex;
		                  bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
		                  bgTrees.animation.play('treeLoop');
		                  bgTrees.scrollFactor.set(0.85, 0.85);
		                  add(bgTrees);

		                  var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
		                  treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals');
		                  treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
		                  treeLeaves.animation.play('leaves');
		                  treeLeaves.scrollFactor.set(0.85, 0.85);
		                  add(treeLeaves);

		                  var widShit = Std.int(bgSky.width * 6);

		                  bgSky.setGraphicSize(widShit);
		                  bgSchool.setGraphicSize(widShit);
		                  bgStreet.setGraphicSize(widShit);
		                  bgTrees.setGraphicSize(Std.int(widShit * 1.4));
		                  fgTrees.setGraphicSize(Std.int(widShit * 0.8));
		                  treeLeaves.setGraphicSize(widShit);

		                  fgTrees.updateHitbox();
		                  bgSky.updateHitbox();
		                  bgSchool.updateHitbox();
		                  bgStreet.updateHitbox();
		                  bgTrees.updateHitbox();
		                  treeLeaves.updateHitbox();

		                  bgGirls = new BackgroundGirls(-100, 190);
		                  bgGirls.scrollFactor.set(0.9, 0.9);

		                  if (SONG.song.toLowerCase() == 'roses')
	                          {
		                          bgGirls.getScared();
		                  }

		                  bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
		                  bgGirls.updateHitbox();
		                  add(bgGirls);
		          }
		          case 'thorns':
		          {
		                  curStage = 'schoolEvil';

		                  var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
		                  var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

		                  var posX = 400;
	                          var posY = 200;

		                  var bg:FlxSprite = new FlxSprite(posX, posY);
		                  bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool');
		                  bg.animation.addByPrefix('idle', 'background 2', 24);
		                  bg.animation.play('idle');
		                  bg.scrollFactor.set(0.8, 0.9);
		                  bg.scale.set(6, 6);
		                  add(bg);

		                  /* 
		                           var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolBG'));
		                           bg.scale.set(6, 6);
		                           // bg.setGraphicSize(Std.int(bg.width * 6));
		                           // bg.updateHitbox();
		                           add(bg);

		                           var fg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolFG'));
		                           fg.scale.set(6, 6);
		                           // fg.setGraphicSize(Std.int(fg.width * 6));
		                           // fg.updateHitbox();
		                           add(fg);

		                           wiggleShit.effectType = WiggleEffectType.DREAMY;
		                           wiggleShit.waveAmplitude = 0.01;
		                           wiggleShit.waveFrequency = 60;
		                           wiggleShit.waveSpeed = 0.8;
		                    */

		                  // bg.shader = wiggleShit.shader;
		                  // fg.shader = wiggleShit.shader;

		                  /* 
		                            var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);
		                            var waveSpriteFG = new FlxEffectSprite(fg, [waveEffectFG]);

		                            // Using scale since setGraphicSize() doesnt work???
		                            waveSprite.scale.set(6, 6);
		                            waveSpriteFG.scale.set(6, 6);
		                            waveSprite.setPosition(posX, posY);
		                            waveSpriteFG.setPosition(posX, posY);

		                            waveSprite.scrollFactor.set(0.7, 0.8);
		                            waveSpriteFG.scrollFactor.set(0.9, 0.8);

		                            // waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
		                            // waveSprite.updateHitbox();
		                            // waveSpriteFG.setGraphicSize(Std.int(fg.width * 6));
		                            // waveSpriteFG.updateHitbox();

		                            add(waveSprite);
		                            add(waveSpriteFG);
		                    */
		          }
				  case 'prismatic':
				  {
						  defaultCamZoom = 0.8;
		                  curStage = 'cave';
		                  var sky:FlxSprite = new FlxSprite(-1250, -700).loadGraphic(Paths.image('cavesky'));
		                  sky.antialiasing = true;
		                  sky.scrollFactor.set(0.01, 0.01);
						  sky.setGraphicSize(Std.int(sky.width * 0.45));
		                  sky.active = false;
		                  add(sky);

						  var bgback:FlxSprite = new FlxSprite(-1250, -700).loadGraphic(Paths.image('cavebgback'));
		                  bgback.antialiasing = true;
		                  bgback.scrollFactor.set(0.1, 0.1);
						  bgback.setGraphicSize(Std.int(bgback.width * 0.45));
		                  bgback.active = false;
		                  add(bgback);

						  var bgfront:FlxSprite = new FlxSprite(-1250, -700).loadGraphic(Paths.image('cavebgfront'));
		                  bgfront.antialiasing = true;
		                  bgfront.scrollFactor.set(0.2, 0.2);
						  bgfront.setGraphicSize(Std.int(bgfront.width * 0.45));
		                  bgfront.active = false;
		                  add(bgfront);

		                  var caveFront:FlxSprite = new FlxSprite(-420, 400).loadGraphic(Paths.image('cavefront'));
		                  caveFront.setGraphicSize(Std.int(caveFront.width * 0.6));
						  caveFront.scrollFactor.set(0.9, 0.9);
		                  caveFront.updateHitbox();
		                  caveFront.antialiasing = true;
		                  caveFront.active = false;
		                  add(caveFront);

		                  /*var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
		                  stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
		                  stageCurtains.updateHitbox();
		                  stageCurtains.antialiasing = true;
		                  stageCurtains.scrollFactor.set(1.3, 1.3);
		                  stageCurtains.active = false;

		                  add(stageCurtains);*/
				  }
				  case 'no-newton':
		          {
		                  defaultCamZoom = 0.9;
		                  curStage = 'mystage2';
		                  var bg:FlxSprite = new FlxSprite(-1400, -700).loadGraphic(Paths.image('spacebg1'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.05, 0.05);
						  bg.setGraphicSize(Std.int(bg.width * 0.58));
		                  bg.active = false;
		                  add(bg);

		                  var spaceFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('spacefront'));
							spaceFront.setGraphicSize(Std.int(spaceFront.width * 1.0));
							spaceFront.updateHitbox();
							spaceFront.antialiasing = true;
							spaceFront.scrollFactor.set(0.9, 0.9);
							spaceFront.active = false;
							//spaceFront.y += 500;
							add(spaceFront);
		          }
				   case 'calamity':
		          {
						  
	
		                  defaultCamZoom = 0.5;
		                  
		                  /*var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.9, 0.9);
		                  bg.active = false;
		                  add(bg);*/

						  //dad = new Character(100, 100, SONG.player2);
						  //add(dad);
						  curStage = 'mystage';
						  
						var spacebg:FlxSprite = new FlxSprite(-1380, -500).loadGraphic(Paths.image('spaceback'));
		                    spacebg.antialiasing = true;
		                    spacebg.scrollFactor.set(0.1, 0.1);
		                    spacebg.active = false;
		                    add(spacebg);

						var spacestarspurp:FlxSprite = new FlxSprite(-1380, -500).loadGraphic(Paths.image('spacestarspurp'));
		                    spacestarspurp.antialiasing = true;
		                    spacestarspurp.scrollFactor.set(0.15, 0.15);
		                    spacestarspurp.active = false;
		                    add(spacestarspurp);

						var spacecrystalsback:FlxSprite = new FlxSprite(-1380, -500).loadGraphic(Paths.image('spacecrystalsback'));
		                    spacecrystalsback.antialiasing = true;
		                    spacecrystalsback.scrollFactor.set(0.25, 0.25);
		                    spacecrystalsback.active = false;
		                    add(spacecrystalsback);

						var spacecrystalsfront:FlxSprite = new FlxSprite(-1380, -500).loadGraphic(Paths.image('spacecrystalsfront'));
		                    spacecrystalsfront.antialiasing = true;
		                    spacecrystalsfront.scrollFactor.set(0.35, 0.35);
		                    spacecrystalsfront.active = false;
		                    add(spacecrystalsfront);

						    spaceblk = new FlxSprite(-1380, -500).loadGraphic(Paths.image('spaceblack'));
		                    //spaceblk.antialiasing = true;
		                    //spaceblk.scrollFactor.set(0.1, 0.1);
		                    //spaceblk.active = false;
		                    add(spaceblk);
						  
						  

		        
		          }
				   case 'calamity-boss-mode':
		          {
						  
	
		                  defaultCamZoom = 0.5;
		                  
		                  /*var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.9, 0.9);
		                  bg.active = false;
		                  add(bg);*/

						  //dad = new Character(100, 100, SONG.player2);
						  //add(dad);
						  curStage = 'bossmodestage';
						  
						var spacebg:FlxSprite = new FlxSprite(-1380, -500).loadGraphic(Paths.image('spaceback'));
		                    spacebg.antialiasing = true;
		                    spacebg.scrollFactor.set(0.1, 0.1);
		                    spacebg.active = false;
		                    add(spacebg);

						var spacestarspurp:FlxSprite = new FlxSprite(-1380, -500).loadGraphic(Paths.image('spacestarspurp'));
		                    spacestarspurp.antialiasing = true;
		                    spacestarspurp.scrollFactor.set(0.15, 0.15);
		                    spacestarspurp.active = false;
		                    add(spacestarspurp);

						var spacecrystalsback:FlxSprite = new FlxSprite(-1380, -500).loadGraphic(Paths.image('spacecrystalsback'));
		                    spacecrystalsback.antialiasing = true;
		                    spacecrystalsback.scrollFactor.set(0.25, 0.25);
		                    spacecrystalsback.active = false;
		                    add(spacecrystalsback);

						var spacecrystalsfront:FlxSprite = new FlxSprite(-1380, -500).loadGraphic(Paths.image('spacecrystalsfront'));
		                    spacecrystalsfront.antialiasing = true;
		                    spacecrystalsfront.scrollFactor.set(0.35, 0.35);
		                    spacecrystalsfront.active = false;
		                    add(spacecrystalsfront);

						    spaceblk = new FlxSprite(-1380, -500).loadGraphic(Paths.image('spaceblack'));
		                    //spaceblk.antialiasing = true;
		                    //spaceblk.scrollFactor.set(0.1, 0.1);
		                    //spaceblk.active = false;
		                    add(spaceblk);
						  
						  

		        
		          }
				  case 'deities':
		          {
		                  defaultCamZoom = 0.3;
		                  curStage = 'finalbattle';
		                  /*var bg:FlxSprite = new FlxSprite(-1400, -700).loadGraphic(Paths.image('spacebg1'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.05, 0.05);
						  bg.setGraphicSize(Std.int(bg.width * 0.78));
		                  bg.active = false;
		                  add(bg);*/

						  deitiesbg = new FlxSprite(0, 0);
		                  deitiesbg.frames = Paths.getSparrowAtlas('energybg');
		                  deitiesbg.animation.addByPrefix('idle', 'energy back', 24);
		                  deitiesbg.animation.play('idle');
		                  deitiesbg.scrollFactor.set(0, 0);
		                  deitiesbg.scale.set(3.5, 3.5);
		                  add(deitiesbg);

						  deitiestransition = new FlxSprite(100, 0);
						  deitiestransition.frames = Paths.getSparrowAtlas('deitiestransition');
						  deitiestransition.animation.addByPrefix('idle', 'transition', 20, false);
						  //deitiestransition.animation.play('idle');
						  deitiestransition.scrollFactor.set(0, 0);
						  deitiestransition.scale.set(1.19, 1.19);
						  add(deitiestransition);
						  
		          }
				  case 'resurrection':
				  {
						  defaultCamZoom = 0.8;
		                  curStage = 'caveday';
		                  var sky:FlxSprite = new FlxSprite(-1250, -700).loadGraphic(Paths.image('caveskyday'));
		                  sky.antialiasing = true;
		                  sky.scrollFactor.set(0.01, 0.01);
						  sky.setGraphicSize(Std.int(sky.width * 0.45));
		                  sky.active = false;
		                  add(sky);

						  var ravine:FlxSprite = new FlxSprite(-1250, -700).loadGraphic(Paths.image('cavebgravineday'));
		                  ravine.antialiasing = true;
		                  ravine.scrollFactor.set(0.02, 0.02);
						  ravine.setGraphicSize(Std.int(ravine.width * 0.45));
		                  ravine.active = false;
		                  add(ravine);

						  var bgback:FlxSprite = new FlxSprite(-1250, -700).loadGraphic(Paths.image('cavebgbackday'));
		                  bgback.antialiasing = true;
		                  bgback.scrollFactor.set(0.1, 0.1);
						  bgback.setGraphicSize(Std.int(bgback.width * 0.45));
		                  bgback.active = false;
		                  add(bgback);

						  var bgfront:FlxSprite = new FlxSprite(-1250, -700).loadGraphic(Paths.image('cavebgfrontday'));
		                  bgfront.antialiasing = true;
		                  bgfront.scrollFactor.set(0.2, 0.2);
						  bgfront.setGraphicSize(Std.int(bgfront.width * 0.45));
		                  bgfront.active = false;
		                  add(bgfront);

		                  var caveFront:FlxSprite = new FlxSprite(-420, 400).loadGraphic(Paths.image('cavefrontday'));
		                  caveFront.setGraphicSize(Std.int(caveFront.width * 0.6));
						  caveFront.scrollFactor.set(0.9, 0.9);
		                  caveFront.updateHitbox();
		                  caveFront.antialiasing = true;
		                  caveFront.active = false;
		                  add(caveFront);

						  gfTP = new FlxSprite(-700, 75);
						  gfTP.frames = Paths.getSparrowAtlas('gfTeleport');
						  gfTP.animation.addByPrefix('tp', 'teleport', 20, false);
						  //rjEndAnim.animation.play('idle');
						  gfTP.scrollFactor.set(.95, .95);
						  gfTP.scale.set(.85, .85);
						  gfTP.antialiasing = true;
						  add(gfTP);

						  rjEndAnim = new FlxSprite(470, 75);
						  rjEndAnim.frames = Paths.getSparrowAtlas('rj_end_anims');
						  rjEndAnim.animation.addByPrefix('anim', 'rj_anim', 20, false);
						  rjEndAnim.animation.addByPrefix('hands', 'rj_hands', 20, false);
						  //rjEndAnim.animation.play('idle');
						  rjEndAnim.scrollFactor.set(.95, .95);
						  rjEndAnim.scale.set(.85, .85);
						  rjEndAnim.antialiasing = true;
						  add(rjEndAnim);

						  flame = new FlxSprite(470, 75);
						  flame.frames = Paths.getSparrowAtlas('bf_flame');
						  flame.animation.addByPrefix('flamestart', 'flame start ', 20, false);
						  flame.animation.addByPrefix('flameburn', 'flame burn ', 20, true);
						  //rjEndAnim.animation.play('idle');
						  flame.scrollFactor.set(.95, .95);
						  flame.scale.set(1, 1);
						  flame.antialiasing = true;
						  //add(flame);

						  credits = new FlxSprite(0, -50);
						  credits.frames = Paths.getSparrowAtlas('endCredits');
						  credits.animation.addByPrefix('one', 'creditsOne ', 20, false);
						  credits.animation.addByPrefix('two', 'creditsTwo ', 20, false);
						  credits.animation.addByPrefix('three', 'creditsThree ', 20, false);
						  credits.animation.addByPrefix('four', 'creditsFour ', 20, false);
						  credits.animation.addByPrefix('five', 'creditsFive ', 20, false);
						  credits.animation.addByPrefix('six', 'creditsSix ', 20, false);
						  credits.scrollFactor.set(0, 0);
						  credits.scale.set(1.15, 1.15);
						  credits.antialiasing = true;
						  //add(credits);

				  }
				  case 'undisturbed':
				  {
						  defaultCamZoom = 0.8;
		                  curStage = 'bonus';
						  GameOverSubstate.undisturbedRJ = false;

						  deitiesbg = new FlxSprite(-1000, -600);
						  //deitiesbg.screenCenter(X);
						  //deitiesbg.screenCenter(Y);
		                  deitiesbg.frames = Paths.getSparrowAtlas('undisturbedbg');
		                  deitiesbg.animation.addByPrefix('idle', 'energy back', 24);
		                  deitiesbg.animation.play('idle');
		                  deitiesbg.scrollFactor.set(0, 0);
		                  deitiesbg.scale.set(1.5, 1.5);
		                  add(deitiesbg);

		                  sky = new FlxSprite(-1250, -700).loadGraphic(Paths.image('cavesky'));
		                  sky.antialiasing = true;
		                  sky.scrollFactor.set(0.01, 0.01);
						  sky.setGraphicSize(Std.int(sky.width * 0.45));
		                  sky.active = false;
		                  add(sky);

						  bgback = new FlxSprite(-1250, -700).loadGraphic(Paths.image('cavebgback'));
		                  bgback.antialiasing = true;
		                  bgback.scrollFactor.set(0.1, 0.1);
						  bgback.setGraphicSize(Std.int(bgback.width * 0.45));
		                  bgback.active = false;
		                  add(bgback);

						  bgfront = new FlxSprite(-1250, -700).loadGraphic(Paths.image('cavebgfront'));
		                  bgfront.antialiasing = true;
		                  bgfront.scrollFactor.set(0.2, 0.2);
						  bgfront.setGraphicSize(Std.int(bgfront.width * 0.45));
		                  bgfront.active = false;
		                  add(bgfront);

		                  caveFront = new FlxSprite(-420, 400).loadGraphic(Paths.image('cavefront'));
		                  caveFront.setGraphicSize(Std.int(caveFront.width * 0.6));
						  caveFront.scrollFactor.set(0.9, 0.9);
		                  caveFront.updateHitbox();
		                  caveFront.antialiasing = true;
		                  caveFront.active = false;
		                  add(caveFront);

						  //if(curBeat == 190){
						  
						  //}
				  }
		          default:
		          {
		                  defaultCamZoom = 0.9;
		                  curStage = 'stage';
		                  var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.9, 0.9);
		                  bg.active = false;
		                  add(bg);

		                  var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
		                  stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		                  stageFront.updateHitbox();
		                  stageFront.antialiasing = true;
		                  stageFront.scrollFactor.set(0.9, 0.9);
		                  stageFront.active = false;
		                  add(stageFront);

		                  var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
		                  stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
		                  stageCurtains.updateHitbox();
		                  stageCurtains.antialiasing = true;
		                  stageCurtains.scrollFactor.set(1.3, 1.3);
		                  stageCurtains.active = false;

		                  add(stageCurtains);
						  //dad = new Character(100, 100, 'allseer');
						  //add(dad);
						  //dad.x = -3000;
						  
		          }
              }

		var gfVersion:String = 'gf';

		switch (curStage)
		{
			case 'limo':
				gfVersion = 'gf-car';
			case 'mall' | 'mallEvil':
				gfVersion = 'gf-christmas';
			case 'school':
				gfVersion = 'gf-pixel';
			case 'schoolEvil':
				gfVersion = 'gf-pixel';
		}

		if (curStage == 'limo')
			gfVersion = 'gf-car';

		gf = new Character(400, 130, gfVersion);
		allseer = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);
		allseer.scrollFactor.set(0.05, 0.05);

		dad = new Character(100, 100, SONG.player2);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}

			case 'allseer':
			    if(curStage == 'mystage' || curStage == 'bossmodestage'){
				//dad.setPosition(gf.x -= 100, gf.y -=100); <-- old allseer
				dad.setPosition(-180, -450);
				gf.visible = false;
				dad.scrollFactor.set(0.10, 0.10);
				//if (isStoryMode)
				//{
				//camPos.x += 600;
				camPos.y -= 400;
				tweenCamIn();
				//}
				}
				else if(curStage == 'finalbattle'){
				//dad.setPosition(gf.x -= 100, gf.y +=300); old
				dad.setPosition(-180, -450);
				gf.visible = false;
				dad.scrollFactor.set(-0.10, 0.10);
				//if (isStoryMode)
				//{
				camPos.x += 300;
				}
			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'purpbf':
			    if(curStage == 'caveday'){
					camPos.set(550, 550);
				}
			case 'shard':
				if(curStage == 'bonus'){
				gf.visible = false;
				}
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				// trailArea.scrollFactor.set();

				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				// evilTrail.changeValuesEnabled(false, false, false, false);
				// evilTrail.changeGraphic()
				add(evilTrail);
				// evilTrail.scrollFactor.set(1.1, 1.1);

				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			/*idk if this shit works or not but eh (commented out for now)
			case 'mystage':
				allseer.y += 2000;*/
			case 'mystage2':
				dad.x -= 100;
				boyfriend.x += 50;
				dad.y -= 110;
			case 'cave':
				boyfriend.x += 200;
				gf.y += -20;
				dad.x -= 200;
				dad.y -= 110;
			case 'finalbattle':
				boyfriend.x += 200;
				dad.y += 500;
			case 'caveday':
				boyfriend.x -= 530;
				boyfriend.y -= 140;
				gf.y += -20;
				gf.x -= 4000;
				dad.x += 400;
				dad.y += 400;
			case 'bonus':
				
				boyfriend.x += 200;
				boyfriend.y -= 350;
				gf.y += -20;
				dad.x -= 200;
				dad.y -= 110;
		}

		if(curStage != 'mystage' && curStage != 'bossmodestage' && curStage != 'finalbattle' && curStage != 'caveday' && curStage != 'bonus'){
		add(gf);

		// Shitty layering but whatev it works LOL
			if (curStage == 'limo'){
				add(limo);
			}
		add(dad);
		add(boyfriend);
		}
		else{
			
			if(curStage == 'caveday'){	
			add(dad);
			dad.visible = false;
			add(boyfriend);
			boyfriend.visible = false;
			}
			else if(curStage == 'bonus'){
			
			dad = new Character(7000, 100, 'allseer');
			add(dad);
			dad.playAnim('idle');
			dad = new Character(-100, 100, SONG.player2);
			add(dad);
			boyfriend = new Boyfriend(-7000, 100, 'rj');
			add(boyfriend);
			boyfriend.playAnim('idle');
			boyfriend = new Boyfriend(770, 100, SONG.player1);
			add(boyfriend);
			//dad.alpha = 0;
			add(boyfriend);
			}
			else if(curStage != 'finalbattle'){		    
			add(dad);
			var spaceFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('spacefront'));
			spaceFront.setGraphicSize(Std.int(spaceFront.width * 1.0));
			spaceFront.updateHitbox();
			spaceFront.antialiasing = true;
			spaceFront.scrollFactor.set(0.9, 0.9);
			spaceFront.active = false;
			//spaceFront.y += 500;
			add(spaceFront);

			


		    /*var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
		    stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
		    stageCurtains.updateHitbox();
		    stageCurtains.antialiasing = true;
		    stageCurtains.scrollFactor.set(1.3, 1.3);
		    stageCurtains.active = false;

		    add(stageCurtains);
			*/
		//space stuff here
		    boyfriend.y += 120;
			boyfriend.x += 750;
		    add(boyfriend);

			rjAnim = new FlxSprite(0, 0).loadGraphic(Paths.image('RJAnim'));
			rjAnim.frames = Paths.getSparrowAtlas('RJAnim');
			rjAnim.animation.addByPrefix('idle', 'rjvanish', 20, false);
			//calamityIntro.animation.play('idle');
			rjAnim.scrollFactor.set(.1, .1);
			rjAnim.scale.set(.7, .7);
			add(rjAnim);
			//if (curSong.toLowerCase() == 'calamity' && curSection == 24){
		      
		    //}
			//while(curSong == 'calamity')
			//{
				//if (spaceBlk == false){
				//	remove(spaceblk);
				//}
				
			//}
			/*if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
			{
				if (curBeat == 96)
				{
					//case 95:
					 remove(spaceblk);
				}
			}*/
			}
			
			else{
				add(dad);
				dad.y -= 250;
				dad.x -= 800;

				var shadow:FlxSprite = new FlxSprite(-1500, -550).loadGraphic(Paths.image('deitiesShadow'));
				shadow.setGraphicSize(Std.int(shadow.width * 1.0));
				shadow.updateHitbox();
				shadow.antialiasing = true;
				shadow.scrollFactor.set(0, 0);
				shadow.active = false;
				add(shadow);

				boyfriend.y -= 170;
				boyfriend.x -= 225;
				boyfriend.setGraphicSize(Std.int(boyfriend.width * 2.4));
				boyfriend.scrollFactor.set(0.3, 0);
				add(boyfriend);

				immortalityIcon = new FlxSprite(5000, 700).loadGraphic(Paths.image('ImmortalityIconsRJ'));
				immortalityIcon.frames = Paths.getSparrowAtlas('ImmortalityIconsRJ');
				immortalityIcon.animation.addByPrefix('count', 'Immortality Count', 1, false);
				immortalityIcon.scrollFactor.set(0, 0);
				immortalityIcon.scale.set(.4, .4);
				add(immortalityIcon);

				immortalityIconReady = new FlxSprite(1300, 700).loadGraphic(Paths.image('ImmortalityIconsRJ'));
				immortalityIconReady.frames = Paths.getSparrowAtlas('ImmortalityIconsRJ');
				immortalityIconReady.animation.addByPrefix('ready', 'Immortality Ready', 15, true);
				immortalityIconReady.scrollFactor.set(0, 0);
				immortalityIconReady.scale.set(.4, .4);
				immortalityIconReady.animation.play('ready');
				add(immortalityIconReady);

				shardAbility = new FlxSprite(-1200, 700).loadGraphic(Paths.image('ShardAbilityIcons'));
				shardAbility.frames = Paths.getSparrowAtlas('ShardAbilityIcons');
				shardAbility.animation.addByPrefix('idle', 'Icon Idle', 1, true);
				shardAbility.animation.addByPrefix('ability', 'Shard Ability', 15, false);
				shardAbility.scrollFactor.set(0, 0);
				shardAbility.scale.set(.4, .4);
				//shardAbility.animation.play('idle');
				add(shardAbility);

				antiPause = new FlxSprite(-100, -300).loadGraphic(Paths.image('AntiPauseIcon'));
				antiPause.setGraphicSize(Std.int(antiPause.width * 1.5));
				antiPause.updateHitbox();
				antiPause.antialiasing = true;
				antiPause.scrollFactor.set(0, 0);
				antiPause.active = false;
				add(antiPause);
				antiPause.alpha = 0;
				
			}
		}

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;
		if (curStage == 'bossmodestage'){
		strumLine = new FlxSprite(1000, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		}
		else{
		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		}
		

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		if (curStage == 'bossmodestage')
		{
		health = 0;
		healthBarBG = new FlxSprite(20, 55).loadGraphic(Paths.image('healthBar'));
		healthBarBG.scrollFactor.set();
		healthBarBGShard = new FlxSprite(0, 45).loadGraphic(Paths.image('healthBarShard'));
		healthBarBGShard.scrollFactor.set();
		//healthBarBG.scale.set(0.9, 0.9);
		hearts = new FlxSprite(healthBarBG.x - 120, healthBarBG.y + 0);
		if(boyfriend.curCharacter == 'purpbf' || boyfriend.curCharacter == 'bf'){
		hearts.frames = Paths.getSparrowAtlas('funnyhearts');
		}
		else{
		hearts.frames = Paths.getSparrowAtlas('defaulthearts');
		}
		hearts.animation.addByPrefix('five', 'five hearts', 24);
		hearts.animation.addByPrefix('four', 'four hearts', 24);
		hearts.animation.addByPrefix('three', 'three hearts', 24);
		hearts.animation.addByPrefix('two', 'two hearts', 24);
		hearts.animation.addByPrefix('one', 'one heart', 24);
		hearts.animation.addByPrefix('none', 'no hearts', 24);
		hearts.scale.set(0.45, 0.45);
		add(hearts);
		//hearts.animation.play('idle');
		}
		else
		{
		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		}
		
		add(healthBarBG);
		if (curStage == 'bossmodestage')
		{
		add(healthBarBGShard);
		}


		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		//healthBar.scale.set(0.8, 0.8);
		if (curStage == 'finalbattle' || curStage == 'bonus')
		{
		healthBar.createFilledBar(0xFF6A0DAD, 0xFFCC33FF);
		}
		else if (curStage == 'bossmodestage')
		{
		//healthBar.scale.set(0.9, 0.9);
		healthBar.createFilledBar(0xFF6A0DAD, 0xFF000000);
		}
		else
		{
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		}
		// healthBar
		add(healthBar);

		scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width - 190, healthBarBG.y + 30, 0, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT);
		scoreTxt.scrollFactor.set();
		add(scoreTxt);
		if(curStage == 'bossmodestage'){
			scoreTxt.visible = false;
		}

		iconP1 = new HealthIcon(SONG.player1, true);
		
		if (curStage == 'bossmodestage'){
		iconP1.y = healthBar.y - (iconP1.height / 2) + 95;
		iconP1.scale.set(0.8, 0.8);
		}
		else{
		iconP1.y = healthBar.y - (iconP1.height / 2);
		}
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		if (curStage == 'bossmodestage'){
		//iconP2.scale.set(0.8, 0.8);
		}
		if (curStage == 'caveday'){
		  iconP2.alpha = 0;
		}
		add(iconP2);

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		if (curStage == 'bossmodestage'){
			healthBarBGShard.cameras = [camHUD];
			hearts.cameras = [camHUD];
		}
		if (curStage == 'finalbattle'){
		
		}
		
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		if (curStage == 'finalbattle'){
			deitiestransition.cameras = [camHUD];
		}
		
		doof.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode)
		{
			switch (curSong.toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
				case 'prismatic':
				//change back to space once made
					spaceIntro(doof);
				case 'no-newton':
				//change back to space once made
					spaceIntro(doof);
				case 'calamity':
				//change back to space once made
					spaceIntro(doof);
				case 'deities':
				//change back to space once made
					spaceIntro(doof);
				case 'resurrection':
					spaceIntro(doof);
				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
			//take deities out after testing
				//case 'deities':
				//	spaceIntro(doof);
				//case 'calamity':
				//	spaceIntro(doof);
				case 'resurrection':
					spaceIntro(doof);
				case 'undisturbed':
					bonusIntro(doof);
				default:
					startCountdown();
			}
		}

		super.create();
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}
	
	function spaceIntro(?dialogueBox:DialogueBox):Void
	{
		/*var nnIntro:FlxSprite = new FlxSprite();
		nnIntro.frames = Paths.getSparrowAtlas('no_newton_cutscene');
		nnIntro.animation.addByPrefix('idle', 'nnintro', 10, false);
		nnIntro.setGraphicSize(Std.int(nnIntro.width * 3.5));
		nnIntro.scrollFactor.set();
		nnIntro.updateHitbox();
		nnIntro.screenCenter();
		*/


		var nnIntro:FlxSprite = new FlxSprite(0, 0);
		nnIntro.frames = Paths.getSparrowAtlas('noNewtonCutscene');
		nnIntro.animation.addByPrefix('idle', 'nnintro', 20, false);
		//nnIntro.animation.play('idle');
		nnIntro.scrollFactor.set(0, 0);
		nnIntro.scale.set(1.14, 1.14);

		var calamityIntro:FlxSprite = new FlxSprite(0, 0);
		calamityIntro.frames = Paths.getSparrowAtlas('calamityCutscene');
		calamityIntro.animation.addByPrefix('idle', 'calamityintro', 20, false);
		//calamityIntro.animation.play('idle');
		calamityIntro.scrollFactor.set(0, 0);
		calamityIntro.scale.set(.8, .8);

		var deitiesIntroOne:FlxSprite = new FlxSprite(0, 0);
		deitiesIntroOne.frames = Paths.getSparrowAtlas('DeitiesPt1');
		deitiesIntroOne.animation.addByPrefix('idle', 'deitiesIntro', 20, false);
		//deitiesIntroOne.animation.play('idle');
		deitiesIntroOne.scrollFactor.set(0, 0);
		deitiesIntroOne.scale.set(1.179, 1.179);

		var deitiesIntroTwo:FlxSprite = new FlxSprite(0, 0);
		deitiesIntroTwo.frames = Paths.getSparrowAtlas('DeitiesPt2');
		deitiesIntroTwo.animation.addByPrefix('idle', 'deitiesIntro', 20, false);
		//deitiesIntroTwo.animation.play('idle');
		deitiesIntroTwo.scrollFactor.set(0, 0);
		deitiesIntroTwo.scale.set(1.179, 1.179);

		var finale:FlxSprite = new FlxSprite(0, 0);
		finale.frames = Paths.getSparrowAtlas('finalecutscene');
		finale.animation.addByPrefix('finale', 'finale', 20, false);
		//finale.animation.play('idle');
		finale.scrollFactor.set(0, 0);
		finale.scale.set(1.0, 1.0);

		

		
				if (dialogueBox != null)
				{
					inCutscene = true;
					if (SONG.song.toLowerCase() == 'prismatic')
					{
						new FlxTimer().start(1, function(deadTime:FlxTimer)
						{
							add(dialogueBox);
						});
						
						
					}
					if (SONG.song.toLowerCase() == 'no-newton')
					{
						//add(nnIntro);
						add(nnIntro);
						nnIntro.antialiasing = true;
						FlxG.camera.fade(FlxColor.BLACK, 1, true);
						new FlxTimer().start(1, function(deadTime:FlxTimer)
						{
							nnIntro.animation.play('idle');
								FlxG.sound.play(Paths.sound('nnintrosound'), 1, false, null, true, function()
								{
									//new FlxTimer().start(1.3, function(deadTime:FlxTimer)
									//{
										add(dialogueBox);
										remove(nnIntro);
										FlxG.camera.fade(FlxColor.WHITE, 1, true, function()
										{
											
									
										}, true);
									//});
								});
								new FlxTimer().start(1.3, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 2, false);
								});
						});	
					}
					if (SONG.song.toLowerCase() == 'calamity')
					{
						//add(rjAnim);
						add(calamityIntro);
						calamityIntro.antialiasing = true;
						FlxG.camera.fade(FlxColor.BLACK, 1, true);
						new FlxTimer().start(1, function(deadTime:FlxTimer)
						{
							
								calamityIntro.animation.play('idle');
									FlxG.sound.play(Paths.sound('calamitycs'), 1, false, null, true, function()
									{
										//new FlxTimer().start(1.3, function(deadTime:FlxTimer)
										//{
											//add(dialogueBox);
											//remove(nnIntro);
											//FlxG.camera.fade(FlxColor.WHITE, 1, true, function()
											//{
											
									
											//}, true);
										//});
									});
									new FlxTimer().start(15, function(deadTime:FlxTimer)
									{
										FlxG.camera.fade(FlxColor.BLACK, 1, false);
									});
									new FlxTimer().start(24, function(deadTime:FlxTimer)
									{
										FlxG.camera.fade(FlxColor.BLACK, 2, true);
										add(dialogueBox);
										remove(calamityIntro);
									});
									
						});	
					}

					if (SONG.song.toLowerCase() == 'deities')
					{
						//add(rjAnim);
						add(deitiesIntroTwo);
						deitiesIntroTwo.cameras = [camHUD];
						deitiesIntroTwo.antialiasing = true;
						deitiesIntroTwo.screenCenter();
						add(deitiesIntroOne);
						deitiesIntroOne.cameras = [camHUD];
						deitiesIntroOne.antialiasing = true;
						deitiesIntroOne.screenCenter();
						//deitiesIntroTwo.visible = false;
						FlxG.camera.fade(FlxColor.BLACK, 1, true);
						new FlxTimer().start(1, function(deadTime:FlxTimer)
						{
							
								deitiesIntroOne.animation.play('idle');
									FlxG.sound.play(Paths.sound('deitiesaudio'), 1, false, null, true, function()
									{
										//new FlxTimer().start(1.3, function(deadTime:FlxTimer)
										//{
											//add(dialogueBox);
											//remove(nnIntro);
											//FlxG.camera.fade(FlxColor.WHITE, 1, true, function()
											//{
											
									
											//}, true);
										//});
									});
									new FlxTimer().start(19, function(deadTime:FlxTimer)
									{
										//deitiesIntroTwo.visible = true;
										deitiesIntroTwo.animation.play('idle');
										remove(deitiesIntroOne);
									});
									new FlxTimer().start(38.95, function(deadTime:FlxTimer)
									{
										remove(deitiesIntroTwo);
										startCountdown();
									});
									
						});	
					}
					if (SONG.song.toLowerCase() == 'resurrection')
					{
						camFollow.y = 550;
						camFollow.x = 550;
						FlxG.camera.focusOn(camFollow.getPosition());
						//add(rjAnim);
						//add(rjEndAnim);
						add(finale);
						finale.cameras = [camHUD];
						finale.antialiasing = true;
						finale.screenCenter();
						FlxG.camera.fade(FlxColor.BLACK, 1, true);
						new FlxTimer().start(1, function(deadTime:FlxTimer)
						{
							finale.animation.play('finale');
							FlxG.sound.play(Paths.sound('finaleaudio'), 1, false, null, true, function()
							{
										//new FlxTimer().start(1.3, function(deadTime:FlxTimer)
										//{
											
											//remove(nnIntro);
											//FlxG.camera.fade(FlxColor.WHITE, 1, true, function()
											//{
											
									
											//}, true);
										//});
							});
						});
						new FlxTimer().start(14, function(deadTime:FlxTimer)
						{		
								new FlxTimer().start(.4, function(tpsound:FlxTimer)
								{
									FlxG.sound.play(Paths.sound('resurrectionsounds'));
								});
								
								new FlxTimer().start(0.05, function(tmr:FlxTimer)
								{
									finale.alpha -= 0.05;

									if (finale.alpha > 0)
									{
										tmr.reset(0.05);
									}
									else
									{
										rjEndAnim.animation.play('anim');
											//FlxG.sound.play(Paths.sound('calamitycs'), 1, false, null, true, function()
											//{
												//new FlxTimer().start(1.3, function(deadTime:FlxTimer)
												//{
													//add(dialogueBox);
													//remove(nnIntro);
													//FlxG.camera.fade(FlxColor.WHITE, 1, true, function()
													//{
											
									
													//}, true);
												//});
											//});
											new FlxTimer().start(1.2, function(gfTPTimer:FlxTimer)
											{
												gfTP.animation.play('tp');
											});
											new FlxTimer().start(3.25, function(deadTime:FlxTimer)
											{
												add(dialogueBox);
												//startCountdown();
												//FlxG.camera.fade(FlxColor.BLACK, 2, true);
												//add(dialogueBox);
												//remove(calamityIntro);
											});
									}
								});
						});	
					}
				}
				else{
					/*if (SONG.song.toLowerCase() == 'calamity')
					{
						rjAnim.animation.play('idle');
						new FlxTimer().start(.4, function(deadTime:FlxTimer)
						{
							remove(rjAnim);
						});
						FlxG.sound.play(Paths.sound('rj_vanish'));
					}*/
					
					startCountdown();
				}

				//remove(black);
			
		
	}
	function bonusIntro(?dialogueBox:DialogueBox):Void
	{

				if (dialogueBox != null)
				{
						add(dialogueBox);
				}
				else
				{
					startCountdown();
				}
		//});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		inCutscene = false;
		generateStaticArrows(0);
		generateStaticArrows(1);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			allseer.dance();
			boyfriend.playAnim('idle');

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('mystage', ['ready-shard', 'set-shard', 'go-shard']);
			introAssets.set('finalbattle', ['ready-shard', 'set-shard', 'go-shard']);
			introAssets.set('bossmodestage', ['ready-shard', 'set-shard', 'go-shard']);
			introAssets.set('caveday', ['blankimage', 'blankimage', 'blankimage']);

			//random placement yeah i know
			if(curStage == 'bossmodestage'){
				health = 0;
			}

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					if (curStage.startsWith('school')){
					FlxG.sound.play(Paths.sound('intro3-pixel'), 0.6);
					}
					else if (curStage == 'bossmodestage'){
					VSIconP2 = new HealthIcon(SONG.player2, true);
					//VSIconP2.screenCenter();
					VSIconP1 = new HealthIcon(SONG.player1, true);
					//VSIconP1.screenCenter();
					vsbg = new FlxSprite(0, 0);
		            vsbg.frames = Paths.getSparrowAtlas('bossmodevsbg');
		            vsbg.animation.addByPrefix('idle', 'vs bg', 10);
					vsbg.screenCenter();
					FlxG.sound.play(Paths.sound('intro3-shard'), 0.6);
					add(vsbg);
					add(VSIconP2);			
					vs = new FlxSprite(0, 0).loadGraphic(Paths.image('bossmodevs'));
					vs.screenCenter();
					VSIconP2.x = vsbg.x + 75;
					VSIconP2.y = vsbg.y + 120;
					VSIconP2.scale.set(1.5, 1.5);
					VSIconP1.x = vsbg.x + 525;
					VSIconP1.y = vsbg.y + 380;
					VSIconP1.scale.set(1.5, 1.5);
					VSIconP1.cameras = [camHUD];
					VSIconP2.cameras = [camHUD];
					VSIconP2.flipX = true;
					vs.cameras = [camHUD];
					vsbg.cameras = [camHUD];
		            vsbg.animation.play('idle');
					}
					else if(curStage == 'mystage' || curStage == 'finalbattle'){
					FlxG.sound.play(Paths.sound('intro3-shard'), 0.6);
						if(curStage == 'finalbattle'){
						deitiestransition.animation.play('idle');
						}
					}
					else if(curStage == 'caveday'){
					}
					else{
					FlxG.sound.play(Paths.sound('intro3'), 0.6);
					}
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school')){
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));
					}
					if (curStage == 'bossmodestage'){
					add(vs);
					}
					else {
					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					}
					if (curStage.startsWith('school')){
					FlxG.sound.play(Paths.sound('intro2-pixel'), 0.6);
					}
					else if(curStage == 'mystage' || curStage == 'bossmodestage' || curStage == 'finalbattle'){
					FlxG.sound.play(Paths.sound('intro2-shard'), 0.6);
					}
					else if(curStage == 'caveday'){
					}
					else{
					FlxG.sound.play(Paths.sound('intro2'), 0.6);
					}
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));
					if (curStage == 'bossmodestage'){
					add(VSIconP1);
					}
					else {
					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					}
					if (curStage.startsWith('school')){
					FlxG.sound.play(Paths.sound('intro1-pixel'), 0.6);
					}
					else if(curStage == 'mystage' || curStage == 'bossmodestage' || curStage == 'finalbattle'){
					FlxG.sound.play(Paths.sound('intro1-shard'), 0.6);
					}
					else if(curStage == 'caveday'){
					}
					else{
					FlxG.sound.play(Paths.sound('intro1'), 0.6);
					}
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));
					if (curStage == 'bossmodestage'){
					remove(vs);
					remove(vsbg);
					remove(VSIconP1);
					remove(VSIconP2);
					}
					else {
					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					}
					if (curStage.startsWith('school')){
					FlxG.sound.play(Paths.sound('introGo-pixel'), 0.6);
					}
					else if(curStage == 'mystage' || curStage == 'bossmodestage' || curStage == 'finalbattle'){
					FlxG.sound.play(Paths.sound('introGo-shard'), 0.6);
					}
					else if(curStage == 'caveday'){
					}
					else{
					FlxG.sound.play(Paths.sound('introGo'), 0.6);
					}
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		#if desktop
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength);
		#end
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for(section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}
				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						//if (gottaHitNote == false && curStage == 'bossmodestage'){
						//	sustainNote.x += FlxG.width / 2 + 1000; // general offset
						//}
						//else{
							sustainNote.x += FlxG.width / 2; // general offset
						//}
					}
					else{
						if (curStage == 'bossmodestage'){
							sustainNote.x += FlxG.width / 2 + 2000; // general offset	
						}
						else{
							//sustainNote.x += FlxG.width / 2; // general offset				
						}

					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					//if (gottaHitNote == false && curStage == 'bossmodestage'){
					//	swagNote.x += FlxG.width / 2 - 2000; // general offset
					//}
					//else{
						swagNote.x += FlxG.width / 2; // general offset
					//}
				}
				else {
					if (curStage == 'bossmodestage'){
							swagNote.x += FlxG.width / 2 - 2000; // general offset	
					}
					else{
					//	swagNote.x += FlxG.width / 2; // general offsett				
					}
					//swagNote.x += FlxG.width / 2 - 2000; // general offset
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			if(player == 0 && curStage == 'bossmodestage'){
			babyArrow.x -= 1000;
			}
			else{
			babyArrow.x += 50;
			}
			babyArrow.x += ((FlxG.width / 2) * player);

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}
	function tweenCamOut():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 0.7}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}

		switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
		}

		super.update(elapsed);

		scoreTxt.text = "Score:" + songScore;

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			if(curStage == 'finalbattle'){
				shardAntiPause();
			}
			else if (curStage != 'caveday'){
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;

				// 1 / 1000 chance for Gitaroo Man easter egg
				//if (FlxG.random.bool(0.1))
				//{
					// gitaroo man easter egg
				//	FlxG.switchState(new GitarooPause());
				//}
				//else
					openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		
				#if desktop
				DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
				#end
			}
			
		}

		if (FlxG.keys.justPressed.SEVEN && curStage != 'caveday')
		{
			FlxG.switchState(new ChartingState());

			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		if (curStage == 'bossmodestage'){
		iconP1.setGraphicSize(Std.int(FlxMath.lerp(120, iconP1.width, 0.50)));
		}
		else{
		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		}
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;
		if (curStage == 'bossmodestage'){
		iconP1.x = healthBar.x - 20;
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset) + 20;
		}
		else{
		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset) ;
		}

		if (health > 2)
			health = 2;
		
		if (curStage != 'bossmodestage'){
			
			if (healthBar.percent < 20){
				iconP1.animation.curAnim.curFrame = 1;
			}
			else{
				iconP1.animation.curAnim.curFrame = 0;
			}
		}
		else{
			if (health >= 2){
				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();
				openSubState(new BossModeOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}
			if (bossModeHealth < 2){
				iconP1.animation.curAnim.curFrame = 1;
			}
			else{
				iconP1.animation.curAnim.curFrame = 0;
			}
		}
		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;
		if (curStage == 'bossmodestage'){
			if (bossModeHealth >= 5){
				hearts.animation.play('five');
			}
			else if (bossModeHealth >= 4){
				hearts.animation.play('four');
			}
			else if (bossModeHealth >= 3){
				hearts.animation.play('three');
			}
			else if (bossModeHealth >= 2){
				hearts.animation.play('two');
			}
			else if (bossModeHealth >= 1){
				hearts.animation.play('one');
			}
			else{
				hearts.animation.play('none');
			}
		}
		/* if you want to use the hearts for the normal healthbar just use this
		if (curStage == 'bossmodestage'){
			if (healthBar.percent > 80){
				hearts.animation.play('five');
			}
			else if (healthBar.percent > 60){
				hearts.animation.play('four');
			}
			else if (healthBar.percent > 40){
				hearts.animation.play('three');
			}
			else if (healthBar.percent > 20){
				hearts.animation.play('two');
			}
			else if (healthBar.percent > 0){
				hearts.animation.play('one');
			}
			else{
				hearts.animation.play('none');
			}
		}
		*/

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		#if debug
		if (FlxG.keys.justPressed.EIGHT)
			FlxG.switchState(new AnimationDebug(SONG.player2));
		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}

			if (camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

				switch (dad.curCharacter)
				{
					case 'mom':
						camFollow.y = dad.getMidpoint().y;
					case 'senpai':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
					case 'senpai-angry':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
				}

				if (dad.curCharacter == 'mom')
					vocals.volume = 1;

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					tweenCamIn();
				}
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

				switch (curStage)
				{
					case 'limo':
						camFollow.x = boyfriend.getMidpoint().x - 300;
					case 'mall':
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'school':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'schoolEvil':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'mystage':
						camFollow.x = boyfriend.getMidpoint().x - 500;
						camFollow.y = boyfriend.getMidpoint().y - 400;
					case 'bossmodestage':
						camFollow.x = boyfriend.getMidpoint().x - 500;
						camFollow.y = boyfriend.getMidpoint().y - 400;
				}

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
				}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}
		// better streaming of shit

		// RESET = Quick Game Over Screen
		if (controls.RESET)
		{
			if(curStage == 'finalbattle'){
				if(immortalityReady == false){
					health = 0;
				}
			}
			else if(curStage == 'bossmodestage'){
				bossModeHealth = 0;
			}
			else if(curStage != 'caveday'){
				health = 0;
			}
			
			trace("RESET = True");
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
			health += 1;
			trace("User is cheating!");
		}
		if (curStage != 'bossmodestage'){
			if (health <= 0)
			{
				if (curStage == 'finalbattle'){
					if(immortalityReady == true){
						health += 1;
						immortalityUsed();
					}
					else{
						boyfriend.stunned = true;

						persistentUpdate = false;
						persistentDraw = false;
						paused = true;

						vocals.stop();
						FlxG.sound.music.stop();

						openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

						// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			
						#if desktop
						// Game Over doesn't get his own variable because it's only used here
						DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
						#end
					}
				}
				else{
					boyfriend.stunned = true;

					persistentUpdate = false;
					persistentDraw = false;
					paused = true;

					vocals.stop();
					FlxG.sound.music.stop();

					openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

					// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			
					#if desktop
					// Game Over doesn't get his own variable because it's only used here
					DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
					#end
				}
			
			}
		}
		else{
			if (bossModeHealth <= 0)
			{
				boyfriend.stunned = true;

					persistentUpdate = false;
					persistentDraw = false;
					paused = true;

					vocals.stop();
					FlxG.sound.music.stop();

					openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

					// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			
					#if desktop
					// Game Over doesn't get his own variable because it's only used here
					DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
					#end
			}
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));

				// i am so fucking sorry for this if condition
				if (daNote.isSustainNote
					&& daNote.y + daNote.offset.y <= strumLine.y + Note.swagWidth / 2
					&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{
					var swagRect = new FlxRect(0, strumLine.y + Note.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);
					swagRect.y /= daNote.scale.y;
					swagRect.height -= swagRect.y;

					daNote.clipRect = swagRect;
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}

					switch (Math.abs(daNote.noteData))
					{
						case 0:
							dad.playAnim('singLEFT' + altAnim, true);
						case 1:
							dad.playAnim('singDOWN' + altAnim, true);
						case 2:
							dad.playAnim('singUP' + altAnim, true);
						case 3:
							dad.playAnim('singRIGHT' + altAnim, true);
					}

					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				if (daNote.y < -daNote.height)
				{
					if (daNote.tooLate || !daNote.wasGoodHit)
					{
						if (curStage != 'bossmodestage'  && curStage != 'caveday'){
						health -= 0.0475;						
						}
						else if (curStage == 'bossmodestage'){
							bossModeMisses += 1;
						}
						vocals.volume = 0;
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}

		if (!inCutscene)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	function endSong():Void
	{
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);
			#end
		}

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				FlxG.switchState(new StoryMenuState());

				if (storyWeek == 1)
				{
				//this unlocks the bonuses. I tried literally everything I thought of to get it to save between sessions, but it doesnt. congratulations, youve discovered a cheat code. Press 9 in freeplay to unlock the bonuses.
				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 8, StoryMenuState.weekUnlocked.length - 1))] = true;
				StoryMenuState.bonusesUnlocked = true;
				FlxG.save.data.bonusesUnlocked = true;
				}
				else{
				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;
				}
				if (SONG.validScore)
				{
					NGio.unlockMedal(60961);
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				}

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				}

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				LoadingState.loadAndSwitchState(new PlayState());
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			FlxG.switchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;

	private function popUpScore(strumtime:Float):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";

		if (noteDiff > Conductor.safeZoneOffset * 0.9)
		{
			daRating = 'shit';
			score = 50;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.75)
		{
			daRating = 'bad';
			score = 100;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.2)
		{
			daRating = 'good';
			score = 200;
		}

		songScore += score;

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		if(curStage != 'caveday'){
		add(rating);
		}

		if (!curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			if (!curStage.startsWith('school'))
			{
				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (combo >= 10 || combo == 0)
				if(curStage != 'caveday'){
					add(numScore);
				}

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
	}

	private function keyShit():Void
	{
		// HOLDING
		var up = controls.UP;
		var right = controls.RIGHT;
		var down = controls.DOWN;
		var left = controls.LEFT;

		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		var upR = controls.UP_R;
		var rightR = controls.RIGHT_R;
		var downR = controls.DOWN_R;
		var leftR = controls.LEFT_R;

		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];

		// FlxG.watch.addQuick('asdfa', upP);
		if ((upP || rightP || downP || leftP) && !boyfriend.stunned && generatedMusic)
		{
			boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = [];

			var ignoreList:Array<Int> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
				{
					// the sorting probably doesn't need to be in here? who cares lol
					possibleNotes.push(daNote);
					possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

					ignoreList.push(daNote.noteData);
				}
			});

			if (possibleNotes.length > 0)
			{
				var daNote = possibleNotes[0];

				if (perfectMode)
					noteCheck(true, daNote);

				// Jump notes
				if (possibleNotes.length >= 2)
				{
					if (possibleNotes[0].strumTime == possibleNotes[1].strumTime)
					{
						for (coolNote in possibleNotes)
						{
							if (controlArray[coolNote.noteData])
								goodNoteHit(coolNote);
							else
							{
								var inIgnoreList:Bool = false;
								for (shit in 0...ignoreList.length)
								{
									if (controlArray[ignoreList[shit]])
										inIgnoreList = true;
								}
								if (!inIgnoreList)
									badNoteCheck();
							}
						}
					}
					else if (possibleNotes[0].noteData == possibleNotes[1].noteData)
					{
						noteCheck(controlArray[daNote.noteData], daNote);
					}
					else
					{
						for (coolNote in possibleNotes)
						{
							noteCheck(controlArray[coolNote.noteData], coolNote);
						}
					}
				}
				else // regular notes?
				{
					noteCheck(controlArray[daNote.noteData], daNote);
				}
				/* 
					if (controlArray[daNote.noteData])
						goodNoteHit(daNote);
				 */
				// trace(daNote.noteData);
				/* 
						switch (daNote.noteData)
						{
							case 2: // NOTES YOU JUST PRESSED
								if (upP || rightP || downP || leftP)
									noteCheck(upP, daNote);
							case 3:
								if (upP || rightP || downP || leftP)
									noteCheck(rightP, daNote);
							case 1:
								if (upP || rightP || downP || leftP)
									noteCheck(downP, daNote);
							case 0:
								if (upP || rightP || downP || leftP)
									noteCheck(leftP, daNote);
						}

					//this is already done in noteCheck / goodNoteHit
					if (daNote.wasGoodHit)
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				 */
			}
			else
			{
				badNoteCheck();
			}
		}

		if ((up || right || down || left) && !boyfriend.stunned && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
				{
					switch (daNote.noteData)
					{
						// NOTES YOU ARE HOLDING
						case 0:
							if (left)
								goodNoteHit(daNote);
						case 1:
							if (down)
								goodNoteHit(daNote);
						case 2:
							if (up)
								goodNoteHit(daNote);
						case 3:
							if (right)
								goodNoteHit(daNote);
					}
				}
			});
		}

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !up && !down && !right && !left)
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.playAnim('idle');
			}
		}

		playerStrums.forEach(function(spr:FlxSprite)
		{
			switch (spr.ID)
			{
				case 0:
					if (leftP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (leftR)
						spr.animation.play('static');
				case 1:
					if (downP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (downR)
						spr.animation.play('static');
				case 2:
					if (upP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (upR)
						spr.animation.play('static');
				case 3:
					if (rightP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (rightR)
						spr.animation.play('static');
			}

			if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});
	}

	function noteMiss(direction:Int = 1):Void
	{
		if (!boyfriend.stunned)
		{
			if (curStage != 'bossmodestage' && curStage != 'caveday'){
			health -= 0.04;
			}
			else if (curStage == 'bossmodestage'){
			bossModeMisses += 1;
			}
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if(curStage != 'caveday'){
				if(curStage != 'bossmodestage'){
					songScore -= 10;
				}
				FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			}
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			boyfriend.stunned = true;

			// get stunned for 5 seconds
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});

			switch (direction)
			{
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
			}
		}
	}

	function badNoteCheck()
	{
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		if (leftP)
			noteMiss(0);
		if (downP)
			noteMiss(1);
		if (upP)
			noteMiss(2);
		if (rightP)
			noteMiss(3);
	}

	function noteCheck(keyP:Bool, note:Note):Void
	{
		if (keyP)
			goodNoteHit(note);
		else
		{
			badNoteCheck();
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				popUpScore(note.strumTime);
				combo += 1;
			}

			if (note.noteData >= 0)
				if (curStage != 'bossmodestage' && curStage != 'caveday'){
				health += 0.023;
				}
				else if (curStage == 'bossmodestage'){
				bossModeHits += 1;
				}
			else
				if (curStage != 'bossmodestage' && curStage != 'caveday'){
				health += 0.004;
				}

			switch (note.noteData)
			{
				case 0:
					boyfriend.playAnim('singLEFT', true);
				case 1:
					boyfriend.playAnim('singDOWN', true);
				case 2:
					boyfriend.playAnim('singUP', true);
				case 3:
					boyfriend.playAnim('singRIGHT', true);
			}

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}
			});

			note.wasGoodHit = true;
			vocals.volume = 1;

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	function moveSpaceBlk():Void
	{
		spaceblk.x = -5000;
	}
	function moveRJ():Void
	{
		FlxG.sound.play(Paths.sound('rj_vanish'));
		rjAnim.animation.play('idle');
		new FlxTimer().start(.4, function(deadTime:FlxTimer)
		{
			rjAnim.x = -5000;	
		});
		
		
	}


	function shardAntiPause():Void
	{
		shardAbility.animation.play('ability');
		health -= .05;
	}

	function immortality():Void
	{
		immortalityReady = true;
		immortalityIcon.x = -5000;
		immortalityIconReady.x = 1300;
	}

	function immortalityUsed():Void
	{
		immortalityReady = false;
		immortalityIcon.x = 1300;
		immortalityIconReady.x = -5000;
		immortalityIcon.animation.play('count');
		new FlxTimer().start(5, function(deadTime:FlxTimer)
		{
			immortality();
		});
	}
	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		if (dad.curCharacter == 'spooky' && curStep % 4 == 2)
		{
			// dad.dance();
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
				dad.dance();
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		// HARDCODING FOR MILF ZOOMS!
		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}
		// HARDCODING FOR CALAMITY STUFF!
		//if (curSong.toLowerCase() == 'calamity')
		//{
		//	FlxG.camera.zoom += 0.015;
		//	camHUD.zoom += 0.03;
		//}
		if (curSong.toLowerCase() == 'calamity' && curBeat == 1)
		{
			
			moveRJ();
		}
		if (curSong.toLowerCase() == 'calamity-boss-mode' && curBeat == 1)
		{
			
			moveRJ();
		}
		if (curSong.toLowerCase() == 'calamity' && curBeat == 94)
		{	
				FlxG.camera.fade(FlxColor.WHITE, 0.2, false, function()
				{
						
							
				}, true);
				new FlxTimer().start(0.5, function(spaceOutTime:FlxTimer)
				{
				    moveSpaceBlk();
					//remove(spaceblk);
					FlxG.camera.fade(FlxColor.WHITE, 1, true);
							
			    });
		}
		if (curSong.toLowerCase() == 'calamity-boss-mode' && curBeat == 94)
		{	
				FlxG.camera.fade(FlxColor.WHITE, 0.2, false, function()
				{
						
							
				}, true);
				new FlxTimer().start(0.5, function(spaceOutTime:FlxTimer)
				{
				    moveSpaceBlk();
					//remove(spaceblk);
					FlxG.camera.fade(FlxColor.WHITE, 1, true);
							
			    });
		}
		if (curSong.toLowerCase() == 'undisturbed' && curBeat == 188)
		{	
				FlxG.camera.fade(FlxColor.WHITE, 0.3, false, function()
				{
					GameOverSubstate.undisturbedRJ = true;
							
				}, true);
				new FlxTimer().start(2.0, function(whiteOutTime:FlxTimer)
				{
				    FlxG.camera.fade(FlxColor.WHITE, 1, true);
							
			    });
		}
		//if (curSong.toLowerCase() == 'undisturbed' && curBeat == 193)
		//{	
		//		FlxG.camera.fade(FlxColor.WHITE, 1, true);
		//}
		if (curSong.toLowerCase() == 'deities' && curBeat == 288)
		{
		
				new FlxTimer().start(0.05, function(bgfadetmr:FlxTimer)
					{
						deitiesbg.alpha -= 0.05;

						if (deitiesbg.alpha > 0)
						{
							bgfadetmr.reset(0.05);
						}
					});
		
		}
		//curBeat is 192
		if (curSong.toLowerCase() == 'undisturbed' && curBeat == 190)
		{
		
				//dad.x = -100;
				//dad.alpha = 1;
				//dad = 'allseer';
				remove(dad);
				remove(boyfriend);
				remove(sky);
				remove(bgback);
				remove(bgfront);
				remove(caveFront);
				
				//var undisturbedRJ = true;
				defaultCamZoom = .3;
				dad = new Character(100, 100, 'allseer');
				dad.setPosition(-180, -450);
				dad.scrollFactor.set(-0.10, 0.10);
				//camPos.x += 300;
				add(dad);
				var shadow:FlxSprite = new FlxSprite(-1500, -350).loadGraphic(Paths.image('deitiesShadow'));
				shadow.setGraphicSize(Std.int(shadow.width * 1.0));
				shadow.updateHitbox();
				shadow.antialiasing = true;
				shadow.scrollFactor.set(0, 0);
				shadow.active = false;
				add(shadow);
				boyfriend = new Boyfriend(770, 450, 'rj');
				dad.y += 400;
				dad.x -= 600;
				boyfriend.y -= 170;
				boyfriend.x -= 25;
				boyfriend.setGraphicSize(Std.int(boyfriend.width * 2.4));
				boyfriend.scrollFactor.set(0.3, 0);
				add(boyfriend);
				

		
		}
		if (curSong.toLowerCase() == 'undisturbed' && curBeat == 188)
		{
		remove(iconP2);
		iconP2 = new HealthIcon('allseer', false);
				iconP2.y = healthBar.y - (iconP2.height / 2);
				iconP2.cameras = [camHUD];
				add(iconP2);
				iconP2.cameras = [camHUD];
		}
		
		
		//Deities stuff
		//if(immortalityReady == false){
			
		//}
		//else{
			
		//}
		if (curSong.toLowerCase() == 'deities' && curBeat == 1)
		{
			
			new FlxTimer().start(0.025, function(tmr:FlxTimer)
			{
				antiPause.alpha += 0.025;

				if (antiPause.alpha < 1)
				{
					tmr.reset(0.025);
				}
			});
			new FlxTimer().start(2.0, function(otherantipausetmr:FlxTimer)
			{
				new FlxTimer().start(0.025, function(timr:FlxTimer)
				{
					antiPause.alpha -= 0.025;
	
					if (antiPause.alpha > 0)
					{
						timr.reset(0.025);
					}
				});
			});

		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing"))
		{
			boyfriend.playAnim('idle');
		}

		if (!allseer.animation.curAnim.name.startsWith("sing"))
		{
			allseer.playAnim('idle');
		}

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}
		//if (curBeat % 8 == 0 && curStage == 'bossmodestage')
		//{
		//	boyfriend.playAnim('hit', true);
		//}
		if (curStage == 'bossmodestage')
		{	
			if(curBeat == 32){
			 if (bossModeMisses > (bossModeHits * .75)){
			 FlxG.sound.play(Paths.sound('bfhurt'));
				vocals.volume = 1;
				dad.playAnim('attack', true);
				boyfriend.playAnim('hit', true);
				bossModeHealth -= 1;
				bossModeMisses = 0;
				bossModeHits = 0;
			 }
			 else{
			 FlxG.sound.play(Paths.sound('shardhurt'));
			 dad.playAnim('stun', true);
			 //change back to .167 after testing
			 health += .167;
			 bossModeMisses = 0;
			 bossModeHits = 0;
			 }
			}
			if(curBeat == 64){
			 if (bossModeMisses > (bossModeHits * .75)){
			 FlxG.sound.play(Paths.sound('bfhurt'));
				vocals.volume = 1;
				dad.playAnim('attack', false);
				boyfriend.playAnim('hit', true);
				bossModeHealth -= 1;
				bossModeMisses = 0;
				bossModeHits = 0;
			 }
			 else{
			 FlxG.sound.play(Paths.sound('shardhurt'));
			 dad.playAnim('stun', false);
			 health += .167;
			 bossModeMisses = 0;
			 bossModeHits = 0;
			 }
			}
			if(curBeat == 80){
			 if (bossModeMisses > (bossModeHits * .75)){
			 FlxG.sound.play(Paths.sound('bfhurt'));
			 	vocals.volume = 1;
				dad.playAnim('attack', true);
				boyfriend.playAnim('hit', true);
				bossModeHealth -= 1;
				bossModeMisses = 0;
				bossModeHits = 0;
			 }
			 else{
			 FlxG.sound.play(Paths.sound('shardhurt'));
			 dad.playAnim('stun', true);
			 health += .167;
			 bossModeMisses = 0;
			 bossModeHits = 0;
			 }
			}
			if(curBeat == 96){
			 if (bossModeMisses > (bossModeHits * .75)){
			 FlxG.sound.play(Paths.sound('bfhurt'));
			 	vocals.volume = 1;
				dad.playAnim('attack', true);
				boyfriend.playAnim('hit', true);
				bossModeHealth -= 1;
				bossModeMisses = 0;
				bossModeHits = 0;
			 }
			 else{
			 FlxG.sound.play(Paths.sound('shardhurt'));
			 dad.playAnim('stun', true);
			 health += .167;
			 bossModeMisses = 0;
			 bossModeHits = 0;
			 }
			}
			if(curBeat == 128){
			 if (bossModeMisses > (bossModeHits * .75)){
			 FlxG.sound.play(Paths.sound('bfhurt'));
			 	vocals.volume = 1;
				dad.playAnim('attack', true);
				boyfriend.playAnim('hit', true);
				bossModeHealth -= 1;
				bossModeMisses = 0;
				bossModeHits = 0;
			 }
			 else{
			 FlxG.sound.play(Paths.sound('shardhurt'));
			 dad.playAnim('stun', true);
			 health += .167;
			 bossModeMisses = 0;
			 bossModeHits = 0;
			 }
			}
			if(curBeat == 160){
			 if (bossModeMisses > (bossModeHits * .75)){
			 FlxG.sound.play(Paths.sound('bfhurt'));
			 	vocals.volume = 1;
				dad.playAnim('attack', true);
				boyfriend.playAnim('hit', true);
				bossModeHealth -= 1;
				bossModeMisses = 0;
				bossModeHits = 0;
			 }
			 else{
			 FlxG.sound.play(Paths.sound('shardhurt'));
			 dad.playAnim('stun', true);
			 health += .167;
			 bossModeMisses = 0;
			 bossModeHits = 0;
			 }
			}
			if(curBeat == 192){
			 if (bossModeMisses > (bossModeHits * .75)){
			 FlxG.sound.play(Paths.sound('bfhurt'));
			 	vocals.volume = 1;
				dad.playAnim('attack', true);
				boyfriend.playAnim('hit', true);
				bossModeHealth -= 1;
				bossModeMisses = 0;
				bossModeHits = 0;
			 }
			 else{
			 FlxG.sound.play(Paths.sound('shardhurt'));
			 dad.playAnim('stun', true);
			 health += .167;
			 bossModeMisses = 0;
			 bossModeHits = 0;
			 }
			}
			if(curBeat == 224){
			 if (bossModeMisses > (bossModeHits * .75)){
			 FlxG.sound.play(Paths.sound('bfhurt'));
			 	vocals.volume = 1;
				dad.playAnim('attack', true);
				boyfriend.playAnim('hit', true);
				bossModeHealth -= 1;
				bossModeMisses = 0;
				bossModeHits = 0;
			 }
			 else{
			 FlxG.sound.play(Paths.sound('shardhurt'));
			 dad.playAnim('stun', true);
			 health += .167;
			 bossModeMisses = 0;
			 bossModeHits = 0;
			 }
			}
			if(curBeat == 256){
			 if (bossModeMisses  > (bossModeHits * .75)){
			 FlxG.sound.play(Paths.sound('bfhurt'));
			 	vocals.volume = 1;
				dad.playAnim('attack', true);
				boyfriend.playAnim('hit', true);
				bossModeHealth -= 1;
				bossModeMisses = 0;
				bossModeHits = 0;
			 }
			 else{
			 FlxG.sound.play(Paths.sound('shardhurt'));
			 dad.playAnim('stun', true);
			 health += .167;
			 bossModeMisses = 0;
			 bossModeHits = 0;
			 }
			}
			if(curBeat == 272){
			 if (bossModeMisses > (bossModeHits * .75)){
			 FlxG.sound.play(Paths.sound('bfhurt'));
			 	vocals.volume = 1;
				dad.playAnim('attack', true);
				boyfriend.playAnim('hit', true);
				bossModeHealth -= 1;
				bossModeMisses = 0;
				bossModeHits = 0;
			 }
			 else{
			 FlxG.sound.play(Paths.sound('shardhurt'));
			 dad.playAnim('stun', true);
			 health += .167;
			 bossModeMisses = 0;
			 bossModeHits = 0;
			 }
			}
			if(curBeat == 288){
			 if (bossModeMisses > (bossModeHits * .75)){
			 FlxG.sound.play(Paths.sound('bfhurt'));
			 	vocals.volume = 1;
				dad.playAnim('attack', true);
				boyfriend.playAnim('hit', true);
				bossModeHealth -= 1;
				bossModeMisses = 0;
				bossModeHits = 0;
			 }
			 else{
			 FlxG.sound.play(Paths.sound('shardhurt'));
			 dad.playAnim('stun', true);
			 health += .167;
			 bossModeMisses = 0;
			 bossModeHits = 0;
			 }
			}
			if(curBeat == 352){
			 if (bossModeMisses > (bossModeHits * .75)){
			 FlxG.sound.play(Paths.sound('bfhurt'));
			 	vocals.volume = 1;
				dad.playAnim('attack', true);
				boyfriend.playAnim('hit', true);
				bossModeHealth -= 2;
				bossModeMisses = 0;
				bossModeHits = 0;
			 }
			 else{
			 FlxG.sound.play(Paths.sound('shardhurt'));
			 dad.playAnim('stun', true);
			 health += .334;
			 bossModeMisses = 0;
			 bossModeHits = 0;
			 }
			}
			if(curBeat == 384){
			 if (bossModeMisses > (bossModeHits * .75)){
			 FlxG.sound.play(Paths.sound('bfhurt'));
			 	vocals.volume = 1;
				dad.playAnim('attack', true);
				boyfriend.playAnim('hit', true);
				bossModeHealth -= 1;
				bossModeMisses = 0;
				bossModeHits = 0;
			 }
			 else{
			 FlxG.sound.play(Paths.sound('shardhurt'));
			 dad.playAnim('stun', true);
			 health += .167;
			 bossModeMisses = 0;
			 bossModeHits = 0;
			 }
			}
			if(curBeat == 416){
			 if (bossModeMisses > (bossModeHits * .75)){
			 FlxG.sound.play(Paths.sound('bfhurt'));
			 	vocals.volume = 1;
				dad.playAnim('attack', true);
				boyfriend.playAnim('hit', true);
				bossModeHealth -= 1;
				bossModeMisses = 0;
				bossModeHits = 0;
			 }
			 else{
			 FlxG.sound.play(Paths.sound('shardhurt'));
			 dad.playAnim('stun', true);
			 health += .167;
			 bossModeMisses = 0;
			 bossModeHits = 0;
			 }
			}
			if(curBeat == 448){
			 if (bossModeMisses > (bossModeHits * .75)){
			 FlxG.sound.play(Paths.sound('bfhurt'));
			 	vocals.volume = 1;
				dad.playAnim('attack', true);
				boyfriend.playAnim('hit', true);
				bossModeHealth -= 1;
				bossModeMisses = 0;
				bossModeHits = 0;
			 }
			 else{
			 FlxG.sound.play(Paths.sound('shardhurt'));
			 dad.playAnim('stun', true);
			 health += .167;
			 bossModeMisses = 0;
			 bossModeHits = 0;
			 }
			}
			if(curBeat == 480){
			 if (bossModeMisses > (bossModeHits * .75)){
				FlxG.sound.play(Paths.sound('bfhurt'));
			 	vocals.volume = 1;
				dad.playAnim('attack', true);
				boyfriend.playAnim('hit', true);
				bossModeHealth -= 1;
				bossModeMisses = 0;
				bossModeHits = 0;
			 }
			 else{
			 FlxG.sound.play(Paths.sound('shardhurt'));
			 dad.playAnim('stun', true);
			 health += .167;
			 bossModeMisses = 0;
			 bossModeHits = 0;
			 }
			}
			if(curBeat == 496){
			 if (bossModeMisses > (bossModeHits * .75)){
			 FlxG.sound.play(Paths.sound('bfhurt'));
			 	vocals.volume = 1;
				dad.playAnim('attack', true);
				boyfriend.playAnim('hit', true);
				bossModeHealth -= 1;
				bossModeMisses = 0;
				bossModeHits = 0;
			 }
			 else{
			 FlxG.sound.play(Paths.sound('shardhurt'));
			 dad.playAnim('stun', true);
			 health += .167;
			 bossModeMisses = 0;
			 bossModeHits = 0;
			 }
			}
			if(curBeat == 512){
			 if (bossModeMisses > (bossModeHits * .75)){
			 FlxG.sound.play(Paths.sound('bfhurt'));
			 	vocals.volume = 1;
				dad.playAnim('attack', true);
				boyfriend.playAnim('hit', true);
				bossModeHealth -= 1;
				bossModeMisses = 0;
				bossModeHits = 0;
			 }
			 else{
			 FlxG.sound.play(Paths.sound('shardhurt'));
			 dad.playAnim('stun', true);
			 health += .167;
			 bossModeMisses = 0;
			 bossModeHits = 0;
			 }
			}
			if(curBeat == 544){
			 if (bossModeMisses > (bossModeHits * .75)){
			 FlxG.sound.play(Paths.sound('bfhurt'));
			 	vocals.volume = 1;
				dad.playAnim('attack', true);
				boyfriend.playAnim('hit', true);
				bossModeHealth -= 1;
				bossModeMisses = 0;
				bossModeHits = 0;
			 }
			 else{
			 FlxG.sound.play(Paths.sound('shardhurt'));
			 dad.playAnim('stun', true);
			 health += .167;
			 bossModeMisses = 0;
			 bossModeHits = 0;
			 }
			}

		}
		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}
		if (curBeat == 1 && curStage == 'caveday')
		{
			rjEndAnim.animation.play('hands');
		}
		if (curBeat == 3 && curStage == 'caveday')
		{
			FlxTween.tween(FlxG.camera, {zoom: 8}, 2.5, {
			ease: FlxEase.quadInOut,
			onComplete: function(twn:FlxTween)
			{
				//startCountdown();
			}
			});
			new FlxTimer().start(0.7, function(spaceOutTime:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 1, false);
				new FlxTimer().start(2, function(replacebgtimer:FlxTimer)
				{
					FlxG.camera.fade(FlxColor.BLACK, .1, true);
					var blkscrn = new FlxSprite(0, 0).loadGraphic(Paths.image('spaceblack'));
		                    blkscrn.scale.set(5, 5);
		                    add(blkscrn);	
							FlxTween.tween(FlxG.camera, {zoom: .2}, .5, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween)
							{
							}
							});
				});			
			});
		}
		if (curBeat == 48 && curStage == 'caveday')
		{
			iconP2.alpha = .33;
			defaultCamZoom = .2;
			add(flame);
			flame.animation.play('flamestart');
			new FlxTimer().start(0.2, function(flametimer:FlxTimer)
			{
				flame.animation.play('flameburn');
			});	
		}
		if (curBeat == 64 && curStage == 'caveday')
		{
			iconP2.alpha = .66;
			FlxTween.tween(FlxG.camera, {zoom: .5}, 1, {
			ease: FlxEase.quadInOut,
			onComplete: function(twn:FlxTween)
			{
			defaultCamZoom = .5;
			}
			});
		}
		if (curBeat == 80 && curStage == 'caveday')
		{
			iconP2.alpha = 1;
			FlxTween.tween(FlxG.camera, {zoom: .9}, 1, {
			ease: FlxEase.quadInOut,
			onComplete: function(twn:FlxTween)
			{
			defaultCamZoom = .9;
			}
			});
		}
		if (curBeat == 94 && curStage == 'caveday')
		{
			FlxG.camera.fade(FlxColor.WHITE, .5, false);
		}
		if (curBeat == 96 && curStage == 'caveday')
		{
			FlxG.camera.fade(FlxColor.WHITE, 0, true);
			strumLineNotes.visible = false;
			notes.visible = false;
			healthBar.visible = false;
			healthBarBG.visible = false;
			iconP1.visible = false;
			iconP2.visible = false;
			scoreTxt.visible = false;
			add(credits);
			credits.animation.play('one');
		}
		if (curBeat == 104 && curStage == 'caveday')
		{
			credits.animation.play('two');
		}
		if (curBeat == 112 && curStage == 'caveday')
		{
			credits.animation.play('three');
		}
		if (curBeat == 120 && curStage == 'caveday')
		{
			credits.animation.play('four');
		}
		if (curBeat == 126 && curStage == 'caveday')
		{
			credits.animation.play('five');
		}
		if (curBeat == 127 && curStage == 'caveday')
		{
			credits.animation.play('six');
		}
		if (dad.curCharacter == 'allseer')
		{
			dad.antialiasing = true;
		}

		switch (curStage)
		{
			case 'school':
				bgGirls.dance();

			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'limo':
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(light:FlxSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					phillyCityLights.members[curLight].visible = true;
					// phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
	}

	var curLight:Int = 0;
}
