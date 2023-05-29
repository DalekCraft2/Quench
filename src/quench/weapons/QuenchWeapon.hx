package quench.weapons;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.weapon.FlxBullet;
import flixel.addons.weapon.FlxWeapon;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxTimer;
import flixel.util.helpers.FlxBounds;

// TODO Add Davy Crockett.
// TODO Make sprites for the weapons and have them show up aiming at where the AI/Player is aiming
// TODO Use FlxEmitter to make impact particles for bullets what explode
class QuenchWeapon extends FlxTypedWeapon<FlxBullet> implements IFlxDestroyable {
	public var recoil:Bool = true;
	public var fireShakeIntensity:Float;
	public var fireShakeDuration:Float;
	public var hitShakeIntensity:Float;
	public var hitShakeDuration:Float;
	public var bulletColor:FlxColor = FlxColor.BLACK;
	public var bulletMass:Float;
	public var bulletDamage:Float;
	public var useAmmo:Bool = true;
	public var ammo:Int;
	public var maxAmmo:Int;
	public var reloading:Bool;
	public var reloadTime:Float;
	public var fireTimer:FlxTimer;

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

			if (fireShakeIntensity > 0) {
				currentBullet.camera.shake(fireShakeIntensity, fireShakeDuration);
			}

			if (useAmmo) {
				ammo--;
				if (ammo <= 0) {
					reload();
				}
			}
		});

		// fireTimer.onComplete = (tmr:FlxTimer) -> {
		// 	if (reloading) {
		// 		reloading = false;
		// 	}
		// };
		fireTimer = new FlxTimer().start(fireRate, (tmr:FlxTimer) -> {
			if (reloading) {
				reloading = false;
			}
		});
		fireTimer.cancel();
	}

	override private function runFire(mode:FlxWeaponFireMode):Bool {
		if (fireRate > 0 && !fireTimer.finished) {
			return false;
		}

		if (onPreFireCallback != null) {
			onPreFireCallback();
		}

		#if FLX_SOUND_SYSTEM
		if (onPreFireSound != null) {
			onPreFireSound.play();
		}
		#end

		fireTimer.reset(fireRate / 1000);

		// Get a free bullet from the pool
		currentBullet = group.recycle(null, bulletFactory.bind(this));
		if (currentBullet == null) {
			return false;
		}

		// Clear any velocity that may have been previously set from the pool
		currentBullet.velocity.zero(); // TODO is this really necessary?

		switch (fireFrom) {
			case PARENT(parent, offset, useParentAngle, angleOffset):
				// store new offset in a new variable
				var actualOffset = FlxPoint.get(FlxG.random.float(offset.min.x, offset.max.x), FlxG.random.float(offset.min.y, offset.max.y));
				if (useParentAngle) {
					// rotate actual offset around parent origin using the parent angle
					// rotatePoints(actualOffset, parent.origin, parent.angle, actualOffset);
					var newActualOffset:FlxPoint = rotatePoints(actualOffset, parent.origin, parent.angle);
					actualOffset.put();
					actualOffset = newActualOffset;

					// reposition offset to have its origin at the new returned point
					actualOffset.subtract(currentBullet.width / 2, currentBullet.height / 2);
					actualOffset.subtract(parent.offset.x, parent.offset.y);
				}

				currentBullet.last.x = currentBullet.x = parent.x + actualOffset.x;
				currentBullet.last.y = currentBullet.y = parent.y + actualOffset.y;

				actualOffset.put();

			case POSITION(position):
				currentBullet.last.x = currentBullet.x = FlxG.random.float(position.min.x, position.max.x);
				currentBullet.last.y = currentBullet.y = FlxG.random.float(position.min.y, position.max.y);
		}

		currentBullet.exists = true;
		@:privateAccess currentBullet.bounds = bounds;
		currentBullet.elasticity = bulletElasticity;
		currentBullet.lifespan = FlxG.random.float(bulletLifeSpan.min, bulletLifeSpan.max);

		switch (mode) {
			case FIRE_AT_POSITION(x, y):
				internalFireAtPoint(currentBullet, FlxPoint.weak(x, y));

			case FIRE_AT_TARGET(target):
				internalFireAtPoint(currentBullet, target.getPosition(FlxPoint.weak()));

			case FIRE_FROM_ANGLE(angle):
				internalFireFromAngle(currentBullet, FlxG.random.float(angle.min, angle.max));

			case FIRE_FROM_PARENT_ANGLE(angle):
				internalFireFromAngle(currentBullet, parent.angle + FlxG.random.float(angle.min, angle.max));

			case FIRE_FROM_PARENT_FACING(angle):
				internalFireFromAngle(currentBullet, parent.facing.degrees + FlxG.random.float(angle.min, angle.max));

			#if FLX_TOUCH
			case FIRE_AT_TOUCH(touch):
				internalFireAtPoint(currentBullet, touch.getPosition(FlxPoint.weak()));
			#end

			#if FLX_MOUSE
			case FIRE_AT_MOUSE:
				internalFireAtPoint(currentBullet, FlxG.mouse.getPosition(FlxPoint.weak()));
			#end
		}

		if (currentBullet.animation.getByName("fire") != null) {
			currentBullet.animation.play("fire");
		}

		// Post fire stuff
		if (onPostFireCallback != null) {
			onPostFireCallback();
		}

		#if FLX_SOUND_SYSTEM
		if (onPostFireSound != null) {
			onPostFireSound.play();
		}
		#end

		return true;
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
			// TODO Do something with the dead unused entities in PlayState so they don't take up memory and space in the groups
			object.hurt(bulletDamage);
		}
	}

	public function reload():Void {
		if (useAmmo) {
			ammo = maxAmmo;
			fireTimer.reset(reloadTime / 1000);
			reloading = true;
		}
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

	public function destroy():Void {
		name = null;
		group = FlxDestroyUtil.destroy(group);
		bounds = FlxDestroyUtil.put(bounds);
		parent = null; // Don't destroy the parent
		positionOffset = FlxDestroyUtil.put(positionOffset);
		// if (positionOffsetBounds != null) {
		// 	positionOffsetBounds.min = FlxDestroyUtil.put(positionOffsetBounds.min);
		// 	positionOffsetBounds.max = FlxDestroyUtil.put(positionOffsetBounds.max);
		// 	positionOffsetBounds = null;
		// }
		if (firePosition != null) {
			firePosition.min = FlxDestroyUtil.put(firePosition.min);
			firePosition.max = FlxDestroyUtil.put(firePosition.max);
			firePosition = null;
		}
		if (fireFrom != null) {
			switch (fireFrom) {
				case PARENT(parent, offset, useParentAngle, angleOffset):
					parent = null;
					if (offset != null) {
						offset.min = FlxDestroyUtil.put(offset.min);
						offset.max = FlxDestroyUtil.put(offset.max);
						offset = null;
					}
					angleOffset = null;
				case POSITION(position):
					if (position != null) {
						position.min = FlxDestroyUtil.put(position.min);
						position.max = FlxDestroyUtil.put(position.max);
						position = null;
					}
			}
			// fireFrom = null; // Can't do this because sending null to set_fireFrom() causes an NPE
			@:bypassAccessor fireFrom = null;
		}
		if (speedMode != null) {
			switch (speedMode) {
				case SPEED(speed):
					speed = null;
				case ACCELERATION(acceleration, maxSpeed):
					acceleration = null;
					maxSpeed = null;
			}
			speedMode = null;
		}
		bulletLifeSpan = null;
		currentBullet = FlxDestroyUtil.destroy(currentBullet);
		onPreFireCallback = null;
		onPostFireCallback = null;
		onPreFireSound = null;
		onPostFireSound = null;
		bulletFactory = null;

		fireTimer = FlxDestroyUtil.destroy(fireTimer);
	}
}
