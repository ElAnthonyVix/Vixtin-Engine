package;

import OptionsHandler.FullOptions;
import haxe.ds.Option;
import OptionsHandler.TOptions;
import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import lime.utils.Assets;
import Controls.KeyboardScheme;
import OptionsHandler.AccuracyMode;
import hscript.Interp;
import hscript.Parser;
import hscript.ParserEx;
import hscript.InterpEx;
// visual studio code gets pissy when you don't use conditionals
#if sys
import sys.io.File;
#end
import haxe.Json;
import tjson.TJSON;

using StringTools;
typedef TOption = {
	var name:String;
	var intName:String;
	var value:Bool;
	var desc:String;
	var ?ignore:Bool;
	var ?amount:Float;
	var ?defAmount:Float;
	var ?precision:Float;
	var ?max:Float;
	var ?min:Float;
}
class SaveDataState extends MusicBeatState
{
	public static var optionList:Array<TOption>;

	var hscriptStates:Map<String, Interp> = [];
	var exInterp:InterpEx = new InterpEx();
	var haxeSprites:Map<String, FlxSprite> = [];

	#if debug
		var debugTarget = true;
	#else
		var debugTarget = false;
	#end

	#if sys
		var sysTarget = true;
	#else
		var sysTarget = false;
	#end

	function callHscript(func_name:String, args:Array<Dynamic>, usehaxe:String) {
		// if function doesn't exist
		if (!hscriptStates.get(usehaxe).variables.exists(func_name)) {
			trace("Function doesn't exist, silently skipping...");
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
		}
	}
	function callAllHScript(func_name:String, args:Array<Dynamic>) {
		for (key in hscriptStates.keys()) {
			callHscript(func_name, args, key);
		}
	}
	function setHaxeVar(name:String, value:Dynamic, usehaxe:String) {
		hscriptStates.get(usehaxe).variables.set(name,value);
	}
	function getHaxeVar(name:String, usehaxe:String):Dynamic {
		return hscriptStates.get(usehaxe).variables.get(name);
	}
	function setAllHaxeVar(name:String, value:Dynamic) {
		for (key in hscriptStates.keys())
			setHaxeVar(name, value, key);
	}
	function makeHaxeState(usehaxe:String, path:String, filename:String) {
		trace("opening a haxe state (because we are cool :))");
		var parser = new ParserEx();
		var program = parser.parseString(FNFAssets.getHscript(path + filename));
		var interp = PluginManager.createSimpleInterp();
		// set vars
		interp.variables.set("Sys", Sys);
		interp.variables.set("FlxTextBorderStyle", FlxTextBorderStyle);
		interp.variables.set("controls", controls);
		interp.variables.set("MainMenuState", MainMenuState);
		interp.variables.set("CategoryState", CategoryState);
		interp.variables.set("ChartingState", ChartingState);
		interp.variables.set("Alphabet", Alphabet);
		interp.variables.set("curBeat", 0);
		interp.variables.set("currentFreeplayState", this);
		interp.variables.set("add", add);
		interp.variables.set("remove", remove);
		interp.variables.set("insert", insert);
		interp.variables.set("pi", Math.PI);
		interp.variables.set("curMusicName", Main.curMusicName);
		interp.variables.set("Highscore", Highscore);
		interp.variables.set("HealthIcon", HealthIcon);
		interp.variables.set("debugTarget", debugTarget);
		interp.variables.set("sysTarget", sysTarget);
		interp.variables.set("EReg", EReg);
		interp.variables.set("StoryMenuState", StoryMenuState);
		interp.variables.set("FreeplayState", FreeplayState);
		interp.variables.set("CreditsState", CreditsState);
		interp.variables.set("SaveDataState", SaveDataState);
		interp.variables.set("DifficultyIcons", DifficultyIcons);
		interp.variables.set("Keyboard", Tooltip.Platform.Keyboard);
		interp.variables.set("Controls", Controls);
		interp.variables.set("Tooltip", Tooltip);
		interp.variables.set("SongInfoPanel", SongInfoPanel);
		interp.variables.set("DifficultyManager", DifficultyManager);
		interp.variables.set("flixelSave", FlxG.save);
		interp.variables.set("Record", Record);
		interp.variables.set("Math", Math);
		interp.variables.set("Song", Song);
		interp.variables.set("ModifierState", ModifierState);
		interp.variables.set("Reflect", Reflect);
		interp.variables.set("curStep", curStep);
		interp.variables.set("curBeat", curBeat);
		interp.variables.set("colorFromString", FlxColor.fromString);
		interp.variables.set("PlayState", PlayState);
		interp.variables.set("SaveFile", SaveFile);
		interp.variables.set("NumberDisplay", NumberDisplay);
		interp.variables.set("Judge", Judge);
		interp.variables.set("oneshot", FlxTweenType.ONESHOT);
		interp.variables.set("optionList", optionList);
		interp.variables.set("valueIsInt", valueIsInt);
		interp.variables.set("valueIsFloat", valueIsFloat);
		interp.variables.set("makeOptionList", makeOptionList);
		interp.variables.set("FlxTypedSpriteGroup", FlxTypedSpriteGroup);
		interp.variables.set("makeSaveData", makeSaveData);
		interp.variables.set("NewCharacterState", NewCharacterState);
		interp.variables.set("NewStageState", NewStageState);
		interp.variables.set("NewSongState", NewSongState);
		interp.variables.set("NewWeekState", NewWeekState);
		interp.variables.set("SelectSortState", SelectSortState);
		interp.variables.set("CategoryState", CategoryState);
		interp.variables.set("ControlsState", ControlsState);
		
		trace("set stuff");
		interp.execute(program);
		hscriptStates.set(usehaxe,interp);
		callHscript("create", [], usehaxe);
		trace('executed');
	}

