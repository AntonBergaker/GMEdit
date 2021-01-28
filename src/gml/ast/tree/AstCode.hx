package gml.ast.tree;

/**Top level element in the Ast tree
**/
class AstCode extends AstNode {
	var statements: StatementList;

	public function new(statements:StatementList) {
		this.statements = statements;
	}

	/** Returns the string as it was originally read
	**/
	public override function toCompleteString() : String {
		return statements.toCompleteString();
	}

	/** Returns a string representing the syntax, with everything including unnecessary parenthesis
	**/
	public override function toSyntaxString() : String {
		return statements.toSyntaxString();
	}

	/** Compares against anothor of itself
	**/
	public function valueEquals(other:AstCode): Bool {
		return statements.valueEquals(other.statements);
	}
}