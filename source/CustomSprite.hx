package;
//STILL A WIP! OR NOT IDK LOL.
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxSprite;
import hscript.Expr;
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
import flixel.addons.editors.pex.FlxPexParser;
import flixel.addons.text.FlxTypeText;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
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

class CustomSprite extends DynamicSprite{
    public var interp:Interp = new Interp();
    override public function new(?X:Float = 0, ?Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset, ?ScriptName:String = ''){
        if (ScriptName != null && ScriptName != '')
            interp = initHScript(ScriptName);
        callInterp("init", [this]);
        callInterp("onCreate", [this]);
        super(X, Y,SimpleGraphic);
    }
    public function initHScript(name:String){
        var interp = PluginManager.createSimpleInterp();
		var parser = new hscript.Parser();
		var program:Expr = null;
        if (FNFAssets.exists('assets/scripts/custom_sprites/' + name, Hscript))
			program = parser.parseString(FNFAssets.getHscript('assets/scripts/custom_sprites/' + name));

		interp.variables.set("hscriptPath", 'assets/images/custom_sprites/' + name + '/');
        interp.variables.set("angle", angle);
        interp.variables.set("x", x);
        interp.variables.set("y", y);
        interp.variables.set("color", color);
        interp.variables.set("pixels", pixels);
        interp.variables.set("frame", frame);
        interp.variables.set("frameWidth", frameWidth);
        interp.variables.set("frameHeight", frameHeight);
        interp.variables.set("numFrames", numFrames);
        interp.variables.set("frames", frames);
        interp.variables.set("graphic", graphic);
        interp.variables.set("bakedRotationAngle", bakedRotationAngle);
        interp.variables.set("alpha", alpha);
        interp.variables.set("facing", facing);
        interp.variables.set("flipX", flipX);
        interp.variables.set("flipY", flipY);
        interp.variables.set("origin", origin);
        interp.variables.set("offset", offset);
        interp.variables.set("scale", scale);
        interp.variables.set("this", this);
        interp.variables.set("blend", blend);
        interp.variables.set("colorTransform", colorTransform);
        interp.variables.set("useColorTransform", useColorTransform);
        interp.variables.set("clipRect", clipRect);
        interp.variables.set("shader", shader);
        interp.variables.set("pixels", pixels);
        interp.variables.set("dirty", dirty);
        interp.variables.set("antialiasing", antialiasing);
        interp.variables.set("useFramePixels", useFramePixels);
        interp.variables.set("framePixels", framePixels);
        interp.variables.set("animation", animation);
        interp.variables.set("getFrames", getFrames);
        interp.variables.set("dirty", dirty);
        interp.variables.set("mixtex", mixtex);
		interp.execute(program);
		trace(interp);
		return interp;
    }
    function getFrames(){
        return this.frames;
    }
    
    override public function destroy():Void
        {
            callInterp("destroy", [this]);
            super.destroy();
        }
    override public function graphicLoaded():Void
        {
            callInterp("graphicLoaded", [this]);
            super.graphicLoaded();
        }
        override public function setGraphicSize(w:Int = 0,h:Int = 0):Void
            {
                callInterp("setGraphicSize", [this,w,h]);
                super.setGraphicSize(w,h);
            }
        override public function getGraphicMidpoint(?p:FlxPoint):FlxPoint
            {
                callInterp("getGraphicMidpoint", [this]);
                return super.getGraphicMidpoint(p);
            }
            override public function centerOffsets(AdjustPosition:Bool = false):Void
                {
                    callInterp("centerOffsets", [AdjustPosition]);
                    super.centerOffsets(AdjustPosition);
                }
        override public function update(elapsed:Float):Void
            {
                callInterp("update", [elapsed,this]);
                super.update(elapsed);

            }
    override public function loadGraphicFromSprite(Sprite:FlxSprite):FlxSprite
        {
           callInterp("loadGraphicFromSprite", [this,Sprite]);
           return super.loadGraphicFromSprite(Sprite);
        }
    override public function clone():FlxSprite
        {
            callInterp("clone", [this]);
            return super.clone();
        }
    override public function loadGraphic(Graphic:FlxGraphicAsset, Animated:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false, ?Key:String):FlxSprite
        {
            interp.variables.set("graphic",graphic);
            callInterp("loadGraphic", [this,Graphic, Animated, Width, Height, Unique, Key]);
            return super.loadGraphic(Graphic, Animated, Width, Height, Unique, Key);
        }
    override public function loadRotatedGraphic(Graphic:FlxGraphicAsset, Rotations:Int = 16, Frame:Int = -1, AntiAliasing:Bool = false, AutoBuffer:Bool = false,
		?Key:String):FlxSprite 
        {
            callInterp("loadRotatedGraphic", [this,Graphic, Rotations, Frame, AntiAliasing, AutoBuffer, Key]);
            return super.loadRotatedGraphic(Graphic, Rotations, Frame, AntiAliasing, AutoBuffer, Key);
        }
    override public function loadRotatedFrame(Frame:FlxFrame, Rotations:Int = 16, AntiAliasing:Bool = false, AutoBuffer:Bool = false):FlxSprite
        {
            callInterp("loadRotatedFrame", [this, Frame, AntiAliasing, AutoBuffer]);
            return super.loadRotatedFrame(Frame, AntiAliasing, AutoBuffer);
        }
    function callInterp(func_name:String, args:Array<Dynamic>) {
		if (interp == null) return;
		if (!interp.variables.exists(func_name)) return;
		var method = interp.variables.get(func_name);
        Reflect.callMethod(null,method,args);
	}
	function mixtex(frames1:FlxAtlasFrames, frames2:FlxAtlasFrames) {
		for (frame in frames2.frames){
			frames1.pushFrame(frame);
		}
		return frames1;
	}
}