package gml.ast;

import ui.Preferences;
import haxe.extern.EitherType;
import gml.ast.tree.*;
import massive.munit.Assert;
import gml.ast.AstShorthand.*;

class AssignmentTest {
	var builder:AstBuilder;
	@Before public function setup() {
		builder = new AstBuilder(GmlVersion.v2, Preferences.current);
	}

	@Test public function testAssignment() {
		treeEquals("a = 5",
			cAssignment("a", null, cNumberLiteral("5"))
		);
		treeEquals("a:number = 5",
			cAssignment("a",
				cTypeDefinition("number"), 
				cNumberLiteral("5")
			)
		);
	}

	private function treeEquals(gmlCode:String, statementList:EitherType<Array<AstNode>, AstNode>) {
		return AstTestHelper.treeEquals(gmlCode, statementList, builder);
	}
}