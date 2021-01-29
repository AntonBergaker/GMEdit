package gml.ast;

import parsers.GmlReader;
import tools.Aliases.GmlCode;
import gml.ast.tree.*;

class AstBuilder {
	var reader:GmlReader;
	var gmlVersion:GmlVersion;
	var errors:Array<String>;
	var lastAst:AstNode;

	public function new(gmlVersion:GmlVersion) {
		this.gmlVersion = gmlVersion;
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

		return new StatementList(statements);
	}

	private function readStatement():AstNode {
		var pre = reader.readNops();

		inline function localReturn(ast:AstNode):AstNode {
			ast.before = pre + ast.before;
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

		var identifier = reader.readIdent();
		switch (identifier) {
			case "var":
				return localReturn(readLocalVarDefinition());
		} 

		return null;
	}

	/**Assumes var has already been read
	*/
	private function readLocalVarDefinition():LocalVarDefinition {
		var end;
		var entries = new Array<VarDefinitionEntry>();
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
		} while(true);
		
		var ast = new LocalVarDefinition(entries);
		ast.after = end;
		return returnAst(ast);
	}

	private function readVarDefinitionEntry():VarDefinitionEntry {
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

		var ast = new VarDefinitionEntry(ident, typeDefinition, assignment);
		ast.afterIdentifier = afterIdentNop;
		ast.before = before;
		return returnAst(ast);
	}

	private function readExpression() : Returnable {
		return returnAst(readLiteral());
	}

	private function readLiteral() : Returnable {
		var before = reader.readNops();
		var peek = reader.peek();
		// If the literal is a number
		if (peek.isDigit()) {
			var number;
			if (peek == '0'.code && reader.peek(1) == 'x'.code) {
				number = reader.readHex();
			} else {
				number = reader.readNumber();
			}
			var ast = new NumberLiteral(number);
			ast.before = before;
			return returnAst(ast);
		}
		// If the literal is a string
		if (peek == '"'.code || peek == "'".code ||
			peek == '`'.code) {
			reader.skip();
			var string = reader.readStringAuto(peek);
			var ast = new StringLiteral(string);
			ast.before = before;
			return returnAst(ast);
		}

		return null;
	}
}