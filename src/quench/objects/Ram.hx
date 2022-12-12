package quench.objects;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxTimer;

/**
 * The world's worst AI, but modified.
 */
class Ram extends PhysicsObject {
	private var canMove:Bool = true;

	private var timer:FlxTimer;

	public function new(?x:Float = 0, ?y:Float = 0) {
		super(x, y);

		makeGraphic(40, 40, FlxColor.PURPLE);

		timer = new FlxTimer().start(3, (tmr:FlxTimer) -> {
			canMove = !canMove;
		}, 0);
		maxVelocity.set(10000, 10000);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		// if (canMove) {
		var player:Player = cast(FlxG.state, PlayState).player; // I will absolutely do this differently in the future, I promise.
		facing = NONE;

		// This does not work with raw coordinates, for whatever reason, so I have to use graphic midpoints.
		var graphicMidpoint:FlxPoint = getGraphicMidpoint();
		var playerGraphicMidpoint:FlxPoint = player.getGraphicMidpoint();
		if (graphicMidpoint.x > playerGraphicMidpoint.x) {
			facing = facing.with(LEFT);
		} else if (graphicMidpoint.x < playerGraphicMidpoint.x) {
			facing = facing.with(RIGHT);
		}
		if (graphicMidpoint.y > playerGraphicMidpoint.y) {
			facing = facing.with(UP);
		} else if (graphicMidpoint.y < playerGraphicMidpoint.y) {
			facing = facing.with(DOWN);
		}
		graphicMidpoint.put();
		playerGraphicMidpoint.put();

		var factor:Float = canMove ? 7 : 1;
		acceleration.set();
		if (facing.has(LEFT)) {
			acceleration.x -= factor * PhysicsObject.MOTION_FACTOR;
		}
		if (facing.has(RIGHT)) {
			acceleration.x += factor * PhysicsObject.MOTION_FACTOR;
		}
		if (facing.has(UP)) {
			acceleration.y -= factor * PhysicsObject.MOTION_FACTOR;
		}
		if (facing.has(DOWN)) {
			acceleration.y += factor * PhysicsObject.MOTION_FACTOR;
		}
		// }
	}

	override public function destroy():Void {
		super.destroy();

		timer = FlxDestroyUtil.destroy(timer);
	}
}
