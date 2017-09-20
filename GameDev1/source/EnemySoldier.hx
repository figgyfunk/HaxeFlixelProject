package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.math.FlxVector;
import flixel.tile.FlxTilemap;
import flixel.FlxObject;

/**
 * ...
 * @author Alexander Christner
 */
class EnemySoldier extends FlxSprite
{
	var walkSpeed:Float = 10; //pixels per second
	var runSpeed:Float = 20; //pixels per second
	var FOV_Distance:Float = 10; //coordinate distance
	var FOV_Angle:Float = 45; //degrees
	var _arriveTolerance:Float = 50;

	var aimTime:Float = 2; //time it takes for the soldier to aim and shoot the player
	var patrolIdleTime:Float = 3; //time turing patrol that the soldier will stand sill before changing direction
	var patrolTurnTime:Float = 1; //time between turns during  patrol that the soldier will turn
	var pursueIdleTime:Float = 3; //time that the soldier will stay at the player's last known location
	var pursueTurnTime:Float = 1; //time between turns while the soldier is at last known player location
	var backtrackAddTime:Float = 3;//time between adding points to the backtrack path
	var aimCountdown:Float;
	var patrolIdleCountdown:Float;
	var patrolTurnCountdown:Float; 
	var pursueIdleCountdown:Float;
	var pursueTurnCountdown:Float; 
	var backtrackAddCountdown:Float;
	
	var _player:FlxSprite;//reference to player
	var _tilemap:FlxTilemap;//reference to tilemap
	var _path:Array<FlxPoint>;//reference to points
	var _moveTowardIndex:Int;
	
	var onAlert = false;
	var _lastKnownPlayerPosition:FlxPoint;
	var _backtrackPath:Array<FlxPoint>;
	
	var _up:Bool = false;
	var _down:Bool = false;
	var _left:Bool = false;
	var _right:Bool = false;
	var _rot:Float = 0;

