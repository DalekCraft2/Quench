package quench.objects;

import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.tile.FlxBaseTilemap;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDirectionFlags;
import haxe.io.Path;

class Entity extends PhysicsObject {
	private static final pathfinder:BigMoverPathfinder = new BigMoverPathfinder(1, 1);

	public var tilemap:FlxTilemap;

	/**
	 * Field of view of this entity, in degrees.
	 */
	public var fieldOfView:Float = 60;

	private var directionalAcceleration:FlxPoint = FlxPoint.get();
	private var destinationPoint:FlxPoint = FlxPoint.get();
	private var entityMovementSpeed:Float = 1;
	/* FIXME This might be a HaxeFlixel bug, but, when useAcceleration is false and I push Enemies like Opponent against the left wall, they can't move away from the wall.
		I feel like it might be related to collisionDrag, and that has a bug of only having effects on objects when the Player pushes them from the right or from the bottom. */
	@:isVar
	private var useAcceleration(get, set):Bool = true;
	private var usePathfinding:Bool = false;

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

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		updateDestinationPoint();
		updateDirectionalAcceleration();
	}

	override public function destroy():Void {
		super.destroy();

		tilemap = null; // Do not destroy
		directionalAcceleration = FlxDestroyUtil.put(directionalAcceleration);
		destinationPoint = FlxDestroyUtil.put(destinationPoint);
	}

	public function canSee(entity:Entity, useFov:Bool = true):Bool {
		var midpoint:FlxPoint = getMidpoint();
		var targetMidpoint:FlxPoint = entity.getMidpoint();
		if (tilemap != null && tilemap.ray(midpoint, targetMidpoint)) {
			if (useFov) {
				var angle:Float = midpoint.degreesTo(targetMidpoint);
				midpoint.put();
				targetMidpoint.put();
				var facingAngle:Float = facing.degrees;
				if (angle >= facingAngle - fieldOfView / 2 && angle <= facingAngle + fieldOfView / 2) {
					return true;
				} else if (facing == LEFT) { // LEFT's angle is both 180 and -180
					facingAngle = -180;
					if (angle >= facingAngle - fieldOfView / 2 && angle <= facingAngle + fieldOfView / 2) {
						return true;
					}
				}
			} else {
				midpoint.put();
				targetMidpoint.put();
				return true;
			}
		}
		return false;
	}

	// TODO Make this not happen instantly and instead happen gradually for NPCs
	public function lookAt(target:Entity):Void {
		var targetMidpoint:FlxPoint = target.getMidpoint();
		lookAtPoint(targetMidpoint);
		targetMidpoint.put();
	}

	public function lookAtPoint(targetPoint:FlxPoint):Void {
		if (alive) {
			var midpoint:FlxPoint = getMidpoint();

			facing = NONE;
			if (midpoint.distanceTo(targetPoint) != 0) {
				var angle:Float = midpoint.degreesTo(targetPoint);

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

	private function updateDestinationPoint():Void {}

	private function updateDirectionalAcceleration():Void {
		// if (path != null && path.nodes.length > 0 && !path.finished) {
		// 	return;
		// }
		if (useAcceleration) {
			acceleration.zero();
		} else {
			velocity.zero();
		}
		directionalAcceleration.zero();
		if (path != null) {
			path.cancel();
		}
		if (alive) {
			var midpoint:FlxPoint = getMidpoint();
			if (!destinationPoint.equals(midpoint)) {
				directionalAcceleration.set(1, 0);
				directionalAcceleration.degrees = midpoint.degreesTo(destinationPoint);
				// Make the acceleration constant regardless of direction
				directionalAcceleration.length = entityMovementSpeed * PhysicsObject.MOTION_FACTOR;

				if (usePathfinding && path != null && tilemap != null) {
					pathfinder.widthInTiles = Math.ceil(tilemap.tileWidth / width);
					pathfinder.heightInTiles = Math.ceil(tilemap.tileHeight / height);
					var pathPoints:Array<FlxPoint> = pathfinder.findPath(cast tilemap, midpoint, destinationPoint, RAY_BOX(width, height));
					path.start(pathPoints, entityMovementSpeed * PhysicsObject.MOTION_FACTOR);
				} else {
					if (useAcceleration) {
						acceleration.copyFrom(directionalAcceleration);
					} else {
						velocity.copyFrom(directionalAcceleration);
					}
				}
			}
			midpoint.put();
		}
	}

	private function loadEntityFrames(color:FlxColor = FlxColor.WHITE, spriteName:String = "entity", size:Int = 40):Void {
		loadGraphic(Path.join(["assets/images/sprites", Path.withExtension(spriteName, "png")]), true, size, size);
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

	private function get_useAcceleration():Bool {
		return useAcceleration;
	}

	private function set_useAcceleration(value:Bool):Bool {
		useAcceleration = value;
		return value;
	}
}
