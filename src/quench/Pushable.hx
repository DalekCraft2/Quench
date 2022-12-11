package quench;

import flixel.FlxSprite;
import flixel.util.FlxColor;

class Pushable extends FlxSprite {
	public static final MOTION_FACTOR:Float = 100;

	public function new(?x:Float = 0, ?y:Float = 0) {
		super(x, y);

		makeGraphic(40, 40, FlxColor.BROWN);
		collisionXDrag = ALWAYS;
		collisionYDrag = ALWAYS;
		maxVelocity.set(MOTION_FACTOR, MOTION_FACTOR);
		drag.set(MOTION_FACTOR, MOTION_FACTOR);
	}
}
