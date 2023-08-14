package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import lime.system.System;
import flixel.FlxSprite;
import flixel.FlxCamera;
import lime.utils.Assets;
import Section.SwagSection;
import flixel.system.FlxSound;
import Song.SwagSong;
import flixel.FlxBasic;
import openfl.geom.Matrix;
import flixel.FlxGame;
import flixel.graphics.FlxGraphic;
import DifficultyIcons;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrailArea;
import openfl.filters.ShaderFilter;
import flixel.math.FlxPoint;
import flash.geom.Rectangle;
import Conductor.BPMChangeEvent;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.ui.FlxButton;
import haxe.Json;
import openfl.events.IOErrorEvent;
import flixel.util.FlxSort;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxAxes;
import haxe.io.Bytes;
import flixel.ui.FlxSpriteButton;
import haxe.format.JsonParser;
import flixel.animation.FlxAnimation;
import lime.utils.UInt8Array;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;

#if desktop
import Sys;
import sys.FileSystem;
#end

#if sys
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
import Song.SwagSong;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import flash.media.Sound;
#end

import hscript.Interp;
import hscript.Parser;
import hscript.ParserEx;
import hscript.InterpEx;
import hscript.ClassDeclEx;

import openfl.net.FileReference;
import flixel.util.FlxStringUtil;
import flixel.addons.text.FlxTypeText;
import flixel.input.FlxKeyManager;
import flash.display.BitmapData;
import flixel.graphics.frames.FlxFrame;
#if desktop
import Discord.DiscordClient;
#end
import lime.app.Application;
import openfl.Lib;
import lime.system.Clipboard;
import flixel.addons.ui.FlxUIState;
import lime.ui.FileDialog;
import lime.ui.FileDialogType;

