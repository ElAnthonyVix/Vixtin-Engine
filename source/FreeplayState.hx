package;

import Controls.Action;
import flixel.input.keyboard.FlxKey;
import flixel.tweens.FlxTween;
import flixel.util.FlxGradient;
import Section.SwagSection;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import DifficultyIcons;
import lime.system.System;
#if sys
import sys.io.File;
import haxe.io.Path;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import flixel.system.FlxSound;
import sys.FileSystem;
import flash.media.Sound;
#end
import haxe.Json;
import tjson.TJSON;
using StringTools;

import hscript.Interp;
import hscript.Parser;
import hscript.ParserEx;
import hscript.InterpEx;
#if mobile
import flixel.input.actions.FlxActionInput;
import android.AndroidControls.AndroidControls;
import android.FlxVirtualPad;
#end
class FreeplayState extends MusicBeatState
{
	public static var currentSongList:Array<JsonMetadata> = [];
	public static var soundTest:Bool = false;

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
			if (OptionsHandler.options.allowCrashHandler){
			try{
	
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
else{
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
}

	function callAllHScript(func_name:String, args:Array<Dynamic>) {
		for (key in hscriptStates.keys()) {
			callHscript(func_name, args, key);
		}
	}
	function setHaxeVar(name:String, value:Dynamic, usehaxe:String) {
		if (OptionsHandler.options.allowCrashHandler){
		try{
		hscriptStates.get(usehaxe).variables.set(name,value);
		}
		catch(e){
			openfl.Lib.application.window.alert(e.message, "your variable had some problem...");
		}
	}
	else
		hscriptStates.get(usehaxe).variables.set(name,value);
	}
	function getHaxeVar(name:String, usehaxe:String):Dynamic {
		var theValue = hscriptStates.get(usehaxe).variables.get(name);
		return theValue;
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
		interp.variables.set("controls", controls);
		interp.variables.set("SongMetadata", SongMetadata);
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
		interp.variables.set("NewCharacterState", NewCharacterState);
		interp.variables.set("NewStageState", NewStageState);
		interp.variables.set("NewSongState", NewSongState);
		interp.variables.set("NewWeekState", NewWeekState);
		interp.variables.set("SelectSortState", SelectSortState);
		interp.variables.set("CategoryState", CategoryState);
		interp.variables.set("ControlsState", ControlsState);
		interp.variables.set("setAutoPause", setAutoPause);
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
		if (OptionsHandler.options.allowCrashHandler){
			try{
				trace("set stuff");
				interp.execute(program);
				hscriptStates.set(usehaxe,interp);
				callHscript("create", [], usehaxe);
				trace('executed');
		}
	catch (e) {
		openfl.Lib.application.window.alert(e.message, "THE FREEPLAY STATE CRASHED!");
		LoadingState.loadAndSwitchState(new PlayState());
	}
}else{
	trace("set stuff");
			interp.execute(program);
			hscriptStates.set(usehaxe,interp);
			callHscript("create", [], usehaxe);
			trace('executed');
}
	}

	function addVirtualPads(dPad:String,act:String){
		#if mobile
		addVirtualPad(dPadModeFromString(dPad),actionModeModeFromString(act));
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
	function setAutoPause(to:Bool):Bool
	{
		FlxG.autoPause = to;
		return to;
	}

	override function create()
	{
		FNFAssets.clearStoredMemory();
		
		#if desktop
		// Updating Discord Rich Presence
		var customPrecence = TitleState.discordStuff.freeplay;
		Discord.DiscordClient.changePresence(customPrecence, null);
		#end
		
		makeHaxeState("freeplay", "assets/scripts/custom_menus/", "FreeplayState");		
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
class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
}
typedef JsonMetadata = {
	var name:String;
	var week:Int;
	var character:String;
	var ?flags:Array<String>;
}