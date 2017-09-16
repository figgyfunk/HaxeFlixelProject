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
        FlxG.sound.playMusic(AssetPaths.titleTheme__ogg, 1, false);
        _music = FlxG.sound.music;
        trace(_music.length);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
