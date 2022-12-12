package quench;

import flixel.FlxG;
import flixel.util.FlxColor;

class Trampoline extends Pushable {
	public function new(?x:Float = 0, ?y:Float = 0) {
		super(x, y);

		makeGraphic(FlxG.width, 60, FlxColor.GREEN);
		immovable = true;
		elasticity = 3;
	}
}
