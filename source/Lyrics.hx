package;

import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import haxe.Json;
import PlayState;
import sys.io.File;
import sys.FileSystem;
using StringTools;

/**
 * The Lyric system is a little complicated but that's because I wanted to do something neat with it!
 * basically, you'll input the point of steps (1 by default, the starting step), then for each "/" used within the lyrics
 * you can input the step at which that division will be highlighted. If the number of steps exceeds the amount of divisions,
 * then the lyrics will end at the first succeeding step.
 */
typedef LyricMeasure = {
    var steps:Array<Float>; 
    var curString:String;
    var font:String;
}

/**
 * author @Yoshubs
 * i might be a little proud of this system LOL
 */
class Lyrics extends FlxTypedGroup<FlxText> {
    public static function parseLyrics(file:String) {
            var lyricsFile = File.getContent(file).trim();
            while (!lyricsFile.endsWith("}"))
                lyricsFile = lyricsFile.substr(0, lyricsFile.length - 1);

            var lyricsList:Array<LyricMeasure> = cast Json.parse(lyricsFile).lyrics;
            trace('lyrics found succesfully');
            return lyricsList;

    }

    public var lyrics:Array<LyricMeasure>;
    public var stepProgression:Float = 0;
    public var funniX:Int;
    public var funniY:Int;
    public function new(lyrics:Array<LyricMeasure>,x:Int = 0,y:Int = 0) {


        funniX = x;
        funniY = y;
        this.lyrics = lyrics;

        
        if (lyrics[0].font == "" || lyrics[0].font == "null" || !FNFAssets.exists(SUtil.getPath() + 'assets/fonts/' + lyrics[0].font))
            lyrics[0].font = "vcr.ttf";

        lyrics.sort(function(lyric1:LyricMeasure, lyric2:LyricMeasure):Int {
            if (lyric1.steps[0] < lyric2.steps[0])
                return -1;
            else return 1;
        });
        trace(lyrics);
        super();
    }

    override public function update(elapsed:Float) {
        if (PlayState.instance.curStep > stepProgression) {
            stepProgression = PlayState.instance.curStep;
            updateLyrics();
        }
        super.update(elapsed);
    }

    public var currentFocusedLyric:LyricMeasure;
    public var currentDivisionAmount:Int = 0;
    public function updateLyrics() {
        while (lyrics.length > 0 && lyrics[0] != null && lyrics[0].steps[0] <= stepProgression) {
            clearOldText();

            var myLyrics:LyricMeasure = lyrics[0];


            // add to this lol
            var myLyricArray:Array<String> = myLyrics.curString.split('/');
            currentDivisionAmount = myLyricArray.length;
            for (text in myLyricArray) {
                var newText:FlxText = new FlxText(0,0,0,text+"\n");


                newText.setFormat(SUtil.getPath() + 'assets/fonts/' + lyrics[0].font), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
                newText.antialiasing = false;
                newText.scrollFactor.set();
                newText.borderSize = 1.5;
                add(newText);
            }
            trace(members);

            currentFocusedLyric = myLyrics;
            lyrics.splice(lyrics.indexOf(myLyrics), 1);
        }

        if (currentFocusedLyric != null) {
            var mySteps:Array<Float> = currentFocusedLyric.steps;
            mySteps.sort(function(step:Float, otherStep:Float){
                if (step < otherStep)
                    return -1;
                else return 1;
            });
            // reset all lyrics
            var totalTextLength:Float = 0;
            for (i in 0...members.length) 
                totalTextLength += members[i].width;
            for (i in 0...members.length) {
                var text:FlxText = members[i];
                text.x = FlxG.width / 2 + funniX;
                text.y = 534 + funniY;
                text.x -= totalTextLength / 2;
                text.color = FlxColor.fromRGB(255, 255, 255);
                if (i > 0)
                    text.x = (members[i - 1].x + members[i - 1].width);
            }

            // find the current division
            var curDivision:Int = 0;
            for (i in 0...mySteps.length) {
                if (stepProgression >= mySteps[i]) {
                    curDivision = i;
                    // break;
                }
            }

            if (curDivision < currentDivisionAmount && members[curDivision] != null) {
                var highlightedLyric:FlxText = members[curDivision];
                highlightedLyric.color = FlxColor.RED;
                highlightedLyric.y -= 4;
            }
            else // delete the current lyric if its over the max divisions
            if (curDivision >= currentDivisionAmount)
                clearOldText();
        }

    }

    public function clearOldText() {
        // delete old text
        if (this.members.length > 0) {
            this.forEach(function(textMember:FlxText){
            if (textMember != null) 
                textMember.destroy();
            });
        }
        clear();
        currentFocusedLyric = null;
    }
}

