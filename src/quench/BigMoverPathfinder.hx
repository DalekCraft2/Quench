package quench;

import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.path.FlxPathfinder.FlxDiagonalPathfinder;
import flixel.path.FlxPathfinder.FlxPathSimplifier;
import flixel.path.FlxPathfinder.FlxPathfinderData;
import flixel.path.FlxPathfinder.FlxTilemapDiagonalPolicy;
import flixel.tile.FlxBaseTilemap;
import flixel.util.FlxDirectionFlags;

class BigMoverPathfinder extends FlxDiagonalPathfinder {
	public var widthInTiles:Int;
	public var heightInTiles:Int;

	public function new(widthInTiles:Int, heightInTiles:Int, diagonalPolicy:FlxTilemapDiagonalPolicy = NONE) {
		this.widthInTiles = widthInTiles;
		this.heightInTiles = heightInTiles;
		super(diagonalPolicy);
	}

	override public function findPath(map:FlxBaseTilemap<FlxObject>, start:FlxPoint, end:FlxPoint, simplify:FlxPathSimplifier = LINE):Null<Array<FlxPoint>> {
		final offset:FlxPoint = FlxPoint.get((widthInTiles - 1) / 2 * map.width / map.widthInTiles, (heightInTiles - 1) / 2 * map.height / map.heightInTiles);
		// offset to center of top-left tile
		var startIndex:Int = map.getTileIndexByCoords(FlxPoint.weak(start.x - offset.x, start.y - offset.y));
		var endIndex:Int = map.getTileIndexByCoords(FlxPoint.weak(end.x - offset.x, end.y - offset.y));

		var data:FlxPathfinderData = createData(map, startIndex, endIndex);
		var indices:Array<Int> = findPathIndicesHelper(data);
		if (indices == null)
			return null;

		var path:Array<FlxPoint> = getPathPointsFromIndices(data, indices);

		// Reset the start and end points to be exact
		path[0].copyFrom(start);
		path[path.length - 1].copyFrom(end);

		// Some simple path cleanup options
		simplifyPath(data, path, simplify);

		start.putWeak();
		end.putWeak();
		offset.put();

		return path;
	}

	override private function getPathPointsFromIndices(data:FlxPathfinderData, indices:Array<Int>):Array<FlxPoint> {
		var path:Array<FlxPoint> = super.getPathPointsFromIndices(data, indices);
		final offset:FlxPoint = FlxPoint.get((widthInTiles - 1) / 2 * data.map.width / data.map.widthInTiles,
			(heightInTiles - 1) / 2 * data.map.height / data.map.heightInTiles);

		for (p in path)
			p.addPoint(offset);

		offset.put();

		return path;
	}

	override private function getInBoundDirections(data:FlxPathfinderData, from:Int):FlxDirectionFlags {
		var x:Int = data.getX(from);
		var y:Int = data.getY(from);
		return FlxDirectionFlags.fromBools(x > 0, x < data.map.widthInTiles - widthInTiles, y > 0, y < data.map.heightInTiles - heightInTiles);
	}

	override private function canGo(data:FlxPathfinderData, to:Int, dir:FlxDirectionFlags = ANY):Bool {
		final cols:Int = data.map.widthInTiles;

		for (x in 0...widthInTiles) {
			for (y in 0...heightInTiles) {
				if (!super.canGo(data, to + x + (y * cols), dir))
					return false;
			}
		}

		return true;
	}

	override private function hasValidInitialData(data:FlxPathfinderData):Bool {
		final maxX:Int = data.map.widthInTiles - widthInTiles;
		final maxY:Int = data.map.heightInTiles - heightInTiles;
		return data.hasValidStartEnd() && data.getX(data.startIndex) <= maxX && data.getY(data.startIndex) <= maxY && data.getX(data.endIndex) <= maxX
			&& data.getY(data.endIndex) <= maxY && canGo(data, data.startIndex) && canGo(data, data.endIndex);
	}
}
