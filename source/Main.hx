package;

import flixel.FlxGame;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.Lib;
import openfl.display.StageScaleMode;
import flixel.FlxState;
import openfl.events.Event;
import lime.system.System;
import SUtil;
#if CRASH_HANDLER
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
#if desktop
import Discord.DiscordClient;
#end
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
#end
using StringTools;
class Main extends Sprite
{
	public static var ammo:Array<Int> = [4, 6, 7, 9];
	public static var curMusicName:String = "";
	public static var fpsVar:FPS;
	public static var memoryVar:MemoryCounter;
	
	#if (haxe >= "4.0.0")
	public static var globalVars:Map<String, Dynamic> = new Map();
	#else
	public static var globalVars:Map<String, Dynamic> = new Map<String, Dynamic>();
	#end

	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets
	
	#if sys
	public static var cwd:String;
	#end
	public static var path:String = System.applicationStorageDirectory;
	public static function main():Void
		{
			Lib.current.addChild(new Main());
		}
	
		public function new()
		{
			super();

			if (stage != null)
			{
				init();
			}
			else
			{
				addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}
	
		private function init(?E:Event):Void
		{
			if (hasEventListener(Event.ADDED_TO_STAGE))
			{
				removeEventListener(Event.ADDED_TO_STAGE, init);
			}
	
			setupGame();
		}
	
		private function setupGame():Void
		{
			var stageWidth:Int = Lib.current.stage.stageWidth;
			var stageHeight:Int = Lib.current.stage.stageHeight;
	
			if (zoom == -1)
			{
				var ratioX:Float = stageWidth / gameWidth;
				var ratioY:Float = stageHeight / gameHeight;
				zoom = Math.min(ratioX, ratioY);
				gameWidth = Math.ceil(stageWidth / zoom);
				gameHeight = Math.ceil(stageHeight / zoom);
			}

		#if (sys && !mobile)
		cwd = Sys.getCwd();
		#end
		#if mobile
		SUtil.doTheCheck();
		#end
		if (OptionsHandler.options.fpsCap != null)
			framerate = OptionsHandler.options.fpsCap;

		if (OptionsHandler.options.showHaxeSplash != null)
			skipSplash = !OptionsHandler.options.showHaxeSplash;

		addChild(new FlxGame(0, 0, initialState, 1, framerate, framerate, skipSplash, startFullscreen));
		//addChild(new FlxGame(0, 0, TitleState, 1, OptionsHandler.options.fpsCap, OptionsHandler.options.fpsCap, true));


		fpsVar = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsVar);

		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;

		memoryVar = new MemoryCounter(10, 3, 0xFFFFFF);
		addChild(memoryVar);

		if (OptionsHandler.options.showFPS != null)
		{
			fpsVar.visible = OptionsHandler.options.showFPS;
		}

		if (OptionsHandler.options.showMemory != null)
		{
			memoryVar.visible = OptionsHandler.options.showMemory;
		}

		
		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end
	}
		// Code was entirely made by sqirra-rng for their fnf engine named "Izzy Engine", big props to them!!!
	// very cool person for real they don't get enough credit for their work
	#if CRASH_HANDLER
	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = "./crash/" + "Modding Plus_" + dateNow + ".txt";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error + "\n> Crash Handler written by: sqirra-rng";

		if (!FileSystem.exists("./crash/"))
			FileSystem.createDirectory("./crash/");

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		Application.current.window.alert(errMsg, "Error!");

		Sys.exit(1);
	}
	#end
}
