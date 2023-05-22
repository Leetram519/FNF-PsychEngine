package editors;

import flixel.addons.ui.FlxUISlider;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIDropDownMenu.FlxUIDropDownHeader;
import openfl.net.FileFilter;
#if desktop
import Discord.DiscordClient;
#end
import animateatlas.AtlasFrameMaker;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.graphics.FlxGraphic;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import openfl.net.FileReference;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import haxe.Json;
import Character;
import flixel.system.debug.interaction.tools.Pointer.GraphicCursorCross;
import lime.system.Clipboard;
import flixel.animation.FlxAnimation;
import sys.io.File;
import Controls;

#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;

typedef RhythmStrum = 
{
    // Json variables
	var noteKey:Array<String>;
    var animationToPlay:String;
    var soundEffect:String;
    var multipleKeys:String;
    var hideNote:Bool;
    var scoreAdded:Int;
    var strumName:String;
    var mustHit:Bool;
    var soundVolume:Float;
}

class StrumGenerateState extends MusicBeatState{
    private static var _file:FileReference;

    var infoTexts:FlxTypedGroup<FlxText>;
    var boxes:FlxTypedGroup<Dynamic>;

    var saveButton:FlxUIButton;
    var loadButton:FlxUIButton;

    var noteKeyBox:FlxUIDropDownMenu;
    var animationToPlayBox:FlxUIInputText;
    var soundEffectBox:FlxUIInputText;
    var multipleKeysBox:FlxUIInputText;
    var hideNoteBox:FlxUICheckBox;
    var scoreAddedBox:FlxUIInputText;
    var strumNameBox:FlxUIInputText;
    var mustHitCheck:FlxUICheckBox;
    var soundVolumeSlider:FlxUISlider;

	var blockPressWhileTypingOn:Array<FlxUIInputText> = [];
    var strumFile:RhythmStrum;
    public static var loadedStrum:RhythmStrum;

    // Json variables
	var noteKey:Array<String>;
    var animationToPlay:String;
    var soundEffect:String;
    var multipleKeys:String;
    var hideNote:Bool;
    var scoreAdded:Int;
    var strumName:String;
    var mustHit:Bool;
    var soundVolume:Float;

    var keys:Array<String> = [
        "BUTTON1",
        "BUTTON2"
    ];

    function makeStrumFile():RhythmStrum{

        var strumFile:RhythmStrum = {
            noteKey: ["BUTTON1"],
            animationToPlay: "singLEFT",
            soundEffect:"",
            multipleKeys: "",
            hideNote: true,
            scoreAdded: 100,
            strumName: "Not assigned!",
            mustHit: true,
            soundVolume: 0.4
        };

        return strumFile;
    }

    public function new(strumFile:RhythmStrum = null){
        super();

        this.strumFile = makeStrumFile();
        if(strumFile != null) this.strumFile = strumFile;
        else strumName = "My new strum";
    }

    override function create(){
        FlxG.mouse.visible = true;

        boxes = new FlxTypedGroup<Dynamic>();
        infoTexts= new FlxTypedGroup<FlxText>();

        var bg = new FlxSprite(0,0).loadGraphic(Paths.image("menuDesat"));
        bg.color = FlxColor.ORANGE;
        add(bg);
        super.create();

        makeEditor();
        makeStrumFile();
        reloadAllShit();
    }

    // Used in create() and on loading file
    function reloadAllShit(){
        /*
        // Json variables   
        var noteKey:Array<String>;
        var animationToPlay:String;
        var soundEffect:String;
        var multipleKeys:Bool;
        var hideNote:Bool;
        var scoreAdded:Int;
        var strumName:String;
        */

        noteKeyBox.selectedLabel = strumFile.noteKey[0];
        animationToPlayBox.text = strumFile.animationToPlay;
        soundEffectBox.text = strumFile.soundEffect;
        multipleKeysBox.text = strumFile.multipleKeys;
        hideNoteBox.checked = strumFile.hideNote;
        scoreAddedBox.text = Std.string(strumFile.scoreAdded);
        strumNameBox.text = strumFile.strumName;
        mustHitCheck.checked = strumFile.mustHit;
        soundVolumeSlider.value = strumFile.soundVolume;
    }

