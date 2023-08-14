package;

import flixel.input.gamepad.mappings.XInputMapping;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.input.keyboard.FlxKey;
using Lambda;
class ControlsState extends MusicBeatState {
    var askToBind:FlxTypedSpriteGroup<FlxSprite>;
    var bindTxt:FlxText;
    var askingToBind:Bool = false;
    var grpBind:FlxTypedGroup<Alphabet>;
    var awaitingFor:Int = -1;
    var curSelected:Int = 0;
    override function create() {
        
        FlxG.mouse.visible = true;
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(SUtil.getPath() + 'assets/images/menuBG.png');
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.2));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg); 
        askToBind = new FlxTypedSpriteGroup<FlxSprite>();
        var askGraphic = new FlxSprite().makeGraphic(Std.int(FlxG.width/2),Std.int(FlxG.height/2), FlxColor.YELLOW);
        bindTxt = new FlxText(60, 20, 0, "Waiting for input\n (press esc or enter to stop binding)");
        bindTxt.setFormat(null, 24, FlxColor.BLACK);
        askToBind.add(askGraphic);
        askToBind.add(bindTxt);
        askToBind.visible = false;
        askToBind.x = 500;
        askToBind.y = 80;
        grpBind = new FlxTypedGroup<Alphabet>();
        add(grpBind);

        for (i in 0...4) {
			var coolText = switch (i)
			{
				case 0:
					'Left: ${FlxG.save.data.keys.left.map(function (key:FlxKey) {return FlxKey.toStringMap.get(key);}).join(",")}';
				case 1:
					'Down: ${FlxG.save.data.keys.down.map(function (key:FlxKey) {return FlxKey.toStringMap.get(key);}).join(",")}';
				case 2:
					'Up: ${FlxG.save.data.keys.up.map(function (key:FlxKey) {return FlxKey.toStringMap.get(key);}).join(",")}';
				case 3:
					'Right: ${FlxG.save.data.keys.right.map(function (key:FlxKey) {return FlxKey.toStringMap.get(key);}).join(",")}';
				default:
					'how did we get here';
			}
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, coolText, true, false, false, null, null, null, true);
			songText.itemType = "Classic";
			songText.isMenuItem = true;
			songText.targetY = i;
			grpBind.add(songText);
        }

		for (i in 0...7) {
			var coolText6K = switch (i)
			{
				case 0:
					'Left-6/7k: ${FlxG.save.data.keys.A1.map(function (key:FlxKey) {return FlxKey.toStringMap.get(key);}).join(",")}';
				case 1:
					'Up-6/7k: ${FlxG.save.data.keys.A2.map(function (key:FlxKey) {return FlxKey.toStringMap.get(key);}).join(",")}';
				case 2:
					'Right-6/7k: ${FlxG.save.data.keys.A3.map(function (key:FlxKey) {return FlxKey.toStringMap.get(key);}).join(",")}';
				case 3:
					'Middle-7k: ${FlxG.save.data.keys.A4.map(function (key:FlxKey) {return FlxKey.toStringMap.get(key);}).join(",")}';
				case 4:
					'Left2-6/7k: ${FlxG.save.data.keys.A5.map(function (key:FlxKey) {return FlxKey.toStringMap.get(key);}).join(",")}';
				case 5:
					'Down-6/7k: ${FlxG.save.data.keys.A6.map(function (key:FlxKey) {return FlxKey.toStringMap.get(key);}).join(",")}';
				case 6:
					'Right2-6/7k: ${FlxG.save.data.keys.A7.map(function (key:FlxKey) {return FlxKey.toStringMap.get(key);}).join(",")}';
				default:
					'how did we get here';
			}
			var songText:Alphabet = new Alphabet(0, (70 * (i + 4)) + 30, coolText6K, true, false, false, null, null, null, true);
			songText.itemType = "Classic";
			songText.isMenuItem = true;
			songText.targetY = i + 4;
			grpBind.add(songText);
        }

		for (i in 0...9) {
			var coolText9K = switch (i)
			{
				case 0:
					'Left-9k: ${FlxG.save.data.keys.B1.map(function (key:FlxKey) {return FlxKey.toStringMap.get(key);}).join(",")}';
				case 1:
					'Down-9k: ${FlxG.save.data.keys.B2.map(function (key:FlxKey) {return FlxKey.toStringMap.get(key);}).join(",")}';
				case 2:
					'Up-9k: ${FlxG.save.data.keys.B3.map(function (key:FlxKey) {return FlxKey.toStringMap.get(key);}).join(",")}';
				case 3:
					'Right-9k: ${FlxG.save.data.keys.B4.map(function (key:FlxKey) {return FlxKey.toStringMap.get(key);}).join(",")}';
				case 4:
					'Middle-9k: ${FlxG.save.data.keys.B5.map(function (key:FlxKey) {return FlxKey.toStringMap.get(key);}).join(",")}';
			    case 5:
					'Left2-9k: ${FlxG.save.data.keys.B6.map(function (key:FlxKey) {return FlxKey.toStringMap.get(key);}).join(",")}';
				case 6:
					'Down2-9k: ${FlxG.save.data.keys.B7.map(function (key:FlxKey) {return FlxKey.toStringMap.get(key);}).join(",")}';
				case 7:
					'Up2-9k: ${FlxG.save.data.keys.B8.map(function (key:FlxKey) {return FlxKey.toStringMap.get(key);}).join(",")}';
				case 8:
					'Right2-9k: ${FlxG.save.data.keys.B9.map(function (key:FlxKey) {return FlxKey.toStringMap.get(key);}).join(",")}';
				default:
					'how did we get here';
			}
			var songText:Alphabet = new Alphabet(0, (70 * (i + 11)) + 30, coolText9K, true, false, false, null, null, null, true);
			songText.itemType = "Classic";
			songText.isMenuItem = true;
			songText.targetY = i + 11;
			grpBind.add(songText);
        }
        add(askToBind);
		#if mobile
		addVirtualPad(UP_DOWN, A_B);
		#end
        super.create();
    }
	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(SUtil.getPath() + 'assets/sounds/custom_menu_sounds/'
			+ CoolUtil.parseJson(FNFAssets.getText(SUtil.getPath() + "assets/sounds/custom_menu_sounds/custom_menu_sounds.json")).customMenuScroll
			+ '/scrollMenu'
			+ TitleState.soundExt,
			0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = 19;
		if (curSelected >= 20)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		// comment out because lag?
		// if (!soundTest)
		//	FlxG.sound.playMusic(FNFAssets.getSound(SUtil.getPath() + "assets/music/"+songs[curSelected].songName+"_Inst"+TitleState.soundExt), 0);
		var bullShit:Int = 0;

		for (item in grpBind.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
		/*
			var dealphaedColors:Array<FlxColor> = [];
			for (color in (Reflect.field(charJson,songs[curSelected].songCharacter).colors : Array<String>)) {
				var newColor = FlxColor.fromString(color);
				newColor.alphaFloat = 0.5;
				dealphaedColors.push(newColor);
		}*/
		// remove(curOverlay);
		// curOverlay = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, dealphaedColors);
		// insert(1, curOverlay);
	}
	var currentKeys:Array<FlxKey> = [];
    override function update(elapsed:Float) {
        super.update(elapsed);
        if (!askingToBind) {
			if (controls.ACCEPT)
			{
				awaitingFor = curSelected;
				// SUS?
				askingToBind = true;
                askToBind.visible = true;
			}
            if (controls.UP_MENU) {
                changeSelection(-1);
            } else if (controls.DOWN_MENU) {
                changeSelection(1);
            }
            if (controls.BACK) {
                LoadingState.loadAndSwitchState(new SaveDataState());
            }
        } else {
			if (FlxG.keys.firstJustPressed() == ESCAPE || FlxG.keys.firstJustPressed() == ENTER) {
				if (currentKeys.length != 0) {
					switch (awaitingFor)
					{
						case 0:
							FlxG.save.data.keys.left = currentKeys;
						case 1:
							FlxG.save.data.keys.down = currentKeys;
						case 2:
							FlxG.save.data.keys.up = currentKeys;
						case 3:
							FlxG.save.data.keys.right = currentKeys;
						case 4:
							FlxG.save.data.keys.A1 = currentKeys;
						case 5:
							FlxG.save.data.keys.A2 = currentKeys;
						case 6:
							FlxG.save.data.keys.A3 = currentKeys;
						case 7:
							FlxG.save.data.keys.A4 = currentKeys;
						case 8:
							FlxG.save.data.keys.A5 = currentKeys;
						case 9:
							FlxG.save.data.keys.A6 = currentKeys;
						case 10:
							FlxG.save.data.keys.A7 = currentKeys;
						case 11:
							FlxG.save.data.keys.B1 = currentKeys;
						case 12:
							FlxG.save.data.keys.B2 = currentKeys;
						case 13:
							FlxG.save.data.keys.B3 = currentKeys;
						case 14:
							FlxG.save.data.keys.B4 = currentKeys;
						case 15:
							FlxG.save.data.keys.B5 = currentKeys;
						case 16:
							FlxG.save.data.keys.B6 = currentKeys;
						case 17:
							FlxG.save.data.keys.B7 = currentKeys;
						case 18:
							FlxG.save.data.keys.B8 = currentKeys;
						case 19:
							FlxG.save.data.keys.B9 = currentKeys;
					}
					var coolText = switch (awaitingFor)
					{
						case 0:
							'Left: ${FlxG.save.data.keys.left.map(function (key:FlxKey) { return FlxKey.toStringMap.get(key);}).join(",")}';
						case 1:
							'Down: ${FlxG.save.data.keys.down.map(function (key:FlxKey) { return FlxKey.toStringMap.get(key);}).join(",")}';
						case 2:
							'Up: ${FlxG.save.data.keys.up.map(function (key:FlxKey) { return FlxKey.toStringMap.get(key);}).join(",")}';
						case 3:
							'Right: ${FlxG.save.data.keys.right.map(function (key:FlxKey) { return FlxKey.toStringMap.get(key);}).join(",")}';
							case 4:
								'Left-6/7k: ${FlxG.save.data.keys.A1.map(function (key:FlxKey) {return FlxKey.toStringMap.get(key);}).join(",")}';
							case 5:
								'Up-6/7k: ${FlxG.save.data.keys.A2.map(function (key:FlxKey) {return FlxKey.toStringMap.get(key);}).join(",")}';
							case 6:
								'Right-6/7k: ${FlxG.save.data.keys.A3.map(function (key:FlxKey) {return FlxKey.toStringMap.get(key);}).join(",")}';
							case 7:
								'Middle-7k: ${FlxG.save.data.keys.A4.map(function (key:FlxKey) {return FlxKey.toStringMap.get(key);}).join(",")}';
							case 8:
								'Left2-6/7k: ${FlxG.save.data.keys.A5.map(function (key:FlxKey) {return FlxKey.toStringMap.get(key);}).join(",")}';
							case 9:
								'Down-6/7k: ${FlxG.save.data.keys.A6.map(function (key:FlxKey) {return FlxKey.toStringMap.get(key);}).join(",")}';
							case 10:
								'Right2-6/7k: ${FlxG.save.data.keys.A7.map(function (key:FlxKey) {return FlxKey.toStringMap.get(key);}).join(",")}';	
				case 11:
					'Left-9k: ${FlxG.save.data.keys.B1.map(function (key:FlxKey) {return FlxKey.toStringMap.get(key);}).join(",")}';
				case 12:
					'Down-9k: ${FlxG.save.data.keys.B2.map(function (key:FlxKey) {return FlxKey.toStringMap.get(key);}).join(",")}';
				case 13:
					'Up-9k: ${FlxG.save.data.keys.B3.map(function (key:FlxKey) {return FlxKey.toStringMap.get(key);}).join(",")}';
				case 14:
					'Right-9k: ${FlxG.save.data.keys.B4.map(function (key:FlxKey) {return FlxKey.toStringMap.get(key);}).join(",")}';
				case 15:
					'Middle-9k: ${FlxG.save.data.keys.B5.map(function (key:FlxKey) {return FlxKey.toStringMap.get(key);}).join(",")}';
			    case 16:
					'Left2-9k: ${FlxG.save.data.keys.B6.map(function (key:FlxKey) {return FlxKey.toStringMap.get(key);}).join(",")}';
				case 17:
					'Down2-9k: ${FlxG.save.data.keys.B7.map(function (key:FlxKey) {return FlxKey.toStringMap.get(key);}).join(",")}';
				case 18:
					'Up2-9k: ${FlxG.save.data.keys.B8.map(function (key:FlxKey) {return FlxKey.toStringMap.get(key);}).join(",")}';
				case 19:
					'Right2-9k: ${FlxG.save.data.keys.B9.map(function (key:FlxKey) {return FlxKey.toStringMap.get(key);}).join(",")}';
						default:
							'how did we get here';
					}
					FlxG.save.flush();
					grpBind.members[awaitingFor] = new Alphabet(0, (70 * awaitingFor) + 30, coolText, true, false, false, null, null, null, true);
					grpBind.members[awaitingFor].itemType = "Classic";
					grpBind.members[awaitingFor].isMenuItem = true;
					grpBind.members[awaitingFor].targetY = 0;
				}
				
				
				// then reeset everything
				awaitingFor = -1;
				askingToBind = false;
				askToBind.visible= false;
				currentKeys = [];
			} else if (FlxG.keys.firstJustPressed() != -1) {
                // blush 
                // add the first key pressed
                currentKeys.push(FlxG.keys.firstJustPressed());
            }
        }
        
    }
}