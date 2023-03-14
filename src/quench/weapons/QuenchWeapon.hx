package quench.weapons;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.weapon.FlxBullet;
import flixel.addons.weapon.FlxWeapon;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.util.helpers.FlxBounds;

// TODO Add Davy Crockett.
// TODO Make sprites for the weapons and have them show up aiming at where the AI/Player is aiming
class QuenchWeapon extends FlxTypedWeapon<FlxBullet> {
	public var recoil:Bool = true;
	public var fireShakeIntensity:Float;
	public var fireShakeDuration:Float;
	public var hitShakeIntensity:Float;
	public var hitShakeDuration:Float;
	public var bulletColor:FlxColor = FlxColor.BLACK;
	public var bulletMass:Float;
	public var bulletDamage:Float;

	public function new(name:String, parent:FlxSprite, speedMode:FlxWeaponSpeedMode, bulletSize:Int) {
		super(name, (weapon:FlxWeapon) -> {
			var bullet:FlxBullet = new FlxBullet();
			bullet.makeGraphic(bulletSize, bulletSize, bulletColor);
			bullet.mass = bulletMass;
			return bullet;
		},
			PARENT(parent, new FlxBounds(FlxPoint.get(parent.width / 2 - bulletSize / 2, parent.height / 2 - bulletSize / 2))), speedMode);

		setPostFireCallback(() -> {
			doRecoil();

			currentBullet.camera.shake(fireShakeIntensity, fireShakeDuration);
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
		currentBullet.camera.shake(hitShakeIntensity, hitShakeDuration);

		if (!(object is FlxTilemap)) { // Don't damage the FlxTilemap
			// TODO Do something with the dead unused entities in PlayState so they don't take up memory and space in the groups
			object.hurt(bulletDamage);
		}
	}

	private function doRecoil():Void {
		if (recoil) {
			// You tend to twist your elbow to absorb the recoeeeel. That's more of a revolver technique.
			// Though that was some fancy shooting. You're pretty good!
			var recoilVector:FlxPoint = currentBullet.velocity.scaleNew(currentBullet.mass);
			parent.velocity.subtractPoint(recoilVector); // Recoil.
			recoilVector.put();
		}
	}
}
