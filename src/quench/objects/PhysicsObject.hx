package quench.objects;

import flixel.FlxSprite;

class PhysicsObject extends FlxSprite {
	public static final MOTION_FACTOR:Float = 100;

	public function new(?x:Float = 0, ?y:Float = 0) {
		super(x, y);

		// maxVelocity.set(MOTION_FACTOR, MOTION_FACTOR);
		drag.set(MOTION_FACTOR, MOTION_FACTOR);
		elasticity = 0.5; // This is a value for how much acceleration is preserved after a collision; 0.5 means that half is preserved
	}
}
