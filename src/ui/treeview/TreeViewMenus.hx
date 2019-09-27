package ui.treeview;
import electron.FileSystem;
import electron.FileWrap;
import electron.Menu;
import electron.Dialog;
import file.kind.gml.KGmlMultifile;
import file.kind.misc.KExtern;
import file.kind.misc.KPlain;
import gml.GmlObjectInfo;
import gml.Project;
import haxe.io.Path;
import js.html.Element;
import gml.file.*;
import js.html.MouseEvent;
import ui.treeview.TreeView;
using tools.HtmlTools;
using tools.NativeString;
using tools.NativeArray;
import Main.*;

/**
 * Context menus for treeview items
 * @author YellowAfterlife
 */
class TreeViewMenus {
	/** treeview element that a menu was invoked at */
	public static var target:Element;
	public static var itemMenu:Menu;
	public static var dirMenu:Menu;
	public static var items:TreeViewMenuData;
	//
	public static function expandAll() {
		var cl = target.classList;
		if (!cl.contains("open")) cl.add("open");
		for (el in target.querySelectorEls('.dir')) {
			cl = el.classList;
			if (!cl.contains("open")) cl.add("open");
		}
	}
	public static function collapseAll() {
		var cl = target.classList;
		if (cl.contains("open")) cl.remove("open");
		for (el in target.querySelectorEls('.dir')) {
			cl = el.classList;
			if (cl.contains("open")) cl.remove("open");
		}
	}
	public static function openAll() {
		var found = 0;
		var els = target.querySelectorEls('.item');
		if (els.length < 50 || Dialog.showMessageBox({
			message: "Are you sure that you want to open " + els.length + " tabs?",
			buttons: ["Yes", "No"],
			cancelId: 1,
		}) == 0) for (el in els) {
			window.setTimeout(function() {
				GmlFile.open(el.innerText, el.getAttribute(TreeView.attrPath));
			}, found * 50);
			found += 1;
		}
	}
	public static function openCombined() {
		var items = [];
		var error = "";
		var mpath = "";
		for (item in target.querySelectorEls('.item[${TreeView.attrKind}="script"]')) {
			var path = item.getAttribute(TreeView.attrPath);
			var ident = item.getAttribute(TreeView.attrIdent);
			if (mpath != "") mpath += "|";
			mpath += path;
			items.push({ name: ident, path: path });
		}
		if (items.length > 0) {
			var name = target.querySelector('.header').innerText;
			GmlFile.openTab(new GmlFile(name, mpath, KGmlMultifile.inst, items));
		}
	}
	//
	static function openYyShader(ext:String) {
		var name = target.getAttribute(TreeView.attrIdent) + "." + ext;
		var path = target.getAttribute(TreeView.attrPath);
		path = Path.withoutExtension(path) + "." + ext;
		GmlFile.open(name, path);
	}
	//
	static function removeFromRecentProjects() {
		RecentProjects.remove(target.getAttribute(TreeView.attrPath));
		target.parentElement.removeChild(target);
	}
	//
	public static function changeIcon(opt:{reset:Bool,open:Bool}) {
		var pj = Project.current;
		var itemPath = target.getAttribute(TreeView.attrPath);
		var def = pj.path != "" ? pj.dir : Path.directory(itemPath);
		//
		var path:String;
		if (!opt.reset) {
			var files = Dialog.showOpenDialog({
				title: "Hello",
				defaultPath: def,
				filters: [
					new DialogFilter("Images", ["png"]),
					new DialogFilter("All files", ["*"]),
				],
			});
			if (files == null || files[0] == null) return;
			path = files[0];
		} else path = null;
		//
		if (pj.path != "") {
			ProjectStyle.setItemThumb({
				thumb: path,
				ident: target.getAttribute(TreeView.attrIdent),
				kind: target.getAttribute(TreeView.attrKind),
				rel: target.getAttribute(TreeView.attrRel),
				suffix: opt.open ? ".open" : "",
			});
		} else {
			// project icons are stored in <project path>.png
			var th = itemPath + ".png";
			if (path != null) {
				FileSystem.copyFileSync(path, th);
				TreeView.setThumb(itemPath, "file:///" + th + "?v=" + Date.now().getTime());
			} else {
				if (FileSystem.existsSync(th)) FileSystem.unlinkSync(th);
				TreeView.resetThumb(itemPath);
			}
		}
	}
	//
	static function openHere() {
		var path = target.getAttribute(TreeView.attrPath);
		GmlFile.open(target.title, path, {noExtern:true});
	}
	public static function openExternal() {
		var path = target.getAttribute(TreeView.attrPath);
		if (path != null) {
			FileWrap.openExternal(path);
		} else {
			Project.current.openExternal(target.getAttribute(TreeView.attrRel));
		}
	}
	public static function openDirectory() {
		var path = target.getAttribute(TreeView.attrPath);
		if (path != null) {
			FileWrap.showItemInFolder(path);
		} else {
			Project.current.showItemInFolder(target.getAttribute(TreeView.attrRel));
		}
	}
	public static function openObjectInfo() {
		GmlObjectInfo.showFor(
			target.getAttribute(TreeView.attrPath),
			target.getAttribute(TreeView.attrIdent)
		);
	}
	static function findReferences() {
		GlobalSearch.findReferences(target.getAttribute(TreeView.attrIdent));
	}
	public static function showAPI() {
		gml.GmlExtensionAPI.showFor(
			target.getAttribute(TreeView.attrPath),
			target.getAttribute(TreeView.attrIdent)
		);
	}
	//
	public static function showDirMenu(el:Element, ev:MouseEvent) {
		target = el;
		items.openAll.enabled = el.querySelector('.item') != null;
		items.openCombined.enabled = el.querySelector('.item[${TreeView.attrKind}="script"]') != null;
		items.changeOpenIcon.visible = true;
		items.resetOpenIcon.visible = true;
		items.openCustomCSS.visible = true;
		var isFileDir = target.getAttribute(TreeView.attrFilter) == "file";
		items.openExternally.visible = isFileDir;
		items.openDirectory.visible = isFileDir;
		items.showAPI.visible = switch (Project.current.version) {
			case v1, v2: el.getAttribute(TreeView.attrRel).startsWith("Extensions/");
			default: false;
		}
		TreeViewItemMenus.update(true);
		TreeView.signal("dirMenu", { element: el, event: ev });
		el.classList.add("selected");
		dirMenu.popupAsync(ev, () -> el.classList.remove("selected"));
	}
	public static function showItemMenu(el:Element, ev:MouseEvent) {
		var z:Bool;
		target = el;
		var kind = el.getAttribute(TreeView.attrKind);
		z = gml.GmlAPI.version == v2 && kind == "shader";
		items.shaderItems.forEach(function(q) q.visible = z);
		//
		z = kind == "project";
		items.removeFromRecentProjects.visible = z;
		items.openCustomCSS.visible = !z;
		//
		items.openExternally.visible = true;
		items.openDirectory.visible = true;
		//
		items.changeOpenIcon.visible = false;
		items.resetOpenIcon.visible = false;
		items.objectInfo.visible = kind == "object";
		items.findReferences.enabled = ~/^\w+$/g.match(el.getAttribute(TreeView.attrIdent));
		TreeViewItemMenus.update(false);
		TreeView.signal("itemMenu", { element: el, event: ev });
		el.classList.add("selected");
		itemMenu.popupAsync(ev, () -> el.classList.remove("selected"));
	}
	//
	static function initIconMenu() {
		var iconMenu = new Menu();
		addLink(iconMenu, "Change icon", function() {
			changeIcon({ reset: false, open: false });
		});
		addLink(iconMenu, "Reset icon", function() {
			changeIcon({ reset: true, open: false });
		});
		items.changeOpenIcon = addLink(iconMenu, 'Change "open" icon', function() {
			changeIcon({ reset: false, open: true });
		});
		items.resetOpenIcon = addLink(iconMenu, 'Reset "open" icon', function() {
			changeIcon({ reset: true, open: true });
		});
		items.openCustomCSS = addLink(iconMenu, "Open custom CSS file", function() {
			var path = ProjectStyle.getPath();
			if (!FileSystem.existsSync(path)) FileSystem.writeFileSync(path, "");
			electron.Shell.openItem(path);
		});
		return new MenuItem({ label: "Custom icon", type: Sub, submenu: iconMenu });
	}
	//
	public static function add(m:Menu, o:MenuItemOptions) {
		var r = new MenuItem(o);
		m.append(r);
		return r;
	}
	public static inline function addLink(m:Menu, label:String, click:Void->Void) {
		return add(m, { label: label, click: click });
	}
	public static function init() {
		var isNative = electron.Electron.isAvailable();
		//
		items = new TreeViewMenuData();
		var iconItem = initIconMenu();
		TreeViewItemMenus.init();
		//{
		itemMenu = new Menu();
		items.shaderItems = [
			addLink(itemMenu, "Open vertex shader", function() openYyShader("vsh")),
			addLink(itemMenu, "Open fragment shader", function() openYyShader("fsh")),
		];
		if (isNative) {
			items.openExternally = addLink(itemMenu, "Open externally", openExternal);
			items.openDirectory = addLink(itemMenu, "Show in directory", openDirectory);
		}
		addLink(itemMenu, "Open here", openHere);
		items.objectInfo = addLink(itemMenu, "Object information", openObjectInfo);
		items.findReferences = addLink(itemMenu, "Find references", findReferences);
		items.removeFromRecentProjects =
			addLink(itemMenu, "Remove from Recent projects", removeFromRecentProjects);
		itemMenu.appendSep();
		for (q in items.manipOuter) itemMenu.append(q);
		itemMenu.append(iconItem);
		//}
		//{
		dirMenu = new Menu();
		addLink(dirMenu, "Expand all", expandAll);
		addLink(dirMenu, "Collapse all", collapseAll);
		items.showAPI = addLink(dirMenu, "Show API", showAPI);
		items.openAll = addLink(dirMenu, "Open all", openAll);
		items.openCombined = addLink(dirMenu, "Open combined view", openCombined);
		if (isNative) {
			dirMenu.append(items.openExternally);
			dirMenu.append(items.openDirectory);
		}
		dirMenu.appendSep();
		for (q in items.manipOuter) dirMenu.append(q);
		dirMenu.append(iconItem);
		//}
	}
}
private class TreeViewMenuData {
	public var openAll:MenuItem;
	public var openCombined:MenuItem;
	public var openExternally:MenuItem;
	public var openDirectory:MenuItem;
	//
	public var objectInfo:MenuItem;
	public var findReferences:MenuItem;
	public var showAPI:MenuItem;
	//
	public var changeOpenIcon:MenuItem;
	public var resetOpenIcon:MenuItem;
	public var openCustomCSS:MenuItem;
	//
	public var manipCreate:MenuItem;
	public var manipOuter:Array<MenuItem> = [];
	public var manipDirOnly:Array<MenuItem> = [];
	public var manipNonRoot:Array<MenuItem> = [];
	//
	public var removeFromRecentProjects:MenuItem;
	public var shaderItems:Array<MenuItem>;
	//
	public function new() { }
}
