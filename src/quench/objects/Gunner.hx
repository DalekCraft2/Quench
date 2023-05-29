package quench.objects;

import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import quench.weapons.QuenchWeapon;
import quench.weapons.Revolver;

/**
 * https://youtu.be/BvXIDUHUKLo?t=54
 */
// TODO Make the AI for this try to keep its distance from the Player instead of rushing at it
class Gunner extends Enemy {
	public var weapon:QuenchWeapon;

	public function new(?x:Float = 0, ?y:Float = 0) {
		super(x, y);

		loadEntityFrames(FlxColor.BROWN);

		initializeHealth(8);

		weapon = new Revolver(this);
		weapon.recoil = false;
		weapon.reload(); // Have it not start shooting immediately.
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (target != null && target.alive && canSee(target)) {
			weapon.fireAtTarget(target);
		}
	}

	override public function destroy():Void {
		super.destroy();

		weapon = FlxDestroyUtil.destroy(weapon);
	}
}
