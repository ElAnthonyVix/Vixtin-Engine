package;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxSprite;
import flxanimate.FlxAnimate;
import flxanimate.frames.FlxAnimateFrames;
/**
 * A sprite that automatically handles loading files dynamically. This is used in hscripts by default.
 * Only overwrites "loadGraphic."
 */
class DynamicSprite extends FlxSprite {
    override public function loadGraphic(Graphic:FlxGraphicAsset, Animated:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false, ?Key:String) {
        if ((Graphic is String)) {
            // show time baby
            var data = FNFAssets.getBitmapData(Graphic);
            return super.loadGraphic(data, Animated, Width, Height, Unique, Key);
        }
        return super.loadGraphic(Graphic, Animated, Width, Height, Unique, Key);
    }
}
class DynamicAnimateFrames{
    public static function fromSparrow(path:FlxSparrow, png:FlxGraphicAsset) {
        if (FNFAssets.exists(path)) {
            path = FNFAssets.getText(path);
        }
        if ((png is String)) {
            // show time again
            png = FNFAssets.getBitmapData(png);
        }
        return FlxAnimateFrames.fromSparrow(path, png);
    }
    public static function fromJson(path:FlxJson, png:FlxGraphicAsset) {
        if (FNFAssets.exists(path)) {
            path = FNFAssets.getText(path);
        }
        if ((png is String)) {
            // show time again
            png = FNFAssets.getBitmapData(png);
        }
        return FlxAnimateFrames.fromJson(path, png);
    }
    public static function fromEdgeAnimate(path:String, png:FlxGraphicAsset){
        if ((png is String)) {
            // show time again
            png = FNFAssets.getBitmapData(png);
        }
        return FlxAnimateFrames.fromEdgeAnimate(path, png);

    }
    public static function fromTextureAtlas(path:String) {
        var returned = FlxAnimateFrames.fromTextureAtlas(path);
		if (!FNFAssets.exists('$path/spritemap.json'))
		{
            trace('spriteMap cannot be found....');
			return null;
		}
        return returned;
    }
}
/**
 * A replacement for FlxAtlasFrames that dynamically handles loading assets.
 * Passed to hscripts by default.
 * Because of how this works only "fromSparrow" and "fromSpriteSheetPAcker is supported."
 */

class DynamicAtlasFrames {
    public static function fromSparrow(png:FlxGraphicAsset, xml:String) {
        if (FNFAssets.exists(xml)) {
            xml = FNFAssets.getText(xml);
        }
        if ((png is String)) {
            // show time again
            png = FNFAssets.getBitmapData(png);
        }
        return FlxAtlasFrames.fromSparrow(png, xml);
    }
    public static function fromSpriteSheetPacker(png:FlxGraphicAsset, txt:String) {
		if (FNFAssets.exists(txt))
		{
			txt = FNFAssets.getText(txt);
		}
		if ((png is String))
		{
			// show time again
			png = FNFAssets.getBitmapData(png);
		}
        return FlxAtlasFrames.fromSpriteSheetPacker(png,txt);
    }
}