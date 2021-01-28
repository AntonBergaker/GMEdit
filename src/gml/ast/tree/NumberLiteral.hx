package gml.ast.tree;

class NumberLiteral extends Returnable {
    public var number : String;

    public function new(number:String) {
		this.number = number;
    }

	/** Returns the string as it was originally read
	**/
	public override function toCompleteString() : String {
		return number;
	}

	/** Returns a string representing the syntax, with everything including unnecessary parenthesis
	**/
	public override function toSyntaxString() : String {
		return number;
	}

	/** Compares against anothor of itself
	**/
	public function valueEquals(other:NumberLiteral): Bool {
		return number == other.number;
	}
}