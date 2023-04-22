package;

import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;

import hscript.Interp;
import hscript.Parser;
import hscript.ParserEx;
import hscript.InterpEx;
import hscript.ClassDeclEx;

#if sys
import sys.io.File;
#end
import haxe.Json;
using StringTools;
typedef TModifierNoName = {
	var value:Bool;
	var conflicts:Array<String>;
	var multi:Float;
	var ?times:Null<Bool>;
	var desc:String;
	var ?amount:Null<Float>;
	var ?defAmount:Null<Float>;
	var ?precision:Null<Float>;
	var ?minimum:Null<Float>;
	var ?maximum:Null<Float>;
	// used for things that give you points in both directions
	var ?absolute:Null<Bool>;
}
typedef TModifier = {
	> TModifierNoName,
	var name:String;
	var internName:String;
	
}
class ModifierState extends MusicBeatState
{

	// use only in this class
	public static var modifiers:Array<TModifier> = [
		{
			name: "",
			internName: "antijank",
			value: false,
			conflicts: [],
			multi: 1,
			times: true,
			desc: ""
		},
		{
			name: "Play",
			internName: "play",
			value: false,
			conflicts: [],
			multi: 1,
			times: true,
			desc: "Play the Funkin Game!"
		},
		{
			name: "Chart...",
			internName: "chart",
			value: false,
			conflicts: [],
			multi: 1,
			times: true,
			desc: "Enter in Chart Mode!"
		},
		{
			name: "Char Select...",
			internName: "charselect",
			value: false,
			conflicts: [],
			multi: 1,
			times: true,
			desc: "You can just select some custom characters"
		},
		{
			name: "Sick Mode",
			internName: "mfc",
			value: false,
			conflicts: [
				"fc",
				"gfc",
				"practice",
				"healthloss",
				"healthgain", "regen", "degen", "poison", "duo", "demo"],
			multi: 3,
			times: true,
			desc: "Instantly fail when you don't get 'Sick'"
		},
		{
			name: "Good Full Combo",
			internName : "gfc",
			value: false,
			conflicts: [
				"mfc",
				"fc",
				"practice",
				"healthloss",
				"healthgain",
				"regen",
				"degen",
				"poison",
				"duo",
				"demo"
			],
			multi : 2.5,
			times: true,
			desc: "Instantly fall if you get worse than 'Good'"
		},
		{
			name: "FC Mode",
			internName: "fc",
			value: false,
			conflicts: [
				"mfc","gfc", "practice", "healthloss", "healthgain", "regen", "degen", "poison", "duo", "demo"],
			multi: 2,
			times: true,
			desc: "Fail when you miss a note, Go for the Perfect!"
		},
		{
			name: "Practice Mode",
			internName: "practice",
			value: false,
			conflicts: ["mfc","gfc", "fc", "duo", "demo"],
			multi: 0,
			times: true,
			desc: "You can't die while you're in practice! (DISABLES SCORE)"
		},
		/*
		{
			name: "Health Gain \\^",
			internName: "hgu",
			value: false,
			conflicts: ["mfc", "fc", 4, 19, 21],
			multi: -0.5,
			desc: "Raise your health gain a little"
		},
		{
			name: "Health Gain \\v",
			internName: "hgd",
			value: false,
			conflicts: [0, 1, 3, 19, 21],
			multi: 0.5,
			desc: "Lower your health gain a little."
		},
		{
			name: "Health Loss \\^",
			internName: "hlu",
			value: false,
			conflicts: [0, 1, 6, 19, 21],
			multi: 0.5,
			desc: "Raise your health loss a little."
		},
		{
			name: "Health Loss \\v",
			internName: "hld",
			value: false,
			conflicts: [0, 1, 5, 19, 21],
			multi: -0.5,
			desc: "Lower your health loss a little."
		},
		*/
		{
			name: "Health Loss",
			internName: "healthloss",
			value:false,
			conflicts: ["mfc", "fc", "gfc"],
			multi: 0.1,
			amount: 1,
			defAmount: 1,
			precision: 0.5,
			minimum: 0,
			maximum: 10,
			desc: "How much health you lose. Can be changed numerically."
		},
		{
			name: "Health Gain",
			internName: "healthgain",
			value: false,
			conflicts: ["mfc", "fc", "gfc"],
			multi: -0.1,
			amount: 1,
			defAmount: 1,
			precision: 0.5,
			minimum: 0,
			maximum: 10,
			desc: "How much health you gain. Can be changed numerically."
		},
		{
			name: "Sup. Love",
			internName: "regen",
			value: false,
			conflicts: ["fc", "mfc", "degen", "duo", "demo", "gfc"],
			multi: -0.03,
			amount: 0,
			defAmount: 0,
			precision: 5,
			minimum: 0,
			maximum: 500,
			desc: "Who knew simping could be so healthy?"
		},
		{
			name: "Poison Fright",
			internName: "degen",
			value: false,
			conflicts: ["fc", "mfc", "duo", "regen", "demo", "gfc"],
			multi: 0.03,
			amount: 0,
			defAmount: 0,
			precision: 5,
			minimum: 0,
			maximum: 500,
			desc: "You are constantly losing health!"
		},
		{
			name: "Fragile Funkin",
			internName: "poison",
			value: false,
			conflicts: ["fc", "mfc", "duo", "demo", "gfc"],
			multi: 1,
			desc: "Missed note makes you lose a lot of health. You wanna have a bad time?"
		},
		{
			name: "Flipped Notes",
			internName: "flipped",
			value: false,
			conflicts: ["invis"],
			multi: 0.5,
			desc: "Notes are flipped"
		},
		{
			name: "Slow Notes",
			internName: "slow",
			value: false,
			conflicts: ["fast", "accel"],
			multi: -0.3,
			desc: "Notes are slow"
		},
		{
			name: "Fast Notes",
			value: false,
			internName: "fast",
			conflicts: ["slow", "accel"],
			multi: 0.8,
			desc: "Notes gotta go fast!"
		},
		{
			name: "Accel Notes",
			internName: "accel",
			value: false,
			conflicts: ["fast", "slow"],
			multi: 0.4,
			desc: "Notes get faster and faster"
		},
		{
			name: "Vnsh Notes",
			internName: "vanish",
			value: false,
			conflicts: ["invis"],
			multi: 0.5,
			desc: "Notes vanish when they get close to the strum line."
		},
		{
			name: "Invs Notes",
			internName: "invis",
			value: false,
			conflicts: ["flipped", "vanish", "snake", "drunk"],
			multi: 1.5,
			desc: "Notes are now invisible! Hard enough for you?"
		},
		{
			name: "Snake Notes",
			internName: "snake",
			value: false,
			conflicts: ["invis"],
			multi: 0.5,
			desc: "Notes smoove across the screen"
		},
		{
			name: "Drunk Notes",
			internName: "drunk",
			value: false,
			conflicts: ["invis"],
			multi: 0.5,
			desc: "Notes be like my dad after a long day at work"
		},
		{
			name: "Stuck in a loop",
			internName: "loop",
			value: false,
			conflicts: ["practice"],
			multi: 0,
			desc: "Insta-replay the level after you die!"
		},
		{
			name: "Duo Mode",
			internName: "duo",
			value: false,
			conflicts: ["mfc", "fc", "gfc", "healthloss", "regen", "degen", "poison", "oppnt", "demo"],
			multi: 0,
			times: true,
			desc: "Boogie with a friend! (FRIEND NOT REQUIRED)"
		},
		{
			name: "Oppnt. Play",
			internName: "oppnt",
			value: false,
			conflicts: ["duo", "demo"],
			multi: 0,
			desc: "Play as the enemy that wanted to beat up Boyfriend!"
		},
		{
			name: "Demo Mode",
			internName: "demo",
			value: false,
			conflicts: ["mfc", "fc","gfc", "healthloss", "regen", "degen", "poison", "oppnt", "duo"],
			multi: 0,
			times: true,
			desc: "Let the game play itself!"
		}
	];
	public static var isStoryMode:Bool = false;
	public static var scoreMultiplier:Float = 1;
	public static var namedModifiers:Dynamic = {};

