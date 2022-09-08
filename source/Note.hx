package;

import DynamicSprite.DynamicAtlasFrames;
import Judgement.TUI;
import openfl.errors.Error;
import flixel.util.typeLimit.OneOfTwo;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import lime.system.System;
import flixel.graphics.FlxGraphic;
import flash.display.BitmapData;
#if sys
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import flash.media.Sound;
#end
using StringTools;
enum abstract Direction(Int) from Int to Int {
	var left;
	var down;
	var up;
	var right;

}

typedef EventNote = {
	strumTime:Float,
	event:String,
	value1:String,
	value2:String,
	value3:String
}

/**
 * What NoteiNfo jsons are like. 
 */
typedef NoteInfo = {
	/**
	 * The animation names of the notes. 1-4
	 * left, down, up, right
	 */
	var animNames:Array<String>;
	/**
	 * Pixel animation thingies. same order as names.
	 */
	var animInt:Array<Int>;
	/**
	 * Amount to heal
	 */
	var ?healAmount:Null<Float>;
	/**
	 * Amount to damange. Is added so should be negative to hurt people!
	 */
	var ?damageAmount:Null<Float>;
	/**
	 * Whether it should be sung. 
	 */
	var ?shouldSing:Null<Bool>;
	/**
	 * Overwritten by healAmount. How much the healing should be multiplied.
	 */
	var ?healMultiplier:Null<Float>;
	/**
	 * Overwritten by damage amount. How much damage should be multiplied by.
	 */
	var ?damageMultiplier:Null<Float>;
	/**
	 * Whether to heal the same amount or hurt the same amount.
	 */
	var ?consistentHealth:Null<Bool>;
	/**
	 * When to stop healing and start hurting. can be
	 * sick
	 * good
	 * bad
	 * shit
	 * wayoff
	 * miss
	 */
	var ?healCutoff:Null<String>;
	/**
	 * How easy it is to hit note. Higher numbers are easier. 0 is literally impossible.
	 */
	var ?timingMultiplier:Null<Float>;
	/**
	 * Whether to ignore health modifiers and use straight numbers. 
	 */
	var ?ignoreHealthMods:Null<Bool>;
	/**
	 * Whether missing the note should add to the combo break counter
	 */
	var ?dontCountNote:Null<Bool>;
	/**
	 * Unused. 
	 */
	var ?dontStrum:Null<Bool>;
	/**
	 * Info about how the opponent sings the note. The opponent _always_ sings this note even if it isn't hit.
	 */
	var ?singInfo:Null<SingInfo>;
	/**
	 * An array of string that can be checked for.
	 */
	var ?classes:Null<Array<String>>;
	/**
	 * A unique string that can be checked for. 
	 */
	var ?id:Null<String>;
	/**
	* Custom note path for if your note isn't in the selected note path
	*/
	var ?customNotePath:Null<String>;
}
/**
 * Used to make opponent sing.
 */
typedef SingInfo = {
	/**
	 * Direction of singing. 0-3 left, down, up, right
	 */
	var direction:Int;
	/**
	 * Alt note. 0 is no alt. 
	 */
	var ?alt:Null<Int>;
	/**
	 * Whether to miss or not. 
	 */
	var ?miss:Null<Bool>;
}
// sinful dynamic sprite
class Note extends DynamicSprite
{
	public var strumTime:Float = 0;
	public static var getFrames:Bool = true;
	static var gotFrames:FlxAtlasFrames = null;
	public static var getSpecialFrames:Bool = true;
	static var specialFramesKey:Array<String> = [];
	static var gotSpecialFrames:Array<FlxAtlasFrames> = [];
	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var duoMode:Bool = false;
	public var oppMode:Bool = false;
	public var sustainLength:Float = 0;
	public var alphaMultiplier:Float = 1;
	public var isSustainNote:Bool = false;
	public var modifiedByLua:Bool = false;
	public var funnyMode:Bool = false;
	public var noteScore:Float = 1;
	public var altNote:Bool = false;
	public var crossFade:Bool = false;
	public var altNum:Int = 0;
	public var isPixel:Bool = false;
	public static var swagWidth:Float = 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;
	public static var NOTE_AMOUNT:Int = 4;

	public var eventName:String = '';
	public var eventLength:Int = 0;
	public var eventVal1:String = '';
	public var eventVal2:String = '';
	public var eventVal3:String = '';

