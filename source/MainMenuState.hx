package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.utils.Assets;
import lime.app.Application;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxObject;
import flixel.math.FlxMath;
import hscript.Interp;
import hscript.Parser;
import hscript.ParserEx;
import hscript.InterpEx;
import flixel.util.FlxAxes;
#if sys
import sys.io.File;
import haxe.io.Path;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import flash.media.Sound;
import sys.FileSystem;
import Song.SwagSong;
#end
import tjson.TJSON;
using StringTools;

/*
typedef VersionJson = {
	var version: String;
	var name_1: String;
	var name_2: String;
	var name_3: String;
}
*/

	
class MainMenuState extends MusicBeatState
{
	#if !switch
	var switchTarget:Bool = false;
	#else
	var switchTarget:Bool = true;
	#end

	#if !linux
	var linuxTarget:Bool = false;
	#else
	var linuxTarget:Bool = true;
	#end

	public static var version:String = "";

	var hscriptStates:Map<String, Interp> = [];
	var exInterp:InterpEx = new InterpEx();
	var haxeSprites:Map<String, FlxSprite> = [];

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
		interp.variables.set("FlxObject", FlxObject);
		interp.variables.set("FlxTransitionableState", FlxTransitionableState);
		interp.variables.set("MainMenuState", MainMenuState);
		interp.variables.set("CategoryState", CategoryState);
		interp.variables.set("ChartingState", ChartingState);
		interp.variables.set("Alphabet", Alphabet);
		interp.variables.set("curBeat", 0);
		interp.variables.set("currentMainMenuState", this);
		interp.variables.set("add", add);
		interp.variables.set("remove", remove);
		interp.variables.set("insert", insert);
		interp.variables.set("pi", Math.PI);
		interp.variables.set("curMusicName", Main.curMusicName);
		interp.variables.set("switchTarget", switchTarget);
		interp.variables.set("linuxTarget", linuxTarget);
		interp.variables.set("setVersion", setVersion);
		interp.variables.set("FlxFlicker", FlxFlicker);
		interp.variables.set("StoryMenuState", StoryMenuState);
		interp.variables.set("FreeplayState", FreeplayState);
		interp.variables.set("CreditsState", CreditsState);
		interp.variables.set("SaveDataState", SaveDataState);
		interp.variables.set("X", FlxAxes.X);
		interp.variables.set("Application", Application);
		interp.variables.set("togglePersistUpdate", togglePersistUpdate);
		interp.variables.set("togglePersistDraw", togglePersistDraw);
		interp.variables.set("coolURL", coolURL);
		interp.variables.set("flixelSave", FlxG.save);
		
		trace("set stuff");
		interp.execute(program);
		hscriptStates.set(usehaxe,interp);
		callHscript("create", [], usehaxe);
		trace('executed');
	}

	function togglePersistUpdate(toggle:Bool)
	{
		persistentUpdate = toggle;
	}

	function togglePersistDraw(toggle:Bool)
	{
		persistentDraw = toggle;
	}

	function setVersion(text:String):String
	{
		version = text;
		return text;
	}

	function coolURL(url:String):String
	{
		FlxG.openURL(url);
		return url;
	}

	override function create()
	{
		FNFAssets.clearStoredMemory();
		
		#if windows
		// Updating Discord Rich Presence
		var customPrecence = TitleState.discordStuff.mainmenu;
		Discord.DiscordClient.changePresence(customPrecence, null);
		#end

		makeHaxeState("mainmenu", "assets/scripts/custom_menus/", "MainMenuState");

		super.create();
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

		if (hscriptStates.get('mainmenu').variables.exists('beatHit'))
			callAllHScript('beatHit', [curBeat]);
	}
}
