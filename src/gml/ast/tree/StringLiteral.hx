package gml.ast.tree;

class StringLiteral extends Returnable {
    public var string : String;

    public function new(string:String) {
		this.string = string;
    }

	/** Returns the string as it was originally read
	**/
	public override function toCompleteString() : String {
		return before + "\"" + string + "\"" + after;
	}

	/** Returns a string representing the syntax, with everything including unnecessary parenthesis
	**/
	public override function toSyntaxString() : String {
		return "\"" + string + "\"";
	}

	/** Returns all child nodes to this node
	**/
	public override function getChildren(): Array<AstNode> {
		return [];
	}

	/** Compares against another of itself
	**/
	public function valueEquals(other:StringLiteral): Bool {
		return string == other.string;
	}
}