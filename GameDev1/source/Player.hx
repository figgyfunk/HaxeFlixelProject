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
import flixel.system.FlxSound;

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

	var spritewidth:Int = 100;
	var spriteheight:Int = 100;
	var graphicHeight:Int = 50;
	var graphicWidth:Int = 50;

	var visionradius:Int = 200;
	var tilesize:Int = 16;
    
    var _cloakSound:FlxSound;
	var _uncloakSound:FlxSound;
    var _hurtSound:FlxSound;
	
	//cooldown in milliseconds
	var inviscooldown:Int = 6000;
	public var cooldown:Int = 0;
	var invisduration:Int = 3000;
	public var duration:Int = 0;
	var toggleinvis:Bool = false;
	public var invisible:Bool = false;
	var frozen:Bool = false;
	var frozenduration:Int = 3000;
	var frozenelapsed:Int = 0;
	
	var rottext:FlxText;
	var invistext:FlxText;
	
	var State:FlxState;

	public function new(startX:Int, startY:Int, walls:FlxTilemap, state:FlxState) {
		super();
		
		State = state;
		_walls = walls;
		setPosition(startX, startY);
		
		//animations
		loadGraphic("assets/images/delta.png", true, spritewidth, spriteheight);
		setGraphicSize(graphicWidth, graphicHeight);
		updateHitbox();
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);
		animation.add("die", [0, 1, 2, 3, 4, 5, 6, 7], 8, false);
		animation.add("idle", [8, 9, 10, 11, 12, 13], 10, true);
		animation.add("reappear", [14, 15, 16, 17, 18], 8, false);
		animation.add("run", [19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33], 20, true);
		animation.add("vanish", [34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44], 10, false);
		
		playermap = new PlayerMap(Std.int(1024 / tilesize), Std.int(768 / tilesize));
		
		//debugging text
		rottext = new FlxText(10, 90, 300, "");
		state.add(rottext);
		invistext = new FlxText(10, 110, 300, "");
		state.add(invistext);
        
        //Sounds
        _cloakSound = FlxG.sound.load(AssetPaths.cloak__wav);
        _uncloakSound = FlxG.sound.load(AssetPaths.uncloak__wav);
        _hurtSound = FlxG.sound.load(AssetPaths.hurt__wav, 0.75);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		poll();
		invisibility(elapsed);
		movement();
			
		//If killed, reset level after a set duration
		if (frozen) {
			frozenelapsed = frozenelapsed + Std.int(elapsed * 1000);
			if (frozenelapsed >= frozenduration) {
				FlxG.resetState();
			}
			rottext.text = "DEAD";//debug
			invistext.text = "DEAD";//debug
		}
		else {
			rottext.text = "player rot: " + Std.string(_rot);//debug
			invistext.text = "invis: " + Std.string(invisible) + " " + Std.string(duration) + " " + Std.string(cooldown);//debug
		}
		
		if (FlxG.keys.justPressed.T) {
			var sb:SpeechBubble = new SpeechBubble(this, 0, -20, 3000, "Hello World!");
			State.add(sb);
		}
	}
	
	public function die():Void {
		frozen = true;
		//play dying animation
		animation.play("die");
        _hurtSound.play();
	}
	
	function invisibility(elapsed:Float):Void {
		//can't do anything when frozen!
		if (frozen) {
			return;
		}
		
		//if invisible
		if (invisible) {
			//increment duration
			duration = duration + Std.int(elapsed * 1000);
		}
		//if visible
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
		
		if (FlxG.keys.justPressed.D) {
			die();
		}
	}

	function movement():Void {
		xspeed = 0;
		yspeed = 0;
		pathblocked = false;
		
		if ((_up || _down || _left || _right) && !frozen) {
			//combine speeds of input directions
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
			
			var destpoint = new FlxPoint(x + xspeed + (spritewidth / 2), y + yspeed + (spriteheight / 2));
			
			//calculate rotation angle
			_rot = FlxAngle.angleBetweenPoint(this, destpoint, true);
			
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
			velocity.set(FlxMath.distanceToPoint(this, destpoint), 0);
			velocity.rotate(new FlxPoint(0, 0), _rot);
			FlxG.collide(this, _walls);
			
			if (!highPriorityAnimation()){
				animation.play("run");
			}
		}
		else {
			velocity.set(0, 0);
			
			if(!highPriorityAnimation()){
				animation.play("idle");
			}
		}
	}
	
	function toggleInvisible():Void {
		//If currently invisible, turn it off and set cooldown
		if (invisible) {
			invisible = false;
			cooldown = inviscooldown;
			duration = 0;
			this.alpha = 1;
			
			animation.play("reappear");
            _uncloakSound.play();
		}
		//If not currently invisible and cooldown is off, then turn it on
		if (!invisible && cooldown == 0) {
			invisible = true;
			duration = 0;
			this.alpha = 0.5;
			
			animation.play("vanish");
            _cloakSound.play();
		}
	}
	
	public function isInvisible():Bool {
		return invisible;
	}
	
	public function isFrozen():Bool{
		return frozen;
	}
	
	function highPriorityAnimation():Bool {
		return ((animation.name == "vanish" || 
				animation.name == "reappear" || 
				animation.name == "die") 
				&& !animation.finished) || frozen;
	}
}
