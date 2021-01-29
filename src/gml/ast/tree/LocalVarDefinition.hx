package gml.ast.tree;


class LocalVarDefinition extends AstNode {
    public var varDefinitions:Array<VarDefinitionEntry>;

    public function new(varDefinitions:Array<VarDefinitionEntry>) {
        this.varDefinitions = varDefinitions;
    }


	/** Returns the string as it was originally read
	**/
	public override function toCompleteString() : String {
		return before + "var" +
			varDefinitions.map(function (statement) {
				return statement.toCompleteString();
			}).join(',') +
		after;
	}

	/** Returns a string representing the syntax, with everything including unnecessary parenthesis
	**/
	public override function toSyntaxString() : String {
		return "var " +
			varDefinitions.map(function (statement) {
				return statement.toSyntaxString();
			}).join(', ');
	}

	/** Returns all child nodes to this node
	**/
	public override function getChildren(): Array<AstNode> {
		return varDefinitions.map(function(x) { return cast(x, AstNode); });
	}

	/** Compares against another of itself
	**/
	public function valueEquals(other:LocalVarDefinition): Bool {
		if (other.varDefinitions.length != varDefinitions.length) {
			return false;
		}
		for (i in 0...varDefinitions.length) {
			if (AstNode.equals(varDefinitions[i], other.varDefinitions[i]) == false) {
				return false;
			}
		}
		return true;
	}
}
