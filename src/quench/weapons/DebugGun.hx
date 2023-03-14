package quench.weapons;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.helpers.FlxBounds;

class DebugGun extends QuenchWeapon {
	public function new(parent:FlxSprite) {
		super("debug_gun", parent, SPEED(new FlxBounds<Float>(1000, 1000)), 16);

		bulletLifeSpan = new FlxBounds<Float>(2, 2);
		fireRate = 0;

		recoil = false;
		bulletColor = FlxColor.RED;
		bulletMass = 0.5;
		bulletDamage = 1;
		fireShakeIntensity = 0.001;
		fireShakeDuration = 0.1;
	}
}
