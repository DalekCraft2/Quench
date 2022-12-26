package quench.objects;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

// TODO Make a common subclass for the AIs, and use Flixel's pathfinder for the AIs

/**
 * The world's worst AI.
 */
class Opponent extends Entity {
	public function new(?x:Float = 0, ?y:Float = 0) {
		super(x, y);

		makeGraphic(40, 40, FlxColor.RED);
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
