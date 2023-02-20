package quench.objects;

import flixel.util.FlxColor;

// TODO Get rid of this AI because it is boring as hell. Make more stuff like the Ram.

/**
 * You will die in the next 5 minutes.
 */
class Fucker extends Enemy {
	public function new(?x:Float = 0, ?y:Float = 0) {
		super(x, y);

		makeGraphic(90, 90, FlxColor.BLUE);
		mass = 5;
		maxVelocity.set(10000, 10000);
		entityMovementSpeed = 3;
	}
}
