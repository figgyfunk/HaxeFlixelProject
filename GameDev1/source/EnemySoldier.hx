package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.math.FlxVector;
import flixel.tile.FlxTilemap;
import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.FlxState;
import flixel.math.FlxVelocity;
import flixel.math.FlxMath;

/**
 * ...
 * @author Alexander Christner
 */
class EnemySoldier extends FlxSprite
{
	var walkSpeed:Float = 150; //pixels per second
	var runSpeed:Float = 200; //pixels per second
	var FOV_Distance:Float = 10000; //max distance from soldier that it can se player
	var FOV_Angle:Float = 30; //max angle away from soldier's facing direction that it can see player IN DEGREES
	var _arriveTolerance:Float = 10; //max distance from a point a point that the soldier is considered arrived
									//too high causes clipping in position, too low causes overshooting

	var aimTime:Float = 2; //time it takes for the soldier to aim and shoot the player
	var patrolIdleTime:Float = 3; //time turing patrol that the soldier will stand sill before moving to next point
	var pursueIdleTime:Float = 5; //time that the soldier will stay at the player's last known location when pursuing
	var pursueTurnTime:Float = 1; //time between turns while the soldier is at last known player location when pursuing
	var backtrackAddTime:Float = .1; //time between adding points to the backtrack path while pursuing
									//making this smaller will improve backtracking but lower performance
	var aimCountdown:Float;
	var patrolIdleCountdown:Float;
	var pursueIdleCountdown:Float;
	var pursueTurnCountdown:Float; 
	var backtrackAddCountdown:Float;
	
	var _player:FlxSprite;
	var _tilemap:FlxTilemap;
	var _path:Array<FlxPoint>;
	var _moveTowardIndex:Int;
	
	var onAlert = false; //true if pursuing or aiming. False if patrolling or backtracking
	var _lastKnownPlayerPosition:FlxPoint;
	var _lastKnownPlayerDirection:FlxPoint;
	var _backtrackPath:Array<FlxPoint>;
	
	var _faceRot:Float = 0;
	var _velRot:Float = 0;
	
	var actionText:FlxText = new FlxText(10, 10, 300, "Debug Text");//debug
	var facingText:FlxText = new FlxText(10, 30, 300, "Facing Text");//debug
	var faceRotText:FlxText = new FlxText(10, 50, 300, "Facing Rotation Text");//debug
	var velRotText:FlxText = new FlxText(10, 70, 300, "Velocity Rotation Text");//debug
	var _state:FlxState;

	/*
	 * arguments:
	 * 		player - reference to the player
	 * 		map - reference to the timemap
	 * 		path - an array containing FlxPoints. The soldier will start on the first point when created.
	 * 				The soldier will travel from the first point to the second and so on. When it reaches the
	 * 				end of the array, it will travel back to the first point.
	 * */
	public function new(player:FlxSprite, map:FlxTilemap, path:Array<FlxPoint>, state:FlxState) 
	{
		super();
		_player = player;
		_tilemap = map;
		_path = path;
		
		_moveTowardIndex = 0;
		_backtrackPath = new Array<FlxPoint>();
		
		aimCountdown = aimTime;
		patrolIdleCountdown = 0;
		pursueIdleCountdown = pursueIdleTime;
		pursueTurnCountdown = pursueTurnTime; 
		backtrackAddCountdown = backtrackAddTime;
		
		loadGraphic("assets/images/duck_small.png", true, 50, 57);//temp animations
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		animation.add("walk", [0, 1, 0, 2], 10, true);
		animation.add("stand", [0], 2, true);
		
		setPosition(_path[0].x, _path[0].y);
		
		drag.x = drag.y = 2000;
		
		_state = state;//debug
		_state.add(actionText);//debug
		_state.add(facingText);//debug
		_state.add(faceRotText);//debug
		_state.add(velRotText);//debug
	}
	
	override public function update(elapsed:Float):Void{
		super.update(elapsed);
		movement();
	}
	
	function movement():Void{
		//on normal patrol
		if (!onAlert){
			
			//if the player is seen,
			//set this soldier's behavior to the chasing behavior
			if (canSeePlayerCone()){
				onAlert = true;
				_lastKnownPlayerPosition = _player.getPosition();
				_backtrackPath.push(getPosition());
			}
			//if the player needs to return to it's patrol bath,
			//follow the packtrack path
			else if (_backtrackPath.length > 0){
				actionText.text = "backtrack";//debug
				backtrack();
			}
			//if the player is not in sight
			//engage ordinary patrol navigation behavior
			else{
				actionText.text = "patrol";//debug
				patrol();
			}
		}
		//is chasing player
		else{
			
			//record soldier's location every 'backtrackAddTime' seconds
			backtrackAddCountdown -= FlxG.elapsed;
			if (backtrackAddCountdown <= 0){
				backtrackAddCountdown = backtrackAddTime;
				
				_backtrackPath.push(getPosition());
			}
			
			//if the player is in sight,
			//the soldier is stationary while counting down to shoot
			if (canSeePlayerCone()){
				actionText.text = "aiming";//debug
				_lastKnownPlayerPosition = _player.getPosition();
				_lastKnownPlayerDirection = FlxVelocity.velocityFromFacing(_player, FlxMath.MAX_VALUE_FLOAT);
				aim();
			}
			//if the player is out of sight
			//engage pursue behavior
			else{
				
				actionText.text = "pursue";//debug
				pursue();
			}
		}
		
		velRotText.text = Std.string(_velRot);//debug
		faceRotText.text = Std.string(_faceRot);//debug
	}
	
