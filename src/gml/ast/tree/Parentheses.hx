package gml.ast.tree;

class Parentheses extends Returnable {
	public var value: Returnable;

    public function new(value: Returnable) {
		this.value = value;
    }

	/** Returns the string as it was originally read
	**/
	public override function toCompleteString() : String {
		return before + '(' + value.toCompleteString() + ')' + after;
	}

	/** Returns a string representing the syntax, with everything including unnecessary parenthesis
	**/
	public override function toSyntaxString() : String {
		return '(' + value.toSyntaxString() + ')';
	}

	/** Returns all child nodes to this node
	**/
	public override function getChildren(): Array<AstNode> {
		return [value];
	}

	/** Compares against another of itself
	**/
	public function valueEquals(other:Parentheses): Bool {
		return AstNode.equals(value, other.value);
	}
}