	var hscriptStates:Map<String, Interp> = [];
	var exInterp:InterpEx = new InterpEx();
	var haxeSprites:Map<String, FlxSprite> = [];

	#if debug
		var debugTarget = true;
	#else
		var debugTarget = false;
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
		interp.variables.set("FlxTextBorderStyle", FlxTextBorderStyle);
		interp.variables.set("MainMenuState", MainMenuState);
		interp.variables.set("CategoryState", CategoryState);
		interp.variables.set("ChartingState", ChartingState);
		interp.variables.set("Alphabet", Alphabet);
		interp.variables.set("instance", this);
		interp.variables.set("add", add);
		interp.variables.set("remove", remove);
		interp.variables.set("insert", insert);
        interp.variables.set("replace", replace);
		interp.variables.set("pi", Math.PI);
		interp.variables.set("curMusicName", Main.curMusicName);
		interp.variables.set("Highscore", Highscore);
		interp.variables.set("HealthIcon", HealthIcon);
		interp.variables.set("debugTarget", debugTarget);
		interp.variables.set("StoryMenuState", StoryMenuState);
		interp.variables.set("FreeplayState", FreeplayState);
		interp.variables.set("CreditsState", CreditsState);
		interp.variables.set("SaveDataState", SaveDataState);
		interp.variables.set("DifficultyIcons", DifficultyIcons);
		interp.variables.set("Controls", Controls);
		interp.variables.set("Tooltip", Tooltip);
		interp.variables.set("SongInfoPanel", SongInfoPanel);
		interp.variables.set("DifficultyManager", DifficultyManager);
		interp.variables.set("flixelSave", FlxG.save);
		interp.variables.set("Record", Record);
		interp.variables.set("Math", Math);
		interp.variables.set("Song", Song);
		interp.variables.set("ModifierState", ModifierState);
        interp.variables.set("ChooseCharState", ChooseCharState);
		interp.variables.set("Reflect", Reflect);
		interp.variables.set("colorFromString", FlxColor.fromString);
		interp.variables.set("PlayState", PlayState);
		interp.variables.set("NewCharacterState", NewCharacterState);
		interp.variables.set("NewStageState", NewStageState);
		interp.variables.set("NewSongState", NewSongState);
		interp.variables.set("NewWeekState", NewWeekState);
		interp.variables.set("SelectSortState", SelectSortState);
		interp.variables.set("CategoryState", CategoryState);
		interp.variables.set("ControlsState", ControlsState);
		interp.variables.set("NumberDisplay", NumberDisplay);
		interp.variables.set("controls", controls);
		interp.variables.set("ModifierState", ModifierState);
		interp.variables.set("FlxTypedGroup", FlxTypedGroup);
		interp.variables.set("modifiers", modifiers);
		interp.variables.set("isStoryMode", isStoryMode);
		interp.variables.set("scoreMultiplier", scoreMultiplier);
		interp.variables.set("namedModifiers", namedModifiers);
		
		trace("set stuff");
		interp.execute(program);
		hscriptStates.set(usehaxe,interp);
		callHscript("create", [], usehaxe);
		trace('executed');
	}

	public static function init() {
		for (modifier in 0...modifiers.length)
		{
			Reflect.setField(namedModifiers, modifiers[modifier].internName, modifiers[modifier]);
		}
	}
	override function create()
	{
		FNFAssets.clearStoredMemory();
		makeHaxeState("modifier", "assets/scripts/custom_menus/", "ModifierState");
		super.create();
	}
	override function update(elapsed:Float) {
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
