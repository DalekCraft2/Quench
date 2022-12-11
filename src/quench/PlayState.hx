package quench;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;

class PlayState extends FlxState {
	private var player:Player;
	private var pushables:FlxTypedGroup<Pushable>;

	override public function create():Void {
		super.create();

		this.bgColor = FlxColor.CYAN;

		pushables = new FlxTypedGroup();
		add(pushables);

		player = new Player();
		player.screenCenter();
		add(player);

		pushables.add(player);
		pushables.add(new Pushable(500, 400));
		pushables.add(new Pushable(400, 500));
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		// FIXME If the player is touching two boxes at the same time and pushing them in the same direction, they eventually start phasing through one of them
		FlxG.collide(pushables, pushables);
	}

	override public function destroy():Void {
		super.destroy();

		player = FlxDestroyUtil.destroy(player);
		pushables = FlxDestroyUtil.destroy(pushables);
	}
}