    function makeEditor(){
        noteKeyBox = new FlxUIDropDownMenu(0, 20, FlxUIDropDownMenu.makeStrIdLabelArray(keys, false), function(control:String){
            strumFile.noteKey = [control];
        });
        noteKeyBox.x = 30;
        noteKeyBox.y = 20;
        noteKeyBox.selectedLabel = strumFile.noteKey[0];
        animationToPlayBox = new FlxUIInputText(30, 80, 300, null, 16, FlxColor.BLACK, FlxColor.GRAY);
        soundEffectBox = new FlxUIInputText(30, 140, 300, null, 16, FlxColor.BLACK, FlxColor.GRAY);
        multipleKeysBox = new FlxUIInputText(30, 200, 300, null, 16, FlxColor.BLACK, FlxColor.GRAY);
        hideNoteBox = new FlxUICheckBox(30, 260, null, null, "Hide note ?", 100, null, function()
            {
                strumFile.hideNote = hideNoteBox.checked;
            });
        scoreAddedBox = new FlxUIInputText(30, 320, 300, null, 16, FlxColor.BLACK, FlxColor.GRAY);
        strumNameBox = new FlxUIInputText(30, 380, 300, null, 16, FlxColor.BLACK, FlxColor.GRAY);
        mustHitCheck = new FlxUICheckBox(200, 260, null, null, "Must Hit ?", 100, null, function()
            {
                strumFile.mustHit = mustHitCheck.checked;
            });

        soundVolumeSlider = new FlxUISlider(this, "soundVolume", 400, 140, 0.0, 1.0, 150, null, 5, FlxColor.WHITE, FlxColor.BLACK);
        soundVolumeSlider.setTexts("Volume of the sound Effect", true, "0", "1");


        saveButton = new FlxUIButton(30, 440, "Save", function() {
			saveJsonFile();
		}, true, false, FlxColor.WHITE);

        loadButton = new FlxUIButton(30, 500, "Load", function() {
			loadJsonFile();
		}, true, false, FlxColor.WHITE);

		infoTexts.add(new FlxText(noteKeyBox.x, noteKeyBox.y - 18, 0, 'Key to press:'));
        infoTexts.add(new FlxText(animationToPlayBox.x, animationToPlayBox.y - 18, 0, 'Animation to play on Hit:'));
		infoTexts.add(new FlxText(soundEffectBox.x, soundEffectBox.y - 18, 0, 'Sound effect to play on Hit:'));
		infoTexts.add(new FlxText(multipleKeysBox.x, multipleKeysBox.y - 18, 0, 'Additionnal Keys ? If yes, add their name here (noteLEFT, noteRIGHT...)'));
		infoTexts.add(new FlxText(scoreAddedBox.x, scoreAddedBox.y - 18, 0, 'Score to add on hit:'));
		infoTexts.add(new FlxText(strumNameBox.x, strumNameBox.y - 18, 0, 'Name of the arrow:'));
        
        boxes.add(animationToPlayBox);
        boxes.add(soundEffectBox);
        boxes.add(multipleKeysBox);
        boxes.add(hideNoteBox);
        boxes.add(scoreAddedBox);
        boxes.add(strumNameBox);
        boxes.add(saveButton);
        boxes.add(loadButton);
        boxes.add(noteKeyBox);
        boxes.add(mustHitCheck);
        boxes.add(soundVolumeSlider);

        boxes.forEach(function (i:Dynamic){
		    blockPressWhileTypingOn.push(i);
        });

        add(infoTexts);
        add(boxes);
    }

    override function update(elapsed){
        if(loadedStrum != null) {
			strumFile = loadedStrum;
			loadedStrum = null;

			reloadAllShit();
		}

        if(FlxG.keys.justPressed.ESCAPE) {
            MusicBeatState.switchState(new editors.MasterEditorMenu());
            FlxG.sound.playMusic(Paths.music('freakyMenu'));
        }

        super.update(elapsed);
    }

