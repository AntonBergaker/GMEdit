package gml.ast.tree;

class Assignment extends AstNode {
	public var variableName: String;
	public var afterIdentifier: String = "";
	public var type: TypeDefinition;
	public var value: Returnable;
	
	public function new(variableName: String, type: TypeDefinition, value: Returnable) {
		this.variableName = variableName;
		this.type = type;
		this.value = value;
	}

	/** Returns the string as it was originally read
	**/
	public override function toCompleteString() : String {
		return before +
			this.variableName + afterIdentifier +
			(this.type == null ? '' : ':' + this.type.toCompleteString()) +
			(this.value == null ? '' : '=' + this.value.toCompleteString()) +
		after;
	}

	/** Returns a string representing the syntax, with everything including unnecessary parenthesis
	**/
	public override function toSyntaxString() : String {
		return this.variableName +
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
			variableName == other.variableName &&
			AstNode.equals(type, other.type);
	}
}