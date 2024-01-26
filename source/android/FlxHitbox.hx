package android;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.ui.FlxButton;
import flixel.FlxSprite;

class FlxHitbox extends FlxSpriteGroup {
	public var hitbox:FlxSpriteGroup;

	public var buttonLeft:FlxButton;
	public var buttonDown:FlxButton;
	public var buttonUp:FlxButton;
	public var buttonRight:FlxButton;
	public var buttonMiddle:FlxButton;
	public var buttonLeft2:FlxButton;
	public var buttonDown2:FlxButton;
	public var buttonUp2:FlxButton;
	public var buttonRight2:FlxButton;

	public var orgAlpha:Float = 0.75;
	public var orgAntialiasing:Bool = true;
	public var mania:Int = 0;
	public var dumbLength:Float = 1280 / 4;
	private static var dumbAssColors:Array<Array<String>> = [['left','down','up','right'],
	['left','up','right','left2','down','right2'],
	['left','up','right','middle','left2','down','right2'],
	['left','down','up','right','middle','left2','down2','up2','right2']
];
private static var lmaoAngel:Array<Array<Int>> = [[0,-90,90,180],
[0,90,180,0,-90,180],
[0,90,180,0,0,-90,180],
[0,-90,90,180,0,0,-90,90,180]
];
	public function new(?alphaAlt:Float = 0.75, ?antialiasingAlt:Bool = true,?curMania:Int = 0) {
		super();

		orgAlpha = alphaAlt;
		orgAntialiasing = antialiasingAlt;
		mania = curMania;
		dumbLength = 1280/Main.ammo[mania];
		buttonLeft = new FlxButton(0, 0);
		buttonDown = new FlxButton(0, 0);
		buttonUp = new FlxButton(0, 0);
		buttonRight = new FlxButton(0, 0);
		buttonMiddle = new FlxButton(0, 0);
		buttonLeft2 = new FlxButton(0, 0);
		buttonDown2 = new FlxButton(0, 0);
		buttonUp2 = new FlxButton(0, 0);
		buttonRight2 = new FlxButton(0, 0);


		hitbox = new FlxSpriteGroup();
		switch (mania){
			case 0:
		hitbox.add(add(buttonLeft = createhitbox(0, 0, "left")));
		hitbox.add(add(buttonDown = createhitbox(dumbLength, 0, "down")));
		hitbox.add(add(buttonUp = createhitbox(dumbLength * 2 , 0, "up")));
		hitbox.add(add(buttonRight = createhitbox(dumbLength * 3, 0, "right")));
            case 1:
		hitbox.add(add(buttonLeft = createhitbox(0, 0, "left")));
		hitbox.add(add(buttonUp = createhitbox(dumbLength , 0, "up")));
		hitbox.add(add(buttonRight = createhitbox(dumbLength * 2, 0, "right")));
		hitbox.add(add(buttonLeft2 = createhitbox(dumbLength * 3, 0, "left2")));
		hitbox.add(add(buttonDown = createhitbox(dumbLength * 4 , 0, "down")));
		hitbox.add(add(buttonRight = createhitbox(dumbLength * 5, 0, "right2")));
		case 2:
			hitbox.add(add(buttonLeft = createhitbox(0, 0, "left")));
			hitbox.add(add(buttonUp = createhitbox(dumbLength , 0, "up")));
			hitbox.add(add(buttonRight = createhitbox(dumbLength * 2, 0, "right")));
			hitbox.add(add(buttonMiddle = createhitbox(dumbLength * 3, 0, "space")));
			hitbox.add(add(buttonLeft2 = createhitbox(dumbLength * 4, 0, "left2")));
			hitbox.add(add(buttonDown = createhitbox(dumbLength * 5 , 0, "down")));
			hitbox.add(add(buttonRight2 = createhitbox(dumbLength * 6, 0, "right2")));
			case 3:
		hitbox.add(add(buttonLeft = createhitbox(0, 0, "left")));
		hitbox.add(add(buttonDown = createhitbox(dumbLength, 0, "down")));
		hitbox.add(add(buttonUp = createhitbox(dumbLength * 2 , 0, "up")));
		hitbox.add(add(buttonRight = createhitbox(dumbLength * 3, 0, "right")));
		hitbox.add(add(buttonMiddle = createhitbox(dumbLength * 4, 0, "space")));
		hitbox.add(add(buttonLeft2 = createhitbox(0, 0, "left2")));
		hitbox.add(add(buttonDown2 = createhitbox(dumbLength, 0, "down2")));
		hitbox.add(add(buttonUp2 = createhitbox(dumbLength * 2 , 0, "up2")));
		hitbox.add(add(buttonRight2 = createhitbox(dumbLength * 3, 0, "right2")));
		}
		
		for (i in 0...Main.ammo[mania] - 1){
			var hitbox_hint:FlxSprite = new FlxSprite(dumbLength * i, 0).loadGraphic(FNFAssets.getBitmapData('assets/images/androidcontrols/hitbox_hintblank.png'));
		hitbox_hint.antialiasing = orgAntialiasing;
		hitbox_hint.alpha = orgAlpha;
		hitbox_hint.angle += lmaoAngel[mania][i];
		hitbox_hint.color = getColor(dumbAssColors[mania][i]);
		add(hitbox_hint);
		}
	}

	public function createhitbox(x:Float = 0, y:Float = 0, frame:String) {
		var button = new FlxButton(x, y);
		button.loadGraphic(FNFAssets.getBitmapData('assets/images/androidcontrols/hitboxblank.png'));
		button.antialiasing = orgAntialiasing;
		button.color = getColor(frame);
		button.setGraphicSize(Std.int(dumbLength),Std.int(button.height));
		button.updateHitbox();
		button.alpha = 0;// sorry but I can't hard lock the hitbox alpha
		button.onDown.callback = function (){FlxTween.num(0, 0.75, 0.075, {ease:FlxEase.circInOut}, function(alpha:Float){ button.alpha = alpha;});};
		button.onUp.callback = function (){FlxTween.num(0.75, 0, 0.1, {ease:FlxEase.circInOut}, function(alpha:Float){ button.alpha = alpha;});}
		button.onOut.callback = function (){FlxTween.num(button.alpha, 0, 0.2, {ease:FlxEase.circInOut}, function(alpha:Float){ button.alpha = alpha;});}
		return button;
	}
    public function getColor(frame:String):flixel.util.FlxColor
		{
			switch (frame){
				case "left":return 0xFFCC5B9E;
				case "down":return 0xFF00E5FF;
				case "up":return 0xFF04D400;
				case "right":return 0xFFFF4C3C;
				case "space":return 0xFFFFFFFF;
				case "left2":return 0xFFFFF476;
				case "down2":return 0xFF7F3DFF;
				case "up2":return 0xFFE3002D;
				case "right2":return 0xFF4E9FFF;
			}
			return 0xFFFFFFFF;
		}
	//public function getFrames():FlxAtlasFrames {
		//return Paths.getSparrowAtlas('androidcontrols/hitboxblank');
	//}

	override public function destroy():Void {
		super.destroy();

		buttonLeft = null;
		buttonDown = null;
		buttonUp = null;
		buttonRight = null;
	}
}
