package gml.ast.tree;

import gml.tokenizer.Token;
import parsers.linter.GmlLinterKind;

class Unary extends Returnable {
	public var value: Returnable;
	public var operation: Token;

    public function new(value: Returnable, operation: Token) {
		this.value = value;
		this.operation = operation;
    }

	/** Returns the string as it was originally read
	**/
	public override function toCompleteString() : String {
		return before + operation.toSource() + value.toCompleteString() + after;
	}

	/** Returns a string representing the syntax, with everything including unnecessary parenthesis
	**/
	public override function toSyntaxString() : String {
		return operation.sourceString + value.toSyntaxString();
	}

	/** Returns all child nodes to this node
	**/
	public override function getChildren(): Array<AstNode> {
		return [value];
	}

	/** Compares against another of itself
	**/
	public function valueEquals(other:Unary): Bool {
		return Token.equals(operation, other.operation) &&
			AstNode.equals(value, other.value);
	}
}