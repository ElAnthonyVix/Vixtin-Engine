package;

import flash.display.BitmapData;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.typeLimit.OneOfTwo;
import lime.system.System;
import DynamicSprite.DynamicAtlasFrames;
using StringTools;

#if sys
import flash.media.Sound;
import haxe.io.Path;
import lime.media.AudioBuffer;
import openfl.utils.ByteArray;
import sys.FileSystem;
import sys.io.File;
#end


class EdtNote extends FlxSprite
{
	public var mustBeUpdated:Bool = false;
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var duoMode:Bool = false;
	public var oppMode:Bool = false;
	public var sustainLength:Float = 0;

	public var funnyMode:Bool = false;
	public var noteScore:Float = 1;
	public var altNote:Bool = false;
	public var altNum:Int = 0;
	public var isPixel:Bool = false;

	public var eventName:String = '';
	public var eventLength:Int = 0;
	public var eventVal1:String = '';
	public var eventVal2:String = '';
	public var eventVal3:String = '';

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;
	public static var NOTE_AMOUNT:Int = 4;

	public var rating = "miss";
	public var isLiftNote:Bool = false;
	public var mineNote:Bool = false;
	public var healMultiplier:Float = 1;
	public var damageMultiplier:Float = 1;
	// Whether to always do the same amount of healing for hitting and the same amount of damage for missing notes
	public var consistentHealth:Bool = false;
	// How relatively hard it is to hit the note. Lower numbers are harder, with 0 being literally impossible
	public var timingMultiplier:Float = 1;
	// whether to play the sing animation for hitting this note
	public var shouldBeSung:Bool = true;
	public var ignoreHealthMods:Bool = false;
	public var nukeNote = false;
	public var drainNote = false;

	static var coolCustomGraphics:Array<FlxGraphic> = [];

