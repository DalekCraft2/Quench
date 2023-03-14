package quench.objects;

import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.util.FlxDirectionFlags;

// TODO Use FlxControl for controls, maybe
// TODO Make a keybind for reviving the Player
// TODO Try not to use the facing variable so much for motion, so we can add analog directions for the Player
// FIXME Weapon bullet offset does not update when making the Player bigger, because the player's width and height are only retrieved in the weapon's constructor
class Player extends Entity {
	private var big(default, set):Bool = false;
	private var bigFactor:Float = 1;

	public function new(?x:Float = 0, ?y:Float = 0) {
		super(x, y, FlxG.bitmap.create(40, 40, FlxColor.YELLOW));

		health = 10;

		entityMovementSpeed = 2 * bigFactor;
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (alive) {
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

			var left:Bool = FlxG.keys.anyPressed([LEFT, A]);
			var right:Bool = FlxG.keys.anyPressed([RIGHT, D]);
			var up:Bool = FlxG.keys.anyPressed([UP, W]);
			var down:Bool = FlxG.keys.anyPressed([DOWN, S]);
			var movementDirection:FlxDirectionFlags = FlxDirectionFlags.fromBools(left, right, up, down);
			isWalking = movementDirection != NONE;
			if (isWalking) {
				facing = movementDirection;
			}
		}

		updateDirectionalAcceleration();
	}

	private function set_big(value:Bool):Bool {
		big = value;
		if (big) {
			bigFactor = 6;
		} else {
			bigFactor = 1;
		}
		if (useMaxVelocity) {
			maxVelocity.set(bigFactor * PhysicsObject.MOTION_FACTOR, bigFactor * PhysicsObject.MOTION_FACTOR);
		}
		scale.set(bigFactor, bigFactor);
		updateHitbox();
		mass = scale.x * scale.y;
		entityMovementSpeed = 2 * bigFactor;
		return value;
	}
}
