package;

import flixel.FlxObject;
import flixel.FlxG;
import flixel.system.FlxSound;

class ProximitySound
{
    var _sound:FlxSound;
    
    public function new (soundPath:String, x:Float, y:Float, target:FlxObject, radius:Float, volume:Float = 1)
    {
        _sound = FlxG.sound.load(soundPath, volume, true);
        _sound.proximity(x, y, target, radius, false);
    }
    
    public function update (x:Float, y:Float)
    {
        _sound.setPosition(x, y);
    }
    
    public function play()
    {
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
