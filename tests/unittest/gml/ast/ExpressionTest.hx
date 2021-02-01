package gml.ast;

import ui.Preferences;
import haxe.extern.EitherType;
import gml.ast.tree.*;
import massive.munit.Assert;
import gml.ast.AstShorthand.*;

class ExpressionTest {
	var builder:AstBuilder;
	@Before public function setup() {
		builder = new AstBuilder(GmlVersion.v2, Preferences.current);
	}

	@Test public function testExpression() {

		// declaration using addition
		treeEquals("var a:number = 5 + 3",
			cLocalVarDefinition([
				cLocalVarDefinitionEntry("a",
					cTypeDefinition("number"),
					cOperation(
						cNumberLiteral("5"),
						KAdd, "+",
						cNumberLiteral("3")
					)
				)
			])
		);

		// declaration using difference
		treeEquals("var b:number = 13 - 6",
			cLocalVarDefinition([
				cLocalVarDefinitionEntry("b",
					cTypeDefinition("number"),
					cOperation(
						cNumberLiteral("13"),
						KSub, "-",
						cNumberLiteral("6")
					)
				)
			])
		);

		// declaration using product
		treeEquals("var c:number = 20 * 4",
			cLocalVarDefinition([
				cLocalVarDefinitionEntry("c",
					cTypeDefinition("number"),
					cOperation(
						cNumberLiteral("20"),
						KMul, "*",
						cNumberLiteral("4")
					)
				)
			])
		);

		// declaration using quotient
		treeEquals("var d:number = 64 / 8",
			cLocalVarDefinition([
				cLocalVarDefinitionEntry("d",
					cTypeDefinition("number"),
					cOperation(
						cNumberLiteral("64"),
						KDiv, "/",
						cNumberLiteral("8")
					)
				)
			])
		);

		// declaration using addition followed by a multiplication
		treeEquals("var e:number = 5 + 3 * 2",
			cLocalVarDefinition([
				cLocalVarDefinitionEntry("e",
					cTypeDefinition("number"),
					cOperation(
						cNumberLiteral("5"),
						KAdd,"+",
						cOperation(
							cNumberLiteral("3"),
							KMul, '*',
							cNumberLiteral("2")
						)
					)
				)
			])
		);

		// declaration using multiplication followed by an addition
		treeEquals("var f:number = 7 * 8 + 9",
			cLocalVarDefinition([
				cLocalVarDefinitionEntry("f",
					cTypeDefinition("number"),
					cOperation(
						cOperation(
							cNumberLiteral("7"),
							KMul, '*',
							cNumberLiteral("8")
						),
						KAdd,"+",
						cNumberLiteral("9")
					)
				)
			])
		);

		// Unary
		treeEquals("var g = 7 * +1",
			cLocalVarDefinition([
				cLocalVarDefinitionEntry("g", null,
					cOperation(
						cNumberLiteral("7"),
						KMul, '*',
						cUnary(KAdd, '+',
							cNumberLiteral("1")
						)
					)
				)
			])
		);
	}

	@Test public function ternary() {
		treeEquals("var a = 5 > 10 ? 10 + 15 : 20",
			cLocalVarDefinition([
				cLocalVarDefinitionEntry("a", null,
					cTernary(
						cOperation(
							cNumberLiteral("5"),
							KGT, '>',
							cNumberLiteral("10")
						),
						cOperation(
							cNumberLiteral("10"),
							KAdd, '+',
							cNumberLiteral("15")
						),
						cNumberLiteral("20")
					)
				)
			])
		);
	}

	private function treeEquals(gmlCode:String, statementList:EitherType<Array<AstNode>, AstNode>) {
		return AstTestHelper.treeEquals(gmlCode, statementList, builder);
	}
}