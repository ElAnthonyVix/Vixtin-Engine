package;

import flixel.util.typeLimit.OneOfTwo;
import FreeplayState.JsonMetadata;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import DifficultyIcons;
import lime.system.System;
#if sys
import haxe.io.Path;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import sys.FileSystem;
import flash.media.Sound;
#end

import hscript.Interp;
import hscript.Parser;
import hscript.ParserEx;
import hscript.InterpEx;
import hscript.ClassDeclEx;

import haxe.Json;
import tjson.TJSON;
using StringTools;
#if mobile
import flixel.input.actions.FlxActionInput;
import android.AndroidControls.AndroidControls;
import android.FlxVirtualPad;
#end
class CategoryState extends MusicBeatState
{
	public static var choosingFor:String = "freeplay";

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
		interp.variables.set("SortState", SortState);
		interp.variables.set("varIsString", varIsString);
		interp.variables.set("choosingFor", choosingFor);
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
		openfl.Lib.application.window.alert(e.message, "THE CATEGORY STATE CRASHED!");
		LoadingState.loadAndSwitchState(new PlayState());
	}
}
else
	{
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
	function varIsString(value:Dynamic):Bool
	{
		if (value is String)
			return true;
		else
			return false;
	}

	override function create()
	{
		// it's a js file to make syntax highlighting acceptable
		#if desktop
		// Updating Discord Rich Presence
		Discord.DiscordClient.changePresence("In the Freeplay Menu", null);
		#end
		FNFAssets.clearStoredMemory();
		makeHaxeState("category", "assets/scripts/custom_menus/", "CategoryState");
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
