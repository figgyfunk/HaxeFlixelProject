package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.ui.FlxButton;
import flixel.addons.display.FlxBackdrop;
/**
 * ...
 * @author Alexander Christner & Brandon Ip
 */
class Cutscene02State extends FlxState
{
	var imagesPath:String = "assets/images/cutscenes/2/2.png";
	var imagesWidth:Int = 400;
	var imagesHeight:Int = 300;

	var cutsceneSprite:FlxSprite;
	var sceneNames:Array<String>;
	var imageStartTimes:Array<Float>;

	var counter:Float = 0;
	var itr:Int = 0;
	var _fadeLength:Float = 0.25;

	var _music:BackgroundMusic;

	private var _skipButton:FlxButton;

	var bg:FlxBackdrop;

	override public function create():Void
	{
		super.create();

		FlxG.fullscreen = true;

		sceneNames = new Array<String>();
		imageStartTimes = new Array<Float>();

		cutsceneSprite = new FlxSprite();
		cutsceneSprite.loadGraphic(imagesPath, true, imagesWidth, imagesHeight);
		cutsceneSprite.setGraphicSize(FlxG.width, FlxG.height);
		imageStartTimes.push(0);
		// (name, frame of spritesheet, duration, must be in order)
		addScene("1", 0, 2);
		addScene("2", 1, 2);
		addScene("3", 2, 2);
		addScene("4", 3, 2);
		cutsceneSprite.x = (FlxG.width-imagesWidth)/2;
		cutsceneSprite.y = (FlxG.height-imagesHeight)/2;
		//FlxG.camera.follow(cutsceneSprite);
		add(cutsceneSprite);

		_skipButton = new FlxButton(0, 0, "Skip", clickSkip);
		_skipButton.y = FlxG.height - _skipButton.height;
		add(_skipButton);
		_music = new BackgroundMusic(AssetPaths.slideBackground__wav, 90001);
		_music.play();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		counter += elapsed;

		if (counter >= imageStartTimes[itr]){
			cutsceneSprite.animation.play(sceneNames[itr]);
			FlxG.camera.fade(0x000000, _fadeLength, true);
			itr++;
		}
		else if (counter >= imageStartTimes[itr] - _fadeLength)
		{
			FlxG.camera.fade(0x000000, _fadeLength, false);
		}

		if (itr > sceneNames.length){
			nextScene();
		}
	}

	//add scenes in the order they appear
	function addScene(name:String, frame:Int, time:Float):Void{
		cutsceneSprite.animation.add(name, [frame], 1, true);
		sceneNames.push(name);
		imageStartTimes.push(imageStartTimes[imageStartTimes.length - 1] + time);
	}

	function clickSkip():Void{
		nextScene();
	}

	function nextScene():Void{
		FlxG.switchState(new LevelOneState());
	}
}
