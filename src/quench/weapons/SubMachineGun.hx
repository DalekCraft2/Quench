package quench.weapons;

import flixel.FlxSprite;
import flixel.util.helpers.FlxBounds;

class SubMachineGun extends QuenchWeapon {
	public function new(parent:FlxSprite) {
		super("submachine_gun", parent, SPEED(new FlxBounds<Float>(500, 500)), 12);

		bulletLifeSpan = new FlxBounds<Float>(2, 2);
		fireRate = 0.1;

		bulletMass = 0.1;
		bulletDamage = 1;
		fireShakeIntensity = 0.001;
		fireShakeDuration = 0.1;

		reloadTime = 1;
		maxAmmo = 50;
		ammo = maxAmmo;
	}
}
