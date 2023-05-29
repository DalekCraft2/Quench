package quench.objects;

import flixel.util.FlxColor;

/**
 * Weeping Angel. Or SCP-173. Take your pick.
 */
class Statue extends Enemy {
	public function new(?x:Float = 0, ?y:Float = 0) {
		super(x, y);

		loadEntityFrames(FlxColor.GRAY);

		initializeHealth(20);

		mass = 1.5;
		elasticity = 0.3;

		entityMovementSpeed = 3;
		drag.set(3 * PhysicsObject.MOTION_FACTOR, 3 * PhysicsObject.MOTION_FACTOR);
	}

	override public function update(elapsed:Float):Void {
		var tempTarget:Entity = target;
		if (target != null && target.alive && target.canSee(this)) {
			target = this; // This sets the animation frame to 0, which I think looks better somehow
			// target = null;
		}

		super.update(elapsed);

		target = tempTarget;
	}
}
