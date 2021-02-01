package gml.tokenizer;

import haxe.EnumTools.EnumValueTools;
import parsers.linter.GmlLinterKind;

class Token {
	public var kind: GmlLinterKind;
	public var sourceString: String;
	public var position: Int;
	public var macroSource: TokenMacroSource;

	public function new(kind: GmlLinterKind, string: String, position: Int, fromMacro: TokenMacroSource) {
		this.kind = kind;
		this.sourceString = string;
		this.position = position;
		this.macroSource = fromMacro;
	}

	public function toSource(): String {
		return this.sourceString;
	}

	public function getInfoString(?printPosition: Bool = true): String {
		var source = StringTools.replace(sourceString, ' ', '\\s');
		source = StringTools.replace(source, '\t', '\\t');
		source = StringTools.replace(source, '\n', '\\n');
		source = StringTools.replace(source, '\r', '\\r');
		if (printPosition) {
			return '{kind: ${kind.getName()}, source: $source, position: $position}';
		}
		return '{kind: ${kind.getName()}, source: $source}';
	}

	public static function equals(a: Token, b: Token) {
		return a.kind == b.kind && 
			a.sourceString == b.sourceString;
	}
}