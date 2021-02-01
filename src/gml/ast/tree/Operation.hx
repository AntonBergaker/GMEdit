package gml.ast.tree;

import gml.tokenizer.Token;
import parsers.linter.GmlLinterKind;

class Operation extends Returnable {
	public var lhs: Returnable;
	public var rhs: Returnable;
	public var operation: Token;

    public function new(lhs: Returnable, operation: Token, rhs:Returnable) {
		this.lhs = lhs;
		this.rhs = rhs;
		this.operation = operation;
    }

	/** Returns the string as it was originally read
	**/
	public override function toCompleteString() : String {
		return before + lhs.toCompleteString() + operation.toSource() + rhs.toCompleteString() + after;
	}

	/** Returns a string representing the syntax, with everything including unnecessary parenthesis
	**/
	public override function toSyntaxString() : String {
		return "(" + lhs.toSyntaxString() + operation.sourceString + rhs.toSyntaxString() + ")";
	}

	/** Returns all child nodes to this node
	**/
	public override function getChildren(): Array<AstNode> {
		return [lhs, rhs];
	}

	/** Compares against another of itself
	**/
	public function valueEquals(other:Operation): Bool {
		return Token.equals(operation, other.operation) &&
			AstNode.equals(lhs, other.lhs) &&
			AstNode.equals(rhs, other.rhs);
	}
}