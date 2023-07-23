package quench.objects;

import flixel.math.FlxPoint;
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

	override public function kill():Void {
		super.kill();

		if (weapon.weaponSprite != null) {
			weapon.weaponSprite.visible = false;
		}
	}

	override public function revive():Void {
		super.revive();

		if (weapon.weaponSprite != null) {
			weapon.weaponSprite.visible = true;
		}
	}

	override public function lookAtPoint(targetPoint:FlxPoint):Void {
		super.lookAtPoint(targetPoint);

		if (alive && weapon.weaponSprite != null) {
			var midpoint:FlxPoint = getMidpoint();

			if (midpoint.distanceTo(targetPoint) != 0) {
				var angle:Float = midpoint.degreesTo(targetPoint);

				weapon.weaponSprite.angle = angle;
				weapon.weaponSprite.flipY = angle > 90 || angle < -90;
			}

			midpoint.put();
		}
	}
}
