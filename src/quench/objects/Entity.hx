package quench.objects;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.tile.FlxTilemap;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDirectionFlags;
import haxe.io.Path;

class Entity extends PhysicsObject {
	public var fieldOfView:Float = 60;

	private var directionalAcceleration:FlxPoint = FlxPoint.get();
	private var destinationPoint:FlxPoint = FlxPoint.get();
	private var entityMovementSpeed:Float = 1;
	/* FIXME This might be a HaxeFlixel bug, but, when noAcceleration is true and I push Enemies like Opponent against the left wall, they can't move away from the wall.
		I feel like it might be related to collisionDrag, and that has a bug of only having effects on objects when the Player pushes them from the right or from the bottom. */
	private var noAcceleration:Bool = false;

	public function new(?x:Float = 0, ?y:Float = 0, ?simpleGraphic:FlxGraphicAsset) {
		super(x, y, simpleGraphic);

		setFacingFlip(RIGHT, false, false);
		setFacingFlip(LEFT, true, false);
		setFacingFlip(DOWN, false, false);
		setFacingFlip(UP, false, true);
		setFacingFlip(RIGHT.with(DOWN), false, false);
		setFacingFlip(LEFT.with(DOWN), true, false);
		setFacingFlip(RIGHT.with(UP), false, true);
		setFacingFlip(LEFT.with(UP), true, true);
	}

	override public function destroy():Void {
		super.destroy();

		directionalAcceleration = FlxDestroyUtil.put(directionalAcceleration);
		destinationPoint = FlxDestroyUtil.put(destinationPoint);
	}

	public function canSee(entity:Entity):Bool {
		var midpoint:FlxPoint = getMidpoint();
		var targetMidpoint:FlxPoint = entity.getMidpoint();
		var angle:Float = midpoint.degreesTo(targetMidpoint);
		var facingAngle:Float = facing.degrees;
		if (angle >= facingAngle - fieldOfView / 2 && angle <= facingAngle + fieldOfView / 2) {
			return true;
		} else if (facing == LEFT) { // LEFT's angle is both 180 and -180
			facingAngle = -180;
			if (angle >= facingAngle - fieldOfView / 2 && angle <= facingAngle + fieldOfView / 2) {
				return true;
			}
		}
		midpoint.put();
		targetMidpoint.put();
		return false;
	}

	// TODO Make this not happen instantly and instead happen gradually for NPCs
	public function lookAt(target:Entity):Void {
		if (alive) {
			var midpoint:FlxPoint = getMidpoint();
			var targetMidpoint:FlxPoint = target.getMidpoint();

			facing = NONE;
			if (midpoint.distanceTo(targetMidpoint) != 0) {
				var angle:Float = midpoint.degreesTo(targetMidpoint);

				var facingValues:Array<FlxDirectionFlags> = [
					RIGHT,
					RIGHT.with(DOWN),
					DOWN,
					LEFT.with(DOWN),
					LEFT,
					LEFT.with(UP),
					UP,
					UP.with(RIGHT)
				];

				for (facingValue in facingValues) {
					var facingAngle:Float = facingValue.degrees;
					if (angle >= facingAngle - 45 / 2 && angle <= facingAngle + 45 / 2) {
						facing = facingValue;
						break;
					} else if (facingValue == LEFT) { // LEFT's angle is both 180 and -180
						facingAngle = -180;
						if (angle >= facingAngle - 45 / 2 && angle <= facingAngle + 45 / 2) {
							facing = facingValue;
							break;
						}
					}
				}
			}

			midpoint.put();
			targetMidpoint.put();
		}
	}

	public function lookAtPoint(targetPoint:FlxPoint):Void {
		if (alive) {
			var midpoint:FlxPoint = getMidpoint();
			if (midpoint.distanceTo(targetPoint) != 0) {
				var angle:Float = midpoint.degreesTo(targetPoint);

				facing = NONE;
				var facingValues:Array<FlxDirectionFlags> = [
					RIGHT,
					RIGHT.with(DOWN),
					DOWN,
					LEFT.with(DOWN),
					LEFT,
					LEFT.with(UP),
					UP,
					UP.with(RIGHT)
				];

				for (facingValue in facingValues) {
					var facingAngle:Float = facingValue.degrees;
					if (angle >= facingAngle - 45 / 2 && angle <= facingAngle + 45 / 2) {
						facing = facingValue;
						break;
					} else if (facingValue == LEFT) { // LEFT's angle is both 180 and -180
						facingAngle = -180;
						if (angle >= facingAngle - 45 / 2 && angle <= facingAngle + 45 / 2) {
							facing = facingValue;
							break;
						}
					}
				}
			}

			midpoint.put();
		}
	}

	private function updateDirectionalAcceleration():Void {
		if (noAcceleration) {
			velocity.zero();
		} else {
			acceleration.subtractPoint(directionalAcceleration);
		}
		directionalAcceleration.zero();
		if (alive) {
			if (!destinationPoint.equals(getMidpoint(FlxPoint.weak()))) {
				var midpoint:FlxPoint = getMidpoint();
				directionalAcceleration.set(1, 0);
				directionalAcceleration.degrees = midpoint.degreesTo(destinationPoint);
				// Make the acceleration constant regardless of direction
				directionalAcceleration.length = entityMovementSpeed * PhysicsObject.MOTION_FACTOR;
				if (noAcceleration) {
					if (path == null) {
						velocity.copyFrom(directionalAcceleration);
					} else {
						// TODO Make this code not awful
						// TODO Figure out whether it is possible to use FlxPath with acceleration instead of velocity, for Enemies other than Worm and Tank (which both use pathfinding)
						var state:PlayState = cast FlxG.state;
						@:privateAccess var tilemap:FlxTilemap = state.tilemap;
						var pathPoints:Array<FlxPoint> = tilemap.findPath(midpoint, destinationPoint, RAY_BOX(width, height));
						path.start(pathPoints, entityMovementSpeed * PhysicsObject.MOTION_FACTOR);
					}
				} else {
					acceleration.addPoint(directionalAcceleration);
				}
				midpoint.put();
			} else if (path != null && path.active) {
				// Make the Entity stop moving
				path.active = false;
				// Make the Entity not instantly teleport to the end of the current path if path.start() is called again
				FlxArrayUtil.clearArray(path.nodes);
			}
		}
	}

	private function loadEntityFrames(color:FlxColor = FlxColor.WHITE):Void {
		loadGraphic(Path.join(["assets", "images", Path.withExtension("entity", "png")]), true, 40, 40);
		this.color = color;
	}

	override private function set_facing(value:FlxDirectionFlags):FlxDirectionFlags {
		super.set_facing(value);

		if (animation != null) {
			if (facing == NONE || facing == ANY || facing == WALL) {
				animation.frameIndex = 0;
			} else if (facing == LEFT || facing == RIGHT && !(facing == LEFT && facing == RIGHT)) {
				animation.frameIndex = 1;
			} else if (facing == UP || facing == DOWN && !(facing == UP && facing == DOWN)) {
				animation.frameIndex = 2;
			} else if (facing == LEFT.with(UP) || facing == RIGHT.with(UP) || facing == LEFT.with(DOWN) || facing == RIGHT.with(DOWN)) {
				animation.frameIndex = 3;
			} else {
				animation.frameIndex = 0;
			}
		}

		return value;
	}
}
