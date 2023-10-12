package quench.weapons;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import haxe.io.Path;
import quench.weapons.FlxWeapon;

// TODO Add Davy Crockett.
// TODO Use FlxEmitter to make impact particles for bullets what explode
// TODO Consider using weaponSprite as the parent instead of the entity what is using the weapon.
class QuenchWeapon extends FlxTypedWeapon<FlxBullet> {
	public var recoil:Bool = true;
	public var fireShakeIntensity:Float;
	public var fireShakeDuration:Float;
	public var hitShakeIntensity:Float;
	public var hitShakeDuration:Float;
	public var bulletColor:FlxColor = FlxColor.BLACK;
	public var bulletSize:Int;
	public var bulletMass:Float;
	public var bulletDamage:Float;
	public var useAmmo:Bool = true;
	public var ammo:Int;
	public var maxAmmo:Int;
	public var reloading:Bool;
	public var reloadTime:Float;
	public var hitSound:FlxSound;
	public var weaponSprite:FlxSprite;

	public function new(name:String, parent:FlxSprite, speedMode:FlxWeaponSpeedMode, bulletSize:Int) {
		this.bulletSize = bulletSize;

		super(name, (weapon:FlxWeapon) -> {
			var bullet:FlxBullet = new FlxBullet();
			bullet.makeGraphic(this.bulletSize, this.bulletSize, bulletColor);
			bullet.mass = bulletMass;
			return bullet;
		},
			PARENT(parent, FlxRect.get(parent.width / 2 - this.bulletSize / 2, parent.height / 2 - this.bulletSize / 2)), speedMode);

		setPostFireCallback(() -> {
			doRecoil();

			if (fireShakeIntensity > 0) {
				currentBullet.camera.shake(fireShakeIntensity, fireShakeDuration);
			}

			if (useAmmo) {
				ammo--;
				if (ammo <= 0) {
					reload();
				}
			}

			if (onPostFireSound != null) {
				onPostFireSound.proximity(parent.x, parent.y, FlxG.camera.target, 1000);
			}
		} // , FlxG.sound.load("assets/audios/sounds/shoot.ogg")
		);

		weaponSprite = new FlxSprite().loadGraphic(Path.join(["assets/images/sprites/weapons", Path.withExtension(this.name, "png")]));
		updateOffsets();
		weaponSprite.solid = false;
		add(weaponSprite);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (weaponSprite != null) {
			var parentMidpoint:FlxPoint = parent.getMidpoint();
			weaponSprite.setPosition(parentMidpoint.x, parentMidpoint.y);
			parentMidpoint.put();
		}

		if (nextFire <= 0 && reloading) {
			reloading = false;
		}
	}

	override public function destroy():Void {
		super.destroy();

		hitSound = null;
		weaponSprite = FlxDestroyUtil.destroy(weaponSprite);
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

		if (hitShakeIntensity > 0) {
			currentBullet.camera.shake(hitShakeIntensity, hitShakeDuration);
		}

		if (!(object is FlxTilemap)) { // Don't damage the FlxTilemap
			object.hurt(bulletDamage);
		}

		if (hitSound != null) {
			hitSound.proximity(currentBullet.x, currentBullet.y, FlxG.camera.target, 1000);
			hitSound.play();
		}
	}

	public function reload():Void {
		if (useAmmo) {
			ammo = maxAmmo;
			nextFire = reloadTime;
			reloading = true;
		}
	}

	public function updateOffsets():Void {
		switch (fireFrom) {
			case PARENT(parent, offset, useParentAngle, angleOffset):
				offset.set(parent.width / 2 - bulletSize / 2, parent.height / 2 - bulletSize / 2);
			case POSITION(position):
		}
		weaponSprite.offset.set(weaponSprite.width / 2 - parent.width, weaponSprite.height / 2);
		weaponSprite.origin.copyFrom(weaponSprite.offset);
	}

	private function doRecoil():Void {
		if (recoil) {
			// You tend to twist your elbow to absorb the recoeeeel. That's more of a revolver technique.
			// Though that was some fancy shooting. You're pretty good!
			var recoilVector:FlxPoint = currentBullet.velocity.scaleNew(currentBullet.mass / parent.mass);
			parent.velocity.subtractPoint(recoilVector); // Recoil.
			recoilVector.put();
		}
	}
}
