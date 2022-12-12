package quench;

import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import quench.objects.BouncyThing;
import quench.objects.Box;
import quench.objects.HeavyBox;
import quench.objects.PhysicsObject;
import quench.objects.Player;
import quench.objects.Trampoline;
import quench.objects.Wall;

class PlayState extends FlxState {
	private var player:Player;
	private var physicsObjects:FlxTypedGroup<PhysicsObject>;
	private var removables:FlxTypedGroup<PhysicsObject>;

	override public function create():Void {
		super.create();

		this.bgColor = FlxColor.CYAN;

		removables = new FlxTypedGroup();

		physicsObjects = new FlxTypedGroup();
		add(physicsObjects);
		var wall1:PhysicsObject = new Wall(0, 0);
		var wall2:PhysicsObject = new Wall(FlxG.width - 60, 0);
		var trampoline1:PhysicsObject = new Trampoline(0, 0);
		var trampoline2:PhysicsObject = new Trampoline(0, FlxG.height - 60);
		physicsObjects.add(wall1);
		physicsObjects.add(wall2);
		physicsObjects.add(trampoline1);
		physicsObjects.add(trampoline2);

		// Something what I learned: if an FlxBasic is added to a state twice (e.g. by doing add(obj), and then add(group) and group.add(obj)), then update() will be called twice for it
		player = new Player();
		player.screenCenter();
		physicsObjects.add(player);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (FlxG.keys.justPressed.SPACE) {
			Debug.logTrace(player.x + ", " + player.y);
		}

		if (FlxG.keys.justPressed.ONE) {
			var newObj:PhysicsObject = new Box(player.x, player.y);
			physicsObjects.add(newObj);
			removables.add(newObj);
		}
		if (FlxG.keys.justPressed.TWO) {
			var newObj:PhysicsObject = new HeavyBox(player.x, player.y);
			physicsObjects.add(newObj);
			removables.add(newObj);
		}
		if (FlxG.keys.justPressed.THREE) {
			var newObj:PhysicsObject = new BouncyThing(player.x, player.y);
			physicsObjects.add(newObj);
			removables.add(newObj);
		}

		if (FlxG.keys.justPressed.R) {
			for (physicsObject in removables) {
				physicsObjects.remove(physicsObject);
				physicsObject.destroy();
			}
			removables.clear();
		}

		if (FlxG.keys.justPressed.T) {
			player.screenCenter();
		}

		// FIXME If the player is touching two objects at the same time and pushing them in the same direction with enough speed, they eventually start phasing through one of them
		FlxG.collide(physicsObjects, physicsObjects);
	}

	override public function destroy():Void {
		super.destroy();

		player = FlxDestroyUtil.destroy(player);
		physicsObjects = FlxDestroyUtil.destroy(physicsObjects);
		removables = FlxDestroyUtil.destroy(removables);
	}
}
