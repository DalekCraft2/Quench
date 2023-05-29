package quench.objects;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDirectionFlags;
import flixel.util.FlxTimer;

/**
 * My favorite AI so far, actually.
 */
// FIXME Ram's color tween sometimes gets cancelled and set to the darker purple before changing back to the magenta before it starts ramming
// It tends to only happen when multiple enemies are present in the world
class Ram extends Enemy {
	private var phase(default, set):RamPhase;

	private var timer:FlxTimer;
	private var dizzy:Bool = false;

	public function new(?x:Float = 0, ?y:Float = 0) {
		super(x, y);

		loadEntityFrames(FlxColor.PURPLE);

		initializeHealth(10);

		timer = new FlxTimer().start(4, (tmr:FlxTimer) -> {
			switch (phase) {
				case IDLE:
					phase = BACKING_UP;
				case BACKING_UP:
					phase = RAMMING;
				case RAMMING:
					phase = COOLDOWN;
				case COOLDOWN:
					phase = IDLE;
			}
		}, 0);
		mass = 2;
		elasticity = 0.3;
		maxVelocity.set(10000, 10000);

		phase = COOLDOWN;
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (alive) {
			if (target != null && target.alive && canSee(target) && timer.finished && phase == IDLE) {
				phase = BACKING_UP;
				timer.reset();
			}
		}
	}

	override public function destroy():Void {
		super.destroy();

		timer = FlxDestroyUtil.destroy(timer);
	}

	override private function updateDirectionalAcceleration():Void {
		if (phase != RAMMING) {
			super.updateDirectionalAcceleration();
		}
	}

	override private function updateDestinationPoint():Void {
		if (dizzy) {
			usePathfinding = false;
			var midPoint:FlxPoint = getMidpoint();
			destinationPoint.subtractPoint(midPoint);
			destinationPoint.radians += FlxG.elapsed * Math.PI;
			destinationPoint.addPoint(midPoint);
			midPoint.put();
			lookAtPoint(destinationPoint);
		} else if (phase != RAMMING) {
			super.updateDestinationPoint();
		}
	}

	public function shouldRamHit(object:FlxObject, ram:FlxObject):Bool {
		if (object is FlxTilemap) {
			return cast(object, FlxTilemap).overlapsWithCallback(ram);
		} else {
			return true;
		}
	}

	public function onRamHit(object:FlxObject, ram:FlxObject):Void {
		var ram:Ram = cast ram;
		if (ram.phase == RAMMING) {
			// Only deal damage and exit the ramming phase if coming into contact with a surface it is facing
			if (ram.justTouched(ram.facing)) {
				camera.shake(0.01, 0.15);
				cast(ram, Ram).phase = COOLDOWN;
				cast(ram, Ram).timer.reset();

				if (!(object is FlxTilemap)) { // Don't damage the FlxTilemap
					var ramMomentum:FlxPoint = ram.velocity.scaleNew(ram.mass);
					var objectMomentum:FlxPoint = object.velocity.scaleNew(object.mass);
					var combinedMomentum:FlxPoint = ramMomentum.clone().subtractPoint(objectMomentum).scale(1 / PhysicsObject.MOTION_FACTOR);
					object.hurt(combinedMomentum.length);
					ramMomentum.put();
					objectMomentum.put();
					combinedMomentum.put();
				} else {
					dizzy = true;
					destinationPoint.copyFrom(directionalAcceleration);
					destinationPoint.addPoint(getMidpoint(FlxPoint.weak()));
				}
			}
		}
	}

	private function set_phase(value:RamPhase):RamPhase {
		phase = value;
		switch (value) {
			case IDLE:
				dizzy = false;
				usePathfinding = true;
				entityMovementSpeed = 1;
				timer.cancel();
				FlxTween.color(this, 1, this.color, FlxColor.PURPLE);
			case BACKING_UP:
				usePathfinding = false;
				entityMovementSpeed = -1.5;
				timer.time = 1;
				FlxTween.color(this, 1, this.color, FlxColor.MAGENTA);
			case RAMMING:
				usePathfinding = false;
				entityMovementSpeed = 7;
				elasticity = 0;
				timer.time = 3;
				FlxTween.color(this, 1, this.color, FlxColor.MAGENTA);
				directionalAcceleration.normalize();
				directionalAcceleration.negate(); // Undo the effect caused by the -1.5 movement speed
				directionalAcceleration.scale(entityMovementSpeed * PhysicsObject.MOTION_FACTOR);
				acceleration.copyFrom(directionalAcceleration);
			case COOLDOWN:
				usePathfinding = true;
				entityMovementSpeed = 1;
				elasticity = 0.3;
				timer.time = 4;
				FlxTween.color(this, 1, this.color, FlxColor.PURPLE);
		}

		return value;
	}
}

enum RamPhase {
	IDLE;
	BACKING_UP; // I am not sure of whether there is a proper word for this...
	RAMMING;
	COOLDOWN;
}
