package;

import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.system.FlxSound;

/**
 * ...
 * @author Alexander Christner
 */
class TitleScreen  extends FlxState
{
	private var _titleText:FlxText;
	private var _startButton:FlxButton;
    private var _titleMusic:FlxSound;
    
	override public function create():Void
	{
		super.create();
		
		_titleText = new FlxText(20, 0, 0, "Game Title", 35);
		_titleText.alignment = CENTER;
		_titleText.screenCenter(X);
		_titleText.y = _titleText.y + 20;
		add(_titleText);
		
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
	}
	
	function clickPlay():Void{
		FlxG.switchState(new PlayState());
	}
}
