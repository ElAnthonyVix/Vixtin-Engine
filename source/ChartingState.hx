package;

import Section.SwagSection;
import Song.SwagSong;
import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.FlxObject;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import haxe.Json;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;
import lime.system.System;
import flixel.util.FlxSort;
#if sys
import sys.io.File;
import haxe.io.Path;
import sys.FileSystem;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import flash.media.Sound;
import tjson.TJSON;
#end

import hscript.InterpEx;
import hscript.Interp;
import hscript.Parser;
import hscript.ParserEx;
import hscript.ClassDeclEx;

using StringTools;

enum abstract NoteTypes(Int) from Int to Int
{
	@:op(A == B) static function _(_, _):Bool;

	var Normal;
	var Lift;
	var Mine;
	var Death;
}

class ChartingState extends MusicBeatState
{
	public static var lastSection:Int = 0;

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
			case 6:
				method(args[0], args[1], args[2], args[3], args[4], args[5]);
			case 7:
				method(args[0], args[1], args[2], args[3], args[4], args[5], args[6]);
			case 8:
				method(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7]);
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
		interp.variables.set("lastSection", lastSection);
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
		interp.variables.set("SortState", SortState);
		interp.variables.set("FlxObject", FlxObject);
		interp.variables.set("Ratings", Ratings);
		interp.variables.set("VictoryLoopState", VictoryLoopState);
		interp.variables.set("FlxTypedGroup", FlxTypedGroup);
		interp.variables.set("EdtNote", EdtNote);
		interp.variables.set("FlixG", FlxG);
		interp.variables.set("FlxUITabMenu", FlxUITabMenu);
		interp.variables.set("FlxUICheckBox", FlxUICheckBox);
		interp.variables.set("FlxUIDropDownMenuCustom", FlxUIDropDownMenuCustom);
		interp.variables.set("FlxUIInputText", FlxUIInputText);
		interp.variables.set("FlxButton", FlxButton);
		interp.variables.set("Prompt", Prompt);
		interp.variables.set("FlxUINumericStepper", FlxUINumericStepper);
		interp.variables.set("FlxUI", FlxUI);
		interp.variables.set("sysTarget", sysTarget);
		interp.variables.set("FlxSound", FlxSound);
		interp.variables.set("Normal", Normal);
		interp.variables.set("Lift", Lift);
		interp.variables.set("Mine", Mine);
		interp.variables.set("Death", Death);
		interp.variables.set("FlxGridOverlay", FlxGridOverlay);
		interp.variables.set("FlxSort", FlxSort);
		interp.variables.set("AttachedFlxText", AttachedFlxText);
		interp.variables.set("Json", Json);
		interp.variables.set("isNumericStepper", isNumericStepper);
		interp.variables.set("isInputText", isInputText);
		interp.variables.set("Section", Section);
		interp.variables.set("Map", haxe.ds.StringMap);
		interp.variables.set("getStepperTextField", getStepperTextField);
		interp.variables.set("createDefaultTabMenu", createDefaultTabMenu);
		interp.variables.set("openSubState", openSubState);
		interp.variables.set("curStep", curStep);
		interp.variables.set("curBeat", curBeat);
		interp.variables.set("checkBoxEvent", FlxUICheckBox.CLICK_EVENT);
		interp.variables.set("numericStepperEvent", FlxUINumericStepper.CHANGE_EVENT);
		interp.variables.set("inputTextEvent", FlxUIInputText.CHANGE_EVENT);

		#if sys
		interp.variables.set("FileSystem", sys.FileSystem);
		interp.variables.set("IoPath", haxe.io.Path);
		interp.variables.set("readDirectory", readDirectory);
		interp.variables.set("isDirectory", isDirectory);
		#end

		trace("set stuff");
		interp.execute(program);
		hscriptStates.set(usehaxe,interp);
		callHscript("create", [], usehaxe);
		trace('executed');
	}
	
	function isNumericStepper(variable:Dynamic):Bool
	{
		return false;
		
		if (variable is FlxUINumericStepper)
		{
			return true;
		}
	}

	function isInputText(variable:Dynamic):Bool
	{
		return false;
		
		if (variable is FlxUIInputText)
		{
			return true;
		}
	}

	function createMap():Map<String, String>
	{
		var daMap:Map<String, String> = new Map<String, String>();

		return daMap;
	}

	function getStepperTextField(stepper:FlxUINumericStepper):Dynamic
	{
		@:privateAccess
		return stepper.text_field;
	}

	function createDefaultTabMenu(tabs:Dynamic):FlxUITabMenu
	{
		var daBox:FlxUITabMenu = new FlxUITabMenu(null, tabs, true);
		return daBox;
	}

	#if sys
	function readDirectory(directory:String):Array<String>
	{
		return FileSystem.readDirectory(directory);
	}

	function isDirectory(directory:String):Bool
	{
		return FileSystem.isDirectory(directory);
	}
	#end

	override function create()
	{
		FNFAssets.clearStoredMemory();
		makeHaxeState("charting", 'assets/scripts/custom_menus/', 'ChartingState');
		super.create();
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		callAllHScript("getEvent", [id, sender, data, params]);
	}

	override function update(elapsed:Float)
	{
		callAllHScript("update", [elapsed]);
		super.update(elapsed);
	}
	
	override function beatHit()
	{
		super.beatHit();
		setAllHaxeVar('curBeat', curBeat);
		callAllHScript('beatHit', [curBeat]);
	}

	override function stepHit()
	{
		super.stepHit();
		setAllHaxeVar('curStep', curStep);
		callAllHScript("stepHit", [curStep]);
	}
}

class AttachedFlxText extends FlxText
{
	public var sprTracker:FlxSprite;
	public var xAdd:Float = 0;
	public var yAdd:Float = 0;

	public function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true) {
		super(X, Y, FieldWidth, Text, Size, EmbeddedFont);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null) {
			setPosition(sprTracker.x + xAdd, sprTracker.y + yAdd);
			angle = sprTracker.angle;
			alpha = sprTracker.alpha;
		}
	}
}