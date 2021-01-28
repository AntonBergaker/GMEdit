package gml.ast.tree;


class VarDefinition extends AstNode {
    public var variableName: String;
    public var type: TypeDefinition;
    public var initialValue: Returnable;

    public function new(variableName:String, typeDefinition: TypeDefinition, initialValue: Returnable) {
        this.variableName = variableName;
        this.type = typeDefinition;
        this.initialValue = initialValue;
    }


	/** Returns the string as it was originally read
	**/
	public override function toCompleteString() : String {
		return "var " +
		this.variableName +
		(this.type == null ? '' : ': ' + this.type.toCompleteString()) +
		(this.initialValue == null ? '' : ' = ' + this.initialValue.toCompleteString());
	}

	/** Returns a string representing the syntax, with everything including unnecessary parenthesis
	**/
	public override function toSyntaxString() : String {
		return "var " +
		this.variableName +
		(this.type == null ? '' : ': ' + this.type.toSyntaxString()) +
		(this.initialValue == null ? '' : ' = ' + this.initialValue.toSyntaxString());
	}
	/** Compares against anothor of itself
	**/
	public function valueEquals(other:VarDefinition): Bool {
		return 
			initialValue.equals(other.initialValue) && 
			variableName == other.variableName &&
			type.valueEquals(other.type);
	}
}