package quench.objects;

import flixel.FlxG;
import flixel.util.FlxColor;

class Player extends PhysicsObject {
	public var big(default, set):Bool = false;

	private var bigFactor:Float = 1;

	public function new(?x:Float = 0, ?y:Float = 0) {
		super(x, y);

		makeGraphic(40, 40, FlxColor.YELLOW);
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

		facing = NONE;
		if (FlxG.keys.pressed.LEFT) {
			facing = facing.with(LEFT);
		}
		if (FlxG.keys.pressed.RIGHT) {
			facing = facing.with(RIGHT);
		}
		if (FlxG.keys.pressed.UP) {
			facing = facing.with(UP);
		}
		if (FlxG.keys.pressed.DOWN) {
			facing = facing.with(DOWN);
		}

		acceleration.set();
		if (facing.has(LEFT)) {
			acceleration.x -= 2 * Pushable.MOTION_FACTOR * bigFactor;
		}
		if (facing.has(RIGHT)) {
			acceleration.x += 2 * Pushable.MOTION_FACTOR * bigFactor;
		}
		if (facing.has(UP)) {
			acceleration.y -= 2 * Pushable.MOTION_FACTOR * bigFactor;
		}
		if (facing.has(DOWN)) {
			acceleration.y += 2 * Pushable.MOTION_FACTOR * bigFactor;
		}
	}

	private function set_big(value:Bool):Bool {
		big = value;
		if (big) {
			bigFactor = 2;
		} else {
			bigFactor = 1;
		}
		maxVelocity.set(bigFactor * Pushable.MOTION_FACTOR, bigFactor * Pushable.MOTION_FACTOR);
		scale.set(bigFactor, bigFactor);
		updateHitbox();
		mass = scale.x * scale.y;
		return value;
	}
}
