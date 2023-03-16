package quench.objects;

import flixel.math.FlxPoint;

// TODO Add idle behavior for when there is no target
class Enemy extends Entity {
	public var target:Entity;

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (target != null && target.alive) {
			lookAt(target);
			destinationPoint.copyFrom(target.getMidpoint(FlxPoint.weak()));
		}

		updateDirectionalAcceleration();
	}

	override public function destroy():Void {
		super.destroy();

		target = null;
	}

	override private function updateDirectionalAcceleration():Void {
		if (target == null || !target.alive) {
			getMidpoint(destinationPoint);
		} else {
			target.getMidpoint(destinationPoint);
		}

		super.updateDirectionalAcceleration();
	}
}
