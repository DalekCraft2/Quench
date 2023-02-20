package quench.objects;

import flixel.FlxG;
import flixel.util.FlxColor;

class Wall extends PhysicsObject {
	public function new(?x:Float = 0, ?y:Float = 0, ?thickness:Int = 60) {
		super(x, y);

		makeGraphic(thickness, FlxG.height, FlxColor.WHITE);
		immovable = true;
	}
}
