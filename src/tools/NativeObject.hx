package tools;

/**
 * Like Reflect, but rawer
 * @author YellowAfterlife
 */
class NativeObject {
	public static inline function removeField(q:Dynamic, fd:String):Void {
		js.Syntax.code("delete {0}[{1}]", q, fd);
	}
	public static inline function forField(q:Dynamic, fn:String->Void):Void {
		var fd:String = null;
		var has:js.lib.Function = untyped js.lib.Object.prototype.hasOwnProperty;
		js.Syntax.code("for ({0} in {1}) {", fd, q);
		if (has.call(q, fd)) fn(fd);
		js.Syntax.code("}");
	}
	public static function hasFields(q:Dynamic):Bool {
		var fd:String = null;
		var has:js.lib.Function = untyped js.lib.Object.prototype.hasOwnProperty;
		js.Syntax.code("for ({0} in {1}) {", fd, q);
		if (has.call(q, fd)) return true;
		js.Syntax.code("}");
		return false;
	}
	public static inline function fillDefaults<T:{}>(obj:T, defaults:T):Void {
		forField(defaults, function(fd:String) {
			var v = Reflect.field(defaults, fd);
			if (v != null && Reflect.field(obj, fd) == null) {
				Reflect.setField(obj, fd, v);
			}
		});
	}
}
