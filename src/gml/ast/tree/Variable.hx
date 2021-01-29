package gml.ast.tree;

class Variable extends Returnable {
    public var name : String;

    public function new(name:String) {
		this.name = name;
    }

	/** Returns the string as it was originally read
	**/
	public override function toCompleteString() : String {
		return before + name + after;
	}

	/** Returns a string representing the syntax, with everything including unnecessary parenthesis
	**/
	public override function toSyntaxString() : String {
		return name;
	}

	/** Returns all child nodes to this node
	**/
	public override function getChildren(): Array<AstNode> {
		return [];
	}

	/** Compares against another of itself
	**/
	public function valueEquals(other:Variable): Bool {
		return name == other.name;
	}
}