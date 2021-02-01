package gml.ast.tree;

import gml.tokenizer.Token;

class LocalVarDefinitionEntry extends AstNode {
	public var variableToken: Token;
	public var afterIdentifier: String = "";
	public var type: TypeDefinition;
	public var initialValue: Returnable;
	
	public function new(variableToken: Token, type: TypeDefinition, initialValue: Returnable) {
		this.variableToken = variableToken;
		this.type = type;
		this.initialValue = initialValue;
	}

	/** Returns the string as it was originally read
	**/
	public override function toCompleteString() : String {
		return before +
			this.variableToken.toSource() + afterIdentifier +
			(this.type == null ? '' : ':' + this.type.toCompleteString()) +
			(this.initialValue == null ? '' : '=' + this.initialValue.toCompleteString()) +
		after;
	}

	/** Returns a string representing the syntax, with everything including unnecessary parenthesis
	**/
	public override function toSyntaxString() : String {
		return this.variableToken.sourceString +
		(this.type == null ? '' : ': ' + this.type.toSyntaxString()) +
		(this.initialValue == null ? '' : ' = ' + this.initialValue.toSyntaxString());
	}

	/** Returns all child nodes to this node
	**/
	public override function getChildren(): Array<AstNode> {
		if (type != null && initialValue != null) {
			return [type, initialValue];
		}
		if (type != null) {
			return [type];
		}
		if (initialValue != null) {
			return [initialValue];
		}
		return [];
	}

	/** Compares against another of itself
	**/
	public function valueEquals(other:LocalVarDefinitionEntry): Bool {
		return 
			AstNode.equals(initialValue, other.initialValue) && 
			Token.equals(variableToken, other.variableToken) &&
			AstNode.equals(type, other.type);
	}
}