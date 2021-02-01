package gml.ast;

import ui.preferences.PrefData;
import gml.tokenizer.Token;
import tools.StringBuilder;
import gml.tokenizer.TokenCollection;
import gml.tokenizer.Tokenizer;
import parsers.linter.GmlLinterKind;
import tools.Dictionary;
import parsers.linter.GmlLinterInit;
import gml.ast.tree.*;

class AstBuilder {
	var reader: TokenCollection;
	var tokenizer: Tokenizer;
	var gmlVersion:GmlVersion;
	var errors:Array<String>;
	var lastAst:AstNode;
	var keywords:Dictionary<GmlLinterKind>;

	public function new(gmlVersion:GmlVersion, preferences:PrefData) {
		this.gmlVersion = gmlVersion;
		keywords = GmlLinterInit.keywords(gmlVersion.config);
		this.tokenizer = new Tokenizer(gmlVersion, preferences);
	}

	private function addError(error: String) {
		errors.push(error);
	}
	public function build(gmlCode: String):AstCode {
		this.reader = tokenizer.tokenize(gmlCode);
		this.errors = new Array();
		this.lastAst = null;
		var list = readStatementList();
		list.hasBraces = false;
		var astCode = new AstCode(list);
		astCode.errors = errors;
		return astCode;
	}

	private inline function readAndCollapseWhitespace(): String {
		var whitespace = "";
		while (reader.peek().kind == KWhitespace) {
			whitespace+=reader.next().sourceString;
		}
		return whitespace;
	}

	private inline function readOneWhitespace(): String {
		if (reader.peek().kind == KWhitespace) {
			return reader.next().sourceString;
		}
		return "";
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
			if (reader.reachedEnd) {
				break;
			}
			var nextToken = reader.peek();
			if (nextToken.kind == KCubClose) {
				reader.skip();
				break;
			}

			var statement = readStatement();
			if (statement != null) {
				statement.after += readOneWhitespace();
				statements.push(statement);
				continue;
			}
		}
		lastAst.after += readAndCollapseWhitespace();
		return new StatementList(statements);
	}

	private function readStatement():AstNode {
		var pre = readAndCollapseWhitespace();

		inline function localReturn(ast:AstNode):AstNode {
			ast.before = pre + ast.before;
			ast.after += readOneWhitespace();
			return returnAst(ast);
		}

		var next = reader.next();
		switch (next.kind) {
			case KCubOpen:
				return localReturn(readStatementList());

			case KSemico:
				lastAst.after += ";";
			
			case KVar:
				return localReturn(readLocalVarDefinition(next));

			case KIdent: 	
				var afterIdentifier = readAndCollapseWhitespace();
				var type = null;
				var nextOp = reader.next();
				if (nextOp.kind == KColon) {
					type = readType();
					nextOp = reader.next();
				}
				if (nextOp.kind == KSet) {
					var assignment = new Assignment(next, type, readExpression());
					assignment.afterIdentifier = afterIdentifier;
					return localReturn(assignment);
				} 

			default: 
		}
		if (pre != "") {
			new AstWhitespace(pre);
		}
		return null;
	}

	/**Assumes var has already been read
	*/
	private function readLocalVarDefinition(varToken: Token):LocalVarDefinition {
		var end;
		var entries = new Array<LocalVarDefinitionEntry>();
		do {
			var entry = readVarDefinitionEntry();
			end = readAndCollapseWhitespace();
			entries.push(entry);
			var next = reader.peek();
			if (next.kind == KComma) {
				reader.skip();
				entry.after = end;
			} else {
				break;
			}
		} while (true);
		
		var ast = new LocalVarDefinition(varToken, entries);
		ast.after = end;
		return returnAst(ast);
	}

	private function readVarDefinitionEntry():LocalVarDefinitionEntry {
		var before = readAndCollapseWhitespace();
		var ident = reader.next();
		if (ident.kind != KIdent) {
			errors.push(">:(");
			return null;
		}

		var afterIdentNop = readAndCollapseWhitespace();
		var typeDefinition:TypeDefinition = null;
		var assignment:Returnable = null;
		var next = reader.peek();
		if (next.kind == KColon) {
			reader.skip();
			typeDefinition = readType();
			next = reader.peek();
		}
		if (next.kind == KSet) {
			reader.skip();
			assignment = readExpression();
		}

		var ast = new LocalVarDefinitionEntry(ident, typeDefinition, assignment);
		ast.afterIdentifier = afterIdentNop;
		ast.before = before;
		return returnAst(ast);
	}

	/**Reads a type, assumes : has already been read*/
	private function readType():TypeDefinition {
		var typeBefore = readAndCollapseWhitespace();
		var typeToken = reader.next();
		var typeDefinition = new TypeDefinition(typeToken);
		typeDefinition.before = typeBefore;
		typeDefinition.after = readOneWhitespace();
		return typeDefinition;
	}

	private function readExpression() : Returnable {
		var before = readAndCollapseWhitespace();
		var ast = readTernary();
		ast.before = before + ast.before;
		ast.after += readAndCollapseWhitespace();
		return returnAst(ast);
	}

	private function readTernary() : Returnable {
		var comparison = readBinaryOperators();

		var peek = reader.peek();
		if (peek.kind == KQMark) {
			reader.skip();
			var lhs = readBinaryOperators();
			var next = reader.next();
			if (next.kind != KColon) {
				addError("");
				return null;
			}
			var rhs = readBinaryOperators();
			return returnAst(new Ternary(comparison, lhs, rhs));
		}

		return returnAst(comparison);
	}

	private function readBinaryOperators(): Returnable {
		return readBinaryOperation(binaryOperationOrder.length-1);
	}

	var binaryOperationOrder = [
		[KMul, KDiv, KMod, KDiv],
		[KAdd, KSub],
		[KShr, KShl],
		[KBoolAnd, KBoolXor, KBoolOr],
		[KSet, KEQ, KNE, KLE, KLT, KGE, KGT],
		[KOr, KXor, KAnd],
	];


	private function readBinaryOperation(depth: Int): Returnable {
		if (depth == -1) {
			return readUnary();
		}

        var operatorsTop = this.binaryOperationOrder[depth];

        var lhs = this.readBinaryOperation(depth-1);
        var token = reader.peek();
        while (operatorsTop.contains(token.kind)) {
			reader.skip();
            lhs = new Operation(lhs, token, readBinaryOperation(depth-1));
            token = reader.peek();
        }

        return lhs;
	}

	private function readUnary() : Returnable {
		var before = readAndCollapseWhitespace();
		
		var peek = reader.peek();
		if (peek.kind == KAdd || peek.kind == KSub) {
			reader.skip();
			var next = readLiteral();
			var unary = new Unary(next, peek);
			unary.before = before;
			return returnAst(unary);
		}

		return returnAst(readLiteral(before));
	}

	/**Reads a literal.*/
	private function readLiteral(?before:String) : Returnable {
		function localReturn(ast: Returnable) {
			ast.after += readOneWhitespace();
			Console.log(ast.after);
			return returnAst(ast);
		}
		if (before == null) {
			before = readAndCollapseWhitespace();
		}
		var next = reader.next();

		switch (next.kind) {
			case KNumber:
				var ast = new NumberLiteral(next);
				ast.before = before;
				return localReturn(ast);

			case KString:
				var ast = new StringLiteral(next);
				ast.before = before;
				return localReturn(ast);

			default:
		}

		return null;
	}
}