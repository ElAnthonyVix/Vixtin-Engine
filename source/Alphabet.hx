package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import flixel.math.FlxPoint;
using StringTools;
enum Alignment
{
	LEFT;
	CENTERED;
	RIGHT;
}

/**
 * Loosley based on FlxTypeText lolol
 */
class Alphabet extends FlxSpriteGroup
{
	public var delay:Float = 0.05;
	public var paused:Bool = false;
	public var letters:Array<AlphaCharacter> = [];
	// for menu shit
	public var targetY:Float = 0;
	public var isMenuItem:Bool = false;
	public var itemType:String = "Classic";
	public var text:String = "";
	public var changeX:Bool = true;
	public var changeY:Bool = true;
	var _finalText:String = "";
	var _curText:String = "";

	public var widthOfWords:Float = FlxG.width;

	var yMulti:Float = 1;
	var isStepped:Bool = true;
	var isWheel:Bool = false;
	var groupX:Float = 90;
	var groupY:Float = 0.48;
	// custom shit
	// amp, backslash, question mark, apostrophy, comma, angry faic, period
	var lastSprite:AlphaCharacter;
	var xPosResetted:Bool = false;
	var lastWasSpace:Bool = false;
	var lastWasEscape:Bool = false;
	var drawHypens:Bool = false;
	var splitWords:Array<String> = [];
	public var scaleX(default, set):Float = 1;
	public var scaleY(default, set):Float = 1;
	public var rows:Int = 0;

	var isBold:Bool = false;

	public function new(x:Float, y:Float, text:String = "", ?bold:Bool = false, ?typed:Bool = false, ?stepped:Bool = true, ?alignX:Float = 90, ?alignY:Float = 0.48, ?drawHypens:Bool = false, ?wheel:Bool = false)
	{
		super(x, y);

		_finalText = text;
		this.text = text;
		isBold = bold;
		isStepped = stepped;
		this.isWheel = wheel;
		if (!isStepped) {
			itemType = "Vertical";
		} 
		if (isWheel) {
			itemType = "D-Shape";
		}
		groupX = alignX;
		groupY = alignY;
		this.drawHypens = drawHypens;
		if (text != "")
		{
			if (typed)
			{
				startTypedText();
			}
			else
			{
				addText();
			}
		}
	}
	private function set_scaleX(value:Float)
		{
			if (value == scaleX) return value;
	
			scale.x = value;
			for (letter in letters)
			{
				if(letter != null)
				{
					letter.updateHitbox();
					//letter.updateLetterOffset();
					var ratio:Float = (value / letter.spawnScale.x);
					letter.x = letter.spawnPos.x * ratio;
				}
			}
			scaleX = value;
			return value;
		}
	
