package gml.ast;

import parsers.linter.GmlLinterKind;
import tools.Dictionary;
import parsers.linter.GmlLinterInit;
import parsers.GmlReader;
import tools.Aliases.GmlCode;
import gml.ast.tree.*;

class AstBuilder {
	var reader:GmlReader;
	var gmlVersion:GmlVersion;
	var errors:Array<String>;
	var lastAst:AstNode;
	var keywords:Dictionary<GmlLinterKind>;

	public function new(gmlVersion:GmlVersion) {
		this.gmlVersion = gmlVersion;
		keywords = GmlLinterInit.keywords(gmlVersion.config);
	}

	private function addError(error: String) {
		errors.push(error);
	}

	public function build(code: GmlCode):AstCode {
		reader = new GmlReader(code, gmlVersion);
		this.errors = new Array();
		this.lastAst = null;
		var list = readStatementList();
		list.hasBraces = false;
		var astCode = new AstCode(list);
		astCode.errors = errors;
		return astCode;
	}

	/** Returns the ast and sets it as lastAst. This is so it can be accessed and whitespace information can be added to it.
	**/
	private inline function returnAst<T:AstNode>(node:T):T {
		lastAst = node;
		return node;
	}

	/**Reads statements until it encounters a closing }**/
	private function readStatementList():StatementList {
		var statements:Array<AstNode> = new Array();
		while (true) {
			if (reader.eof) {
				break;
			}
			var code = reader.peek();
			if (code == '}'.code) {
				reader.skip();
				break;
			}

			var statement = readStatement();
			if (statement != null) {
				var after = reader.readNopsTillNewline();
				statement.after += after;
				statements.push(statement);
			}
		}
		lastAst.after += reader.readNops();
		return new StatementList(statements);
	}

	private function readStatement():AstNode {
		var pre = reader.readNops();

		inline function localReturn(ast:AstNode):AstNode {
			ast.before = pre + ast.before;
			ast.after += reader.readNopsTillNewline();
			return returnAst(ast);
		}

		var peek = reader.peek();
		switch (peek) {
			case '{'.code:
				reader.skip();
				return localReturn(readStatementList());
			case ';'.code:
				reader.skip();
				lastAst.after += ";";
		}

		if (peek.isIdent0()) {
			var identifier = reader.readIdent();
			var keyword = keywords[identifier];
			if (keyword != null) {
				switch (keyword) {
					case KVar:
						return localReturn(readLocalVarDefinition());
					default:
						return null;
				}
			}

			var afterIdentifier = reader.readNops();
		}

		return null;
	}

	/**Assumes var has already been read
	*/
	private function readLocalVarDefinition():LocalVarDefinition {
		var end;
		var entries = new Array<LocalVarDefinitionEntry>();
		do {
			var entry = readVarDefinitionEntry();
			end = reader.readNops();
			var next = reader.peek();
			entries.push(entry);
			if (next == ','.code) {
				reader.skip();
				entry.after = end;
			} else {
				break;
			}
		} while (true);
		
		var ast = new LocalVarDefinition(entries);
		ast.after = end;
		return returnAst(ast);
	}

	private function readVarDefinitionEntry():LocalVarDefinitionEntry {
		var before = reader.readNops();
		var ident = reader.readIdent();
		var afterIdentNop = reader.readNops();
		var typeDefinition:TypeDefinition = null;
		var assignment:Returnable = null;
		var next = reader.peek();
		if (next == ':'.code) {
			reader.skip();
			var typeBefore = reader.readNops();
			var typeName = reader.readIdent();
			typeDefinition = new TypeDefinition(typeName);
			typeDefinition.before = typeBefore;
			typeDefinition.after = reader.readNops();
			next = reader.peek();
		}
		if (next == '='.code) {
			reader.skip();
			assignment = readExpression();
		}

		var ast = new LocalVarDefinitionEntry(ident, typeDefinition, assignment);
		ast.afterIdentifier = afterIdentNop;
		ast.before = before;
		return returnAst(ast);
	}

	private function readExpression() : Returnable {
		return returnAst(readTernary());
	}

	private function readTernary() : Returnable {
		var comparison = readBitwiseOperators();

		var peek = reader.peek();
		if (peek == '?'.code) {
			reader.skip();
			var lhs = readBitwiseOperators();
			var read = reader.read();
			if (read != ':'.code) {
				addError("");
				return null;
			}
			var rhs = readBitwiseOperators();
			return returnAst(new Ternary(comparison, lhs, rhs));
		}

		return returnAst(comparison);
	}

	// These are very expressive and could all be generalized, but there's no good structure to store it in
	private function readBitwiseOperators() : Returnable {
		var next = readBooleanComparisons;
		var lhs = next();

		while(true) {
			var peek = reader.peek();
			var nextPeek = reader.peek(1);
			if (peek == '|'.code && nextPeek != '|'.code) {
				reader.skip();
				lhs = new Operation(lhs, KOr, '|',  next());
			} else if (peek == '&'.code && nextPeek != '&'.code) {
				reader.skip();
				lhs = new Operation(lhs, KAnd, '&',  next());
			} else if (peek == '^'.code && nextPeek != '^'.code) {
				reader.skip();
				lhs = new Operation(lhs, KXor, '^',  next());
			} else {
				break;
			}
		}

		return returnAst(lhs);
	}

