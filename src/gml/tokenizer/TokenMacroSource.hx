package gml.tokenizer;

/**
	A reference to a macro. Is used by tokens to find where they came from.
	If multiple tokens came from the same instance of a macro being typed, they'll share the same reference
*/
class TokenMacroSource {

	public var name: String;

	public function new(macroName: String) {
		name = macroName;
	}
}