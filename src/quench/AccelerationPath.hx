package quench;

import flixel.math.FlxPoint;
import flixel.path.FlxPath;

// TODO Make this work without requiring constantly recreating the path
class AccelerationPath extends FlxPath {
	public var useAcceleration:Bool = true;

	override public function update(elapsed:Float):Void {
		if (useAcceleration) {
			if (object == null)
				return;

			if (_firstUpdate) {
				if (immovable) {
					_wasObjectImmovable = object.immovable;
					object.immovable = true;
				}
				_firstUpdate = false;
			}

			// first check if we need to be pointing at the next node yet
			FlxPath._point.x = object.x;
			FlxPath._point.y = object.y;
			if (autoCenter) {
				FlxPath._point.add(object.width * 0.5, object.height * 0.5);
			}
			var node:FlxPoint = _nodes[nodeIndex];
			var deltaX:Float = node.x - FlxPath._point.x;
			var deltaY:Float = node.y - FlxPath._point.y;

			var horizontalOnly:Bool = axes == X;
			var verticalOnly:Bool = axes == Y;

			// TODO Determine whether these conditions for "speed * elapsed" should be modified to suit acceleration
			if (horizontalOnly) {
				if (((deltaX > 0) ? deltaX : -deltaX) < speed * elapsed) {
					node = advancePath(false);
				}
			} else if (verticalOnly) {
				if (((deltaY > 0) ? deltaY : -deltaY) < speed * elapsed) {
					node = advancePath(false);
				}
			} else {
				if (Math.sqrt(deltaX * deltaX + deltaY * deltaY) < speed * elapsed) {
					node = advancePath(false);
				}
			}

			// then just move toward the current node at the requested speed
			if (object != null && speed != 0) {
				// set velocity based on path mode
				FlxPath._point.x = object.x;
				FlxPath._point.y = object.y;

				if (autoCenter) {
					FlxPath._point.add(object.width * 0.5, object.height * 0.5);
				}

				if (!FlxPath._point.equals(node)) {
					calculateVelocity(node, horizontalOnly, verticalOnly);
				} else {
					object.acceleration.set();
				}

				// then set object rotation if necessary
				if (autoRotate) {
					object.angularVelocity = 0;
					object.angularAcceleration = 0;
					object.angle = angle + angleOffset;
				}

				if (finished) {
					cancel();
				}
			}
		} else {
			super.update(elapsed);
		}
	}

	override private function calculateVelocity(node:FlxPoint, horizontalOnly:Bool, verticalOnly:Bool):Void {
		if (useAcceleration) {
			if (horizontalOnly || FlxPath._point.y == node.y) {
				object.acceleration.x = (FlxPath._point.x < node.x) ? speed : -speed;
				angle = (object.acceleration.x < 0) ? 180 : 0;

				if (!horizontalOnly) {
					object.acceleration.y = 0;
				}
			} else if (verticalOnly || FlxPath._point.x == node.x) {
				object.acceleration.y = (FlxPath._point.y < node.y) ? speed : -speed;
				angle = (object.acceleration.y < 0) ? -90 : 90;

				if (!verticalOnly) {
					object.acceleration.x = 0;
				}
			} else {
				var acceleration:FlxPoint = object.acceleration.copyFrom(node).subtractPoint(FlxPath._point);
				acceleration.length = speed;
				angle = acceleration.degrees;
			}
		} else {
			super.calculateVelocity(node, horizontalOnly, verticalOnly);
		}
	}

	override public function cancel():FlxPath {
		if (useAcceleration) {
			onEnd();

			if (object != null) {
				object.acceleration.zero();
			}
			return this;
		} else {
			return super.cancel();
		}
	}
}
