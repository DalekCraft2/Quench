package quench;

import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;

class PlayState extends FlxState {
	private var player:Player;
	private var pushables:FlxTypedGroup<Pushable>;
	private var removables:FlxTypedGroup<Pushable>;

	override public function create():Void {
		super.create();

		this.bgColor = FlxColor.CYAN;

		removables = new FlxTypedGroup();

		pushables = new FlxTypedGroup();
		add(pushables);
		var wall1:Pushable = new Wall(0, 0);
		var wall2:Pushable = new Wall(FlxG.width - 60, 0);
		var trampoline1:Pushable = new Trampoline(0, 0);
		var trampoline2:Pushable = new Trampoline(0, FlxG.height - 60);
		pushables.add(wall1);
		pushables.add(wall2);
		pushables.add(trampoline1);
		pushables.add(trampoline2);

		// Something what I learned: if an FlxBasic is added to a state twice (e.g. by doing add(obj), and then add(group) and group.add(obj)), then update() will be called twice for it
		player = new Player();
		player.screenCenter();
		pushables.add(player);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (FlxG.keys.justPressed.SPACE) {
			Debug.logTrace(player.x + ", " + player.y);
		}

		if (FlxG.keys.justPressed.ONE) {
			var newObj:Pushable = new Box(player.x, player.y);
			pushables.add(newObj);
			removables.add(newObj);
		}
		if (FlxG.keys.justPressed.TWO) {
			var newObj:Pushable = new HeavyBox(player.x, player.y);
			pushables.add(newObj);
			removables.add(newObj);
		}
		if (FlxG.keys.justPressed.THREE) {
			var newObj:Pushable = new BouncyThing(player.x, player.y);
			pushables.add(newObj);
			removables.add(newObj);
		}

		if (FlxG.keys.justPressed.R) {
			for (pushable in removables) {
				pushables.remove(pushable);
				pushable.destroy();
			}
			removables.clear();
		}

		if (FlxG.keys.justPressed.T) {
			player.screenCenter();
		}

		// FIXME If the player is touching two objects at the same time and pushing them in the same direction with enough speed, they eventually start phasing through one of them
		FlxG.collide(pushables, pushables);
	}

	override public function destroy():Void {
		super.destroy();

		player = FlxDestroyUtil.destroy(player);
		pushables = FlxDestroyUtil.destroy(pushables);
		removables = FlxDestroyUtil.destroy(removables);
	}
}
