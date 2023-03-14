package quench;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.addons.weapon.FlxWeapon;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import haxe.io.Path;
import quench.objects.*;
import quench.weapons.*;

class PlayState extends FlxState {
	private var hudCamera:FlxCamera;
	private var weaponText:FlxText;
	private var playerWeapons:Array<FlxWeapon> = [];
	private var weaponIndex:Int = 0;

	private var weapons:Array<FlxWeapon> = [];

	private var tilemap:FlxTilemap;

	private var player:Player;
	private var physicsObjects:FlxTypedGroup<FlxBasic>;
	private var removables:FlxTypedGroup<FlxBasic>;

	// Slight edit of FlxG.collide().
	private static inline function collide(?objectOrGroup1:FlxBasic, ?objectOrGroup2:FlxBasic, ?notifyCallback:(obj1:FlxObject, obj2:FlxObject) -> Void):Bool {
		return FlxG.overlap(objectOrGroup1, objectOrGroup2, notifyCallback, (obj1:FlxObject, obj2:FlxObject) -> {
			if (obj1 is Worm.WormSegment && obj2 is Worm.WormSegment) {
				return false;
			} else {
				return FlxObject.separate(obj1, obj2);
			}
		});
	}

	override public function create():Void {
		super.create();

		this.bgColor = FlxColor.CYAN;

		physicsObjects = new FlxTypedGroup();
		add(physicsObjects);

		tilemap = new FlxTilemap();
		// I like to use the Path class even though most persons would see it as unnecessary.
		// Also, I took the tile graphics from the FlxTilemap demo.
		// https://haxeflixel.com/demos/TileMap/
		// I wonder whether I should change the extension to "csv"...
		tilemap.loadMapFromCSV(Path.join(["assets", Path.withExtension("tilemap", "txt")]),
			Path.join(["assets", "images", Path.withExtension("full_tiles", "png")]), 16, 16, FULL);
		tilemap.scale.set(FlxG.width / (tilemap.widthInTiles * tilemap.tileWidth), FlxG.height / (tilemap.heightInTiles * tilemap.tileHeight));
		physicsObjects.add(tilemap);

		removables = new FlxTypedGroup();
		physicsObjects.add(removables);

		// Something what I learned: if an FlxBasic is added to a state twice (e.g. by doing add(obj), and then add(group) and group.add(obj)), then update() will be called twice for it
		player = new Player();
		player.screenCenter();
		physicsObjects.add(player);

		playerWeapons.push(new Revolver(player));
		playerWeapons.push(new MachineGun(player));
		playerWeapons.push(new RocketPropelledGrenade(player));
		playerWeapons.push(new TankGun(player));
		#if debug
		playerWeapons.push(new DebugGun(player));
		#end
		for (weapon in playerWeapons) {
			physicsObjects.add(weapon.group);
			weapons.push(weapon);
		}

		hudCamera = new FlxCamera();
		hudCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(hudCamera, false);

		weaponText = new FlxText(0, 0, 512, null, 16);
		weaponText.camera = hudCamera;
		weaponText.setFormat(null, weaponText.size, FlxColor.WHITE, null, OUTLINE, FlxColor.BLACK);
		add(weaponText);

		updateWeaponText();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		// This has to be checked here instead of in Player because update() is not called when Player is dead
		if (FlxG.keys.justPressed.SPACE) {
			player.revive();
			player.health = 10;
			player.solid = true;
		}

		if (FlxG.mouse.wheel != 0) {
			weaponIndex = FlxMath.wrap(weaponIndex - FlxG.mouse.wheel, 0, playerWeapons.length - 1);
		}

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
		if (FlxG.keys.justPressed.EIGHT || (FlxG.keys.pressed.EIGHT && FlxG.keys.pressed.SHIFT)) {
			var newObj:Gunner = new Gunner(player.x, player.y);
			newObj.target = player;
			removables.add(newObj);
			weapons.push(newObj.weapon);
			removables.add(newObj.weapon.group);
		}
		if (FlxG.keys.justPressed.NINE || (FlxG.keys.pressed.NINE && FlxG.keys.pressed.SHIFT)) {
			var newObj:Tank = new Tank(player.x, player.y);
			newObj.target = player;
			removables.add(newObj);
			weapons.push(newObj.weapon);
			removables.add(newObj.weapon.group);
		}
		// I think I should save the ZERO key for something *really* big...

		if (FlxG.keys.justPressed.R) {
			for (physicsObject in removables) {
				physicsObject.destroy();
			}
			removables.clear();
			FlxArrayUtil.clearArray(weapons);
			for (weapon in playerWeapons) {
				weapons.push(weapon);
			}
		}
		if (FlxG.keys.justPressed.B) {
			tilemap.exists = !tilemap.exists;
		}
		if (FlxG.keys.justPressed.F) {
			if (camera.target == null) {
				// Start following
				camera.follow(player, NO_DEAD_ZONE);
			} else {
				// Stop following
				camera.follow(null);
				// Set the camera's position to the center of the screen
				camera.scroll.zero();
			}
		}

		var weapon:FlxWeapon = playerWeapons[weaponIndex];
		if (player.alive) {
			if (FlxG.mouse.pressed) {
				// Fire a bullet at the mouse
				weapon.fireAtMouse();
			}
		}

		// Without this line, the collisions will only happen within the area what the camera would see if it was at (0, 0), and nowhere else
		// However, this only matters if the camera is being moved around by code like "camera.follow(player, NO_DEAD_ZONE)". If not, it's better to just comment this out.
		FlxG.worldBounds.set(FlxG.camera.x, FlxG.camera.y);

		for (weapon in weapons) {
			weapon.bulletsOverlap(tilemap); // This lets bullets call kill() on themselves when they overlap with the tilemap
		}
		collide(physicsObjects, physicsObjects);
		for (weapon in weapons) {
			weapon.bulletsOverlap(physicsObjects);
		}

		// Do this check after the collision, because, otherwise, the game acts as if the Player just moved extremely quickly from one position to another rather than teleporting
		if (FlxG.keys.justPressed.T) {
			player.screenCenter();
		}

		updateWeaponText();
	}

	override public function destroy():Void {
		super.destroy();

		hudCamera = FlxDestroyUtil.destroy(hudCamera);
		weaponText = FlxDestroyUtil.destroy(weaponText);
		FlxArrayUtil.clearArray(playerWeapons);
		playerWeapons = null;
		FlxArrayUtil.clearArray(weapons);
		weapons = null;
		tilemap = FlxDestroyUtil.destroy(tilemap);
		player = FlxDestroyUtil.destroy(player);
		physicsObjects = FlxDestroyUtil.destroy(physicsObjects);
		removables = FlxDestroyUtil.destroy(removables);
	}

	private function updateWeaponText():Void {
		weaponText.text = "";
		for (i => weapon in playerWeapons) {
			if (i == weaponIndex) {
				weaponText.text += "> ";
			}
			weaponText.text += weapon.name;
			// Measured in seconds
			var timeUntilReady:Float = (weapon.nextFire - FlxG.game.ticks) / 1000;
			if (timeUntilReady > 0) {
				weaponText.text += " (" + timeUntilReady + " s)";
			}
			weaponText.text += "\n";
		}
		weaponText.screenCenter(Y);
	}
}
