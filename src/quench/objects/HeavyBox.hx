package quench.objects;

import flixel.FlxG;

class HeavyBox extends PhysicsObject {
	public function new(?x:Float = 0, ?y:Float = 0) {
		super(x, y, FlxG.bitmap.add("assets/images/sprites/heavy_box.png"));

		initializeHealth(5);
		mass = 2;
	}
}
