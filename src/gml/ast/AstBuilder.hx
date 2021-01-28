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
		var pre = reader.readNops();
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
				statements.push(statement);
			}
		}

		return new StatementList(statements);
	}

	private function readStatement():AstNode {
		var pre = reader.skipNops();

		var peek = reader.peek();
		switch (peek) {
			case '{'.code:
				reader.skip();
				return returnAst(readStatementList());
			case ';'.code:
				reader.skip();
				lastAst.after += ";";
		}

		var identifier = reader.readIdent();
		switch (identifier) {
			case "var":
				return returnAst(readVarDefinition());
		} 

		return null;
	}

	/**Assumes var has already been read
	*/
	private function readVarDefinition():VarDefinition {
		var before = reader.readNops();
		var ident = reader.readIdent();
		var after = reader.readNops();
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

		var ast = new VarDefinition(ident, typeDefinition, assignment);
		ast.before = before;
		return returnAst(ast);
	}

	private function readExpression() : Returnable {
		return returnAst(readLiteral());
	}

	private function readLiteral() : Returnable {
		var before = reader.readNops();
		var peek = reader.peek();
		if (peek.isDigit()) {
			var number = reader.readNumber();
			var ast = new NumberLiteral(number);
			ast.before = before;
			return returnAst(ast);
		}

		return null;
	}
}