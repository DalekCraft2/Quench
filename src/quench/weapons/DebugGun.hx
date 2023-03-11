package quench.weapons;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.weapon.FlxBullet;
import flixel.addons.weapon.FlxWeapon;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.helpers.FlxBounds;
import quench.objects.PhysicsObject;

class DebugGun extends FlxTypedWeapon<FlxBullet> {
	public function new(parent:FlxSprite) {
		var bulletSize:FlxPoint = FlxPoint.get(16, 16);
		super("debug_gun", (weapon:FlxWeapon) -> {
			var bullet:FlxBullet = new FlxBullet();
			bullet.makeGraphic(Std.int(bulletSize.x), Std.int(bulletSize.y), FlxColor.RED);
			bullet.mass = 0.5;
			return bullet;
		},
			PARENT(parent, new FlxBounds(FlxPoint.get(parent.width / 2 - bulletSize.x / 2, parent.height / 2 - bulletSize.y / 2))),
			SPEED(new FlxBounds<Float>(1000, 1000)));
		bulletLifeSpan = new FlxBounds<Float>(2, 2);
		// bulletSize.put(); // We can't do this because this FlxPoint gets reused in the bullet factory whenever the weapon is used.

		fireRate = 0; // Time between each shot in milliseconds

		setPostFireCallback(() -> {
			// You tend to twist your elbow to absorb the recoeeeel. That's more of a revolver technique.
			// Though that was some fancy shooting. You're pretty good!
			// var recoil:FlxPoint = currentBullet.velocity.scaleNew(currentBullet.mass);
			// parent.velocity.subtractPoint(recoil); // Recoil.
			// recoil.put();
			// Just kidding. I absorbed the recoil.

			currentBullet.camera.shake(0.001, 0.1);
		});
	}

	override private function shouldBulletHit(object:FlxObject, bullet:FlxObject):Bool {
		if (object is FlxBullet) {
			return false;
		} else {
			return super.shouldBulletHit(object, bullet);
		}
	}

	override private function onBulletHit(object:FlxObject, bullet:FlxObject):Void {
		super.onBulletHit(object, bullet);

		if (object is PhysicsObject) { // Don't damage the FlxTilemap
			// TODO Do something with the dead unused entities in PlayState so they don't take up memory and space in the groups
			object.hurt(1); // I don't want high damage. The reason why I made this weapon was so I could pelt enemies in the face for as long as possible.
		}
	}
}
