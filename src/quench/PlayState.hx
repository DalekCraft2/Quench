package quench;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.addons.weapon.FlxBullet;
import flixel.addons.weapon.FlxWeapon;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.helpers.FlxBounds;
import quench.objects.*;

// TODO Use TileMaps for pathfinding, and also use FlxWeapon/FlxBullet to implement health stuff
// TODO Use FlxControl for Player
class PlayState extends FlxState {
	public var player:Player;
	public var weapon:FlxWeapon;

	private var bullets:FlxTypedGroup<FlxBullet>;

	private var physicsObjects:FlxTypedGroup<FlxBasic>;
	private var boundaries:FlxTypedGroup<PhysicsObject>;
	private var removables:FlxTypedGroup<FlxBasic>;

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
		// bulletSize.put(); // We can't do this because this FlxPoint gets reused in the bullet factory whenever the weapon is used.
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
			var newObj:Enemy = new Statue(player.x, player.y);
			newObj.target = player;
			removables.add(newObj);
		}
		if (FlxG.keys.justPressed.SEVEN || (FlxG.keys.pressed.SEVEN && FlxG.keys.pressed.SHIFT)) {
			var newObj:Worm = new Worm(player.x, player.y);
			newObj.target = player;
			removables.add(newObj.children);
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

		if (FlxG.keys.justPressed.Z || (FlxG.keys.pressed.Z && FlxG.keys.pressed.SHIFT)) {
			weapon.fireFromParentFacing(new FlxBounds<Float>(0)); // Fire a bullet with a direction based on the Player's "facing" value
		}

		if (FlxG.mouse.justPressed || (FlxG.mouse.pressed && FlxG.keys.pressed.SHIFT)) {
			weapon.fireAtMouse(); // Fire a bullet at the mouse
		}

		// Without this line, the collisions will only happen within the area what the camera would see if it was at (0, 0), and nowhere else
		// However, this only matters if the camera is being moved around by code like "camera.follow(player, NO_DEAD_ZONE)". If not, it's better to just comment this out.
		// FlxG.worldBounds.set(FlxG.camera.x, FlxG.camera.y);
		// FlxG.collide(physicsObjects, physicsObjects);
		collide(physicsObjects, physicsObjects);

		// Do this check after the collision, because, otherwise, the game acts as if the Player just moved extremely quickly from one position to another rather than teleporting
		if (FlxG.keys.justPressed.T) {
			player.screenCenter();
		}
	}

	private static inline function collide(?ObjectOrGroup1:FlxBasic, ?ObjectOrGroup2:FlxBasic, ?NotifyCallback:(obj1:Dynamic, obj2:Dynamic) -> Void):Bool {
		return FlxG.overlap(ObjectOrGroup1, ObjectOrGroup2, NotifyCallback, (obj1:Dynamic, obj2:Dynamic) -> {
			if (obj1 is Worm.WormSegment && obj2 is Worm.WormSegment) {
				return false;
			} else {
				return FlxObject.separate(obj1, obj2);
			}
		});
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
