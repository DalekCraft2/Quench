package quench.objects;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.path.FlxPathfinder;
import flixel.tile.FlxTilemap;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxDirectionFlags;

// TODO Add idle behavior for when there is no target
class Enemy extends Entity {
	public var target:Entity;

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (target != null && target.alive) {
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
		if (alive && isWalking) {
			if (target != null && target.alive) {
				var midpoint:FlxPoint = getMidpoint();
				var targetMidpoint:FlxPoint = target.getMidpoint();
				directionalAcceleration.set(1, 0);
				directionalAcceleration.degrees = midpoint.degreesTo(targetMidpoint);
				// Make the acceleration constant regardless of direction
				directionalAcceleration.length = entityMovementSpeed * PhysicsObject.MOTION_FACTOR;
				if (noAcceleration) {
					if (path == null) {
						velocity.copyFrom(directionalAcceleration);
					} else {
						// TODO Make this code not awful
						// TODO Figure out whether it is possible to use FlxPath with acceleration instead of velocity, for Enemies other than Worm
						var state:PlayState = cast FlxG.state;
						@:privateAccess var tilemap:FlxTilemap = state.tilemap;
						var pathPoints:Array<FlxPoint> = tilemap.findPath(midpoint, targetMidpoint, NONE, NONE);
						path.start(pathPoints, entityMovementSpeed * PhysicsObject.MOTION_FACTOR);
					}
				} else {
					acceleration.addPoint(directionalAcceleration);
				}
				midpoint.put();
				targetMidpoint.put();
			} else if (path != null && path.active) {
				// Make the Enemy stop moving
				path.active = false;
				// Make the Enemy not instantly teleport to the end of the current path if the Player respawns
				FlxArrayUtil.clearArray(path.nodes);
			}
		}
	}

	// TODO Make this not happen instantly and instead happen gradually
	// TODO Make the requirements for looking straight in any direction (i.e. up, down, left, and right) more lenient (in other words, the target does not have to be directly horizontal to the enemy for the enemy to face left or right)
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
