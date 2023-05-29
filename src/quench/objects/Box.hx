package quench.objects;

import flixel.FlxG;

class Box extends PhysicsObject {
	public function new(?x:Float = 0, ?y:Float = 0) {
		super(x, y, FlxG.bitmap.add("assets/images/sprites/box.png"));

		initializeHealth(3);
	}
}
