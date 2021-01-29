package gml.ast;

import haxe.extern.EitherType;
import gml.ast.tree.*;
import massive.munit.Assert;

class LocalVarDefinitionTest {
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

	private function treeEquals(gmlCode:String, statementList:EitherType<Array<AstNode>, AstNode>) {
		return AstTestHelper.treeEquals(gmlCode, statementList, builder);
	}
}