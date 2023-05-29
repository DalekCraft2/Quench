package quench.objects;

import flixel.system.FlxAssets.FlxGraphicAsset;

// TODO Add idle behavior for when there is no target
class Enemy extends Entity {
	public var target:Entity;

	public function new(?x:Float = 0, ?y:Float = 0, ?simpleGraphic:FlxGraphicAsset) {
		super(x, y, simpleGraphic);

		path = new AccelerationPath();
		usePathfinding = true;
	}

	override public function destroy():Void {
		super.destroy();

		target = null;
	}

	override private function updateDestinationPoint():Void {
		super.updateDestinationPoint();

		if (target == null || !target.alive /*|| !canSee(target, false)*/) {
			getMidpoint(destinationPoint);
		} else {
			// lookAt(target);
			target.getMidpoint(destinationPoint);
		}
		lookAtPoint(destinationPoint);
	}

	override private function set_useAcceleration(value:Bool):Bool {
		super.set_useAcceleration(value);
		if (path != null && path is AccelerationPath) {
			cast(path, AccelerationPath).useAcceleration = value;
		}
		return value;
	}
}
