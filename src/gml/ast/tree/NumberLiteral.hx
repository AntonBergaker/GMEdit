package gml.ast.tree;

class NumberLiteral extends Returnable {
    public var number : String;

    public function new(number:String) {
		this.number = number;
    }

	/** Returns the string as it was originally read
	**/
	public override function toCompleteString() : String {
		return before + number + after;
	}

	/** Returns a string representing the syntax, with everything including unnecessary parenthesis
	**/
	public override function toSyntaxString() : String {
		return number;
	}

	/** Returns all child nodes to this node
	**/
	public override function getChildren(): Array<AstNode> {
		return [];
	}

	/** Compares against anothor of itself
	**/
	public function valueEquals(other:NumberLiteral): Bool {
		return number == other.number;
	}
}