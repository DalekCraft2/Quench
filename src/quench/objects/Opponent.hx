package quench.objects;

import flixel.util.FlxColor;

/**
 * The world's worst AI.
 */
class Opponent extends Enemy {
	public function new(?x:Float = 0, ?y:Float = 0) {
		super(x, y);

		loadEntityFrames(FlxColor.RED);

		initializeHealth(4);
	}
}