	//walk along the path given by the _path variable
	function patrol():Void{
		
		aimCountdown= aimTime;
		//patrolIdleCountdown = patrolIdleTime;
		pursueIdleCountdown = pursueIdleTime;
		pursueTurnCountdown = pursueTurnTime; 
		backtrackAddCountdown = backtrackAddTime;
		
		//if we are on a node specified by path..
		if ( arrivedAt( _path[_moveTowardIndex] ) ){
			
			//after idle for 'patrolIdleTime' seconds, turn toward the next point in the path and start moving toward it
			patrolIdleCountdown -= FlxG.elapsed;
			if (patrolIdleCountdown <= 0){
				patrolIdleCountdown = patrolIdleTime;
				
				_moveTowardIndex++;
				if (_moveTowardIndex >= _path.length){
					_moveTowardIndex = 0;
				}
			}
			
			animation.stop();
		}
		//not on a node specifed by path
		else{
			
			//turn toward that point and move toward it
			turnToward(_path[_moveTowardIndex]);
			velocity.set(walkSpeed);
			velocity.rotate(new FlxPoint(0, 0), _velRot);
			
			animation.play("walk");
		}
		
	}
	
	//walk along path stored in backtrack array
	function backtrack():Void{
		
		aimCountdown= aimTime;
		patrolIdleCountdown = patrolIdleTime;
		pursueIdleCountdown = pursueIdleTime;
		pursueTurnCountdown = pursueTurnTime; 
		backtrackAddCountdown = backtrackAddTime;
		
		var destination:FlxPoint = _backtrackPath[_backtrackPath.length-1];
		
		//if at the most recent backtrack location
		if ( arrivedAt(destination) ){
			_backtrackPath.pop();
		}
		else{
			
			turnToward(destination);
			velocity.set(walkSpeed);
			velocity.rotate(new FlxPoint(0, 0), _velRot);
		}
		
		animation.play("walk");
	}
	
	//stand still and aim at player to kill it
	function aim():Void{
		
		//aimCountdown= aimTime;
		patrolIdleCountdown = patrolIdleTime;
		pursueIdleCountdown = pursueIdleTime;
		pursueTurnCountdown = pursueTurnTime; 
		//backtrackAddCountdown = backtrackAddTime;
		
		turnToward(_player.getMidpoint());
		
		/*
		aimCountdown -= FlxG.elapsed;
		if (aimCountdown <= 0){
			aimCountdown = aimTime;
			//to add: kill player
		}
		*/
		
		animation.stop();
	}
	
	//run to location player was last seen at. If there, wait, then leave alert
	function pursue():Void{
		
		aimCountdown= aimTime;
		patrolIdleCountdown = patrolIdleTime;
		//pursueIdleCountdown = pursueIdleTime;
		//pursueTurnCountdown = pursueTurnTime; 
		//backtrackAddCountdown = backtrackAddTime;
		
		//if we are at the last know player location
		if ( arrivedAt(_lastKnownPlayerPosition) ){
			
			if (_lastKnownPlayerDirection != null){
				turnToward(_lastKnownPlayerDirection);
				_lastKnownPlayerDirection = null;
			}
			//look around every 'pursueTurnTime' seconds
			pursueTurnCountdown -= FlxG.elapsed;
			if (pursueTurnCountdown <= 0){
				pursueTurnCountdown = pursueTurnTime;
				
				randomDirection();
			}
			
			//after idle for 'pursueIdleCountdown' seconds, return to the patrol behavior
			pursueIdleCountdown -= FlxG.elapsed;
			if (pursueIdleCountdown <= 0){
				pursueIdleCountdown = pursueIdleTime;
				
				onAlert = false;
			}
			
			animation.stop();
		}
		//not at last known player location
		else{
			
			pursueIdleCountdown = pursueIdleTime;
			pursueTurnCountdown = pursueTurnTime;
			
			turnToward(_lastKnownPlayerPosition);
			velocity.set(runSpeed);
			velocity.rotate(new FlxPoint(0, 0), _velRot);
			
			animation.play("walk");
		}
	}
	
