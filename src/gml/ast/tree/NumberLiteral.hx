package gml.ast.tree;

import gml.tokenizer.Token;

class NumberLiteral extends Returnable {
    public var number : Token;

    public function new(number:Token) {
		this.number = number;
    }

	/** Returns the string as it was originally read
	**/
	public override function toCompleteString() : String {
		return before + number.toSource() + after;
	}

	/** Returns a string representing the syntax, with everything including unnecessary parenthesis
	**/
	public override function toSyntaxString() : String {
		return number.sourceString;
	}

	/** Returns all child nodes to this node
	**/
	public override function getChildren(): Array<AstNode> {
		return [];
	}

	/** Compares against another of itself
	**/
	public function valueEquals(other:NumberLiteral): Bool {
		return Token.equals(number, other.number);
	}
}