	private function readBooleanComparisons() : Returnable {
		var next = readBooleanLogicalOperations;
		var lhs = next();
		while(true) {
			var peek = reader.peek();
			
			// Equals
			if (peek == '='.code) {
				var nextPeek = reader.peek(1);
				if (nextPeek == '='.code) {
					reader.skip(2);
					lhs = new Operation(lhs, KEQ, '==',  next());
				} else {
					reader.skip();
					lhs = new Operation(lhs, KEQ, '=',  next());
				}
			} else if (peek == ':'.code && reader.peek(1) == '='.code) { // so cursed
				reader.skip(2);
				lhs = new Operation(lhs, KEQ, 'and',  next());
			}

			// Not equals
			else if (peek == '!'.code && reader.peek(1) == '='.code) {
				reader.skip(2);
				lhs = new Operation(lhs, KNE, '!=',  next());
			}
			
			// Lesser than
			else if (peek == '<'.code) {
				var nextPeek = reader.peek(1);
				if (nextPeek == '<'.code) {
					// Not the operator we're looking for
					break;
				}
				if (nextPeek == '='.code) {
					reader.skip(2);
					lhs = new Operation(lhs, KLE, '<=',  next());
				} else {
					reader.skip();
					lhs = new Operation(lhs, KLT, '<',  next());
				}
			}

			// Greater than
			else if (peek == '>'.code) {
				var nextPeek = reader.peek(1);
				if (nextPeek == '>'.code) {
					// Not the operator we're looking for
					break;
				}
				if (nextPeek == '='.code) {
					reader.skip(2);
					lhs = new Operation(lhs, KGE, '>=',  next());
				} else {
					reader.skip();
					lhs = new Operation(lhs, KGT, '>',  next());
				}
			}
			
			else {
				break;
			}
		}

		return returnAst(lhs);
	}

	private function readBooleanLogicalOperations(): Returnable {
		var next = readBinaryShift;
		var lhs = next();
		while(true) {
			var peek = reader.peek();
			if (peek == '&'.code && reader.peek(1) == '&'.code) {
				reader.skip(2);
				lhs = new Operation(lhs, KBoolAnd, '&&',  next());
			} else if (peek == 'a'.code && reader.peek(1) == 'n'.code && reader.peek(2) == 'd'.code) {
				reader.skip(3);
				lhs = new Operation(lhs, KBoolAnd, 'and',  next());
			}

			else if (peek == '|'.code && reader.peek(1) == '|'.code) {
				reader.skip(2);
				lhs = new Operation(lhs, KBoolOr, '||',  next());
			} else if (peek == 'o'.code && reader.peek(1) == 'r'.code) {
				reader.skip(2);
				lhs = new Operation(lhs, KBoolOr, 'or',  next());
			}

			else if (peek == '^'.code && reader.peek(1) == '^'.code) {
				reader.skip(2);
				lhs = new Operation(lhs, KBoolXor, '^^',  next());
			} else if (peek == 'x'.code && reader.peek(1) == 'o'.code && reader.peek(2) == 'r'.code) {
				reader.skip(3);
				lhs = new Operation(lhs, KBoolXor, 'xor',  next());
			} else {
				break;
			}
		}

		return returnAst(lhs);
	}

	private function readBinaryShift(): Returnable {
		var next = readAdditionSubtraction;
		var lhs = next();
		while(true) {
			var peek = reader.peek();
			if (peek == '>'.code && reader.peek(1) == '>'.code) {
				reader.skip(2);
				lhs = new Operation(lhs, KShr, '>>',  next());
			} else if (peek == '<'.code && reader.peek(1) == '<'.code) {
				reader.skip(2);
				lhs = new Operation(lhs, KShl, '<<',  next());
			} else {
				break;
			}
		}

		return returnAst(lhs);
	}
	
	private function readAdditionSubtraction() : Returnable {
		var next = readMultiplicationDivision;
		var lhs = next();
		while(true) {
			var peek = reader.peek();
			if (peek == '+'.code) {
				reader.skip();
				lhs = new Operation(lhs, KAdd, '+', next());
			} else if (peek == '-'.code) {
				reader.skip();
				lhs = new Operation(lhs, KSub, '-', next());
			} else {
				break;
			}
		}

		return returnAst(lhs);
	}


	private function readMultiplicationDivision() : Returnable {
		var next = readLiteral;
		var lhs = next();

		while(true) {
			var peek = reader.peek();
			if (peek == '*'.code) {
				reader.skip();
				lhs = new Operation(lhs, KMul, '*', next());
			} else if (peek == '/'.code) {
				reader.skip();
				lhs = new Operation(lhs, KDiv, '/', next());
			} else if (peek == 'm'.code && reader.peek(1) == 'o'.code && reader.peek(2) == 'd'.code) {
				reader.skip(3);
				lhs = new Operation(lhs, KMod, 'mod', next());
			} else if (peek == 'd'.code && reader.peek(1) == 'i'.code && reader.peek(2) == 'v'.code) {
				reader.skip(3);
				lhs = new Operation(lhs, KDiv, 'div', next());
			} else {
				break;
			}
		}

		return returnAst(lhs);
	}



	private function readLiteral() : Returnable {
		function localReturn(ast: Returnable) {
			ast.after += reader.readNopsTillNewline();
			return returnAst(ast);
		}

		var before = reader.readNops();
		var peek = reader.peek();
		// If the literal is a number
		if (peek.isDigit()) {
			var number;
			if (peek == '0'.code && reader.peek(1) == 'x'.code) {
				reader.skip();
				reader.skip();
				number = reader.readHex();
			} else {
				number = reader.readNumber();
			}
			var ast = new NumberLiteral(number);
			ast.before = before;
			return localReturn(ast);
		}

		// If the literal is a string
		if (peek == '"'.code || peek == "'".code ||
			peek == '`'.code || peek == '@'.code) {
			reader.skip();
			var string = reader.readStringAuto(peek);
			var ast = new StringLiteral(string);
			ast.before = before;
			return localReturn(ast);
		}

		if (peek.isIdent0()) {
			var identifier = reader.readIdent();
		}

		return null;
	}
}