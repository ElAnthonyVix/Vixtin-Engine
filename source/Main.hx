package;

import flixel.FlxGame;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.Lib;
import openfl.display.StageScaleMode;
import flixel.FlxState;
#if typebuild
import plugins.ExamplePlugin;
import plugins.ExamplePlugin.ExampleCharPlugin;
#end

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

	public function new()
	{
		#if typebuild
			// god is dead
			ExamplePlugin;
			ExampleCharPlugin;
		#end
		super();
		#if sys
		cwd = Sys.getCwd();
		#end

		if (OptionsHandler.options.fpsCap != null)
			framerate = OptionsHandler.options.fpsCap;

		if (OptionsHandler.options.showHaxeSplash != null)
			skipSplash = !OptionsHandler.options.showHaxeSplash;

		addChild(new FlxGame(0, 0, initialState, #if (flixel < "5.0.0") 1, #end framerate, framerate, skipSplash, startFullscreen));

		#if !mobile
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
		#end
	}
}
