package quench.weapons;

import flixel.FlxSprite;
import flixel.util.helpers.FlxBounds;

class Revolver extends QuenchWeapon {
	public function new(parent:FlxSprite) {
		super("revolver", parent, SPEED(new FlxBounds<Float>(500, 500)), 16);

		bulletLifeSpan = new FlxBounds<Float>(2, 2);
		fireRate = 0.2;

		bulletMass = 0.3;
		bulletDamage = 2;
		fireShakeIntensity = 0.003;
		fireShakeDuration = 0.1;

		reloadTime = 1.5;
		maxAmmo = 6;
		ammo = maxAmmo;
	}
}
