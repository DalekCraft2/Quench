package quench.objects;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

/**
 * You will die in the next 5 minutes.
 */
class Fucker extends PhysicsObject {
	public function new(?x:Float = 0, ?y:Float = 0) {
		super(x, y);

		makeGraphic(90, 90, FlxColor.BLUE);
		mass = 5;
		maxVelocity.set(10000, 10000);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		var player:Player = cast(FlxG.state, PlayState).player; // I will absolutely do this differently in the future, I promise.
		facing = NONE;

		// This does not work with raw coordinates, for whatever reason, so I have to use graphic midpoints.
		var graphicMidpoint:FlxPoint = getGraphicMidpoint();
		var playerGraphicMidpoint:FlxPoint = player.getGraphicMidpoint();
		if (graphicMidpoint.x > playerGraphicMidpoint.x) {
			facing = facing.with(LEFT);
		}
		if (graphicMidpoint.x < playerGraphicMidpoint.x) {
			facing = facing.with(RIGHT);
		}
		if (graphicMidpoint.y > playerGraphicMidpoint.y) {
			facing = facing.with(UP);
		}
		if (graphicMidpoint.y < playerGraphicMidpoint.y) {
			facing = facing.with(DOWN);
		}
		graphicMidpoint.put();
		playerGraphicMidpoint.put();

		acceleration.set();
		if (facing.has(LEFT)) {
			acceleration.x -= 3 * PhysicsObject.MOTION_FACTOR;
		}
		if (facing.has(RIGHT)) {
			acceleration.x += 3 * PhysicsObject.MOTION_FACTOR;
		}
		if (facing.has(UP)) {
			acceleration.y -= 3 * PhysicsObject.MOTION_FACTOR;
		}
		if (facing.has(DOWN)) {
			acceleration.y += 3 * PhysicsObject.MOTION_FACTOR;
		}
	}
}
