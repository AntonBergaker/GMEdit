package gml.ast.tree;

import gml.tokenizer.Token;

class TypeDefinition extends AstNode {
	var typeToken: Token;

	public function new(typeToken: Token) {
		this.typeToken = typeToken;
	}

	/** Returns the string as it was originally read
	**/
	public override function toCompleteString() : String {
		return before + typeToken.toSource() + after;
	}

	/** Returns a string representing the syntax, with everything including unnecessary parenthesis
	**/
	public override function toSyntaxString() : String {
		return typeToken.sourceString;
	}

	/** Returns all child nodes to this node
	**/
	public override function getChildren(): Array<AstNode> {
		return [];
	}

	/** Compares against another of itself
	**/
	public function valueEquals(other:TypeDefinition): Bool {
		return Token.equals(typeToken, other.typeToken);
	}
}