package gml.tokenizer;

import parsers.linter.GmlLinterKind;

class TokenHelper {

	static var stringToKind: Map<String, GmlLinterKind> = new Map();
	static var kindToString: Map<GmlLinterKind, String> = new Map();

	static private var hasSetup: Bool = false;

	private static function setup() {
		hasSetup = true;

		var entries: Array<Dynamic> = [
			[KEQ, "=="],
			[KNE, "!="],
			[KLT, "<"],
			[KLE, "<="],
			[KGT, ">"],
			[KGE, ">="],
			[KBoolAnd, "&&"],
			[KBoolOr, "||"],
			[KBoolXor, "^^"],
			[KNot, "!"],
			[KAdd, "+"],
			[KSub, "-"],
			[KMul, "*"],
			[KDiv, "/"],
			[KIntDiv, "div"],
			[KMod, "%"],
			[KAnd, "&"],
			[KOr, "|"],
			[KXor, "^"],
			[KShl, "<<"],
			[KShr, ">>"],
			[KBitNot, "~"],
			[KSet, "="],
			[KSetAdd, "+="],
			[KSetSub, "-="],
			[KSetMul, "*="],
			[KSetDiv, "/="],
			[KSetMod, "%="],
			[KSetAnd, "&="],
			[KSetOr, "|="],
			[KSetXor, "^="]
		];

		for (entry in entries) {
			stringToKind[entry[1]] = entry[0];
			kindToString[entry[0]] = entry[1];
		}
	}

	public static function identifierToKind(identifier: String): GmlLinterKind {
		if (hasSetup == false) {
			setup();
		}

		return stringToKind[identifier];
	}

	public static function kindToIdentifier(kind: GmlLinterKind): String {
		if (hasSetup == false) {
			setup();
		}

		return kindToString[kind];
	}

}