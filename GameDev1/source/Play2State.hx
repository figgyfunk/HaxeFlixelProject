package;

import flixel.FlxState;
import flixel.FlxObject;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.tile.FlxTilemap;
import flixel.group.FlxGroup;
import flixel.FlxG;


import flixel.math.FlxPoint;


class Play2State extends FlxState
{
	private var _map:FlxOgmoLoader;
	private var _mWalls:FlxTilemap;
	private var _fogGroup:FlxTypedGroup<Fog>;

	private var _proceed:Bool = false;


	private var _player:Player;
	private var _warpPad:WarpPad;
	private var _soldier01:EnemySoldier;

	override public function create():Void
	{
		//copy this with correct file names to load levels

		_map = new FlxOgmoLoader(AssetPaths.fog_big1__oel);
		_mWalls = _map.loadTilemap(AssetPaths.tiles__png, 16, 16, "walls");
		_mWalls.setTileProperties(2, FlxObject.ANY);
		//_wallGroup = new FlxTypedGroup<Wall>();
		//add(_wallGroup);
		//_map.loadEntities(placeEntities, "entities");
		add(_mWalls);
		_fogGroup = new FlxTypedGroup<Fog>();
		add(_fogGroup);

		_map.loadEntities(placeEntities, "fog");
		_map.loadEntities(placeEntities, "warpPad");
    add(_warpPad);

		_player = new Player(20, 20, _mWalls);
		add(_player);

		_soldier01 = new EnemySoldier(_player, _mWalls, createEnemyPath(), this);
		add(_soldier01);


		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		FlxG.overlap(_player, _fogGroup, playerTouchFog);
		FlxG.overlap(_player, _warpPad, changeStage);
		super.update(elapsed);

	}


	private function createEnemyPath():Array<FlxPoint>{

		var result:Array<FlxPoint> = new Array<FlxPoint>();
		result.push(new FlxPoint(300, 60));
		result.push(new FlxPoint(512, 200));
		result.push(new FlxPoint(300, 385));
		result.push(new FlxPoint(80, 200));
		return result;
	}

	private function placeEntities(entityName:String, entityData:Xml):Void
{
		var x:Int = Std.parseInt(entityData.get("x"));
		var y:Int = Std.parseInt(entityData.get("y"));
		if (entityName == "fog")
		{
				_fogGroup.add(new Fog(x+4, y+4));
		}
		if(entityName == "warpPad"){
			_warpPad = new WarpPad(x+4, y+4);
		}
}

private function playerTouchFog(P:Player, F:Fog):Void
{
    if (P.alive && P.exists && F.alive && F.exists)
    {
        F.kill();
				if( _fogGroup.countLiving() == 0 ) {
					_proceed = true;

				}

    }
}

private function changeStage(P:Player, W:WarpPad) : Void {
		if(_proceed){
			FlxG.switchState(new PlayState());
		}

}


}
