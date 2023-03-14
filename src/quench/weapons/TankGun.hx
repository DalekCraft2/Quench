package quench.weapons;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.helpers.FlxBounds;

class TankGun extends QuenchWeapon {
	public function new(parent:FlxSprite) {
		super("tank_gun", parent, SPEED(new FlxBounds<Float>(1000, 1000)), 30);
		bulletLifeSpan = new FlxBounds<Float>(3, 3);
		fireRate = 4000;

		bulletColor = FlxColor.BROWN;
		bulletMass = 1;
		bulletDamage = 10;
		fireShakeIntensity = 0.003;
		fireShakeDuration = 0.2;
		hitShakeIntensity = 0.02;
		hitShakeDuration = 0.5;
	}
}
