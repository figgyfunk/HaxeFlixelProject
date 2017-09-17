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
	var walkDist:Float = 10;
	var runDist:Float = 20;
	var aimTime:Float = 2;
	var shootCountdown:Float = aimTime;
	var searchTime:Float = 2;
	var searchCountdown:Float = searchTime;
	var FOV_Distance:Float = 10;
	var FOV_Angle:Float = 45;
	
	var _player:FlxSprite;//reference to player
	var _tilemap:FlxTilemap;//reference to tilemap
	var _walls:FlxGroup;//reference to group of all the walls
	var _lastKnownPlayerMidpoint:FlxPoint;
	var onAlert = false;
	
	var _up:Bool = false;
	var _down:Bool = false;
	var _left:Bool = false;
	var _right:Bool = false;

	//arguments: reference to the player, tilemap, and a group of all walls in the level
	public function new(FlxSprite player, FlxTilemap map, FlxGroup walls) 
	{
		super();
		_player = player;
		_tilemap = map;
		_walls = walls;
		
		//too add: image & animation adding
		//setFacingFlip
		
		randomDirection();
	}
	
	override public function update(elapsed:Float):Void{
		super.update(elapsed);
	}
	
	function movement():Void{
		//on normal patrol
		if (!onAlert){
			//if the player is seen,
			//set this soldier's behavior to the chasing behavior
			if (canSeePlayer()){
				onAlert = true;
				_lastKnownPlayerMidpoint = _player.getMidpoint();
			}
			//if the player is not in sight
			//engage ordinary patrol navigation behavior
			else{
				patrol();
			}
		}
		//is chasing player
		else{
			//if the player is in sight,
			//the soldier is stationary while counting down to shoot
			if (canSeePlayer()){
				searchCountdown = searchTime;
				_lastKnownPlayerMidpoint = _player.getMidpoint();
				shootCountdown -= FlxG.timescale;
				if (aimTime<=0){
					//to add: kill player
				}
			}
			//if the player is out of sight..
			else{
				shootCountdown = aimTime;
				//if the soldier is at the last position it saw the player,
				//it is stationary while counting down. If the countdown reaches 0,
				//the soldier returns to the patrol behavior
				if (getMidpoint().equals(_lastKnownPlayerMidpoint)){
					searchCountdown -= FlxG.timescale;
					if (searchCountdown <= 0){
						onAlert = false;
						searchCountdown = searchTime;
					}
				}
				//if the soldier is not at the last position it saw the player,
				//it runs toward that position
				else{
					pursue();
				}
			}
		}
	}
	
	//if can move in the direction the soldier is facing, move that way,
	//otherwise, changee to a random direction
	//note: may change later
	function patrol():Void{
		var currentX:Float = getMidpoint().x;
		var currentY:Float = getMidpoint().y;
		if (_up){
			if (!overlapsAt(currentX, currentY + walkDist, _walls){
				setPosition(currentX, currentY + walkDist);
			}
			else{
				randomDirection();
				patrol();
			}
		}
		else if (_down){
			if (!overlapsAt(currentX, currentY - walkDist, _walls){
				setPosition(currentX, currentY - walkDist);
			}
			else{
				randomDirection();
				patrol();
			}
		}
		else if (_left){
			if (!overlapsAt(currentX - walkDist, currentY, _walls){
				setPosition(currentX - walkDist, currentY);
			}
			else{
				randomDirection();
				patrol();
			}
		}
		else{//_right
			if (!overlapsAt(currentX + walkDist, currentY, _walls){
				setPosition(currentX + walkDist, currentY);
			}
			else{
				randomDirection();
				patrol();
			}
		}
		
	}
	
	//place the last known player position so that it is inline vertically or horizontally with soldier
	//then, move the soldier toward that point
	function pursue():Void{
		
		var _lastKnownPlayerX:Float = _lastKnownPlayerMidpoint.x;
		var _lastKnownPlayerY:Float = _lastKnownPlayerMidpoint.y;
		var xVariance = Math.abs(_lastKnownPlayerX - getMidpoint().x);
		var yVariance = Math.abs(_lastKnownPlayerY - getMidpoint().y);
		if (xVariance < yVariance){
			_lastKnownPlayerMidpoint = new FlxPoint(getMidpoint().x, _lastKnownPlayerY);
			if (_lastKnownPlayerMidpoint.y > getMidpoint().y){
				turnUp();
				setPosition(getPosition().x, getPosition().y + runDist);
			}
			else{
				turnDown();
				setPosition(getPosition().x, getPosition().y - runDist);
			}
		}
		else{//xVariance > yVariance
			_lastKnownPlayerMidpoint = new FlxPoint(_lastKnownPlayerX, getMidpoint().y);
			if (_lastKnownPlayerMidpoint.x > getMidpoint().x){
				turnRight();
			setPosition(getPosition().x + runDist, getPosition().y);
			}
			else{
				turnLeft();
				setPosition(getPosition().x - runDist, getPosition().y);
			}
		}
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
		facing= FlxObject.UP;
	}
	
	function turnDown():Void{
		_up = false;
		_down = true;
		_left = false;
		_right = false;
		facing= FlxObject.DOWN;
	}
	
	function turnLeft():Void{
		_up = false;
		_down = false;
		_left = true;
		_right = false;
		facing = FlxObject.LEFT;
	}
	
	function turnRight():Void{
		_up = false;
		_down = false;
		_left = false;
		_right = true;
		facing = FlxObject.RIGHT;
	}
	
	//returns true if the 
	function canSeePlayer():Bool{
		
		//to add: if the player is invisible. return false
		
		
		//if a ray cannot travel from soldier to player without hitting anything,
		//return false
		if (!_tilemap.ray(getMidpoint(), _player.getMidpoint()){
			return false;
		}
		
		//if the distance from the soldier to the player is greater than the viewDistance,
		//return false
		var distanceToPlayer:Float = Math.sqrt( Math.pow(_player.getMidpoint().x - getMidpoint().x, 2) 
												+ Math.pow(_player.getMidpoint().y - getMidpoint().y, 2));
		
		if (distanceToPlayer > FOV_Distance){
			return false;
		}
		
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
		
		//if all conditions for player being unseen fail to be true,
		//return true
		return true;
	}
}