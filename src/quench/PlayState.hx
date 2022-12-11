package quench;

import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;

class PlayState extends FlxState {
	private var player:Player;

	override public function create():Void {
		super.create();

		this.bgColor = FlxColor.CYAN;

		player = new Player();
		player.screenCenter();
		add(player);
	}

	override public function destroy():Void {
		super.destroy();

		player = FlxDestroyUtil.destroy(player);
	}
}
