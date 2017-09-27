package;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.Math;
import flixel.math.FlxVector;
class Beam extends FlxSprite
{
    var _time:Float = 0.125;
    public function new(enemy:FlxPoint, player:FlxPoint){
        var between:FlxVector enemy.toVector().subtractNew(player.toVector());
        var len = between.length;
        var center:FlxVector = enemy.toVector().addNew(player.toVector()).scale(0.5);
        super(cener.length * center.dx, center.length * center.dy, AssetPaths.beam__png);
        setGraphicsScale(len, 50);
        centerOrigin();
        angle = between.degrees;
    }
    
    public function update(elapsed:Float):Void{
        _time = elapsed;
        if(_time <= 0){
            this.destroy();
        }
    }
}
