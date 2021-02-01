package gml.ast;

import ui.Preferences;
import haxe.extern.EitherType;
import gml.ast.tree.*;
import massive.munit.Assert;
import gml.ast.AstShorthand.*;

class LocalVarDefinitionTest {
	var builder:AstBuilder;
	@Before public function setup() {
		builder = new AstBuilder(GmlVersion.v2, Preferences.current);
	}

	@Test public function testLocalVarDefinition() {
		treeEquals("var a = 5",
			cLocalVarDefinition([
				cLocalVarDefinitionEntry("a", null,
					cNumberLiteral("5")
				)
			])
		);

		treeEquals("var a:number = 5",
			cLocalVarDefinition([
				cLocalVarDefinitionEntry("a",
					cTypeDefinition("number"),
					cNumberLiteral("5")
				)
			])
		);

		treeEquals("var a, b = 5",
			cLocalVarDefinition([
				cLocalVarDefinitionEntry("a", null, null),
				cLocalVarDefinitionEntry("b", null,
					cNumberLiteral("5")
				)
			])
		);

		treeEquals("var a:number = 4, b:string = \"5\"",
			cLocalVarDefinition([
				cLocalVarDefinitionEntry("a", 
					cTypeDefinition("number"),
					cNumberLiteral("4")
				),
				cLocalVarDefinitionEntry("b", 
					cTypeDefinition("string"),
					cStringLiteral("5")
				)
			])
		);
	}

	private function treeEquals(gmlCode:String, statementList:EitherType<Array<AstNode>, AstNode>) {
		return AstTestHelper.treeEquals(gmlCode, statementList, builder);
	}
}