		private function set_scaleY(value:Float)
		{
			if (value == scaleY) return value;
	
			scale.y = value;
			for (letter in letters)
			{
				if(letter != null)
				{
					letter.updateHitbox();
					letter.updateLetterOffset();
					var ratio:Float = (value / letter.spawnScale.y);
					letter.y = letter.spawnPos.y * ratio;
				}
			}
			scaleY = value;
			return value;
		}
	public function clearText() {
		var kidsToMurder:Array<FlxSprite> = [];
		forEach(function (sprite:FlxSprite) {
			kidsToMurder.push(sprite);
		});
		clear();
		for( kid in kidsToMurder ) {
			kid.destroy();
		}

	}
	public function addText()
	{
		_finalText = text;
		clearText();
		lastSprite = null;
		lastWasSpace = false;
		lastWasEscape = false;
		xPosResetted = false;
		doSplitWords();
		var xPos:Float = 0;
		for (character in splitWords)
		{
			// if (character.fastCodeAt() == " ")
			// {
			// }
			// doing dummy character bs because idk how for loops in haxe work
			var dummyCharacter = character;
			if (dummyCharacter == " " || (dummyCharacter == "-" && !drawHypens))
			{
				lastWasSpace = true;
				continue;
			}
			// make grave or whatever? 
			if ((dummyCharacter == "\\" || dummyCharacter == "`") && !lastWasEscape) {
				lastWasEscape = true;
				continue;
			}
			if (lastWasEscape) {
				switch (dummyCharacter) {
					case "\\":
						// do nothing
					case "v":
						dummyCharacter = "da";
					case ">":
						dummyCharacter = "ra";
					case "<":
						dummyCharacter = "la";
					case "^":
						dummyCharacter = "ua";
					case "h":
						dummyCharacter = "heart";
				}
				lastWasEscape = false;
			}
			if ((AlphaCharacter.alphabet.indexOf(dummyCharacter.toLowerCase()) != -1 || AlphaCharacter.numbers.indexOf(dummyCharacter) != -1 || StringTools.contains(AlphaCharacter.symbols,dummyCharacter)))
				// if (AlphaCharacter.alphabet.contains(character.toLowerCase()))
			{
				if (lastSprite != null)
				{
					xPos = lastSprite.x + lastSprite.width;
				}

				if (lastWasSpace)
				{
					xPos += 40;
					lastWasSpace = false;
				}

				// var letter:AlphaCharacter = new AlphaCharacter(30 * loopNum, 0);
				var letter:AlphaCharacter = new AlphaCharacter(xPos, 0);
				letter.x += letter.letterOffset[0] * scaleX;
				letter.y -= letter.letterOffset[1] * scaleY;
				if (isBold)
					letter.createBold(dummyCharacter);
				else
				{
					letter.createLetter(dummyCharacter);
				}

				add(letter);
				letters.push(letter);
				lastSprite = letter;
			}

			// loopNum += 1;
		}
		for (letter in letters)
			{
				letter.spawnPos.set(letter.x, letter.y);
				letter.spawnScale.set(scaleX, scaleY);
			}
	
	}

	function doSplitWords():Void
	{
		splitWords = _finalText.split("");
	}

	public var personTalking:String = 'gf';

	public function startTypedText():Void
	{
		_finalText = text;
		doSplitWords();

		// trace(arrayShit);

		var loopNum:Int = 0;

		var xPos:Float = 0;
		var curRow:Int = 0;

		new FlxTimer().start(0.05, function(tmr:FlxTimer)
		{
			// trace(_finalText.fastCodeAt(loopNum) + " " + _finalText.charAt(loopNum));
			if (_finalText.fastCodeAt(loopNum) == "\n".code)
			{
				yMulti += 1;
				xPosResetted = true;
				xPos = 0;
				curRow += 1;
			}

			if (splitWords[loopNum] == " ")
			{
				lastWasSpace = true;
			}

			#if (haxe >= "4.0.0")
			var isNumber:Bool = AlphaCharacter.numbers.contains(splitWords[loopNum]);
			var isSymbol:Bool = AlphaCharacter.symbols.contains(splitWords[loopNum]);
			#else
			var isNumber:Bool = AlphaCharacter.numbers.indexOf(splitWords[loopNum]) != -1;
			var isSymbol:Bool = AlphaCharacter.symbols.indexOf(splitWords[loopNum]) != -1;
			#end

			if (AlphaCharacter.alphabet.indexOf(splitWords[loopNum].toLowerCase()) != -1 || isNumber || isSymbol)
				// if (AlphaCharacter.alphabet.contains(splitWords[loopNum].toLowerCase()) || isNumber || isSymbol)

			{
				if (lastSprite != null && !xPosResetted)
				{
					lastSprite.updateHitbox();
					xPos += lastSprite.width + 3;
					// if (isBold)
					// xPos -= 80;
				}
				else
				{
					xPosResetted = false;
				}

				if (lastWasSpace)
				{
					xPos += 20;
					lastWasSpace = false;
				}
				// trace(_finalText.fastCodeAt(loopNum) + " " + _finalText.charAt(loopNum));

				// var letter:AlphaCharacter = new AlphaCharacter(30 * loopNum, 0);
				var letter:AlphaCharacter = new AlphaCharacter(xPos, 55 * yMulti);
				letter.x += letter.letterOffset[0] * scaleX;
				letter.y -= letter.letterOffset[1] * scaleY;
				letter.row = curRow;
				if (isBold)
				{
					letter.createBold(splitWords[loopNum]);
				}
				else
				{
					if (isNumber)
					{
						letter.createNumber(splitWords[loopNum]);
					}
					else if (isSymbol)
					{
						letter.createSymbol(splitWords[loopNum]);
					}
					else
					{
						letter.createLetter(splitWords[loopNum]);
					}

					letter.x += 90;
				}

				if (FlxG.random.bool(40))
				{
					var daSound:String = "GF_";
					FlxG.sound.play('assets/sounds/' + daSound + FlxG.random.int(1, 4) + TitleState.soundExt, 0.4);
				}

				add(letter);
				letters.push(letter);
				lastSprite = letter;
			}

			loopNum += 1;

			tmr.time = FlxG.random.float(0.04, 0.09);
		}, splitWords.length);
		for (letter in letters)
			{
				letter.spawnPos.set(letter.x, letter.y);
				letter.spawnScale.set(scaleX, scaleY);
			}
	}

