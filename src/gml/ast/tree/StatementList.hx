package gml.ast.tree;

class StatementList extends AstNode {
	var statements:Array<AstNode>;

    public function new(statements:Array<AstNode>) {
		this.statements = statements;
    }

	/** Returns the string as it was originally read
	**/
	public override function toCompleteString() : String {
		return "";
	}

	/** Returns a string representing the syntax, with everything including unnecessary parenthesis
	**/
	public override function toSyntaxString() : String {
		return statements.join(';\r\n');
	}
	/** Compares against anothor of itself
	**/
	public function valueEquals(other:StatementList): Bool {
		if (other.statements.length != statements.length) {
			return false;
		}
		for (i in 0...statements.length) {
			if (statements[i].equals(other.statements[i]) == false) {
				return false;
			}
		}
		return true;
	}
}