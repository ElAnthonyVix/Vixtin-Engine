package;

import lime.app.Promise;
import lime.app.Future;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;

import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;

import haxe.io.Path;

import flixel.text.FlxText;
import flixel.FlxState;
import flixel.FlxG;
// lol
// doesn't actually load anything except fixing menus
class LoadingState extends FlxState {
    public static function loadAndSwitchState(target:FlxState, ?allowDjkf:Bool) {

		PlayerSettings.player1.controls.setKeyboardScheme(Solo(false));
        if ((target is ChartingState)) {
            FlxG.switchState(new LoadingState());
        } else {
			FlxG.switchState(target);
        }
        
    }

    override function create() {
        FlxG.switchState(new ChartingState());
    }

    public static function loadAndSwitchCustomState(scriptName:String, scriptPath:String = 'assets/scripts/custom_menus/')
    {
        if (FNFAssets.exists(scriptPath + scriptName + '.hscript'))
        {
            CustomState.customStateScriptPath = scriptPath;
            CustomState.customStateScriptName = scriptName;
            PlayerSettings.player1.controls.setKeyboardScheme(Solo(false));
            FlxG.switchState(new CustomState());
        }
    }
}