import haxe.Json;
import tjson.TJSON;
using StringTools;
#if mobile
import flixel.input.actions.FlxActionInput;
import android.AndroidControls.AndroidControls;
import android.FlxVirtualPad;
#end
#if VIDEOS_ALLOWED
import hxcodec.flixel.FlxVideo as FlxVideo;
#end
class CustomState extends MusicBeatState
{
	public static var customStateScriptName:String = "";
	public static var customStateScriptPath:String = "";
	
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
			try{
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
	catch(e){
		openfl.Lib.application.window.alert(e.message, "your function had some problem...");
	}
}
	function callAllHScript(func_name:String, args:Array<Dynamic>) {
		for (key in hscriptStates.keys()) {
			callHscript(func_name, args, key);
		}
	}
	function setHaxeVar(name:String, value:Dynamic, usehaxe:String) {
		try{
		hscriptStates.get(usehaxe).variables.set(name,value);
		}
		catch(e){
			openfl.Lib.application.window.alert(e.message, "your variable had some problem...");
		}
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
		interp.variables.set("MainMenuState", MainMenuState);
		interp.variables.set("CategoryState", CategoryState);
		interp.variables.set("ChartingState", ChartingState);
		interp.variables.set("Alphabet", Alphabet);
		interp.variables.set("AnimationDebug", AnimationDebug);
		interp.variables.set("instance", this);
		interp.variables.set("current" + filename, this);
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
		interp.variables.set("DifficultyManager", DifficultyManager);
		interp.variables.set("Controls", Controls);
		interp.variables.set("Map", haxe.ds.StringMap);
		interp.variables.set("Date", Date);
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
		interp.variables.set("controlsPlayerTwo", controlsPlayerTwo);
		interp.variables.set("setKeyScheme", setKeyScheme);
		interp.variables.set("ModifierState", ModifierState);
		interp.variables.set("SortState", SortState);
		interp.variables.set("FlxObject", FlxObject);
		interp.variables.set("Ratings", Ratings);
		interp.variables.set("FlxSort", FlxSort);
		interp.variables.set("VictoryLoopState", VictoryLoopState);
		interp.variables.set("FlxCameraFollowStyle", FlxCameraFollowStyle);
		interp.variables.set("CustomState", CustomState);
		interp.variables.set("DialogueBox", DialogueBox);
		interp.variables.set("EdtNote", EdtNote);
		interp.variables.set("FileParser", FileParser);
		interp.variables.set("FirstTimeState", FirstTimeState);
		interp.variables.set("FlxShaderFix", FlxShaderFix);
		interp.variables.set("FlxUIDropDownMenuCustom", FlxUIDropDownMenuCustom);
		#if VIDEOS_ALLOWED
		interp.variables.set("FlxVideo", FlxVideo);
		#end
		interp.variables.set("FlxTypedGroup", FlxTypedGroup);
		interp.variables.set("GameOverSubstate", GameOverSubstate);
		interp.variables.set("PauseSubState", PauseSubState);
		interp.variables.set("HelperFunctions", HelperFunctions);
		interp.variables.set("Judge", Judge);
		interp.variables.set("Judgement", Judgement);
		interp.variables.set("MenuCharacter", MenuCharacter);
		interp.variables.set("MenuItem", MenuItem);
		interp.variables.set("MusicBeatState", MusicBeatState);
		interp.variables.set("Note", Note);
		interp.variables.set("NoteSplash", NoteSplash);
		interp.variables.set("OptionsHandler", OptionsHandler);
		interp.variables.set("PauseSubState", PauseSubState);
		interp.variables.set("Prompt", Prompt);
		interp.variables.set("Ratings", Ratings);
		interp.variables.set("ConvertScore", ConvertScore);
		interp.variables.set("Record", Record);
		interp.variables.set("SaveFile", SaveFile);
		interp.variables.set("Section", Section);
		interp.variables.set("SelectSongsState", SelectSongsState);
		interp.variables.set("ShaderCustom", ShaderCustom);
		interp.variables.set("Signal", Signal);
		interp.variables.set("Song", Song);
		interp.variables.set("SongInfoPanel", SongInfoPanel);
		interp.variables.set("SortState", SortState);
		interp.variables.set("Song", Song);
		interp.variables.set("FlxFlicker", FlxFlicker);
		interp.variables.set("FlxAxes", FlxAxes);
		interp.variables.set("FlxGridOverlay", FlxGridOverlay);
		interp.variables.set("FlxPoint", FlxPoint);
		interp.variables.set("FlxTrailArea", FlxTrailArea);
		interp.variables.set("ShaderFilter", ShaderFilter);
		interp.variables.set("FlxInputText", FlxInputText);
		interp.variables.set("FlxUI9SliceSprite", FlxUI9SliceSprite);
		interp.variables.set("FlxUI", FlxUI);
		interp.variables.set("FlxUICheckBox", FlxUICheckBox);
		interp.variables.set("FlxUIDropDownMenu", FlxUIDropDownMenu);
		interp.variables.set("FlxUIInputText", FlxUIInputText);
		interp.variables.set("FlxUINumericStepper", FlxUINumericStepper);
		interp.variables.set("FlxUITabMenu", FlxUITabMenu);
		interp.variables.set("FlxButton", FlxButton);
		interp.variables.set("Json", Json);
		interp.variables.set("FlxUI", FlxUI);
		interp.variables.set("FlxSound", FlxSound);
		interp.variables.set("sysTarget", sysTarget);
		interp.variables.set("FlxGridOverlay", FlxGridOverlay);
		interp.variables.set("AttachedSprite", AttachedSprite);
		interp.variables.set("AttachedText", AttachedText);

		#if sys
		interp.variables.set("FileSystem", FileSystem);
		interp.variables.set("IoPath", haxe.io.Path);
		interp.variables.set("IoFile", sys.io.File);
		#end

		interp.variables.set("Interp", Interp);
		interp.variables.set("Parser", Parser);
		interp.variables.set("InterpEx", InterpEx);
		interp.variables.set("ParserEx", ParserEx);
		//interp.variables.set("ClassDeclEx", ClassDeclEx);

		interp.variables.set(SUtil.getPath() + "assets/", Assets);
		interp.variables.set("FlxBasic", FlxBasic);
		interp.variables.set("FlxGame", FlxGame);
		interp.variables.set("IOErrorEvent", IOErrorEvent);
		interp.variables.set("Sys", Sys);
		interp.variables.set("TJSON", TJSON);
		interp.variables.set("FlxGraphic", FlxGraphic);
		interp.variables.set("Rectangle", Rectangle);
		interp.variables.set("Bytes", Bytes);
		interp.variables.set("FlxSpriteButton", FlxSpriteButton);
		interp.variables.set("AudioBuffer", AudioBuffer);
		interp.variables.set("FileReference", FileReference);

		interp.variables.set("FlxStringUtil", FlxStringUtil);
		interp.variables.set("FlxTypeText", FlxTypeText);
		interp.variables.set("FlxKeyManager", FlxKeyManager);
		interp.variables.set("BitmapData", BitmapData);
		interp.variables.set("FlxFrame", FlxFrame);
		interp.variables.set("JsonParser", JsonParser);
		
		#if desktop interp.variables.set("DiscordClient", DiscordClient); #end
		interp.variables.set("FlxState", FlxState);
		interp.variables.set("FlxSubState", FlxSubState);
		interp.variables.set("Application", Application);
		interp.variables.set("Lib", Lib);
		interp.variables.set("Clipboard", Clipboard);
		interp.variables.set("FlxAnimation", FlxAnimation);
		interp.variables.set("FlxUIState", FlxUIState);
		interp.variables.set("FileDialog", FileDialog);
		interp.variables.set("FileDialogType", FileDialogType);
		interp.variables.set("LatencyState", LatencyState);
		interp.variables.set("FlxTransitionableState", FlxTransitionableState);
		interp.variables.set("TransitionData", TransitionData);
		
		// Color Functions
		interp.variables.set("colorFromRGB", colorFromRGB);
		interp.variables.set("colorFromString", colorFromString);
		interp.variables.set("colorFromInt", colorFromInt);
		interp.variables.set("colorFromRBGFloat", colorFromRGBFloat);
		interp.variables.set("colorInterpolate", colorInterpolate);

		//Audio Buffer Functions
		interp.variables.set("dataToBytes", dataToBytes);
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
		try{
			trace("set stuff");
			interp.execute(program);
			hscriptStates.set(usehaxe,interp);
			callHscript("create", [], usehaxe);
			trace('executed');
	}
	catch (e) {
		openfl.Lib.application.window.alert(e.message, "THE CUSTOM STATE CRASHED!");
		LoadingState.loadAndSwitchState(new MainMenuState());
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
	override function create()
	{
		FNFAssets.clearStoredMemory(); //Clean the stored cache to prevent crash
		makeHaxeState("customstate", customStateScriptPath, customStateScriptName); //Load the Custom State :D!!! POWERFULL!!
		super.create();
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		callAllHScript("getEvent", [id, sender, data, params]);
	}

	override function openSubState(SubState:FlxSubState)
	{
		callAllHScript("openSubState", [SubState]);
	}
	
	override function closeSubState()
	{
		callAllHScript("closeSubState", []);

		super.closeSubState();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		callAllHScript("update", [elapsed]);
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

	override function destroy()
	{
		callAllHScript("destroy", [destroy]);
		super.destroy();
	}
	
	public function setKeyScheme(isPlayerOne:Bool = true, mode:String = "solo"):Void
	{
		if (isPlayerOne)
		{
			switch (mode.toLowerCase())
			{
				case "duo-false":
					controls.setKeyboardScheme(Duo(false));
				case "duo-true":
					controls.setKeyboardScheme(Duo(true));
				case "solo-true":
					controls.setKeyboardScheme(Solo(true));
				default:
					controls.setKeyboardScheme(Solo(false));
			}
		}
		else
		{
			switch (mode.toLowerCase())
			{
				case "duo-false":
					controlsPlayerTwo.setKeyboardScheme(Duo(false));
				case "duo-true":
					controlsPlayerTwo.setKeyboardScheme(Duo(true));
				case "solo-true":
					controlsPlayerTwo.setKeyboardScheme(Solo(true));
				default:
					controlsPlayerTwo.setKeyboardScheme(Solo(false));
			}
		}
	}

	public function colorFromRGB(red:Int, green:Int, blue:Int, alpha:Int = 255):FlxColor
	{
		return FlxColor.fromRGB(red, green, blue, alpha);
	}

	public function colorFromString(str:String):FlxColor
	{
		return FlxColor.fromString(str);
	}

	public function colorFromInt(value:Int):FlxColor
	{
		return FlxColor.fromInt(value);
	}

	public function dataToBytes(data:UInt8Array):Bytes
	{
		return data.toBytes();
	}

	public function colorFromRGBFloat(red:Float, green:Float, blue:Float, alpha:Float = 255.0):FlxColor
	{
		return FlxColor.fromRGBFloat(red, green, blue, alpha);
	}

	public function colorInterpolate(color1:FlxColor, color2:FlxColor, factor:Float = 0.5):FlxColor
	{
		return FlxColor.interpolate(color1, color2, factor);
	}
}
