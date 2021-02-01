package gml.ast.tree;

import gml.tokenizer.Token;

class Assignment extends AstNode {
	public var variableToken: Token;
	public var afterIdentifier: String = "";
	public var type: TypeDefinition;
	public var value: Returnable;
	
	public function new(variableToken: Token, type: TypeDefinition, value: Returnable) {
		this.variableToken = variableToken;
		this.type = type;
		this.value = value;
	}

	/** Returns the string as it was originally read
	**/
	public override function toCompleteString() : String {
		return before +
			this.variableToken.toSource() + afterIdentifier +
			(this.type == null ? '' : ':' + this.type.toCompleteString()) +
			(this.value == null ? '' : '=' + this.value.toCompleteString()) +
		after;
	}

	/** Returns a string representing the syntax, with everything including unnecessary parenthesis
	**/
	public override function toSyntaxString() : String {
		return this.variableToken.sourceString +
		(this.type == null ? '' : ': ' + this.type.toSyntaxString()) +
		(this.value == null ? '' : ' = ' + this.value.toSyntaxString());
	}

	/** Returns all child nodes to this node
	**/
	public override function getChildren(): Array<AstNode> {
		if (type != null) {
			return [type, value];
		}
		return [value];
	}

	/** Compares against another of itself
	**/
	public function valueEquals(other:Assignment): Bool {
		return 
			AstNode.equals(value, other.value) && 
			Token.equals(variableToken, other.variableToken) &&
			AstNode.equals(type, other.type);
	}
}