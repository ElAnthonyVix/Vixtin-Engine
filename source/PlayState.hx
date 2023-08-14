package;

#if web
import js.lib.intl.RelativeTimeFormat.RelativeTimeUnit;
#end
import openfl.Lib;
import flixel.util.typeLimit.OneOfTwo;
import Character.EpicLevel;
import flixel.ui.FlxButton.FlxTypedButton;
import flixel.ui.FlxButton;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import openfl.geom.Matrix;
import flixel.FlxGame;
import WiggleEffect.WiggleEffectType;
import flixel.FlxObject;
import flixel.graphics.FlxGraphic;
#if desktop
import Sys;
import sys.FileSystem;

#if cpp
import Discord.DiscordClient;
#end
#end
import DifficultyIcons;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.FlxState;
import flixel.FlxSubState;
import flash.display.BitmapData;
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
import flixel.addons.editors.pex.FlxPexParser;
import flixel.addons.text.FlxTypeText;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import flixel.addons.display.FlxBackdrop;
import lime.system.System;
import openfl.media.Sound;
import flixel.group.FlxGroup;
import hscript.Interp;
import hscript.Parser;
import hscript.ParserEx;
import hscript.InterpEx;
import hscript.ClassDeclEx;
import openfl.filters.ShaderFilter;
import Note.EventNote;
import openfl.filters.BitmapFilter;
import Shaders;
import openfl.events.KeyboardEvent;
#if sys
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;

#end
import tjson.TJSON;
import Judgement.TUI;
using StringTools;
using CoolUtil.FlxTools;
#if VIDEOS_ALLOWED
import hxcodec.flixel.FlxVideo as FlxVideo;
#end
#if mobile
import flixel.input.actions.FlxActionInput;
import android.AndroidControls.AndroidControls;
import android.FlxVirtualPad;
#end
typedef LuaAnim = {
	var prefix : String;
	@:optional var indices: Array<Int>;
	var name : String;
	@:optional var fps : Int;
	@:optional var loop : Bool;
}
enum abstract DisplayLayer(Int) from Int to Int {
	var BEHIND_GF = 1;
	var BEHIND_BF = 1 << 1;
	var BEHIND_DAD = 1 << 2;
	var BEHIND_ALL = BEHIND_GF | BEHIND_BF | BEHIND_DAD;
}
class PlayState extends MusicBeatState
{
	#if desktop
	public static var customPrecence = FNFAssets.getText(SUtil.getPath() + "assets/discord/presence/play.txt");
	#end
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var defaultPlaylistLength = 0;
	public static var campaignScoreDef = 0;
	public static var ss:Bool = true;
	public static var gOverSuffix:String = "";
	public var forceAlphaStrum:Bool = true;
	public var endingCutscene = false;
	public var hasDefaultBoom = true;
	
	public var modTweens:Array<FlxTween> = [];
	public var modTimers:Array<FlxTimer> = [];

	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Character> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	public var spriteZone:Map<String, FlxSprite> = new Map();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	public var spriteZone:Map<String, FlxSprite> = new Map<String, FlxSprite>();
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var camSpeed:Float = 0.04;

	public var cfDuration:Float = 0.75;
	public var cfIntensity:Float = 1.0;
	public var cfBlend:String = "add";

	public var judOffsetX:Float = 0;
	public var judOffsetY:Float = 0;

	public var boyfriendGroup:FlxTypedGroup<Character>;
	public var dadGroup:FlxTypedGroup<Character>;
	public var gfGroup:FlxTypedGroup<Character>;

	private var vocals:FlxSound;
	private var vsounds:FlxSound;
	public static var noteSpeedest:Float = 0.45;
	// use old bf
	private var oldMode:Bool = false;
	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Character;

