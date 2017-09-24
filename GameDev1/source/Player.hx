package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup;
import flixel.math.FlxAngle;
import flixel.tile.FlxTilemap;
import flixel.FlxState;
import flixel.text.FlxText;

class Player extends FlxSprite {
	var _walls:FlxTilemap;
	public var playermap:PlayerMap;
	
	public var _rot:Float = 0;
	var _up:Bool = false;
	var _down:Bool = true;
	var _left:Bool = false;
	var _right:Bool = false;
	
	var speed:Float = 200;
	var xspeed:Float = 0;
	var yspeed:Float = 0;
	var pathblocked:Bool = false;
	
	var spritewidth:Int = 50;
	var spriteheight:Int = 57;
	
	var visionradius:Int = 200;
	var tilesize:Int = 16;
	
	//cooldown in milliseconds
	var inviscooldown:Int = 6000;
	public var cooldown:Int = 0;
	var invisduration:Int = 3000;
	public var duration:Int = 0;
	var toggleinvis:Bool = false;
	public var invisible:Bool = false;
	var frozen:Bool = false;
	
	var rottext:FlxText;
	var invistext:FlxText;

	public function new(startX:Int, startY:Int, walls:FlxTilemap, state:FlxState) {
		super();
		
		_walls = walls;
		
		loadGraphic("assets/images/duck_small.png", true, spritewidth, spriteheight);
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		animation.add("walk", [0, 1, 0, 2], 10, true);
		animation.add("stand", [0], 2, true);
		
		setPosition(startX, startY);
		
		playermap = new PlayerMap(Std.int(1024 / tilesize), Std.int(768 / tilesize));
		
		rottext = new FlxText(10, 90, 300, "");
		state.add(rottext);
		invistext = new FlxText(10, 110, 300, "");
		state.add(invistext);
	}
	
	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		poll();
		movement();
		detect();
		invisibility(elapsed);
		
		rottext.text = "player rot: " + Std.string(_rot);
		invistext.text = "invis: " + Std.string(invisible) + " " + Std.string(duration) + " " + Std.string(cooldown);
	}
	
	function invisibility(elapsed:Float):Void {
		if (invisible) {
			//increment duration
			duration = duration + Std.int(elapsed * 1000);
		}
		else {
			//decrement cooldown
			cooldown = FlxMath.maxInt(0, Std.int(cooldown - (elapsed * 1000)));
		}
		
		//toggle invis if key is pressed of duration is passed
		if (toggleinvis || duration > invisduration) {
			toggleInvisible();
		}
	}
	
	function poll():Void {
		_up = FlxG.keys.anyPressed([UP, W]);
		_down = FlxG.keys.anyPressed([DOWN, S]);
		_left = FlxG.keys.anyPressed([LEFT, A]);
		_right = FlxG.keys.anyPressed([RIGHT, D]);
		
		toggleinvis = FlxG.keys.justPressed.SPACE;
	}
	
	function movement():Void {
		xspeed = 0;
		yspeed = 0;
		pathblocked = false;
		
		if ((_up || _down || _left || _right) && !frozen) {
			//combine speeds of input directions, also check if there is something blocking in the path
			if (_left) {
				xspeed -= speed;
			}
			if (_right) {
				xspeed += speed;
			}
			if (_up) {
				yspeed -= speed;
			}
			if (_down) {
				yspeed += speed;
			}
			
			//check if there is something ahead of direction
			//pathblocked = overlapsAt(x + (xspeed / 60), y + (yspeed / 60), _walls);
			
			//calculate rotation angle
			_rot = FlxAngle.angleBetweenPoint(this, new FlxPoint(x + xspeed + (spritewidth / 2), y + yspeed + (spriteheight / 2)), true);
			
			//flip sprite when moving left/right
			if (_rot < 90 && _rot > -90) {
				facing = FlxObject.RIGHT;
			}
			else if (_rot > 90 || _rot < -90) {
				facing = FlxObject.LEFT;
			}
			else if (_rot == -90) {
				facing = FlxObject.UP;
			}
			else if (_rot == 90) {
				facing = FlxObject.DOWN;
			}
			
			//move it!
			velocity.set(speed, 0);
			velocity.rotate(new FlxPoint(0, 0), _rot);
			FlxG.collide(this, _walls);
			animation.play("walk");
		}
		else {
			velocity.set(0, 0);
			animation.play("stand");
		}
	}
	
	//Checks for objects in the player's circle of view
	function detect():Void {
		for (i in Std.int((x - visionradius) / tilesize)...Std.int((x + visionradius) / tilesize)) {
			for (j in Std.int((y - visionradius) / tilesize)...Std.int((y + visionradius) / tilesize)) {
				var result:FlxPoint = null;
				if (_walls.ray(new FlxPoint(x, y), new FlxPoint(i, j), result) == false) {
					playermap.setpixel(Std.int(i), Std.int(j), 1);
				}
			}
		}
	}
	
	function toggleInvisible():Void {
		//If currently invisible, turn it off and set cooldown
		if (invisible) {
			invisible = false;
			cooldown = inviscooldown;
			duration = 0;
		}
		//If not currently invisible and cooldown is off, then turn it on
		if (!invisible && cooldown == 0) {
			invisible = true;
			duration = 0;
		}
	}
	
	public function isInvisible():Bool {
		return invisible;
	}
}