	public static var specialNoteJson:Null<Array<NoteInfo>>;
	public var damageAmount:Null<Float> = null;
	public var healAmount:Null<Float> = null;
	// pwease freeplay state don't edit me i already have special info :grief: :grief:
	public var dontEdit:Bool = false;
	public var rating = "miss";
	public var isLiftNote:Bool = false;
	public var mineNote:Bool = false;
	public var specialSinger:Null<Character> = null;
	// like expurgation's notes; insta die lmao
	public var nukeNote:Bool = false;
	// tabi mod
	public var drainNote:Bool =  false;
	public var healMultiplier:Float = 1;
	public var damageMultiplier:Float = 1;
	// Whether to always do the same amount of healing for hitting and the same amount of damage for missing notes
	public var consistentHealth:Bool = false;
	// How relatively hard it is to hit the note. Lower numbers are harder, with 0 being literally impossible
	public var timingMultiplier:Float = 1;
	// whether to play the sing animation for hitting this note
	public var shouldBeSung:Bool = true;
	public var hittedNote:Bool = false;
	public var ignoreHealthMods:Bool = false;
	public var healCutoff:Null<String>;
	var specialNoteInfo:NoteInfo;
	public var dontCountNote = false;
	public var dontStrum = false;
	public var oppntAnim:Null<String> = null;
	public var classes:Null<Array<String>> = [];
	public var coolId:Null<String> = null;
	public var oppntSing:Null<SingInfo>;
	public var customNotePath:Null<String> = null;
	public static var scales:Array<Float> = [0.7, 0.6, 0.55, 0.46];
	public static var pixelscales:Array<Float> = [1, 0.9, 0.85, 0.76];
	public static var swidths:Array<Float> = [160, 120, 110, 90];
	public static var posRest:Array<Int> = [0, 35, 50, 70];
	// altNote can be int or bool. int just determines what alt is played
	// format: [strumTime:Float, noteDirection:Int, sustainLength:Float, altNote:Union<Bool, Int>, isLiftNote:Bool, healMultiplier:Float, damageMultipler:Float, consistentHealth:Bool, timingMultiplier:Float, shouldBeSung:Bool, ignoreHealthMods:Bool, animSuffix:Union<String, Int>]
	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?customImage:Null<BitmapData>, ?customXml:Null<String>, ?customEnds:Null<BitmapData>, ?LiftNote:Bool=false, ?animSuffix:String, ?numSuffix:Int)
	{
		super();

		// uh oh notedata sussy :flushed:
		if (prevNote == null)
			prevNote = this;

		var mania = PlayState.SONG.mania;
		NOTE_AMOUNT = Main.ammo[mania];

		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		isLiftNote = LiftNote;
		
		x += (42 + 50) - posRest[mania];
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;

		this.noteData = noteData % NOTE_AMOUNT;
		// overloading : )
		if (noteData >= NOTE_AMOUNT * 2 && noteData < NOTE_AMOUNT * 4) {
			mineNote = true;
		}
		if (noteData >= NOTE_AMOUNT * 4 && noteData < NOTE_AMOUNT * 6) {
			isLiftNote = true;
		}
		// die : )
		if (noteData >= NOTE_AMOUNT * 6 && noteData < NOTE_AMOUNT * 8) {
			nukeNote = true;
		}
		if (noteData >= NOTE_AMOUNT * 8 && noteData < NOTE_AMOUNT * 10) {
			drainNote = true;
		}
		if (noteData >= NOTE_AMOUNT * 10 && specialNoteJson != null) {
			// special note...
			// get the note thingie
			var sussyNoteThing = Math.floor(noteData/ (NOTE_AMOUNT * 2));
			// there are already 4 thingies and the thing is index 0 
			sussyNoteThing -= 5;
			var thingie = specialNoteJson[sussyNoteThing];
			dontEdit = true;
			if (thingie.damageAmount != null) {
				damageAmount = thingie.damageAmount;
			} else if (thingie.damageMultiplier != null) {
				damageMultiplier = thingie.damageMultiplier;
			}
			if (thingie.healAmount != null) {
				healAmount = thingie.healAmount;
			} else if (thingie.healMultiplier != null) {
				healMultiplier = thingie.healMultiplier;
			}
			
			if (thingie.shouldSing != null) {
				shouldBeSung = thingie.shouldSing;
			}

			if (thingie.consistentHealth != null) {
				consistentHealth = thingie.consistentHealth;
			}
			if (healAmount < 0 || healMultiplier < 0) {
				dontCountNote = true;
			}
			if (thingie.dontCountNote != null)
				dontCountNote = thingie.dontCountNote;
			if (thingie.healCutoff != null) {
				healCutoff = thingie.healCutoff;
			}
			if (thingie.timingMultiplier != null) {
				timingMultiplier = thingie.timingMultiplier;
			} 
			if (thingie.dontStrum != null) {
				dontStrum = thingie.dontStrum;
			}
			if (thingie.classes != null) {
				classes = thingie.classes;
			}
			if (thingie.id != null) {
				coolId = thingie.id;
			}
			if (thingie.singInfo != null) {
				oppntSing = thingie.singInfo;
				if (oppntSing.alt == null) {
					oppntSing.alt = 0;
				}
				if (oppntSing.miss == null)
					oppntSing.miss = false;
			}
			if (thingie.customNotePath != null) {
				customNotePath = thingie.customNotePath;
			}
			specialNoteInfo = thingie;
			ignoreHealthMods = cast thingie.ignoreHealthMods;
		}
		if (mineNote || nukeNote) {
			shouldBeSung = false;
			dontCountNote = true;
			dontStrum = true;
		}
		if (isLiftNote) {
			shouldBeSung = false;
			// dontStrum = true;
		}
		var curUiType:TUI = Reflect.field(Judgement.uiJson, PlayState.SONG.uiType);
		// var daStage:String = PlayState.curStage;
		if (!curUiType.isPixel)
		{	
			if (customNotePath != null) {
				if (getSpecialFrames) {
					getSpecialFrames = false;
					specialFramesKey = [];
					gotSpecialFrames = [];
				}
				var funnyNum = specialFramesKey.indexOf(customNotePath);
				if (funnyNum == -1) {
					var daFrames = DynamicAtlasFrames.fromSparrow(customNotePath + '.png', customNotePath + '.xml');
					specialFramesKey.push(customNotePath);
					gotSpecialFrames.push(daFrames);
					funnyNum = specialFramesKey.length - 1;
				}
				frames = gotSpecialFrames[funnyNum];
			} else {
				if (getFrames) {
					getFrames = false;
					gotFrames = DynamicAtlasFrames.fromSparrow('assets/images/custom_ui/ui_packs/'
						+ curUiType.uses
						+ "/NOTE_assets.png",
						'assets/images/custom_ui/ui_packs/'
						+ curUiType.uses
						+ "/NOTE_assets.xml");
				}
				frames = gotFrames;
			}
			if (animSuffix == null)
			{
				animSuffix = '';
			}
			else
			{
				animSuffix = ' ' + animSuffix;
			}
			
			loadNoteAnims(animSuffix);

			if (!isSustainNote)
				setGraphicSize(Std.int(width * scales[PlayState.SONG.mania]));
			else
				setGraphicSize(Std.int(width * scales[PlayState.SONG.mania]), Std.int(height * scales[0]));

			updateHitbox();
			antialiasing = true;
			// when arrowsEnds != arrowEnds :laughing_crying:
		}
		else
		{
			if (customNotePath != null)
				loadGraphic(customNotePath + '.png', true, 17, 17);
			else
				loadGraphic('assets/images/custom_ui/ui_packs/' + curUiType.uses + "/arrows-pixels.png", true, 17, 17);
			
			if (animSuffix != null && numSuffix == null)
			{
				numSuffix = Std.parseInt(animSuffix);
			}
			if (numSuffix != null)
			{
				var intSuffix = numSuffix;
				animation.add('greenScroll', [intSuffix]);
				animation.add('redScroll', [intSuffix]);
				animation.add('blueScroll', [intSuffix]);
				animation.add('purpleScroll', [intSuffix]);
				animation.add('whiteScroll', [intSuffix]);
				animation.add('yellowScroll', [intSuffix]);
				animation.add('lilaScroll', [intSuffix]);
				animation.add('cherryScroll', [intSuffix]);
				animation.add('cyanScroll', [intSuffix]);
				if (isSustainNote)
				{
					loadGraphic('assets/images/custom_ui/ui_packs/' + curUiType.uses + "/arrowEnds.png", true, 7, 6);

					animation.add('purpleholdend', [intSuffix]);
					animation.add('greenholdend', [intSuffix]);
					animation.add('redholdend', [intSuffix]);
					animation.add('blueholdend', [intSuffix]);
					animation.add('whiteholdend', [intSuffix]);
					animation.add('yellowholdend', [intSuffix]);
					animation.add('lilaholdend', [intSuffix]);
					animation.add('cherryholdend', [intSuffix]);
					animation.add('cyanholdend', [intSuffix]);

					animation.add('purplehold', [intSuffix]);
					animation.add('greenhold', [intSuffix]);
					animation.add('redhold', [intSuffix]);
					animation.add('bluehold', [intSuffix]);
					animation.add('whitehold', [intSuffix]);
					animation.add('yellowhold', [intSuffix]);
					animation.add('lilahold', [intSuffix]);
					animation.add('cherryhold', [intSuffix]);
					animation.add('cyanhold', [intSuffix]);
				}
			}
			else
			{
				animation.add('greenScroll', [6]);
				animation.add('redScroll', [7]);
				animation.add('blueScroll', [5]);
				animation.add('purpleScroll', [4]);
				animation.add('whiteScroll', [52]);
				animation.add('yellowScroll', [36]);
				animation.add('lilaScroll', [37]);
				animation.add('cherryScroll', [38]);
				animation.add('cyanScroll', [39]);

				if (isSustainNote)
				{
					loadGraphic('assets/images/custom_ui/ui_packs/' + curUiType.uses + "/arrowEnds.png", true, 7, 6);

					animation.add('purpleholdend', [4]);
					animation.add('greenholdend', [6]);
					animation.add('redholdend', [7]);
					animation.add('blueholdend', [5]);
					animation.add('whiteholdend', [20]);
					animation.add('yellowholdend', [12]);
					animation.add('lilaholdend', [13]);
					animation.add('cherryholdend', [14]);
					animation.add('cyanholdend', [15]);

					animation.add('purplehold', [0]);
					animation.add('greenhold', [2]);
					animation.add('redhold', [3]);
					animation.add('bluehold', [1]);
					animation.add('whitehold', [16]);
					animation.add('yellowhold', [8]);
					animation.add('lilahold', [9]);
					animation.add('cherryhold', [10]);
					animation.add('cyanhold', [11]);
				}
				if (isLiftNote)
				{
					animation.add('greenScroll', [22]);
					animation.add('redScroll', [23]);
					animation.add('blueScroll', [21]);
					animation.add('purpleScroll', [20]);
				}
				if (mineNote) {
					animation.add('greenScroll', [26]);
					animation.add('redScroll', [27]);
					animation.add('blueScroll', [25]);
					animation.add('purpleScroll', [24]);
					animation.add('whiteScroll', [26]);
					animation.add('yellowScroll', [24]);
					animation.add('lilaScroll', [25]);
					animation.add('cherryScroll', [26]);
					animation.add('cyanScroll', [27]);
				}
				if (nukeNote) {
					animation.add('greenScroll', [30]);
					animation.add('redScroll', [31]);
					animation.add('blueScroll', [29]);
					animation.add('purpleScroll', [28]);
					animation.add('whiteScroll', [30]);
					animation.add('yellowScroll', [28]);
					animation.add('lilaScroll', [29]);
					animation.add('cherryScroll', [30]);
					animation.add('cyanScroll', [31]);
				}
			}
			if (dontEdit)
			{
				animation.add('greenScroll', [specialNoteInfo.animInt[2]]);
				animation.add('redScroll', [specialNoteInfo.animInt[3]]);
				animation.add('purpleScroll', [specialNoteInfo.animInt[0]]);
				animation.add('blueScroll', [specialNoteInfo.animInt[1]]);
				animation.add('whiteScroll', [specialNoteInfo.animInt[4]]);
				animation.add('yellowScroll', [specialNoteInfo.animInt[5]]);
				animation.add('lilaScroll', [specialNoteInfo.animInt[6]]);
				animation.add('cherryScroll', [specialNoteInfo.animInt[7]]);
				animation.add('cyanScroll', [specialNoteInfo.animInt[8]]);
			}
			setGraphicSize(Std.int(width * PlayState.daPixelZoom * pixelscales[PlayState.SONG.mania]));
			updateHitbox();
		}

		if (NOTE_AMOUNT == 4)
		{
			switch (noteData % 4)
			{
				case 0:
					x += swidths[mania] * swagWidth * 0;
					animation.play('purpleScroll');
				case 1:
					x += swidths[mania] * swagWidth * 1;
					animation.play('blueScroll');
				case 2:
					x += swidths[mania] * swagWidth * 2;
					animation.play('greenScroll');
				case 3:
					x += swidths[mania] * swagWidth * 3;
					animation.play('redScroll');
			}
		}

		if (NOTE_AMOUNT == 6)
		{
			switch (noteData % 6)
			{
				case 0:
					x += swidths[mania] * swagWidth * 0;
					animation.play('purpleScroll');
				case 1:
					x += swidths[mania] * swagWidth * 1;
					animation.play('greenScroll');
				case 2:
					x += swidths[mania] * swagWidth * 2;
					animation.play('redScroll');
				case 3:
					x += swidths[mania] * swagWidth * 3;
					animation.play('yellowScroll');
				case 4:
					x += swidths[mania] * swagWidth * 4;
					animation.play('blueScroll');
				case 5:
					x += swidths[mania] * swagWidth * 5;
					animation.play('cyanScroll');
			}
		}

		if (NOTE_AMOUNT == 7)
		{
			switch (noteData % 7)
			{
				case 0:
					x += swidths[mania] * swagWidth * 0;
					animation.play('purpleScroll');
				case 1:
					x += swidths[mania] * swagWidth * 1;
					animation.play('greenScroll');
				case 2:
					x += swidths[mania] * swagWidth * 2;
					animation.play('redScroll');
				case 3:
					x += swidths[mania] * swagWidth * 3;
					animation.play('whiteScroll');
				case 4:
					x += swidths[mania] * swagWidth * 4;
					animation.play('yellowScroll');
				case 5:
					x += swidths[mania] * swagWidth * 5;
					animation.play('blueScroll');
				case 6:
					x += swidths[mania] * swagWidth * 6;
					animation.play('cyanScroll');
			}
		}

		if (NOTE_AMOUNT == 9)
		{
			switch (noteData % 9)
			{
				case 0:
					x += swidths[mania] * swagWidth * 0;
					animation.play('purpleScroll');
				case 1:
					x += swidths[mania] * swagWidth * 1;
					animation.play('blueScroll');
				case 2:
					x += swidths[mania] * swagWidth * 2;
					animation.play('greenScroll');
				case 3:
					x += swidths[mania] * swagWidth * 3;
					animation.play('redScroll');
				case 4:
					x += swidths[mania] * swagWidth * 4;
					animation.play('whiteScroll');
				case 5:
					x += swidths[mania] * swagWidth * 5;
					animation.play('yellowScroll');
				case 6:
					x += swidths[mania] * swagWidth * 6;
					animation.play('lilaScroll');
				case 7:
					x += swidths[mania] * swagWidth * 7;
					animation.play('cherryScroll');
				case 8:
					x += swidths[mania] * swagWidth * 8;
					animation.play('cyanScroll');
			}
		}

		// trace(prevNote);
		if (isSustainNote && OptionsHandler.options.downscroll) {
			flipY = true;
		}
		if (isSustainNote && prevNote != null)
		{
			noteScore * 0.2;
			alpha = 0.6;

			x += width / 2;

			if (NOTE_AMOUNT == 4)
			{
				switch (noteData % 4)
				{
					case 0:
						animation.play('purpleholdend');
					case 1:
						animation.play('blueholdend');
					case 2:
						animation.play('greenholdend');
					case 3:
						animation.play('redholdend');
				}
			}

			if (NOTE_AMOUNT == 6)
			{
				switch (noteData % 6)
				{
					case 0:
						animation.play('purpleholdend');
					case 1:
						animation.play('greenholdend');
					case 2:
						animation.play('redholdend');
					case 3:
						animation.play('yellowholdend');
					case 4:
						animation.play('blueholdend');
					case 5:
						animation.play('cyanholdend');
				}
			}

			if (NOTE_AMOUNT == 7)
			{
				switch (noteData % 7)
				{
					case 0:
						animation.play('purpleholdend');
					case 1:
						animation.play('greenholdend');
					case 2:
						animation.play('redholdend');
					case 3:
						animation.play('whiteholdend');
					case 4:
						animation.play('yellowholdend');
					case 5:
						animation.play('blueholdend');
					case 6:
						animation.play('cyanholdend');
				}
			}

			if (NOTE_AMOUNT == 9)
			{
				switch (noteData % 9)
				{
					case 0:
						animation.play('purpleholdend');
					case 1:
						animation.play('blueholdend');
					case 2:
						animation.play('greenholdend');
					case 3:
						animation.play('redholdend');
					case 4:
						animation.play('whiteholdend');
					case 5:
						animation.play('yellowholdend');
					case 6:
						animation.play('lilaholdend');
					case 7:
						animation.play('cherryholdend');
					case 8:
						animation.play('cyanholdend');
				}
			}

			updateHitbox();

			x -= width / 2;

			if (isPixel)
				x += 30;

			if (prevNote.isSustainNote)
			{
				// DO mod it because we DIDN'T do that
				if (NOTE_AMOUNT == 4)
				{
					switch (prevNote.noteData % 4)
					{
						case 0:
							prevNote.animation.play('purplehold');
						case 1:
							prevNote.animation.play('bluehold');
						case 2:
							prevNote.animation.play('greenhold');
						case 3:
							prevNote.animation.play('redhold');
					}
				}

				if (NOTE_AMOUNT == 6)
				{
					switch (prevNote.noteData % 6)
					{
						case 0:
							prevNote.animation.play('purplehold');
						case 1:
							prevNote.animation.play('greenhold');
						case 2:
							prevNote.animation.play('redhold');
						case 3:
							prevNote.animation.play('yellowhold');
						case 4:
							prevNote.animation.play('bluehold');
						case 5:
							prevNote.animation.play('cyanhold');
					}
				}

				if (NOTE_AMOUNT == 7)
				{
					switch (prevNote.noteData % 7)
					{
						case 0:
							prevNote.animation.play('purplehold');
						case 1:
							prevNote.animation.play('greenhold');
						case 2:
							prevNote.animation.play('redhold');
						case 3:
							prevNote.animation.play('whitehold');
						case 4:
							prevNote.animation.play('yellowhold');
						case 5:
							prevNote.animation.play('bluehold');
						case 6:
							prevNote.animation.play('cyanhold');
					}
				}

				if (NOTE_AMOUNT == 9)
				{
					switch (prevNote.noteData % 9)
					{
						case 0:
							prevNote.animation.play('purplehold');
						case 1:
							prevNote.animation.play('bluehold');
						case 2:
							prevNote.animation.play('greenhold');
						case 3:
							prevNote.animation.play('redhold');
						case 4:
							prevNote.animation.play('whitehold');
						case 5:
							prevNote.animation.play('yellowhold');
						case 6:
							prevNote.animation.play('lilahold');
						case 7:
							prevNote.animation.play('cherryhold');
						case 8:
							prevNote.animation.play('cyanhold');
					}
				}

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5;
				prevNote.scale.y *= PlayState.daScrollSpeed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}
	}

	function loadNoteAnims(?animSuffix:String)
	{
		animation.addByPrefix('greenScroll', 'green${animSuffix}0');
		animation.addByPrefix('redScroll', 'red${animSuffix}0');
		animation.addByPrefix('blueScroll', 'blue${animSuffix}0');
		animation.addByPrefix('purpleScroll', 'purple${animSuffix}0');
		animation.addByPrefix('whiteScroll', 'white${animSuffix}0');
		animation.addByPrefix('yellowScroll', 'yellow${animSuffix}0');
		animation.addByPrefix('lilaScroll', 'lila${animSuffix}0');
		animation.addByPrefix('cherryScroll', 'cherry${animSuffix}0');
		animation.addByPrefix('cyanScroll', 'cyan${animSuffix}0');

		if (animation.getByName('whiteScroll') == null)
			animation.addByPrefix('whiteScroll', 'green${animSuffix}0');

		if (animation.getByName('yellowScroll') == null)
			animation.addByPrefix('yellowScroll', 'purple${animSuffix}0');

		if (animation.getByName('lilaScroll') == null)
			animation.addByPrefix('lilaScroll', 'blue${animSuffix}0');

		if (animation.getByName('cherryScroll') == null)
			animation.addByPrefix('cherryScroll', 'green${animSuffix}0');

		if (animation.getByName('cyanScroll') == null)
			animation.addByPrefix('cyanScroll', 'red${animSuffix}0');

		if (isSustainNote)
		{
			animation.addByPrefix('purpleholdend', 'pruple end hold${animSuffix}');
			animation.addByPrefix('greenholdend', 'green hold end${animSuffix}');
			animation.addByPrefix('redholdend', 'red hold end${animSuffix}');
			animation.addByPrefix('blueholdend', 'blue hold end${animSuffix}');
			animation.addByPrefix('whiteholdend', 'white hold end${animSuffix}');
			animation.addByPrefix('yellowholdend', 'yellow end hold${animSuffix}');
			animation.addByPrefix('lilaholdend', 'lila hold end${animSuffix}');
			animation.addByPrefix('cherryholdend', 'red hold end${animSuffix}');
			animation.addByPrefix('cyanholdend', 'cyan hold end${animSuffix}');

			if (animation.getByName('whiteholdend') == null)
				animation.addByPrefix('whiteholdend', 'green hold end${animSuffix}');
	
			if (animation.getByName('yellowholdend') == null)
				animation.addByPrefix('yellowholdend', 'pruple hold end${animSuffix}');
	
			if (animation.getByName('lilaholdend') == null)
				animation.addByPrefix('lilaholdend', 'blue hold end${animSuffix}');
	
			if (animation.getByName('cherryholdend') == null)
				animation.addByPrefix('cherryholdend', 'green hold end${animSuffix}');
	
			if (animation.getByName('cyanholdend') == null)
				animation.addByPrefix('cyanholdend', 'red hold end${animSuffix}');

			animation.addByPrefix('purplehold', 'purple hold piece${animSuffix}');
			animation.addByPrefix('greenhold', 'green hold piece${animSuffix}');
			animation.addByPrefix('redhold', 'red hold piece${animSuffix}');
			animation.addByPrefix('bluehold', 'blue hold piece${animSuffix}');
			animation.addByPrefix('whitehold', 'white hold piece${animSuffix}');
			animation.addByPrefix('yellowhold', 'yellow hold piece${animSuffix}');
			animation.addByPrefix('lilahold', 'lila hold piece${animSuffix}');
			animation.addByPrefix('cherryhold', 'cherry hold piece${animSuffix}');
			animation.addByPrefix('cyanhold', 'cyan hold piece${animSuffix}');

			if (animation.getByName('whitehold') == null)
				animation.addByPrefix('whitehold', 'green hold piece${animSuffix}');
	
			if (animation.getByName('yellowhold') == null)
				animation.addByPrefix('yellowhold', 'pruple hold piece${animSuffix}');
	
			if (animation.getByName('lilahold') == null)
				animation.addByPrefix('lilahold', 'blue hold piece${animSuffix}');
	
			if (animation.getByName('cherryhold') == null)
				animation.addByPrefix('cherryhold', 'green hold piece${animSuffix}');
	
			if (animation.getByName('cyanhold') == null)
				animation.addByPrefix('cyanhold', 'red hold piece${animSuffix}');
		}

		if (isLiftNote)
		{
			animation.addByPrefix('greenScroll', 'green lift${animSuffix}');
			animation.addByPrefix('redScroll', 'red lift${animSuffix}');
			animation.addByPrefix('blueScroll', 'blue lift${animSuffix}');
			animation.addByPrefix('purpleScroll', 'purple lift${animSuffix}');
			animation.addByPrefix('whiteScroll', 'white lift${animSuffix}');
			animation.addByPrefix('yellowScroll', 'yellow lift${animSuffix}');
			animation.addByPrefix('lilaScroll', 'lila lift${animSuffix}');
			animation.addByPrefix('cherryScroll', 'cherry lift${animSuffix}');
			animation.addByPrefix('cyanScroll', 'cyan lift${animSuffix}');
		}
		if (nukeNote)
		{
			animation.addByPrefix('greenScroll', 'green nuke${animSuffix}');
			animation.addByPrefix('redScroll', 'red nuke${animSuffix}');
			animation.addByPrefix('blueScroll', 'blue nuke${animSuffix}');
			animation.addByPrefix('purpleScroll', 'purple nuke${animSuffix}');
			animation.addByPrefix('whiteScroll', 'white nuke${animSuffix}');
			animation.addByPrefix('yellowScroll', 'yellow nuke${animSuffix}');
			animation.addByPrefix('lilaScroll', 'lila nuke${animSuffix}');
			animation.addByPrefix('cherryScroll', 'cherry nuke${animSuffix}');
			animation.addByPrefix('cyanScroll', 'cyan nuke${animSuffix}');
		}
		
		if (mineNote)
		{
			animation.addByPrefix('greenScroll', 'green mine${animSuffix}');
			animation.addByPrefix('redScroll', 'red mine${animSuffix}');
			animation.addByPrefix('blueScroll', 'blue mine${animSuffix}');
			animation.addByPrefix('purpleScroll', 'purple mine${animSuffix}');
			animation.addByPrefix('whiteScroll', 'white mine${animSuffix}');
			animation.addByPrefix('yellowScroll', 'yellow mine${animSuffix}');
			animation.addByPrefix('lilaScroll', 'lila mine${animSuffix}');
			animation.addByPrefix('cherryScroll', 'cherry mine${animSuffix}');
			animation.addByPrefix('cyanScroll', 'cyan mine${animSuffix}');
		}
		if (dontEdit) {
			animation.addByPrefix('greenScroll', specialNoteInfo.animNames[2]);
			animation.addByPrefix('redScroll', specialNoteInfo.animNames[3]);
			animation.addByPrefix('purpleScroll', specialNoteInfo.animNames[0]);
			animation.addByPrefix('blueScroll', specialNoteInfo.animNames[1]);
			animation.addByPrefix('whiteScroll', specialNoteInfo.animNames[4]);
			animation.addByPrefix('yellowScroll', specialNoteInfo.animNames[5]);
			animation.addByPrefix('lilaScroll', specialNoteInfo.animNames[6]);
			animation.addByPrefix('cherryScroll', specialNoteInfo.animNames[7]);
			animation.addByPrefix('cyanScroll', specialNoteInfo.animNames[8]);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		// if we are player one and it's bf's note or we are duo mode or we are player two and it's p2's note
		// and it isn't demo mode
		if ((((mustPress && !oppMode) || duoMode) || (oppMode && !mustPress)) && !funnyMode)
		{
			var signedDiff = Conductor.songPosition - strumTime;
			// ok.... so if strumTime is bigger than songPosition that means it is waiting to be hit because well the song hasn't reached it???
			// negative is early, positive is late
			var noteDiff = Math.abs(signedDiff);
			// The * 0.5 us so that its easier to hit them too late, instead of too early
			if (noteDiff < Judge.wayoffJudge * timingMultiplier)
			{
				canBeHit = true;
			}
			else
				canBeHit = false;
			// Nuke notes can only be hit with a bad or better because nuke notes are weird champ
			if (nukeNote && !(noteDiff < Judge.badJudge * timingMultiplier)) {
				canBeHit = false;
			}
			if (mineNote && !(noteDiff < Judge.shitJudge * timingMultiplier))
			{
				canBeHit = false;
			}
			if (signedDiff > Judge.wayoffJudge)
				tooLate = true;
			if (nukeNote && signedDiff > Judge.badJudge) {
				tooLate = true;
			}
			if (mineNote && signedDiff > Judge.shitJudge) {
				tooLate = true;
			}
		}
		else
		{
			if (!dontStrum) {
				canBeHit = false;

				if (strumTime <= Conductor.songPosition)
				{
					wasGoodHit = true;
				}
			}
			
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
	// inline because it's 1 fucking line dumbass
	public inline function daStrumTime():Float {
		return strumTime + OptionsHandler.options.offset;
	}
	public static inline function getTrueStrumTime(strumTime:Float):Float {
		return strumTime + OptionsHandler.options.offset;
	}
	public function getHealth(rating:String):Float {
		if (mineNote) {
			if (rating != 'miss') {
				return -0.45;
			} else {
				return 0;
			}
		}
		if (nukeNote) {
			if (rating != 'miss')
				return -69;
			else
				return 0;
		}
		if (consistentHealth)
		{
			var ouchie = false;
			switch (healCutoff)
			{
				case 'shit':
					ouchie = rating == 'shit' || rating == 'wayoff' || rating == 'miss';
				case 'wayoff':
					ouchie = rating == 'wayoff' || rating == 'miss';
				case 'miss':
					ouchie = rating == 'miss';
				case 'bad' | null:
					ouchie = rating == 'shit' || rating == 'wayoff' || rating == 'bad' || rating == 'miss';
				case 'good':
					ouchie = rating == 'shit' || rating == 'wayoff' || rating == 'bad' || rating == 'miss' || rating == 'good';
				case 'sick':
					ouchie = true;
				case 'none':
					ouchie = false;
			}
			if (ouchie)
			{
				if (damageAmount != null)
				{
					return damageAmount * (ignoreHealthMods ? 1 : PlayState.healthLossMultiplier);
				}
				else
				{
					return damageMultiplier * -0.04 * (ignoreHealthMods ? 1 : PlayState.healthLossMultiplier);
				}
			}
			else
			{
				if (healAmount != null)
				{
					return healAmount * (ignoreHealthMods ? 1 : PlayState.healthGainMultiplier);
				}
				else
				{
					return healMultiplier * (ignoreHealthMods ? 1 : PlayState.healthGainMultiplier) * 0.04;
				}
			}
		} else {
			var healies = 0.0;
			var shitHeal = OptionsHandler.options.useKadeHealth ? 0.2 : 0.06;
			var badHeal = OptionsHandler.options.useKadeHealth ? 0.06 : 0.03;
			var goodHeal = OptionsHandler.options.useKadeHealth ? 0.04  : 0.03;
			var missHeal = 0.04;
			var sickHeal = OptionsHandler.options.useKadeHealth ? 0.1 : 0.07;
			switch (healCutoff) {
				case "shit":
					switch (rating) {
						case "shit" | 'wayoff':
							healies = -shitHeal;
						case "bad":
							healies = badHeal;
						case "good":
							healies = goodHeal;
						case "miss":
							
							healies = -missHeal;
						case "sick":
							healies = sickHeal;
					}
				case "bad" | null: 
					switch (rating)
					{
						case "shit" | 'wayoff':
							healies = -shitHeal;
						case "bad":
							healies = -badHeal;
						case "good":
							healies = goodHeal;
						case "miss":
							healies = -missHeal;
						case "sick":
							healies = sickHeal;
					}
				case "good": 
					switch (rating)
					{
						case "shit" | 'wayoff':
							healies = -shitHeal;
						case "bad":
							healies = -badHeal;
						case "good":
							healies = -goodHeal;
						case "miss":
							healies = -missHeal;
						case "sick":
							healies = sickHeal;
					}
				case "wayoff":
					switch (rating)
					{
						case "shit":
							healies = shitHeal;
						case 'wayoff': 
							healies = -shitHeal;
						case "bad":
							healies = badHeal;
						case "good":
							healies = goodHeal;
						case "miss":
							healies = -missHeal;
						case "sick":
							healies = sickHeal;
					}
				case "miss":
					switch (rating)
					{
						case "shit" | 'wayoff':
							healies = shitHeal;
						case "bad":
							healies = badHeal;
						case "good":
							healies = goodHeal;
						case "miss":
							healies = -missHeal;
						case "sick":
							healies = sickHeal;
					}

				case "sick":
					switch (rating)
					{
						case "shit" | 'wayoff':
							healies = -shitHeal;
						case "bad":
							healies = -badHeal;
						case "good":
							healies = -goodHeal;
						case "miss":
							healies = -missHeal;
						case "sick":
							healies = -sickHeal;
					}
			}
			if (healies > 0) {
				// this was pointless then :grief:
				if (healAmount != null) {
					return healAmount * (ignoreHealthMods ? 1 : PlayState.healthGainMultiplier);
				} else {
					return healMultiplier * healies * (ignoreHealthMods ? 1 : PlayState.healthGainMultiplier);

				}

			} else {
				if (damageAmount != null)
				{
					return damageAmount * (ignoreHealthMods ? 1 : PlayState.healthLossMultiplier);
				}
				else
				{
					return damageMultiplier * healies * (ignoreHealthMods ? 1 : PlayState.healthLossMultiplier);
				}
			}
		}
		
		
	}
}
