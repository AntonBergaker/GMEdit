package gml.ast.tree;

import parsers.linter.GmlLinterKind;

class Operation extends Returnable {
	public var lhs: Returnable;
	public var rhs: Returnable;
	public var opString: String;
	public var opKind: GmlLinterKind;

    public function new(lhs: Returnable, rhs:Returnable, opKind: GmlLinterKind, opString: String) {
		this.lhs = lhs;
		this.rhs = rhs;
		this.opString = opString;
    }

	/** Returns the string as it was originally read
	**/
	public override function toCompleteString() : String {
		return before + lhs.toCompleteString() + opString + rhs.toCompleteString() + after;
	}

	/** Returns a string representing the syntax, with everything including unnecessary parenthesis
	**/
	public override function toSyntaxString() : String {
		return "(" + lhs.toSyntaxString() + opString + rhs.toSyntaxString() + ")";
	}

	/** Returns all child nodes to this node
	**/
	public override function getChildren(): Array<AstNode> {
		return [lhs, rhs];
	}

	/** Compares against another of itself
	**/
	public function valueEquals(other:Operation): Bool {
		return opKind == other.opKind &&
			AstNode.equals(lhs, other.lhs) &&
			AstNode.equals(rhs, other.rhs);
	}
}