	function valueIsInt(value:Dynamic):Bool
	{
		if (value is Int)
			return true;
		else
			return false;
	}

	function valueIsFloat(value:Dynamic):Bool
	{
		if (value is Float)
			return true;
		else
			return false;
	}

	function makeOptionList()
	{
		optionList = [
			{name: "Always Show Cutscenes", intName: "alwaysDoCutscenes", value: false, desc: "Force show cutscenes, even in freeplay"}, 
			{name: "Skip Modifier Menu", value: false, intName: "skipModifierMenu", desc: "Skip the modifier menu"}, 
			{name: "Skip Victory Screen", value: false, intName : "skipVictoryScreen", desc: "Skip the victory screen at the end of songs."},
			{name: "Skip Debug Screen", value: false, intName : "skipDebugScreen", desc: "Skip the warning screen that happens when you enter charting mode."},
			{name: "Downscroll", value: false, intName: "downscroll", desc: "Put da arrows on the bottom and have em scroll down"},
			{name: "Don't mute on miss", intName: "dontMuteMiss", value: false, desc: "When missing notes, don't mute vocals"},
			{name: "Judge", value: false, intName: "judge", desc: "The Judge to use.", amount: cast Judge.Jury.Classic, defAmount: cast Judge.Jury.Classic, max: 10},
			{name: "Ghost Tapping", value: false, intName: "useCustomInput", desc: "Whether to allow spamming"},
			// sorry, always ignore bad timing :penisve:
			/*{name: "Ignore Bad Timing", value: false, intName:"ignoreShittyTiming", desc: "Even with new input on, if you hit a note really poorly, it counts as a miss. This disables that."},*/
			{name: "Show Song Position", value: false, intName: "showSongPos", desc: "Whether to show the song bar."},
			{name: "Style", value: false, intName: "style", desc: "Whether to use fancy style or default to base game."},
			{
				name: "Ignore Unlocks",
				value: false,
				intName: "ignoreUnlocks",
				desc: "Show/Unlock all songs/weeks, even if you haven't met conditions."
			},
			{
				name: "New Judgement Layout",
				value: false,
				intName: "newJudgementPos",
				desc: "Put judgements in a more convenient place."
			},						
			{name: "Overwrite Judgement", value: false, intName: "preferJudgement", desc: "What judgement to display other than default, if any.", defAmount: 0, amount: 0, max: CoolUtil.coolTextFile('assets/data/judgements.txt').length - 1},
			{name: "Emulate Osu Lifts", value: false, intName: "emuOsuLifts", desc: "Whether to add lift notes at the end of sustains to force releasing buttons."},
			{name: "Show Combo Breaks", value: false, intName:"showComboBreaks", desc: "Whether to display any combo breaks by flashing the screen."},
			{name: "Funny Songs", value: false, intName: "stressTankmen", desc: "funny songs"},
			{name: "Use Kade Health", value: false, intName: "useKadeHealth", desc: "Use kade engines health numbers when healing and dealing damage"},
			{name: "Use Miss Stun", value: false, intName: "useMissStun", desc: "Prevent hitting notes for a short time after missing."},
			{name: "Don't Use Vile Rating", value: false, intName: "ignoreVile", desc: "Don't use the \"Vile\" rating"},
			{name: "Offset", value: false, intName: "offset", desc: "How much to offset notes when playing. Can fix some latency issues! Hold Control to scroll faster.", amount: 0, defAmount: 0, max: 1000, min: -1000, precision: 0.1,},
			{name: "Accuracy Mode", value: false, intName: "accuracyMode", desc: "How accuracy is calculated. Complex = uses ms timing, Simple = uses rating only", amount: 0, defAmount: 0, min: -1, max: 2,},
			{name: "Credits", value: false, intName:'credits', desc: "Show the credits!", ignore: true},
			{name: "Sound Test...", value: false, intName: 'soundtest', desc: "Listen to the soundtrack", ignore: true,},
			{name: "Controls...", value: false, intName:'controls', desc:"Edit bindings!", ignore: true,},
			{name: "Hit Sounds", value: false, intName:"hitSounds", desc: "Play a sound when hitting a note"},
			{name: "Fps Cap", value: false, intName: "fpsCap", desc: "What should the max fps be.", amount: 60, defAmount: 60, max: 240, min: 20, precision: 10,},
			{name: "Allow Story Mode", value: false, intName:"allowStoryMode", desc: "Show story mode from the main menu."},
			{name: "Allow Freeplay", value: false, intName:"allowFreeplay", desc: "Show freeplay from the main menu."},
			{name: "Allow Donate Button", value: false, intName:"allowDonate", desc: "Show the donate button from the main menu."},
			#if sys
			{name: "Toggle Title Background", value: true, intName:'titleToggle', desc:"Turn on/off the title screen background.", ignore: true,},
			{name: "Modding Plus Rating Recs", value: false, intName:'ratingColorRecs', desc:"Turn on/off the rating color rectangles on game.",},
			{name: "Show Splashes", value: true, intName:'showSplashes', desc:"Turn on/off the Note Splashes.",},
			{name:"New Character...", value: false, intName:'newchar', desc: "Make a new character!", ignore: true,},
			{name:"New Stage...", value:false, intName:'newstage', desc: "Make a new stage!", ignore: true, },
			{name: "New Song...", value: false, intName:'newsong', desc: "Make a new song!", ignore: true, },
			{name: "New Week...", value: false, intName: 'newweek', desc: "Make a new week!", ignore: true,},
			{name: "Sort...", value: false, intName: 'sort', desc: "Sort some of your current songs/weeks!", ignore : true,}
			#end
		];
	}

	function makeSaveData(allowEdit:Bool, prefSave:Int, useSave:Bool)
	{
		var valui = {
			"allowEditOptions": allowEdit,
			"preferredSave": prefSave,
			"useSaveDataMenu": useSave
		};

		return valui;
	}

	override function create()
	{
		FNFAssets.clearStoredMemory();
		makeHaxeState("savedata", "assets/scripts/custom_menus/", "SaveDataState");	
		super.create();
	}

	override function update(elapsed:Float) 
	{
		super.update(elapsed);
		callAllHScript("update", [elapsed]);
	}

	override function stepHit()
	{
		super.stepHit();
		setAllHaxeVar('curStep', curStep);
		callAllHScript("stepHit", [curStep]);
	}

	override function beatHit()
	{
		super.beatHit();
		setAllHaxeVar('curBeat', curBeat);
		callAllHScript('beatHit', [curBeat]);
	}
}