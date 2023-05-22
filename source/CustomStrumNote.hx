package;

import sys.io.File;
import haxe.Json;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import sys.FileSystem;

using StringTools;

typedef RhythmStrum = {
	var noteKey:Array<String>;
    var animationToPlay:String;
    var soundEffect:String;
    var multipleKeys:String;
    var hideNote:Bool;
    var scoreAdded:Int;
    var strumName:String;
	var mustHit:Bool;
}

class CustomStrumNote extends FlxSprite
{
	public var noteKey:Array<String>;
    public var animationToPlay:String;
    public var soundEffect:String;
    public var multipleKeys:String;
    public var hideNote:Bool;
    public var scoreAdded:Int;
    public var strumName:String;
	public var mustHit:Bool;

	private var colorSwap:ColorSwap;
	public var resetAnim:Float = 0;
	private var noteData:Int = 0;
	public var direction:Float = 90;//plan on doing scroll directions soon -bb
	public var downScroll:Bool = false;//plan on doing scroll directions soon -bb
	public var sustainReduce:Bool = true;

	var strumFile:RhythmStrum;
	
	private var player:Int;
	
	public var texture(default, set):String = null;
	private function set_texture(value:String):String {
		if(texture != value) {
			texture = value;
			reloadNote();
		}
		return value;
	}

	public function new(x:Float, y:Float, leData:Int, strumFile:RhythmStrum) {
		this.strumFile = strumFile;

		colorSwap = new ColorSwap();
		shader = colorSwap.shader;
		noteData = leData;
		this.player = strumFile.mustHit ? 1 : 0;
		this.noteData = leData;
		super(x, y);

		this.alpha = strumFile.hideNote ? 0.0001 : 0.8;

		texture = 'NOTE_assets'; //Load texture and anims

		scrollFactor.set();
	}

	public function reloadNote()
	{
		var lastAnim:String = null;
		if(animation.curAnim != null) lastAnim = animation.curAnim.name;
		else
		{
			frames = Paths.getSparrowAtlas(texture);

			antialiasing = ClientPrefs.globalAntialiasing;
			setGraphicSize(Std.int(width * 0.7));

			switch (this.strumFile.noteKey[0])
			{
				case "BUTTON1":
					animation.addByPrefix('static', 'arrowLEFT');
					animation.addByPrefix('pressed', 'left press', 24, false);
					animation.addByPrefix('confirm', 'left confirm', 24, false);
				case "BUTTON2":
					animation.addByPrefix('static', 'arrowRIGHT');
					animation.addByPrefix('pressed', 'right press', 24, false);
					animation.addByPrefix('confirm', 'right confirm', 24, false);
				default:
			}
		}
		updateHitbox();

		if(lastAnim != null)
		{
			playAnim(lastAnim, true);
		}
	}

	public function postAddedToGroup() {
		playAnim('static');
		x += Note.swagWidth * noteData;
		x += 50;
		x += ((FlxG.width / 2) * player);
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
		if(animation.curAnim.name == 'confirm' && !PlayState.isPixelStage) {
			centerOrigin();
		//}
		}

		super.update(elapsed);
	}

	public function playAnim(anim:String, ?force:Bool = false) {
		animation.play(anim, force);
		centerOffsets();
		centerOrigin();
		if(animation.curAnim == null || animation.curAnim.name == 'static') {
			colorSwap.hue = 0;
			colorSwap.saturation = 0;
			colorSwap.brightness = 0;
		} else {
			if (noteData > -1 && noteData < ClientPrefs.arrowHSV.length)
			{
				colorSwap.hue = ClientPrefs.arrowHSV[noteData][0] / 360;
				colorSwap.saturation = ClientPrefs.arrowHSV[noteData][1] / 100;
				colorSwap.brightness = ClientPrefs.arrowHSV[noteData][2] / 100;
			}

			if(animation.curAnim.name == 'confirm' && !PlayState.isPixelStage) {
				centerOrigin();
			}
		}
	}
	public function loadFromJson(){
		var currentFile = PlayState.SONG.song;
		var ret = "";
		var gamingPath = Paths.formatToSongPath(currentFile);
		if (FileSystem.exists(gamingPath)){
			for (file in FileSystem.readDirectory(gamingPath)){
				var gayPath = haxe.io.Path.join([gamingPath, file]);

				try{
					var rawJson:String = File.getContent(gayPath);

					var loadedStrum:RhythmStrum = cast Json.parse(rawJson);
					if(loadedStrum.strumName != null && loadedStrum.noteKey != null){

						trace("Successfully loaded Strum: " + loadedStrum.strumName);
						return loadedStrum;
					}
				} catch(err){
					trace(err);
				}
			}
		}
		return null;
	}
}
