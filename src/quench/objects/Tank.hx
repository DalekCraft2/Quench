package quench.objects;

import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import quench.weapons.QuenchWeapon;
import quench.weapons.TankGun;

class Tank extends Enemy {
	public var weapon:QuenchWeapon;

	public function new(?x:Float = 0, ?y:Float = 0) {
		super(x, y);

		loadEntityFrames(FlxColor.WHITE, "tank", 80);

		mass = 20;
		elasticity = 0.2;
		initializeHealth(50);
		entityMovementSpeed = 0.5;

		weapon = new TankGun(this);
		weapon.reload(); // I do not want to instantly die when spawning this thing.
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
