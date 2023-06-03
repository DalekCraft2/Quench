package quench.weapons;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.helpers.FlxBounds;
import quench.weapons.FlxWeapon.FlxWeaponFireMode;

class MedKit extends QuenchWeapon {
	public function new(parent:FlxSprite) {
		// It feels wrong to not capitalize the "K" in "MedKit", but it also feels wrong to add an underscore in-between "med" and "kit" for the ID...
		super("medkit", parent, SPEED(new FlxBounds<Float>(0, 0)), 16);

		bulletLifeSpan = new FlxBounds<Float>(0, 0);
		fireRate = 0;

		recoil = false;
		useAmmo = false;
	}

	override private function runFire(mode:FlxWeaponFireMode):Bool {
		parent.hurt(-FlxG.elapsed);
		return true;
	}
}
