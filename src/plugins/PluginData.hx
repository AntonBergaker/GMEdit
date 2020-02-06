package plugins;

/**
 * ...
 * @author YellowAfterlife
 */
typedef PluginData = {
	/**
	 * Called after all of plugin's files are loaded up.
	 */
	?init:(state:PluginState)->Void,
	
	/**
	 * Called before unloading the plugin (currently you cannot)
	 */
	?cleanup:()->Void,
}
