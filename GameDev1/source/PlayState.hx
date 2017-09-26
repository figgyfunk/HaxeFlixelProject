package;

import flixel.FlxState;
import flixel.system.FlxSound;
import flixel.FlxObject;
import flixel.FlxG;
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
	private var _soldiers:Array<EnemySoldier>;

	private var _backMusic:BackgroundMusic;
	private var _alertMusic:BackgroundMusic;
	private var _lastFrameAlert:Bool = false;

	override public function create():Void
	{
		//FlxG.camera.setSize(1000,1000);
		FlxG.worldBounds.set(1000,1000);
		FlxG.camera.setScale(.9,.9);
		//copy this with correct file names to load levels

		_fog = new FlxTypedGroup<Fog>();
		_map = new FlxOgmoLoader(AssetPaths.bigger_fog__oel);
		_mWalls = _map.loadTilemap(AssetPaths.place_holder_test__png, 64, 64, "walls");
		_mWalls.setTileProperties(2, FlxObject.ANY);
		//_wallGroup = new FlxTypedGroup<Wall>();
		//add(_wallGroup);
		//_map.loadEntities(placeEntities, "entities");



		add(_mWalls);
		_decoration = _map.loadTilemap(AssetPaths.level_1_fixed__png, 3200, 3200, "notouch");
		add(_decoration);

		_map.loadEntities(placeEntities, "player");
		add(_player);
		FlxG.camera.follow(_player);

		_map.loadEntities(placeEntities, "warpPad");
		add(_warpPad);

		_map.loadEntities(placeEntities, "fog");
		add(_fog);


		_soldiers = new Array<EnemySoldier>();
		_soldier01 = new EnemySoldier(_player, _mWalls, createEnemyPathRectangle(), this, new ProximitySound(AssetPaths.Powerup21__wav, 0, 0, _player, 250, 0.5) );
		_soldiers.push(_soldier01);
		add(_soldier01);

		FlxG.camera.bgColor = 0xFF555555;

		_backMusic = new BackgroundMusic(AssetPaths.WalkTheme__wav, 5810, 34810);
		_alertMusic = new BackgroundMusic(AssetPaths.DetectTheme__wav, 90001);

		_backMusic.play();

		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		//manage detected music
		var oneAlerted:Bool = false;
		for(s in _soldiers){
			if (s.isOnAlert()){
				oneAlerted = true;
				break;
			}
		}
		if (oneAlerted && !_lastFrameAlert){
			_backMusic.pause();
			_alertMusic.play();
			_lastFrameAlert = true;
		}
		else if ( !oneAlerted && _lastFrameAlert ){
			_alertMusic.stop();
			_backMusic.unpauseAndReset();
			_lastFrameAlert = false;
		}

		//manage fog
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
			_warpPad = new WarpPad(x, y);
		}

		if(entityName == "player"){
			_player = new Player(x,y,_mWalls,this);
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
