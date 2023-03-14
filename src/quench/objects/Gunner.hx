package quench.objects;

import flixel.FlxG;
import flixel.util.FlxColor;
import quench.weapons.QuenchWeapon;
import quench.weapons.Revolver;

/**
 * https://youtu.be/BvXIDUHUKLo?t=54
 */
class Gunner extends Enemy {
	public var weapon:QuenchWeapon;

	public function new(?x:Float = 0, ?y:Float = 0) {
		super(x, y, FlxG.bitmap.create(40, 40, FlxColor.BROWN));

		health = 8;

		weapon = new Revolver(this);
		weapon.recoil = false;
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (target != null && target.alive) {
			weapon.fireAtTarget(target);
		}
	}
}
