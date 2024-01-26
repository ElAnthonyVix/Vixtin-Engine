package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import Judgement.TUI;
using StringTools;
import DynamicSprite.DynamicAtlasFrames;
//a StrumNote can fixed that spin angle offsets
@:access(flixel.animation.FlxAnimationController)
class StrumNote extends FlxSprite
{
	public var resetAnim:Float = 0;
	private var noteData:Int = 0;
	public var direction:Float = 90;
	public var downScroll:Bool = false;
	public var sustainReduce:Bool = true;
	public var isPixelNote:Bool = false;
	private var player:Int;
	var flippedNotes:Bool = false;
	public var animOffsets:Map<String, Array<Float>>;

	public function new(x:Float, y:Float, leData:Int, player:Int) {
		animOffsets = new Map<String, Array<Float>>();
		var curUiType:TUI = Reflect.field(Judgement.uiJson, PlayState.SONG.uiType);
		noteData = leData;
		this.player = player;
		this.noteData = leData;
		flippedNotes = ModifierState.namedModifiers.flipped.value;
		isPixelNote = curUiType.isPixel;
		super(x, y);
       trace('Strum Crated');
		if(isPixelNote)
		loadGraphic(FNFAssets.getBitmapData('assets/images/custom_ui/ui_packs/' + curUiType.uses + "/arrows-pixels.png"), true, 17, 17);
		else
		frames = DynamicAtlasFrames.fromSparrow('assets/images/custom_ui/ui_packs/'
						+ curUiType.uses
						+ "/NOTE_assets.png",
						'assets/images/custom_ui/ui_packs/'
						+ curUiType.uses
						+ "/NOTE_assets.xml");
						
		loadNoteAnims();
		scrollFactor.set();
		
			animOffsets.set('static',[0,0]);
			animOffsets.set('pressed',[0,0]);
			animOffsets.set('confirm',[0,0]);
	}

