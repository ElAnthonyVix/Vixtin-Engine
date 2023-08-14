package;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
#if mobile
import flixel.input.actions.FlxActionInput;
import android.AndroidControls.AndroidControls;
import android.FlxVirtualPad;
#end
class MusicBeatState extends FlxUIState
{
	public var lastBeat:Float = 0;
	public var lastStep:Float = 0;

	public var curStep:Int = 0;
	public var curBeat:Int = 0;
	public var controls(get, never):Controls;
	public var controlsPlayerTwo(get, never):Controls;
	inline function get_controls():Controls
		return PlayerSettings.player1.controls;
	inline function get_controlsPlayerTwo():Controls
		return PlayerSettings.player2.controls;
	#if mobile
	public var _virtualpad:FlxVirtualPad;
	var androidc:AndroidControls;
	var trackedinputsUI:Array<FlxActionInput> = [];
	var trackedinputsNOTES:Array<FlxActionInput> = [];
	#end
	#if mobile
	public function addVirtualPad(?DPad:FlxDPadMode, ?Action:FlxActionMode) {
		_virtualpad = new FlxVirtualPad(DPad, Action, 0.75, true);
		add(_virtualpad);
		controls.setVirtualPadUI(_virtualpad, DPad, Action);
		trackedinputsUI = controls.trackedinputsUI;
		controls.trackedinputsUI = [];
	}
	#end

	#if mobile
	public function removeVirtualPad() {
		controls.removeFlxInput(trackedinputsUI);
		remove(_virtualpad);
	}
	#end

	#if mobile
	public function addAndroidControls(isOpp:Bool = false) {
                androidc = new AndroidControls();

		switch (androidc.mode)
		{
			case VIRTUALPAD_RIGHT | VIRTUALPAD_LEFT | VIRTUALPAD_CUSTOM:
if (isOpp)
				controls.setVirtualPadNOTES(androidc.vpad, FULL, NONE);
				
			case DUO:
				if (!ModifierState.namedModifiers.duo.value){
					if (ModifierState.namedModifiers.oppnt.value)
						controlsPlayerTwo.setVirtualPadNOTES(androidc.vpad, RIGHT_FULL, NONE);
					else
						controls.setVirtualPadNOTES(androidc.vpad, DUO, NONE);
				}
				else {
					controls.setVirtualPadNOTES(androidc.vpad, RIGHT_FULL, NONE);
					controlsPlayerTwo.setVirtualPadNOTES(androidc.vpad, FULL, NONE);
				}
			case HITBOX:
				if (ModifierState.namedModifiers.duo.value){
				addHitBoi(true);
				addHitBoi(false);
				}
				else{
				addHitBoi(ModifierState.namedModifiers.oppnt.value);	
				}
			default:
		}

		trackedinputsNOTES = controls.trackedinputsNOTES;
		controls.trackedinputsNOTES = [];

		var camcontrol = new flixel.FlxCamera();
		FlxG.cameras.add(camcontrol);
		camcontrol.bgColor.alpha = 0;
		androidc.cameras = [camcontrol];

		androidc.visible = false;

		add(androidc);
	}
	public function addHitBoi(isOpp:Bool = false){
		var mania = 0;
				if (PlayState.SONG != null)
					mania = PlayState.SONG.mania;
				if (!isOpp)
				controls.setHitBox(androidc.hbox,mania);
				else
				controlsPlayerTwo.setHitBox(androidc.hbox,mania);	
	}
	#end

	#if mobile
        public function addPadCamera() {
		var camcontrol = new flixel.FlxCamera();
		FlxG.cameras.add(camcontrol);
		camcontrol.bgColor.alpha = 0;
		_virtualpad.cameras = [camcontrol];
	}
	#end
	
	override function destroy() {
		#if mobile
		controls.removeFlxInput(trackedinputsUI);
		controls.removeFlxInput(trackedinputsNOTES);	
		#end	
		
		super.destroy();
	}

	override function create()
	{
		if (transIn != null)
			trace('reg ' + transIn.region);

		#if (!web)
		TitleState.soundExt = '.ogg';
		#end

		super.create();
	}

	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();

		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//do literally nothing dumbass
	}
}
