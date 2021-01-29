package gml.ast.tree;

class TypeDefinition extends AstNode {
	var typeName: String;

	public function new(typeName: String) {
		this.typeName = typeName;
	}

	/** Returns the string as it was originally read
	**/
	public override function toCompleteString() : String {
		return before + typeName + after;
	}

	/** Returns a string representing the syntax, with everything including unnecessary parenthesis
	**/
	public override function toSyntaxString() : String {
		return typeName;
	}

	/** Returns all child nodes to this node
	**/
	public override function getChildren(): Array<AstNode> {
		return [];
	}

	/** Compares against another of itself
	**/
	public function valueEquals(other:TypeDefinition): Bool {
		return typeName == other.typeName;
	}
}