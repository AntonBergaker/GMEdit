package gml.ast.tree;

class StatementList extends AstNode {
	var statements:Array<AstNode>;
	public var hasBraces:Bool;

    public function new(statements:Array<AstNode>) {
		this.statements = statements;
		hasBraces = true;
    }

	/** Returns the string as it was originally read
	**/
	public override function toCompleteString() : String {
		return before +
			(hasBraces ? '{' : '') +
				statements.map(function (statement) {
					return statement.toCompleteString();
				}).join('') +
			(hasBraces ? '}' : '') +
		after;
	}

	/** Returns a string representing the syntax, with everything including unnecessary parenthesis
	**/
	public override function toSyntaxString() : String {
		return '{' + statements.map(function (statement) {
			return statement.toSyntaxString();
		}).join(';\r\n') + '}';
	}

	/** Returns all child nodes to this node
	**/
	public override function getChildren(): Array<AstNode> {
		return statements;
	}

	/** Compares against another of itself
	**/
	public function valueEquals(other:StatementList): Bool {
		if (other.statements.length != statements.length) {
			return false;
		}
		for (i in 0...statements.length) {
			if (AstNode.equals(statements[i], other.statements[i]) == false) {
				return false;
			}
		}
		return true;
	}
}