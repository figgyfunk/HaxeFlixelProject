package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.system.FlxSound;

class PlayState extends FlxState
{
    var _title:FlxSound;
    var _music:BackgroundMusic;
    var _state:Int = 0;
	override public function create():Void
	{
		super.create();
        _music = new BackgroundMusic(AssetPaths.walkTheme__wav, 5810, 34810);
        _title = FlxG.sound.load(AssetPaths.titleTheme__wav, 1, false);
        _title.play();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
        if(FlxG.keys.justReleased.SPACE)
        {
            if(_state == 0)
            {
                _title.stop();
                _music.play();
                _state = 1;
            }
            else if(_state == 1)
            {
                _music.pause();
                _state = 2;
            }
            else
            {
                _music.unpauseAndReset();
                _state = 1;
            }
        }
	}
}
