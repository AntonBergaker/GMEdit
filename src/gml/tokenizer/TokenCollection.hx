package gml.tokenizer;

class TokenCollection {
	var errored = false;
	var errorMessage = null;
	var tokens:Array<Token>;
	var index: Int;

	public function new(tokens:Array<Token>) {
		this.tokens = tokens;
		this.index = 0;
	}

	/**Returns true if the tokencollection has reached the end of the list*/
	public var reachedEnd(get, null):Bool;

	private inline function get_reachedEnd() {
	  return index >= tokens.length;
	}

	/**Returns the number of elements in the collection*/
	public var length(get, null):Int;

	private inline function get_length() {
		return tokens.length;
	  }

	public function reset() {
		index = 0;
	}

	/**Reads and returns the next token*/
	public inline function next():Token {
		if (index >= tokens.length) {
			return new Token(KEOF, "", index, null);
		}
		return tokens[index++];
	}

	/**Reads the next token without moving ahead*/
	public inline function peek():Token {
		if (index >= tokens.length) {
			return new Token(KEOF, "", index, null);
		}
		return tokens[index];
	}

	/**Skips over a token moving the reader ahead*/
	public inline function skip() {
		index++;
	}

	public static function CreateError(message: String): TokenCollection {
		var collection = new TokenCollection(null);
		collection.errored = true;
		collection.errorMessage = message;
		return collection;
	}
}