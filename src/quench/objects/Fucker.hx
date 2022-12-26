package quench.objects;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

// TODO Get rid of this AI because it is boring as hell. Make more stuff like the Ram.

/**
 * You will die in the next 5 minutes.
 */
class Fucker extends Entity {
	public function new(?x:Float = 0, ?y:Float = 0) {
		super(x, y);

		makeGraphic(90, 90, FlxColor.BLUE);
		mass = 5;
		maxVelocity.set(10000, 10000);
		entityMovementSpeed = 3;
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		var player:Player = cast(FlxG.state, PlayState).player; // I will absolutely do this differently in the future, I promise.
		facing = NONE;

		// This does not work with raw coordinates, for whatever reason, so I have to use graphic midpoints.
		var graphicMidpoint:FlxPoint = getMidpoint();
		var playerGraphicMidpoint:FlxPoint = player.getMidpoint();
		var left:Bool = graphicMidpoint.x > playerGraphicMidpoint.x;
		var right:Bool = graphicMidpoint.x < playerGraphicMidpoint.x;
		var up:Bool = graphicMidpoint.y > playerGraphicMidpoint.y;
		var down:Bool = graphicMidpoint.y < playerGraphicMidpoint.y;
		facing = FlxDirectionFlags.fromBools(left, right, up, down);
		graphicMidpoint.put();
		playerGraphicMidpoint.put();

		updateDirectionalAcceleration();
	}
}
