package quench.objects;

import flixel.util.FlxColor;

class BouncyThing extends PhysicsObject {
	public function new(?x:Float = 0, ?y:Float = 0) {
		super(x, y);

		makeGraphic(40, 40, FlxColor.ORANGE);
		elasticity = 0.9;
	}
}
