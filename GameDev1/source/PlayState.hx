package;

import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.tile.FlxTilemap;
import flixel.FlxObject;

class PlayState extends FlxState
{

	private var _map:FlxOgmoLoader;
	private var _mWalls:FlxTilemap;
	override public function create():Void
	{
		_map = new FlxOgmoLoader(AssetPaths.level1_tight__oel);
		_mWalls = _map.loadTilemap(AssetPaths.tiles__png, 16, 16, "wall");
		add(_mWalls);
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
