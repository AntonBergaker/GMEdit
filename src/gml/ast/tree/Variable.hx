package gml.ast.tree;

import gml.tokenizer.Token;

class Variable extends Returnable {
    public var name : Token;

    public function new(name:Token) {
		this.name = name;
    }

	/** Returns the string as it was originally read
	**/
	public override function toCompleteString() : String {
		return before + name.toSource() + after;
	}

	/** Returns a string representing the syntax, with everything including unnecessary parenthesis
	**/
	public override function toSyntaxString() : String {
		return name.sourceString;
	}

	/** Returns all child nodes to this node
	**/
	public override function getChildren(): Array<AstNode> {
		return [];
	}

	/** Compares against another of itself
	**/
	public function valueEquals(other:Variable): Bool {
		return Token.equals(name, other.name);
	}
}