	public function loadNoteAnims()
	{
		var lastAnim:String = null;
		if(animation.curAnim != null) lastAnim = animation.curAnim.name;

		if(isPixelNote)
		{
			
			antialiasing = false;
			setGraphicSize(Std.int(width * PlayState.daPixelZoom * Note.pixelscales[PlayState.SONG.mania]));
			animation.add('green', [6]);
			animation.add('red', [7]);
			animation.add('blue', [5]);
			animation.add('purplel', [4]);
			animation.add('space', [55]);
			if (flippedNotes)
				{
					animation.add('blue', [6]);
					animation.add('purplel', [7]);
					animation.add('green', [5]);
					animation.add('red', [4]);
				}
				//if (Main.ammo[PlayState.SONG.mania] == x) is kinda cursed for me...
			switch (Main.ammo[PlayState.SONG.mania]){
				case 4:
					
						switch (Math.abs(noteData))
						{
							case 0:
							
								animation.add('static', [0]);
								animation.add('pressed', [4, 8], 12, false);
								animation.add('confirm', [12, 16], 24, false);
								if (flippedNotes)
								{
									animation.add('static', [3]);
									animation.add('pressed', [7, 11], 12, false);
									animation.add('confirm', [15, 19], 24, false);
								}
							case 1:
							
								animation.add('static', [1]);
								animation.add('pressed', [5, 9], 12, false);
								animation.add('confirm', [13, 17], 24, false);
								if (flippedNotes)
								{
									animation.add('static', [2]);
									animation.add('pressed', [6, 10], 12, false);
									animation.add('confirm', [14, 18], 12, false);
								}
							case 2:
							
								animation.add('static', [2]);
								animation.add('pressed', [6, 10], 12, false);
								animation.add('confirm', [14, 18], 12, false);
								if (flippedNotes)
								{
									animation.add('static', [1]);
									animation.add('pressed', [5, 9], 12, false);
									animation.add('confirm', [13, 17], 12, false);
								}
							case 3:
							
								animation.add('static', [3]);
								animation.add('pressed', [7, 11], 12, false);
								animation.add('confirm', [15, 19], 24, false);
								if (flippedNotes)
								{
									animation.add('static', [0]);
									animation.add('pressed', [4, 8], 12, false);
									animation.add('confirm', [12, 16], 24, false);
								}
						
					}
	
					case 6:
					
						switch (Math.abs(noteData))
						{
							case 0:
							
								animation.add('static', [0]);
								animation.add('pressed', [4, 8], 12, false);
								animation.add('confirm', [12, 16], 24, false);
								if (flippedNotes)
								{
									animation.add('static', [3]);
									animation.add('pressed', [7, 11], 12, false);
									animation.add('confirm', [15, 19], 24, false);
								}
							case 1:
						
								animation.add('static', [2]);
								animation.add('pressed', [6, 10], 12, false);
								animation.add('confirm', [14, 18], 12, false);
								if (flippedNotes)
								{
									animation.add('static', [1]);
									animation.add('pressed', [5, 9], 12, false);
									animation.add('confirm', [13, 17], 12, false);
								}
							case 2:
							
	
								animation.add('static', [3]);
								animation.add('pressed', [7, 11], 12, false);
								animation.add('confirm', [15, 19], 24, false);
								if (flippedNotes)
								{
									animation.add('static', [0]);
									animation.add('pressed', [4, 8], 12, false);
									animation.add('confirm', [12, 16], 24, false);
								}
							case 3:
							
								animation.add('static', [0]);
								animation.add('pressed', [36, 40], 12, false);
								animation.add('confirm', [44, 48], 24, false);
								if (flippedNotes)
								{
									animation.add('static', [3]);
									animation.add('pressed', [39, 43], 12, false);
									animation.add('confirm', [47, 51], 24, false);
								}
							case 4:
							
								animation.add('static', [1]);
								animation.add('pressed', [5, 9], 12, false);
								animation.add('confirm', [13, 17], 12, false);
								if (flippedNotes)
								{
									animation.add('static', [2]);
									animation.add('pressed', [6, 10], 12, false);
									animation.add('confirm', [14, 18], 12, false);
								}
							case 5:
							
								animation.add('static', [3]);
								animation.add('pressed', [39, 43], 12, false);
								animation.add('confirm', [47, 51], 24, false);
								if (flippedNotes)
								{
									animation.add('static', [0]);
									animation.add('pressed', [36, 40], 12, false);
									animation.add('confirm', [44, 48], 24, false);
								}
						}
					
	
					case 7:
					
						switch (Math.abs(noteData))
						{
							case 0:
								
								animation.add('static', [0]);
								animation.add('pressed', [4, 8], 12, false);
								animation.add('confirm', [12, 16], 24, false);
								if (flippedNotes)
								{
									animation.add('static', [3]);
									animation.add('pressed', [7, 11], 12, false);
									animation.add('confirm', [15, 19], 24, false);
								}
							case 1:
							
								animation.add('static', [2]);
								animation.add('pressed', [6, 10], 12, false);
								animation.add('confirm', [14, 18], 12, false);
								if (flippedNotes)
								{
									animation.add('static', [1]);
									animation.add('pressed', [5, 9], 12, false);
									animation.add('confirm', [13, 17], 12, false);
								}
							case 2:
							
	
								animation.add('static', [3]);
								animation.add('pressed', [7, 11], 12, false);
								animation.add('confirm', [15, 19], 24, false);
								if (flippedNotes)
								{
									animation.add('static', [0]);
									animation.add('pressed', [4, 8], 12, false);
									animation.add('confirm', [12, 16], 24, false);
								}
							case 3:
							
								animation.add('static', [52]);
								animation.add('pressed', [55, 53], 12, false);
								animation.add('confirm', [54, 55], 24, false);
							case 4:
							
								animation.add('static', [0]);
								animation.add('pressed', [36, 40], 12, false);
								animation.add('confirm', [44, 48], 24, false);
								if (flippedNotes)
								{
									animation.add('static', [3]);
									animation.add('pressed', [39, 43], 12, false);
									animation.add('confirm', [47, 51], 24, false);
								}
							case 5:
							
								animation.add('static', [1]);
								animation.add('pressed', [5, 9], 12, false);
								animation.add('confirm', [13, 17], 12, false);
								if (flippedNotes)
								{
									animation.add('static', [2]);
									animation.add('pressed', [6, 10], 12, false);
									animation.add('confirm', [14, 18], 12, false);
								}
							case 6:
								
								animation.add('static', [3]);
								animation.add('pressed', [39, 43], 12, false);
								animation.add('confirm', [47, 51], 24, false);
								if (flippedNotes)
								{
									animation.add('static', [0]);
									animation.add('pressed', [36, 40], 12, false);
									animation.add('confirm', [44, 48], 24, false);
								}
						
					}
	
					case 9:
					
						switch (Math.abs(noteData))
						{
							case 0:
							
								animation.add('static', [0]);
								animation.add('pressed', [4, 8], 12, false);
								animation.add('confirm', [12, 16], 24, false);
								if (flippedNotes)
								{
									animation.add('static', [3]);
									animation.add('pressed', [7, 11], 12, false);
									animation.add('confirm', [15, 19], 24, false);
								}
							case 1:
							
								animation.add('static', [1]);
								animation.add('pressed', [5, 9], 12, false);
								animation.add('confirm', [13, 17], 24, false);
								if (flippedNotes)
								{
									animation.add('static', [2]);
									animation.add('pressed', [6, 10], 12, false);
									animation.add('confirm', [14, 18], 12, false);
								}
							case 2:
							
								animation.add('static', [2]);
								animation.add('pressed', [6, 10], 12, false);
								animation.add('confirm', [14, 18], 12, false);
								if (flippedNotes)
								{
									animation.add('static', [1]);
									animation.add('pressed', [5, 9], 12, false);
									animation.add('confirm', [13, 17], 12, false);
								}
							case 3:
							
								animation.add('static', [3]);
								animation.add('pressed', [7, 11], 12, false);
								animation.add('confirm', [15, 19], 24, false);
								if (flippedNotes)
								{
									animation.add('static', [0]);
									animation.add('pressed', [4, 8], 12, false);
									animation.add('confirm', [12, 16], 24, false);
								}
							case 4:
								
								animation.add('static', [52]);
								animation.add('pressed', [55, 53], 12, false);
								animation.add('confirm', [54, 55], 24, false);
							case 5:
								
								animation.add('static', [0]);
								animation.add('pressed', [36, 40], 12, false);
								animation.add('confirm', [44, 48], 24, false);
								if (flippedNotes)
								{
									animation.add('static', [3]);
									animation.add('pressed', [39, 43], 12, false);
									animation.add('confirm', [47, 51], 24, false);
								}
							case 6:
								
								animation.add('static', [1]);
								animation.add('pressed', [37, 41], 12, false);
								animation.add('confirm', [45, 49], 12, false);
								if (flippedNotes)
								{
									animation.add('static', [2]);
									animation.add('pressed', [38, 42], 12, false);
									animation.add('confirm', [46, 50], 12, false);
								}
							case 7:
								
								animation.add('static', [2]);
								animation.add('pressed', [38, 42], 12, false);
								animation.add('confirm', [46, 50], 12, false);
								if (flippedNotes)
								{
									animation.add('static', [1]);
									animation.add('pressed', [37, 41], 12, false);
									animation.add('confirm', [45, 49], 12, false);
								}
							case 8:
								
								animation.add('static', [3]);
								animation.add('pressed', [39, 43], 12, false);
								animation.add('confirm', [47, 51], 24, false);
								if (flippedNotes)
								{
									animation.add('static', [0]);
									animation.add('pressed', [36, 40], 12, false);
									animation.add('confirm', [44, 48], 24, false);
								}
						}
					}
				
		}
		else
		{
			
				animation.addByPrefix('green', 'arrowUP');
				animation.addByPrefix('blue', 'arrowDOWN');
				animation.addByPrefix('purple', 'arrowLEFT');
				animation.addByPrefix('red', 'arrowRIGHT');
				animation.addByPrefix('white', 'arrowSPACE');

				if (animation.getByName('white') == null)
				{
					animation.addByPrefix('white', 'arrowUP');
				}

				if (flippedNotes)
				{
					animation.addByPrefix('blue', 'arrowUP');
					animation.addByPrefix('green', 'arrowDOWN');
					animation.addByPrefix('red', 'arrowLEFT');
					animation.addByPrefix('purple', 'arrowRIGHT');
				}
				antialiasing = true;
				setGraphicSize(Std.int(width * Note.scales[PlayState.SONG.mania]));

				PlayState.instance.setArrowsAnim(this,noteData);
		}
		updateHitbox();

		if(lastAnim != null)
		{
			playAnim(lastAnim, true);
		}
	}
	
