package quench.objects;

import flixel.FlxG;
import flixel.addons.plugin.control.FlxControl;
import flixel.addons.plugin.control.FlxControlHandler;
import flixel.util.FlxColor;
import flixel.util.FlxDirectionFlags;

class Player extends Entity {
	public var big(default, set):Bool = false;

	private var bigFactor:Float = 1;

	// private var control:FlxControlHandler;

	public function new(?x:Float = 0, ?y:Float = 0) {
		super(x, y, FlxG.bitmap.create(40, 40, FlxColor.YELLOW));

		health = 10;

		entityMovementSpeed = 2 * bigFactor;

		// control = FlxControl.create(this, noAcceleration ? FlxControlHandler.MOVEMENT_INSTANT : FlxControlHandler.MOVEMENT_ACCELERATES,
		// 	noAcceleration ? FlxControlHandler.STOPPING_INSTANT : FlxControlHandler.STOPPING_DECELERATES, 1, true);
		// FlxControl.start(control);
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

		var left:Bool = FlxG.keys.anyPressed([LEFT, A]);
		var right:Bool = FlxG.keys.anyPressed([RIGHT, D]);
		var up:Bool = FlxG.keys.anyPressed([UP, W]);
		var down:Bool = FlxG.keys.anyPressed([DOWN, S]);
		// var left:Bool = control.isPressedLeft;
		// var right:Bool = control.isPressedRight;
		// var up:Bool = control.isPressedUp;
		// var down:Bool = control.isPressedDown;
		var movementDirection:FlxDirectionFlags = FlxDirectionFlags.fromBools(left, right, up, down);
		isWalking = movementDirection != NONE;
		if (isWalking) {
			facing = movementDirection;
		}

		updateDirectionalAcceleration();
	}

	/*
		override public function destroy():Void {
			super.destroy();

			// FlxControl.stop(control);
			// FlxControl.remove(control);
			// control = null;
		}
	 */
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
