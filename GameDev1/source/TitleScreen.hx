package;

import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.system.FlxSound;
import openfl.Lib;
import flixel.FlxSprite;

/**
 * ...
 * @author Alexander Christner
 */
class TitleScreen  extends FlxState
{
	var imagesPath:String = "assets/images/titlescreen.png";
	var imagesWidth:Int = 400;
	var imagesHeight:Int = 300;
	
	var cutsceneSprite:FlxSprite;
	
	private var _startButton:FlxButton;
    private var _titleMusic:FlxSound;

	override public function create():Void
	{
		super.create();

		FlxG.fullscreen = true;
		
		cutsceneSprite = new FlxSprite();
		cutsceneSprite.loadGraphic(imagesPath, true, imagesWidth, imagesHeight);
		cutsceneSprite.setGraphicSize(FlxG.width, FlxG.height);
		cutsceneSprite.animation.add("titleImage", [0], 1, true);
		cutsceneSprite.x = (FlxG.width-imagesWidth)/2;
		cutsceneSprite.y = (FlxG.height-imagesHeight)/2;
		add(cutsceneSprite);

		_startButton = new FlxButton(0, 0, "Start", clickPlay);
		_startButton.x = (FlxG.width / 2) - _startButton.width/2 ;
		_startButton.y = FlxG.height - _startButton.height - 20;
		add(_startButton);
        _titleMusic = FlxG.sound.load(AssetPaths.titleTheme__wav);
        _titleMusic.play();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
        if(FlxG.keys.justPressed.ESCAPE)
        {
            Lib.close();
        }
		
		cutsceneSprite.animation.play("titleImage");
	}

	function clickPlay():Void{
		FlxG.switchState(new OpeningSceneState());
	}
}
