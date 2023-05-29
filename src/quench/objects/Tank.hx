package quench.objects;

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
}