	public var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];
	// var curVideo:Null<Dynamic> = null;

	public var strumLine:FlxSprite;
	private var curSection:Int = 0;
	var totalNotesHit:Float = 0;
	var totalPlayed:Int =0;
	var inVideoCutscene:Bool = false;
	var totalNotesHitDefault:Float = 0;
	public var camFollow:FlxObject;
	private var player1Icon:String;
	private var player2Icon:String;
	public static var prevCamFollow:FlxObject;

	//Shader shit lol
	public var shaderUpdates:Array<Float->Void> = [];
	public var camGameShaders:Array<ShaderEffect> = [];
	public var camHUDShaders:Array<ShaderEffect> = [];

	//more keys!
	public static var mania:Int;

	public static var misses:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	private var accuracy:Float = 0.00;
	private var accuracyDefault:Float = 0.00;
	public static var sicks:Int = 0;
	public var songPosBar:FlxBar;
	public var songPosBG:FlxSprite;
	public var songPositionBar:Float = 0;
	var songLength:Float = 0.0;
	var songScoreDef:Int = 0;
	var nps:Int = 0;
	var currentTimingShown:FlxText;
	var playingAsRpc:String = "";
	private var strumLineNotes:FlxTypedGroup<StrumNote>;
	private var playerStrums:FlxTypedGroup<StrumNote>;
	private var enemyStrums:FlxTypedGroup<StrumNote>;
	private var playerComboBreak:FlxTypedGroup<FlxSprite>;
	private var enemyComboBreak:FlxTypedGroup<FlxSprite>;
	public var shitBreakColor:FlxColor = 0xFF175DB3;
	public var wayoffBreakColor:FlxColor = 0xFFAF0000;
	public var missBreakColor:FlxColor = 0xFFDD0A93;
	
	public static var instance:PlayState;

	private var camZooming:Bool = false;
	private var curSong:String = "";
	private var strumming2:Array<Bool> = [false, false, false, false];
	private var strumming1:Array<Bool> = [false,false,false,false];

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	private var combo:Int = 0;
	public var daScrollSpeed:Float = 1;
	public static var duoMode:Bool = false;
	public static var gameOverChar:String;
	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;
	//private var enemyColor:FlxColor = 0xFFFF0000;
	//private var opponentColor:FlxColor = 0xFFBC47FF;
	// private var playerColor:FlxColor = 0xFF66FF33;
	// private var poisonColor:FlxColor = 0xFFA22CD1;
	// private var poisonColorEnemy:FlxColor = 0xFFEA2FFF;
	// private var bfColor:FlxColor = 0xFF149DFF;
	private var barShowingPoison:Bool = false;
	private var pixelUI:Bool = false;
	#if (desktop && cpp)
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end
	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;
	/**
	 * Icon of player one
	 */
	public var iconP1:HealthIcon;
	/**
	 * Icon of player two
	 */
	public var iconP2:HealthIcon;
	/**
	 * HUD Camera (arrows, health)
	 */
	public var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	public var doof:DialogueBox;
	public var forceCamera:Bool = false;



	var talking:Bool = true;
	var songScore:Int = 0;
	var trueScore:Int = 0;
	var scoreTxt:FlxText;
	var healthTxt:FlxText;
	var accuracyTxt:FlxText;
	var difficTxt:FlxText;
	// hehe fuck around with these lamo
	public static var oldx:Float;
	public static var oldy:Float;
	/**
	 * The total score of the week. Not a good idea to touch
	 * as it is a total and not divided until the end.
	 */
	public static var campaignScore:Int = 0;
	/**
	 * Total Accuracy of the week. Not a good idea to touch as it is a total. 
	 */
	public static var campaignAccuracy:Float = 0;

	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;
	public var defaultCamZoom:Float = 1.05;
	public var disableScoreChange:Bool = false;
	var grpNoteSplashes:FlxTypedGroup<NoteSplash>;
	var grpCrossfades:FlxTypedGroup<FlxSprite>;
	/**
	 * How big pixel assets are stretched
	 */
	public static var daPixelZoom:Float = 6;

	var bfoffset = [0.0, 0.0];
	var gfoffset = [0.0, 0.0];
	var dadoffset = [0.0, 0.0];

	public var skipCountdown:Bool = false;
	public static var chartingMode:Bool = false;
	var inCutscene:Bool = false;
	var alwaysDoCutscenes = false;
	var fullComboMode:Bool = false;
	var perfectMode:Bool = false;
	var practiceMode:Bool = false;
	public static var healthLossMultiplier:Float = 1;
	public static var healthGainMultiplier:Float = 1;
	var poisonExr:Bool = false;
	var poisonPlus:Bool = false;
	var beingPoisioned:Bool = false;
	var poisonTimes:Int = 0;
	var flippedNotes:Bool = false;
	var noteSpeed:Float = 0.45;
	var practiceDied:Bool = false;
	var practiceDieIcon:HealthIcon;
	private var regenTimer:FlxTimer;
	var sickFastTimer:FlxTimer;
	var accelNotes:Bool = false;
	var notesHit:Float = 0;
	var notesPassing:Int = 0;
	var vnshNotes:Bool = false;
	var invsNotes:Bool = false;
	var snakeNotes:Bool = false;
	var snekNumber:Float = 0;
	var drunkNotes:Bool = false;
	var alcholTimer:FlxTimer;
	var notesHitArray:Array<Date> = [];
	var alcholNumber:Float = 0;
	var inALoop:Bool = false;
	var useVictoryScreen:Bool = true;
	var demoMode:Bool = false;
	var downscroll:Bool = false;
	var luaRegistered:Bool = false;
	var currentFrames:Int = 0;
	var supLove:Bool = false;
	var loveMultiplier:Float = 0;
	var poisonMultiplier:Float = 0;
	var goodCombo:Bool = false;
	var isUsingSounds:Bool = false;
	public var player1GoodHitSignal:Signal<Note>;
	public var player2GoodHitSignal:Signal<Note>;
	private var judgementList:Array<String> = [];
	private var preferredJudgement:String = '';
	/**
	 * If we are playing as opponent. 
	 */
	public static var opponentPlayer:Bool = false;
	/**
	 *  How much health is drained/regened with Supportive love 
	 * or Poison Fright
	 */
	 @:deprecated("REPLACED BY MODIFIER NUMBERS")
	public var drainBy:Float = 0.005;
	/**
	 * Auto update note x pos to be under their correct strumline pos. 
	 * 
	 */
	public var snapToStrumline:Bool = false;
	public var songSpeedTween:FlxTween;
	var oldStrumlineX:Float = 0;
	// this is just so i can collapse it lol
	#if true
	var hscriptStates:Map<String, Interp> = [];
	var hscriptIsModChart:Map<String, Bool> = [];
	var exInterp:InterpEx = new InterpEx();
	var haxeSprites:Map<String, FlxSprite> = [];
	var traced:Bool = false;
    public function callHscript(func_name:String, args:Array<Dynamic>, usehaxe:String) {
		// if function doesn't exist
			try{
		if (!hscriptStates.get(usehaxe).variables.exists(func_name)) {
			if (!traced){
			trace("Function doesn't exist, silently skipping...");
			traced = true;
			}
			return;
		}
		var method = hscriptStates.get(usehaxe).variables.get(func_name);
		switch(args.length) {
			case 0:
				method();
			case 1:
				method(args[0]);
			case 2:
				method(args[0], args[1]);
			case 3:
				method(args[0], args[1], args[2]);
			case 4:
				method(args[0], args[1], args[2], args[3]);
			case 5:
				method(args[0], args[1], args[2], args[3], args[4]);
			case 6:
				method(args[0], args[1], args[2], args[3], args[4], args[5]);
			case 7:
				method(args[0], args[1], args[2], args[3], args[4], args[5], args[6]);
			case 8:
				method(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7]);
		}
	}
	catch(e){
		openfl.Lib.application.window.alert(e.message, "your function had some problem...");
	}
}
	public function callAllHScript(func_name:String, args:Array<Dynamic>) {
		for (key in hscriptStates.keys()) {
			callHscript(func_name, args, key);
		}
	}
	public function setHaxeVar(name:String, value:Dynamic, usehaxe:String) {
		try{
		hscriptStates.get(usehaxe).variables.set(name,value);
		}
		catch(e){
			openfl.Lib.application.window.alert(e.message, "your variable had some problem...");
		}
	}
	public function setAllHaxeVar(name:String, value:Dynamic) {
		for (key in hscriptStates.keys())
			setHaxeVar(name, value, key);
	}
	function getHaxeActor(name:String):Dynamic {
		switch (name) {
			case "boyfriend" | "bf":
				return boyfriend;
			case "girlfriend" | "gf":
				return gf;
			case "dad":
				return dad;
			default:
				return strumLineNotes.members[Std.parseInt(name)];
		}
	}
	function getHaxeVar(name:String, usehaxe:String):Dynamic {
		var theValue = hscriptStates.get(usehaxe).variables.get(name);
		return theValue;
	}
	function camerabgAlphaShits(cam:FlxCamera)
		{
			cam.bgColor.alpha = 0;
		}
		function addVirtualPads(dPad:String,act:String){
			#if mobile
			addVirtualPad(dPadModeFromString(dPad),actionModeModeFromString(act));
			#end
		}
		
		function getHaxeVirtualPad(dumbass:String = ''):FlxButton
			{
				#if mobile
				var lmao =  Reflect.field(_virtualpad, 'button' + dumbass);
				return lmao;
				#else
				return null;
				#end
			}
			#if mobile
		public function dPadModeFromString(lmao:String):FlxDPadMode{
		switch (lmao){
		case 'up_down':return FlxDPadMode.UP_DOWN;
		case 'left_right':return FlxDPadMode.LEFT_RIGHT;
		case 'up_left_right':return FlxDPadMode.UP_LEFT_RIGHT;
		case 'full':return FlxDPadMode.FULL;
		case 'right_full':return FlxDPadMode.RIGHT_FULL;
		case 'none':return FlxDPadMode.NONE;
		}
		return FlxDPadMode.NONE;
		}
		public function actionModeModeFromString(lmao:String):FlxActionMode{
			switch (lmao){
			case 'a':return FlxActionMode.A;
			case 'b':return FlxActionMode.B;
			case 'd':return FlxActionMode.D;
			case 'a_b':return FlxActionMode.A_B;
			case 'a_b_c':return FlxActionMode.A_B_C;
			case 'a_b_e':return FlxActionMode.A_B_E;
			case 'a_b_7':return FlxActionMode.A_B_7;
			case 'a_b_x_y':return FlxActionMode.A_B_X_Y;
			case 'a_b_c_x_y':return FlxActionMode.A_B_C_X_Y;
			case 'a_b_c_x_y_z':return FlxActionMode.A_B_C_X_Y_Z;
			case 'full':return FlxActionMode.FULL;
			case 'none':return FlxActionMode.NONE;
			}
			return FlxActionMode.NONE;
			}
		#end
		public function visPressed(dumbass:String = ''):Bool{
			#if mobile
			
			return _virtualpad.returnPressed(dumbass);
			#else
			return false;
			#end
		}
	function makeHaxeState(usehaxe:String, path:String, filename:String) {
		trace("opening a haxe state (because we are cool :))");
		var parser = new ParserEx();
		var program = parser.parseString(FNFAssets.getHscript(path + filename));
		var interp = PluginManager.createSimpleInterp();
		// set vars
		#if mobile
		interp.variables.set("addVirtualPad", addVirtualPad);
		interp.variables.set("removeVirtualPad", removeVirtualPad);
		interp.variables.set("addPadCamera", addPadCamera);
		interp.variables.set("addAndroidControls", addAndroidControls);
		interp.variables.set("_virtualpad", _virtualpad);
		interp.variables.set("dPadModeFromString", dPadModeFromString);
		interp.variables.set("actionModeModeFromString", actionModeModeFromString);
	
		#end
		interp.variables.set("addVirtualPads", addVirtualPads);
		interp.variables.set("visPressed", visPressed);
		interp.variables.set("BEHIND_GF", BEHIND_GF);
		interp.variables.set("BEHIND_BF", BEHIND_BF);
		interp.variables.set("BEHIND_DAD", BEHIND_DAD);
		interp.variables.set("BEHIND_ALL", BEHIND_ALL);
		interp.variables.set("BEHIND_NONE", 0);
		interp.variables.set("difficulty", storyDifficulty);
		interp.variables.set("isDemoMode", ModifierState.namedModifiers.demo.value);
		interp.variables.set("bpm", Conductor.bpm);
		interp.variables.set("songData", SONG);
		interp.variables.set("curSong", SONG.song);
		interp.variables.set("curStep", 0);
		interp.variables.set("curBeat", 0);
		interp.variables.set("camHUD", camHUD);
		interp.variables.set("pi", Math.PI);
		interp.variables.set("FlxTypeText", FlxTypeText);
		interp.variables.set("FlxPexParser", FlxPexParser);
		interp.variables.set("FlxEmitter", FlxEmitter);
		interp.variables.set("FlxParticle", FlxParticle);
		interp.variables.set("setPresence", function (to:String) {
			#if (desktop && cpp)
			customPrecence = to;
			updatePrecence();
			#else 
			FlxG.log.warn("Ignoring hscript setPresence as we aren't on windows");
			#end
		});
		
		interp.variables.set("showOnlyStrums", false);
		interp.variables.set("playerStrums", playerStrums);
		interp.variables.set("enemyStrums", enemyStrums);
		interp.variables.set("mustHit", false);
		interp.variables.set("strumLineY", strumLine.y);
		interp.variables.set("hscriptPath", path);
		interp.variables.set("addCustomShaderToSprite", addCustomShaderToSprite);
		interp.variables.set("addCustomShaderToCam", addCustomShaderToCam);

		interp.variables.set("boyfriend", boyfriend);
		interp.variables.set("gf", gf);
		interp.variables.set("dad", dad);
		interp.variables.set("vocals", vocals);
		interp.variables.set("gfSpeed", gfSpeed);
		interp.variables.set("tweenCamIn", tweenCamIn);
		interp.variables.set("health", health);
		interp.variables.set("iconP1", iconP1);
		interp.variables.set("iconP2", iconP2);
		interp.variables.set("currentPlayState", this);
		interp.variables.set("PlayState", PlayState);
		interp.variables.set("makeText", function (posx:Float, posy:Float, fwidth:Float, ?text:String, size:Int = 8, embFont:Bool = true) {
			return (new FlxText(posx, posy, fwidth, text, size, embFont)); //make text in hcripts
		});
		interp.variables.set("window", Lib.application.window);
		// give them access to save data, everything will be fine ;)
		interp.variables.set("isInCutscene", function () return inCutscene);
		trace("set vars");
		interp.variables.set("camZooming", false);
		// callbacks
		interp.variables.set("start", function (song) {});
		interp.variables.set("beatHit", function (beat) {});
		interp.variables.set("update", function (elapsed) {});
		interp.variables.set("endUpdate", function (elapsed) {});
		interp.variables.set("stepHit", function(step) {});
		interp.variables.set("playerTwoTurn", function () {});
		interp.variables.set("playerTwoMiss", function () {});
		interp.variables.set("playerTwoSing", function () {});
		interp.variables.set("playerOneTurn", function() {});
		interp.variables.set("playerOneMiss", function() {});
		interp.variables.set("playerOneSing", function() {});
		//interp.variables.set("noteHit", function(player1:Bool, note:Note, wasGoodHit:Bool) {});
		interp.variables.set("goodNoteHit", function(id:Note, direction:Int, noteType:String, isSustainNote:Bool, isPlayer:Bool) {});
		interp.variables.set("noteMiss", function(id, direction, noteType, isSustainNote, isPlayer) {});
		interp.variables.set("blendModeFromString", blendModeFromString);
		interp.variables.set("addSprite", function (sprite, position) {
			// sprite is a FlxSprite
			// position is a Int
			if (position & BEHIND_GF != 0)
				remove(gfGroup);
			if ((position & BEHIND_DAD != 0) || (position & BEHIND_BF != 0))
				remove(grpCrossfades);
			if (position & BEHIND_DAD != 0)
				remove(dadGroup);
			if (position & BEHIND_BF != 0)
				remove(boyfriendGroup);
			add(sprite);
			if (position & BEHIND_GF != 0)
				add(gfGroup);
			if ((position & BEHIND_DAD != 0) || (position & BEHIND_BF != 0))
				add(grpCrossfades);
			if (position & BEHIND_DAD != 0)	
				add(dadGroup);
			if (position & BEHIND_BF != 0)
				add(boyfriendGroup); 
		});
		interp.variables.set("add", add);
		interp.variables.set("remove", remove);
		interp.variables.set("insert", insert);
		interp.variables.set("replace", replace);
		interp.variables.set("setDefaultZoom", function(zoom:Float){
			defaultCamZoom = zoom;
			FlxG.camera.zoom = zoom;
		});
		interp.variables.set("removeSprite", function(sprite) {
			remove(sprite);
		});
		interp.variables.set("getHaxeActor", getHaxeActor);
		interp.variables.set("instancePluginClass", instanceExClass);
		interp.variables.set("scaleChar", function (char:String, amount:Float) {
			switch(char) {
				case 'boyfriend':
					remove(boyfriend);
					boyfriend.setGraphicSize(Std.int(boyfriend.width * amount));
					boyfriend.y *= amount;
					add(boyfriend);
				case 'dad':
					remove(dad);
					dad.setGraphicSize(Std.int(dad.width * amount));
					dad.y *= amount;
					add(dad);
				case 'gf':
					remove(gf);
					gf.setGraphicSize(Std.int(gf.width * amount));
					gf.y *= amount;
					add(gf);
			}
		});
		interp.variables.set("preloadCharsFromFile", preloadCharsFromFile);
		interp.variables.set("addCharacterToList", addCharacterToList);
		interp.variables.set("changeCharacter", changeCharacter);
		interp.variables.set("removeCharacterFromList", removeCharacterFromList);
		interp.variables.set("setGlobalSprite", setGlobalSprite);
		interp.variables.set("getGlobalSprite", getGlobalSprite);
		interp.variables.set("removeGlobalSprite", removeGlobalSprite);
		interp.variables.set("change_songSpeed", change_songSpeed);
		interp.variables.set("flixG", FlxG);

		//Shader Shit
		interp.variables.set("addPulseEffect", addPulseEffect);
		interp.variables.set("addDistortionEffect", addDistortionEffect);
		interp.variables.set("addInvertEffect", addInvertEffect);
		interp.variables.set("addGrayScaleEffect", addGrayScaleEffect);
		interp.variables.set("addScanLineEffect", addScanLineEffect);
		interp.variables.set("addChromaticAberrationEffect", addChromaticAberrationEffect);
		interp.variables.set("ShaderHandler", ShaderHandler);
		interp.variables.set("OverlayShader", OverlayShader);
		interp.variables.set("ColorSwap", ColorSwap);
		interp.variables.set("ShaderFilter", ShaderFilter);

		//Fow Ending Cutscenes lol
		interp.variables.set("endSong", endSong);
		interp.variables.set("endForReal", endForReal);
		try{
			trace("set stuff");
			interp.execute(program);
			hscriptStates.set(usehaxe,interp);
			callHscript("start", [SONG.song], usehaxe);
			trace('executed');
			}
			catch (e) {
				openfl.Lib.application.window.alert(e.message, "YOUR SCRIPT CRASHED!");
			}
		
	}

	function makeHaxeStateUI(usehaxe:String, path:String, filename:String) {
		trace("opening a haxe state (because we are cool :))");
		var parser = new ParserEx();
		var program = parser.parseString(FNFAssets.getText(path + filename));
		var interp = PluginManager.createSimpleInterp();
		// set vars
		#if mobile
		interp.variables.set("addVirtualPad", addVirtualPad);
		interp.variables.set("removeVirtualPad", removeVirtualPad);
		interp.variables.set("addPadCamera", addPadCamera);
		interp.variables.set("addAndroidControls", addAndroidControls);
		interp.variables.set("_virtualpad", _virtualpad);
		interp.variables.set("dPadModeFromString", dPadModeFromString);
		interp.variables.set("actionModeModeFromString", actionModeModeFromString);
	
		#end
		interp.variables.set("addVirtualPads", addVirtualPads);
		interp.variables.set("visPressed", visPressed);
		interp.variables.set("difficulty", storyDifficulty);
	    interp.variables.set("Math", Math);
		interp.variables.set("Conductor", Conductor);
		interp.variables.set("songData", SONG);
		interp.variables.set("curSong", SONG.song);
		interp.variables.set("curStep", 0);
		interp.variables.set("curBeat", 0);
		interp.variables.set("duoMode", duoMode);
		interp.variables.set("deathCounter", deathCounter);
		interp.variables.set("opponentPlayer", opponentPlayer);
		interp.variables.set("demoMode", demoMode);
		interp.variables.set("disableScoreChange", function(funny:Bool) {disableScoreChange = funny;});
		interp.variables.set("camHUD", camHUD);
		interp.variables.set("downscroll", downscroll);
		interp.variables.set("playerStrums", playerStrums);
		interp.variables.set("enemyStrums", enemyStrums);
		//interp.variables.set("changeNoteType", function(player, type, trans) { NO FOR THE MOMENT
		//	generateStaticArrows(player, type, trans);
		//});
		interp.variables.set("strumLineY", strumLine.y);
		interp.variables.set("hscriptPath", path);
		interp.variables.set("health", health);
		interp.variables.set("scoreTxt", scoreTxt);
		interp.variables.set("difficTxt", difficTxt);
		interp.variables.set('useSongBar', useSongBar);
		interp.variables.set("songPosBG", songPosBG);
		interp.variables.set("songPosBar", songPosBar);
		interp.variables.set("songName", songName);
		interp.variables.set("NewBar", function (daX:Float, daY:Float, width:Int, height:Int, min:Float, max:Float, barColor:Bool = true) {
			var daBar = new FlxBar(daX, daY, LEFT_TO_RIGHT, width, height, this, 'songPositionBar', min, max);
			if (barColor) {
				var leftSideFill = opponentPlayer ? dad.opponentColor : dad.enemyColor;
				if (duoMode)
					leftSideFill = dad.opponentColor;
				var rightSideFill = opponentPlayer ? boyfriend.bfColor : boyfriend.playerColor;
				if (duoMode)
					rightSideFill = boyfriend.bfColor;
				daBar.createFilledBar(leftSideFill, rightSideFill);
			} else
				daBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
			return daBar;
		});
		interp.variables.set("healthBar", healthBar);
		interp.variables.set("healthBarBG", healthBarBG);
		//interp.variables.set("currentTimingShown", currentTimingShown);
		interp.variables.set("iconP1", iconP1);
		interp.variables.set("iconP2", iconP2);

		//funny numbers (how do I make them read only????????)
		interp.variables.set("songScore", songScore);
		interp.variables.set("songScoreDef", songScoreDef);
		interp.variables.set("nps", nps);
		interp.variables.set("accuracy", accuracy);
		interp.variables.set("combo", combo);

		interp.variables.set("start", function (song) {});
		interp.variables.set("update", function (elapsed) {});
		interp.variables.set("beatHit", function (beat) {});
		interp.variables.set("stepHit", function(step) {});
		interp.variables.set("playerTwoTurn", function () {});
		interp.variables.set("playerTwoMiss", function () {});
		interp.variables.set("playerTwoSing", function () {});
		interp.variables.set("playerOneTurn", function() {});
		interp.variables.set("playerOneMiss", function() {});
		interp.variables.set("playerOneSing", function() {});
		//interp.variables.set("noteHit", function(player1:Bool, note:Note, wasGoodHit:Bool) {}); //this works finally!! :D
		interp.variables.set("addSprite", function (sprite) {add(sprite);});
		interp.variables.set("removeSprite", function(sprite) {remove(sprite);});
		interp.variables.set("replaceSprite", function(sprite, replaced) {replace(sprite, replaced);});
		interp.variables.set("PlayState", PlayState);
		interp.variables.set("HelperFunctions", HelperFunctions);
		interp.variables.set("instancePluginClass", instanceExClass);
		try{
		trace("set stuff");
		interp.execute(program);
		hscriptStates.set(usehaxe,interp);
		callHscript("start", [SONG.song], usehaxe);
		trace('executed');
		}
		catch (e) {
			openfl.Lib.application.window.alert(e.message, "YOUR SCRIPT CRASHED!");
		}
	}
	
	function blendModeFromString(blend:String):BlendMode {
		switch(blend.toLowerCase().trim()) {
			case 'add': return ADD;
			case 'alpha': return ALPHA;
			case 'darken': return DARKEN;
			case 'difference': return DIFFERENCE;
			case 'erase': return ERASE;
			case 'hardlight': return HARDLIGHT;
			case 'invert': return INVERT;
			case 'layer': return LAYER;
			case 'lighten': return LIGHTEN;
			case 'multiply': return MULTIPLY;
			case 'overlay': return OVERLAY;
			case 'screen': return SCREEN;
			case 'shader': return SHADER;
			case 'subtract': return SUBTRACT;
		}
		return NORMAL;
	}

	public static function addCustomShaderToSprite(spriteSh:FlxSprite, shaderName:String):FlxSprite
	{
		spriteSh.shader = new ShaderCustom(shaderName);
		//startCustomShader(shaderName);

		return spriteSh;
	}

	public static function startCustomShader(shaderName:String):Null<ShaderHandler>
	{
		var fragText:String = '';
		var vertText:String = '';

		if (FNFAssets.exists(SUtil.getPath() + 'assets/shaders/' + shaderName + '.frag'))
			fragText = FNFAssets.getText(SUtil.getPath() + 'assets/shaders/' + shaderName + '.frag');

		if (FNFAssets.exists(SUtil.getPath() + 'assets/shaders/' + shaderName + '.vert'))
			vertText = FNFAssets.getText(SUtil.getPath() + 'assets/shaders/' + shaderName + '.vert');

		if (fragText == '' && vertText == '')
			return null; //If not nothing text, ignore this

		return new ShaderHandler(fragText, vertText); //Return the Shader ID sucessly.
	}

	public function addShaderToCam(cam:String,effect:ShaderEffect)
	{ //STOLE FROM ANDROMEDA AND PSYCH ENGINE 0.5.1 WITH SHADERS

		switch(cam.toLowerCase()) 
		{
			case 'camhud' | 'hud':
					camHUDShaders.push(effect);
					var newCamEffects:Array<BitmapFilter>=[]; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
					for(i in camHUDShaders){
					  newCamEffects.push(new ShaderFilter(i.shader));
					}
					camHUD.setFilters(newCamEffects);
			default:
					camGameShaders.push(effect);
					var newCamEffects:Array<BitmapFilter>=[]; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
					for(i in camGameShaders){
					  newCamEffects.push(new ShaderFilter(i.shader));
					}
					camGame.setFilters(newCamEffects);
		}
	}

	public function addCustomShaderToCam(cam:String,shname:String)
	{ //STOLE FROM ANDROMEDA AND PSYCH ENGINE 0.5.1 WITH SHADERS

		var cshader:ShaderCustom = new ShaderCustom(shname);

		switch(cam.toLowerCase()) 
		{
			case 'camhud' | 'hud':
					var newCamEffects:Array<BitmapFilter>=[new ShaderFilter(cshader)]; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
					camHUD.setFilters(newCamEffects);
			default:
					var newCamEffects:Array<BitmapFilter>=[new ShaderFilter(cshader)]; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
					camGame.setFilters(newCamEffects);
		}
	}

	public function addSpriteShader(sprite:FlxSprite,effect:ShaderEffect)
	{
		sprite.shader = effect.shader;
	}

	public function removeShaderFromCamera(cam:String,effect:ShaderEffect)
	{
		switch(cam.toLowerCase()) 
		{
			case 'camhud' | 'hud': 
				camHUDShaders.remove(effect);
				var newCamEffects:Array<BitmapFilter>=[];
				for(i in camHUDShaders)
				{
					newCamEffects.push(new ShaderFilter(i.shader));
				}
				camHUD.setFilters(newCamEffects);
			default: 
				camGameShaders.remove(effect);
				var newCamEffects:Array<BitmapFilter>=[];
				for(i in camGameShaders){
				  newCamEffects.push(new ShaderFilter(i.shader));
				}
				camGame.setFilters(newCamEffects);
		}
	}

	public function clearShaderFromCamera(cam:String)
	{
		switch(cam.toLowerCase()) {
			case 'camhud' | 'hud': 
				camHUDShaders = [];
				var newCamEffects:Array<BitmapFilter>=[];
				camHUD.setFilters(newCamEffects);
			default: 
				camGameShaders = [];
				var newCamEffects:Array<BitmapFilter>=[];
				camGame.setFilters(newCamEffects);
		}
	}

	//SHADERS STUFF

	public function addPulseEffect(dest:String, sprite:Null<FlxSprite> = null, waveSpeed:Float = 0.1, waveFrq:Float = 0.1, waveAmp:Float = 0.1)
	{
		switch (dest.toLowerCase())
		{
			case 'camhud', 'hud', 'camgame', 'game':
				addShaderToCam(dest, new PulseEffect(waveSpeed,waveFrq,waveAmp));
			default:
				if (sprite != null)
					sprite.shader = (new PulseEffect(waveSpeed,waveFrq,waveAmp)).shader;
		}
	}

	public function addDistortionEffect(dest:String, sprite:Null<FlxSprite> = null, waveSpeed:Float = 0.1, waveFrq:Float = 0.1, waveAmp:Float = 0.1)
	{
		switch (dest.toLowerCase())
		{
			case 'camhud', 'hud', 'camgame', 'game':
				addShaderToCam(dest, new DistortBGEffect(waveSpeed,waveFrq,waveAmp));
			default:
				if (sprite != null)
					sprite.shader = (new DistortBGEffect(waveSpeed,waveFrq,waveAmp)).shader;
		}
	}

	public function addInvertEffect(dest:String, sprite:Null<FlxSprite> = null, lockAlpha:Bool = false)
	{
		switch (dest.toLowerCase())
		{
			case 'camhud', 'hud', 'camgame', 'game':
				addShaderToCam(dest, new InvertColorsEffect(lockAlpha));
			default:
				if (sprite != null)
					sprite.shader = (new InvertColorsEffect(lockAlpha)).shader;
		}
	}

	public function addGrayScaleEffect(dest:String, sprite:Null<FlxSprite> = null)
	{
		switch (dest.toLowerCase())
		{
			case 'camhud', 'hud', 'camgame', 'game':
				addShaderToCam(dest, new GreyscaleEffect());
			default:
				if (sprite != null)
					sprite.shader = (new GreyscaleEffect()).shader;
		}
	}

	public function addScanLineEffect(dest:String, sprite:Null<FlxSprite> = null, lockAlpha:Bool = false)
	{
		switch (dest.toLowerCase())
		{
			case 'camhud', 'hud', 'camgame', 'game':
				addShaderToCam(dest, new ScanlineEffect(lockAlpha));
			default:
				if (sprite != null)
					sprite.shader = (new ScanlineEffect(lockAlpha)).shader;
		}
	}

	public function addChromaticAberrationEffect(dest:String, sprite:Null<FlxSprite> = null, offset:Float = 0.03)
	{
		switch (dest.toLowerCase())
		{
			case 'camhud', 'hud', 'camgame', 'game':
				addShaderToCam(dest, new ChromaticAberrationEffect(offset));
			default:
				if (sprite != null)
					sprite.shader = (new ChromaticAberrationEffect(offset)).shader;
		}
	}

	function change_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / daScrollSpeed; //funny word huh
			for (note in notes)
			{
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					note.scale.y *= ratio;
					note.updateHitbox();
				}
			}
			for (note in unspawnNotes)
			{
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					note.scale.y *= ratio;
					note.updateHitbox();
				}
			}
		}
		daScrollSpeed = value;
		//noteKillOffset = 350 / songSpeed;
		return value;
	}
	function instanceExClass(classname:String, args:Array<Dynamic> = null) {
		return exInterp.createScriptClassInstance(classname, args);
	}
	function makeHaxeExState(usehaxe:String, path:String, filename:String)
	{
		trace("opening a haxe state (because we are cool :))");
		var parser = new ParserEx();
		var program = parser.parseModule(FNFAssets.getHscript(path + filename));
		trace("set stuff");
		exInterp.registerModule(program);

		trace('executed');
	}
	#end
	var useCustomInput:Bool = false;
	var showMisses:Bool = false;
	var nightcoreMode:Bool = false;
	var daycoreMode:Bool = false;
	var useSongBar:Bool = true;
	var songName:FlxText;
	var uiSmelly:TUI;
	override public function create()
	{
		FNFAssets.clearStoredMemory();
		
		#if desktop
		// pre lowercasing the song name (create)
        var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
        switch (songLowercase) {
            case 'dad-battle': songLowercase = 'dadbattle';
            case 'philly-nice': songLowercase = 'philly';
        }
		#end
		Note.getFrames = true;
		NoteSplash.getFrames = true;
		Note.getSpecialFrames = true;
		Note.specialNoteJson = null;
		instance = this;

		if (FNFAssets.exists(SUtil.getPath() + 'assets/images/custom_notetypes/noteInfo.json')) {
			Note.specialNoteJson = CoolUtil.parseJson(FNFAssets.getText(SUtil.getPath() + 'assets/images/custom_notetypes/noteInfo.json'));
		}
		else if (FNFAssets.exists(SUtil.getPath() + 'assets/data/${SONG.song.toLowerCase()}/noteInfo.json')) {  //Oudated function
			Note.specialNoteJson = CoolUtil.parseJson(FNFAssets.getText(SUtil.getPath() + 'assets/data/${SONG.song.toLowerCase()}/noteInfo.json'));
		}
		Judgement.uiJson = CoolUtil.parseJson(FNFAssets.getText(SUtil.getPath() + 'assets/images/custom_ui/ui_packs/ui.json'));
		uiSmelly = Reflect.field(Judgement.uiJson, SONG.uiType);

		misses = 0;
		bads = 0;
		goods = 0;
		sicks = 0;
		shits = 0;
		ss = true;
		// use current note amount
		Note.NOTE_AMOUNT = SONG.preferredNoteAmount;
		judgementList = CoolUtil.coolTextFile(SUtil.getPath() + 'assets/data/judgements.txt');
		preferredJudgement = judgementList[OptionsHandler.options.preferJudgement];
		if (preferredJudgement == 'none' || SONG.forceJudgements) {
			preferredJudgement = SONG.uiType;
			// if it is not using its own folder make preferred judgement
			if (Reflect.hasField(Judgement.uiJson, preferredJudgement) && Reflect.field(Judgement.uiJson, preferredJudgement).uses != preferredJudgement)
				preferredJudgement = Reflect.field(Judgement.uiJson, preferredJudgement).uses;
		}
		#if desktop
		// Making difficulty text for Discord Rich Presence.
		// I JUST REALIZED THIS IS NOT VERY COMPATIBILE
		/*
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
		}
		*/
		storyDifficultyText = DifficultyManager.getDiffName(storyDifficulty);
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
		DiscordClient.changePresence(customPrecence
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end
		
		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];
		persistentUpdate = true;
		persistentDraw = true;
		alwaysDoCutscenes = OptionsHandler.options.alwaysDoCutscenes;
		useCustomInput = OptionsHandler.options.useCustomInput;
		useVictoryScreen = !OptionsHandler.options.skipVictoryScreen;
		downscroll = OptionsHandler.options.downscroll;
		useSongBar = OptionsHandler.options.showSongPos;
		Judge.setJudge(cast OptionsHandler.options.judge);
		pixelUI = uiSmelly.isPixel;
		if (!OptionsHandler.options.skipModifierMenu) {
			fullComboMode = ModifierState.namedModifiers.fc.value;
			goodCombo = ModifierState.namedModifiers.gfc.value;
			perfectMode = ModifierState.namedModifiers.mfc.value;
			practiceMode = ModifierState.namedModifiers.practice.value;
			flippedNotes = ModifierState.namedModifiers.flipped.value;
			accelNotes = ModifierState.namedModifiers.accel.value;
			vnshNotes = ModifierState.namedModifiers.vanish.value;
			invsNotes = ModifierState.namedModifiers.invis.value;
			snakeNotes = ModifierState.namedModifiers.snake.value;
			drunkNotes = ModifierState.namedModifiers.drunk.value;
			// nightcoreMode = ModifierState.modifiers[18].value;
			// daycoreMode = ModifierState.modifiers[19].value;
			inALoop = ModifierState.namedModifiers.loop.value;
			duoMode = ModifierState.namedModifiers.duo.value;
			opponentPlayer = ModifierState.namedModifiers.oppnt.value;
			demoMode = ModifierState.namedModifiers.demo.value;
			if (ModifierState.namedModifiers.healthloss.value)
				healthLossMultiplier = ModifierState.namedModifiers.healthloss.amount;
			if (ModifierState.namedModifiers.healthgain.value)
				healthGainMultiplier = ModifierState.namedModifiers.healthgain.amount;
			if (ModifierState.namedModifiers.slow.value)
				noteSpeed = 0.3;
			if (accelNotes) {
				noteSpeed = 0.45;
				trace("accel arrows");
			}
			if (daycoreMode) {
				noteSpeed = 0.5;
			}


			if (ModifierState.namedModifiers.fast.value)
				noteSpeed = 0.9;
			if (ModifierState.namedModifiers.regen.value) {
				loveMultiplier = ModifierState.namedModifiers.regen.amount;
				supLove = true;
			}
			if (ModifierState.namedModifiers.degen.value) {
				poisonMultiplier = ModifierState.namedModifiers.degen.amount;
				poisonExr = true;
			}
			poisonPlus = ModifierState.namedModifiers.poison.value;
		} else {
			ModifierState.scoreMultiplier = 1;
		}
		player1GoodHitSignal = new Signal<Note>();
		player2GoodHitSignal = new Signal<Note>();
		// rebind always, to support djkf
		
		if (!opponentPlayer && !duoMode) {
			controls.setKeyboardScheme(Solo(false));
		}
		if (opponentPlayer) {
			controlsPlayerTwo.setKeyboardScheme(Solo(false));
		} else {
			controlsPlayerTwo.setKeyboardScheme(Duo(false));
		}
		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');
		
		if (OptionsHandler.options.showSplashes)
		{
			grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
			var sploosh = new NoteSplash(100, 100, 0);
			sploosh.alpha = 0.01;
			grpNoteSplashes.add(sploosh);
		}

		boyfriendGroup = new FlxTypedGroup<Character>();
		dadGroup = new FlxTypedGroup<Character>();
		gfGroup = new FlxTypedGroup<Character>();
		grpCrossfades = new FlxTypedGroup<FlxSprite>();

		mania = SONG.mania;

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);
		var dialogSuffix = "";
		if (OptionsHandler.options.stressTankmen) {
			dialogSuffix = "-shit";
		}
		// if this is skipped when love is on, that means love is less than or equal to fright so
		else if (supLove && poisonMultiplier < loveMultiplier) {
			dialogSuffix = "-love";
		} else if (poisonExr && poisonMultiplier < 50) {
			dialogSuffix = "-uneasy";
		} else if (poisonExr && poisonMultiplier >= 50 && poisonMultiplier < 100) {
			dialogSuffix = "-scared";
		} else if (poisonExr && poisonMultiplier >= 100 && poisonMultiplier < 200) {
			dialogSuffix = "-terrified";
		} else if (poisonExr && poisonMultiplier >= 200) {
			dialogSuffix = "-depressed";
		} else if (practiceMode) {
			dialogSuffix = "-practice";
		} else if (perfectMode || fullComboMode || goodCombo) {
			dialogSuffix = "-perfect";
		}
		var filename:Null<String> = null;
		if (FNFAssets.exists(SUtil.getPath() + 'assets/images/custom_chars/' + SONG.player1 + '/' + SONG.song.toLowerCase() + 'Dialog.txt'))
		{	
			filename = SUtil.getPath() + 'assets/images/custom_chars/' + SONG.player1 + '/' + SONG.song.toLowerCase() + 'Dialog.txt';
			if (FNFAssets.exists(SUtil.getPath() + 'assets/images/custom_chars/' + SONG.player1 + '/' + SONG.song.toLowerCase() + 'Dialog'+dialogSuffix+'.txt'))
				filename = SUtil.getPath() + 'assets/images/custom_chars/' + SONG.player1 + '/' + SONG.song.toLowerCase() + 'Dialog' + dialogSuffix + '.txt';
		}
		else if (FNFAssets.exists(SUtil.getPath() + 'assets/images/custom_chars/' + SONG.player2 + '/' + SONG.song.toLowerCase() + 'Dialog.txt'))
		{
			filename = SUtil.getPath() + 'assets/images/custom_chars/' + SONG.player2 + '/' + SONG.song.toLowerCase() + 'Dialog.txt';
			if (FNFAssets.exists(SUtil.getPath() + 'assets/images/custom_chars/' + SONG.player2 + '/' + SONG.song.toLowerCase() + 'Dialog${dialogSuffix}.txt')) {
				filename = SUtil.getPath() + 'assets/images/custom_chars/' + SONG.player2 + '/' + SONG.song.toLowerCase() + 'Dialog${dialogSuffix}.txt';
			}
			// if no player dialog, use default
		}
		else if (FNFAssets.exists(SUtil.getPath() + 'assets/data/' + SONG.song.toLowerCase() + '/dialog.txt'))
		{
			filename = SUtil.getPath() + 'assets/data/' + SONG.song.toLowerCase() + '/dialog.txt';
			if (FNFAssets.exists(SUtil.getPath() + 'assets/data/' + SONG.song.toLowerCase() + '/dialog${dialogSuffix}.txt'))
			{
				filename = SUtil.getPath() + 'assets/data/' + SONG.song.toLowerCase() + '/dialog${dialogSuffix}.txt';
			}
		}
		else if (FNFAssets.exists(SUtil.getPath() + 'assets/data/' + SONG.song.toLowerCase() + '/dialogue.txt'))
		{
			filename = SUtil.getPath() + 'assets/data/' + SONG.song.toLowerCase() + '/dialogue.txt';
			if (FNFAssets.exists(SUtil.getPath() + 'assets/data/' + SONG.song.toLowerCase() + '/dialogue${dialogSuffix}.txt'))
			{
				filename = SUtil.getPath() + 'assets/data/' + SONG.song.toLowerCase() + '/dialogue${dialogSuffix}.txt';
			}
		}
		var goodDialog:String;
		if (filename != null) {
			goodDialog = FNFAssets.getText(filename);
		} else {
			goodDialog = ':dad: The game tried to get a dialog file but couldn\'t find it. Please make sure there is a dialog file named "dialog.txt".';
		}

		daScrollSpeed = SONG.speed;
		
		var gfVersion:String = 'gf';

		gfVersion = SONG.gf;
		trace(SONG.gf);

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);
		gfGroup.add(gf);
		gfMap.set(gfVersion, gf);

		/*#if desktop
		if (FileSystem.exists(Paths.txt(songLowercase  + "/preload")))
			{
				var characters:Array<String> = CoolUtil.coolTextFile(Paths.txt(songLowercase  + "/preload"));
	
				for (i in 0...characters.length)
				{
					var data:Array<String> = characters[i].split(' ');
					dad = new Character (0, 0, data[0]);
				}
			}
		if (FileSystem.exists(Paths.txt(songLowercase  + "/preload")))
				{
					var characters:Array<String> = CoolUtil.coolTextFile(Paths.txt(songLowercase  + "/preload"));
		
					for (i in 0...characters.length)
					{
						var data:Array<String> = characters[i].split(' ');
						boyfriend = new Character (0, 0, data[0]);
					}
				}
		#end*/
		dad = new Character(100, 100, SONG.player2);

		dadGroup.add(dad);
		dadMap.set(SONG.player2, dad);

		if (duoMode || opponentPlayer)
			dad.beingControlled = true;
		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			default:
				dad.x += dad.enemyOffsetX;
				dad.y += dad.enemyOffsetY;
				camPos.x += dad.camOffsetX;
				camPos.y += dad.camOffsetY;
				if (dad.likeGf) {
					dad.setPosition(gf.x, gf.y);
					gf.visible = false;
					if (isStoryMode)
					{
						camPos.x += 600;
						tweenCamIn();
					}
				}
		}



		boyfriend = new Character(770, 450, SONG.player1, true);
		boyfriendGroup.add(boyfriend);
		boyfriendMap.set(SONG.player1, boyfriend);
		if (!opponentPlayer && !demoMode)
			boyfriend.beingControlled = true;
		trace("newBF");
		switch (SONG.player1) // no clue why i didnt think of this before lol
		{
			default:
				//boyfriend.x += boyfriend.bfOffsetX; //just use sprite offsets
				//boyfriend.y += boyfriend.bfOffsetY;
				camPos.x += boyfriend.camOffsetX;
				camPos.y += boyfriend.camOffsetY;
				boyfriend.x += boyfriend.playerOffsetX;
				boyfriend.y += boyfriend.playerOffsetY;
				if (boyfriend.likeGf) {
					boyfriend.setPosition(gf.x, gf.y);
					gf.visible = false;
					if (isStoryMode)
					{
						camPos.x += 600;
						tweenCamIn();
					}
				}
		}

		// REPOSITIONING PER STAGE
		boyfriend.x += bfoffset[0];
		boyfriend.y += bfoffset[1];
		gf.x += gfoffset[0];
		gf.y += gfoffset[1];
		dad.x += dadoffset[0];
		dad.y += dadoffset[1];
		trace('befpre spoop check');
		if (SONG.isSpooky) {
			trace("WOAH SPOOPY");
			var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
			evilTrail.framesEnabled = false;
			// evilTrail.changeValuesEnabled(false, false, false, false);
			// evilTrail.changeGraphic()
			trace(evilTrail);
			add(evilTrail);
		}
		add(gfGroup);
		// Shitty layering but whatev it works 
		add(grpCrossfades);
		trace('dad');
		add(dadGroup);
		trace('dy UWU');
		add(boyfriendGroup);
		trace('bf cheeks');

		doof = new DialogueBox(false, goodDialog);
		trace('doofensmiz');
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		Conductor.songPosition = -5000;
		trace('prepare your strumlime');
		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		if (downscroll) {
			strumLine.y = FlxG.height - 165;
		}
		playerComboBreak = new FlxTypedGroup<FlxSprite>();
		enemyComboBreak = new FlxTypedGroup<FlxSprite>();
		playerComboBreak.cameras = [camHUD];
		enemyComboBreak.cameras = [camHUD];
		add(playerComboBreak);
		add(enemyComboBreak);
		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);

		if (OptionsHandler.options.showSplashes)
		{
			add(grpNoteSplashes);
		}

		playerStrums = new FlxTypedGroup<StrumNote>();
		enemyStrums = new FlxTypedGroup<StrumNote>();
		
		// startCountdown();
		trace('before generate');
		generateSong(SONG.song);

		//Notetypes (the reason it is a single file is to further optimize space and ram memory.)
		if (FNFAssets.exists(SUtil.getPath() + "assets/images/custom_notetypes/notetypes", Hscript))
		{
			makeHaxeState("notetypes", SUtil.getPath() + "assets/images/custom_notetypes/", "notetypes");
		}

		//Events (the same reason of the notetypes)
		if (FNFAssets.exists(SUtil.getPath() + "assets/images/custom_events/events", Hscript))
		{
			makeHaxeState("events", SUtil.getPath() + "assets/images/custom_events/", "events");
		}

		// add(strumLine);
		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, camSpeed);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		trace('gay');
		if (useSongBar) {
			// todo, add options
			var lmao = FNFAssets.getBitmapData(SUtil.getPath() + 'assets/images/healthBar.png');
		if (FNFAssets.exists(SUtil.getPath() + 'assets/images/custom_ui/ui_packs/' + uiSmelly.uses + 'timeBar.png'))
			lmao = FNFAssets.getBitmapData(SUtil.getPath() + 'assets/images/custom_ui/ui_packs/' + uiSmelly.uses + 'timeBar.png');
		else if (FNFAssets.exists(SUtil.getPath() + 'assets/images/timeBar.png'))
			lmao = FNFAssets.getBitmapData(SUtil.getPath() + 'assets/images/timeBar.png');
        else
			lmao = FNFAssets.getBitmapData(SUtil.getPath() + 'assets/images/healthBar.png');
			songPosBG = new FlxSprite(0, 10).loadGraphic(lmao);
			if (downscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);
			songPosBG.cameras = [camHUD];

			songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, 1);
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);
			songPosBar.cameras = [camHUD];

			songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - 20, songPosBG.y, 0, SONG.song, 16);
			if (downscroll)
				songName.y -= 3;
			songName.setFormat(SUtil.getPath() + "assets/fonts/vcr.ttf", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);
			songName.cameras = [camHUD];
		}
		var lmao = FNFAssets.getBitmapData(SUtil.getPath() + 'assets/images/healthBar.png');
		if (FNFAssets.exists(SUtil.getPath() + 'assets/images/custom_ui/ui_packs/' + uiSmelly.uses + 'healthBar.png'))
			lmao = FNFAssets.getBitmapData(SUtil.getPath() + 'assets/images/custom_ui/ui_packs/' + uiSmelly.uses + 'healthBar.png');
		else
			lmao = FNFAssets.getBitmapData(SUtil.getPath() + 'assets/images/healthBar.png');
		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(lmao);
		if (downscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);
 
		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		var leftSideFill = opponentPlayer ? dad.opponentColor : dad.enemyColor;
		if (duoMode)
			leftSideFill = dad.opponentColor;
		var rightSideFill = opponentPlayer ? boyfriend.bfColor : boyfriend.playerColor;
		if (duoMode)
			rightSideFill = boyfriend.bfColor;
		healthBar.createFilledBar(leftSideFill, rightSideFill);
		// healthBar
		add(healthBar);

		scoreTxt = new FlxText(healthBarBG.x, healthBarBG.y + 40, 0, "", 200);
		scoreTxt.setFormat(SUtil.getPath() + "assets/fonts/vcr.ttf", 20, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();

		healthTxt = new FlxText(healthBarBG.x + healthBarBG.width - 300, scoreTxt.y, 0, "", 200);
		healthTxt.setFormat(SUtil.getPath() + "assets/fonts/vcr.ttf", 20, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		healthTxt.scrollFactor.set();
		healthTxt.visible = false;
		accuracyTxt = new FlxText(healthBarBG.x, scoreTxt.y, 0, "", 200);
		accuracyTxt.setFormat(SUtil.getPath() + "assets/fonts/vcr.ttf", 20, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		accuracyTxt.scrollFactor.set();
		// shitty work around but okay
		accuracyTxt.visible = false;
		difficTxt = new FlxText(10, FlxG.height, 0, "", 150);
		
		difficTxt.setFormat(SUtil.getPath() + "assets/fonts/vcr.ttf", 15, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		difficTxt.scrollFactor.set();
		difficTxt.y -= difficTxt.height;
		if (downscroll) {
			difficTxt.y = 0;
		}
		// screwy way of getting text
		difficTxt.text = DifficultyIcons.changeDifficultyFreeplay(storyDifficulty, 0).text + ' - M+ ${MainMenuState.version}';
		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);
		practiceDieIcon = new HealthIcon('bf-old', false);
		practiceDieIcon.y = healthBar.y - (practiceDieIcon.height / 2);
		practiceDieIcon.x = healthBar.x - 130;
		practiceDieIcon.animation.curAnim.curFrame = 1;
		add(practiceDieIcon);

		if (OptionsHandler.options.showSplashes)
		{
			grpNoteSplashes.cameras = [camHUD];
		}

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		practiceDieIcon.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		healthTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		accuracyTxt.cameras = [camHUD];
		difficTxt.cameras = [camHUD];
		practiceDieIcon.visible = false;

		add(scoreTxt);
		add(difficTxt);

		startingSong = true;
		trace('finish uo');
		
		#if mobile
		addAndroidControls();
		#end
		
		var stageJson = CoolUtil.parseJson(FNFAssets.getText(SUtil.getPath() + "assets/images/custom_stages/custom_stages.json"));
		makeHaxeState("stages", SUtil.getPath() + "assets/images/custom_stages/" + SONG.stage + "/", "../"+Reflect.field(stageJson, SONG.stage));
		trace('stage done');
		var modchartPushed:Array<String> = [];
		if(FileSystem.exists(SUtil.getPath() + "assets/data/" + SONG.song.toLowerCase() + "/"))
			{
				for (file in FileSystem.readDirectory(SUtil.getPath() + "assets/data/" + SONG.song.toLowerCase() + "/"))
				{
		if (file.endsWith('.hscript') && !modchartPushed.contains(file))
		{
			hscriptIsModChart.set(file.substr(0, file.length - 8),true);
			makeHaxeState(file.substr(0, file.length - 8), SUtil.getPath() + "assets/data/" + SONG.song.toLowerCase() + "/", file.substr(0, file.length - 8));	
		}
	}
	}
		
		var uiJson = CoolUtil.parseJson(FNFAssets.getText(SUtil.getPath() + "assets/images/custom_ui/ui_layouts/ui.json"));
		makeHaxeStateUI("ui", SUtil.getPath() + "assets/images/custom_ui/ui_layouts/" + Reflect.field(uiJson, 'layout') + "/", "../" + Reflect.field(uiJson, 'layout') + ".hscript");
		trace('ui done');

		var scriptPushed:Array<String> = [];
		if(FileSystem.exists(SUtil.getPath() + "assets/scripts/"))
			{
				for (file in FileSystem.readDirectory(SUtil.getPath() + "assets/scripts/"))
				{
		if (file.endsWith('.hscript') && !scriptPushed.contains(file))
		{
			makeHaxeState(file.substr(0, file.length - 8), SUtil.getPath() + "assets/scripts/", file.substr(0, file.length - 8));	
		}
	}
	}
		if ((alwaysDoCutscenes || isStoryMode )&& (!seenCutscene || chartingMode))
		{

			switch (SONG.cutsceneType)
			{
				/*
				case "monster":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(SUtil.getPath() + 'assets/sounds/Lights_Turn_On' + TitleState.soundExt);
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
				*/
				case 'senpai':
					schoolIntro(doof);
				case 'angry-senpai':
					
					schoolIntro(doof);
				case 'none':
					startCountdown();
				default:
					// schoolIntro(doof);
					customIntro(doof);
			}
			seenCutscene = true;
		}
		else
		{

			startCountdown();
		}

		var useSong = SUtil.getPath() + "assets/music/" + SONG.song + "_Inst" + TitleState.soundExt;
		if (FNFAssets.exists(SUtil.getPath() + "assets/music/" + SONG.song + "_" + SONG.player1 + "_Inst" + TitleState.soundExt))
			useSong = SUtil.getPath() + "assets/music/" + SONG.song + "_" + SONG.player1 + "_Inst" + TitleState.soundExt;
		if (OptionsHandler.options.stressTankmen && FNFAssets.exists(SUtil.getPath() + "assets/music/" + SONG.song + "/Shit_Inst.ogg"))
			useSong = SUtil.getPath() + "assets/music/" + SONG.song + "/Shit_Inst.ogg";

		FNFAssets.precacheSound(useSong);

		callAllHScript('endStart', [SONG.song]);

		super.create();
	}

	public function preloadCharsFromFile(file:String, type:Int)
	{

		if (type < 0)
			type = 0;

		if (type > 2)
			type = 2;

		if (FNFAssets.exists(SUtil.getPath() + 'assets/data/' + SONG.song.toLowerCase() + '/' + file + '.txt'))
		{
			var cFile = FNFAssets.getText(SUtil.getPath() + 'assets/data/' + SONG.song.toLowerCase() + '/' + file + '.txt');

			var fileSplit = cFile.split('\n');

			for (i in 0...fileSplit.length)
			{
				addCharacterToList(fileSplit[i], type);
			}
		}
	}

	public function addCharacterToList(newCharacter:String, type:Int) {

		var cPosX:Float;
		var cPosY:Float;

		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					cPosX = boyfriend.x - boyfriend.playerOffsetX;
					cPosY = boyfriend.y - boyfriend.playerOffsetY;
					var newBoyfriend:Character = new Character(cPosX, cPosY, newCharacter, true);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					newBoyfriend.alpha = 0.0001;
					newBoyfriend.active = false;
					newBoyfriend.x += newBoyfriend.playerOffsetX;
					newBoyfriend.y += newBoyfriend.playerOffsetY;

					if (!opponentPlayer && !demoMode)
						newBoyfriend.beingControlled = true;
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					cPosX = dad.x - dad.enemyOffsetX;
					cPosY = dad.y - dad.enemyOffsetY;
					var newDad:Character = new Character(cPosX, cPosY, newCharacter, false);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					newDad.alpha = 0.0001;
					newDad.active = false;
					newDad.x += newDad.enemyOffsetX;
					newDad.y += newDad.enemyOffsetY;

					if (duoMode || opponentPlayer)
						newDad.beingControlled = true;
				}

			case 2:
				if(!gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(gf.x, gf.y, newCharacter, false);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					newGf.alpha = 0.0001;
					newGf.active = false;
				}
		}
	}

	public function changeCharacter(charName:String, charType:Int, ?delBef:Bool = false)
	{
		if (charType < 0)
			charType = 0;

		if (charType > 2)
			charType = 2;
		
		switch(charType) {
			case 0:
				if(boyfriend.curCharacter != charName) {
					if(!boyfriendMap.exists(charName)) {
						addCharacterToList(charName, charType);
					}

					var lastAlpha:Float = boyfriend.alpha;
					boyfriend.alpha = 0;
					boyfriend = boyfriendMap.get(charName);
					boyfriend.alpha = lastAlpha;
					boyfriend.active = true;
					iconP1.switchAnim(boyfriend.curCharacter);
				}
				setAllHaxeVar('boyfriend', boyfriend);
			case 1:
				if(dad.curCharacter != charName) {
					if(!dadMap.exists(charName)) {
						addCharacterToList(charName, charType);
					}

					var lastAlpha:Float = dad.alpha;
					dad.alpha = 0;
					dad = dadMap.get(charName);
					if(dad.likeGf) {
						gf.visible = false;
					}
					dad.alpha = lastAlpha;
					dad.active = true;
					iconP2.switchAnim(dad.curCharacter);
				}
				setAllHaxeVar('dad', dad);

			case 2:
				if(gf.curCharacter != charName) {
					if(!gfMap.exists(charName)) {
						addCharacterToList(charName, charType);
					}

					var lastAlpha:Float = gf.alpha;
					gf.alpha = 0;
					gf = gfMap.get(charName);
					gf.alpha = lastAlpha;
					gf.active = true;
				}
				setAllHaxeVar('gf', gf);
		}
		reloadHealthBarColors();
	}

	public function removeCharacterFromList(charName:String, charType:Int)
	{
		if (charType < 0)
			charType = 0;

		if (charType > 2)
			charType = 2;

		var chId:Character;

		switch (charType)
		{
			case 0:
				if(boyfriendMap.exists(charName)) {
					chId = boyfriendMap.get(charName);
					boyfriendMap.remove(charName);
					chId.destroy();
				}
			case 1:
				if(dadMap.exists(charName)) {
					chId = dadMap.get(charName);
					dadMap.remove(charName);
					chId.destroy();
				}
			case 2:
				if(gfMap.exists(charName)) {
					chId = gfMap.get(charName);
					gfMap.remove(charName);
					chId.destroy();
				}
		}
	}

	public function reloadHealthBarColors()
	{
		var leftSideFill = opponentPlayer ? dad.opponentColor : dad.enemyColor;
		if (duoMode)
			leftSideFill = dad.opponentColor;
		var rightSideFill = opponentPlayer ? boyfriend.bfColor : boyfriend.playerColor;
		if (duoMode)
			rightSideFill = boyfriend.bfColor;
		healthBar.createFilledBar(leftSideFill, rightSideFill);
	}

	public function setGlobalSprite(key:String, sprite:FlxSprite):Void
	{
		spriteZone.set(key, sprite);
	}

	public function getGlobalSprite(key:String):Null<FlxSprite>
	{
		if (spriteZone.exists(key))
			return (spriteZone.get(key));
		else
			return null;
	}

	public function removeGlobalSprite(key:String, ?destroy:Bool = false):Void
	{
		var spId:FlxSprite;
		
		if (spriteZone.exists(key))
		{
			spId = spriteZone.get(key);
			spriteZone.remove(key);

			if (destroy)
				spId.destroy();
		}
	}

	function customIntro(?dialogueBox:DialogueBox) {
		var goodJson = CoolUtil.parseJson(FNFAssets.getText(SUtil.getPath() + 'assets/images/custom_cutscenes/cutscenes.json'));
		if (!Reflect.hasField(goodJson, SONG.cutsceneType)) {
			schoolIntro(dialogueBox);
			return;
		}
		inCutscene = true;
		makeHaxeState("cutscene", SUtil.getPath() + "assets/images/custom_cutscenes/"+SONG.cutsceneType+'/', "../"+Reflect.field(goodJson, SONG.cutsceneType));
	}
	function schoolIntro(?dialogueBox:DialogueBox, intro:Bool=true):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		inCutscene = true;

		if (SONG.cutsceneType == 'angry-senpai')
		{
			remove(black);
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
					add(dialogueBox);
				}
				else
					if (intro)
						startCountdown();
					else 
						endForReal();

				remove(black);
			}
		});
	}
	function videoIntro(filename:String, ?finishfunk:Void->Void = null) 
	{
		#if VIDEOS_ALLOWED
		var foundFile:Bool = false;

		if(FNFAssets.exists(filename)) {
			foundFile = true;
		}

		if(foundFile) {
			inCutscene = true;
			var bg = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
			bg.scrollFactor.set();
			bg.cameras = [camHUD];
			add(bg);

			var daVideo = new FlxVideo();
			daVideo.play(filename);


			daVideo.onEndReached.add(function()
				{
					daVideo.dispose();
					remove(bg);
					if (finishfunk == null)
						startCountdown();
					else
						finishfunk();
					return;
				}, true);

			return;
		}
		else
		{
			FlxG.log.warn('Couldnt find video file: ' + filename);
			if (finishfunk == null)
				startCountdown();
			else
				finishfunk();

			return;
		}

		//startAndEnd();
		#else
		FlxG.log.warn('Platform not supported!');
		startCountdown();
			return;
		#end
	}
	
	function startAndEnd()
		{
			if(endingSong)
				endSong();
			else
				startCountdown();
		}

	var startTimer:FlxTimer;
	var perfectModeOld:Bool = false;
	public static var startOnTime:Float = 0;
	public function startCountdown():Void
	{
		if(startedCountdown) {
			return;
		}
		inCutscene = false;
		if (skipCountdown || startOnTime > 0) skipArrowStartTween = true;
		#if mobile 
		androidc.visible = true;
		#end
		generateStaticArrows(0);
		generateStaticArrows(1);
		
		if (duoMode)
		{
			controls.setKeyboardScheme(Duo(true));
		}

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		if(startOnTime < 0) startOnTime = 0;

			if (startOnTime > 0) {
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 350);
				return;
			}
			else if (skipCountdown)
			{
				setSongTime(0);
				return;
			}

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			if (!duoMode || opponentPlayer)
				dad.dance();
			if (opponentPlayer)
				boyfriend.dance();
			gf.dance();


			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();

			for (field in Reflect.fields(Judgement.uiJson)) {
				if (Reflect.field(Judgement.uiJson, field).isPixel)
					introAssets.set(field, [
						'custom_ui/ui_packs/' + Reflect.field(Judgement.uiJson, field).uses + '/ready-pixel.png',
						'custom_ui/ui_packs/' + Reflect.field(Judgement.uiJson, field).uses + '/set-pixel.png',
						'custom_ui/ui_packs/' + Reflect.field(Judgement.uiJson, field).uses+'/date-pixel.png']);
				else
					introAssets.set(field, [
						'custom_ui/ui_packs/' + field + '/ready.png',
						'custom_ui/ui_packs/' + Reflect.field(Judgement.uiJson, field).uses + '/set.png',
						'custom_ui/ui_packs/' + Reflect.field(Judgement.uiJson, field).uses+'/go.png']);
			
			}

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";
			var intro3Sound:Sound;
			var intro2Sound:Sound;
			var intro1Sound:Sound;
			var introGoSound:Sound;
			for (value in introAssets.keys())
			{
				if (value == SONG.uiType)
				{
					introAlts = introAssets.get(value);
					// ok so apparently a leading slash means absolute soooooo
					if (pixelUI)
						altSuffix = '-pixel';
				}
			}

			// god is dead for we have killed him
			if (FNFAssets.exists(SUtil.getPath() + "assets/images/custom_ui/ui_packs/" + uiSmelly.uses + '/intro3' + altSuffix + '.ogg')) {
				intro3Sound = FNFAssets.getSound(SUtil.getPath() + "assets/images/custom_ui/ui_packs/" + uiSmelly.uses + '/intro3' + altSuffix + '.ogg');
				intro2Sound = FNFAssets.getSound(SUtil.getPath() + "assets/images/custom_ui/ui_packs/" + uiSmelly.uses + '/intro2' + altSuffix + '.ogg');
				intro1Sound = FNFAssets.getSound(SUtil.getPath() + "assets/images/custom_ui/ui_packs/" + uiSmelly.uses + '/intro1' + altSuffix + '.ogg');
				// apparently this crashes if we do it from audio buffer?
				// no it just understands 'hey that file doesn't exist better do an error'
				introGoSound = FNFAssets.getSound(SUtil.getPath() + "assets/images/custom_ui/ui_packs/" + uiSmelly.uses + '/introGo' + altSuffix + '.ogg');
			} else {
				intro3Sound = FNFAssets.getSound(SUtil.getPath() + 'assets/sounds/intro3.ogg');
				intro2Sound = FNFAssets.getSound(SUtil.getPath() + 'assets/sounds/intro2.ogg');
				intro1Sound = FNFAssets.getSound(SUtil.getPath() + 'assets/sounds/intro1.ogg');
				introGoSound = FNFAssets.getSound(SUtil.getPath() + 'assets/sounds/introGo.ogg');
			}
	


			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(intro3Sound, 0.6);
				case 1:
					// my life is a lie, it was always this simple
					var sussyPath = SUtil.getPath() + 'assets/images/ready.png';
					if (FNFAssets.exists(SUtil.getPath() + 'assets/images/' + introAlts[0]))
						sussyPath = SUtil.getPath() + 'assets/images/' + introAlts[0];
					var readyImage = FNFAssets.getBitmapData(sussyPath);
					var ready:FlxSprite = new FlxSprite().loadGraphic(readyImage);
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (pixelUI)
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(intro2Sound, 0.6);
				case 2:
					var sussyPath = SUtil.getPath() + 'assets/images/set.png';
					if (FNFAssets.exists(SUtil.getPath() + 'assets/images/' + introAlts[1]))
						sussyPath = SUtil.getPath() + 'assets/images/' + introAlts[1];
					var setImage = FNFAssets.getBitmapData(sussyPath);
					// can't believe you can actually use this as a variable name
					var set:FlxSprite = new FlxSprite().loadGraphic(setImage);
					set.scrollFactor.set();

					if (pixelUI)
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(intro1Sound, 0.6);
				case 3:
					var sussyPath = SUtil.getPath() + 'assets/images/go.png';
					if (FNFAssets.exists(SUtil.getPath() + 'assets/images/' + introAlts[2]))
						sussyPath = SUtil.getPath() + 'assets/images/' + introAlts[2];
					var goImage = FNFAssets.getBitmapData(sussyPath);
					var go:FlxSprite = new FlxSprite().loadGraphic(goImage);
					go.scrollFactor.set();

					if (pixelUI)
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

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
					FlxG.sound.play(introGoSound, 0.6);
				case 4:
					// what is this here for?
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
		/*
		regenTimer = new FlxTimer().start(2, function (tmr:FlxTimer) {
			var bonus = drainBy;
			if (opponentPlayer) {
				bonus = -1 * drainBy;
			}
			if (poisonExr && !paused)
				health -= bonus;
			if (supLove && !paused)
				health +=  bonus;
		}, 0);
		*/
		sickFastTimer = new FlxTimer().start(2, function (tmr:FlxTimer) {
			if (accelNotes && !paused) {
				trace("tick:" + noteSpeed);
				noteSpeed += 0.01;
			}

		}, 0);
		var snekBase:Float = 0;
		var snekTimer = new FlxTimer().start(0.01, function (tmr:FlxTimer) {
			if (snakeNotes && !paused) {
				snekNumber = Math.sin(snekBase) * 100;
				snekBase += Math.PI/100;
			}

		}, 0);
	}
	public function setSongTime(time:Float)
	{
		if(time < 0) time = 0;

		FlxG.sound.music.pause();
		vocals.pause();
		if (isUsingSounds)
			vsounds.pause();

		FlxG.sound.music.time = time;
		FlxG.sound.music.play();

		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = time;
		}
		vocals.play();

		if (isUsingSounds){
			if (Conductor.songPosition <= vocals.length)
				{
					vsounds.time = time;
				}
			vsounds.play();
		}

		Conductor.songPosition = time;
		songTime = time;
	}

	public function clearNotesBefore(time:Float)
		{
			var i:Int = unspawnNotes.length - 1;
			while (i >= 0) {
				var daNote:Note = unspawnNotes[i];
				if(daNote.strumTime - 350 < time)
				{
					daNote.active = false;
					daNote.visible = false;
					daNote.funnyMode = true;
	
					daNote.kill();
					unspawnNotes.remove(daNote);
					daNote.destroy();
				}
				--i;
			}
	
			i = notes.length - 1;
			while (i >= 0) {
				var daNote:Note = notes.members[i];
				if(daNote.strumTime - 350 < time)
				{
					daNote.active = false;
					daNote.visible = false;
					daNote.funnyMode = true;
	
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
				--i;
			}
		}
	
	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;
		if (FlxG.sound.music != null) {
			// cuck lunchbox
			FlxG.sound.music.stop();
		}
		// : )
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;
		var useSong = SUtil.getPath() + "assets/music/" + SONG.song + "_Inst" + TitleState.soundExt;
		if (FNFAssets.exists(SUtil.getPath() + "assets/music/" + SONG.song + "_" + SONG.player1 + "_Inst" + TitleState.soundExt))
			useSong = SUtil.getPath() + "assets/music/" + SONG.song + "_" + SONG.player1 + "_Inst" + TitleState.soundExt;
		if (OptionsHandler.options.stressTankmen && FNFAssets.exists(SUtil.getPath() + "assets/music/" + SONG.song + "/Shit_Inst.ogg"))
			useSong = SUtil.getPath() + "assets/music/" + SONG.song + "/Shit_Inst.ogg";
		if (!paused)
			FlxG.sound.playMusic(FNFAssets.getSound(useSong), 1, false);
		songLength = FlxG.sound.music.length;

		/*if (useSongBar) // I dont wanna talk about this code :(
		{
			remove(songPosBG);
			remove(songPosBar);
			remove(songName);

			songPosBG = new FlxSprite(0, 10).loadGraphic(SUtil.getPath() + 'assets/images/healthBar.png');
			if (downscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);
			songPosBG.cameras = [camHUD];
			if (FlxG.sound.music.length == 0) {
				songLength = 69696969;
			}
			songPosBar = new FlxBar(songPosBG.x
				+ 4, songPosBG.y
				+ 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, songLength
				- 1000);
			songPosBar.numDivisions = 1000;
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);
			songPosBar.cameras = [camHUD];

			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - 20, songPosBG.y, 0, SONG.song, 16);
			if (downscroll)
				songName.y -= 3;
			songName.setFormat(SUtil.getPath() + "assets/fonts/vcr.ttf", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);
			songName.cameras = [camHUD];
		}*/
		if(startOnTime > 0)
			{
				setSongTime(startOnTime - 500);
			}
			startOnTime = 0;

		FlxG.sound.music.onComplete = endSong;
		vocals.play();
		if (isUsingSounds)
			vsounds.play();
	}

	var debugNum:Int = 0;
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();
	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;
		var useSong = SUtil.getPath() + "assets/music/" + SONG.song + "_Voices" + TitleState.soundExt;
		if (FNFAssets.exists(SUtil.getPath() + "assets/music/" + SONG.song + "_" + SONG.player1 + "_Voices" + TitleState.soundExt))
			useSong = SUtil.getPath() + "assets/music/" + SONG.song + "_" + SONG.player1 + "_Voices" + TitleState.soundExt;
		if (OptionsHandler.options.stressTankmen && FNFAssets.exists(SUtil.getPath() + "assets/music/" + SONG.song + "Shit_Voices.ogg"))
			useSong = SUtil.getPath() + "assets/music/" + SONG.song + "Shit_Voices.ogg";

		var useSounds = SUtil.getPath() + "assets/music/" + SONG.song + "_Sounds" + TitleState.soundExt;
		if (FNFAssets.exists(useSounds))
		{
			isUsingSounds = true;
		}

		if (SONG.needsVoices) {
			#if sys
			var vocalSound = Sound.fromFile(useSong);
			vocals = new FlxSound().loadEmbedded(vocalSound);
			#else
			vocals = new FlxSound().loadEmbedded(useSong);
			#end
		}	else
			vocals = new FlxSound();

		if (isUsingSounds) {
			#if sys
			var sfxSound = Sound.fromFile(useSounds);
			vsounds = new FlxSound().loadEmbedded(sfxSound);
			#else
			vsounds = new FlxSound().loadEmbedded(useSounds);
			#end
		}	else
			vsounds = new FlxSound();

		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(vsounds);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		var customImage:Null<BitmapData> = null;
		var customXml:Null<String> = null;
		var arrowEndsImage:Null<BitmapData> = null;
		//var spCustomImage:Null<BitmapData>;
		//var spCustomXml:Null<String>;
		//var sp2CustomImage:Null<BitmapData>;
		//var sp2CustomXml:Null<String>;

		//spCustomImage = FNFAssets.getBitmapData(SUtil.getPath() + 'assets/images/custom_ui/ui_packs/' + uiSmelly.uses+'/noteSplashes.png');
		//spCustomXml = FNFAssets.getText(SUtil.getPath() + 'assets/images/custom_ui/ui_packs/' + uiSmelly.uses+'/noteSplashes.xml');
		
		//if (!pixelUI) {
		//	trace("has this been reached");
		//	customImage = FNFAssets.getBitmapData(SUtil.getPath() + 'assets/images/custom_ui/ui_packs/' + uiSmelly.uses+'/NOTE_assets.png');
		//	customXml = FNFAssets.getText(SUtil.getPath() + 'assets/images/custom_ui/ui_packs/' + uiSmelly.uses+'/NOTE_assets.xml');
		//} else {
		//	customImage = FNFAssets.getBitmapData(SUtil.getPath() + 'assets/images/custom_ui/ui_packs/' + uiSmelly.uses+'/arrows-pixels.png');
		//	arrowEndsImage = FNFAssets.getBitmapData(SUtil.getPath() + 'assets/images/custom_ui/ui_packs/' + uiSmelly.uses+'/arrowEnds.png');
		//}

		var songName:String = SONG.song.toLowerCase();
		var file:String = SUtil.getPath() + 'assets/data/' + songName + '/events.json';
		if (FNFAssets.exists(file)) {
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) //Event Notes
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2], event[1][i][3], event[1][i][4]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0] + OptionsHandler.options.offset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3],
						value3: newEventNote[4]
					};
					subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}

		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] + OptionsHandler.options.offset;
				var daNoteData:Int = Std.int(songNotes[1] % Note.NOTE_AMOUNT);
				var daLift:Bool = songNotes[4];
				var noteHeal:Float = songNotes[5] == null ? 1 : songNotes[5];
				var noteDamage:Float = songNotes[6] == null ? 1 : songNotes[6];
				var consitentNote:Bool = cast songNotes[7];
				var timeThingy:Float = songNotes[8] == null ? 1 : songNotes[8];
				// casting is not ok as default is true
				var shouldSing:Bool = if (songNotes[9] == null) true else songNotes[9];
				// casting is ok as null is falsey
				var ignoreHealthMods:Bool = cast songNotes[10];
				var animSuffix:Null<String> = songNotes[11];
				var gottaHitNote:Bool = section.mustHitSection;
				var altNote:Bool = false;
				var crossFade:Bool = false;
				var altNoteNum:Int = 0;

				if (songNotes[1] % (Main.ammo[mania] * 2) > Main.ammo[mania] - 1)
				{
					gottaHitNote = !section.mustHitSection;
				}

				/*
				if (songNotes[1] >= 8 && songNotes[1] < 16) {
					// sussy fire note support? :flushed:
					// Percent in decimal divided by health thingie
					noteHeal = 0.125 / 0.04;
					consitentNote = true;
					shouldSing = false;
					timeThingy = 0.5;
					noteDamage = 0;
					ignoreHealthMods = true;
					animSuffix = "lift";
				}
				*/
				if (songNotes[3] || section.altAnim)
				{
					altNote = true;
				}

				if (songNotes[12] || (gottaHitNote && section.crossfadeBf) || (!gottaHitNote && section.crossfadeDad))
				{
					crossFade = true;
				}
				// force nuke notes : )
				if (songNotes[1] >= Note.NOTE_AMOUNT * 2 && songNotes[1] < Note.NOTE_AMOUNT * 4 && SONG.convertMineToNuke) {
					songNotes[1] += Note.NOTE_AMOUNT * 4;
				}
				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;
				// stand back i am a professional idiot
				var swagNote:Note = new Note(daStrumTime, songNotes[1], oldNote, false, customImage, customXml, arrowEndsImage, daLift, animSuffix);
				if (!swagNote.dontEdit && !swagNote.mineNote && !swagNote.nukeNote && !swagNote.isLiftNote) {
					swagNote.shouldBeSung = shouldSing;
					swagNote.ignoreHealthMods = ignoreHealthMods;
					swagNote.timingMultiplier = timeThingy;
					swagNote.healMultiplier = noteHeal;
					swagNote.damageMultiplier = noteDamage;
					swagNote.consistentHealth = consitentNote;
				}
				

				// altNote
				swagNote.altNote = altNote;
				swagNote.crossFade = crossFade;
				
				if (!section.altAnim)
					swagNote.altNum = songNotes[3] == null ? (swagNote.altNote ? 1 : 0) : songNotes[3];
				else
					swagNote.altNum = section.altAnimNum == null ? (section.altAnim ? 1 : 0) : section.altAnimNum;
				
				// so much more complicated but makes playstation like shit work
				if (flippedNotes) {
					if (swagNote.animation.curAnim.name == 'greenScroll') {
						swagNote.animation.play('blueScroll');
					} else if (swagNote.animation.curAnim.name == 'blueScroll') {
						swagNote.animation.play('greenScroll');
					} else if (swagNote.animation.curAnim.name == 'redScroll') {
						swagNote.animation.play('purpleScroll');
					} else if (swagNote.animation.curAnim.name == 'purpleScroll') {
						swagNote.animation.play('redScroll');
					} else if (swagNote.animation.curAnim.name == 'yellowScroll') {
						swagNote.animation.play('cyanScroll');
					} else if (swagNote.animation.curAnim.name == 'lilaScroll') {
						swagNote.animation.play('cherryScroll');
					} else if (swagNote.animation.curAnim.name == 'cherryScroll') {
						swagNote.animation.play('lilaScroll');
					} else if (swagNote.animation.curAnim.name == 'cyanScroll') {
						swagNote.animation.play('yellowScroll');
					}
				}
				if (duoMode)
				{
					swagNote.duoMode = true;
				}
				if (opponentPlayer) {
					swagNote.oppMode = true;
				}
				if (demoMode)
					swagNote.funnyMode = true;
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);
				// when the imposter is sus XD
				if (susLength != 0) {
					for (susNote in 0...(Math.floor(susLength) + 2))
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
						if (OptionsHandler.options.emuOsuLifts && susLength < susNote)
						{
							// simulate osu!mania holds by adding lifts at the end
							var liftNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, false,
								customImage, customXml, arrowEndsImage, true);
							if (duoMode)
								liftNote.duoMode = true;
							if (opponentPlayer)
								liftNote.oppMode = true;
							if (demoMode)
								liftNote.funnyMode = true;
							liftNote.scrollFactor.set();
							unspawnNotes.push(liftNote);
							liftNote.mustPress = gottaHitNote;
							if (liftNote.mustPress)
								liftNote.x += FlxG.width / 2;

							// how haxe works by default is exclusive?
						}
						else if (susLength > susNote)
						{
							var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(daScrollSpeed, 2)), daNoteData, oldNote,
								true, customImage, customXml, arrowEndsImage);
							if (duoMode)
							{
								sustainNote.duoMode = true;
							}
							if (opponentPlayer)
							{
								sustainNote.oppMode = true;
							}
							if (demoMode)
								sustainNote.funnyMode = true;
							sustainNote.scrollFactor.set();
							unspawnNotes.push(sustainNote);
							sustainNote.shouldBeSung = shouldSing;
							sustainNote.ignoreHealthMods = ignoreHealthMods;
							sustainNote.timingMultiplier = timeThingy;
							sustainNote.healMultiplier = noteHeal;
							sustainNote.damageMultiplier = noteDamage;
							sustainNote.consistentHealth = consitentNote;
							sustainNote.mustPress = gottaHitNote;
							sustainNote.altNote = swagNote.altNote;
							sustainNote.crossFade = swagNote.crossFade;
							sustainNote.altNum = swagNote.altNum;
							sustainNote.coolId = swagNote.coolId;
							sustainNote.dontCountNote = swagNote.dontCountNote;

							if (sustainNote.mustPress)
							{
								sustainNote.x += FlxG.width / 2; // general offset
							}
						}
					}
				}
				

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
			}
			daBeats += 1;
		}

		for (event in songData.events) //Event Notes
		{
			for (i in 0...event[1].length)
			{
				var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2], event[1][i][3], event[1][i][4]];
				var subEvent:EventNote = {
					strumTime: newEventNote[0] + OptionsHandler.options.offset,
					event: newEventNote[1],
					value1: newEventNote[2],
					value2: newEventNote[3],
					value3: newEventNote[4]
				};
				subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
				eventNotes.push(subEvent);
				eventPushed(subEvent);
			}
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;
		// to get around how pecked up the note system is
		for (epicNote in unspawnNotes) {
			if (epicNote.isSustainNote) {
				if (flippedNotes) {
					if (epicNote.animation.curAnim.name == 'greenhold') {
						epicNote.animation.play('bluehold');
					} else if (epicNote.animation.curAnim.name == 'bluehold') {
						epicNote.animation.play('greenhold');
					} else if (epicNote.animation.curAnim.name == 'redhold') {
						epicNote.animation.play('purplehold');
					} else if (epicNote.animation.curAnim.name == 'purplehold') {
						epicNote.animation.play('redhold');
					} else if (epicNote.animation.curAnim.name == 'yellowhold') {
						epicNote.animation.play('cyanhold');
					} else if (epicNote.animation.curAnim.name == 'lilahold') {
						epicNote.animation.play('cherryhold');
					} else if (epicNote.animation.curAnim.name == 'cherryhold') {
						epicNote.animation.play('lilahold');
					} else if (epicNote.animation.curAnim.name == 'cyanhold') {
						epicNote.animation.play('yellowhold');
					} else if (epicNote.animation.curAnim.name == 'greenholdend') {
						epicNote.animation.play('blueholdend');
					} else if (epicNote.animation.curAnim.name == 'blueholdend') {
						epicNote.animation.play('greenholdend');
					} else if (epicNote.animation.curAnim.name == 'redholdend') {
						epicNote.animation.play('purpleholdend');
					} else if (epicNote.animation.curAnim.name == 'blueholdend') {
						epicNote.animation.play('greenholdend');
					} else if (epicNote.animation.curAnim.name == 'yellowholdend') {
						epicNote.animation.play('cyanholdend');
					} else if (epicNote.animation.curAnim.name == 'lilaholdend') {
						epicNote.animation.play('cherryholdend');
					} else if (epicNote.animation.curAnim.name == 'cherryholdend') {
						epicNote.animation.play('lilaholdend');
					} else if (epicNote.animation.curAnim.name == 'cyanholdend') {
						epicNote.animation.play('yellowholdend');
					}
				}
			}
		}
		
		unspawnNotes.sort(sortByShit);
		if(eventNotes.length > 1) { //No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}
		defaultNoteWidth = unspawnNotes[0].width;
		generatedMusic = true;
	}

	function eventPushed(event:EventNote) 
	{
		switch(event.event) {
			case 'Change Character':
				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event.value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);
		}

		if(!eventPushedMap.exists(event.event)) {
			eventPushedMap.set(event.event, true);
		}
	}

	function eventNoteEarlyTrigger(event:EventNote):Float {
		//var returnedValue:Float = callOnLuas('eventEarlyTrigger', [event.event]);
		//if(returnedValue != 0) {
		//	return returnedValue;
		//}

		//switch(event.event) {
		//	case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
		//		return 280; //Plays 280ms before the actual position
		//}
		return 0;
	}

	var defaultNoteWidth:Float;
	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:EventNote, Obj2:EventNote):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public function setArrowsAnim(arrSpr:FlxSprite, ident:Int):FlxSprite
	{
		var tempArray:Array<Array<String>> = [[]];
		tempArray[0] = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
		tempArray[1] = ['LEFT', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'RIGHT'];
		tempArray[2] = ['LEFT', 'UP', 'RIGHT', 'SPACE', 'LEFT', 'DOWN', 'RIGHT'];
		tempArray[3] = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'SPACE', 'LEFT', 'DOWN', 'UP', 'RIGHT'];

		var tempArray2:Array<Array<String>> = [[]];
		tempArray2[0] = ['left', 'down', 'up', 'right'];
		tempArray2[1] = ['left', 'up', 'right', 'left2', 'down', 'right2'];
		tempArray2[2] = ['left', 'up', 'right','space', 'left2', 'down', 'right2'];
		tempArray2[3] = ['left', 'down', 'up', 'right', 'space', 'left2', 'down2', 'up2', 'right2'];

		if (flippedNotes)
		{
			tempArray[0] = ['RIGHT', 'UP', 'DOWN', 'LEFT'];
			tempArray[1] = ['RIGHT', 'DOWN', 'LEFT', 'RIGHT', 'UP', 'LEFT'];
			tempArray[2] = ['RIGHT', 'DOWN', 'LEFT', 'SPACE', 'RIGHT', 'UP', 'LEFT'];
			tempArray[3] = ['RIGHT', 'UP', 'DOWN', 'LEFT', 'SPACE', 'RIGHT', 'UP', 'DOWN', 'LEFT'];

			tempArray2[0] = ['right', 'up', 'down', 'left'];
			tempArray2[1] = ['right', 'down', 'left', 'right2', 'up', 'left2'];
			tempArray2[2] = ['right', 'down', 'left', 'space', 'right2', 'up', 'left2'];
			tempArray2[3] = ['right', 'up', 'down', 'left', 'space', 'right2', 'up2', 'down2', 'left2'];
		}
		arrSpr.animation.addByPrefix('static', 'arrow' + tempArray[mania][ident]);
		arrSpr.animation.addByPrefix('pressed', tempArray2[mania][ident] + ' press', 24, false);
		arrSpr.animation.addByPrefix('confirm', tempArray2[mania][ident] + ' confirm', 24, false);

		tempArray = [[]];
		tempArray2 = [[]];

		return arrSpr;
	}
	public var skipArrowStartTween:Bool = false; 
	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...Main.ammo[mania])
		{
			// FlxG.log.add(i);
			var babyArrow:StrumNote = new StrumNote(42, strumLine.y, i, player);
			babyArrow.downScroll = downscroll;

			if (!isStoryMode && !skipArrowStartTween)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			
			babyArrow.ID = i;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			} else {
				enemyStrums.add(babyArrow);
			}
			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
			// does not need to be unique because it uses special thingies
			var comboBreakThing = new FlxSprite(babyArrow.x, 0).makeGraphic(Std.int(babyArrow.width), FlxG.height, FlxColor.WHITE);
			comboBreakThing.visible = false;
			comboBreakThing.alpha = 0.6;

			if (player == 1) {
				playerComboBreak.add(comboBreakThing);
			} else {
				enemyComboBreak.add(comboBreakThing);
			}
		}
	}
	function comboBreak(dir:Int, playerOne:Bool = true, rating:String = 'miss') {
	
		if (!OptionsHandler.options.showComboBreaks || !OptionsHandler.options.ratingColorRecs)
			return;
		var coolor = switch (rating) {
			case 'miss':
				missBreakColor;
			case 'wayoff':
				wayoffBreakColor;
			case 'shit':
				shitBreakColor;
			default:
				// just return, as we shouldn't even be here
				return;
		}
		var breakGroup = playerOne ? playerComboBreak : enemyComboBreak;
		dir = dir % Main.ammo[mania];
		var thingToDisplay = breakGroup.members[dir];
		thingToDisplay.color = coolor;
		thingToDisplay.alpha = 1;
		thingToDisplay.visible = true;
		FlxTween.tween(thingToDisplay, {alpha: 0}, 1, {onComplete: function(_) {thingToDisplay.visible = false;}});
	}
	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	/*
	function switchCharacter(charTo:String, charState:String) {
	    switch(charState) {
			case 'boyfriend':
			    remove(boyfriend);
				remove(iconP1);
				boyfriend = new Character(770, 450, charTo, true);
				var camPos = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);
				camPos.x += boyfriend.camOffsetX;
				camPos.y += boyfriend.camOffsetY;
				boyfriend.x += boyfriend.playerOffsetX;
				boyfriend.y += boyfriend.playerOffsetY;
				if (boyfriend.likeGf) {
					boyfriend.setPosition(gf.x, gf.y);
					gf.visible = false;
					if (isStoryMode)
					{
						camPos.x += 600;
						tweenCamIn();
					}
				} else if (!dad.likeGf) {
					gf.visible = true;
				}
				boyfriend.x += bfoffset[0];
				boyfriend.y += bfoffset[1];
				iconP1 = new HealthIcon(charTo, true);
				iconP1.y = healthBar.y - (iconP1.height / 2);
				iconP1.cameras = [camHUD];

				// Layering nonsense
				add(boyfriend);
				add(iconP1);
			case 'dad':
				remove(dad);
				remove(iconP2);
				dad = new Character(100, 100, charTo);
				var camPos = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);
				dad.x += dad.enemyOffsetX;
				dad.y += dad.enemyOffsetY;
				camPos.x += dad.camOffsetX;
				camPos.y += dad.camOffsetY;
				if (dad.likeGf) {
					dad.setPosition(gf.x, gf.y);
					gf.visible = false;
					if (isStoryMode)
					{
						camPos.x += 600;
						tweenCamIn();
					}
				} else if (!boyfriend.likeGf) {
					gf.visible = true;
				}
				dad.x += dadoffset[0];
		                dad.y += dadoffset[1];
				iconP2 = new HealthIcon(charTo, false);
				iconP2.y = healthBar.y - (iconP2.height / 2);
				iconP2.cameras = [camHUD];

				// Layering nonsense
				add(dad);
				add(iconP2);
			case 'gf':
				remove(gf);
				gf = new Character(400, 130, charTo);
				gf.scrollFactor.set(0.95, 0.95);
				gf.x += gfoffset[0];
				gf.y += gfoffset[1];

				// Layering nonsense
				add(gf);

		}
    }
	*/

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
				if (isUsingSounds)
					vsounds.pause();
			}
			controls.setKeyboardScheme(Solo(false));

			if (songSpeedTween != null)
				songSpeedTween.active = false;

			#if desktop
			var ae = FNFAssets.getText(SUtil.getPath() + "assets/discord/presence/playpause.txt");
			DiscordClient.changePresence(ae
				+ SONG.song
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"Acc: "
				+ HelperFunctions.truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC, null, null, playingAsRpc);
			#end
			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
		}
		
		for (tween in modTweens) {
			tween.active = false;
		}
		
		for (timer in modTimers) {
			timer.active = false;
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
			if (!opponentPlayer && !duoMode)
			{
				controls.setKeyboardScheme(Solo(false));
			}
			if (duoMode) {
				controls.setKeyboardScheme(Duo(true));
			}
			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;
			paused = false;
			var currentIconState = "";

			if (songSpeedTween != null)
				songSpeedTween.active = true;

			if (opponentPlayer)
			{
				if (healthBar.percent > 80)
				{
					currentIconState = "Dying";
				}
				else
				{
					currentIconState = "Playing";
				}
				if (poisonTimes != 0)
				{
					currentIconState = "Being Posioned";
				}
			}
			else
			{
				if (healthBar.percent > 20)
				{
					currentIconState = "Dying";
				}
				else
				{
					currentIconState = "Playing";
				}
				if (poisonTimes != 0)
				{
					currentIconState = "Being Posioned";
				}
			}
			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(customPrecence
					+ " "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC, true,
					songLength
					- Conductor.songPosition, playingAsRpc);
			}
			else
			{
				DiscordClient.changePresence(customPrecence, SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy), iconRPC,
					playingAsRpc);
			}
			#end
		}
		
		for (tween in modTweens) {
			tween.active = true;
		}
		
		for (timer in modTimers) {
			timer.active = true;
		}

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		vocals.pause();
		if (isUsingSounds)
			vsounds.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
		if (isUsingSounds)
		{
			vsounds.time = Conductor.songPosition;
			vsounds.play();
		}
		
		#if desktop
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC,
			playingAsRpc);
		#end

		
			
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectModeOld = false;
		#end
		oldStrumlineX = strumLine.x;
		noteSpeedest = noteSpeed;
		setAllHaxeVar('camZooming', camZooming);
		setAllHaxeVar('gfSpeed', gfSpeed);
		setAllHaxeVar('health', health);
		callAllHScript('update', [elapsed]);

		for (i in shaderUpdates){
			i(elapsed);
		}
		for (name in hscriptStates.keys()) {
		if (hscriptIsModChart.exists(name) && hscriptIsModChart.get(name)) {
			if (getHaxeVar("showOnlyStrums", name))
			{
				healthBarBG.visible = false;
				healthBar.visible = false;
				iconP1.visible = false;
				iconP2.visible = false;
				scoreTxt.visible = false;
			}
			else
			{
				healthBarBG.visible = true;
				healthBar.visible = true;
				iconP1.visible = true;
				iconP2.visible = true;
				scoreTxt.visible = true;
			}
			camZooming = getHaxeVar("camZooming", name);
			gfSpeed = getHaxeVar("gfSpeed", name);
			health = getHaxeVar("health", name);

		}
	}
		if (currentFrames == FlxG.save.data.fpsCap)
		{
			for (i in 0...notesHitArray.length)
			{
				var cock:Date = notesHitArray[i];
				if (cock != null)
					if (cock.getTime() + 2000 < Date.now().getTime())
						notesHitArray.remove(cock);
			}
			nps = Math.floor(notesHitArray.length / 2);
			currentFrames = 0;
		}
		else
			currentFrames++;
		super.update(elapsed);
		if (snapToStrumline) {
			notes.forEachAlive(function (daNote) {
				var noteData = daNote.noteData;
				if (daNote.mustPress)
					noteData += 4; 
				daNote.x = strumLineNotes.members[noteData].x;
				if (daNote.isSustainNote)
					daNote.x += defaultNoteWidth / 2 - daNote.width / 2; 
			});
			for (i in 0...playerStrums.members.length)
			{
				playerComboBreak.members[i].x = playerStrums.members[i].x;
			}
			for (i in 0...enemyStrums.members.length) {
				enemyComboBreak.members[i].x = enemyStrums.members[i].x;
			}
		}
		var properHealth = opponentPlayer ? 100 - Math.round(health*50) : Math.round(health*50);
		healthTxt.text = "Health:" + properHealth + "%";
		/*
		switch (OptionsHandler.options.accuracyMode) {
			case Simple | Binary | Complex: 
				if (notesPassing != 0)
					accuracy = HelperFunctions.truncateFloat((notesHit / notesPassing) * 100, 2);
				else
					accuracy = 100;
			case None:
				accuracy = 0;
		}*/
		if (disableScoreChange == false) {
			scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, accuracy);
		}
		if (perfectMode && !Ratings.CalculateFullCombo(Sick))
		{
			if (opponentPlayer)
				health = 50;
			else
				health = -50;
		}
		if (fullComboMode && !Ratings.CalculateFullCombo(Shit)) {
			if (opponentPlayer)
				health = 50;
			else
				health = -50;
		}
		if (goodCombo && !Ratings.CalculateFullCombo(Good)) {
			if (opponentPlayer)
				health = 50;
			else
				health = -50;
		}
		accuracyTxt.text = "Accuracy:" + accuracy + "%";
		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
				if (isUsingSounds)
					vsounds.pause();
			}

			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (FlxG.keys.justPressed.SEVEN && !OptionsHandler.options.danceMode && !inVideoCutscene)
		{
			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
			chartingMode = true;
			LoadingState.loadAndSwitchState(new ChartingState());
		}
		if (FlxG.keys.justPressed.NINE) {
			oldMode = !oldMode;
			if (oldMode) {
				if (boyfriend.isPixel)
					iconP1.switchAnim("bf-pixel-old");
				else
					iconP1.switchAnim("bf-old");
			} else {
				iconP1.switchAnim(SONG.player1);
			}
		}
		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		var hitSpeed = 0.50;
		
		if (CoolUtil.fps == 120)
			hitSpeed = 0.25;
		
		if (CoolUtil.fps == 240)
			hitSpeed = 0.125;

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, hitSpeed)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, hitSpeed)));
		practiceDieIcon.setGraphicSize(Std.int(FlxMath.lerp(150, practiceDieIcon.width, hitSpeed)));
		iconP1.updateHitbox();
		iconP2.updateHitbox();
		practiceDieIcon.updateHitbox();
		var iconOffset:Int = 26;
		
		if (poisonTimes > 0 && !barShowingPoison) {
			var leftSideFill = opponentPlayer ? dad.poisonColorEnemy : dad.enemyColor;
			var rightSideFill = opponentPlayer ? boyfriend.bfColor : boyfriend.poisonColor;
			healthBar.createFilledBar(leftSideFill, rightSideFill);
			barShowingPoison = true;
		} else if (poisonTimes == 0 && barShowingPoison) {
			var leftSideFill = opponentPlayer ? dad.opponentColor : dad.enemyColor;
			var rightSideFill = opponentPlayer ? boyfriend.bfColor : boyfriend.playerColor;
			if (duoMode) {
				leftSideFill = dad.opponentColor;
				rightSideFill = boyfriend.bfColor;
			}
			healthBar.createFilledBar(leftSideFill, rightSideFill);
			barShowingPoison = false;
		}

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
		player1Icon = SONG.player1;
		switch(SONG.player1) {
			case "bf-car":
				player1Icon = "bf";
			case "bf-christmas":
				player1Icon = "bf";
			case "bf-holding-gf":
				player1Icon = "bf";
			case "monster-christmas":
				player1Icon = "monster";
			case "mom-car":
				player1Icon = "mom";
			case "pico-speaker":
				player1Icon = "pico";
			case "gf-car":
				player1Icon = "gf";
			case "gf-christmas":
				player1Icon = "gf";
			case "gf-pixel":
				player1Icon = "gf";
			case "gf-tankman":
				player1Icon = "gf";
				
		}
		if (healthBar.percent < 20)
		{
			iconP1.iconState = Dying;
			iconP2.iconState = Winning;
			#if desktop
			iconRPC = player1Icon + "-dead";
			#end
		}
		else
		{
			iconP1.iconState = Normal;
			#if desktop
			iconRPC = player1Icon;
			#end
		}
		if (!opponentPlayer && poisonTimes != 0)
		{
			iconP1.iconState = Poisoned;
			#if desktop
			iconRPC = player1Icon + "-dazed";
			#end
		}	
		
		// duo mode shouldn't show low health
		if (properHealth < 20 && !duoMode) {
			healthTxt.setFormat(SUtil.getPath() + "assets/fonts/vcr.ttf", 20, FlxColor.RED, RIGHT, OUTLINE, FlxColor.BLACK);
		} else {
			healthTxt.setFormat(SUtil.getPath() + "assets/fonts/vcr.ttf", 20, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		}	
		player2Icon = SONG.player2;
		switch (SONG.player2)
		{
			case "bf-car":
				player2Icon = "bf";
			case "bf-christmas":
				player2Icon = "bf";
			case "bf-holding-gf":
				player2Icon = "bf";
			case "monster-christmas":
				player2Icon = "monster";
			case "mom-car":
				player2Icon = "mom";
			case "pico-speaker":
				player2Icon = "pico";
			case "gf-car":
				player2Icon = "gf";
			case "gf-christmas":
				player2Icon = "gf";
			case "gf-pixel":
				player2Icon = "gf";
			case "gf-tankman":
				player2Icon = "gf";
		}

		if (healthBar.percent > 80) {
			iconP2.iconState = Dying;
			if (iconP1.iconState != Poisoned) {
				iconP1.iconState = Winning;
			}
			#if desktop
			if (opponentPlayer)
				iconRPC = player2Icon + "-dead";
			#end
		}
		else {
			iconP2.iconState = Normal;
			#if desktop
			if (opponentPlayer)
				iconRPC = player2Icon;
			#end
		}
		if (healthBar.percent < 20) {
			iconP2.iconState = Winning;
		}
		if (poisonTimes != 0 && opponentPlayer) {
			iconP2.iconState = Poisoned;
			#if desktop
			if (opponentPlayer)
				iconRPC = player2Icon + "-dazed";
			#end
		}
		/* if (FlxG.keys.justPressed.NINE)
			LoadingState.loadAndSwitchState(new Charting()); */

		if (FlxG.keys.justPressed.EIGHT && !OptionsHandler.options.danceMode) // stop checking for debug so i can fix my offsets!
			LoadingState.loadAndSwitchState(new AnimationDebug(SONG.player2, SONG.player1));
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
			songPositionBar = Conductor.songPosition / songLength;
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

		if (unspawnNotes[0] != null)
		{
			var time:Float = 3000;//shit be werid on 4:3
			if(daScrollSpeed < 1) time /= daScrollSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (endingSong)
			return;
		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}
			setAllHaxeVar("mustHit", PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			if (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				if (!forceCamera)
				{
					camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
				}
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);
				callAllHScript("playerTwoTurn", []);
				if (dad.isCustom) {
					if (!forceCamera)
					{
						camFollow.y = dad.getMidpoint().y + dad.followCamY;
						camFollow.x = dad.getMidpoint().x + dad.followCamX;
					}
				}
				if (!opponentPlayer || !duoMode)
				vocals.volume = 1;
			}
			var currentIconState = "";
			if (opponentPlayer)
			{
				if (healthBar.percent > 80)
				{
					currentIconState = "Dying";
				}
				else
				{
					currentIconState = "Playing";
				}
				if (poisonTimes != 0)
				{
					currentIconState = "Being Posioned";
				}
			}
			else
			{
				if (healthBar.percent < 20)
				{
					currentIconState = "Dying";
				}
				else
				{
					currentIconState = "Playing";
				}
				if (poisonTimes != 0)
				{
					currentIconState = "Being Posioned";
				}
			}
			if (supLove) {
				health += loveMultiplier * (opponentPlayer ? -1 : 1) / 600000;
			}
			if (poisonExr) {
				health -= poisonMultiplier * (opponentPlayer ? -1 : 1)/ 700000;
			}
			playingAsRpc = "Playing as " + (opponentPlayer ? player2Icon : player1Icon) + " | " + currentIconState;
			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				if (!forceCamera)
				{
					camFollow.setPosition((boyfriend.getMidpoint().x - 100 + boyfriend.followCamX), (boyfriend.getMidpoint().y - 100+boyfriend.followCamY));
				}
				callAllHScript("playerOneTurn", []);
				if (!forceCamera)
				{
					switch (curStage)
					{
						// not sure that's how variable assignment works
						#if !windows
						case 'limo':
							camFollow.x = boyfriend.getMidpoint().x - 300 + boyfriend.followCamX; // why are you hard coded
						
						case 'mall':
							camFollow.y = boyfriend.getMidpoint().y - 200 + boyfriend.followCamY;
						#end
						case 'school':
							camFollow.x = boyfriend.getMidpoint().x - 200 + boyfriend.followCamX;
							camFollow.y = boyfriend.getMidpoint().y - 200 + boyfriend.followCamY;
						case 'schoolEvil':
							camFollow.x = boyfriend.getMidpoint().x - 200 + boyfriend.followCamX;
							camFollow.y = boyfriend.getMidpoint().y - 200 + boyfriend.followCamY;
					}
				}
				
				/*
				if (SONG.song.toLowerCase() == 'tutorial')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
				}
				*/
				if (opponentPlayer || !duoMode)
					vocals.volume = 1;
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);
		// now modchart
		/*
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
		}*/
		// now mod chart
		/*
		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}*/
		// better streaming of shit

		// RESET = Quick Game Over Screen
		if (controls.RESET && !inCutscene)
		{
			if (opponentPlayer)
				health = 2;
			else
				health = 0;
			trace("RESET = True");
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
			health += 1;
			trace("User is cheating!");
		}

		if (((health <= 0 && !opponentPlayer) || (health >= 2 && opponentPlayer)) && !practiceMode && !duoMode)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();
			deathCounter++;
			
			if (inALoop) {
				FlxG.resetState();
			} else {
				// 1 / 1000 chance for Gitaroo Man easter egg
				if (FlxG.random.bool(0.1))
				{
					// gitaroo man easter egg
					LoadingState.loadAndSwitchState(new GitarooPause());
				}
				else
				{
					if (opponentPlayer)
					{
						gameOverChar = dad.curCharacter;
						openSubState(new GameOverSubstate(dad.getScreenPosition().x, dad.getScreenPosition().y, dad.isPlayer));
					}
					else
					{
						gameOverChar = boyfriend.curCharacter;
						openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y, boyfriend.isPlayer));
					}
				}
				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("GAME OVER -- "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC, null, null,
					playingAsRpc);
				#end

			}

			
			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}
		else if (((health <= 0 && !opponentPlayer) || (health >= 2 && opponentPlayer)) && !practiceDied && practiceMode) {
			practiceDied = true;
			practiceDieIcon.visible = true;
		}
		health = FlxMath.bound(health,0,2);
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

		if (!inCutscene && !demoMode) {
			// is that why it was crashing
			if (!opponentPlayer)
				keyShit(true);
			if (duoMode || opponentPlayer)
			{
				keyShit(false);
			}
		}

		if (generatedMusic)
		{
			var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
			notes.forEachAlive(function(daNote:Note)
			{
				var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
				if(!daNote.mustPress) strumGroup = enemyStrums;

				var strumX:Float = strumGroup.members[daNote.noteData].x;
				var strumY:Float = strumGroup.members[daNote.noteData].y;
				var strumAngle:Float = strumGroup.members[daNote.noteData].angle;
				var strumAlpha:Float = strumGroup.members[daNote.noteData].alpha;
				var strumDown:Bool = strumGroup.members[daNote.noteData].downScroll;
				var strumDirection:Float = strumGroup.members[daNote.noteData].direction;
				var strumAlpha:Float = strumGroup.members[daNote.noteData].alpha;
				var noteDistance:Float;
				var strumAngle:Float = strumGroup.members[daNote.noteData].angle;
				
				var angleDir = strumDirection * Math.PI / 180;
				if (daNote.copyAngle)
					daNote.angle = strumDirection - 90 + strumAngle;

				if (strumDown) //Downscroll
				{
					//daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
					noteDistance = (0.45 * (Conductor.songPosition - daNote.strumTime) * daScrollSpeed);
				}
				else //Upscroll
				{
					//daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
					noteDistance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * daScrollSpeed);
				}

				if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = !invsNotes;
					daNote.active = true;
				}

			
				if (forceAlphaStrum)
					daNote.alpha = strumAlpha * daNote.alphaMultiplier;

				var coolMustPress = daNote.mustPress;
				if (duoMode)
					coolMustPress = true;
				if (opponentPlayer)
					coolMustPress = !daNote.mustPress;
							
				if (!daNote.modifiedByLua) {
					//var center:Float = strumLine.y + Note.swagWidth / 2;

					daNote.y = strumY + noteDistance;

					if(downscroll && daNote.isSustainNote)
					{
						if (daNote.animation.curAnim.name.endsWith('end')) {
							daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * daScrollSpeed + (46 * (daScrollSpeed - 1));
							daNote.y -= 46 * (1 - (fakeCrochet / 600)) * daScrollSpeed;
							daNote.y += 19;
						} 
						daNote.y += ((Note.swidths[mania] * Note.swagWidth) / 2) - (60.5 * (daScrollSpeed - 1));
						daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (daScrollSpeed - 1);
					}

					if (daNote.isSustainNote)
					{
						//aaaa
					}

					var center:Float = strumY + ((Note.swidths[mania] * Note.swagWidth) / 2);
					if (daNote.isSustainNote && ((daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
					{
						if (downscroll)
						{
							if (daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
							{
								var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
								swagRect.height = (center - daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;

								daNote.clipRect = swagRect;
							}
						}
						else
						{
							if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (center - daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
						}
					}
				}

				if (!daNote.hittedNote && (!daNote.mustPress && daNote.wasGoodHit && ((!duoMode && !opponentPlayer) || demoMode)))
				{
					camZooming = true;
					dad.altAnim = "";
					dad.altNum = 0;
					
					if (daNote.altNote)
					{
						dad.altAnim = '-alt';
						dad.altNum = 1;
					}
					
					dad.altNum = daNote.altNum;

					/*if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if ((SONG.notes[Math.floor(curStep / 16)].altAnimNum > 0 && SONG.notes[Math.floor(curStep / 16)].altAnimNum != null) || SONG.notes[Math.floor(curStep / 16)].altAnim)
							// backwards compatibility shit
							if (SONG.notes[Math.floor(curStep / 16)].altAnimNum == 1 || SONG.notes[Math.floor(curStep / 16)].altAnim || daNote.altNote)
								dad.altNum = 1;
							else if (SONG.notes[Math.floor(curStep / 16)].altAnimNum != 0)
								dad.altNum = SONG.notes[Math.floor(curStep / 16)].altAnimNum;
					}*/
					
					if (dad.altNum == 1) {
						dad.altAnim = '-alt';
					} else if (dad.altNum > 1) {
						dad.altAnim = '-' + dad.altNum + 'alt';
					}
					
					// go wild <3
					if (daNote.shouldBeSung) {
						dad.sing(Std.int(Math.abs(daNote.noteData)), false, dad.altNum);
						if (daNote.oppntSing != null) {
							boyfriend.sing(daNote.oppntSing.direction, daNote.oppntSing.miss, daNote.oppntSing.alt);
						}
					}

					if (daNote.specialSinger != null) {
						daNote.specialSinger.sing(Std.int(Math.abs(daNote.noteData)), false, dad.altNum);
					}
					var time:Float = 0.15;
					if(daNote.isSustainNote && !daNote.animation.curAnim.name.endsWith('end')) {
						time += 0.15;
					}
					if (!OptionsHandler.options.disableCpuStrums)
					{
						StrumPlayAnim(true, (Std.int(Math.abs(daNote.noteData)) % Main.ammo[mania]), time,!opponentPlayer);
					}
					
					dad.holdTimer = 0;

					if (daNote.crossFade)
					{
						makeCrossfades(false);
					}

					callAllHScript("playerTwoSing", []);
					var daData = Math.round(Math.abs(daNote.noteData));
					callAllHScript("goodNoteHit", [daNote, daData, daNote.coolId, daNote.isSustainNote, false]);

					if (SONG.needsVoices)
						vocals.volume = 1;

					if (!daNote.isSustainNote)
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}

					daNote.hittedNote = true;
					
				} else if (!daNote.hittedNote && (daNote.mustPress && daNote.wasGoodHit && (opponentPlayer || demoMode))) {
					camZooming = true;
					boyfriend.altAnim = "";
					boyfriend.altNum = 0;
					if (daNote.altNote)
					{
						boyfriend.altAnim = '-alt';
						boyfriend.altNum = 1;
					}
					boyfriend.altNum = daNote.altNum;

					/*
					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if ((SONG.notes[Math.floor(curStep / 16)].altAnimNum > 0 && SONG.notes[Math.floor(curStep / 16)].altAnimNum != null) || SONG.notes[Math.floor(curStep / 16)].altAnim)
							// backwards compatibility shit
							if (SONG.notes[Math.floor(curStep / 16)].altAnimNum == 1 || SONG.notes[Math.floor(curStep / 16)].altAnim || daNote.altNote)
								boyfriend.altNum = 1;
							else if (SONG.notes[Math.floor(curStep / 16)].altAnimNum != 0)
								boyfriend.altNum = SONG.notes[Math.floor(curStep / 16)].altAnimNum;
					}
					*/
					
					if (boyfriend.altNum == 1) {
						boyfriend.altAnim = '-alt';
					} else if (boyfriend.altNum > 1) {
						boyfriend.altAnim = '-' + boyfriend.altNum + 'alt';
					}

					if (demoMode)
					{
						popUpScore(Conductor.songPosition, daNote, true);
						if (!daNote.isSustainNote)
							combo += 1;

						if (combo > 9999)
							combo = 9999;
					}
					
					if (daNote.shouldBeSung) {
						boyfriend.sing(Std.int(Math.abs(daNote.noteData % Main.ammo[mania])), false, boyfriend.altNum);
						if (daNote.oppntSing != null) {
							dad.sing(Std.int(Math.abs(daNote.oppntSing.direction % Main.ammo[mania])), daNote.oppntSing.miss, daNote.oppntSing.alt);
							// don't strum it because there isn't actually a note
						}
					}

					if (daNote.specialSinger != null) {
						daNote.specialSinger.sing(Std.int(Math.abs(daNote.noteData % Main.ammo[mania])), false, boyfriend.altNum);
					}
					var time:Float = 0.15;
					if(daNote.isSustainNote && !daNote.animation.curAnim.name.endsWith('end')) {
						time += 0.15;
					}
					if (!OptionsHandler.options.disableCpuStrums)
					{
						StrumPlayAnim(true, (Std.int(Math.abs(daNote.noteData)) % Main.ammo[mania]), time,opponentPlayer);
					}

					boyfriend.holdTimer = 0;
					
					if (daNote.crossFade)
					{
						makeCrossfades(true);
					}

					callAllHScript("playerOneSing", []);
					var daData = Math.round(Math.abs(daNote.noteData));
					callAllHScript("goodNoteHit", [daNote, daData, daNote.coolId, daNote.isSustainNote, true]);

					if (SONG.needsVoices)
						vocals.volume = 1;

					if (!daNote.isSustainNote)
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}

					daNote.hittedNote = true;
				}

				var neg = downscroll ? -1 : 1;
				//if (drunkNotes) {
				//	daNote.y = (strumLine.y - neg * (Conductor.songPosition - daNote.strumTime) * ((Math.sin(songTime/400)/6)+0.5) * noteSpeed * FlxMath.roundDecimal(PlayState.daScrollSpeed, 2));
				//} else {
				//	daNote.y = (strumLine.y - neg * (Conductor.songPosition - daNote.strumTime) * (noteSpeed * FlxMath.roundDecimal(PlayState.daScrollSpeed, 2)));
				//}
				if (vnshNotes) {
					if (downscroll) {
						daNote.alpha = FlxMath.remapToRange(-daNote.y, -strumLine.y,0 , 0, 1);
					} else {
						daNote.alpha = FlxMath.remapToRange(daNote.y, strumLine.y, FlxG.height, 0, 1);
					}
				}
					
				if (snakeNotes) {
					if (daNote.mustPress) {
						daNote.x = (FlxG.width/2)+snekNumber+(Note.swagWidth*daNote.noteData)+50;
					} else {
						daNote.x = snekNumber+(Note.swagWidth*daNote.noteData)+50;
					}
				}
				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * daScrollSpeed));

				if (Conductor.songPosition > 500 + daNote.strumTime) //(((daNote.y < -daNote.height - 120 && !downscroll) || (daNote.y > FlxG.height + daNote.height && downscroll)) && !daNote.dontCountNote)
				{

						if (((daNote.tooLate && !daNote.hittedNote) || !daNote.wasGoodHit) && !daNote.dontCountNote)
						{
							// always show the graphic
							popUpScore(Conductor.songPosition, daNote, daNote.mustPress, true);
							var daData = Math.round(Math.abs(daNote.noteData));
							callAllHScript("noteMiss", [daNote, daData, daNote.coolId, daNote.isSustainNote, daNote.mustPress]);
							if (!OptionsHandler.options.dontMuteMiss)
								vocals.volume = 0;
							if (poisonPlus && poisonTimes < 3)
							{
								poisonTimes += 1;
								var poisonPlusTimer = new FlxTimer().start(0.5, function(tmr:FlxTimer)
								{
									if (opponentPlayer)
										health += 0.04;
									else
										health -= 0.04;
								}, 0);
								// stop timer after 3 seconds
								new FlxTimer().start(3, function(tmr:FlxTimer)
								{
									poisonPlusTimer.cancel();
									poisonTimes -= 1;
								});
							}
						}

						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
				}
				if ((!duoMode && !opponentPlayer) || demoMode) {
					enemyStrums.forEach(function(spr:StrumNote)
					{
						if (strumming2[spr.ID])
						{
							spr.playAnim('confirm', true);
						}

						
					});
				} 
				if (opponentPlayer || demoMode) {
					playerStrums.forEach(function(spr:StrumNote)
					{
						if (strumming1[spr.ID])
						{
							spr.playAnim('confirm', true);
						}

					});
				}
			});
		}

		checkEventNote();
			
		callAllHScript('endUpdate', [elapsed]);

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
			setSongTime(Conductor.songPosition + 10000);
			clearNotesBefore(Conductor.songPosition);
		}
		#end
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0].strumTime;
			if(Conductor.songPosition < leStrumTime) {
				break;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			var value3:String = '';
			if(eventNotes[0].value3 != null)
				value3 = eventNotes[0].value3;

			triggerEventNote(eventNotes[0].event, value1, value2, value3);
			eventNotes.shift();
		}
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String, value3:String) {
		switch(eventName) {
			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if(Math.isNaN(time) || time <= 0) time = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					} else if (gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if(Math.isNaN(value) || value < 1) value = 1;
				gfSpeed = value;

			case 'Add Camera Zoom':
				if(FlxG.camera.zoom < 1.35) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if(Math.isNaN(camZoom)) camZoom = 0.015;
					if(Math.isNaN(hudZoom)) hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}

			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if(Math.isNaN(val2)) val2 = 0;
		
						switch(val2) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 0;
				if(Math.isNaN(val2)) val2 = 0;

				forceCamera = false;
				if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
					camFollow.x = val1;
					camFollow.y = val2;
					forceCamera = true;
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					//char.recalculateDanceIdle();
				}

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if(split[0] != null) duration = Std.parseFloat(split[0].trim());
					if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}

			case 'Change Character':
				var oldChar:Character;
				var charType:Int = 0;
				switch(value1) {
					case 'gf' | 'girlfriend':
						charType = 2;
						oldChar = gf;
					case 'dad' | 'opponent':
						charType = 1;
						oldChar = dad;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
						oldChar = boyfriend;
				}

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend.active = false;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							boyfriend.active = true;
							iconP1.switchAnim(boyfriend.curCharacter);

							if ((value3 == 'true' || value3 == '1') && oldChar != boyfriend)
							{
								if (boyfriendMap.exists(oldChar.curCharacter))
								{
									removeCharacterFromList(oldChar.curCharacter, charType);
								}
							}
						}
						//setOnLuas('boyfriendName', boyfriend.curCharacter);

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad.active = false;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf')) {
								if(wasGf && gf != null) {
									gf.visible = true;
								}
							} else if(gf != null) {
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							dad.active = true;
							iconP2.switchAnim(dad.curCharacter);

							if ((value3 == 'true' || value3 == '1') && oldChar != dad)
							{
								if (dadMap.exists(oldChar.curCharacter))
								{
									removeCharacterFromList(oldChar.curCharacter, charType);
								}
							}
						}
						//setOnLuas('dadName', dad.curCharacter);

					case 2:
						if(gf != null)
						{
							if(gf.curCharacter != value2)
							{
								if(!gfMap.exists(value2))
								{
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf.active = false;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
								gf.active = true;

								if ((value3 == 'true' || value3 == '1') && oldChar != gf)
								{
									if (gfMap.exists(oldChar.curCharacter))
									{
										removeCharacterFromList(oldChar.curCharacter, charType);
									}
								}
							}
							//setOnLuas('gfName', gf.curCharacter);
						}
				}
				reloadHealthBarColors();
			
			case 'Change Scroll Speed':
				//if (songSpeedType == "constant")
				//	return;
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 1;
				if(Math.isNaN(val2)) val2 = 0;

				var newValue:Float = SONG.speed * val1;

				if(val2 <= 0)
				{
					daScrollSpeed = newValue;
				}
				else
				{
					songSpeedTween = FlxTween.tween(this, {daScrollSpeed: newValue}, val2, {ease: FlxEase.linear, onComplete:
						function (twn:FlxTween)
						{
							songSpeedTween = null;
						}
					});
				}
			case 'Setting Crossfades':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				var val3:String = value3;
				if(Math.isNaN(val1)) val1 = 0.75;
				if(Math.isNaN(val2)) val2 = 1.0;
				if(val3 == '') val3 = 'normal';

				cfDuration = val1;
				cfIntensity = val2;
				cfBlend = val3;
		}
		callAllHScript("onEvent", [eventName, value1, value2, value3]);
	}

	function sustain2(strum:Int, spr:StrumNote, note:Note):Void
	{
		var length:Float = note.sustainLength;

		var bps:Float = Conductor.bpm / 60;
		var spb:Float = 1 / bps;

		if (!note.isSustainNote)
		{
			new FlxTimer().start(length == 0 ? 0.2 : (length / Conductor.crochet * spb) + 0.1, function(tmr:FlxTimer)
			{
				if (spr.animation.curAnim.finished) {
					spr.animation.play('static', true);
					spr.centerOffsets();
				} else {
					tmr.reset(0.1);
				}
			});
		}
	}
	function endSong():Void
	{
		endingSong = true;
		canPause = false;
		FlxG.sound.music.volume = 0;
		if (!OptionsHandler.options.dontMuteMiss)
			vocals.volume = 0;
		vocals.pause();
		trace(vocals.getActualVolume());
		var dialogSuffix = "-end";
		if (OptionsHandler.options.stressTankmen) {
			dialogSuffix += "-shit";
		}
		// if this is skipped when love is on, that means love is less than or equal to fright so
		else if (supLove && poisonMultiplier < loveMultiplier) {
			dialogSuffix += "-love";
		} else if (poisonExr && poisonMultiplier < 50) {
			dialogSuffix += "-uneasy";
		} else if (poisonExr && poisonMultiplier >= 50 && poisonMultiplier < 100) {
			dialogSuffix += "-scared";
		} else if (poisonExr && poisonMultiplier >= 100 && poisonMultiplier < 200) {
			dialogSuffix += "-terrified";
		} else if (poisonExr && poisonMultiplier >= 200) {
			dialogSuffix += "-depressed";
		} else if (practiceMode) {
			dialogSuffix += "-practice";
		} else if (perfectMode || fullComboMode || goodCombo) {
			dialogSuffix += "-perfect";
		}
		var filename:Null<String> = null;
		if (FNFAssets.exists(SUtil.getPath() + 'assets/images/custom_chars/' + SONG.player1 + '/' + SONG.song.toLowerCase() + 'Dialog-end.txt'))
		{	
			filename = SUtil.getPath() + 'assets/images/custom_chars/' + SONG.player1 + '/' + SONG.song.toLowerCase() + 'Dialog-end.txt';
			if (FNFAssets.exists(SUtil.getPath() + 'assets/images/custom_chars/' + SONG.player1 + '/' + SONG.song.toLowerCase() + 'Dialog'+dialogSuffix+'.txt'))
				filename = SUtil.getPath() + 'assets/images/custom_chars/' + SONG.player1 + '/' + SONG.song.toLowerCase() + 'Dialog' + dialogSuffix + '.txt';
		}
		else if (FNFAssets.exists(SUtil.getPath() + 'assets/images/custom_chars/' + SONG.player2 + '/' + SONG.song.toLowerCase() + 'Dialog-end.txt'))
		{
			filename = SUtil.getPath() + 'assets/images/custom_chars/' + SONG.player2 + '/' + SONG.song.toLowerCase() + 'Dialog-end.txt';
			if (FNFAssets.exists(SUtil.getPath() + 'assets/images/custom_chars/' + SONG.player2 + '/' + SONG.song.toLowerCase() + 'Dialog${dialogSuffix}.txt')) {
				filename = SUtil.getPath() + 'assets/images/custom_chars/' + SONG.player2 + '/' + SONG.song.toLowerCase() + 'Dialog${dialogSuffix}.txt';
			}
			// if no player dialog, use default
		}
		else if (FNFAssets.exists(SUtil.getPath() + 'assets/data/' + SONG.song.toLowerCase() + '/dialog-end.txt'))
		{
			filename = SUtil.getPath() + 'assets/data/' + SONG.song.toLowerCase() + '/dialog-end.txt';
			if (FNFAssets.exists(SUtil.getPath() + 'assets/data/' + SONG.song.toLowerCase() + '/dialog${dialogSuffix}.txt'))
			{
				filename = SUtil.getPath() + 'assets/data/' + SONG.song.toLowerCase() + '/dialog${dialogSuffix}.txt';
			}
		}
		else if (FNFAssets.exists(SUtil.getPath() + 'assets/data/' + SONG.song.toLowerCase() + '/dialogue-end.txt'))
		{
			filename = SUtil.getPath() + 'assets/data/' + SONG.song.toLowerCase() + '/dialogue-end.txt';
			if (FNFAssets.exists(SUtil.getPath() + 'assets/data/' + SONG.song.toLowerCase() + '/dialogue${dialogSuffix}.txt'))
			{
				filename = SUtil.getPath() + 'assets/data/' + SONG.song.toLowerCase() + '/dialogue${dialogSuffix}.txt';
			}
		}
		var goodDialog:String;
		if (filename != null) {
			goodDialog = FNFAssets.getText(filename);
		} else {
			goodDialog = ':dad: The game tried to get a dialog file but couldn\'t find it. Please make sure there is a dialog file named "dialog.txt".';
		}
		// never play it if the file doesn't exist
		if ((OptionsHandler.options.alwaysDoCutscenes || isStoryMode) && filename != null) {
			doof = new DialogueBox(false, goodDialog);
			doof.scrollFactor.set();
			doof.finishThing = endForReal;

			doof.cameras = [camHUD];
			schoolIntro(doof, false);
		} else {
			if (!endingCutscene)
			{
				endForReal();
			}
		}
		
		callAllHScript('onEndSong', [SONG.song]);
	}
	function endForReal() {
		#if !switch
		if (!demoMode && ModifierState.scoreMultiplier > 0)
			Highscore.saveScore(SONG.song, songScore, storyDifficulty, accuracy / 100, Ratings.CalculateFCRating(), OptionsHandler.options.judge);
		#end
		controls.setKeyboardScheme(Solo(false));
		if (chartingMode)
			{
				LoadingState.loadAndSwitchState(new ChartingState());
				return;
			}
			seenCutscene = false;
		if (isStoryMode)
		{
			campaignScore += songScore;
			campaignScoreDef += songScoreDef;
			campaignAccuracy += accuracy;
			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic(SUtil.getPath() + 'assets/music/freakyMenu' + TitleState.soundExt);

				if (!demoMode && ModifierState.scoreMultiplier > 0)
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty, campaignAccuracy / defaultPlaylistLength);
				campaignAccuracy = campaignAccuracy / defaultPlaylistLength;
				if (useVictoryScreen)
				{
					#if desktop
					DiscordClient.changePresence("Reviewing Score -- "
						+ SONG.song
						+ " ("
						+ storyDifficultyText
						+ ") "
						+ Ratings.GenerateLetterRank(accuracy),
						"\nAcc: "
						+ HelperFunctions.truncateFloat(accuracy, 2)
						+ "% | Score: "
						+ songScore
						+ " | Misses: "
						+ misses, iconRPC, playingAsRpc);
					#end
					LoadingState.loadAndSwitchState(new VictoryLoopState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y,
						gf.getScreenPosition().x, gf.getScreenPosition().y, campaignAccuracy, campaignScore, dad.getScreenPosition().x,
						dad.getScreenPosition().y));
				}
				else
				{
					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;
					LoadingState.loadAndSwitchState(new StoryMenuState());
				}
				FlxG.save.flush();
			}
			else
			{
				var difficulty:String = "";

				difficulty = DifficultyIcons.getEndingFP(storyDifficulty);
				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(SUtil.getPath() + 'assets/sounds/Lights_Shut_off' + TitleState.soundExt);
				}

				if (SONG.song.toLowerCase() == 'senpai')
				{
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					prevCamFollow = camFollow;
				}
				if (FNFAssets.exists(SUtil.getPath() + 'assets/data/'
					+ PlayState.storyPlaylist[0].toLowerCase() + '/' + PlayState.storyPlaylist[0].toLowerCase() + difficulty + '.json'))
					// do this to make custom difficulties not as unstable
					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				else
					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase(), PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				LoadingState.loadAndSwitchState(new PlayState());
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			if (useVictoryScreen)
			{
				#if desktop
				DiscordClient.changePresence("Reviewing Score -- "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC, playingAsRpc);
				#end
				LoadingState.loadAndSwitchState(new VictoryLoopState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y,
					gf.getScreenPosition().x, gf.getScreenPosition().y, accuracy, songScore, dad.getScreenPosition().x, dad.getScreenPosition().y));
			}
			else
				LoadingState.loadAndSwitchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;
	var timeShown:Int = 0;
	private function popUpScore(strumtime:Float, daNote:Note, playerOne:Bool, forceMiss:Bool = false):Void
	{
		var noteDiff:Float = Math.abs(Conductor.songPosition - daNote.strumTime);
		var noteDiffSigned:Float = Conductor.songPosition - daNote.strumTime;
		var wife:Float = HelperFunctions.wife3(noteDiffSigned, Conductor.timeScale);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;
		camZooming = true;
		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;

		coolText.x += judOffsetX;
		coolText.y += judOffsetY;

		
		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";
		if (daNote.mineNote)
			// make note diff sussy and harder to hit because mine notes are weird champ
			noteDiff *= 1.9;
		if (daNote.nukeNote)
			noteDiff *= 3;
		daNote.rating = Ratings.CalculateRating(noteDiff);
		daRating = daNote.rating;
		trace(daRating);
		var healthBonus = 0.0;
		// you can't really control how you hit sustains so always make em sick
		if (daNote.isSustainNote || demoMode) {
			daRating = 'sick';
		}
		if (forceMiss) {
			daRating = 'miss';
		}
		if (OptionsHandler.options.accuracyMode == Complex)
			totalNotesHit += wife;
		
		// SHIT IS A COMBO BREAKER IN ETTERNA NERDS
		// GIT GUD
		var dontCountNote = daNote.dontCountNote;
		if (!daNote.mineNote) {
			switch (daRating)
			{
				case 'shit':
					if (!dontCountNote)
					{
						ss = false;
						shits++;
						
						if (OptionsHandler.options.accuracyMode == Simple)
						{
							totalNotesHit -= 1;
						} 
						misses++;
						setAllHaxeVar("misses", misses);
						score = -300;
						combo = 0;
						setAllHaxeVar("combo", combo);
					}

					// healthBonus -= 0.06 * if (daNote.ignoreHealthMods) 1 else healthLossMultiplier * daNote.damageMultiplier;

				case 'wayoff':
					if (!dontCountNote)
					{
						score = -300;
						combo = 0;
						setAllHaxeVar("combo", combo);
						misses++;
						setAllHaxeVar("misses", misses);
						ss = false;
						shits++;
						if (OptionsHandler.options.accuracyMode == Simple)
						{
							totalNotesHit -= 1;
						}
					}

					// healthBonus -= 0.06 * if (daNote.ignoreHealthMods) 1 else healthLossMultiplier * daNote.damageMultiplier;

				case 'bad':
					if (!dontCountNote)
					{
						score = 0;
						ss = false;
						bads++;
						if (OptionsHandler.options.accuracyMode == Simple)
						{
							totalNotesHit += 0.50;
						}
						else if (OptionsHandler.options.accuracyMode == Binary)
						{
							totalNotesHit += 1;
						}
					}
					daRating = 'bad';

					// healthBonus -= 0.03 * if (daNote.ignoreHealthMods) 1 else healthLossMultiplier * daNote.damageMultiplier;

				case 'good':
					if (!dontCountNote)
					{
						score = 200;
						ss = false;
						goods++;
						if (OptionsHandler.options.accuracyMode == Simple)
						{
							totalNotesHit += 0.75;
						}
						else if (OptionsHandler.options.accuracyMode == Binary)
						{
							totalNotesHit += 1;
						}
					}
					daRating = 'good';

					// healthBonus += 0.03 * if (daNote.ignoreHealthMods) 1 else healthGainMultiplier * daNote.healMultiplier;

				case 'sick':
					// healthBonus += 0.07 * if (daNote.ignoreHealthMods) 1 else healthGainMultiplier * daNote.healMultiplier;
					if (!dontCountNote)
					{
						// if it be binary or not
						// it shall be a 1
						if (OptionsHandler.options.accuracyMode == Simple)
						{
							totalNotesHit += 1;
						}
						else if (OptionsHandler.options.accuracyMode == Binary)
						{
							totalNotesHit += 1;
						}
						sicks++;
					}

					if (!daNote.isSustainNote && OptionsHandler.options.showSplashes)
					{
						var recycledNote = grpNoteSplashes.recycle(NoteSplash);
						recycledNote.setupNoteSplash(daNote.x, daNote.y, daNote.noteData);
						grpNoteSplashes.add(recycledNote);
					}

				case 'miss':
					// noteMiss(daNote.noteData, playerOne);
					// healthBonus = -0.04 * if (daNote.ignoreHealthMods) 1 else healthLossMultiplier * daNote.damageMultiplier;
					if (!dontCountNote)
					{
						misses++;
						setAllHaxeVar("misses", misses);
						if (OptionsHandler.options.accuracyMode == Simple)
						{
							totalNotesHit -= 1;
						}
						ss = false;
						score = -5;
					}
			}
		}

		if (daNote.nukeNote && daRating != 'miss')
			// die <3
			healthBonus = -4;
		healthBonus = daNote.getHealth(daRating);
		if (daNote.dontEdit)
			trace(healthBonus);
		if (daNote.isSustainNote) {
			healthBonus  *= 0.2;
		}
		if (!playerOne)
			health -= healthBonus;
		else
			health += healthBonus;
		updateAccuracy();
		if (daNote.isSustainNote) {
			return;
		}
		if (notesHit > notesPassing) {
			notesHit = notesPassing;
		}

		if (!dontCountNote) {
			songScore += Math.round(ConvertScore.convertScore(noteDiff));
			songScoreDef += Math.round(ConvertScore.convertScore(noteDiff));
			trueScore += Math.round(ConvertScore.convertScore(noteDiff));
		}
		comboBreak(daNote.noteData % Main.ammo[mania], playerOne, daRating);

		setAllHaxeVar('songScore', songScore);
		setAllHaxeVar('songScoreDef', songScoreDef);
		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */
		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';
		if (uiSmelly.isPixel) {
			pixelShitPart2 = '-pixel';
		}
		var ratingImage:BitmapData;
		ratingImage = FNFAssets.getBitmapData(SUtil.getPath() + 'assets/images/custom_ui/ui_packs/' + uiSmelly.uses + '/' + daRating + pixelShitPart2 + ".png");
		trace(pixelUI);
		rating = new Judgement(0, 0, daRating, preferredJudgement,
			noteDiffSigned < 0, pixelUI);
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		if (OptionsHandler.options.newJudgementPos) {
			rating.cameras = [camHUD];
			rating.y = 0;
			rating.x = 0;
			if (!downscroll) {
				rating.y = FlxG.height - rating.height;
			}
			
		}
		rating.y += judOffsetY;
		rating.x += judOffsetX;
		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(ratingImage);
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;
		comboSpr.y += judOffsetY;
		comboSpr.x += judOffsetX;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);
		rating.setGraphicSize(Std.int(rating.width * 0.7));

		var msTiming = HelperFunctions.truncateFloat(noteDiffSigned, 3);
		if (FlxG.save.data.botplay)
			msTiming = 0;
		
		timeShown = 0;

		if (OptionsHandler.options.showNoteMsCounter)
		{
			if (currentTimingShown != null)
				remove(currentTimingShown);

			currentTimingShown = new FlxText(0, 0, 0, "0ms");
			switch (daRating)
			{
				case 'miss':
					currentTimingShown.color = FlxColor.MAGENTA;
				case 'shit' | 'bad' | 'wayoff':
					currentTimingShown.color = FlxColor.RED;
				case 'good':
					currentTimingShown.color = FlxColor.GREEN;
				case 'sick':
					currentTimingShown.color = FlxColor.CYAN;
			}
			currentTimingShown.borderStyle = OUTLINE;
			currentTimingShown.borderSize = 1;
			currentTimingShown.borderColor = FlxColor.BLACK;
			currentTimingShown.text = msTiming + "ms";
			currentTimingShown.size = 20;


			if (currentTimingShown.alpha != 1)
				currentTimingShown.alpha = 1;

			if (!demoMode)
				add(currentTimingShown);
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if(combo >= 1000) {
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		//seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(Math.floor((combo / 10) % 10));
		seperatedScore.push(combo % 10);

		if (OptionsHandler.options.showNoteMsCounter)
		{
			currentTimingShown.screenCenter();
			currentTimingShown.x = comboSpr.x + 100;
			currentTimingShown.y = rating.y + 100;
			currentTimingShown.acceleration.y = 600;
			currentTimingShown.velocity.y -= 150;
		}

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numImage:BitmapData;
			if (FNFAssets.exists(SUtil.getPath() + 'assets/images/custom_ui/ui_packs/' + uiSmelly.uses + '/num' + Std.int(i) + pixelShitPart2 + ".png"))
				numImage = FNFAssets.getBitmapData(SUtil.getPath() + 'assets/images/custom_ui/ui_packs/' + uiSmelly.uses + '/num' + Std.int(i) + pixelShitPart2 + ".png");
			else
				numImage = FNFAssets.getBitmapData(SUtil.getPath() + 'assets/images/num' + Std.int(i) + '.png');
			var numScore:FlxSprite = new FlxSprite().loadGraphic(numImage);
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;
			numScore.x += judOffsetX;
			numScore.y += judOffsetY;

			if (!pixelUI)
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
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}

		if (OptionsHandler.options.showNoteMsCounter)
			currentTimingShown.cameras = [camHUD];

		/*
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001,
			onUpdate: function(tween:FlxTween)
			{
				if (currentTimingShown != null)
					currentTimingShown.alpha -= 0.02;
				timeShown++;
			},
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
				if (currentTimingShown != null && timeShown >= 20)
				{
					remove(currentTimingShown);
					currentTimingShown = null;
				}
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
		if (daNote.nukeNote && daRating != 'miss')
		{
			if (!playerOne)
				health = 69;
			else
				health = -69;
		}
	}
	function updateAccuracy()
	{
		totalPlayed += 1;
		accuracy = Math.max(0, totalNotesHit / totalPlayed * 100);
		accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);
		setAllHaxeVar('accuracy', accuracy);
	}
	private function keyShit(?playerOne:Bool=true):Void
	{
		// HOLDING
		var coolControls = playerOne ? controls : controlsPlayerTwo;
		var up = coolControls.UP;
		var right = coolControls.RIGHT;
		var down = coolControls.DOWN;
		var left = coolControls.LEFT;

		var sH = [
			controls.A1,
			controls.A2,
			controls.A3,
			controls.A5,
			controls.A6,
			controls.A7
		];

		var vH = [
			controls.A1,
			controls.A2,
			controls.A3,
			controls.A4,
			controls.A5,
			controls.A6,
			controls.A7
		];

		var nH = [
			controls.B1,
			controls.B2,
			controls.B3,
			controls.B4,
			controls.B5,
			controls.B6,
			controls.B7,
			controls.B8,
			controls.B9
		];


		var sP = [
			controls.A1_P,
			controls.A2_P,
			controls.A3_P,
			controls.A5_P,
			controls.A6_P,
			controls.A7_P
		];

		var vP = [
			controls.A1_P,
			controls.A2_P,
			controls.A3_P,
			controls.A4_P,
			controls.A5_P,
			controls.A6_P,
			controls.A7_P
		];

		var nP = [
			controls.B1_P,
			controls.B2_P,
			controls.B3_P,
			controls.B4_P,
			controls.B5_P,
			controls.B6_P,
			controls.B7_P,
			controls.B8_P,
			controls.B9_P
		];


		var sR = [
			controls.A1_R,
			controls.A2_R,
			controls.A3_R,
			controls.A5_R,
			controls.A6_R,
			controls.A7_R
		];

		var vR = [
			controls.A1_R,
			controls.A2_R,
			controls.A3_R,
			controls.A4_R,
			controls.A5_R,
			controls.A6_R,
			controls.A7_R
		];

		var nR = [
			controls.B1_R,
			controls.B2_R,
			controls.B3_R,
			controls.B4_R,
			controls.B5_R,
			controls.B6_R,
			controls.B7_R,
			controls.B8_R,
			controls.B9_R
		];

		var upP = coolControls.UP_P;
		var rightP = coolControls.RIGHT_P;
		var downP = coolControls.DOWN_P;
		var leftP = coolControls.LEFT_P;

		var upR = coolControls.UP_R;
		var rightR = coolControls.RIGHT_R;
		var downR = coolControls.DOWN_R;
		var leftR = coolControls.LEFT_R;

		var holdArray = [left, down, up, right];
		var releaseArray = [leftR, downR, upR, rightR];
		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];

		switch (mania)
		{
			case 1:
				controlArray = sP;
				releaseArray = sR;
				holdArray = sH;
			case 2:
				controlArray = vP;
				releaseArray = vR;
				holdArray = vH;
			case 3:
				controlArray = nP;
				releaseArray = nR;
				holdArray = nH;
		}
		
		var pressArray = controlArray;

		// FlxG.watch.addQuick('asdfa', upP);
		var actingOn:Character = playerOne ? boyfriend : dad;
		// <3 easy way of doing it
		if (controlArray.contains(true) && !actingOn.stunned && generatedMusic)
		{
			actingOn.holdTimer = 0;

			var possibleNotes:Array<Note> = [];
			var directionList:Array<Int> = [];
			var dumbNotes:Array<Note> = [];
			var ignoreList:Array<Int> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				var coolShouldPress = playerOne ? daNote.mustPress : !daNote.mustPress;
				if (daNote.canBeHit && coolShouldPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isLiftNote)
				{
					// the sorting probably doesn't need to be in here? who cares lol
					if (directionList.contains(daNote.noteData)) {
						for (coolNote in possibleNotes) {
							if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10) {
								dumbNotes.push(daNote);
								break;
							} else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime) {
								possibleNotes.remove(coolNote);
								possibleNotes.push(daNote);
								break;
							}
						}
					} else  {
						possibleNotes.push(daNote);
						directionList.push(daNote.noteData);
					}

				}
			});
			for (note in 0...dumbNotes.length)
			{
				if (!dumbNotes[note].isSustainNote)
				{
					FlxG.log.add("killing dumb ass note at " + dumbNotes[note].strumTime);
					dumbNotes[note].kill();
					notes.remove(dumbNotes[note], true);
					dumbNotes[note].destroy();
				}
			}
			possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

			var dontCheck = false;

			for (i in 0...pressArray.length)
			{
				if (pressArray[i] && !directionList.contains(i))
					dontCheck = true;
			}
			if (possibleNotes.length > 0 && !dontCheck)
			{
				var daNote = possibleNotes[0];

				if (!OptionsHandler.options.useCustomInput) {
					for (shit in 0...pressArray.length)
					{ // if a direction is hit that shouldn't be
						if (pressArray[shit] && !directionList.contains(shit))
							noteMiss(shit, playerOne);
					}
				}
				
				// Jump notes
				for (coolNote in possibleNotes)
				{
					// even though IT SHOULD BE ABLE TO BE HIT we do this terrible ness
					if (pressArray[coolNote.noteData] && coolNote.canBeHit && !coolNote.tooLate)
					{
						if (mashViolations != 0)
							mashViolations--;
						scoreTxt.color = FlxColor.WHITE;
						if (!coolNote.hittedNote)
							goodNoteHit(coolNote, playerOne);
					}
				}

			}
			else if (!OptionsHandler.options.useCustomInput)
			{
				for (shit in 0...pressArray.length)
					if (pressArray[shit])
						noteMiss(shit, playerOne);
			}
			// :shrug: idk what this for
			if (dontCheck && possibleNotes.length > 0 && OptionsHandler.options.useCustomInput && !demoMode) {
				if (mashViolations > 4)
				{
					trace('mash violations ' + mashViolations);
					scoreTxt.color = FlxColor.RED;
					noteMiss(0, playerOne);
				}
				else
					mashViolations++;
			}
		}
		// lift notes :)
		if (releaseArray.contains(true) && !actingOn.stunned && generatedMusic)
		{
			actingOn.holdTimer = 0;

			var possibleNotes:Array<Note> = [];
			var directionList:Array<Int> = [];
			var dumbNotes:Array<Note> = [];
			var ignoreList:Array<Int> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				var coolShouldPress = playerOne ? daNote.mustPress : !daNote.mustPress;
				if (daNote.canBeHit && coolShouldPress && !daNote.tooLate && !daNote.wasGoodHit && daNote.isLiftNote)
				{
					// the sorting probably doesn't need to be in here? who cares lol
					if (directionList.contains(daNote.noteData))
					{
						for (coolNote in possibleNotes)
						{
							if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
							{
								dumbNotes.push(daNote);
								break;
							}
							else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
							{
								possibleNotes.remove(coolNote);
								possibleNotes.push(daNote);
								break;
							}
						}
					}
					else
					{
						possibleNotes.push(daNote);
						directionList.push(daNote.noteData);
					}
				}
			});
			for (note in 0...dumbNotes.length)
			{
				if (!dumbNotes[note].isSustainNote)
				{
					FlxG.log.add("killing dumb ass note at " + dumbNotes[note].strumTime);
					dumbNotes[note].kill();
					notes.remove(dumbNotes[note], true);
					dumbNotes[note].destroy();
				}
			}
			possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

			var dontCheck = false;

			for (i in 0...releaseArray.length)
			{
				if (releaseArray[i] && !directionList.contains(i))
					dontCheck = true;
			}
			if (possibleNotes.length > 0 && !dontCheck)
			{
				var daNote = possibleNotes[0];
				/*
				if (!OptionsHandler.options.useCustomInput)
				{
					for (shit in 0...releaseArray.length)
					{ // if a direction is hit that shouldn't be
						if (releaseArray[shit] && !directionList.contains(shit))
							noteMiss(shit, playerOne);
					}
				}
				*/
				//	 Jump notes
				for (coolNote in possibleNotes)
				{
					if (releaseArray[coolNote.noteData])
					{
						if (mashViolations != 0)
							mashViolations--;
						scoreTxt.color = FlxColor.WHITE;
						if (!coolNote.hittedNote)
							goodNoteHit(coolNote, playerOne);
					}
				}
			}
			/*
			else if (!OptionsHandler.options.useCustomInput)
			{
				for (shit in 0...releaseArray.length)
					if (releaseArray[shit])
						noteMiss(shit, playerOne);
			}
			*/
			// :shrug: idk what this for
			if (dontCheck && possibleNotes.length > 0 && OptionsHandler.options.useCustomInput && !demoMode)
			{
				if (mashViolations > 4)
				{
					trace('mash violations ' + mashViolations);
					scoreTxt.color = FlxColor.RED;
					noteMiss(0, playerOne);
				}
				else
					mashViolations++;
			}
		}
		if (holdArray.contains(true) && !actingOn.stunned && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				var coolShouldPress = playerOne ? daNote.mustPress : !daNote.mustPress;
				var daRating = Ratings.CalculateRating(Math.abs(daNote.strumTime - Conductor.songPosition));
				// make sustain notes act
				// changing it to sick :blush:
				if (daNote.canBeHit && coolShouldPress && daNote.isSustainNote && ( daRating == 'sick'))
				{
					if (holdArray[daNote.noteData] && !daNote.hittedNote)
						goodNoteHit(daNote, playerOne);
				}
			});
		}
		if (actingOn.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !holdArray.contains(true))
		{
			if (actingOn.animation.curAnim.name.startsWith('sing') && !actingOn.animation.curAnim.name.endsWith('miss'))
			{
				actingOn.dance();
				trace("idle from non miss sing");
			}
		}
		var strums = playerOne ? playerStrums : enemyStrums;
		strums.forEach(function(spr:StrumNote)
		{
			if (controlArray[spr.ID] && spr != null && spr.animation.curAnim.name != 'confirm'){
				spr.playAnim('pressed');
			spr.resetAnim = 0;
			}
			if (releaseArray[spr.ID]){
				if(spr != null)
					{
						spr.playAnim('static');
						spr.resetAnim = 0;
					}
				}
			
		});
	}
	var mashing:Int = 0;
	var mashViolations:Int = 0;
	function noteMiss(direction:Int = 1, playerOne:Bool, ?note:Null<Note>):Void
	{
		var actingOn = playerOne ? boyfriend : dad;
		var onActing = playerOne ? dad : boyfriend;
		if (!actingOn.stunned)
		{
			misses += 1;
			setAllHaxeVar("misses", misses);
			
			var healthBonus = -0.04 * healthLossMultiplier;
			if (note != null) {
				healthBonus = note.getHealth('miss');
			}
			if (playerOne)
				health += healthBonus;
			else
				health -= healthBonus;
			if (combo > 5 && gf.gfEpicLevel >= EpicLevel.Level_Sadness)
			{
				gf.playAnim('sad');
			}
			updateAccuracy();
			combo = 0;
			setAllHaxeVar("combo", combo);
			if (!practiceMode) {
				songScore -= 5;

			}
			setAllHaxeVar('songScore', songScore);
			trueScore -= 5;
			FlxG.sound.play(SUtil.getPath() + 'assets/sounds/missnote' + FlxG.random.int(1, 3) + TitleState.soundExt, FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(SUtil.getPath() + 'assets/sounds/missnote1' + TitleState.soundExt, 1, false);
			// FlxG.log.add('played imss note');

			actingOn.stunned = true;

			// get stunned for 5 seconds
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
			{
				actingOn.stunned = false;
			});
			if (note == null || note.shouldBeSung) {
				actingOn.sing(direction, true);
				if (note != null && note.oppntSing != null) {
					onActing.sing(note.oppntSing.direction, note.oppntSing.miss, note.oppntSing.alt);
				}
			}
				
			if (playerOne) {
				callAllHScript("playerOneMiss", []);
			} else {
				callAllHScript("playerTwoMiss", []);
			}

			if (note != null)
			{
				var daData = Math.round(Math.abs(note.noteData));
				callAllHScript("noteMiss", [note, daData, note.coolId, note.isSustainNote, playerOne]);
			}
		}
	}

	function badNoteCheck(?playerOne:Bool=true)
	{
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		var coolControls = playerOne ? controls : controlsPlayerTwo;
		var upP = coolControls.UP_P;
		var rightP = coolControls.RIGHT_P;
		var downP = coolControls.DOWN_P;
		var leftP = coolControls.LEFT_P;

		if (leftP)
			noteMiss(0, playerOne);
		if (downP)
			noteMiss(1, playerOne);
		if (upP)
			noteMiss(2,playerOne);
		if (rightP)
			noteMiss(3,playerOne);
	}

	function noteCheck(keyP:Bool, note:Note, playerOne:Bool):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

		note.rating = Ratings.CalculateRating(noteDiff);
		if (keyP)
			if (!note.hittedNote)
				goodNoteHit(note,playerOne);
		else
		{
			badNoteCheck(playerOne);
		}
	}

	function goodNoteHit(note:Note, playerOne:Bool):Void
	{
		var actingOn = playerOne ? boyfriend : dad;
		var onActing = playerOne ? dad : boyfriend;
		if (!note.canBeHit || note.tooLate)
			return;
		if (!note.isSustainNote)
			notesHitArray.push(Date.now());
		if (!note.wasGoodHit)
		{
			trace("<3 was good hit");
			actingOn.altAnim = "";
			actingOn.altNum = 0;
			
			/*
			if (SONG.notes[Math.floor(curStep / 16)] != null)
			{
				if (( SONG.notes[Math.floor(curStep / 16)].altAnimNum != null && SONG.notes[Math.floor(curStep / 16)].altAnimNum > 0)
					|| SONG.notes[Math.floor(curStep / 16)].altAnim)
					// backwards compatibility shit
					if (SONG.notes[Math.floor(curStep / 16)].altAnimNum == 1
						|| SONG.notes[Math.floor(curStep / 16)].altAnim)
						actingOn.altNum = 1;
					else if (SONG.notes[Math.floor(curStep / 16)].altAnimNum > 1)
						actingOn.altNum = SONG.notes[Math.floor(curStep / 16)].altAnimNum;
			}*/
			
			if (note.altNote)
				actingOn.altNum = 1;
				
			actingOn.altNum = note.altNum;
			
			if (actingOn.altNum == 1)
			{
				actingOn.altAnim = '-alt';
			}
			else if (actingOn.altNum > 1)
			{
				actingOn.altAnim = '-' + actingOn.altNum + 'alt';
			}
			// We pop it up even for sustains, just to update score. We don't actually show anything.
			trace("<3 pop up score");
			if (!note.dontCountNote)
				notesPassing += 1;
			popUpScore(note.strumTime, note, playerOne);
			if (!note.isSustainNote) {
				combo += 1;
				if (combo > 9999)
					combo = 9999;

				setAllHaxeVar("combo", combo);
			}
			
			if (note.noteData >= 0)
				health += 0.01 * healthGainMultiplier;
			else
				health += 0.005 * healthGainMultiplier;

			if (note.shouldBeSung) {
				actingOn.sing(note.noteData, false, actingOn.altNum);
				// callAllHScript("noteHit", [playerOne, note, goodhit]);

				if (note.oppntSing != null) {
					onActing.sing(note.oppntSing.direction, note.oppntSing.miss, note.oppntSing.alt);
				}
			}

			if (note.specialSinger != null) {
				note.specialSinger.sing(note.noteData, false, actingOn.altNum);
			}

			if (OptionsHandler.options.hitSounds){
				FlxG.sound.play(FNFAssets.getSound(SUtil.getPath() + "assets/sounds/hitSound.ogg"));
			}
			if (playerOne)
			{
				callAllHScript("playerOneSing", []);
			}
			else
			{
				callAllHScript("playerTwoSing", []);
			}

			var strums = playerOne ? playerStrums : enemyStrums;
			strums.forEach(function(spr:StrumNote)
				{
					if (Math.abs(note.noteData) == spr.ID)
					{
						spr.playAnim('confirm', true);
					}
				});
			
			var daData = Math.round(Math.abs(note.noteData));
			callAllHScript("goodNoteHit", [note, daData, note.coolId, note.isSustainNote, playerOne]);

			if (note.crossFade)
			{
				makeCrossfades(playerOne);
			}

			note.wasGoodHit = true;
			var goodhit = note.wasGoodHit;
			vocals.volume = 1;
			if (playerOne)
			{
				player1GoodHitSignal.trigger(note);
			}
			else
			{
				player2GoodHitSignal.trigger(note);
			}
			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
			
		}

		note.hittedNote = true;
	}

	function StrumPlayAnim(isOpp:Bool, id:Int, time:Float,isNormal:Bool) {
		var spr:StrumNote = null;
		var strums = isNormal ? playerStrums : enemyStrums;
		var strumsOpp = isNormal ? enemyStrums : playerStrums;
		if(isOpp) {
			spr = strumsOpp.members[id];
		} else {
			spr = strums.members[id];
		}

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}
	override function stepHit()
	{
		super.stepHit();
		if (SONG.needsVoices)
		{
			//if (vocals.time > Conductor.songPosition + 20 || vocals.time < Conductor.songPosition - 20)
			//{
			//	resyncVocals();
			//}
			if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
				|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 20))
			{
				resyncVocals();
			}
		}

		setAllHaxeVar("curStep", curStep);
		callAllHScript("stepHit", [curStep]);

		songLength = FlxG.sound.music.length;

		/*if (useSongBar && songPosBar.max == 69695969) {
			remove(songPosBG);
			remove(songPosBar);
			remove(songName);

			songPosBG = new FlxSprite(0, 10).loadGraphic(SUtil.getPath() + 'assets/images/healthBar.png');
			if (downscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);
			songPosBG.cameras = [camHUD];
			if (FlxG.sound.music.length == 0)
			{
				songLength = 69696969;
			}
			songPosBar = new FlxBar(songPosBG.x
				+ 4, songPosBG.y
				+ 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, songLength
				- 1000);
			songPosBar.numDivisions = 1000;
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);
			songPosBar.cameras = [camHUD];

			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - 20, songPosBG.y, 0, SONG.song, 16);
			if (downscroll)
				songName.y -= 3;
			songName.setFormat(SUtil.getPath() + "assets/fonts/vcr.ttf", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);
			songName.cameras = [camHUD];
			
		}*/
		#if desktop
		// Song duration in a float, useful for the time left feature
		

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"Acc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC,true,
			songLength
			- Conductor.songPosition, playingAsRpc);
		#end
	}


	override function beatHit()
	{
		super.beatHit();
		
		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
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
			if (!dad.animation.curAnim.name.startsWith("sing") && ((!duoMode && !opponentPlayer) || demoMode))
				dad.dance();
			if (!boyfriend.animation.curAnim.name.startsWith("sing") && (opponentPlayer || demoMode))
				boyfriend.dance();
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		
		if (!endingSong && camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0 && hasDefaultBoom)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));
		practiceDieIcon.setGraphicSize(Std.int(practiceDieIcon.width + 30));
		iconP1.updateHitbox();
		iconP2.updateHitbox();
		practiceDieIcon.updateHitbox();
		if (!gf.animation.curAnim.name.startsWith("sing") && curBeat % gfSpeed == 0)
		{
			gf.dance();
		}
		if (!boyfriend.animation.curAnim.name.startsWith("sing") && !opponentPlayer && !demoMode)
		{
			boyfriend.dance();
		}
		if (dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith("sing") && (duoMode || opponentPlayer) && !demoMode) {
			dad.dance();
		}
		if (curBeat % 8 == 7 && SONG.isHey)
		{
			boyfriend.playAnim('hey', true);

			
		}
		if (curBeat % 8 == 7 && SONG.isCheer && dad.gfEpicLevel >= Character.EpicLevel.Level_Sing)
		{
			dad.playAnim('cheer', true);
		}
		// gf should also cheer?
		if (curBeat % 8 == 7 && SONG.isCheer && gf.gfEpicLevel >= Character.EpicLevel.Level_Sing)
		{
			gf.playAnim('cheer', true);
		}

		setAllHaxeVar('curBeat', curBeat);
		callAllHScript('beatHit', [curBeat]);
	}
	function updatePrecence() {
		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(customPrecence
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end
	}

	public function makeCrossfades(toPlayer:Bool):Void
	{
		var cFd:FlxSprite = new FlxSprite();
		var charID:Character;

		if (toPlayer)
		{
			charID = boyfriend;
		}
		else
		{
			charID = dad;
		}

        cFd.frames = charID.frames;
		cFd.flipX = charID.flipX;
        cFd.animation.copyFrom(charID.animation);
        var animName:String;
		animName = charID.animation.curAnim.name;

        cFd.animation.play(animName, false);

        cFd.updateHitbox();

		if (toPlayer) {
			cFd.setPosition(charID.x - 40, charID.y);
			cFd.velocity.x = 200*FlxG.random.float(1, 1.2);
		} else {
			cFd.setPosition(charID.x + 40, charID.y);
			cFd.velocity.x = -200*FlxG.random.float(0.8, 1.2);
		}

        cFd.offset.set(charID.offset.x, charID.offset.y);

        cFd.antialiasing = true;
        cFd.color = charID.crossFadeColor;
        cFd.alpha = cfIntensity;
		cFd.blend = blendModeFromString(cfBlend);

        grpCrossfades.add(cFd);

        FlxTween.tween(cFd, {alpha: 0}, cfDuration, {onComplete: function (twn:FlxTween) {
            grpCrossfades.remove(cFd, true);
            cFd.destroy();
        }});
	}

}
