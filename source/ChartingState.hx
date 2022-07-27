package;

import Section.SwagSection;
import Song.SwagSong;
import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.FlxObject;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import haxe.Json;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;
import lime.system.System;
import flixel.util.FlxSort;
#if sys
import sys.io.File;
import haxe.io.Path;
import sys.FileSystem;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import flash.media.Sound;
import tjson.TJSON;
#end

using StringTools;

enum abstract NoteTypes(Int) from Int to Int
{
	@:op(A == B) static function _(_, _):Bool;

	var Normal;
	var Lift;
	var Mine;
	var Death;
}

class ChartingState extends MusicBeatState
{
	//var _file:FileReference;

	var UI_box:FlxUITabMenu;
	var copyedSection:Int = 0;

	/**
	 * Array of notes showing when each section STARTS in STEPS
	 * Usually rounded up??
	 */
	var curSection:Int = 0;

	var eventStuff:Array<Dynamic> =
	[
		['', "Nothing. Yep, that's right."],
		['Hey!', "Plays the \"Hey!\" animation from Bopeebo,\nValue 1: BF = Only Boyfriend, GF = Only Girlfriend,\nSomething else = Both.\nValue 2: Custom animation duration,\nleave it blank for 0.6s"],
		['Set GF Speed', "Sets GF head bopping speed,\nValue 1: 1 = Normal speed,\n2 = 1/2 speed, 4 = 1/4 speed etc.\nUsed on Fresh during the beatbox parts.\n\nWarning: Value must be integer!"],
		['Add Camera Zoom', "Used on MILF on that one \"hard\" part\nValue 1: Camera zoom add (Default: 0.015)\nValue 2: UI zoom add (Default: 0.03)\nLeave the values blank if you want to use Default."],
		['Play Animation', "Plays an animation on a Character,\nonce the animation is completed,\nthe animation changes to Idle\n\nValue 1: Animation to play.\nValue 2: Character (Dad, BF, GF)"],
		['Camera Follow Pos', "Value 1: X\nValue 2: Y\n\nThe camera won't change the follow point\nafter using this, for getting it back\nto normal, leave both values blank."],
		['Alt Idle Animation', "Sets a specified suffix after the idle animation name.\nYou can use this to trigger 'idle-alt' if you set\nValue 2 to -alt\n\nValue 1: Character to set (Dad, BF or GF)\nValue 2: New suffix (Leave it blank to disable)"],
		['Screen Shake', "Value 1: Camera shake\nValue 2: HUD shake\n\nEvery value works as the following example: \"1, 0.05\".\nThe first number (1) is the duration.\nThe second number (0.05) is the intensity."],
		['Change Character', "Value 1: Character to change (Dad, BF, GF)\nValue 2: New character's name\nValue 3: Destroy the previous character for higher performance.\n(If a previously destroyed character is reloaded, it will cause some lag)."],
		['Change Scroll Speed', "Value 1: Scroll Speed Multiplier (1 is default)\nValue 2: Time it takes to change fully in seconds."],
		['Setting Crossfades', "Value 1: Crossfade Duration\nValue 2: Crossfade Intensity\nValue 3: Crossfade Blend\nLeave the values blank if you want to use Default."]
	];

	public static var lastSection:Int = 0;

	var difficultyChoices:Array<String> = [];

	private var blockPressWhileTypingOn:Array<FlxUIInputText> = [];
	private var blockPressWhileTypingOnStepper:Array<FlxUINumericStepper> = [];
	private var blockPressWhileScrolling:Array<FlxUIDropDownMenuCustom> = [];

	var bpmTxt:FlxText;

	var strumLine:FlxSprite;
	var curSong:String = 'Dadbattle';
	var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;
	var noteTypeText:FlxText;
	var highlight:FlxSprite;
	var camPos:FlxObject;
	var CAM_OFFSET:Int = 360;
	var curEventSelected:Int = 0;
	var curDifficulty:String;
	//var customNoteJson:Null<Array<NoteInfo>>;

	var GRID_SIZE:Int = 40;

	var dummyArrow:FlxSprite;

	var curRenderedNotes:FlxTypedGroup<EdtNote>;
	var curRenderedSustains:FlxTypedGroup<FlxSprite>;
	var curRenderedNoteType:FlxTypedGroup<FlxText>;

	var gridBG:FlxSprite;

	var _song:SwagSong;
	var noteType:Int = Normal;
	var typingShit:FlxInputText;
	var player1TextField:FlxUIInputText;
	var player2TextField:FlxUIInputText;
	var gfTextField:FlxUIInputText;
	var cutsceneTextField:FlxUIInputText;
	var uiTextField:FlxUIInputText;
	var stageTextField:FlxUIInputText;
	var isAltNoteCheck:FlxUICheckBox;
	var isCrossfade:FlxUICheckBox;
	var customNoteNamesFile:String = "";
	var customNoteNamesData:Array<String>;
	var value1InputText:FlxUIInputText;
	var value2InputText:FlxUIInputText;
	var value3InputText:FlxUIInputText;
	public var ignoreWarnings = false;
	
	var playerText:FlxText;
	var gfText:FlxText;
	var enemyText:FlxText;
	var stageText:FlxText;
	var uiText:FlxText;
	var cutsceneText:FlxText;
	var coolText = new FlxText(0, 0, 0, "69", 16);
	var coolBeat = new FlxText(0, 0, 0, "69", 16);

	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curSelectedNote:Array<Dynamic> = null;

	var tempBpm:Float = 0;

	var vocals:FlxSound;

	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;
	var temlicon:String;
	var temricon:String;

	var useLiftNote:Bool = false;
	var gridLayer:FlxTypedGroup<FlxSprite>;

	var text:String = "";