    override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>) {
		if(id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText)) {
			if(sender == animationToPlayBox){
                strumFile.animationToPlay = animationToPlayBox.text.trim();
            } else if(sender == soundEffectBox){
                strumFile.soundEffect = soundEffectBox.text.trim();
            } else if(sender == scoreAddedBox){
                strumFile.scoreAdded = Std.parseInt(scoreAddedBox.text.trim());
            } else if(sender == strumNameBox){
                strumFile.strumName = strumNameBox.text.trim();
            } else if(sender == multipleKeysBox){
                strumFile.multipleKeys = multipleKeysBox.text.trim();
            } else if(sender == soundVolumeSlider){
                strumFile.soundVolume = soundVolumeSlider.value;
            }
		}
	}

    private function translateStringToControl(control:String){
        switch(control){
            case "BUTTON1":
                return Controls.Control.BUTTON1;
            case "BUTTON2":
                return Controls.Control.BUTTON2;
            default:
                return null;
        }
    }


    // SAVE

    function onSaveComplete(_):Void
        {
            _file.removeEventListener(Event.COMPLETE, onSaveComplete);
            _file.removeEventListener(Event.CANCEL, onSaveCancel);
            _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
            _file = null;
            FlxG.log.notice("Successfully saved file.");
        }

    /**
		* Called if there is an error while saving the gameplay recording.
		*/
	function onSaveError(_):Void
        {
            _file.removeEventListener(Event.COMPLETE, onSaveComplete);
            _file.removeEventListener(Event.CANCEL, onSaveCancel);
            _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
            _file = null;
            FlxG.log.error("Problem saving file");
        }

    /**
		* Called when the save file dialog is cancelled.
		*/
	function onSaveCancel(_):Void
        {
            _file.removeEventListener(Event.COMPLETE, onSaveComplete);
            _file.removeEventListener(Event.CANCEL, onSaveCancel);
            _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
            _file = null;
        }

    function saveJsonFile(){
        var json = {
			"noteKey": strumFile.noteKey,
			"animationToPlay": strumFile.animationToPlay,
			"soundEffect": strumFile.soundEffect,
			"multipleKeys": strumFile.multipleKeys,
			"scoreAdded": strumFile.scoreAdded,
			"hideNote":	strumFile.hideNote,
            "strumName": strumFile.strumName,
            "mustHit": strumFile.mustHit,
            "soundVolume": strumFile.soundVolume
		};

        var data:String = Json.stringify(json, "\t");

        
		if (data.length > 0)
            {
                _file = new FileReference();
                _file.addEventListener(Event.COMPLETE, onSaveComplete);
                _file.addEventListener(Event.CANCEL, onSaveCancel);
                _file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
                _file.save(data, strumFile.strumName + ".json");
            }
    }

    // LOAD

	public static function loadJsonFile() {
		var jsonFilter:FileFilter = new FileFilter('JSON', 'json');
		_file = new FileReference();
		_file.addEventListener(Event.SELECT, onLoadComplete);
		_file.addEventListener(Event.CANCEL, onLoadCancel);
		_file.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file.browse([jsonFilter]);
	}

	public static var loadError:Bool = false;
	private static function onLoadComplete(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);

		#if sys
		var fullPath:String = null;
		@:privateAccess
		if(_file.__path != null) fullPath = _file.__path;

		if(fullPath != null) {
			var rawJson:String = File.getContent(fullPath);
			if(rawJson != null) {
                // Gaming
                loadedStrum = cast Json.parse(rawJson);
                if(loadedStrum.strumName != null && loadedStrum.noteKey != null){
                    var cutName:String = _file.name.substr(0, _file.name.length - 5);

                    trace("Successfully loaded file: " + cutName);
                    loadError = false;

                    _file = null;
                    return;
                }

			}
		}
		loadError = true;
		_file = null;
		#else
		trace("File couldn't be loaded! You aren't on Desktop, are you?");
		#end
	}

    /**
    * Called when the save file dialog is cancelled.
    */
    private static function onLoadCancel(_):Void
        {
            _file.removeEventListener(Event.SELECT, onLoadComplete);
            _file.removeEventListener(Event.CANCEL, onLoadCancel);
            _file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
            _file = null;
            trace("Cancelled file loading.");
        }
        
    /**
        * Called if there is an error while saving the gameplay recording.
        */
    private static function onLoadError(_):Void
    {
        _file.removeEventListener(Event.SELECT, onLoadComplete);
        _file.removeEventListener(Event.CANCEL, onLoadCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
        _file = null;
        trace("Problem loading file");
    }
}