typedef external_call_type;
typedef external_value_type;
typedef external_function;

//
typedef ds_type;
typedef ds_map;
typedef ds_list;
typedef ds_stack;
typedef ds_queue;
typedef ds_grid;
typedef ds_priority;

// Asset types
typedef asset;
typedef sprite : asset;
typedef sound : asset;
typedef path : asset;
typedef script : asset;
typedef shader : asset;
typedef font : asset;
typedef timeline : asset;
typedef object : asset;
typedef room : asset;
typedef audio_group : asset;

// Types that generally have some data attached to them
typedef datetime
typedef pointer
typedef mp_grid
typedef buffer
typedef surface
typedef texture
typedef audio_emitter
typedef sound_instance
typedef sound_sync_group
typedef sound_play_queue
typedef html_clickable
typedef html_clickable_tpe
typedef texture_group
typedef file_handle
typedef binary_file_handle
typedef particle
typedef particle_system
typedef particle_emitter
typedef virtual_key
typedef physics_fixture
typedef physics_joint
typedef physics_particle
typedef physics_particle_group
typedef network_socket
typedef network_server
typedef vertex_buffer
typedef steam_id
typedef steam_ugc
typedef steam_ugc_query
typedef shader_sampler
typedef shader_uniform
typedef vertex_format
typedef vertex_buffer

// Things inheriting from uncompareable shouldn't be compared to each other
typedef uncompareable

// Dumb types, only used as function arguments, can't be created
typedef timezone_type : uncompareable
typedef gamespeed_type : uncompareable
typedef path_endaction : uncompareable
typedef event_type : uncompareable
typedef event_number : uncompareable
typedef mouse_button : uncompareable
typedef bbox_mode : uncompareable
typedef bbox_kind : uncompareable
typedef horizontal_alignment : uncompareable
typedef vertical_alignment : uncompareable
typedef primitive_type : uncompareable
typedef blendmode : uncompareable
typedef blendmode_ext : uncompareable
typedef texture_mip_filter : uncompareable
typedef texture_mip_state : uncompareable
typedef audio_falloff_model : uncompareable
typedef audio_sound_channel : uncompareable
typedef display_orientation : uncompareable
typedef window_cursor : uncompareable
typedef buffer_kind : uncompareable//buffer_grow etc
typedef buffer_type : uncompareable //buffer_s8 etc
typedef sprite_speed_type : uncompareable
typedef asset_type : uncompareable
typedef buffer_auto_type // magic - picks up the type from the nearby buffer_type argument
typedef file_attribute : int
typedef particle_shape : uncompareable
typedef particle_distribution : uncompareable
typedef particle_region_shape : uncompareable
typedef effect_kind : uncompareable
typedef matrix_type : uncompareable
typedef os_type : uncompareable
typedef browser_type : uncompareable
typedef device_type : uncompareable
typedef openfeint_challenge : uncompareable
typedef achievement_leaderboard_filter : uncompareable
typedef achievement_challenge_type : uncompareable
typedef achievement_async_id : uncompareable
typedef achievement_show_type : uncompareable
typedef iap_system_status : uncompareable
typedef iap_order_status : uncompareable
typedef iap_async_id : uncompareable
typedef iap_async_storeload : uncompareable
typedef gamepad_button : uncompareable
typedef physics_debug_flag : int
typedef physics_joint_value
typedef physics_particle_flag : int
typedef physics_particle_data_flag : int
typedef physics_particle_group_flag : int
typedef network_type : uncompareable
typedef network_config : uncompareable
typedef network_async_id : uncompareable
typedef buffer_seek_base : uncompareable
typedef steam_overlay_page : uncompareable
typedef steam_leaderboard_sort_type : uncompareable
typedef steam_leaderboard_display_type : uncompareable
typedef steam_ugc_type : uncompareable
typedef steam_ugc_async_result : uncompareable
typedef steam_ugc_visibility : uncompareable
typedef steam_ugc_query_type : uncompareable
typedef steam_ugc_query_list_type : uncompareable
typedef steam_ugc_query_match_type : uncompareable
typedef steam_ugc_query_sort_order : uncompareable
typedef vertex_type : uncompareable
typedef vertex_usage : uncompareable
typedef layer_element_type : uncompareable