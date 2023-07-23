package quench;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tile.FlxBaseTilemap;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxBar;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import quench.objects.*;
import quench.weapons.QuenchWeapon;

class PlayState extends FlxState {
	private static final CAMERA_LERP:Float = 0.1;

	private var hudCamera:FlxCamera;
	private var weaponText:FlxText;
	private var weapons:Array<QuenchWeapon> = [];

	private var tilemap:FlxTilemap;

	private var player:Player;
	private var physicsObjects:FlxTypedGroup<FlxBasic>;
	private var removables:FlxTypedGroup<FlxBasic>;

	/**
	 * A slight edit of FlxG.collide(). Does special collision checks for Worms and Rams.
	 */
	private static function collide(?objectOrGroup1:FlxBasic, ?objectOrGroup2:FlxBasic, ?notifyCallback:(obj1:FlxObject, obj2:FlxObject) -> Void):Bool {
		return FlxG.overlap(objectOrGroup1, objectOrGroup2, notifyCallback, (obj1:FlxObject, obj2:FlxObject) -> {
			if (obj1 is Worm.WormSegment && obj2 is Worm.WormSegment) {
				if (cast(obj1, Worm.WormSegment).head != cast(obj2, Worm.WormSegment).head) {
					return FlxObject.separate(obj1, obj2);
				} else {
					return false;
				}
			} else if (obj1 is Ram || obj2 is Ram) {
				var ram:Ram = obj1 is Ram ? cast obj1 : cast obj2;
				var object:FlxObject = obj1 is Ram ? obj2 : obj1;
				if (ram.shouldRamHit(object, ram)) {
					return FlxObject.separate(obj1, obj2);
				} else {
					return false;
				}
			} else {
				return FlxObject.separate(obj1, obj2);
			}
		});
	}

	private static function collideNotify(obj1:FlxObject, obj2:FlxObject):Void {
		// TODO Find a way to clean this code so the Ram code isn't all over the place
		if (obj1 is Ram || obj2 is Ram) {
			var ram:Ram = obj1 is Ram ? cast obj1 : cast obj2;
			var object:FlxObject = obj1 is Ram ? obj2 : obj1;
			ram.onRamHit(object, ram);
		}
	}

