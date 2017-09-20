package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup;
import flixel.math.FlxAngle;
import flixel.tile.FlxTilemap;

class Player extends FlxSprite {
	var _walls:FlxTilemap;
	
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

	public function new(startX:Int, startY:Int, walls:FlxTilemap) {
		super();
		
		_walls = walls;
		
		loadGraphic("assets/images/duck.png", true, spritewidth, spriteheight);
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		animation.add("walk", [0, 1, 0, 2], 10, true);
		animation.add("stand", [0], 2, true);
		
		setPosition(startX, startY);
	}
	
	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		poll();
		movement();
	}
	
	function poll():Void {
		_up = FlxG.keys.anyPressed([UP, W]);
		_down = FlxG.keys.anyPressed([DOWN, S]);
		_left = FlxG.keys.anyPressed([LEFT, A]);
		_right = FlxG.keys.anyPressed([RIGHT, D]);
	}
	
	function movement():Void {
		xspeed = 0;
		yspeed = 0;
		pathblocked = false;
		
		if (_up || _down || _left || _right) {
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
			pathblocked = overlapsAt(x + (xspeed / 60), y + (yspeed / 60), _walls);
			
			//calculate rotation angle
			_rot = FlxAngle.angleBetweenPoint(this, new FlxPoint(x + xspeed + (spritewidth / 2), y + yspeed + (spriteheight / 2)), true);
			
			//flip sprite when moving left/right
			if (_rot < 90 && _rot > -90) {
				facing = FlxObject.RIGHT;
			}
			else if (_rot > 90 || _rot < -90) {
				facing = FlxObject.LEFT;
			}
			
			//move it!
			if (!pathblocked) {
				velocity.set(speed, 0);
			}
			velocity.rotate(new FlxPoint(0,0), _rot);
			animation.play("walk");
		}
		else {
			velocity.set(0, 0);
			animation.play("stand");
		}
	}
}