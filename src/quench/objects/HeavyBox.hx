package quench.objects;

import flixel.FlxG;
import flixel.util.FlxColor;

class HeavyBox extends PhysicsObject {
	public function new(?x:Float = 0, ?y:Float = 0) {
		super(x, y, FlxG.bitmap.create(50, 50, FlxColor.GRAY));

		health = 5;
		mass = 2;
	}
}