	override function update(elapsed:Float)
	{
		if (isMenuItem)
		{
			var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);

			switch (itemType) {
				case "Classic":
					x = FlxMath.lerp(x, (targetY * 20) + groupX, 0.16 / (CoolUtil.fps / 60));
					y = FlxMath.lerp(y, (scaledY * 120) + (FlxG.height * groupY), 0.16 / (CoolUtil.fps / 60));
				case "Vertical":
					y = FlxMath.lerp(y, (scaledY * 120) + (FlxG.height * 0.5), 0.16 / (CoolUtil.fps / 60));
					// x = FlxMath.lerp(x, (targetY * 0) + 308, 0.16 / 2);
				case "C-Shape":
					// not actually a wheel, just trying to imitate mic'd up
					// use exponent because circles????
					// using equation of a sideways parabola.
					// x = a(y-k)^2 + h
					// k is probably inaccurate because, well, the coordinate system
					// is flipped veritcally.
					// We still use lerp as that just makes it move smoothly.
					// I'm going to add instead and see how that works.

					// :grief: i give up time to steal code
					y = FlxMath.lerp(y, (scaledY * 65) + (FlxG.height * 0.39), 0.16 / (CoolUtil.fps / 60));

					x = FlxMath.lerp(x, Math.exp(scaledY * 0.8) * 70 + (FlxG.width * 0.1), 0.16 / (CoolUtil.fps / 60));
					if (scaledY < 0)
						x = FlxMath.lerp(x, Math.exp(scaledY * -0.8) * 70 + (FlxG.width * 0.1), 0.16 / (CoolUtil.fps / 60));

					if (x > FlxG.width + 30)
						x = FlxG.width + 30;

				case "D-Shape":
					y = FlxMath.lerp(y, (scaledY * 90) + (FlxG.height * 0.45), 0.16 / (CoolUtil.fps / 60));

					x = FlxMath.lerp(x, Math.exp(Math.abs(scaledY * 0.8)) * -70 + (FlxG.width * 0.35), 0.16 / (CoolUtil.fps / 60));

					if (x < -900)
						x = -900;
			}
		}

		super.update(elapsed);
	}
}
typedef Letter = {
	?anim:Null<String>,
	?offsets:Array<Float>,
	?offsetsBold:Array<Float>
}

