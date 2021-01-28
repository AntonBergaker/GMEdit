package gml.ast;

import parsers.GmlReader;
import tools.Aliases.GmlCode;
import gml.ast.tree.AstNode;
import gml.ast.tree.StatementList;
import gml.ast.tree.AstCode;

class AstBuilder {
	var reader:GmlReader;
	var gmlVersion:GmlVersion;
	public function new(gmlVersion:GmlVersion) {
		
	}

	public function build(code: GmlCode):AstCode {
		reader = new GmlReader(code, gmlVersion);
		return new AstCode(readStatementList());
	}

	/**Reads statements until it encounters a closing }**/
	private function readStatementList():StatementList {
		var statements:Array<AstNode> = new Array();


		while (true) {
			var pre = reader.skipNops();
			if (reader.eof) {
				break;
			}
			var code = reader.read();

			switch code {
				case '}'.code:
					break;
			}
		}

		return new StatementList(0, 0, statements);
	}
}