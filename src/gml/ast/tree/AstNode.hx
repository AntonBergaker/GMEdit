package gml.ast.tree;


/** Parent for all the Ast elements
**/
class AstNode {
	var line: Int;
	var character: Int;
	public var before: String = "";
	public var after: String = "";
	
	/** Returns the string as it was originally read
	**/
	public function toCompleteString() : String {
		throw new haxe.Exception('toCompleteString is not overriden in type ${Type.typeof(this).getName()}');
	}

	/** Returns a string representing the syntax, with everything including unnecessary parenthesis
	**/
	public function toSyntaxString() : String {
		throw new haxe.Exception('toCompleteString is not overriden in type ${Type.typeof(this).getName()}');
	}

	/** Returns all child nodes to this node
	**/
	public function getChildren(): Array<AstNode> {
		throw new haxe.Exception('getChildren is not overriden in type ${Type.typeof(this).getName()}');
	}

	/**Compares two AstNodes*/
	public static function equals(a:AstNode, b:AstNode) {
		if (a == null && b == null) {
			return true;
		}
		if (a == null || b == null) {
			return false;
		}
		if (Type.enumEq(Type.typeof(a), Type.typeof(b)) == false) {
			return false;
		}
		var dynamicA:Dynamic = cast a;
		if (dynamicA.valueEquals != null) {
			return dynamicA.valueEquals(b);
		}
		return false;
	}
}
