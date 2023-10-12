package quench.weapons;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.particles.FlxEmitter;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDirectionFlags;
import flixel.util.helpers.FlxBounds;

class TankGun extends QuenchWeapon {
	private var emitter:FlxEmitter = new FlxEmitter();

	public function new(parent:FlxSprite) {
		super("tank_gun", parent, SPEED(new FlxBounds<Float>(1000, 1000)), 30);
		bulletLifeSpan = new FlxBounds<Float>(3, 3);
		fireRate = 4;

		bulletColor = FlxColor.BROWN;
		bulletMass = 1;
		bulletDamage = 10;
		fireShakeIntensity = 0.003;
		fireShakeDuration = 0.2;
		hitShakeIntensity = 0.02;
		hitShakeDuration = 0.5;

		reloadTime = 4;
		maxAmmo = 1;
		ammo = maxAmmo;

		emitter.setSize(bulletSize, bulletSize);
		emitter.speed.set(500);
		emitter.elasticity.set(0.3);
		emitter.makeParticles(6, 6, bulletColor);
		emitter.solid = true;
		emitter.lifespan.set(2);
		add(emitter);

		// hitSound = FlxG.sound.load("assets/audios/sounds/asplode.ogg");
	}

	override public function destroy() {
		super.destroy();

		emitter = FlxDestroyUtil.destroy(emitter);
	}

	override public function bulletsOverlap(objectOrGroup:FlxBasic, ?notifyCallBack:FlxObject->FlxObject->Void, skipParent = true):Void {
		super.bulletsOverlap(objectOrGroup, notifyCallBack, skipParent);
		if (emitter != null && emitter.length > 0) {
			FlxG.overlap(objectOrGroup, emitter, notifyCallBack != null ? notifyCallBack : onShellPieceHit, shouldBulletHit);
		}
	}

	override private function onBulletHit(object:FlxObject, bullet:FlxObject):Void {
		super.onBulletHit(object, bullet);

		var touching:FlxDirectionFlags = bullet.touching;
		if (touching != NONE) {
			emitter.launchAngle.set(touching.degrees - 270, touching.degrees + 270);
		}
		emitter.setPosition(bullet.x, bullet.y);
		emitter.start(true);
	}

	private function onShellPieceHit(object:FlxObject, shellPiece:FlxObject):Void {
		if (!(object is FlxTilemap)) { // Don't damage the FlxTilemap
			shellPiece.kill();
			object.hurt(0.5);
		}
	}
}
