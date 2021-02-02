package gml.ast.tree;

import gml.tokenizer.Token;
import parsers.linter.GmlLinterKind;

class IfCondition extends AstNode {
	public var condition: Returnable;
	public var statement: AstNode;

    public function new(condition: Returnable, statement: AstNode) {
		this.condition = condition;
		this.statement = statement;
    }

	/** Returns the string as it was originally read
	**/
	public override function toCompleteString() : String {
		return before + condition.toCompleteString() + statement.toCompleteString() + after;
	}

	/** Returns a string representing the syntax, with everything including unnecessary parenthesis
	**/
	public override function toSyntaxString() : String {
		return "if " + condition.toSyntaxString() + "\n" + statement.toSyntaxString();
	}

	/** Returns all child nodes to this node
	**/
	public override function getChildren(): Array<AstNode> {
		return [condition, statement];
	}

	/** Compares against another of itself
	**/
	public function valueEquals(other:IfCondition): Bool {
		return AstNode.equals(condition, other.condition) &&
			AstNode.equals(statement, other.statement);
	}
}