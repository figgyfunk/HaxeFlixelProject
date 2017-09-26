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
    private var _wallFog:Bool;

    public function new(?X:Float=0, ?Y:Float=0, player:FlxSprite, walls:FlxTilemap)
    {
        super(X, Y);
        makeGraphic(64,64, FlxColor.GRAY);
        updateHitbox();
        _player = player;
        _walls = walls;
        _wallFog = false;
        var tiles:Array<FlxPoint> = _walls.getTileCoords(2);
        for( tile in tiles ) {
          if( getMidpoint().x+2 >=  tile.x && getMidpoint().x-2 <= tile.x) {
              if( getMidpoint().y+2 >= tile.y && getMidpoint().y -2 <=tile.y ) {
                _wallFog = true;
              }
          }
        }


    }

    override public function update(elapsed:Float):Void {

      super.update(elapsed);
  	}




    public function checkFog() : Bool {
        var blocked:Bool = _walls.ray(getMidpoint(), _player.getMidpoint());
        if(blocked){
          var distance = getMidpoint().distanceTo( _player.getMidpoint());
          if(distance < 250){
            return true;
          }
        }

        if( _wallFog) {
          var distance = getMidpoint().distanceTo( _player.getMidpoint());
          if(distance < 250){
            return true;

          }
        }


        return false;
    }
  }
