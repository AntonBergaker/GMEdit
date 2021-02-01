package gml.ast;

import gml.tokenizer.Tokenizer;
import massive.munit.Assert;
import haxe.extern.EitherType;
import gml.ast.tree.*;

class AstTestHelper {
	public static function treeEquals(gmlCode:String, statementList:EitherType<Array<AstNode>, AstNode>, builder: AstBuilder) {
		if ((statementList is Array) == false) {
			statementList = [statementList];
		}
		var tree = new AstCode(new StatementList(statementList));
		var compiledTree = builder.build(gmlCode);
		var equals = AstNode.equals(tree, compiledTree);
		if (!equals) {
			Assert.fail('Trees are not identical\n\nExpected:\n${tree.toSyntaxString()}\n\nGot:\n${compiledTree.toSyntaxString()}');
		}
	}
}