	//returns true if the soldier can see the player from any direction
	function canSeePlayer360():Bool{
		
		//to add: if the player is invisible. return false
		
		
		//if a ray cannot travel from soldier to player's midpoint without hitting anything,
		//return false
		if ( !_tilemap.ray(getMidpoint(), _player.getMidpoint()) ){
			return false;
		}
		
		//if the distance from the soldier to the player is greater than the viewDistance,
		//return false
		var distanceToPlayer:Float = _player.getMidpoint().distanceTo( getMidpoint() );
		if (distanceToPlayer > FOV_Distance){
			return false;
		}
		
		//if all conditions for player being unseen fail to be true,
		//return true
		return true;
	}
	
	//todo: find proper facing vectors and make sure angle measuring is correct
	//returns true if the soldier can see the player within its FOV angle
	function canSeePlayerCone():Bool{
		//if the player is outside the soldier's viewAngle pointing where the soldier is facing,
		//return false
		var directionVec:FlxVector = _player.getMidpoint().toVector().subtractNew( getMidpoint().toVector() );
		var facingVec = new FlxVector( Math.cos(_faceRot * Math.PI / 180), Math.sin(_faceRot* Math.PI / 180) );
		
		var angleBetween:Float = directionVec.degreesBetween(facingVec);
		if (angleBetween > FOV_Angle){
			return false;
		}
		
		return canSeePlayer360();
	}
	
	//if the player's position is within 'arriveTolerance' of 'point'
	//set it position to that point and return true
	//return false otherwise
	function arrivedAt(point:FlxPoint):Bool{
		if (getPosition().distanceTo(point) <= _arriveTolerance){
			setPosition(point.x, point.y);
			return true;
		}
		return false;
	}
	
	//get vector from soldier's position to dest
	function getVectorTo(dest:FlxPoint):FlxVector{
		return new FlxVector(dest.x - this.x, dest.y - this.y);
	}
	
	/*
	//get vector from soldier's position to dest
	function getVectorTo(dest:FlxVector):FlxVector{
		return dest.subtractNew(getPosition());
	}
	*/
	
	//face in the direction closest to the direction of dest
	//and set soldier's _rot toward dest
	function turnToward(dest:FlxPoint):Void{
		
		if (isUp(dest)){
			faceUp();
		}
		if (isDown(dest)){
			faceDown();
		}
		if (isLeft(dest)){
			faceLeft();
		}
		if (isRight(dest)){
			faceRight();
		}
		
		_velRot = getVectorTo(dest).degrees;
		while (_velRot > 360){
			_velRot -= 360;
		}
		while (_velRot < 0){
			_velRot += 360;
		}
	}
	
	//face and set _rot to up, down, left, or right randomly
	function randomDirection():Void{
		var rand:FlxRandom = new FlxRandom();
		var direction:Int = rand.int(0, 3);
		if (direction == 0){
			faceUp();
		}
		else if (direction == 1){
			faceDown();
		}
		else if (direction == 2){
			faceLeft();
		}
		else{//direction == 3
			faceRight();
		}
	}
	
	function faceUp():Void{
		facing = FlxObject.UP;
		_faceRot = 270;
		facingText.text = "Face Up";//debug
	}
	
	function faceDown():Void{
		facing = FlxObject.DOWN;
		_faceRot = 90;
		facingText.text = "Face Down";//debug
	}
	
	function faceLeft():Void{
		facing = FlxObject.LEFT;
		_faceRot = 180;
		facingText.text = "Face Left";//debug
	}
	
	function faceRight():Void{
		facing = FlxObject.RIGHT;
		_faceRot = 0;
		facingText.text = "Face Right";//debug
	}
	
	//true if point is above this object's location
	function isUp(point:FlxPoint):Bool{
		var xVariance:Float = Math.abs(point.x - this.x);
		var yVariance:Float = Math.abs(point.y - this.y);
		return (yVariance > xVariance) && (point.y < this.y);
	}
	
	//true if point is below this object's location
	function isDown(point:FlxPoint):Bool{
		var xVariance:Float = Math.abs(point.x - this.x);
		var yVariance:Float = Math.abs(point.y - this.y);
		return (yVariance > xVariance) && (point.y > this.y);
	}
	
	//true if point is to the left of this object's location
	function isLeft(point:FlxPoint):Bool{
		var xVariance:Float = Math.abs(point.x - this.x);
		var yVariance:Float = Math.abs(point.y - this.y);
		return (xVariance > yVariance) && (point.x < this.x);
	}
	
	//true if point is to the right of this object's location
	function isRight(point:FlxPoint):Bool{
		var xVariance:Float = Math.abs(point.x - this.x);
		var yVariance:Float = Math.abs(point.y - this.y);
		return (xVariance > yVariance) && (point.x > this.x);
	}
}