class AlphaCharacter extends FlxSprite
{
	public static var alphabet:String = "abcdefghijklmnopqrstuvwxyz";
	public static var allLetters:Map<String, Null<Letter>> = [
		//alphabet
		'a'  => null, 'b'  => null, 'c'  => null, 'd'  => null, 'e'  => null, 'f'  => null,
		'g'  => null, 'h'  => null, 'i'  => null, 'j'  => null, 'k'  => null, 'l'  => null,
		'm'  => null, 'n'  => null, 'o'  => null, 'p'  => null, 'q'  => null, 'r'  => null,
		's'  => null, 't'  => null, 'u'  => null, 'v'  => null, 'w'  => null, 'x'  => null,
		'y'  => null, 'z'  => null,
		
		//numbers
		'0'  => null, '1'  => null, '2'  => null, '3'  => null, '4'  => null,
		'5'  => null, '6'  => null, '7'  => null, '8'  => null, '9'  => null,

		//symbols
		'&'  => {offsetsBold: [0, 2]},
		'('  => {offsetsBold: [0, 5]},
		')'  => {offsetsBold: [0, 5]},
		'*'  => {offsets: [0, 28]},
		'+'  => {offsets: [0, 7], offsetsBold: [0, -12]},
		'-'  => {offsets: [0, 16], offsetsBold: [0, -30]},
		'<'  => {offsetsBold: [0, 4]},
		'>'  => {offsetsBold: [0, 4]},
		'\'' => {anim: 'apostrophe', offsets: [0, 32]},
		'"'  => {anim: 'quote', offsets: [0, 32], offsetsBold: [0, 0]},
		'!'  => {anim: 'exclamation', offsetsBold: [0, 10]},
		'?'  => {anim: 'question', offsetsBold: [0, 4]},			//also used for "unknown"
		'.'  => {anim: 'period', offsetsBold: [0, -44]},
		'❝'  => {anim: 'start quote', offsets: [0, 24], offsetsBold: [0, -5]},
		'❞'  => {anim: 'end quote', offsets: [0, 24], offsetsBold: [0, -5]},

		//symbols with no bold
		'_'  => null,
		'#'  => null,
		'$'  => null,
		'%'  => null,
		':'  => {offsets: [0, 2]},
		';'  => {offsets: [0, -2]},
		'@'  => null,
		'['  => null,
		']'  => {offsets: [0, -1]},
		'^'  => {offsets: [0, 28]},
		','  => {anim: 'comma', offsets: [0, -6]},
		'\\' => {anim: 'back slash', offsets: [0, 0]},
		'/'  => {anim: 'forward slash', offsets: [0, 0]},
		'|'  => null,
		'~'  => {offsets: [0, 16]}
	];
	public static var numbers:String = "1234567890";

	public static var symbols:String = ".,'!/?\\-+_#$%&()*:;<=>@[]^|~\"daralauaheart";
	public var spawnPos:FlxPoint = new FlxPoint();
	public var row:Int = 0;
	public var letterOffset:Array<Float> = [0, 0];
	public var spawnScale:FlxPoint = new FlxPoint();
	public function new(x:Float, y:Float)
	{
		super(x, y);
		var tex = FlxAtlasFrames.fromSparrow('assets/images/alphabet.png', 'assets/images/alphabet.xml');
		frames = tex;

		antialiasing = true;
	}

	public function createBold(letter:String)
	{
		var curLetter:Letter = null;
		var lowercase = letter.toLowerCase();
		if(allLetters.exists(lowercase)) curLetter = allLetters.get(lowercase);
		if(curLetter != null && curLetter.offsetsBold != null)
			{
				letterOffset[0] = curLetter.offsetsBold[0];
				letterOffset[1] = curLetter.offsetsBold[1];
			}
		if (StringTools.contains(alphabet, letter) || StringTools.contains(numbers, letter)) {
			animation.addByPrefix(letter, letter.toUpperCase() + " bold", 24);
			animation.play(letter);
			updateHitbox();
		} else {
			var animName = "";
			switch (letter)
			{
				case '.':
					animName = "period bold";
					y += 50;
				case "'":
					animName = "apostraphie bold";
					y -= 0;
				case "?":
					animName = "question mark bold";
				case "!":
					animName = "exclamation point bold";
				case ",":
					animName = "comma bold";
					y += 50;
				case "\\":
					animName = "bs bold";
				case "/":
					animName = "fs bold";
				case "da":
					animName = "down arrow bold";
				case "ua":
					animName = "up arrow bold";
				case "la":
					animName = "left arrow bold";
				case "heart":
					animName = "heart bold";
				case "ra":
					animName = "right arrow bold";
				case "\"":
					animName = "quote";
				default:
					animName = letter + " bold";
					switch (letter) {
						case "-" | "~" | "+":
							y += 25;
						case "_":
							y += 50;
					}

			}
			animation.addByPrefix(letter, animName, 24);
			animation.play(letter);
			updateHitbox();
			updateLetterOffset();
		}

	}

