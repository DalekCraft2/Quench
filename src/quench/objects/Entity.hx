package quench.objects;

import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil;

class Entity extends PhysicsObject {
	// public var fieldOfView:Float = 60; // TODO Use this for Statue's "isSeen" system
	private var directionalAcceleration:FlxPoint = FlxPoint.get();
	private var entityMovementSpeed:Float = 1;
	private var isWalking:Bool = false;
	/* FIXME This might be a HaxeFlixel bug, but, when noAcceleration is true and I push Enemies like Opponent against the left wall, they can't move away from the wall.
		I feel like it might be related to collisionDrag, and that has a bug of only having effects on objects when the Player pushes them from the right or from the bottom. */
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
