package gml.ast.tree;

import gml.tokenizer.Token;

class StringLiteral extends Returnable {
    public var string : Token;

    public function new(string:Token) {
		this.string = string;
    }

	/** Returns the string as it was originally read
	**/
	public override function toCompleteString() : String {
		return before + "\"" + string.toSource() + "\"" + after;
	}

	/** Returns a string representing the syntax, with everything including unnecessary parenthesis
	**/
	public override function toSyntaxString() : String {
		return "\"" + string.sourceString + "\"";
	}

	/** Returns all child nodes to this node
	**/
	public override function getChildren(): Array<AstNode> {
		return [];
	}

	/** Compares against another of itself
	**/
	public function valueEquals(other:StringLiteral): Bool {
		return Token.equals(string, other.string);
	}
}