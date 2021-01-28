package gml.ast;

import gml.ast.tree.TypeDefinition;
import haxe.extern.EitherType;
import gml.ast.tree.AstNode;
import gml.ast.tree.NumberLiteral;
import gml.ast.tree.VarDefinition;
import gml.ast.tree.AstCode;
import haxe.display.Protocol.Version;
import gml.ast.tree.StatementList;
import massive.munit.Assert;

class AstBuilderTest {
	var builder:AstBuilder;
	@Before public function setup() {
		builder = new AstBuilder(GmlVersion.v2);
	}

	@Test public function testVarDefinition() {
		treeEquals("var a = 5",
			new VarDefinition("a", null,
				new NumberLiteral("5")
			)
		);

		treeEquals("var a:number = 5",
			new VarDefinition("a",
				new TypeDefinition("number"),
				new NumberLiteral("5")
			)
		);
	}

	@Test public function testExpression() {
		treeEquals("var a:number = 5",
			new VarDefinition("a",
				new TypeDefinition("number"),
				new NumberLiteral("5")
			)
		);

	}


	@Test public function testBinaryEquals() {
		var codes = [
			"var a:number = 5;",
			"var a:number = 5",
			"var a:number=5",
			"var /*comment*/ a    :   number =   5;;;;"
		];

		for (code in codes) {
			Console.log(code);
			var result = builder.build(code);
			Assert.areEqual(code, result.toCompleteString());
		}
	}


	private function treeEquals(gmlCode:String, statementList:EitherType<Array<AstNode>, AstNode>) {
		if ((statementList is Array) == false) {
			statementList = [statementList];
		}
		var tree = new AstCode(new StatementList(statementList));
		var compiledTree = builder.build(gmlCode);
		var equals = AstNode.equals(tree, compiledTree);
		if (!equals) {
			Assert.fail('Tree\'s are not identical\n\nExpected:\n${tree.toSyntaxString()}\n\nGot:\n${compiledTree.toSyntaxString()}');
		}
	}
}