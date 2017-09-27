package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.FlxState;
import flixel.text.FlxText;

using flixel.util.FlxSpriteUtil;

class SpeechBubble extends FlxText {
	var THEentity:FlxSprite;
	var lifeTime:Int;
	
	var bubble:FlxSprite;
	
	public function new(entity:FlxSprite, lifetime:Int, text:String, textcolor:Int, bubblecolor:Int, State:FlxState) {
		super();
		THEentity = entity;
		this.setFormat("", 20, textcolor);
		this.text = text;
		this.x = entity.x - ((this.fieldWidth - entity.width) / 2);
		this.y = entity.y - 20;
		lifeTime = lifetime;
		
		//draw a bubble
		bubble = new FlxSprite();
		State.add(bubble);
		var lineStyle:LineStyle = { color: 0x000000, thickness: 1 };
		var drawStyle:DrawStyle = { smoothing: true };
		bubble.x = this.x;
		bubble.y = this.y;
		bubble.makeGraphic(Std.int(this.fieldWidth), Std.int(this.height), flixel.util.FlxColor.TRANSPARENT, true);
		bubble.drawRoundRect(0, 0, this.fieldWidth, this.height, 10, 10, bubblecolor, lineStyle, drawStyle);
	}
	
	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		
		//update the positions
		this.x = THEentity.x - ((this.fieldWidth - THEentity.width) / 2);
		this.y = THEentity.y - 20;
		bubble.x = this.x;
		bubble.y = this.y;
		
		//decrement lifetime
		lifeTime = lifeTime - Std.int(elapsed * 1000);
		
		//when lifetime reaches 0, destroy the speech bubble!
		if (lifeTime <= 0){
			this.destroy();
			bubble.destroy();
		}
		
		//debugging
		//setText("(" + this.x + "," + this.y + ") (" + ellipse.x + "," + ellipse.y + ")");
	}
	
	public function setText(string:String):Void {
		this.text = string;
	}
}