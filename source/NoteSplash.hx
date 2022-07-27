package;
import openfl.display.BitmapData;
import flixel.FlxSprite;
import DynamicSprite.DynamicAtlasFrames;
import flixel.FlxG;
import Judgement.TUI;
import flixel.graphics.frames.FlxAtlasFrames;

class NoteSplash extends FlxSprite {

    public static var getFrames:Bool = true;
	static var gotFrames:FlxAtlasFrames = null;

    public function new(xPos:Float,yPos:Float,?c:Int) {
        if (c == null) c = 0;
        super(xPos,yPos);

        //setAnims(c);
        setupNoteSplash(xPos,xPos,c);
    }
    public function setupNoteSplash(xPos:Float, yPos:Float, ?c:Int) {
        if (c == null) c = 0;
        setPosition(xPos, yPos);

        setAnims(c);

        alpha = 0.6;
        animation.play("note"+c+"-"+FlxG.random.int(0,1), true);
		animation.curAnim.frameRate += FlxG.random.int(-2, 2);
        if (animation.curAnim.frameRate < 6)
        {
            animation.curAnim.frameRate = 6;
        }
        updateHitbox();
        offset.set(0.3 * width, 0.3 * height);
    }
    private function setAnims(?c:Int) {
        var curUiType:TUI = Reflect.field(Judgement.uiJson, PlayState.SONG.uiType);

        //frames = DynamicAtlasFrames.fromSparrow('assets/images/custom_ui/ui_packs/${curUiType.uses}/noteSplashes.png',
        //'assets/images/custom_ui/ui_packs/${curUiType.uses}/noteSplashes.xml');

        if (getFrames) {
            getFrames = false;
            gotFrames = DynamicAtlasFrames.fromSparrow('assets/images/custom_ui/ui_packs/${curUiType.uses}/noteSplashes.png',
            'assets/images/custom_ui/ui_packs/${curUiType.uses}/noteSplashes.xml');
        }
        frames = gotFrames;
        
        if (PlayState.SONG.mania == 0)
        {
            animation.addByPrefix("note1-0", "note impact 1  blue", 24, false);
            animation.addByPrefix("note2-0", "note impact 1 green", 24, false);
            animation.addByPrefix("note0-0", "note impact 1 purple", 24, false);
            animation.addByPrefix("note3-0", "note impact 1 red", 24, false);

            animation.addByPrefix("note1-1", "note impact 2 blue", 24, false);
            animation.addByPrefix("note2-1", "note impact 2 green", 24, false);
            animation.addByPrefix("note0-1", "note impact 2 purple", 24, false);
            animation.addByPrefix("note3-1", "note impact 2 red", 24, false);
        }

        if (PlayState.SONG.mania == 1)
        {
            animation.addByPrefix("note0-0", "note impact 1 purple", 24, false);
            animation.addByPrefix("note1-0", "note impact 1 green", 24, false);
            animation.addByPrefix("note2-0", "note impact 1 red", 24, false);
            animation.addByPrefix("note3-0", "note impact 1 yellow", 24, false);
            animation.addByPrefix("note4-0", "note impact 1  blue", 24, false);
            animation.addByPrefix("note5-0", "note impact 1 cyan", 24, false);

            animation.addByPrefix("note0-1", "note impact 2 purple", 24, false);
            animation.addByPrefix("note1-1", "note impact 2 green", 24, false);
            animation.addByPrefix("note2-1", "note impact 2 red", 24, false);
            animation.addByPrefix("note3-1", "note impact 2 yellow", 24, false);
            animation.addByPrefix("note4-1", "note impact 2 blue", 24, false);
            animation.addByPrefix("note5-1", "note impact 2 cyan", 24, false);
        }

        if (PlayState.SONG.mania == 2)
        {
            animation.addByPrefix("note0-0", "note impact 1 purple", 24, false);
            animation.addByPrefix("note1-0", "note impact 1 green", 24, false);
            animation.addByPrefix("note2-0", "note impact 1 red", 24, false);
            animation.addByPrefix("note3-0", "note impact 1 white", 24, false);
            animation.addByPrefix("note4-0", "note impact 1 yellow", 24, false);
            animation.addByPrefix("note5-0", "note impact 1  blue", 24, false);
            animation.addByPrefix("note6-0", "note impact 1 cyan", 24, false);

            animation.addByPrefix("note0-1", "note impact 2 purple", 24, false);
            animation.addByPrefix("note1-1", "note impact 2 green", 24, false);
            animation.addByPrefix("note2-1", "note impact 2 red", 24, false);
            animation.addByPrefix("note3-1", "note impact 2 white", 24, false);
            animation.addByPrefix("note4-1", "note impact 2 yellow", 24, false);
            animation.addByPrefix("note5-1", "note impact 2 blue", 24, false);
            animation.addByPrefix("note6-1", "note impact 2 cyan", 24, false);
        }

        if (PlayState.SONG.mania == 3)
        {
            animation.addByPrefix("note1-0", "note impact 1  blue", 24, false);
            animation.addByPrefix("note2-0", "note impact 1 green", 24, false);
            animation.addByPrefix("note0-0", "note impact 1 purple", 24, false);
            animation.addByPrefix("note3-0", "note impact 1 red", 24, false);
            animation.addByPrefix("note4-0", "note impact 1 white", 24, false);
            animation.addByPrefix("note5-0", "note impact 1 yellow", 24, false);
            animation.addByPrefix("note6-0", "note impact 1 lila", 24, false);
            animation.addByPrefix("note7-0", "note impact 1 cherry", 24, false);
            animation.addByPrefix("note8-0", "note impact 1 cyan", 24, false);

            animation.addByPrefix("note1-1", "note impact 2 blue", 24, false);
            animation.addByPrefix("note2-1", "note impact 2 green", 24, false);
            animation.addByPrefix("note0-1", "note impact 2 purple", 24, false);
            animation.addByPrefix("note3-1", "note impact 2 red", 24, false);
            animation.addByPrefix("note4-1", "note impact 2 white", 24, false);
            animation.addByPrefix("note5-1", "note impact 2 yellow", 24, false);
            animation.addByPrefix("note6-1", "note impact 2 lila", 24, false);
            animation.addByPrefix("note7-1", "note impact 2 cherry", 24, false);
            animation.addByPrefix("note8-1", "note impact 2 cyan", 24, false);
        }

    }
    override public function update(elapsed) {
        if (animation.curAnim.finished) {
            // club pengiun is
            kill();
        }
        super.update(elapsed);
    }
}