package quench;

import flixel.FlxG;
import flixel.util.FlxColor;

class Player extends Pushable {
	public function new(?x:Float = 0, ?y:Float = 0) {
		super(x, y);

		makeGraphic(40, 40, FlxColor.YELLOW);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		facing = NONE;

		if (FlxG.keys.pressed.LEFT) {
			facing = facing.with(LEFT);
		}
		if (FlxG.keys.pressed.RIGHT) {
			facing = facing.with(RIGHT);
		}
		if (FlxG.keys.pressed.UP) {
			facing = facing.with(UP);
		}
		if (FlxG.keys.pressed.DOWN) {
			facing = facing.with(DOWN);
		}

		acceleration.set();
		if (facing.has(LEFT)) {
			acceleration.x -= Pushable.MOTION_FACTOR;
		}
		if (facing.has(RIGHT)) {
			acceleration.x += Pushable.MOTION_FACTOR;
		}
		if (facing.has(UP)) {
			acceleration.y -= Pushable.MOTION_FACTOR;
		}
		if (facing.has(DOWN)) {
			acceleration.y += Pushable.MOTION_FACTOR;
		}
	}
}
