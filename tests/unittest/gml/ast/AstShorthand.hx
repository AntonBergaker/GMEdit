package gml.ast;

import haxe.extern.EitherType;
import parsers.linter.GmlLinter;
import parsers.linter.GmlLinterKind;
import gml.tokenizer.Token;
import gml.ast.tree.*;

class AstShorthand {

	public static function cNumberLiteral(number: String): NumberLiteral {
		return new NumberLiteral(new Token(KNumber, number, 0, null));
	}

	public static function cStringLiteral(number: String): StringLiteral {
		return new StringLiteral(new Token(KString, number, 0, null));
	}

	public static function cLocalVarDefinitionEntry(name: String, type: EitherType<TypeDefinition, String>, initialValue: Returnable): LocalVarDefinitionEntry {
		if ((type is String)) {
			type = new TypeDefinition(new Token(KIdent, type, 0, null));
		}
		return new LocalVarDefinitionEntry(new Token(KIdent, name, 0, null), type, initialValue);
	}

	public static function cLocalVarDefinition(entries: Array<LocalVarDefinitionEntry>): LocalVarDefinition {
		return new LocalVarDefinition(new Token(KVar, "var", 0, null), entries);
	}

	public static function cTypeDefinition(name: String) {
		return new TypeDefinition(new Token(KIdent, name, 0, null));
	}

	public static function cOperation(lhs: Returnable, kind: GmlLinterKind, operation: String, rhs: Returnable): Operation {
		return new Operation(lhs, new Token(kind, operation, 0, null), rhs);
	}
	
	public static function cTernary(comparision: Returnable, lhs: Returnable, rhs: Returnable): Ternary {
		return new Ternary(comparision, lhs, rhs);
	}

	public static function cUnary(kind: GmlLinterKind, operation: String, value: Returnable) {
		return new Unary(value, new Token(kind, operation, 0, null));
	}

	public static function cAssignment(name: String, type: TypeDefinition, value: Returnable) {
		return new Assignment(new Token(KIdent, name, 0, null), type, value);
	}
}