package;

import flixel.FlxState;
import flixel.FlxObject;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.tile.FlxTilemap;

class PlayState extends FlxState
{
	private var _map:FlxOgmoLoader;
	private var _mWalls:FlxTilemap;
	private var _wallGroup:FlxTypedGroup<Wall>;
	override public function create():Void
	{
		//copy this with correct file names to load levels
		_map = new FlxOgmoLoader(AssetPaths.level1__oel);
		_mWalls = _map.loadTilemap(AssetPaths.place_holder__png, 16, 16, "wall");
		_mWalls.setTileProperties(2, FlxObject.ANY);
		add(_mWalls);
		add(_wallGroup);
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
				_wallGroup.add(new Wall(x+4, y+4))
		}
}

}
