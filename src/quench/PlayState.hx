package quench;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.weapon.FlxBullet;
import flixel.addons.weapon.FlxWeapon;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.helpers.FlxBounds;
import quench.objects.BouncyThing;
import quench.objects.Box;
import quench.objects.Enemy;
import quench.objects.Fucker;
import quench.objects.HeavyBox;
import quench.objects.Opponent;
import quench.objects.PhysicsObject;
import quench.objects.Player;
import quench.objects.Ram;
import quench.objects.Statue;
import quench.objects.Trampoline;
import quench.objects.Wall;

// TODO Use TileMaps for pathfinding, and also use FlxWeapon/FlxBullet to implement health stuff
// TODO Use FlxControl for Player
class PlayState extends FlxState {
	public var player:Player;
	public var weapon:FlxWeapon;

	private var bullets:FlxTypedGroup<FlxBullet>;

	private var physicsObjects:FlxTypedGroup<FlxBasic>;
	private var boundaries:FlxTypedGroup<PhysicsObject>;
	private var removables:FlxTypedGroup<PhysicsObject>;

	override public function create():Void {
		super.create();

		this.bgColor = FlxColor.CYAN;

		boundaries = new FlxTypedGroup();
		final boundaryThickness:Int = 60;
		var wall1:PhysicsObject = new Wall(0, 0, boundaryThickness);
		var wall2:PhysicsObject = new Wall(FlxG.width - boundaryThickness, 0, boundaryThickness);
		var trampoline1:PhysicsObject = new Trampoline(0, 0, boundaryThickness);
		var trampoline2:PhysicsObject = new Trampoline(0, FlxG.height - boundaryThickness, boundaryThickness);
		boundaries.add(wall1);
		boundaries.add(wall2);
		boundaries.add(trampoline1);
		boundaries.add(trampoline2);

		removables = new FlxTypedGroup();

		physicsObjects = new FlxTypedGroup();
		physicsObjects.add(boundaries);
		physicsObjects.add(removables);
		add(physicsObjects);

		// Something what I learned: if an FlxBasic is added to a state twice (e.g. by doing add(obj), and then add(group) and group.add(obj)), then update() will be called twice for it
		player = new Player();
		player.screenCenter();
		physicsObjects.add(player);

		var bulletSize:FlxPoint = FlxPoint.get(16, 16);
		weapon = new FlxWeapon("default_weapon", (weapon:FlxWeapon) -> {
			var bullet:FlxBullet = bullets.recycle(FlxBullet, () -> {
				var bullet:FlxBullet = new FlxBullet();
				bullet.makeGraphic(Std.int(bulletSize.x), Std.int(bulletSize.y), FlxColor.BLACK);
				return bullet;
			});

			return bullet;
		},
			PARENT(player, new FlxBounds(FlxPoint.get(player.width / 2 - bulletSize.x / 2, player.height / 2 - bulletSize.y / 2))),
			SPEED(new FlxBounds<Float>(500, 500)));
		weapon.bulletLifeSpan = new FlxBounds<Float>(2, 2);
		// bulletSize.put(); // Can't do this because it gets reused in the bullet factory
		bullets = new FlxTypedGroup();
		physicsObjects.add(bullets);

		// camera.follow(player, NO_DEAD_ZONE);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (FlxG.keys.justPressed.ONE || (FlxG.keys.pressed.ONE && FlxG.keys.pressed.SHIFT)) {
			var newObj:PhysicsObject = new Box(player.x, player.y);
			removables.add(newObj);
		}
		if (FlxG.keys.justPressed.TWO || (FlxG.keys.pressed.TWO && FlxG.keys.pressed.SHIFT)) {
			var newObj:PhysicsObject = new HeavyBox(player.x, player.y);
			removables.add(newObj);
		}
		if (FlxG.keys.justPressed.THREE || (FlxG.keys.pressed.THREE && FlxG.keys.pressed.SHIFT)) {
			var newObj:PhysicsObject = new BouncyThing(player.x, player.y);
			removables.add(newObj);
		}
		if (FlxG.keys.justPressed.FOUR || (FlxG.keys.pressed.FOUR && FlxG.keys.pressed.SHIFT)) {
			var newObj:Enemy = new Opponent(player.x, player.y);
			newObj.target = player;
			removables.add(newObj);
		}
		if (FlxG.keys.justPressed.FIVE || (FlxG.keys.pressed.FIVE && FlxG.keys.pressed.SHIFT)) {
			var newObj:Enemy = new Ram(player.x, player.y);
			newObj.target = player;
			removables.add(newObj);
		}
		if (FlxG.keys.justPressed.SIX || (FlxG.keys.pressed.SIX && FlxG.keys.pressed.SHIFT)) {
			var newObj:Enemy = new Fucker(player.x, player.y);
			newObj.target = player;
			removables.add(newObj);
		}
		if (FlxG.keys.justPressed.SEVEN || (FlxG.keys.pressed.SEVEN && FlxG.keys.pressed.SHIFT)) {
			var newObj:Enemy = new Statue(player.x, player.y);
			newObj.target = player;
			removables.add(newObj);
		}

		if (FlxG.keys.justPressed.R) {
			for (physicsObject in removables) {
				physicsObject.destroy();
			}
			removables.clear();
		}
		if (FlxG.keys.justPressed.B) {
			for (boundary in boundaries) {
				boundary.solid = !boundary.solid;
				boundary.visible = !boundary.visible;
			}
		}

		if (FlxG.keys.justPressed.T) {
			player.screenCenter();
		}

		if (FlxG.keys.justPressed.Z) {
			weapon.fireFromParentFacing(new FlxBounds<Float>(0));
		}

		// FIXME Not a bug on my end (I believe), but I am writing this as a reminder to report to the Flixel repository that collision does not occur outside of the camera's default view, even if FlxCamera.focusOn() is used to move the focus outside of the default view
		FlxG.collide(physicsObjects, physicsObjects);
	}

	override public function destroy():Void {
		super.destroy();

		player = FlxDestroyUtil.destroy(player);
		physicsObjects = FlxDestroyUtil.destroy(physicsObjects);
		removables = FlxDestroyUtil.destroy(removables);
		boundaries = FlxDestroyUtil.destroy(boundaries);
		weapon = null;
		bullets = FlxDestroyUtil.destroy(bullets);
	}
}
