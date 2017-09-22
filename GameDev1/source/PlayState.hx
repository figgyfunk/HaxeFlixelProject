package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.tile.FlxTilemap;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.FlxCamera;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class PlayState extends FlxState {
	var player:Player;
	var debugtext:FlxText;
	
	private var _level:FlxOgmoLoader;
	private var _tilemap:FlxTilemap;
	private var _wallGroup:FlxTypedGroup<Wall>;
	
	private var playercam:FlxCamera;
	
	var canvas:FlxSprite;
	
	override public function create():Void {
		super.create();
		
		FlxG.resizeWindow(1024, 768);
		
		//Main camera focuses on the player's map
		FlxG.camera.setSize(FlxG.width + 1000, FlxG.height + 1000);
		FlxG.camera.setPosition(-500, -500);
		FlxG.camera.bgColor = 0xFF555555;
		
		//copy this with correct file names to load levels
		_level = new FlxOgmoLoader(AssetPaths.level__oel);
		_tilemap = _level.loadTilemap(AssetPaths.place_holder__png, 16, 16, "wall");
		_tilemap.setTileProperties(2, FlxObject.ANY);
		_wallGroup = new FlxTypedGroup<Wall>();
		add(_wallGroup);
		_level.loadEntities(placeEntities, "entities");
		add(_tilemap);
		
		player = new Player(50, 50, _tilemap);
		add(player);
		
		debugtext = new FlxText(10, 10, 300, "");
		add(debugtext);
		
		//Player camera centers on the player
		playercam = new FlxCamera(Std.int(FlxG.width/2) - 100, Std.int(FlxG.height/2) - 100, 200, 200);
		playercam.bgColor = 0xFFAAAAAA;
		playercam.follow(player, FlxCameraFollowStyle.TOPDOWN);
		FlxG.cameras.add(playercam);
		
		/*
		canvas = new FlxSprite();
		canvas.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
		add(canvas);
		*/
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		//debugtext.text = Std.string(player._rot);
		//debugtext.text = Std.string(player.playermap.map);
		debugtext.text = Std.string(player.invisible) + " " + Std.string(player.duration) + " " + Std.string(player.cooldown);
		
		var lineStyle:LineStyle = {color: FlxColor.RED, thickness: 1};
		var drawStyle:DrawStyle = {smoothing: true};
		//canvas.drawCircle(0, 0, 10, FlxColor.GREEN, lineStyle, drawStyle);
	}
	
	private function placeEntities(entityName:String, entityData:Xml):Void {
		var x:Int = Std.parseInt(entityData.get("x"));
		var y:Int = Std.parseInt(entityData.get("y"));
		if (entityName == "wallCol") {
				_wallGroup.add(new Wall(x+4, y+4));
		}
	}
}