	public function createLetter(letter:String):Void
	{
		var curLetter:Letter = null;
		var lowercase = character.toLowerCase();
		if(allLetters.exists(lowercase)) curLetter = allLetters.get(lowercase);
		if(curLetter != null && curLetter.offsets != null)
			{
				letterOffset[0] = curLetter.offsets[0];
				letterOffset[1] = curLetter.offsets[1];
			}

		if (StringTools.contains(alphabet, letter)) {
			var letterCase:String = "lowercase";
			if (letter.toLowerCase() != letter)
			{
				letterCase = 'capital';
			}

			animation.addByPrefix(letter, letter + " " + letterCase, 24);
			animation.play(letter);
			updateHitbox();

			FlxG.log.add('the row' + row);

			y = (110 - height);
			y += row * 60;
	  } else if (StringTools.contains(numbers,letter)) {
			createNumber(letter);
		} else if (StringTools.contains(symbols,letter)) {
			createSymbol(letter);
		}
	}

	public function createNumber(letter:String):Void
	{
		var curLetter:Letter = null;
		var lowercase = character.toLowerCase();
		if(allLetters.exists(lowercase)) curLetter = allLetters.get(lowercase);
		if(curLetter != null && curLetter.offsets != null)
			{
				letterOffset[0] = curLetter.offsets[0];
				letterOffset[1] = curLetter.offsets[1];
			}
		animation.addByPrefix(letter, letter, 24);
		animation.play(letter);

		updateHitbox();
	}

	public function createSymbol(letter:String)
	{
		var curLetter:Letter = null;
		var lowercase = character.toLowerCase();
		if(allLetters.exists(lowercase)) curLetter = allLetters.get(lowercase);
		if(curLetter != null && curLetter.offsets != null)
			{
				letterOffset[0] = curLetter.offsets[0];
				letterOffset[1] = curLetter.offsets[1];
			}
		switch (letter)
		{
			case '.':
				animation.addByPrefix(letter, 'period', 24);
				animation.play(letter);
				y += 50;
			case "'":
				animation.addByPrefix(letter, 'apostraphie', 24);
				animation.play(letter);
				y -= 0;
			case "?":
				animation.addByPrefix(letter, 'question mark', 24);
				animation.play(letter);
			case "!":
				animation.addByPrefix(letter, 'exclamation point', 24);
				animation.play(letter);
			case ",":
				animation.addByPrefix(letter, 'comma', 24);
				animation.play(letter);
			case "\\":
				animation.addByPrefix(letter, 'bs', 24);
				animation.play(letter);
			case "/":
				animation.addByPrefix(letter, 'fs', 24);
				animation.play(letter);
			case "da":
				animation.addByPrefix(letter, 'down arrow', 24);
				animation.play(letter);
			case "ua":
				animation.addByPrefix(letter, 'up arrow', 24);
				animation.play(letter);
			case "la":
				animation.addByPrefix(letter, 'left arrow', 24);
				animation.play(letter);
			case "heart":
				animation.addByPrefix(letter, 'heart', 24);
				animation.play(letter);
			case "ra":
				animation.addByPrefix(letter, 'right arrow', 24);
				animation.play(letter);
			default:
				animation.addByPrefix(letter, letter.toLowerCase(), 24);
				animation.play(letter);
				switch (letter) {
					case "-":
						y += 25;
					case "_":
						y += 50;
					case "~":
						y += 25;
					case "+":
						y += 25;
				}
		}

		updateHitbox();
	}
	public function updateLetterOffset()
		{
			if (animation.curAnim == null) return;
	
			if(!animation.curAnim.name.endsWith('bold'))
			{
				offset.y += -(110 - height);
			}
		}
}
