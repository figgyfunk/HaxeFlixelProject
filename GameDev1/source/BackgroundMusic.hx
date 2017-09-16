package;

import flixel.FlxG;
import flixel.system.FlxSound;

class BackgroundMusic
{
    var _music:FlxSound;
    var _frameTime:Float;
    
    public function new(path:String, frameTime:Float, loopTime:Float = 0,volume:Float = 1, loop:Bool = true)
    {
        _music = FlxG.sound.load(path, volume, loop);
        _music.loopTime = loopTime;
        _frameTime = frameTime;
    }
    
    public function play()
    {
        _music.play(true, 0);
    }
    
    public function pause()
    {
        _music.pause();
    }
    
    public function unpause(fadeIn:Float = 0)
    {
        _music.fadeIn(fadeIn, 0, _music.volume);
        _music.resume();
    }
    
    public function unpauseAndReset(fadeIn:Float = 0)
    {
        var current:Float = _music.time;
        _music.time -= _music.time % _frameTime;
        _music.fadeIn(fadeIn, 0, _music.volume);
        _music.resume();
    }
    
    public function stop()
    {
        _music.stop();
    }
}
