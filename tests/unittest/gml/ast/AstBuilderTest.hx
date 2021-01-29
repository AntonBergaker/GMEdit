package gml.ast;

import haxe.extern.EitherType;
import gml.ast.tree.*;
import massive.munit.Assert;

class AstBuilderTest {
	var builder:AstBuilder;
	@Before public function setup() {
		builder = new AstBuilder(GmlVersion.v2);
	}

	@Test public function testLocalVarDefinition() {
		treeEquals("var a = 5",
			new LocalVarDefinition([
				new VarDefinitionEntry("a", null,
					new NumberLiteral("5")
				)
			])
		);

		treeEquals("var a:number = 5",
			new LocalVarDefinition([
				new VarDefinitionEntry("a",
					new TypeDefinition("number"),
					new NumberLiteral("5")
				)
			])
		);

		treeEquals("var a, b = 5",
			new LocalVarDefinition([
				new VarDefinitionEntry("a", null, null),
				new VarDefinitionEntry("b", null,
					new NumberLiteral("5")
				)
			])
		);

		treeEquals("var a:number = 4, b:string = \"5\"",
			new LocalVarDefinition([
				new VarDefinitionEntry("a", 
					new TypeDefinition("number"),
					new NumberLiteral("4")
				),
				new VarDefinitionEntry("b", 
					new TypeDefinition("string"),
					new StringLiteral("5")
				)
			])
		);
	}

	@Test public function testExpression() {
		treeEquals("var a:number = 5",
			new LocalVarDefinition([
				new VarDefinitionEntry("a",
					new TypeDefinition("number"),
					new NumberLiteral("5")
				)
			])
		);

	}


	@Test public function testBinaryEquals() {
		var codes = [
			"var a:number = 5;",
			"var a:number = 5",
			"var a:number=5",
			"var /*comment*/ a    :   number =   5;;;;",
			"/*comment*/ var a = 5 //comment",
		];

		for (code in codes) {
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