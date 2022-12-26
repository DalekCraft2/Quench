package quench.objects;

import flixel.FlxG;
import flixel.util.FlxColor;

class Player extends Entity {
	public var big(default, set):Bool = false;

	private var bigFactor:Float = 1;

	public function new(?x:Float = 0, ?y:Float = 0) {
		super(x, y);

		makeGraphic(40, 40, FlxColor.YELLOW);
		entityMovementSpeed = 2 * bigFactor;
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (FlxG.keys.justPressed.ENTER) {
			big = !big;
		}
		if (FlxG.keys.justPressed.V) { // Garry's Mod.
			solid = !solid;
			if (solid) {
				alpha = 1;
			} else {
				alpha = 0.5;
			}
		}

		var left:Bool = FlxG.keys.pressed.LEFT;
		var right:Bool = FlxG.keys.pressed.RIGHT;
		var up:Bool = FlxG.keys.pressed.UP;
		var down:Bool = FlxG.keys.pressed.DOWN;
		facing = FlxDirectionFlags.fromBools(left, right, up, down);

		updateDirectionalAcceleration();
	}

	private function set_big(value:Bool):Bool {
		big = value;
		if (big) {
			bigFactor = 6;
		} else {
			bigFactor = 1;
		}
		// maxVelocity.set(bigFactor * PhysicsObject.MOTION_FACTOR, bigFactor * PhysicsObject.MOTION_FACTOR);
		scale.set(bigFactor, bigFactor);
		updateHitbox();
		mass = scale.x * scale.y;
		entityMovementSpeed = 2 * bigFactor;
		return value;
	}
}