	// altNote can be int or bool. int just determines what alt is played
	// format: [strumTime:Float, noteDirection:Int, sustainLength:Float, altNote:Union<Bool, Int>, isLiftNote:Bool, healMultiplier:Float, damageMultipler:Float, consistentHealth:Bool, timingMultiplier:Float, shouldBeSung:Bool, ignoreHealthMods:Bool, animSuffix:Union<String, Int>]
	public function new(strumTime:Float, noteData:Int, ?LiftNote:Bool = false)
	{
		super();
		// uh oh notedata sussy :flushed:

		var mania = PlayState.SONG.mania;
		NOTE_AMOUNT = Main.ammo[mania];
		
		isLiftNote = LiftNote;
		if (isLiftNote)
			shouldBeSung = false;
		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;

		this.noteData = noteData % 8;
		var sussy:Bool = false;

		if (noteData > -1)
		{

			if (noteData >= NOTE_AMOUNT * 2 && noteData < NOTE_AMOUNT * 4)
			{
				mineNote = true;
			}
			if (noteData >= NOTE_AMOUNT * 4 && noteData < NOTE_AMOUNT * 6)
			{
				isLiftNote = true;
			}
			// die : )
			if (noteData >= NOTE_AMOUNT * 6 && noteData < NOTE_AMOUNT * 8)
			{
				nukeNote = true;
			}
			if (noteData >= NOTE_AMOUNT * 8 && noteData < NOTE_AMOUNT * 10)
			{
				drainNote = true;
			}
			if (noteData >= NOTE_AMOUNT * 10)
			{
				sussy = true;
			}
			
			frames = DynamicAtlasFrames.fromSparrow('assets/images/custom_ui/ui_packs/normal/NOTE_assets.png',
				'assets/images/custom_ui/ui_packs/normal/NOTE_assets.xml');

			if (sussy)
			{
				// we need to load a unique instance
				// we only need 1 unique instance per number so we do save the graphics
				var sussyInfo = Math.floor(noteData / (NOTE_AMOUNT * 2));
				sussyInfo -= 5;
				if (coolCustomGraphics[sussyInfo] == null)
					coolCustomGraphics[sussyInfo] = FlxGraphic.fromAssetKey('assets/images/custom_ui/ui_packs/normal/NOTE_assets.png', true);

				frames = FlxAtlasFrames.fromSparrow(coolCustomGraphics[sussyInfo], 'assets/images/custom_ui/ui_packs/normal/NOTE_assets.xml');
			}

			animation.addByPrefix('greenScroll', 'green0');
			animation.addByPrefix('redScroll', 'red0');
			animation.addByPrefix('blueScroll', 'blue0');
			animation.addByPrefix('purpleScroll', 'purple0');
			animation.addByPrefix('whiteScroll', 'white0');
			animation.addByPrefix('yellowScroll', 'yellow0');
			animation.addByPrefix('lilaScroll', 'lila0');
			animation.addByPrefix('cherryScroll', 'cherry0');
			animation.addByPrefix('cyanScroll', 'cyan0');

			if (animation.getByName('whiteScroll') == null)
				animation.addByPrefix('whiteScroll', 'green0');

			if (animation.getByName('yellowScroll') == null)
				animation.addByPrefix('yellowScroll', 'purple0');

			if (animation.getByName('lilaScroll') == null)
				animation.addByPrefix('lilaScroll', 'blue0');

			if (animation.getByName('cherryScroll') == null)
				animation.addByPrefix('cherryScroll', 'green0');

			if (animation.getByName('cyanScroll') == null)
				animation.addByPrefix('cyanScroll', 'red0');

			if (isLiftNote)
			{
				animation.addByPrefix('greenScroll', 'green lift');
				animation.addByPrefix('redScroll', 'red lift');
				animation.addByPrefix('blueScroll', 'blue lift');
				animation.addByPrefix('purpleScroll', 'purple lift');
				animation.addByPrefix('whiteScroll', 'white lift');
				animation.addByPrefix('yellowScroll', 'yellow lift');
				animation.addByPrefix('lilaScroll', 'lila lift');
				animation.addByPrefix('cherryScroll', 'cherry lift');
				animation.addByPrefix('cyanScroll', 'cyan lift');

				if (animation.getByName('whiteScroll') == null)
					animation.addByPrefix('whiteScroll', 'green lift');
		
				if (animation.getByName('yellowScroll') == null)
					animation.addByPrefix('yellowScroll', 'purple lift');
		
				if (animation.getByName('lilaScroll') == null)
					animation.addByPrefix('lilaScroll', 'blue lift');
		
				if (animation.getByName('cherryScroll') == null)
					animation.addByPrefix('cherryScroll', 'green lift');
		
				if (animation.getByName('cyanScroll') == null)
					animation.addByPrefix('cyanScroll', 'red lift');
			}
			if (nukeNote)
			{
				animation.addByPrefix('greenScroll', 'green nuke');
				animation.addByPrefix('redScroll', 'red nuke');
				animation.addByPrefix('blueScroll', 'blue nuke');
				animation.addByPrefix('purpleScroll', 'purple nuke');
				animation.addByPrefix('whiteScroll', 'white nuke');
				animation.addByPrefix('yellowScroll', 'yellow nuke');
				animation.addByPrefix('lilaScroll', 'lila nuke');
				animation.addByPrefix('cherryScroll', 'cherry nuke');
				animation.addByPrefix('cyanScroll', 'cyan nuke');

				if (animation.getByName('whiteScroll') == null)
					animation.addByPrefix('whiteScroll', 'green nuke');
		
				if (animation.getByName('yellowScroll') == null)
					animation.addByPrefix('yellowScroll', 'purple nuke');
		
				if (animation.getByName('lilaScroll') == null)
					animation.addByPrefix('lilaScroll', 'blue nuke');
		
				if (animation.getByName('cherryScroll') == null)
					animation.addByPrefix('cherryScroll', 'green nuke');
		
				if (animation.getByName('cyanScroll') == null)
					animation.addByPrefix('cyanScroll', 'red nuke');
			}
			if (mineNote)
			{
				animation.addByPrefix('greenScroll', 'green mine');
				animation.addByPrefix('redScroll', 'red mine');
				animation.addByPrefix('blueScroll', 'blue mine');
				animation.addByPrefix('purpleScroll', 'purple mine');
				animation.addByPrefix('whiteScroll', 'white mine');
				animation.addByPrefix('yellowScroll', 'yellow mine');
				animation.addByPrefix('lilaScroll', 'lila mine');
				animation.addByPrefix('cherryScroll', 'cherry mine');
				animation.addByPrefix('cyanScroll', 'cyan mine');

				if (animation.getByName('whiteScroll') == null)
					animation.addByPrefix('whiteScroll', 'green mine');
		
				if (animation.getByName('yellowScroll') == null)
					animation.addByPrefix('yellowScroll', 'purple mine');
		
				if (animation.getByName('lilaScroll') == null)
					animation.addByPrefix('lilaScroll', 'blue mine');
		
				if (animation.getByName('cherryScroll') == null)
					animation.addByPrefix('cherryScroll', 'green mine');
		
				if (animation.getByName('cyanScroll') == null)
					animation.addByPrefix('cyanScroll', 'red mine');
			}

			setGraphicSize(Std.int(width * 0.7));
			updateHitbox();
			antialiasing = true;

			if (NOTE_AMOUNT == 4)
			{
				switch (noteData % 4)
				{
					case 0:
						x += swagWidth * 0;
						animation.play('purpleScroll');
					case 1:
						x += swagWidth * 1;
						animation.play('blueScroll');
					case 2:
						x += swagWidth * 2;
						animation.play('greenScroll');
					case 3:
						x += swagWidth * 3;
						animation.play('redScroll');
				}
			}

			if (NOTE_AMOUNT == 6)
			{
				switch (noteData % 6)
				{
					case 0:
						x += swagWidth * 0;
						animation.play('purpleScroll');
					case 1:
						x += swagWidth * 1;
						animation.play('greenScroll');
					case 2:
						x += swagWidth * 2;
						animation.play('redScroll');
					case 3:
						x += swagWidth * 3;
						animation.play('yellowScroll');
					case 4:
						x += swagWidth * 4;
						animation.play('blueScroll');
					case 5:
						x += swagWidth * 5;
						animation.play('cyanScroll');
				}
			}

			if (NOTE_AMOUNT == 7)
			{
				switch (noteData % 7)
				{
					case 0:
						x += swagWidth * 0;
						animation.play('purpleScroll');
					case 1:
						x += swagWidth * 1;
						animation.play('greenScroll');
					case 2:
						x += swagWidth * 2;
						animation.play('redScroll');
					case 3:
						x += swagWidth * 3;
						animation.play('whiteScroll');
					case 4:
						x += swagWidth * 4;
						animation.play('yellowScroll');
					case 5:
						x += swagWidth * 5;
						animation.play('blueScroll');
					case 6:
						x += swagWidth * 6;
						animation.play('cyanScroll');
				}
			}

			if (NOTE_AMOUNT == 9)
			{
				switch (noteData % 9)
				{
					case 0:
						x += swagWidth * 0;
						animation.play('purpleScroll');
					case 1:
						x += swagWidth * 1;
						animation.play('greenScroll');
					case 2:
						x += swagWidth * 2;
						animation.play('blueScroll');
					case 3:
						x += swagWidth * 3;
						animation.play('redScroll');
					case 4:
						x += swagWidth * 4;
						animation.play('whiteScroll');
					case 5:
						x += swagWidth * 5;
						animation.play('yellowScroll');
					case 6:
						x += swagWidth * 6;
						animation.play('lilaScroll');
					case 7:
						x += swagWidth * 7;
						animation.play('cherryScroll');
					case 8:
						x += swagWidth * 8;
						animation.play('cyanScroll');
				}
			}

			if (noteData >= NOTE_AMOUNT * 10)
			{
				var sussyInfo = Math.floor(noteData / (NOTE_AMOUNT * 2));
				sussyInfo -= 4;
				var text = new FlxText(0, 0, 0, cast sussyInfo, 64);
				stamp(text, Std.int(this.width / 2), 20);
			}
		}
	}
}
