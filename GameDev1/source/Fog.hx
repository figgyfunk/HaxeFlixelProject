package;


import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.math.FlxVector;
import flixel.tile.FlxTilemap;
import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.FlxState;

class Fog extends FlxSprite
{
    private var _player:FlxSprite;
    private var _walls:FlxTilemap;

    public function new(?X:Float=0, ?Y:Float=0, player:FlxSprite, walls:FlxTilemap)
    {
        super(X, Y);
        makeGraphic(64,64, FlxColor.RED);

        _player = player;
        _walls = walls;

    }

    override public function update(elapsed:Float):Void {

      super.update(elapsed);
  	}

    override public function kill():Void {
      super.kill();
  	}

    public function checkFog() : Bool {
        var blocked:Bool = _walls.ray(getMidpoint(), _player.getMidpoint());
        if(blocked){
          var distance =getMidpoint().distanceTo( _player.getMidpoint());
          if(distance < 100){
            return true;

          }
          return false;

        }
        return false;
    }
  }
