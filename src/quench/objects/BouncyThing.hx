package quench.objects;

import flixel.FlxG;
import flixel.util.FlxColor;

class BouncyThing extends PhysicsObject {
	public function new(?x:Float = 0, ?y:Float = 0) {
		super(x, y, FlxG.bitmap.create(40, 40, FlxColor.ORANGE));

		elasticity = 0.9;
	}
}
