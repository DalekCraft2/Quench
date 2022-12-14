package quench.objects;

import flixel.util.FlxColor;

class HeavyBox extends PhysicsObject {
	public function new(?x:Float = 0, ?y:Float = 0) {
		super(x, y);

		makeGraphic(50, 50, FlxColor.GRAY);
		mass = 2;
	}
}
