package gml.ast;

import ui.Preferences;
import haxe.extern.EitherType;
import gml.ast.tree.*;
import massive.munit.Assert;
import gml.ast.AstShorthand.*;

class StatementTest {
	var builder:AstBuilder;
	@Before public function setup() {
		builder = new AstBuilder(GmlVersion.v2, Preferences.current);
	}

	@Test public function testIf() {
		treeEquals("if (5 > 3) a = 5",
			cIfCondition(
				cParentheses(
					cOperation(
						cNumberLiteral("5"),
						'>',
						cNumberLiteral("3")
					)
				),
				cAssignment(
					"a", null,
					cNumberLiteral("5")
				)
			)
		);

		treeEquals("if (3 != 7) {var a = 5; var b = 7;}",
			cIfCondition(
				cParentheses(
					cOperation(
						cNumberLiteral("3"),
						'!=',
						cNumberLiteral("7")
					)
				),
				cStatementList([
					cLocalVarDefinition([
						cLocalVarDefinitionEntry(
							"a", null, cNumberLiteral("5")
						)
					]),
					cLocalVarDefinition([
						cLocalVarDefinitionEntry(
							"b", null, cNumberLiteral("7")
						)
					])
				])
			)
		);
	}

	private function treeEquals(gmlCode:String, statementList:EitherType<Array<AstNode>, AstNode>) {
		return AstTestHelper.treeEquals(gmlCode, statementList, builder);
	}
}