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
		treeEquals("var a:number = 5 + 3",
			new LocalVarDefinition([
				new VarDefinitionEntry("a",
					new TypeDefinition("number"),
					new Operation(
						new NumberLiteral("5"),
						new NumberLiteral("3"),
						KAdd,
						"+"
					)
				)
			])
		);

		treeEquals("var a:number = 5 + 3 * 2",
		new LocalVarDefinition([
			new VarDefinitionEntry("a",
				new TypeDefinition("number"),
				new Operation(
					new NumberLiteral("5"),
					new Operation(
						new NumberLiteral("3"),
						new NumberLiteral("2"),
					KMul, '*'),
				KAdd,"+")
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
		return AstTestHelper.treeEquals(gmlCode, statementList, builder);
	}
}