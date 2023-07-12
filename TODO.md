# TODO

* Use JSON files for things like weapons and entities, possibly. For weapons, they could include a field for the offset of the weapon sprite.

## Flixel-specific TODOs because I am very nitpicky

* Make a PR to Flixel what makes classes like `FlxBasic` implement their respective interfaces (in this case, `IFlxBasic`).
* Make a PR to Flixel what makes the classes in `flixel.postprocess` use `lime.graphics.opengl.GL` when `openfl.gl.GL` is unavailable.
* Make a PR to Flixel (or include in one of the above ones) what replaces stuff like `@:enum` with `enum` and `Dynamic->Dynamic->Void` with `(Dynamic, Dynamic) -> Void`.
* In Flixel, add semicolons to the end of things like `typedef`s and `return switch` statements.

* Add `@deprecated` tags to the doc comments of deprecated fields in Flixel.
