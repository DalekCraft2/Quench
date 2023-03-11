package quench.weapons;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.weapon.FlxBullet;
import flixel.addons.weapon.FlxWeapon;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.helpers.FlxBounds;
import quench.objects.PhysicsObject;

class RocketPropelledGrenade extends FlxTypedWeapon<FlxBullet> {
	public function new(parent:FlxSprite) {
		var bulletSize:FlxPoint = FlxPoint.get(20, 20);
		super("rocket_propelled_grenade", (weapon:FlxWeapon) -> {
			var bullet:FlxBullet = new FlxBullet();
			bullet.makeGraphic(Std.int(bulletSize.x), Std.int(bulletSize.y), FlxColor.BROWN);
			bullet.mass = 0.5;
			return bullet;
		},
			PARENT(parent, new FlxBounds(FlxPoint.get(parent.width / 2 - bulletSize.x / 2, parent.height / 2 - bulletSize.y / 2))),
			ACCELERATION(new FlxBounds<Float>(1000, 1000), new FlxBounds<Float>(10000, 10000)));
		bulletLifeSpan = new FlxBounds<Float>(3, 3);
		// bulletSize.put(); // We can't do this because this FlxPoint gets reused in the bullet factory whenever the weapon is used.

		fireRate = 1000; // Time between each shot in milliseconds

		setPostFireCallback(() -> {
			// You tend to twist your elbow to absorb the recoeeeel. That's more of a revolver technique.
			// Though that was some fancy shooting. You're pretty good!
			var recoil:FlxPoint = currentBullet.velocity.scaleNew(currentBullet.mass);
			parent.velocity.subtractPoint(recoil); // Recoil.
			recoil.put();

			currentBullet.camera.shake(0.003, 0.2);
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
			object.hurt(5);
			currentBullet.camera.shake(0.01, 0.1);
		}
	}
}