	override public function create():Void {
		super.create();

		this.bgColor = FlxColor.CYAN;

		physicsObjects = new FlxTypedGroup();
		add(physicsObjects);

		@:privateAccess FlxBaseTilemap.diagonalPathfinder = new BigMoverPathfinder(1, 1, WIDE);
		tilemap = new FlxTilemap();
		// I took the tile graphics from the FlxTilemap demo.
		// https://haxeflixel.com/demos/TileMap/
		tilemap.loadMapFromCSV("assets/tilemap.csv", "assets/images/tiles/full_tiles.png", 16, 16, FULL);
		// tilemap.scale.set(FlxG.width / (tilemap.widthInTiles * tilemap.tileWidth), FlxG.height / (tilemap.heightInTiles * tilemap.tileHeight));
		tilemap.scale.set(FlxG.width / (16 * tilemap.tileWidth), FlxG.height / (9 * tilemap.tileHeight));
		physicsObjects.add(tilemap);

		removables = new FlxTypedGroup();
		physicsObjects.add(removables);

		// Something what I learned: if an FlxBasic is added to a state twice (e.g. by doing add(obj), and then add(group) and group.add(obj)), then update() will be called twice for it
		player = new Player();
		player.tilemap = tilemap;
		player.screenCenter();
		physicsObjects.add(player);

		for (weapon in player.weapons) {
			physicsObjects.add(weapon);
			weapons.push(weapon);
		}

		hudCamera = new FlxCamera();
		hudCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(hudCamera, false);

		weaponText = new FlxText(0, 0, 512, null, 16);
		weaponText.camera = hudCamera;
		weaponText.setFormat(null, weaponText.size, FlxColor.WHITE, null, OUTLINE, FlxColor.BLACK);
		#if FLX_DEBUG
		weaponText.ignoreDrawDebug = true;
		#end
		add(weaponText);
		updateWeaponText();

		var spawnGuideText:FlxText = new FlxText(0, 0, 200,
			"Spawn Guide:\n"
			+ "1: Box\n"
			+ "2: Heavy Box\n"
			+ "3: Bouncy Thing\n"
			+ "4: Opponent\n"
			+ "5: Ram\n"
			+ "6: Statue\n"
			+ "7: Worm\n"
			+ "8: Gunner\n"
			+ "9: Tank",
			16);
		spawnGuideText.camera = hudCamera;
		spawnGuideText.setFormat(null, weaponText.size, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		spawnGuideText.screenCenter(Y);
		spawnGuideText.x = FlxG.width - spawnGuideText.width;
		#if FLX_DEBUG
		spawnGuideText.ignoreDrawDebug = true;
		#end
		add(spawnGuideText);

		var healthBar:FlxBar = new FlxBar(0, 40, null, 300, 30, player, "health", 0, 10, true);
		healthBar.camera = hudCamera;
		healthBar.screenCenter(X);
		add(healthBar);

		camera.follow(player, SCREEN_BY_SCREEN, CAMERA_LERP);

		tilemap.follow(camera);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		// This has to be checked here instead of in Player.update() because update() is not called when Player is dead
		if (FlxG.keys.justPressed.SPACE #if !debug && !player.alive #end) {
			player.revive();
			// player.reset(0, 0);
			// player.screenCenter();
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
			newObj.tilemap = tilemap;
			removables.add(newObj);
		}
		if (FlxG.keys.justPressed.FIVE || (FlxG.keys.pressed.FIVE && FlxG.keys.pressed.SHIFT)) {
			var newObj:Enemy = new Ram(player.x, player.y);
			newObj.target = player;
			newObj.tilemap = tilemap;
			removables.add(newObj);
		}
		if (FlxG.keys.justPressed.SIX || (FlxG.keys.pressed.SIX && FlxG.keys.pressed.SHIFT)) {
			var newObj:Enemy = new Statue(player.x, player.y);
			newObj.target = player;
			newObj.tilemap = tilemap;
			removables.add(newObj);
		}
		if (FlxG.keys.justPressed.SEVEN || (FlxG.keys.pressed.SEVEN && FlxG.keys.pressed.SHIFT)) {
			var newObj:Worm = new Worm(player.x, player.y);
			newObj.target = player;
			newObj.tilemap = tilemap;
			removables.add(newObj.children);
			removables.add(newObj);
		}
		if (FlxG.keys.justPressed.EIGHT || (FlxG.keys.pressed.EIGHT && FlxG.keys.pressed.SHIFT)) {
			var newObj:Gunner = new Gunner(player.x, player.y);
			newObj.target = player;
			newObj.tilemap = tilemap;
			removables.add(newObj);
			weapons.push(newObj.weapon);
			removables.add(newObj.weapon);
		}
		if (FlxG.keys.justPressed.NINE || (FlxG.keys.pressed.NINE && FlxG.keys.pressed.SHIFT)) {
			var newObj:Tank = new Tank(player.x, player.y);
			newObj.target = player;
			newObj.tilemap = tilemap;
			removables.add(newObj);
			weapons.push(newObj.weapon);
			removables.add(newObj.weapon);
		}
		// I think I should save the ZERO key for something *really* big...

		// TODO Replace these arbitrary keybinds with buttons on the HUD or something
		if (FlxG.keys.justPressed.R) {
			for (physicsObject in removables) {
				physicsObject.destroy();
			}
			removables.clear();
			FlxArrayUtil.clearArray(weapons);
			for (weapon in player.weapons) {
				weapons.push(weapon);
			}
		}
		if (FlxG.keys.justPressed.B) {
			tilemap.exists = !tilemap.exists;
		}
		if (FlxG.keys.justPressed.F) {
			if (camera.target == null || camera.style != NO_DEAD_ZONE) {
				// Follow directly
				camera.follow(player, NO_DEAD_ZONE, CAMERA_LERP);
			} else {
				// Follow screenwise
				camera.follow(player, SCREEN_BY_SCREEN, CAMERA_LERP);
				// Reset the camera's position so it is not offset from where it should be
				@:privateAccess
				{
					camera._scrollTarget.zero();

					// var targetX:Float = camera.target.x + camera.targetOffset.x;
					// var targetY:Float = camera.target.y + camera.targetOffset.y;
					// while ((targetX >= (camera.scroll.x + camera.width) || targetX < camera.scroll.x)
					// 	|| (targetY >= (camera.scroll.y + camera.height) || targetY < camera.scroll.y)) {
					// 	if (targetX >= (camera.scroll.x + camera.width)) {
					// 		camera._scrollTarget.x += camera.width;
					// 	} else if (targetX < camera.scroll.x) {
					// 		camera._scrollTarget.x -= camera.width;
					// 	}

					// 	if (targetY >= (camera.scroll.y + camera.height)) {
					// 		camera._scrollTarget.y += camera.height;
					// 	} else if (targetY < camera.scroll.y) {
					// 		camera._scrollTarget.y -= camera.height;
					// 	}
					// }
				}
				camera.updateFollow();
			}
		}

		// Without this line, the collisions will only happen within the area what the camera would see if it was at (0, 0), and nowhere else
		// However, this only matters if the camera is being moved around by code like "camera.follow(player, NO_DEAD_ZONE)". If not, it's better to just comment this out.
		// FlxG.worldBounds.setPosition(camera.scroll.x, camera.scroll.y);
		if (tilemap.exists) {
			tilemap.getBounds(FlxG.worldBounds);
		} else {
			FlxG.worldBounds.set(camera.scroll.x, camera.scroll.y, FlxG.width + 20,
				FlxG.height + 20); // The "+ 20"s are from the FlxG class; those are the default dimensions
		}

		for (weapon in weapons) {
			weapon.bounds.copyFrom(FlxG.worldBounds);
			weapon.bulletsOverlap(tilemap); // This lets bullets call kill() on themselves when they overlap with the tilemap
		}
		collide(physicsObjects, physicsObjects, collideNotify);
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
		weapons = FlxDestroyUtil.destroyArray(weapons);
		tilemap = FlxDestroyUtil.destroy(tilemap);
		player = FlxDestroyUtil.destroy(player);
		physicsObjects = FlxDestroyUtil.destroy(physicsObjects);
		removables = FlxDestroyUtil.destroy(removables);
	}

	private function updateWeaponText():Void {
		weaponText.text = "Weapons:\n";
		for (i => weapon in player.weapons) {
			if (i == player.weaponIndex) {
				weaponText.text += "> ";
			}
			weaponText.text += weapon.name;

			if (weapon.useAmmo) {
				if (weapon.reloading) {
					weaponText.text += " (Reloading...)";
				} else {
					weaponText.text += " (Ammo: " + weapon.ammo + ")";
				}
			}

			if (weapon.nextFire > 0) {
				weaponText.text += " (" + FlxMath.roundDecimal(weapon.nextFire, 3) + " s)";
			}
			weaponText.text += "\n";
		}
		weaponText.screenCenter(Y);
	}
}
