package;

import flixel.FlxState;
import flixel.FlxObject;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.tile.FlxTilemap;
import flixel.group.FlxGroup;
import flixel.FlxG;


import flixel.math.FlxPoint;


class PlayState extends FlxState
{
	private var _map:FlxOgmoLoader;
	private var _mWalls:FlxTilemap;
	private var _decoration:FlxTilemap;
	private var _fog:FlxTypedGroup<Fog>;


	private var _proceed:Bool = false;


	private var _player:Player;
	private var _warpPad:WarpPad;
	private var _soldier01:EnemySoldier;

	override public function create():Void
	{
		//copy this with correct file names to load levels
		_fog = new FlxTypedGroup<Fog>();
		_map = new FlxOgmoLoader(AssetPaths.blocked__oel);
		_mWalls = _map.loadTilemap(AssetPaths.place_holder_test_alpha__png, 16, 16, "walls");
		_mWalls.setTileProperties(1, FlxObject.ANY);
		//_wallGroup = new FlxTypedGroup<Wall>();
		//add(_wallGroup);
		//_map.loadEntities(placeEntities, "entities");
		add(_mWalls);
		_decoration = _map.loadTilemap(AssetPaths.place_holder__png, 16, 16, "notouch");
		add(_decoration);

		_map.loadEntities(placeEntities, "warpPad");
		add(_warpPad);



		_player = new Player(20, 20, _mWalls);
		add(_player);



		_soldier01 = new EnemySoldier(_player, _mWalls, createEnemyPath(), this);
		add(_soldier01);
		_map.loadEntities(placeEntities, "fog");
		add(_fog);

		super.create();
	}

	override public function update(elapsed:Float):Void
	{

		for( fog in _fog.members ) {
				if(fog.checkFog()){
					//_fog.remove(fog);
					if(fog.exists){

						fog.kill();

					}
				}
		}

		if( _fog.countLiving() == 0 ) {

				_proceed = true;
		}

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
				var fog:Fog = new Fog(x, y,_player,_mWalls);
				_fog.add(fog);


		}
		if(entityName == "warpPad"){
			_warpPad = new WarpPad(x+4, y+4);
		}
}




private function changeStage(P:Player, W:WarpPad) : Void {
		if(_proceed){
			//FlxG.switchState(new Play2State());
			var text = new flixel.text.FlxText(0, 0, 0, "yay", 64);
			text.screenCenter();
			add(text);
		}

}


}
