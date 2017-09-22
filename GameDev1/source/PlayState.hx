package;

import flixel.FlxState;
import flixel.FlxObject;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.tile.FlxTilemap;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;

class PlayState extends FlxState
{
	private var _map:FlxOgmoLoader;
	private var _mWalls:FlxTilemap;
	private var _wallGroup:FlxTypedGroup<Wall>;
	
	private var _player:Player;
	private var _soldier01:EnemySoldier;
	
	override public function create():Void
	{
		//copy this with correct file names to load levels

		_map = new FlxOgmoLoader(AssetPaths.RectangleHallway__oel);
		_mWalls = _map.loadTilemap(AssetPaths.tiles__png, 16, 16, "Walls");
		_mWalls.setTileProperties(2, FlxObject.ANY);
		//_wallGroup = new FlxTypedGroup<Wall>();
		//add(_wallGroup);
		//_map.loadEntities(placeEntities, "entities");
		add(_mWalls);
		
		_player = new Player(300, 385, _mWalls);
		add(_player);
		
		_soldier01 = new EnemySoldier(_player, _mWalls, createEnemyPathRectangle(), this);
		add(_soldier01);

		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}

	private function placeEntities(entityName:String, entityData:Xml):Void
	{
		var x:Int = Std.parseInt(entityData.get("x"));
		var y:Int = Std.parseInt(entityData.get("y"));
		if (entityName == "wallCol")
		{
			_wallGroup.add(new Wall(x+4, y+4));
		}
	}
	
	private function createEnemyPathDiamond():Array<FlxPoint>{
		
		var result:Array<FlxPoint> = new Array<FlxPoint>();
		result.push(new FlxPoint(300, 60));
		result.push(new FlxPoint(512, 200));
		result.push(new FlxPoint(300, 385));
		result.push(new FlxPoint(80, 200));
		return result;
	}
	
	private function createEnemyPathRectangle():Array<FlxPoint>{
		
		var result:Array<FlxPoint> = new Array<FlxPoint>();
		result.push(new FlxPoint(32, 32));
		result.push(new FlxPoint(512, 32));
		result.push(new FlxPoint(512, 385));
		result.push(new FlxPoint(32, 385));
		return result;
	}

}
