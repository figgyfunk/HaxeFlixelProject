package;

import flixel.FlxState;
import flixel.FlxObject;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.tile.FlxTilemap;
import flixel.group.FlxGroup;
import flixel.text.FlxText;

class PlayState extends FlxState {
	var _player:Player;
	var debugtext:FlxText;
	
	private var _level:FlxOgmoLoader;
	private var _tilemap:FlxTilemap;
	private var _wallGroup:FlxTypedGroup<Wall>;
	
	override public function create():Void {
		super.create();
		
		//copy this with correct file names to load levels
		_level = new FlxOgmoLoader(AssetPaths.level__oel);
		_tilemap = _level.loadTilemap(AssetPaths.place_holder__png, 16, 16, "wall");
		_tilemap.setTileProperties(2, FlxObject.ANY);
		_wallGroup = new FlxTypedGroup<Wall>();
		add(_wallGroup);
		_level.loadEntities(placeEntities, "entities");
		add(_tilemap);
		
		_player = new Player(50, 50, _tilemap);
		add(_player);
		
		debugtext = new FlxText(10, 10, 300, "");
		add(debugtext);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		debugtext.text = Std.string(_player._rot);
	}
	
	private function placeEntities(entityName:String, entityData:Xml):Void {
		var x:Int = Std.parseInt(entityData.get("x"));
		var y:Int = Std.parseInt(entityData.get("y"));
		if (entityName == "wallCol") {
				_wallGroup.add(new Wall(x+4, y+4));
		}
	}
}
