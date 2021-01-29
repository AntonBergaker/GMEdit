package gml.ast.tree;

class Ternary extends Returnable {
	var comparison: Returnable;
	var lhs: Returnable;
	var rhs: Returnable;

	public function new(comparison: Returnable, lhs:Returnable, rhs:Returnable) {
		this.comparison = comparison;
		this.lhs = lhs;
		this.rhs = rhs;
	}

	/** Returns the string as it was originally read
	**/
	public override function toCompleteString() : String {
		return before + 
			comparison.toCompleteString() + '?' +
			lhs.toCompleteString() + ":" +
			rhs.toCompleteString() +
		after;
	}

	/** Returns a string representing the syntax, with everything including unnecessary parenthesis
	**/
	public override function toSyntaxString() : String {
			return comparison.toSyntaxString() + ' ? ' +
				lhs.toSyntaxString() + " : " +
				rhs.toSyntaxString();
	}

	/** Returns all child nodes to this node
	**/
	public override function getChildren(): Array<AstNode> {
		return [comparison, lhs, rhs];
	}

	/** Compares against another of itself
	**/
	public function valueEquals(other:Ternary): Bool {
		return AstNode.equals(comparison, other.comparison) &&
			AstNode.equals(lhs, other.lhs) &&
			AstNode.equals(rhs, other.rhs);
	}
}