	public function postAddedToGroup() {
		playAnim('static');
		x += Note.swidths[PlayState.SONG.mania] * Note.swagWidth * noteData;
		x += 50;
		x += ((FlxG.width / 2) * player);
		x -= Note.posRest[PlayState.SONG.mania];
		ID = noteData;
	}

	override function update(elapsed:Float) {
		if(resetAnim > 0) {
			resetAnim -= elapsed;
			if(resetAnim <= 0) {
				playAnim('static');
				resetAnim = 0;
			}
		}
		//if(animation.curAnim != null){ //my bad i was upset
		if(animation.curAnim.name == 'confirm' && !isPixelNote) {
			var daOffset = [0.0,0.0];
			if (animOffsets.exists('confirm'))
				{
					daOffset = animOffsets.get('confirm');
				}
			offset.x = (frameWidth - width) * 0.5+ daOffset[0];
		offset.y = (frameHeight - height) * 0.5 + daOffset[1];
			
		//}
		}

		super.update(elapsed);
	}

	public function playAnim(anim:String, ?force:Bool = false) {
		animation.play(anim, force);
		var daOffset = [0.0,0.0];
		if (animOffsets.exists(anim))
			{
		 daOffset = animOffsets.get(anim);
			}
		offset.x = (frameWidth - width) * 0.5 +daOffset[0];
		offset.y = (frameHeight - height) * 0.5 + daOffset[1];
		centerOrigin();
		if(animation.curAnim == null || animation.curAnim.name == 'static') {
	//do nothing...since no shader... or you can add stuff here idk lol
		} else {
			if(animation.curAnim.name == 'confirm' && !isPixelNote) {
				centerOrigin();
			}
		}
	}
}
