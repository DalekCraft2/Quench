package quench;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;

class Player extends FlxSprite {
	private static final MOTION_FACTOR:Float = 100;

	public function new() {
		super();

		makeGraphic(40, 40, FlxColor.RED);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		if (FlxG.keys.pressed.UP) {
			y -= elapsed * MOTION_FACTOR;
		}
		if (FlxG.keys.pressed.DOWN) {
			y += elapsed * MOTION_FACTOR;
		}
		if (FlxG.keys.pressed.LEFT) {
			x -= elapsed * MOTION_FACTOR;
		}
		if (FlxG.keys.pressed.RIGHT) {
			x += elapsed * MOTION_FACTOR;
		}
	}
}
