package quench.objects;

import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil;

class Entity extends PhysicsObject {
	// public var fieldOfView:Float = 60; // TODO Use this for Statue's "isSeen" system
	private var directionalAcceleration:FlxPoint = FlxPoint.get();
	private var entityMovementSpeed:Float = 1;
	private var isWalking:Bool = false;
	private var noAcceleration:Bool = false;

	override public function destroy():Void {
		super.destroy();

		directionalAcceleration = FlxDestroyUtil.put(directionalAcceleration);
	}

	private function updateDirectionalAcceleration():Void {
		if (noAcceleration) {
			velocity.zero();
		} else {
			acceleration.subtractPoint(directionalAcceleration);
		}
		directionalAcceleration.zero();
		if (isWalking) {
			if (facing.has(LEFT)) {
				directionalAcceleration.x -= entityMovementSpeed * PhysicsObject.MOTION_FACTOR;
			}
			if (facing.has(RIGHT)) {
				directionalAcceleration.x += entityMovementSpeed * PhysicsObject.MOTION_FACTOR;
			}
			if (facing.has(UP)) {
				directionalAcceleration.y -= entityMovementSpeed * PhysicsObject.MOTION_FACTOR;
			}
			if (facing.has(DOWN)) {
				directionalAcceleration.y += entityMovementSpeed * PhysicsObject.MOTION_FACTOR;
			}
			// Make the acceleration constant regardless of direction
			directionalAcceleration.length = entityMovementSpeed * PhysicsObject.MOTION_FACTOR;
			if (noAcceleration) {
				velocity.copyFrom(directionalAcceleration);
			} else {
				acceleration.addPoint(directionalAcceleration);
			}
		}
	}
}
