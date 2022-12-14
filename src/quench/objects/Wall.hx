package quench.objects;

import flixel.FlxG;
import flixel.util.FlxColor;

class Wall extends PhysicsObject {
	public function new(?x:Float = 0, ?y:Float = 0) {
		super(x, y);

		makeGraphic(60, FlxG.height, FlxColor.WHITE);
		immovable = true;
	}
}