	/*
	 * arguments:
	 * 		player - reference to the player
	 * 		map - reference to the timemap
	 * 		path - an array containing FlxPoints. The soldier will start on the first point when created.
	 * 				The soldier will travel from the first point to the second and so on. When it reaches the
	 * 				end of the array, it will travel back to the first point.
	 * 				IMPORTANT: In order to work properly, each point must be stictly above, below, left, or right
	 * 						from the previous one. i.e path[i].x == path[i+1].x OR path[i].y == path[i+1].y
	 * 						This must also be true for the last and first points in the array.
	 * */
	public function new(player:FlxSprite, map:FlxTilemap, path:Array<FlxPoint>) 
	{
		super();
		_player = player;
		_tilemap = map;
		_path = path;
		
		_moveTowardIndex = 0;
		_backtrackPath = new Array<FlxPoint>();
		
		aimCountdown = aimTime;
		patrolIdleCountdown = patrolIdleTime;
		patrolTurnCountdown = patrolTurnTime; 
		pursueIdleCountdown = pursueIdleTime;
		pursueTurnCountdown = pursueTurnTime; 
		backtrackAddCountdown = backtrackAddTime;
		
		//too add: image & animation adding
		//setFacingFlip
		
		setPosition(_path[0].x, _path[0].y);
		
		drag.x = drag.y = 2000;
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
				backtrack();
			}
			//if the player is not in sight
			//engage ordinary patrol navigation behavior
			else{
				patrol();
			}
		}
		//is chasing player
		else{
			
			//record soldier's location every 'backtrackAddTime' seconds
			backtrackAddCountdown -= FlxG.timeScale;
			if (backtrackAddCountdown <= 0){
				backtrackAddCountdown = backtrackAddTime;
				
				_backtrackPath.push(getPosition());
			}
			
			//if the player is in sight,
			//the soldier is stationary while counting down to shoot
			if (canSeePlayer360()){
				_lastKnownPlayerPosition = _player.getPosition();
				aim();
			}
			//if the player is out of sight
			//engage pursue behavior
			else{
				pursue();
			}
		}
	}
	
	//walk along the path given by the _path variable
	function patrol():Void{
		
		aimCountdown= aimTime;
		//patrolIdleCountdown = patrolIdleTime;
		//patrolTurnCountdown = patrolTurnTime; 
		pursueIdleCountdown = pursueIdleTime;
		pursueTurnCountdown = pursueTurnTime; 
		backtrackAddCountdown = backtrackAddTime;
		
		//if we are on a node specified by path..
		if ( withinTolerance( _path[_moveTowardIndex] ) ){
			
			//while idle, the soldier turns in a random direction every 'patrolTurnTime' seconds
			patrolTurnCountdown -= FlxG.timeScale;
			if (patrolTurnCountdown <= 0){
				patrolTurnCountdown = patrolTurnTime;
				
				randomDirection();
			}
			
			//after idle for 'patrolIdleTime' seconds, turn toward the next point in the path and start moving toward it
			patrolIdleCountdown -= FlxG.timeScale;
			if (patrolIdleCountdown <= 0){
				patrolIdleCountdown = patrolIdleTime;
				
				_moveTowardIndex++;
				if (_moveTowardIndex >= _path.length){
					_moveTowardIndex = 0;
				}
			}
		}
		//not on a node specifed by path
		else{
			
			//turn toward that point and move toward it
			turnToward(_path[_moveTowardIndex]);
			
			velocity.set(walkSpeed);
			velocity.rotate(new FlxPoint(0,0), _rot);
		}
		
	}
	
	function backtrack():Void{
		
		aimCountdown= aimTime;
		patrolIdleCountdown = patrolIdleTime;
		patrolTurnCountdown = patrolTurnTime; 
		pursueIdleCountdown = pursueIdleTime;
		pursueTurnCountdown = pursueTurnTime; 
		backtrackAddCountdown = backtrackAddTime;
		
		var destination:FlxPoint = _backtrackPath[_backtrackPath.length-1];
		
		//if at the most recent backtrack location
		if ( withinTolerance(destination) ){
			_backtrackPath.pop();
		}
		else{
			
			turnToward(destination);
			
			//to check: degrees gets proper angle measurment
			var travelVector:FlxVector = destination.toVector().subtractNew( getPosition().toVector() );
			var moveAngle:Float = travelVector.degrees;
			velocity.set(walkSpeed);
			velocity.rotate(new FlxPoint(0, 0), moveAngle);
		}
	}
	
	function aim():Void{
		
		//aimCountdown= aimTime;
		patrolIdleCountdown = patrolIdleTime;
		patrolTurnCountdown = patrolTurnTime; 
		pursueIdleCountdown = pursueIdleTime;
		pursueTurnCountdown = pursueTurnTime; 
		//backtrackAddCountdown = backtrackAddTime;
		
		aimCountdown -= FlxG.timeScale;
		if (aimCountdown <= 0){
			aimCountdown = aimTime;
			//to add: kill player
		}
	}
	
	//place the last known player midpoint so that it is in line vertically or horizontally with soldier
	//then, move the soldier toward that point
	function pursue():Void{
		
		aimCountdown= aimTime;
		patrolIdleCountdown = patrolIdleTime;
		patrolTurnCountdown = patrolTurnTime; 
		//pursueIdleCountdown = pursueIdleTime;
		//pursueTurnCountdown = pursueTurnTime; 
		//backtrackAddCountdown = backtrackAddTime;
		
		//if we are at the last know player midpoint
		if ( withinTolerance(_lastKnownPlayerPosition) ){
			
			//look around every 'pursueTurnTime' seconds
			pursueTurnCountdown -= FlxG.timeScale;
			if (pursueTurnCountdown <= 0){
				pursueTurnCountdown = pursueTurnTime;
				
				randomDirection();
			}
			
			//after idle for 'pursueIdleCountdown' seconds, return to the patrol behavior
			pursueIdleCountdown -= FlxG.timeScale;
			if (pursueIdleCountdown <= 0){
				pursueIdleCountdown = pursueIdleTime;
				
				onAlert = false;
			}
		}
		//not at last known player midpoint
		else{
			
			pursueIdleCountdown = pursueIdleTime;
			pursueTurnCountdown = pursueTurnTime;
			
			turnToward(_lastKnownPlayerPosition);
			
			//to check: degrees gets proper angle measurment
			var travelVector:FlxVector = _lastKnownPlayerPosition.toVector().subtractNew( getPosition().toVector() );
			var moveAngle:Float = travelVector.degrees;
			velocity.set(runSpeed);
			velocity.rotate(new FlxPoint(0,0), moveAngle);
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
		var distanceToPlayer:Float = _player.getMidpoint().distanceTo(getMidpoint());
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
		var facingVec;
		if (this.facing == FlxObject.UP){
			facingVec = new FlxVector(0, -1);
		}
		if (this.facing == FlxObject.DOWN){
			facingVec = new FlxVector(0, 1);
		}
		if (this.facing == FlxObject.LEFT){
			facingVec = new FlxVector(-1, 0);
		}
		else{//facing right
			facingVec = new FlxVector(1, 0);
		}
		
		var angle:Float = directionVec.degreesBetween(facingVec);
		if (angle > FOV_Angle){
			return false;
		}
		
		return canSeePlayer360();
	}
	
	//if the player's position is within 'arriveTolerance' of 'point'
	//set it position to that point and return true
	//return false otherwise
	function withinTolerance(point:FlxPoint):Bool{
		if (getPosition().distanceTo(point) <= _arriveTolerance){
			setPosition(point.x, point.y);
			return true;
		}
		return false;
	}
	
	function turnToward(dest:FlxPoint):Void{
		
		if (isUp(dest)){
			turnUp();
		}
		if (isDown(dest)){
			turnDown();
		}
		if (isLeft(dest)){
			turnLeft();
		}
		if (isRight(dest)){
			turnRight();
		}
	}
	
	function randomDirection():Void{
		var rand:FlxRandom = new FlxRandom();
		var direction:Int = rand.int(0, 3);
		if (direction == 0){
			turnUp();
		}
		else if (direction == 1){
			turnDown();
		}
		else if (direction == 2){
			turnLeft();
		}
		else{//direction == 3
			turnRight();
		}
	}
	
	function turnUp():Void{
		_up = true;
		_down = false;
		_left = false;
		_right = false;
		facing = FlxObject.UP;
		_rot = 270;
	}
	
	function turnDown():Void{
		_up = false;
		_down = true;
		_left = false;
		_right = false;
		facing = FlxObject.DOWN;
		_rot = 90;
	}
	
	function turnLeft():Void{
		_up = false;
		_down = false;
		_left = true;
		_right = false;
		facing = FlxObject.LEFT;
		_rot = 180;
	}
	
	function turnRight():Void{
		_up = false;
		_down = false;
		_left = false;
		_right = true;
		facing = FlxObject.RIGHT;
		_rot = 0;
	}
	
	//todo: check coordinate system
	//true if point is above this object's location
	function isUp(point:FlxPoint):Bool{
		var xVariance:Float = Math.abs(point.x - this.x);
		var yVariance:Float = Math.abs(point.y - this.y);
		return (yVariance > xVariance) && (this.y > point.y);
	}
	
	//true if point is below this object's location
	function isDown(point:FlxPoint):Bool{
		var xVariance:Float = Math.abs(point.x - this.x);
		var yVariance:Float = Math.abs(point.y - this.y);
		return (yVariance > xVariance) && (this.y < point.y);
	}
	
	//true if point is to the left of this object's location
	function isLeft(point:FlxPoint):Bool{
		var xVariance:Float = Math.abs(point.x - this.x);
		var yVariance:Float = Math.abs(point.y - this.y);
		return (xVariance > yVariance) && (this.x < point.x);
	}
	
	//true if point is to the right of this object's location
	function isRight(point:FlxPoint):Bool{
		var xVariance:Float = Math.abs(point.x - this.x);
		var yVariance:Float = Math.abs(point.y - this.y);
		return (xVariance > yVariance) && (this.x > point.x);
	}
}