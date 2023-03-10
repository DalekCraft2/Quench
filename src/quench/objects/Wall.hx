package quench.objects;

import flixel.FlxG;
import flixel.util.FlxColor;

class Wall extends PhysicsObject {
	public function new(?x:Float = 0, ?y:Float = 0, ?thickness:Int = 60) {
		super(x, y, FlxG.bitmap.create(thickness, FlxG.height, FlxColor.WHITE));

		immovable = true;
	}

	override public function hurt(damage:Float):Void {
		// Nope. Indestructible.
	}
}
