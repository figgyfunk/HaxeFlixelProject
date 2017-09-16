package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.system.FlxSound;

class PlayState extends FlxState
{
    var _music:FlxSound;
	override public function create():Void
	{
		super.create();
        _music = FlxG.sound.load(AssetPaths.titleTheme__wav, 1, false);
        _music.play();
        trace(_music.length);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
