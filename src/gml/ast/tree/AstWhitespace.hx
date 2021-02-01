package gml.ast.tree;
import gml.tokenizer.Token;

class AstWhitespace extends AstNode {
	var content: String;
    public function new(whitespace: String) {
		content = whitespace;
    }

	/** Returns the string as it was originally read
	**/
	public override function toCompleteString() : String {
		return before + content + after;
	}

	/** Returns a string representing the syntax, with everything including unnecessary parenthesis
	**/
	public override function toSyntaxString() : String {
		return "";
	}

	/** Returns all child nodes to this node
	**/
	public override function getChildren(): Array<AstNode> {
		return [];
	}

	/** Compares against another of itself
	**/
	public function valueEquals(other:NumberLiteral): Bool {
		return true;
	}
}