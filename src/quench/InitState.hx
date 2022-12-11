package quench;

import flixel.util.FlxColor;
import flixel.FlxState;

class InitState extends FlxState {
	override public function create():Void {
		super.create();

		this.bgColor = FlxColor.CYAN;
	}
}
