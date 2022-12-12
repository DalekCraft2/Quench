package quench.objects;

import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.util.FlxColor;

/**
 * The world's worst AI.
 */
class Opponent extends PhysicsObject {
	public function new(?x:Float = 0, ?y:Float = 0) {
		super(x, y);

		makeGraphic(40, 40, FlxColor.RED);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		var player:Player = cast(FlxG.state, PlayState).player; // I will absolutely do this different in the future, I promise.
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
		// velocity.set();
		if (facing.has(LEFT)) {
			acceleration.x -= PhysicsObject.MOTION_FACTOR;
			// velocity.x -= PhysicsObject.MOTION_FACTOR;
		}
		if (facing.has(RIGHT)) {
			acceleration.x += PhysicsObject.MOTION_FACTOR;
			// velocity.x += PhysicsObject.MOTION_FACTOR;
		}
		if (facing.has(UP)) {
			acceleration.y -= PhysicsObject.MOTION_FACTOR;
			// velocity.y -= PhysicsObject.MOTION_FACTOR;
		}
		if (facing.has(DOWN)) {
			acceleration.y += PhysicsObject.MOTION_FACTOR;
			// velocity.y += PhysicsObject.MOTION_FACTOR;
		}
	}
}
