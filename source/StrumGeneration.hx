package;

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

#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;

typedef RhythmStrum = {
	var noteKey:Array<String>;
    var animationToPlay:String;
    var soundEffect:String;
    var multipleKeys:Bool;
    var hideNote:Bool;
    var scoreAdded:Int;
    var strumName:String;
}

class StrumGenerateState extends MusicBeatState{
    var currentStrum:RhythmStrum;
    private static var _file:FileReference;

    var infoTexts:FlxTypedGroup<FlxText>;
    var boxes:FlxTypedGroup<Dynamic>;

    var noteKeyBox:FlxUIDropDownHeader;
    var animationToPlayBox:FlxUIInputText;
    var soundEffectBox:FlxUIInputText;
    var multipleKeysBox:FlxUIInputText;
    var hideNoteBox:FlxUICheckBox;
    var scoreAddedBox:FlxUIInputText;
    var strumNameBox:FlxUIInputText;

    override function create(){
        super.create();

        makeEditor();
        reloadAllShit();
    }

    // Used in create() and on loading file
    function reloadAllShit(){
        
    }

    function makeEditor(){
        noteKeyBox = new FlxUIDropDownHeader(120);
        noteKeyBox.x = 0;
        noteKeyBox.y = 20;
        boxes.add(noteKeyBox);
        animationToPlayBox = new FlxUIInputText(0, 80, 300, null, 16, FlxColor.BLACK, FlxColor.GRAY);
        boxes.add(animationToPlayBox);
        soundEffectBox = new FlxUIInputText(0, 140, 300, null, 16, FlxColor.BLACK, FlxColor.GRAY);
        boxes.add(soundEffectBox);
        multipleKeysBox = new FlxUIInputText(0, 200, 300, null, 16, FlxColor.BLACK, FlxColor.GRAY);
        boxes.add(multipleKeysBox);
        hideNoteBox = new FlxUICheckBox(0, 260);
        boxes.add(hideNoteBox);
        scoreAddedBox = new FlxUIInputText(0, 320, 300, null, 16, FlxColor.BLACK, FlxColor.GRAY);
        boxes.add(scoreAddedBox);
        strumNameBox = new FlxUIInputText(0, 380, 300, null, 16, FlxColor.BLACK, FlxColor.GRAY);
        boxes.add(strumNameBox);

		infoTexts.add(new FlxText(noteKeyBox.x, noteKeyBox.y - 18, 0, 'Key to press:'));
        infoTexts.add(new FlxText(animationToPlayBox.x, animationToPlayBox.y - 18, 0, 'Animation to play on Hit:'));
		infoTexts.add(new FlxText(soundEffectBox.x, soundEffectBox.y - 18, 0, 'Sound effect to play on Hit:'));
		infoTexts.add(new FlxText(multipleKeysBox.x, multipleKeysBox.y - 18, 0, 'Additionnal Keys ? If yes, add their name here (noteLEFT, noteRIGHT...)'));
		infoTexts.add(new FlxText(hideNoteBox.x, hideNoteBox.y - 18, 0, 'Hide note ?'));
		infoTexts.add(new FlxText(scoreAddedBox.x, scoreAddedBox.y - 18, 0, 'Score to add on hit:'));
		infoTexts.add(new FlxText(strumNameBox.x, strumNameBox.y - 18, 0, 'Name of the arrow:'));
        
        add(boxes);
        add(infoTexts);
    }

    override function update(elapsed){
        super.update(elapsed);
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
			"noteKey": currentStrum.noteKey,
			"animationToPlay": currentStrum.animationToPlay,
			"soundEffect": currentStrum.soundEffect,
			"multipleKeys": currentStrum.multipleKeys,
			"scoreAdded": currentStrum.scoreAdded,
			"hideNote":	currentStrum.hideNote,
            "strumName": currentStrum.strumName
		};

        var data:String = Json.stringify(json, "\t");

        
		if (data.length > 0)
            {
                _file = new FileReference();
                _file.addEventListener(Event.COMPLETE, onSaveComplete);
                _file.addEventListener(Event.CANCEL, onSaveCancel);
                _file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
                _file.save(data, currentStrum.strumName + ".json");
            }
    }

    // LOAD

	public static function loadWeek() {
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

				return;
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