package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.FlxState;
import flixel.text.FlxText;

class SpeechBubble extends FlxText {
	var THEentity:FlxSprite;
	var relPosX:Int;
	var relPosY:Int;
	var lifeTime:Int;
	
	public function new(entity:FlxSprite, relposx:Int, relposy:Int, lifetime:Int, text:String) {
		super();
		THEentity = entity;
		this.x = entity.x + relposx;
		this.y = entity.y + relposy;
		this.size = 10;
		this.text = text;
		relPosX = relposx;
		relPosY = relposy;
		lifeTime = lifetime;
	}
	
	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		this.x = THEentity.x + relPosX;
		this.y = THEentity.y + relPosY;
		
		lifeTime = lifeTime - Std.int(elapsed * 1000);
		if (lifeTime <= 0){
			this.destroy();
		}
	}
	
	public function setText(string:String):Void {
		this.text = string;
	}
}