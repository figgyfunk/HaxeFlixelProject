package;

import flixel.FlxObject;
import flixel.FlxG;
import flixel.system.FlxSound;

class ProximitySound
{
    var _sound:FlxSound;
	var _x:Float;
	var _y:Float;
	var _target:FlxObject;
	var _radius:Float;
    
    public function new (soundPath:String, x:Float, y:Float, target:FlxObject, radius:Float, volume:Float = 1)
    {
        _sound = FlxG.sound.load(soundPath, volume, true);
        _x = x;
		_y = y;
		_target = target;
		_radius = radius;
    }
    
    public function update (x:Float, y:Float)
    {
        _sound.setPosition(x, y);
		_x = x;
		_y = y;
    }
    
    public function play()
    {
		_sound.proximity(_x, _y, _target, _radius, false);
        _sound.play(true, 0);
    }
    
    public function pause()
    {
        _sound.pause();
    }
    
    public function resume()
    {
        _sound.resume();
    }
    
    public function stop()
    {
        _sound.stop();
    }
}
