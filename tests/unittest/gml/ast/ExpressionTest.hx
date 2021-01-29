package gml.ast;

import haxe.extern.EitherType;
import gml.ast.tree.*;
import massive.munit.Assert;

class ExpressionTest {
	var builder:AstBuilder;
	@Before public function setup() {
		builder = new AstBuilder(GmlVersion.v2);
	}

	@Test public function testExpression() {

		// declaration using addition
		treeEquals("var a:number = 5 + 3",
			new LocalVarDefinition([
				new VarDefinitionEntry("a",
					new TypeDefinition("number"),
					new Operation(
						new NumberLiteral("5"),
						KAdd, "+",
						new NumberLiteral("3")
					)
				)
			])
		);

		// declaration using difference
		treeEquals("var b:number = 13 - 6",
			new LocalVarDefinition([
				new VarDefinitionEntry("b",
					new TypeDefinition("number"),
					new Operation(
						new NumberLiteral("13"),
						KSub, "-",
						new NumberLiteral("6")
					)
				)
			])
		);

		// declaration using product
		treeEquals("var c:number = 20 * 4",
			new LocalVarDefinition([
				new VarDefinitionEntry("c",
					new TypeDefinition("number"),
					new Operation(
						new NumberLiteral("20"),
						KMul, "*",
						new NumberLiteral("4")
					)
				)
			])
		);

		// declaration using quotient
		treeEquals("var d:number = 64 / 8",
			new LocalVarDefinition([
				new VarDefinitionEntry("d",
					new TypeDefinition("number"),
					new Operation(
						new NumberLiteral("64"),
						KDiv, "/",
						new NumberLiteral("8")
					)
				)
			])
		);

		// declaration using addition followed by a multiplication
		treeEquals("var e:number = 5 + 3 * 2",
		new LocalVarDefinition([
			new VarDefinitionEntry("e",
				new TypeDefinition("number"),
				new Operation(
					new NumberLiteral("5"),
					KAdd,"+",
					new Operation(
						new NumberLiteral("3"),
						KMul, '*',
						new NumberLiteral("2")
					)
				)
			)
		]));

		// declaration using multiplication followed by an addition
		treeEquals("var f:number = 7 * 8 + 9",
		new LocalVarDefinition([
			new VarDefinitionEntry("f",
				new TypeDefinition("number"),
				new Operation(
					new Operation(
						new NumberLiteral("7"),
						KMul, '*',
						new NumberLiteral("8")
					),
					KAdd,"+",
					new NumberLiteral("9")
				)
			)
		]));
	}

	private function treeEquals(gmlCode:String, statementList:EitherType<Array<AstNode>, AstNode>) {
		return AstTestHelper.treeEquals(gmlCode, statementList, builder);
	}
}