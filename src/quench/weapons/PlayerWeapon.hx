package quench.weapons;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.weapon.FlxBullet;
import flixel.addons.weapon.FlxWeapon;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.helpers.FlxBounds;

class PlayerWeapon extends FlxTypedWeapon<FlxBullet> {
	public function new(parent:FlxSprite) {
		var bulletSize:FlxPoint = FlxPoint.get(16, 16);
		super("default_weapon", (weapon:FlxWeapon) -> {
			var bullet:FlxBullet = new FlxBullet();
			bullet.makeGraphic(Std.int(bulletSize.x), Std.int(bulletSize.y), FlxColor.BLACK);
			bullet.mass = 0.1;
			return bullet;
		},
			PARENT(parent, new FlxBounds(FlxPoint.get(parent.width / 2 - bulletSize.x / 2, parent.height / 2 - bulletSize.y / 2))),
			SPEED(new FlxBounds<Float>(500, 500)));
		bulletLifeSpan = new FlxBounds<Float>(2, 2);
		// bulletSize.put(); // We can't do this because this FlxPoint gets reused in the bullet factory whenever the weapon is used.

		// fireRate = 100; // 100 ms between each shot
		skipParentCollision = true;

		setPostFireCallback(() -> {
			// You tend to twist your elbow to absorb the recoeeeel. That's more of a revolver technique.
			// Though that was some fancy shooting. You're pretty good!
			var recoil:FlxPoint = currentBullet.velocity.scaleNew(currentBullet.mass);
			parent.velocity.subtractPoint(recoil); // Recoil.
			recoil.put();
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

		// TODO Do something with the dead unused entities in PlayState so they don't take up memory and space in the groups
		object.hurt(1);
	}
}
