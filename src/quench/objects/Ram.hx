package quench.objects;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxTimer;

/**
 * My favorite AI so far, actually.
 */
class Ram extends Entity {
	private var phase:RamPhase = IDLE;

	private var timer:FlxTimer;

	public function new(?x:Float = 0, ?y:Float = 0) {
		super(x, y);

		makeGraphic(40, 40, FlxColor.WHITE);

		timer = new FlxTimer().start(4, (tmr:FlxTimer) -> {
			switch (phase) {
				case IDLE:
					phase = BACKING_UP;
					entityMovementSpeed = -1.5;
					tmr.time = 1;
					FlxTween.color(this, 1, this.color, FlxColor.MAGENTA);
				case BACKING_UP:
					phase = RAMMING;
					entityMovementSpeed = 7;
					tmr.time = 3;
					FlxTween.color(this, 1, this.color, FlxColor.MAGENTA);
				case RAMMING:
					phase = IDLE;
					entityMovementSpeed = 1;
					tmr.time = 4;
					FlxTween.color(this, 1, this.color, FlxColor.PURPLE);
			}
		}, 0);
		color = FlxColor.PURPLE;
		mass = 2;
		maxVelocity.set(10000, 10000);
		drag.set();
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

	override public function destroy():Void {
		super.destroy();

		timer = FlxDestroyUtil.destroy(timer);
	}
}

enum RamPhase {
	IDLE;
	BACKING_UP; // I am not sure of whether there is a proper word for this...
	RAMMING;
}
