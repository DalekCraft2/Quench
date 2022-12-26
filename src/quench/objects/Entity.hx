package quench.objects;

import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil;

class Entity extends PhysicsObject {
	private var directionalAcceleration:FlxPoint = FlxPoint.get();
	private var entityMovementSpeed:Float = 1;

	override public function destroy():Void {
		super.destroy();

		directionalAcceleration = FlxDestroyUtil.put(directionalAcceleration);
	}

	private function updateDirectionalAcceleration():Void {
		acceleration.subtractPoint(directionalAcceleration);
		directionalAcceleration.set();
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
		acceleration.addPoint(directionalAcceleration);
	}
}
