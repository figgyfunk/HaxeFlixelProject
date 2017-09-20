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

	var aimTime:Float = 2; //time it takes for the soldier to aim and shoot the player
	var patrolIdleTime:Float = 3; //time turing patrol that the soldier will stand sill before changing direction
	var patrolTurnTime:Float = 1; //time between turns during  patrol that the soldier will turn
	var pursueIdleTime:Float = 3; //time that the soldier will stay at the player's last known location
	var pursueTurnTime:Float = 1; //time between turns while the soldier is at last known player location
	var backtrackAddTime:Float = 3;//time between adding points to the backtrack path
	var aimCountdown:Float = aimTime;
	var patrolIdleCountdown:Float = patrolIdleTime;
	var patrolTurnCountdown:Float = patrolTurnTime; 
	var pursueIdleCountdown:Float = pursueIdleTime;
	var pursueTurnCountdown:Float = pursueTurnTime; 
	var backtrackAddCountdown:Float = backtrackAddTime;
	
	var _player:FlxSprite;//reference to player
	var _tilemap:FlxTilemap;//reference to tilemap
	var _path:Array;//reference to points
	var _moveTowardIndex:Int;
	
	var onAlert = false;
	var _lastKnownPlayerPosition:FlxPoint;
	var _backtrackPath:Array;
	
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
	public function new(FlxSprite player, FlxTilemap map, Array path) 
	{
		super();
		_player = player;
		_tilemap = map;
		_path = path;
		
		_moveTowardIndex = 0;
		
		//too add: image & animation adding
		//setFacingFlip
		
		setPosition(path[0].x, path[0].y);
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
			//if the player is not in sight
			//engage ordinary patrol navigation behavior
			else{
				patrol();
			}
		}
		//is chasing player
		else{
			
			//reset offAlert related countdowns
			patrolIdleCountdown = patrolIdleTime;
			patrolTurnCountdown = patrolTurnTime;
			
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
		
		if (_backtrackPath.length > 0){
			//need: get the rotation required to set velocity in a point's direction
		}
		//if we are on a node specified by path..
		else if (path[_moveTowardIndex].equals(getPosition()){
			
			//while idle, the soldier turns in a random direction every 'patrolTurnTime' seconds
			patrolTurnCountdown -= FlxG.timescale;
			if (patrolTurnCountdown <= 0){
				patrolTurnCountdown = patrolTurnTime;
				
				randomDirection();
			}
			
			//after idle for 'patrolIdleTime' seconds, turn toward the next point in the path and start moving toward it
			patrolIdleCountdown -= FlxG.timescale;
			if (patrolIdleCountdown <= 0){
				patrolIdleCountdown = patrolIdleTime;
				
				_moveTowardIndex++;
				if (_moveTowardIndex > _path.length){
					_moveTowardIndex = 0;
				}
				
				if (isUp(_path[_moveTowardIndex])){
					turnUp();
				}
				if (isDown(_path[_moveTowardIndex])){
					turnDown();
				}
				if (isLeft(_path[_moveTowardIndex])){
					turnLef();
				}
				if (isRight(_path[_moveTowardIndex])){
					turnRigth();
				}
			}
		}
		//not on a node specifed by path
		else{
			
			//turn toward that point and move toward it
			if (isUp(_path[_moveTowardIndex])){
				turnUp();
			}
			if (isDown(_path[_moveTowardIndex])){
				turnDown();
			}
			if (isLeft(_path[_moveTowardIndex])){
				turnLef();
			}
			if (isRight(_path[_moveTowardIndex])){
				turnRigth();
			}
			velocity.set(walkSpeed);
			velocity.rotate(new FlxPoint(0,0), _rot);
		}
		
	}
	
	function aim():Void{
		
		//aimCountdown= aimTime;
		patrolIdleCountdown = patrolIdleTime;
		patrolTurnCountdown = patrolTurnTime; 
		pursueIdleCountdown = pursueIdleTime;
		pursueTurnCountdown = pursueTurnTime; 
		backtrackAddCountdown = backtrackAddTime;
		
		aimCountdown -= FlxG.timescale;
		if (aimCountdown <= 0){
			aimCountdown = aimTime;
			//to add: kill player
		}
	}
	
	//place the last known player position so that it is in line vertically or horizontally with soldier
	//then, move the soldier toward that point
	function pursue():Void{
		
		aimCountdown= aimTime;
		patrolIdleCountdown = patrolIdleTime;
		patrolTurnCountdown = patrolTurnTime; 
		pursueIdleCountdown = pursueIdleTime;
		pursueTurnCountdown = pursueTurnTime; 
		//backtrackAddCountdown = backtrackAddTime;
		
		//if we are at the last know player position
		if (getPosition().equals(_lastKnownPlayerPosition)){
			
		}
		//not at last known player position
		else{
			
			backtrackAddCountdown -= FlxG.timescale;
			if (backtrackAddCountdown <= 0){
				backtrackAddCountdown = backtrackAddTime;
				
				_backtrackPath.push(getPosition());
			}
			
			//need: get the rotation required to set velocity in a point's direction
		}
	}
	
	//returns true if the soldier can see the player from any direction
	function canSeePlayer360():Bool{
		
		//to add: if the player is invisible. return false
		
		
		//if a ray cannot travel from soldier to player's midpoint without hitting anything,
		//return false
		if (!_tilemap.ray(getMidpoint(), _player.getMidpoint()){
			return false;
		}
		
		//if the distance from the soldier to the player is greater than the viewDistance,
		//return false
		var distanceToPlayer:Float = Math.sqrt( Math.pow(_player.getPosition().x - getPosition().x, 2) 
												+ Math.pow(_player.getPosition().y - getPosition().y, 2));
		
		if (distanceToPlayer > FOV_Distance){
			return false;
		}
		
		//if all conditions for player being unseen fail to be true,
		//return true
		return true;
	}
	
	//todo: find proper facing vectors and make sure angle measuring is correct
	//returns true if the soldier can see the player within its FOV angle
	function canSeePlayerCone(){
		//if the player is outside the soldier's viewAngle pointing where the soldier is facing,
		//return false
		var directionVec:FlxVector = (new FlxVector(_player.getMidpoint().x - getMidpoint().x,
													_player.getMidpoint().y - getMidpoint().y);
		var facingVec:FlxVector;
		if (this.facing == FlxObject.UP){
			facingVec = new FlxVector(0, 1);
		}
		if (this.facing == FlxObject.DOWN){
			facingVec = new FlxVector(0, -1);
		}
		if (this.facing == FlxObject.LEFT){
			facingVec = new FlxVector(-1, 0);
		}
		else){
			facingVec = new FlxVector(1, 0);
		}
		var angle:Float = directionVec.degreesBetween(facingVec);
		if (angle > FOV_Angle){
			return false;
		}
		
		return canSeePlayer360();
	}
	
	function randomDirection():Void{
		var direction int = FlxRandom.int(0, 3);
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
	function isUp(FlxPoint point):Bool{
		var xVariance:Float = Math.abs(point.x - this.x);
		var yVariance:Float = Math.abs(point.y - this.y);
		return (yVariance > xVariance) && (this.y > point.y);
	}
	
	//true if point is below this object's location
	function isDown(FlxPoint point):Bool{
		var xVariance:Float = Math.abs(point.x - this.x);
		var yVariance:Float = Math.abs(point.y - this.y);
		return (yVariance > xVariance) && (this.y < point.y);
	}
	
	//true if point is to the left of this object's location
	function isLeft(FlxPoint point):Bool{
		var xVariance:Float = Math.abs(point.x - this.x);
		var yVariance:Float = Math.abs(point.y - this.y);
		return (xVariance > yVariance) && (this.x < point.x);
	}
	
	//true if point is to the right of this object's location
	function isRight(FlxPoint point):Bool{
		var xVariance:Float = Math.abs(point.x - this.x);
		var yVariance:Float = Math.abs(point.y - this.y);
		return (xVariance > yVariance) && (this.x > point.x);
	}
}