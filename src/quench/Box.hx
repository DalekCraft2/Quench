package quench;

import flixel.util.FlxColor;

class Box extends Pushable {
	public function new(?x:Float = 0, ?y:Float = 0) {
		super(x, y);

		makeGraphic(40, 40, FlxColor.BROWN);
	}
}