	override function create()
	{
		
		FNFAssets.clearStoredMemory();
		
		// wierd fix but might work?
		remove(coolText);
		curSection = lastSection;

		var bg:FlxSprite = new FlxSprite().loadGraphic(FNFAssets.getBitmapData('assets/images/menuDesat.png'));
		bg.scrollFactor.set();
		bg.color = 0xFF222222;
		add(bg);

		//gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16);
		//add(gridBG);

		gridLayer = new FlxTypedGroup<FlxSprite>();
		add(gridLayer);

		var eventIcon:FlxSprite = new FlxSprite(-GRID_SIZE - 5, -90).loadGraphic(FNFAssets.getGraphicData('assets/images/eventArrow.png'));
		leftIcon = new HealthIcon('bf');
		rightIcon = new HealthIcon('dad');
		leftIcon.scrollFactor.set(1, 1);
		rightIcon.scrollFactor.set(1, 1);

		eventIcon.setGraphicSize(30, 30);
		leftIcon.setGraphicSize(0, 45);
		rightIcon.setGraphicSize(0, 45);

		add(eventIcon);
		add(leftIcon);
		add(rightIcon);

		leftIcon.setPosition(GRID_SIZE + 10, -100);
		rightIcon.setPosition(GRID_SIZE * 5.2, -100);

		//var gridBlackLine:FlxSprite = new FlxSprite(gridBG.x + gridBG.width / 2).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		//add(gridBlackLine);

		curRenderedNotes = new FlxTypedGroup<EdtNote>();
		curRenderedSustains = new FlxTypedGroup<FlxSprite>();
		curRenderedNoteType = new FlxTypedGroup<FlxText>();

		if (PlayState.SONG != null)
			_song = PlayState.SONG;
		else
		{
			_song = {
				song: 'Test',
				notes: [],
				events: [],
				bpm: 150,
				needsVoices: true,
				player1: 'bf',
				player2: 'dad',
				stage: 'stage',
				gf: 'gf',
				isHey: false,
				speed: 1,
				isSpooky: false,
				isMoody: false,
				cutsceneType: "none",
				uiType: 'normal',
				isCheer: false,
				preferredNoteAmount: 4,
				forceJudgements: false,
				convertMineToNuke: false,
				mania: 0
			};
		}

		if (FNFAssets.exists('assets/images/custom_notetypes/notetypes.txt'))
		{
			customNoteNamesFile = FNFAssets.getText('assets/images/custom_notetypes/notetypes.txt');
			
			if (customNoteNamesFile != "")
			{
				//if (!customNoteNamesFile.endsWith(','))
				//	customNoteNamesFile += ",";

				customNoteNamesData = customNoteNamesFile.split('\n');
			}
		}

		var diffJson = CoolUtil.parseJson(FNFAssets.getJson("assets/images/custom_difficulties/difficulties"));
		var diffJsonDiff:Array<Dynamic> = diffJson.difficulties;
		for (i in diffJsonDiff) {
			var nameDif = '-' + i.name.toLowerCase();
			if (nameDif == '-normal')
			{
				nameDif = '';
			}
			if (FNFAssets.exists('assets/data/' + PlayState.SONG.song.toLowerCase() + '/' + PlayState.SONG.song.toLowerCase() + nameDif.toLowerCase() + '.json'))
			{
				difficultyChoices.push(i.name);
			}
		}
		curDifficulty = difficultyChoices[0];

		FlxG.mouse.visible = true;
		//FlxG.save.bind('save1', 'bulbyVR');
		// i don't know why we need to rebind our save
		tempBpm = _song.bpm;
		leftIcon.switchAnim(_song.player1);
		rightIcon.switchAnim(_song.player2);
		leftIcon.scrollFactor.set(1, 1);
		rightIcon.scrollFactor.set(1, 1);
		ignoreWarnings = FlxG.save.data.ignoreWarnings;

		addSection();

		// sections = _song.notes;

		reloadGridLayer();

		loadSong(_song.song);
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		bpmTxt = new FlxText(1000 + 120, 50, 0, "", 16);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		//strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(FlxG.width / 2), 4);
		//add(strumLine);
		camPos = new FlxObject(0, 0, 1, 1);
		camPos.setPosition(strumLine.x + CAM_OFFSET, strumLine.y);

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		var tabs = [
			{name: "Song", label: 'Song'},
			{name: "Section", label: 'Section'},
			{name: "Note", label: 'Note'},
			{name: "Events", label: 'Events'},
			{name: "Char", label: 'Char'},
			{name: "Charting", label: 'Charting'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 400);
		UI_box.x = FlxG.width / 2 + 120;
		UI_box.y = 20;

		text =
		"W/S or Mouse Wheel - Change Conductor's strum time
		\nA or Left/D or Right - Go to the previous/next section
		\nHold Shift to move 4x faster
		\nHold Control and click on an arrow to select it
		\n
		\nEnter - Play your chart
		\nQ/E - Decrease/Increase Note Sustain Length
		\nSpace - Stop/Resume song";

		var tipTextArray:Array<String> = text.split('\n');
		for (i in 0...tipTextArray.length) {
			var tipText:FlxText = new FlxText(UI_box.x, UI_box.y + UI_box.height + 8, 0, tipTextArray[i], 16);
			tipText.y += i * 14;
			tipText.setFormat("assets/fonts/vcr.ttf", 16, FlxColor.WHITE, LEFT/*, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK*/);
			//tipText.borderSize = 2;
			tipText.scrollFactor.set();
			add(tipText);
		}

		add(UI_box);

		noteTypeText = new FlxText(FlxG.width / 2, FlxG.height, 0, "Normal Type", 16);
		noteTypeText.x += 120;
		noteTypeText.y -= noteTypeText.height;
		noteTypeText.scrollFactor.set();
		add(noteTypeText);
		addSongUI();
		addSectionUI();
		addNoteUI();
		addEventsUI();
		addCharsUI();
		addChartingUI();

		add(curRenderedNotes);
		add(curRenderedSustains);
		add(curRenderedNoteType);

		changeSection();

		updateGrid();
		super.create();
	}

	var playSoundBf:FlxUICheckBox = null;
	var playSoundDad:FlxUICheckBox = null;
	var check_warnings:FlxUICheckBox = null;
	var diffDropDown:FlxUIDropDownMenuCustom;
	
	function addSongUI():Void
	{
		var UI_songTitle = new FlxUIInputText(10, 10, 70, _song.song, 8);
		blockPressWhileTypingOn.push(UI_songTitle);
		typingShit = UI_songTitle;

		var check_voices = new FlxUICheckBox(10, 25, null, null, "Has voice track", 100);
		check_voices.checked = _song.needsVoices;
		// _song.needsVoices = check_voices.checked;
		check_voices.callback = function()
		{
			_song.needsVoices = check_voices.checked;
			trace('CHECKED!');
		};

		var saveButton:FlxButton = new FlxButton(110, 8, "Save", function()
		{
			saveLevel();
		});

		var reloadSong:FlxButton = new FlxButton(saveButton.x + saveButton.width + 10, saveButton.y, "Reload Audio", function()
		{
			loadSong(_song.song);
		});

		var reloadSongJson:FlxButton = new FlxButton(reloadSong.x, saveButton.y + 30, "Reload JSON", function()
		{
			loadJson(_song.song.toLowerCase());
		});

		var isSpookyCheck = new FlxUICheckBox(10, 280,null,null,"Is Spooky", 100);
		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, 'load autosave', loadAutosave);

		var loadEventJson:FlxButton = new FlxButton(loadAutosaveBtn.x, loadAutosaveBtn.y + 30, 'Load Events', function()
		{
			var songName:String = _song.song.toLowerCase();
			var file:String = 'assets/data/' + songName + '/events.json';
			if (FNFAssets.exists(file))
			{
				trace('ok this json exists! :D');
				clearEvents();
				var events:SwagSong = Song.loadFromJson('events', songName);
				_song.events = events.events;
				changeSection(curSection);
			}
		});

		var saveEvents:FlxButton = new FlxButton(110, reloadSongJson.y, 'Save Events', function ()
		{
			saveEvents();
		});

		var clear_events:FlxButton = new FlxButton(320, 310, 'Clear events', function()
		{
			openSubState(new Prompt('This action will clear current progress.\n\nProceed?', 0, clearEvents, null, ignoreWarnings));
		});
		clear_events.color = FlxColor.RED;
		clear_events.label.color = FlxColor.WHITE;

		var clear_notes:FlxButton = new FlxButton(320, clear_events.y + 30, 'Clear notes', function()
		{
			openSubState(new Prompt('This action will clear current progress.\n\nProceed?', 0, function(){for (sec in 0..._song.notes.length) {
				_song.notes[sec].sectionNotes = [];
			}
			updateGrid();
		}, null, ignoreWarnings));
			
		});
		clear_notes.color = FlxColor.RED;
		clear_notes.label.color = FlxColor.WHITE;
		
		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, 100, 0.1, 1, 0.1, 10, 1);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';
		blockPressWhileTypingOnStepper.push(stepperSpeed);

		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 65, 1, 1, 1, 339, 0);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';
		blockPressWhileTypingOnStepper.push(stepperBPM);

		diffDropDown = new FlxUIDropDownMenuCustom(10, 135, FlxUIDropDownMenuCustom.makeStrIdLabelArray(difficultyChoices, true), function(pressed:String)
		{
			var selectedDiff:Int = Std.parseInt(pressed);
			curDifficulty = difficultyChoices[selectedDiff];
		});

		var stepperMania:FlxUINumericStepper = new FlxUINumericStepper(100, 70, 1, 0, 0, 3, 1);
		stepperMania.value = _song.mania;
		stepperMania.name = 'mania';
		blockPressWhileTypingOnStepper.push(stepperMania);

		//player1TextField = new FlxUIInputText(10, 100, 70, _song.player1, 8);
		//player2TextField = new FlxUIInputText(80, 100, 70, _song.player2, 8);
		//gfTextField = new FlxUIInputText(10, 120, 70, _song.gf, 8);
		//stageTextField = new FlxUIInputText(80, 120, 70, _song.stage, 8);
		//cutsceneTextField = new FlxUIInputText(80, 140, 70, _song.cutsceneType, 8);
		//uiTextField = new FlxUIInputText(10, 140, 70, _song.uiType, 8);
		var isMoodyCheck = new FlxUICheckBox(10, 220, null, null, "Is Moody", 100);
		var isHeyCheck = new FlxUICheckBox(10, 250, null, null, "Is Hey", 100);
		var isCheerCheck = new FlxUICheckBox(100, 250, null, null, "Is Cheer", 100);
		isMoodyCheck.name = "isMoody";
		isHeyCheck.name = "isHey";
		isCheerCheck.name = "isCheer";
		isSpookyCheck.name = 'isSpooky';
		isMoodyCheck.checked = _song.isMoody;
		isSpookyCheck.checked = _song.isSpooky;
		isHeyCheck.checked = _song.isHey;
		isCheerCheck.checked = _song.isCheer;
		var curStage = _song.stage;
		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);

		tab_group_song.add(check_voices);
		tab_group_song.add(clear_events);
		tab_group_song.add(clear_notes);
		tab_group_song.add(isMoodyCheck);
		tab_group_song.add(isSpookyCheck);
		tab_group_song.add(isHeyCheck);
		tab_group_song.add(isCheerCheck);
		tab_group_song.add(saveButton);
		tab_group_song.add(saveEvents);
		tab_group_song.add(reloadSong);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(loadEventJson);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperMania);
		tab_group_song.add(stepperSpeed);
		tab_group_song.add(diffDropDown);
		tab_group_song.add(new FlxText(stepperMania.x, stepperMania.y - 15, 0, 'Mania:'));
		tab_group_song.add(new FlxText(stepperSpeed.x, stepperSpeed.y - 15, 0, 'Song Speed:'));
		tab_group_song.add(new FlxText(diffDropDown.x, diffDropDown.y - 15, 0, 'Song Difficulty:'));

		UI_box.addGroup(tab_group_song);
		UI_box.scrollFactor.set();

		FlxG.camera.follow(camPos);
	}

	function addCharsUI():Void
	{
		player1TextField = new FlxUIInputText(10, 100, 70, _song.player1, 8);
		blockPressWhileTypingOn.push(player1TextField);
		player2TextField = new FlxUIInputText(120, 100, 70, _song.player2, 8);
		blockPressWhileTypingOn.push(player2TextField);
		gfTextField = new FlxUIInputText(10, 120, 70, _song.gf, 8);
		blockPressWhileTypingOn.push(gfTextField);
		stageTextField = new FlxUIInputText(120, 120, 70, _song.stage, 8);
		blockPressWhileTypingOn.push(stageTextField);
		cutsceneTextField = new FlxUIInputText(120, 140, 70, _song.cutsceneType, 8);
		blockPressWhileTypingOn.push(cutsceneTextField);
		uiTextField = new FlxUIInputText(10, 140, 70, _song.uiType, 8);
		blockPressWhileTypingOn.push(uiTextField);

		playerText = new FlxText(player1TextField.x + 70, player1TextField.y, 0, "Player", 8, false);
		enemyText = new FlxText(player2TextField.x + 70, player2TextField.y, 0, "Enemy", 8, false);
		gfText = new FlxText(gfTextField.x + 70, gfTextField.y, 0, "GF", 8, false);
		stageText = new FlxText(stageTextField.x + 70, stageTextField.y, 0, "Stage", 8, false);
		cutsceneText = new FlxText(cutsceneTextField.x + 70, uiTextField.y, 0, "Cutscene", 8, false);
		uiText = new FlxText(uiTextField.x + 70, uiTextField.y, 0, "UI", 8, false);

		var curStage = _song.stage;

		var tab_group_char = new FlxUI(null, UI_box);
		tab_group_char.name = "Char";

		tab_group_char.add(playerText);
		tab_group_char.add(enemyText);
		tab_group_char.add(gfText);
		tab_group_char.add(stageText);
		tab_group_char.add(cutsceneText);
		tab_group_char.add(uiText);
		tab_group_char.add(uiTextField);
		tab_group_char.add(cutsceneTextField);
		tab_group_char.add(stageTextField);
		tab_group_char.add(gfTextField);
		tab_group_char.add(player1TextField);
		tab_group_char.add(player2TextField);

		UI_box.addGroup(tab_group_char);
		UI_box.scrollFactor.set();
	}

	var stepperLength:FlxUINumericStepper;
	var stepperAltAnim:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var check_altAnim:FlxUICheckBox;
	var check_crossfadeBf:FlxUICheckBox;
	var check_crossfadeDad:FlxUICheckBox;

	function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		stepperLength = new FlxUINumericStepper(10, 10, 4, 0, 0, 999, 0);
		stepperLength.value = _song.notes[curSection].lengthInSteps;
		stepperLength.name = "section_length";
		blockPressWhileTypingOnStepper.push(stepperLength);

		stepperSectionBPM = new FlxUINumericStepper(10, 80, 1, Conductor.bpm, 0, 999, 0);
		stepperSectionBPM.value = Conductor.bpm;
		stepperSectionBPM.name = 'section_bpm';
		blockPressWhileTypingOnStepper.push(stepperSectionBPM);

		stepperAltAnim = new FlxUINumericStepper(10, 200, 1, Conductor.bpm, 0, 999, 0);
		stepperAltAnim.value = 0;
		stepperAltAnim.name = 'alt_anim_number';
		blockPressWhileTypingOnStepper.push(stepperAltAnim);

		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, 130, 1, 1, -999, 999, 0);
		blockPressWhileTypingOnStepper.push(stepperCopy);

		var copyButton:FlxButton = new FlxButton(10, 130, "Copy last section", function()
		{
			copySection(Std.int(stepperCopy.value));
		});

		var copyCurSection:FlxButton = new FlxButton(210, 130, "Copy sect", function()
		{
			copyedSection = curSection;
		});

		var pasteCurSection:FlxButton = new FlxButton(210, 150, "Paste sect", function()
		{
			copySection(Std.int(copyedSection));
		});

		var clearSectionButton:FlxButton = new FlxButton(10, 150, "Clear", clearSection);

		var swapSection:FlxButton = new FlxButton(10, 170, "Swap section", function()
		{
			for (i in 0..._song.notes[curSection].sectionNotes.length)
			{
				var note:Array<Dynamic> = _song.notes[curSection].sectionNotes[i];
				if(note[1] > -1) {
					note[1] = (note[1] + Main.ammo[_song.mania]) % (Main.ammo[_song.mania] * 2);
					_song.notes[curSection].sectionNotes[i] = note;
				}
				//updateGrid();
			}
			updateGrid();
		});

		check_mustHitSection = new FlxUICheckBox(10, 30, null, null, "Must hit section", 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = true;
		// _song.needsVoices = check_mustHit.checked;

		check_altAnim = new FlxUICheckBox(10, 220, null, null, "Alt Animation", 100);
		check_altAnim.name = 'check_altAnim';

		check_crossfadeBf = new FlxUICheckBox(10, 240, null, null, "Player Crossfade", 100);
		check_crossfadeBf.name = 'check_crossfadeBf';

		check_crossfadeDad = new FlxUICheckBox(160, 240, null, null, "Opponent Crossfade", 100);
		check_crossfadeDad.name = 'check_crossfadeDad';

		check_changeBPM = new FlxUICheckBox(10, 60, null, null, 'Change BPM', 100);
		check_changeBPM.name = 'check_changeBPM';

		tab_group_section.add(stepperLength);
		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(copyCurSection);
		tab_group_section.add(pasteCurSection);
		tab_group_section.add(check_mustHitSection);
		tab_group_section.add(check_altAnim);
		tab_group_section.add(stepperAltAnim);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(copyButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(swapSection);
		tab_group_section.add(check_crossfadeBf);
		tab_group_section.add(check_crossfadeDad);


		UI_box.addGroup(tab_group_section);
	}

	var stepperSusLength:FlxUINumericStepper;
	var stepperAltNote:FlxUINumericStepper;
	
	function addNoteUI():Void
	{
		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		stepperSusLength = new FlxUINumericStepper(10, 10, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * 16);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';
		blockPressWhileTypingOnStepper.push(stepperSusLength);

		var applyLength:FlxButton = new FlxButton(100, 10, 'Apply');
		isAltNoteCheck = new FlxUICheckBox(10, 100, null, null, "Alt Anim Note", 100);
		isAltNoteCheck.name = "isAltNote";
		stepperAltNote = new FlxUINumericStepper(10, 200, 1, 0, 0, 999, 0);
		stepperAltNote.value = 0;
		stepperAltNote.name = 'alt_anim_note';
		blockPressWhileTypingOnStepper.push(stepperAltNote);

		isCrossfade = new FlxUICheckBox(10, 120, null, null, "Cross Fade", 100);
		isCrossfade.name = "isCrossfade";

		tab_group_note.add(stepperSusLength);
		tab_group_note.add(applyLength);
		tab_group_note.add(isAltNoteCheck);
		tab_group_note.add(stepperAltNote);
		tab_group_note.add(isCrossfade);
		UI_box.addGroup(tab_group_note);


	}

	var eventDropDown:FlxUIDropDownMenuCustom;
	var descText:FlxText;
	var selectedEventText:FlxText;
	function addEventsUI():Void
	{
		var tab_group_event = new FlxUI(null, UI_box);
		tab_group_event.name = 'Events';

		#if sys
		var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();
		var directories:Array<String> = ['assets/images/custom_events/'];
		for (i in 0...directories.length) {
			var directory:String =  directories[i];
			if(FNFAssets.exists(directory)) 
			{
				for (file in FileSystem.readDirectory(directory)) {
					var path = haxe.io.Path.join([directory, file]);
					if (!FileSystem.isDirectory(path) && file != 'readme.txt' && file.endsWith('.txt')) {
						var fileToCheck:String = file.substr(0, file.length - 4);
						if(!eventPushedMap.exists(fileToCheck)) {
							eventPushedMap.set(fileToCheck, true);
							eventStuff.push([fileToCheck, File.getContent(path)]);
						}
					}
				}
			}
		}
		eventPushedMap.clear();
		eventPushedMap = null;
		#end

		descText = new FlxText(20, 250, 0, eventStuff[0][0]);

		var leEvents:Array<String> = [];
		for (i in 0...eventStuff.length) {
			leEvents.push(eventStuff[i][0]);
		}

		var text:FlxText = new FlxText(20, 30, 0, "Event:");
		tab_group_event.add(text);
		eventDropDown = new FlxUIDropDownMenuCustom(20, 50, FlxUIDropDownMenuCustom.makeStrIdLabelArray(leEvents, true), function(pressed:String) {
			var selectedEvent:Int = Std.parseInt(pressed);
			descText.text = eventStuff[selectedEvent][1];
			if (curSelectedNote != null && eventStuff != null) 
			{
				if (curSelectedNote != null && curSelectedNote[2] == null)
				{
					curSelectedNote[1][curEventSelected][0] = eventStuff[selectedEvent][0];
				}
				updateGrid();
			}
		});
		blockPressWhileScrolling.push(eventDropDown);

		var text:FlxText = new FlxText(20, 90, 0, "Value 1:");
		tab_group_event.add(text);
		value1InputText = new FlxUIInputText(20, 110, 100, "");
		blockPressWhileTypingOn.push(value1InputText);

		var text:FlxText = new FlxText(20, 130, 0, "Value 2:");
		tab_group_event.add(text);
		value2InputText = new FlxUIInputText(20, 150, 100, "");
		blockPressWhileTypingOn.push(value2InputText);

		var text:FlxText = new FlxText(20, 170, 0, "Value 3:");
		tab_group_event.add(text);
		value3InputText = new FlxUIInputText(20, 190, 100, "");
		blockPressWhileTypingOn.push(value3InputText);

		// New event buttons
		var removeButton:FlxButton = new FlxButton(eventDropDown.x + eventDropDown.width + 10, eventDropDown.y, '-', function()
		{
			if(curSelectedNote != null && curSelectedNote[2] == null) //Is event note
			{
				if(curSelectedNote[1].length < 2)
				{
					_song.events.remove(curSelectedNote);
					curSelectedNote = null;
				}
				else
				{
					curSelectedNote[1].remove(curSelectedNote[1][curEventSelected]);
				}

				var eventsGroup:Array<Dynamic>;
				--curEventSelected;
				if(curEventSelected < 0) curEventSelected = 0;
				else if(curSelectedNote != null && curEventSelected >= (eventsGroup = curSelectedNote[1]).length) curEventSelected = eventsGroup.length - 1;
				
				changeEventSelected();
				updateGrid();
			}
		});
		removeButton.setGraphicSize(Std.int(removeButton.height), Std.int(removeButton.height));
		removeButton.updateHitbox();
		removeButton.color = FlxColor.RED;
		removeButton.label.color = FlxColor.WHITE;
		removeButton.label.size = 12;
		setAllLabelsOffset(removeButton, -30, 0);
		tab_group_event.add(removeButton);
			
		var addButton:FlxButton = new FlxButton(removeButton.x + removeButton.width + 10, removeButton.y, '+', function()
		{
			if(curSelectedNote != null && curSelectedNote[2] == null) //Is event note
			{
				var eventsGroup:Array<Dynamic> = curSelectedNote[1];
				eventsGroup.push(['', '', '']);

				changeEventSelected(1);
				updateGrid();
			}
		});
		addButton.setGraphicSize(Std.int(removeButton.width), Std.int(removeButton.height));
		addButton.updateHitbox();
		addButton.color = FlxColor.GREEN;
		addButton.label.color = FlxColor.WHITE;
		addButton.label.size = 12;
		setAllLabelsOffset(addButton, -30, 0);
		tab_group_event.add(addButton);
			
		var moveLeftButton:FlxButton = new FlxButton(addButton.x + addButton.width + 20, addButton.y, '<', function()
		{
			changeEventSelected(-1);
		});
		moveLeftButton.setGraphicSize(Std.int(addButton.width), Std.int(addButton.height));
		moveLeftButton.updateHitbox();
		moveLeftButton.label.size = 12;
		setAllLabelsOffset(moveLeftButton, -30, 0);
		tab_group_event.add(moveLeftButton);
			
		var moveRightButton:FlxButton = new FlxButton(moveLeftButton.x + moveLeftButton.width + 10, moveLeftButton.y, '>', function()
		{
			changeEventSelected(1);
		});
		moveRightButton.setGraphicSize(Std.int(moveLeftButton.width), Std.int(moveLeftButton.height));
		moveRightButton.updateHitbox();
		moveRightButton.label.size = 12;
		setAllLabelsOffset(moveRightButton, -30, 0);
		tab_group_event.add(moveRightButton);

		selectedEventText = new FlxText(addButton.x - 100, addButton.y + addButton.height + 6, (moveRightButton.x - addButton.x) + 186, 'Selected Event: None');
		selectedEventText.alignment = CENTER;
		tab_group_event.add(selectedEventText);

		tab_group_event.add(descText);
		tab_group_event.add(value1InputText);
		tab_group_event.add(value2InputText);
		tab_group_event.add(value3InputText);
		tab_group_event.add(eventDropDown);

		UI_box.addGroup(tab_group_event);
	}

	function changeEventSelected(change:Int = 0)
	{
		if(curSelectedNote != null && curSelectedNote[2] == null) //Is event note
		{
			curEventSelected += change;
			if(curEventSelected < 0) curEventSelected = Std.int(curSelectedNote[1].length) - 1;
			else if(curEventSelected >= curSelectedNote[1].length) curEventSelected = 0;
			selectedEventText.text = 'Selected Event: ' + (curEventSelected + 1) + ' / ' + curSelectedNote[1].length;
		}
		else
		{
			curEventSelected = 0;
			selectedEventText.text = 'Selected Event: None';
		}
		updateNoteUI();
	}

	function setAllLabelsOffset(button:FlxButton, x:Float, y:Float)
	{
		for (point in button.labelOffsets)
		{
			point.set(x, y);
		}
	}

	var instVolume:FlxUINumericStepper;
	var voicesVolume:FlxUINumericStepper;
	function addChartingUI()
	{
		var tab_group_chart = new FlxUI(null, UI_box);
		tab_group_chart.name = 'Charting';

		var check_mute_inst = new FlxUICheckBox(10, 200, null, null, "Mute Instrumental (in editor)", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_inst.checked)
				vol = 0;

			FlxG.sound.music.volume = vol;
		};

		check_warnings = new FlxUICheckBox(10, 120, null, null, "Ignore Progress Warnings", 100);
		if (FlxG.save.data.ignoreWarnings == null) FlxG.save.data.ignoreWarnings = false;
		check_warnings.checked = FlxG.save.data.ignoreWarnings;

		check_warnings.callback = function()
		{
			FlxG.save.data.ignoreWarnings = check_warnings.checked;
			ignoreWarnings = FlxG.save.data.ignoreWarnings;
		};

		var check_mute_vocals = new FlxUICheckBox(check_mute_inst.x + 120, check_mute_inst.y, null, null, "Mute Vocals (in editor)", 100);
		check_mute_vocals.checked = false;
		check_mute_vocals.callback = function()
		{
			if(vocals != null) {
				var vol:Float = 1;

				if (check_mute_vocals.checked)
					vol = 0;

				vocals.volume = vol;
			}
		};

		playSoundBf = new FlxUICheckBox(check_mute_inst.x, check_mute_vocals.y + 30, null, null, 'Play Sound (Player notes)', 100,
			function() {
				FlxG.save.data.chart_playSoundBf = playSoundBf.checked;
			}
		);
		if (FlxG.save.data.chart_playSoundBf == null) FlxG.save.data.chart_playSoundBf = false;
		playSoundBf.checked = FlxG.save.data.chart_playSoundBf;

		playSoundDad = new FlxUICheckBox(check_mute_inst.x + 120, playSoundBf.y, null, null, 'Play Sound (Opponent notes)', 100,
			function() {
				FlxG.save.data.chart_playSoundDad = playSoundDad.checked;
			}
		);
		if (FlxG.save.data.chart_playSoundDad == null) FlxG.save.data.chart_playSoundDad = false;
		playSoundDad.checked = FlxG.save.data.chart_playSoundDad;

		instVolume = new FlxUINumericStepper(15, 270, 0.1, 1, 0, 1, 1);
		instVolume.value = FlxG.sound.music.volume;
		instVolume.name = 'inst_volume';
		blockPressWhileTypingOnStepper.push(instVolume);

		voicesVolume = new FlxUINumericStepper(instVolume.x + 100, instVolume.y, 0.1, 1, 0, 1, 1);
		voicesVolume.value = vocals.volume;
		voicesVolume.name = 'voices_volume';
		blockPressWhileTypingOnStepper.push(voicesVolume);

		tab_group_chart.add(new FlxText(instVolume.x, instVolume.y - 15, 0, 'Inst Volume'));
		tab_group_chart.add(new FlxText(voicesVolume.x, voicesVolume.y - 15, 0, 'Voices Volume'));
		tab_group_chart.add(check_mute_inst);
		tab_group_chart.add(check_mute_vocals);
		tab_group_chart.add(check_warnings);
		tab_group_chart.add(playSoundBf);
		tab_group_chart.add(playSoundDad);
		tab_group_chart.add(instVolume);
		tab_group_chart.add(voicesVolume);
		UI_box.addGroup(tab_group_chart);
	}
	function changeKeyType(change:Int) {
		noteType += change;
		noteType = cast FlxMath.wrap(noteType, 0, 99);
		switch (noteType)
		{
			case Normal:
				noteTypeText.text = "Normal Note";
			case Lift:
				noteTypeText.text = "Lift Note";
			case Mine:
				noteTypeText.text = "Mine Note";
			case Death:
				noteTypeText.text = "Death Note";
			case 4:
				// drain
				noteTypeText.text = "Drain Note";
			default:
				if (customNoteNamesFile != "" && noteType - 5 < customNoteNamesData.length)
				{
					noteTypeText.text = customNoteNamesData[noteType - 5];
				}
				else
				{
					noteTypeText.text = 'Custom Note ${noteType - 4}';
				}

		}
	}
	function loadSong(daSong:String):Void
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
			// vocals.stop();
		}
		#if sys
		FlxG.sound.playMusic(Sound.fromFile("assets/music/"+daSong+"_Inst"+TitleState.soundExt), 0.6);
		#else
		FlxG.sound.playMusic('assets/music/' + daSong + "_Inst" + TitleState.soundExt, 0.6);
		#end

		if (instVolume != null) FlxG.sound.music.volume = instVolume.value;

		// WONT WORK FOR TUTORIAL OR TEST SONG!!! REDO LATER
		if (_song.needsVoices) {
			#if sys
			var vocalSound = Sound.fromFile("assets/music/"+daSong+"_Voices"+TitleState.soundExt);
			vocals = new FlxSound().loadEmbedded(vocalSound);
			#else
			vocals = new FlxSound().loadEmbedded("assets/music/" + daSong + "_Voices" + TitleState.soundExt);
			#end
			FlxG.sound.list.add(vocals);

		}

		FlxG.sound.music.pause();
		if (_song.needsVoices) {
			vocals.pause();
		}


		FlxG.sound.music.onComplete = function()
		{
			if (_song.needsVoices) {
				vocals.pause();
				vocals.time = 0;
			}

			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		};
	}

	function generateUI():Void
	{
		while (bullshitUI.members.length > 0)
		{
			bullshitUI.remove(bullshitUI.members[0], true);
		}

		// general shit
		var title:FlxText = new FlxText(UI_box.x + 20, UI_box.y + 20, 0);
		bullshitUI.add(title);
		/*
			var loopCheck = new FlxUICheckBox(UI_box.x + 10, UI_box.y + 50, null, null, "Loops", 100, ['loop check']);
			loopCheck.checked = curNoteSelected.doesLoop;
			tooltips.add(loopCheck, {title: 'Section looping', body: "Whether or not it's a simon says style section", style: tooltipType});
			bullshitUI.add(loopCheck);
		 */
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case 'Must hit section':
					_song.notes[curSection].mustHitSection = check.checked;

					updateHeads();

				case 'Change BPM':
					_song.notes[curSection].changeBPM = check.checked;
					FlxG.log.add('changed bpm shit');
				case "Alt Animation":
					_song.notes[curSection].altAnim = check.checked;
				case "Is Moody":
					_song.isMoody = check.checked;
				case "Is Spooky":
					_song.isSpooky = check.checked;
				case "Is Hey":
					_song.isHey = check.checked;
				case 'Alt Anim Note':
					if (curSelectedNote != null && curSelectedNote[1] > -1) {
						curSelectedNote[3] = check.checked ? 1 : 0;
						updateNoteUI();
					}
					else
					{
						sender.value = false;
					}
				case 'Is Cheer':
					_song.isCheer = check.checked;
				case 'Cross Fade':
					if (curSelectedNote != null && curSelectedNote[1] > -1) {
						curSelectedNote[12] = check.checked;
						updateNoteUI();
					}
					else
					{
						sender.value = false;
					}
				case 'Player Crossfade':
					_song.notes[curSection].crossfadeBf = check.checked;
				case 'Opponent Crossfade':
					_song.notes[curSection].crossfadeDad = check.checked;
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
			if (wname == 'section_length')
			{
				_song.notes[curSection].lengthInSteps = Std.int(nums.value);
				updateGrid();
			}
			else if (wname == 'song_speed')
			{
				_song.speed = nums.value;
			}
			else if (wname == 'song_bpm')
			{
				tempBpm = nums.value;
				Conductor.mapBPMChanges(_song);
				Conductor.changeBPM(nums.value);
			}
			else if (wname == 'note_susLength')
			{
				if(curSelectedNote != null && curSelectedNote[1] > -1) {
					curSelectedNote[2] = nums.value;
					updateGrid();
				} else {
					sender.value = 0;
				}
			}
			else if (wname == 'section_bpm')
			{
				_song.notes[curSection].bpm = nums.value;
				updateGrid();
			} else if (wname == 'alt_anim_number')
			{
				_song.notes[curSection].altAnimNum = Std.int(nums.value);
			}  else if (wname == 'alt_anim_note') {
				if (curSelectedNote != null)
					curSelectedNote[3] = nums.value;
				updateNoteUI();
			}
			else if (wname == 'inst_volume')
			{
				FlxG.sound.music.volume = nums.value;
			}
			else if (wname == 'voices_volume')
			{
				vocals.volume = nums.value;
			}
			else if (wname == 'mania')
			{
				_song.mania = Std.int(nums.value);
				reloadGridLayer();
			}
		}
		else if(id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText)) {
			if(curSelectedNote != null)
			{
				if(sender == value1InputText) {
					curSelectedNote[1][curEventSelected][1] = value1InputText.text;
					updateGrid();
				}
				else if(sender == value2InputText) {
					curSelectedNote[1][curEventSelected][2] = value2InputText.text;
					updateGrid();
				}
				else if(sender == value3InputText) {
					curSelectedNote[1][curEventSelected][3] = value3InputText.text;
					updateGrid();
				}
			}
		}

		// FlxG.log.add(id + " WEED " + sender + " WEED " + data + " WEED " + params);
	}

	var updatedSection:Bool = false;

	/* this function got owned LOL
	function lengthBpmBullshit():Float
	{
		if (_song.notes[curSection].changeBPM)
			return _song.notes[curSection].lengthInSteps * (_song.notes[curSection].bpm / _song.bpm);
		else
			return _song.notes[curSection].lengthInSteps;
	}*/

	function sectionStartTime(add:Int = 0):Float
	{
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...curSection + add)
		{
			if(_song.notes[i] != null)
			{
				if (_song.notes[i].changeBPM)
				{
					daBPM = _song.notes[i].bpm;
				}
				daPos += 4 * (1000 * 60 / daBPM);
			}
		}
		return daPos;
	}

	var colorSine:Float = 0;
	var lastConductorPos:Float;
	override function update(elapsed:Float)
	{
		curStep = recalculateSteps();
		var ctrlPressed = FlxG.keys.pressed.CONTROL;

		var gWidth = GRID_SIZE * (Main.ammo[_song.mania] * 2);
		camPos.x = -80 + gWidth;
		strumLine.width = gWidth;
		//rightIcon.x = gWidth / 2 + GRID_SIZE * 2;

		remove(coolText);
		coolText.text = 'curStep: ' + Std.string(curStep);
		coolText.x = 1000 + 120;
		coolText.y = 100;
		coolText.scrollFactor.set();
		add(coolText);

		remove(coolBeat);
		coolBeat.text = 'curBeat: ' + Std.string(curBeat);
		coolBeat.x = 1000 + 120;
		coolBeat.y = 120;
		coolBeat.scrollFactor.set();
		add(coolBeat);

		Conductor.songPosition = FlxG.sound.music.time;
		_song.song = typingShit.text;
		_song.player1 = player1TextField.text;
		_song.player2 = player2TextField.text;
		_song.gf = gfTextField.text;
		_song.stage = stageTextField.text;
		_song.cutsceneType = cutsceneTextField.text;
		_song.uiType = uiTextField.text;
		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps));
		camPos.y = strumLine.y;
		
		
		if (temlicon != _song.player1)
		{
			temlicon = _song.player1;
			leftIcon.switchAnim(_song.player1);
		}
		
		if (temricon != _song.player2)
		{
			temricon = _song.player2;
			rightIcon.switchAnim(_song.player2);
		}

		if (curBeat % 4 == 0 && curStep >= 16 * (curSection + 1))
		//if (Math.ceil(strumLine.y) >= (gridBG.height))
		{
			//trace(curStep);
			//trace((_song.notes[curSection].lengthInSteps) * (curSection + 1));
			//trace('DUMBSHIT');

			if (_song.notes[curSection + 1] == null)
			{
				addSection();
			}

			changeSection(curSection + 1, false);
		}
		else if(strumLine.y < -10) {
			changeSection(curSection - 1, false);
		}

		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);
		if (FlxG.mouse.justPressed)
		{
			if (FlxG.mouse.overlaps(curRenderedNotes))
			{
				curRenderedNotes.forEach(function(note:EdtNote)
				{
					if (FlxG.mouse.overlaps(note))
					{
						if (ctrlPressed)
						{
							selectNote(note);
						}
						else
						{
							trace('tryin to delete note...');
							deleteNote(note);
						}
					}
				});
			}
			else
			{
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * 2 * _song.notes[curSection].lengthInSteps))
				{
					FlxG.log.add('added note');
					addNote();
				}
			}
		}

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * 2 * _song.notes[curSection].lengthInSteps))
		{
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;
		}

		if (FlxG.keys.justPressed.ENTER)
		{
			lastSection = curSection;

			PlayState.SONG = _song;
			FlxG.sound.music.stop();
			if (_song.needsVoices) {
				vocals.stop();
			}
			FlxG.mouse.visible = false;
			LoadingState.loadAndSwitchState(new PlayState());
		}

		if(curSelectedNote != null && curSelectedNote[1] > -1) {
			if (FlxG.keys.justPressed.E)
			{
				changeNoteSustain(Conductor.stepCrochet);
			}
			if (FlxG.keys.justPressed.Q)
			{
				changeNoteSustain(-Conductor.stepCrochet);
			}
		}

		if (FlxG.keys.justPressed.TAB)
		{
			if (FlxG.keys.pressed.SHIFT)
			{
				UI_box.selected_tab -= 1;
				if (UI_box.selected_tab < 0)
					UI_box.selected_tab = 5;
			}
			else
			{
				UI_box.selected_tab += 1;
				if (UI_box.selected_tab >= 6)
					UI_box.selected_tab = 0;
			}
		}

		var blockInput:Bool = false;
		for (inputText in blockPressWhileTypingOn) {
			if(inputText.hasFocus) {
				FlxG.sound.muteKeys = [];
				FlxG.sound.volumeDownKeys = [];
				FlxG.sound.volumeUpKeys = [];
				blockInput = true;
				break;
			}
		}

		if(!blockInput) {
			for (stepper in blockPressWhileTypingOnStepper) {
				@:privateAccess
				var leText:Dynamic = stepper.text_field;
				var leText:FlxUIInputText = leText;
				if(leText.hasFocus) {
					FlxG.sound.muteKeys = [];
					FlxG.sound.volumeDownKeys = [];
					FlxG.sound.volumeUpKeys = [];
					blockInput = true;
					break;
				}
			}
		}

		if(!blockInput) {
			FlxG.sound.muteKeys = TitleState.muteKeys;
			FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
			FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
			for (dropDownMenu in blockPressWhileScrolling) {
				if(dropDownMenu.dropPanel.visible) {
					blockInput = true;
					break;
				}
			}
		}

		/*
		if (typingShit.hasFocus && !player1TextField.hasFocus && !player2TextField.hasFocus && !gfTextField.hasFocus && !stageTextField.hasFocus && !cutsceneTextField.hasFocus && !uiTextField.hasFocus)
		{
			//NOTHING :D
		}
		else
		{
			blockInput = true;
		}
		*/

		var shiftThing:Int = 1;
		if (!blockInput)
		{
			if (FlxG.keys.justPressed.SPACE)
			{
				if (FlxG.sound.music.playing)
				{
					FlxG.sound.music.pause();
					if (_song.needsVoices) {
						vocals.pause();
					}

				}
				else
				{
					if (_song.needsVoices) {
						vocals.play();
					}
					FlxG.sound.music.play();
				}
			}

			if (FlxG.keys.justPressed.R)
			{
				if (FlxG.keys.pressed.SHIFT)
					resetSection(true);
				else
					resetSection();
			}

			if (FlxG.mouse.wheel != 0)
			{
				FlxG.sound.music.pause();
				if (_song.needsVoices) {
					vocals.pause();
				}


				FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);
				if (_song.needsVoices) {
					vocals.time = FlxG.sound.music.time;
				}

			}
			if (FlxG.keys.pressed.SHIFT)
				shiftThing = 4;

			if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
				changeSection(curSection + shiftThing);
			if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
				changeSection(curSection - shiftThing);
			
			if (!FlxG.keys.pressed.SHIFT)
			{
				if (FlxG.keys.pressed.W || FlxG.keys.pressed.S)
				{
					FlxG.sound.music.pause();
					if (_song.needsVoices) {
						vocals.pause();
					}


					var daTime:Float = 700 * FlxG.elapsed;

					if (FlxG.keys.pressed.W)
					{
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;
					if (_song.needsVoices) {
						vocals.time = FlxG.sound.music.time;
					}

				}
			}
			else
			{
				if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.S)
				{
					FlxG.sound.music.pause();
					if (_song.needsVoices) {
						vocals.pause();
					}


					var daTime:Float = Conductor.stepCrochet * 2;

					if (FlxG.keys.justPressed.W)
					{
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;
					if (_song.needsVoices) {
						vocals.time = FlxG.sound.music.time;
					}

				}
			}

			if (FlxG.keys.justPressed.I) {
				changeKeyType(-1);
			} else if (FlxG.keys.justPressed.O) {
				changeKeyType(1);
			}

		} else if (FlxG.keys.justPressed.ENTER) {
			for (i in 0...blockPressWhileTypingOn.length) {
				if(blockPressWhileTypingOn[i].hasFocus) {
					blockPressWhileTypingOn[i].hasFocus = false;
				}
			}
		}

		_song.bpm = tempBpm;

		/* if (FlxG.keys.justPressed.UP)
				Conductor.changeBPM(Conductor.bpm + 1);
			if (FlxG.keys.justPressed.DOWN)
				Conductor.changeBPM(Conductor.bpm - 1); */

		bpmTxt.text = bpmTxt.text = Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2))
			+ " / "
			+ Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2))
			+ "\nSection: "
			+ curSection;

		var playedSound:Array<Bool> = [false, false, false, false]; //Prevents ouchy GF sex sounds
		curRenderedNotes.forEachAlive(function(note:EdtNote)
		{
			note.alpha = 1;

			if(note.strumTime <= Conductor.songPosition) {
				note.alpha = 0.4;
				if(note.strumTime > lastConductorPos && FlxG.sound.music.playing && note.noteData > -1) {
					var data:Int = note.noteData % 4;
					if(!playedSound[data]) {
						if((playSoundBf.checked && note.mustPress) || (playSoundDad.checked && !note.mustPress)){
							var soundToPlay = 'chartingTick';
							if(_song.player1 == 'gf' && _song.mania == 0) { //Easter egg
								soundToPlay = 'GF_' + Std.string(data + 1);
							}
							
							FlxG.sound.play(FNFAssets.getSound('assets/sounds/' + soundToPlay + '.ogg')).pan = note.noteData < 4? -0.3 : 0.3; //would be coolio
							playedSound[data] = true;
						}
					
						data = note.noteData;
						if(note.mustPress != _song.notes[curSection].mustHitSection)
						{
							data += 4;
						}
					}
				}
			}
		});
		
		lastConductorPos = Conductor.songPosition;

		super.update(elapsed);
	}

	function reloadGridLayer() {
		gridLayer.clear();
		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * (Main.ammo[_song.mania] * 2 + 1), Std.int(GRID_SIZE * 32));
		gridLayer.add(gridBG);

		//var gridBlack:FlxSprite = new FlxSprite(0, gridBG.height / 2).makeGraphic(Std.int(GRID_SIZE + GRID_SIZE * Main.ammo[_song.mania] * 2), Std.int(gridBG.height / 2), FlxColor.BLACK);
		//gridBlack.alpha = 0.4;
		//gridLayer.add(gridBlack);

		var gridBlackLine:FlxSprite = new FlxSprite(gridBG.x + gridBG.width - (GRID_SIZE * Main.ammo[_song.mania])).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		gridLayer.add(gridBlackLine);

		var gridBlackLine = new FlxSprite(gridBG.x + GRID_SIZE).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		gridLayer.add(gridBlackLine);

		remove(strumLine);
		strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(GRID_SIZE * Main.ammo[_song.mania] * 2), 4);
		add(strumLine);

		updateGrid();
	}

	function changeNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}

		updateNoteUI();
		updateGrid();
	}
	function toggleNoteAnim():Void {
		if (curSelectedNote != null) {
			if (curSelectedNote[2] != null)
			{
				if (curSelectedNote[3] != null) {
					curSelectedNote[3] = curSelectedNote[3] == 1 ? 0 : 1;

				} else {
					curSelectedNote[3] = 1;
				}
			}
		}
		updateNoteUI();
	}
	function recalculateSteps():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (FlxG.sound.music.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time - lastChange.songTime) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		updateGrid();

		FlxG.sound.music.pause();
		if (_song.needsVoices) {
			vocals.pause();
		}


		// Basically old shit from changeSection???
		FlxG.sound.music.time = sectionStartTime();

		if (songBeginning)
		{
			FlxG.sound.music.time = 0;
			curSection = 0;
		}
		if (_song.needsVoices) {
			vocals.time = FlxG.sound.music.time;
		}

		updateCurStep();

		updateGrid();
		updateSectionUI();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		trace('changing section' + sec);

		if (_song.notes[sec] != null)
		{
			curSection = sec;

			updateGrid();

			if (updateMusic)
			{
				FlxG.sound.music.pause();
				//if (_song.needsVoices) {
				//	vocals.pause();
				//}


				/*var daNum:Int = 0;
				var daLength:Float = 0;
				while (daNum <= sec)
				{
					daLength += lengthBpmBullshit();
					daNum++;
				}*/

				FlxG.sound.music.time = sectionStartTime();
				if (_song.needsVoices) {
					vocals.pause();
					vocals.time = FlxG.sound.music.time;
				}

				updateCurStep();
			}

			updateGrid();
			updateSectionUI();
		}
		else
		{
			changeSection();
		}
		Conductor.songPosition = FlxG.sound.music.time;
	}

	function copySection(?sectionNum:Int = 1)
	{
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (note in _song.notes[daSec - sectionNum].sectionNotes)
		{
			var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2]];
			_song.notes[daSec].sectionNotes.push(copiedNote);
		}

		updateGrid();
	}

	function updateSectionUI():Void
	{
		var sec = _song.notes[curSection];

		stepperLength.value = sec.lengthInSteps;
		check_mustHitSection.checked = sec.mustHitSection;
		check_altAnim.checked = sec.altAnim;
		check_crossfadeBf.checked = sec.crossfadeBf;
		check_crossfadeDad.checked = sec.crossfadeDad;
		check_changeBPM.checked = sec.changeBPM;
		// note that 0 implies regular anim and 1 implies default alt 
		if (sec.altAnimNum == null) {
			sec.altAnimNum == if (sec.altAnim) 1 else 0;
		}
		stepperAltAnim.value = sec.altAnimNum;
		stepperSectionBPM.value = sec.bpm;

		updateHeads();
	}

	function updateHeads():Void
	{
		if (check_mustHitSection.checked)
		{
			leftIcon.setPosition(GRID_SIZE + 0, -100);
			rightIcon.setPosition(GRID_SIZE + gridBG.width / 2, -100);
		}
		else
		{
			rightIcon.setPosition(GRID_SIZE + 0, -100);
			leftIcon.setPosition(GRID_SIZE + gridBG.width / 2, -100);
		}
	}

	function updateNoteUI():Void
	{
		if (curSelectedNote != null) 
		{
			if(curSelectedNote[2] != null) 
			{
				stepperSusLength.value = curSelectedNote[2];
				// null is falsy
				isAltNoteCheck.checked = cast curSelectedNote[3];
				stepperAltNote.value = curSelectedNote[3] != null ? curSelectedNote[3] : 0;
				isCrossfade.checked = cast curSelectedNote[12];
			}
			else
			{
				eventDropDown.selectedLabel = curSelectedNote[1][curEventSelected][0];
				var selected:Int = Std.parseInt(eventDropDown.selectedId);
				if(selected > 0 && selected < eventStuff.length) {
					descText.text = eventStuff[selected][1];
				}
				value1InputText.text = curSelectedNote[1][curEventSelected][1];
				value2InputText.text = curSelectedNote[1][curEventSelected][2];
				value3InputText.text = curSelectedNote[1][curEventSelected][3];
			}
				//strumTimeInputText.text = '' + curSelectedNote[0];
		}
			

	}

	function updateGrid():Void
	{
		
		//curRenderedNoteType.clear();
		
		while (curRenderedNotes.members.length > 0)
		{
			curRenderedNotes.remove(curRenderedNotes.members[0], true);
		}

		while (curRenderedSustains.members.length > 0)
		{
			curRenderedSustains.remove(curRenderedSustains.members[0], true);
		}

		while (curRenderedNoteType.members.length > 0)
		{
			curRenderedNoteType.remove(curRenderedNoteType.members[0], true);
		}

		//var sectionInfo:Array<Dynamic> = _song.notes[curSection].sectionNotes;

		if (_song.notes[curSection].changeBPM && _song.notes[curSection].bpm > 0)
		{
			Conductor.changeBPM(_song.notes[curSection].bpm);
			//FlxG.log.add('CHANGED BPM!');
		}
		else
		{
			//get last bpm
			var daBPM:Float = _song.bpm;
			for (i in 0...curSection)
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;
			Conductor.changeBPM(daBPM);
		}

		/* // PORT BULLSHIT, INCASE THERE'S NO SUSTAIN DATA FOR A NOTE
			for (sec in 0..._song.notes.length)
			{
				for (notesse in 0..._song.notes[sec].sectionNotes.length)
				{
					if (_song.notes[sec].sectionNotes[notesse][2] == null)
					{
						trace('SUS NULL');
						_song.notes[sec].sectionNotes[notesse][2] = 0;
					}
				}
			}
		 */

		//var yummyPng = FNFAssets.getBitmapData('assets/images/custom_ui/ui_packs/normal/NOTE_assets.png');
		//var yummyXml = FNFAssets.getText('assets/images/custom_ui/ui_packs/normal/NOTE_assets.xml');
		
		for (i in _song.notes[curSection].sectionNotes)
		{

			var note:EdtNote = setupNoteData(i);
			curRenderedNotes.add(note);

			if (note.sustainLength > 0)
			{
				var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2),
					note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(note.sustainLength, 0, Conductor.stepCrochet * 16, 0, gridBG.height)));
				curRenderedSustains.add(sustainVis);
			}

			note.mustPress = _song.notes[curSection].mustHitSection;
			if(i[1] > Main.ammo[_song.mania] - 1) note.mustPress = !note.mustPress;

		}

		// CURRENT EVENTS
		var startThing:Float = sectionStartTime();
		var endThing:Float = sectionStartTime(1);
		if (_song.events != null && _song.events.length > 0)
		{
			for (i in _song.events)
			{
				if(endThing > i[0] && i[0] >= startThing)
				{
					var note:EdtNote = setupNoteData(i);
					curRenderedNotes.add(note);
					
					if(note.y < -150) note.y = -150;

					var text:String = 'Event: ' + note.eventName + ' (' + Math.floor(note.strumTime) + ' ms)' + '\nValue 1: ' + note.eventVal1 + '\nValue 2: ' + note.eventVal2;
					if(note.eventLength > 1) text = note.eventLength + ' Events:\n' + note.eventName;

					var daText:AttachedFlxText = new AttachedFlxText(0, 0, 400, text, 12);
					daText.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
					daText.xAdd = -410;
					daText.borderSize = 1;
					if(note.eventLength > 1) daText.yAdd += 8;
					curRenderedNoteType.add(daText);
					daText.sprTracker = note;
					//trace('test: ' + i[0], 'startThing: ' + startThing, 'endThing: ' + endThing);
				}
			}
		}
	}

	function setupNoteData(i:Array<Dynamic>):EdtNote
	{
		var daNoteInfo = i[1];
		var daStrumTime = i[0];
		var daSus:Dynamic = i[2];
		var daLift = i[4];
		
		var note:EdtNote = new EdtNote(daStrumTime, daNoteInfo, daLift);
		if (daSus != null)
		{
			note.sustainLength = daSus;
		}
		else
		{
			note.loadGraphic(FNFAssets.getGraphicData('assets/images/eventArrow.png'));
			note.eventName = getEventName(i[1]);
			note.eventLength = i[1].length;
			if(i[1].length < 3)
			{
				note.eventVal1 = i[1][0][1];
				note.eventVal2 = i[1][0][2];
				note.eventVal3 = i[1][0][3];
			}
			note.noteData = -1;
			daNoteInfo = -1;
		}
		note.setGraphicSize(GRID_SIZE, GRID_SIZE);
		note.updateHitbox();
		note.x = Math.floor((daNoteInfo % (Main.ammo[_song.mania] * 2)) * GRID_SIZE) + GRID_SIZE;
		note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps)));

		return note;
	}

	function getEventName(names:Array<Dynamic>):String
	{
		var retStr:String = '';
		var addedOne:Bool = false;
		for (i in 0...names.length)
		{
			if(addedOne) retStr += ', ';
			retStr += names[i][0];
			addedOne = true;
		}
		return retStr;
	}

	private function addSection(lengthInSteps:Int = 16):Void
	{
		var sec:SwagSection = {
			lengthInSteps: lengthInSteps,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: true,
			sectionNotes: [],
			typeOfSection: 0,
			altAnim: false,
			altAnimNum: 0,
			crossfadeBf: false,
			crossfadeDad: false
		};

		_song.notes.push(sec);
	}

	function selectNote(note:EdtNote):Void
	{
		/*var swagNum:Int = 0;
		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i[0] == note.strumTime && i[1] % (Main.ammo[_song.mania]*2) == note.noteData % (Main.ammo[_song.mania]*2)) {
				curSelectedNote = _song.notes[curSection].sectionNotes[swagNum];
			}
			swagNum += 1;
		}

		if (UI_box.selected_tab != 3)
			UI_box.selected_tab = 3;
		*/

		var noteDataToCheck:Int = note.noteData;

		if(noteDataToCheck > -1)
		{
			if(note.mustPress != _song.notes[curSection].mustHitSection) noteDataToCheck += Main.ammo[_song.mania];
			for (i in _song.notes[curSection].sectionNotes)
			{
				if (i != curSelectedNote && i.length > 2 && i[0] == note.strumTime && i[1] == noteDataToCheck)
				{
					curSelectedNote = i;
					break;
				}
			}
		}
		else
		{
			for (i in _song.events)
			{
				if(i != curSelectedNote && i[0] == note.strumTime)
				{
					curSelectedNote = i;
					curEventSelected = Std.int(curSelectedNote[1].length) - 1;
					changeEventSelected();
					break;
				}
			}
		}

		updateGrid();
		updateNoteUI();
	}

	function deleteNote(note:EdtNote):Void
	{
		//if (note. != ) 
		if(note.noteData > -1) //Normal Notes
		{
			for (i in _song.notes[curSection].sectionNotes)
			{
				if (i[0] == note.strumTime && i[1] % 8 == note.noteData % 8)
				{
					FlxG.log.add('FOUND EVIL NUMBER');
					_song.notes[curSection].sectionNotes.remove(i);
				}
			}
		}
		else //Events
		{
			for (i in _song.events)
			{
				if(i[0] == note.strumTime)
				{
					if(i == curSelectedNote)
					{
						curSelectedNote = null;
						changeEventSelected();
					}
					//FlxG.log.add('FOUND EVIL EVENT');
					_song.events.remove(i);
					break;
				}
			}
		}

		updateGrid();
	}

	function clearSection():Void
	{
		_song.notes[curSection].sectionNotes = [];

		updateGrid();
	}

	function clearSong():Void
	{
		for (daSection in 0..._song.notes.length)
		{
			_song.notes[daSection].sectionNotes = [];
		}

		updateGrid();
	}

	private function addNote():Void
	{
		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime();
		var noteData = Math.floor((FlxG.mouse.x - GRID_SIZE) / GRID_SIZE);
		var noteSus = 0;
		var limit = Main.ammo[_song.mania] * 2;
		if (noteData > -1)
		{
			switch (noteType) {
				case Normal: 
					// nothing
				case Mine: 
					noteData += limit;
				case Lift: 
					noteData += limit*2;
				case Death: 
					noteData += limit*3;
				case key: 
					noteData += limit * key;
			}
		}

		if (noteData > -1)
		{
			_song.notes[curSection].sectionNotes.push([noteStrum, noteData, noteSus, false, useLiftNote]);
			curSelectedNote = _song.notes[curSection].sectionNotes[_song.notes[curSection].sectionNotes.length - 1];
		}
		else 
		{
			var event = eventStuff[Std.parseInt(eventDropDown.selectedId)][0];
			var text1 = value1InputText.text;
			var text2 = value2InputText.text;
			var text3 = value3InputText.text;
			_song.events.push([noteStrum, [[event, text1, text2, text3]]]);
			curSelectedNote = _song.events[_song.events.length - 1];
			curEventSelected = 0;
			changeEventSelected();
		}

		if (FlxG.keys.pressed.CONTROL && noteData > -1)
		{
			_song.notes[curSection].sectionNotes.push([noteStrum, (noteData + Main.ammo[_song.mania]) % (Main.ammo[_song.mania] * 2), noteSus, false, useLiftNote]);
		}

		trace(noteStrum);
		trace(curSection);

		updateGrid();
		updateNoteUI();

		autosaveSong();
	}

	function getStrumTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}

	/*
	function calculateSectionLengths(?sec:SwagSection):Int
	{
		var daLength:Int = 0;

		for (i in _song.notes)
		{
			var swagLength = i.lengthInSteps;

			if (i.typeOfSection == Section.COPYCAT)
				swagLength * 2;

			daLength += swagLength;

			if (sec != null && sec == i)
			{
				trace('swag loop??');
				break;
			}
		}

		return daLength;
	}*/

	private var daSpacing:Float = 0.3;

	function loadLevel():Void
	{
		trace(_song.notes);
	}

	function getNotes():Array<Dynamic>
	{
		var noteData:Array<Dynamic> = [];

		for (i in _song.notes)
		{
			noteData.push(i.sectionNotes);
		}

		return noteData;
	}

	function loadJson(song:String):Void
	{
		var diffSuxx:String = '-' + diffDropDown.selectedLabel.toLowerCase();
		if (diffSuxx == '-normal') {diffSuxx = '';}
		var poop:String = song.toLowerCase() + diffSuxx;
		PlayState.SONG = Song.loadFromJson(poop, song.toLowerCase());
		PlayState.storyDifficulty = Std.parseInt(diffDropDown.selectedId);
		FlxG.resetState();
	}

	function loadAutosave():Void
	{
		PlayState.SONG = Song.parseJSONshit(FlxG.save.data.autosave);
		FlxG.resetState();
	}

	function autosaveSong():Void
	{
		FlxG.save.data.autosave = Json.stringify({
			"song": _song
		});
		FlxG.save.flush();
	}

	function clearEvents() {
		_song.events = [];
		updateGrid();
	}

	private function saveLevel()
	{
		_song.events.sort(sortByTime);
		var json = {
			"song": _song
		};

		var data:String = CoolUtil.stringifyJson(json);

		if ((data != null) && (data.length > 0))
		{
			/*
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), _song.song.toLowerCase() + ".json");
			*/ 
			FNFAssets.askToSave(_song.song.toLowerCase() + '.json', data);
		}
	}

	function sortByTime(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
	}

	private function saveEvents()
	{
		_song.events.sort(sortByTime);

		var eventsSong:SwagSong = {
			song: _song.song,
			notes: [],
			events: _song.events,
			bpm: _song.bpm,
			needsVoices: _song.needsVoices,
			player1: _song.player1,
			player2: _song.player2,
			stage: _song.stage,
			gf: _song.gf,
			isHey: _song.isHey,
			speed: _song.speed,
			isSpooky: _song.isSpooky,
			isMoody: _song.isMoody,
			cutsceneType: _song.cutsceneType,
			uiType: _song.uiType,
			isCheer: _song.isCheer,
			preferredNoteAmount: _song.preferredNoteAmount,
			forceJudgements: false,
			convertMineToNuke: false,
			mania: _song.mania
		};

		var json = {
			"song": eventsSong
		}

		var data:String = Json.stringify(json, "\t");

		if ((data != null) && (data.length > 0))
		{
			FNFAssets.askToSave('events.json', data);
		}
	}

	/*
	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}
	*/
	/**
	 * Called when the save file dialog is cancelled.
	 */
	 /*
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}
	*/
	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	 /*
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}*/
}

class AttachedFlxText extends FlxText
{
	public var sprTracker:FlxSprite;
	public var xAdd:Float = 0;
	public var yAdd:Float = 0;

	public function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true) {
		super(X, Y, FieldWidth, Text, Size, EmbeddedFont);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null) {
			setPosition(sprTracker.x + xAdd, sprTracker.y + yAdd);
			angle = sprTracker.angle;
			alpha = sprTracker.alpha;
		}
	}
}