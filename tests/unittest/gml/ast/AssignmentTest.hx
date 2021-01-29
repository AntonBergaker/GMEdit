package gml.ast;

import haxe.extern.EitherType;
import gml.ast.tree.*;
import massive.munit.Assert;

class AssignmentTest {
	var builder:AstBuilder;
	@Before public function setup() {
		builder = new AstBuilder(GmlVersion.v2);
	}

	@Test public function testAssignment() {
		treeEquals("a = 5",
			new Assignment("a", null, new NumberLiteral("5"))
		);
		treeEquals("a:number = 5",
			new Assignment("a",
				new TypeDefinition("number"), 
				new NumberLiteral("5")
			)
		);
	}

	private function treeEquals(gmlCode:String, statementList:EitherType<Array<AstNode>, AstNode>) {
		return AstTestHelper.treeEquals(gmlCode, statementList, builder);
	}
}