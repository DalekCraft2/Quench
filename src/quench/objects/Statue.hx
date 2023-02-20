package quench.objects;

import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxDirectionFlags;

/**
 * Weeping Angel. Or SCP-173. Take your pick.
 */
class Statue extends Enemy {
	public function new(?x:Float = 0, ?y:Float = 0) {
		super(x, y);

		makeGraphic(40, 40, FlxColor.GRAY);

		mass = 1.5;
	}

	override private function lookAtTarget():Void {
		var midpoint:FlxPoint = getMidpoint();
		var targetMidpoint:FlxPoint = target.getMidpoint();
		var left:Bool = midpoint.x > targetMidpoint.x;
		var right:Bool = midpoint.x < targetMidpoint.x;
		var up:Bool = midpoint.y > targetMidpoint.y;
		var down:Bool = midpoint.y < targetMidpoint.y;
		var movementDirection:FlxDirectionFlags = FlxDirectionFlags.fromBools(left, right, up, down);

		var isSeen:Bool = false;
		if (left && target.facing.has(RIGHT)) {
			isSeen = true;
		}
		if (right && target.facing.has(LEFT)) {
			isSeen = true;
		}
		if (up && target.facing.has(DOWN)) {
			isSeen = true;
		}
		if (down && target.facing.has(UP)) {
			isSeen = true;
		}

		// isWalking = movementDirection != NONE && target.isWalking;
		isWalking = movementDirection != NONE && !isSeen;
		if (isWalking) {
			facing = movementDirection;
		}
		midpoint.put();
		targetMidpoint.put();
	}
}
