package quench.objects;

import flixel.FlxG;
import flixel.util.FlxColor;

class Trampoline extends PhysicsObject {
	public function new(?x:Float = 0, ?y:Float = 0, ?thickness:Int = 60) {
		super(x, y, FlxG.bitmap.create(FlxG.width, thickness, FlxColor.GREEN));

		immovable = true;
		elasticity = 3;
	}

	override public function hurt(damage:Float):Void {
		// Nope. Indestructible.
	}
}
