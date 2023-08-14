package;

import flixel.FlxSprite;
import lime.utils.Assets;
import lime.system.System;
import flash.display.BitmapData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
#if sys
import sys.io.File;
import haxe.io.Path;
import openfl.utils.ByteArray;

import sys.FileSystem;
#end
import haxe.Json;
import haxe.format.JsonParser;
import tjson.TJSON;
using StringTools;
enum abstract IconState(Int) from Int to Int {
	var Normal;
	var Dying;
	var Poisoned;
	var Winning;
}
class HealthIcon extends FlxSprite
{
	var player:Bool = false;
	public var sprTracker:FlxSprite;
	public var iconState(default, set):IconState = Normal;
	public var xAdd:Float = 0;
	public var yAdd:Float = 0;
	public var hasAnim:Bool = false;
	function set_iconState(x:IconState):IconState {

		if (!hasAnim)
		{
			switch (x) {
				case Normal:
					animation.curAnim.curFrame = 0;
				case Dying:
					// if we set it out of bounds it doesn't realy matter as it goes to normal anyway
					animation.curAnim.curFrame = 1;
				case Poisoned:
					// same deal it will go to dying which is good enough
					animation.curAnim.curFrame = 2;
				case Winning:
					// we DO do it here here we want to make sure it isn't silly
					if (animation.curAnim.frames.length >= 4) {
						animation.curAnim.curFrame = 3;
					} else {
						animation.curAnim.curFrame = 0;
					}
			}
		}
		else
		{
			switch (x) {
				case Normal:
					if (animation.curAnim.name != 'normal')
						animation.play('normal', true);
				case Dying:
					// if we set it out of bounds it doesn't realy matter as it goes to normal anyway
					if (animation.curAnim.name != 'losing')
						animation.play('losing', true);
				case Poisoned:
					// same deal it will go to dying which is good enough
					if (animation.curAnim.name != 'poison')
						animation.play('poison', true);
				case Winning:
					// we DO do it here here we want to make sure it isn't silly
					if (animation.curAnim.frames.length >= 4) {
						if (animation.curAnim.name != 'winning')
							animation.play('winning', true);
					} else {
						if (animation.curAnim.name != 'normal')
							animation.play('normal', true);
					}
			}
		}

		return iconState = x;
	}
	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		player = isPlayer;
		super();
		antialiasing = true;
		switchAnim(char);
		scrollFactor.set();

	}
	public function switchAnim(char:String = 'bf') {
		var charJson:Dynamic = CoolUtil.parseJson(FNFAssets.getJson(SUtil.getPath() + "assets/images/custom_chars/custom_chars"));
		var iconJson:Dynamic = CoolUtil.parseJson(FNFAssets.getJson(SUtil.getPath() + "assets/images/custom_chars/icon_only_chars"));
		var iconFrames:Array<Int> = [];
		var isAnimated:Null<Bool>;
		var iconAnimations:Null<Array<String>> = [];
		var boWidth:Null<Int>;
		var boHeight:Null<Int>;

		if (Reflect.hasField(charJson, char))
		{
			iconFrames = Reflect.field(charJson, char).icons;
			isAnimated = Reflect.field(charJson, char).isAnimatedIcon;
			iconAnimations = Reflect.field(charJson, char).iconAnimations;
			boWidth = Reflect.field(charJson, char).iconWidth;
			boHeight = Reflect.field(charJson, char).iconHeight;
		}
		else if (Reflect.hasField(iconJson, char))
		{
			iconFrames = Reflect.field(iconJson, char).frames;
			isAnimated = Reflect.field(iconJson, char).isAnimated;
			iconAnimations = Reflect.field(iconJson, char).animations;
			boWidth = Reflect.field(iconJson, char).width;
			boHeight = Reflect.field(iconJson, char).height;
		}
		else
		{
			iconFrames = [0, 0, 0, 0];
			isAnimated = false;
			iconAnimations = [];
			boWidth = 150;
			boHeight = 150;
		}

		if (isAnimated == null)
			isAnimated = false;

		if (iconAnimations == null || iconAnimations == [])
		{
			iconAnimations = [];
			isAnimated = false;
		}

		if (boWidth == null)
			boWidth = 150;

		if (boHeight == null)
			boHeight = 150;

		hasAnim = isAnimated;

		if (FNFAssets.exists(SUtil.getPath() + 'assets/images/custom_chars/' + char + "/icons.png") && !isAnimated)
		{
			var rawPic:BitmapData = FNFAssets.getBitmapData(SUtil.getPath() + 'assets/images/custom_chars/' + char + "/icons.png");
			loadGraphic(rawPic, true, boWidth, boHeight);
			animation.add('icon', iconFrames, false, player);
		}
		else if (FNFAssets.exists(SUtil.getPath() + 'assets/images/custom_chars/' + char + "/icons.png") && FNFAssets.exists(SUtil.getPath() + 'assets/images/custom_chars/' + char + "/icons.xml") && isAnimated)
		{
			var rawPic:BitmapData = FNFAssets.getBitmapData(SUtil.getPath() + 'assets/images/custom_chars/' + char + "/icons.png");
			var rawXml:String = FNFAssets.getText(SUtil.getPath() + 'assets/images/custom_chars/' + char + "/icons.xml");
			frames = FlxAtlasFrames.fromSparrow(rawPic, rawXml);
			animation.addByPrefix('normal', iconAnimations[0], 24, true, player);
			animation.addByPrefix('losing', iconAnimations[1], 24, true, player);
			animation.addByPrefix('poison', iconAnimations[2], 24, true, player);
			animation.addByPrefix('winning', iconAnimations[3], 24, true, player);
		}
		else
		{
			loadGraphic(SUtil.getPath() + 'assets/images/iconGrid.png', true, 150, 150);
			animation.add('icon', [10, 11, 11, 10], false, player);
			isAnimated = false;
		}

		if (!isAnimated)
		{
			animation.play('icon');
			animation.pause();
		}
	}
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10 + xAdd, sprTracker.y + yAdd - 30);
	}
}
