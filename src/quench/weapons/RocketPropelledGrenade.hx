package quench.weapons;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.helpers.FlxBounds;

class RocketPropelledGrenade extends QuenchWeapon {
	public function new(parent:FlxSprite) {
		super("rocket_propelled_grenade", parent, ACCELERATION(new FlxBounds<Float>(1000, 1000), new FlxBounds<Float>(10000, 10000)), 20);
		bulletLifeSpan = new FlxBounds<Float>(3, 3);
		fireRate = 1;

		bulletColor = FlxColor.BROWN;
		bulletMass = 0.5;
		bulletDamage = 5;
		fireShakeIntensity = 0.003;
		fireShakeDuration = 0.2;
		hitShakeIntensity = 0.01;
		hitShakeDuration = 0.1;

		reloadTime = 1;
		maxAmmo = 1;
		ammo = maxAmmo;

		// hitSound = FlxG.sound.load("assets/audios/sounds/asplode.ogg");
	}
}
