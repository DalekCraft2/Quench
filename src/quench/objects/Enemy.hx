package quench.objects;

import flixel.math.FlxPoint;
import flixel.util.FlxDirectionFlags;

class Enemy extends Entity {
	public var target:Entity;

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (target != null) {
			lookAtTarget();
		}

		updateDirectionalAcceleration();
	}

	override public function destroy():Void {
		super.destroy();

		target = null;
	}

	override private function updateDirectionalAcceleration():Void {
		if (noAcceleration) {
			velocity.zero();
		} else {
			acceleration.subtractPoint(directionalAcceleration);
		}
		directionalAcceleration.zero();
		// if (facing.has(LEFT)) {
		// 	directionalAcceleration.x -= entityMovementSpeed * PhysicsObject.MOTION_FACTOR;
		// }
		// if (facing.has(RIGHT)) {
		// 	directionalAcceleration.x += entityMovementSpeed * PhysicsObject.MOTION_FACTOR;
		// }
		// if (facing.has(UP)) {
		// 	directionalAcceleration.y -= entityMovementSpeed * PhysicsObject.MOTION_FACTOR;
		// }
		// if (facing.has(DOWN)) {
		// 	directionalAcceleration.y += entityMovementSpeed * PhysicsObject.MOTION_FACTOR;
		// }

		if (alive && isWalking) {
			// This does not work with raw coordinates, for whatever reason, so I have to use midpoints.
			var midpoint:FlxPoint = getMidpoint();
			var targetMidpoint:FlxPoint = target.getMidpoint();
			directionalAcceleration.set(1, 0);
			directionalAcceleration.degrees = midpoint.degreesTo(targetMidpoint);
			// Make the acceleration constant regardless of direction
			directionalAcceleration.length = entityMovementSpeed * PhysicsObject.MOTION_FACTOR;
			if (noAcceleration) {
				velocity.copyFrom(directionalAcceleration);
			} else {
				acceleration.addPoint(directionalAcceleration);
			}
		}
	}

	// TODO Make this not happen instantly and instead happen gradually
	// TODO Make the requirements for looking straight in any direction (i.e. up, down, left, and right) more lenient
	private function lookAtTarget():Void {
		if (alive) {
			var midpoint:FlxPoint = getMidpoint();
			var targetMidpoint:FlxPoint = target.getMidpoint();
			var left:Bool = midpoint.x > targetMidpoint.x;
			var right:Bool = midpoint.x < targetMidpoint.x;
			var up:Bool = midpoint.y > targetMidpoint.y;
			var down:Bool = midpoint.y < targetMidpoint.y;
			var movementDirection:FlxDirectionFlags = FlxDirectionFlags.fromBools(left, right, up, down);
			isWalking = movementDirection != NONE;
			if (isWalking) {
				facing = movementDirection;
			}
			midpoint.put();
			targetMidpoint.put();
		}
	}
}
