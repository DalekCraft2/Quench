package quench.weapons;

import flixel.FlxSprite;
import flixel.util.helpers.FlxBounds;

class MachineGun extends QuenchWeapon {
	public function new(parent:FlxSprite) {
		super("machine_gun", parent, SPEED(new FlxBounds<Float>(500, 500)), 12);

		bulletLifeSpan = new FlxBounds<Float>(2, 2);
		fireRate = 100;

		bulletMass = 0.1;
		bulletDamage = 1;
		fireShakeIntensity = 0.001;
		fireShakeDuration = 0.1;
	}
}
