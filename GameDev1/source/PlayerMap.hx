package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup;
import flixel.math.FlxAngle;
import flixel.tile.FlxTilemap;

class PlayerMap extends FlxObject {
	public var map:Array<Array<Int>>;
	
	//0 = Undiscovered
	//1 = Nothing
	//2 = Wall
	//3 = Enemy
	
	public function new(w:Int, h:Int) {
		super();
		width = w;
		height = h;
		
		map = [for (x in 0...w) [for (y in 0...h) 0]];
	}
	
	public function setpixel(x:Int, y:Int, value:Int):Void {
		if (x >= 0 && x < width && y >= 0 && y < height) {
			map[x][y] = value;
		}
	}
}