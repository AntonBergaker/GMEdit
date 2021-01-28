package gml.ast.tree;


/** Parent for all the Ast elements
**/
class AstNode {
	var line: Int;
	var character: Int;
	
	/** Returns the string as it was originally read
	**/
	public function toCompleteString() : String {
		throw new haxe.Exception('toCompleteString is not overriden in type ${Type.typeof(this)}');
	}

	/** Returns a string representing the syntax, with everything including unnecessary parenthesis
	**/
	public function toSyntaxString() : String {
		throw new haxe.Exception('toCompleteString is not overriden in type ${Type.typeof(this)}');
	}

	/** Compares against another AstNode
	**/
	public function equals(other:AstNode): Bool {
		if (Type.typeof(other) != Type.typeof(other)) {
			return false;
		}
		var dynamicSelf:Dynamic = cast this;
		if (dynamicSelf.valueEquals != null) {
			return dynamicSelf.valueEquals(other);
		}
		return false;
	}
}
