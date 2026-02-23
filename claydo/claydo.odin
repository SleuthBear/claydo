package claydo

import "base:intrinsics"
import "base:runtime"
import "core:mem"

// NOTE -- TYPES --
Color :: [4]f32
Wrap_Mode :: enum {
	WRAP_WORDS,
	WRAP_NEWLINES,
	WRAP_NONE,
}
Padding :: struct {
	left, right, top, bottom: f32
}
Sizing :: struct {
	width, height: Sizing_Axis,
	type: Sizing_Type,
}
Sizing_Type :: enum {
	FIT,
	GROW,
	PERCENT,
	FIXED,
}
Sizing_Axis :: union {
	Percent,
	Sizing_Min_Max,
}
Percent :: distinct f32
Sizing_Min_Max :: struct {
	min, max: f32
}
Bounding_Box :: struct {
	x, y: f32,
	width, height: f32
}
Alignment :: enum {
	LEFT,
	RIGHT,
	CENTER,
}
Text_Element_Config :: struct {
	user_ptr: rawptr,
	text_color: Color,
	font_id: u16,
	font_size: f32,
	spacing: f32,
	line_height: f32,
	wrap_mode: Wrap_Mode,
	alignment: Alignment,
}
Aspect_Ratio :: distinct f32
Image_Data :: distinct rawptr
Attach_Point_Type :: enum {
	LEFT_TOP,
	LEFT_CENTER,
	LEFT_BOTTOM,
	CENTER_TOP,
	CENTER_CENTER,
	CENTER_BOTTOM,
	RIGHT_TOP,
	RIGHT_CENTER,
	RIGHT_BOTTOM
}
Floating_Attach_Points :: struct {
	element: Attach_Point_Type,
	parent: Attach_Point_Type,
}
Pointer_Capture_Mode :: enum {
	CAPTURE,
	PASSTHROUGH,
}
Floating_Attach_To_Element :: enum {
	NONE,
	PARENT,
	ELEMENT_WITH_ID,
	ROOT,
}
Floating_Clip_To_Element :: enum {
	NONE,
	ATTACHED_PARENT,
}
Floating_Element_Config :: struct {
	offset: [2]f32,
	expand: [2]f32,
	parent_id: u32,
	z_idx: i16,
	attach_points: Floating_Attach_Points,
	pointer_capture_mode: Pointer_Capture_Mode,
	attach_to: Floating_Attach_To_Element,
	clip_to: Floating_Clip_To_Element,
}
Custom_Element_Config :: distinct rawptr
Clip_Element_Config :: struct {
	horizontal: bool,
	vertical: bool,
	child_offset: [2]f32,
}
Border_Width :: struct {
	left, right, top, bottom: f32,
	between_children: f32,
}
Border_Element_Config :: struct {
	color: Color,
	width: Border_Width,
}
Corner_Radius :: struct {
	top_left,
	top_right,
	bottom_left,
	bottom_right: f32
}
Text_Render_Data :: struct {
	text: string,
	color: Color,
	font_id: u16,
	font_size: f32,
	spacing: f32,
	line_height: f32,
}
Rectangle_Render_Data :: struct {
	color: Color,
	corner_radius: Corner_Radius,
}
Image_Render_Data :: struct {
	color: Color,
	corner_radius: Corner_Radius,
	data: Image_Data,
}
Custom_Render_Data :: struct {
	color: Color,
	corner_radius: Corner_Radius,
	data: rawptr
}
Scroll_Render_Data :: struct {
	horizontal: bool,
	vertical: bool,
}
Border_Render_Data :: struct {
	color: Color,
	corner_radius: Corner_Radius,
	width: Border_Width,
}
Render_Data :: union {
	Text_Render_Data,
	Rectangle_Render_Data,
	Image_Render_Data,
	Custom_Render_Data,
	Scroll_Render_Data,
	Border_Render_Data
}
Render_Command :: struct {
	bounding_box: Bounding_Box,
	render_data: Render_Data,
	user_data: rawptr,
	id: u32,
	z_idx: i16,
	// No need for command type, as we can switch on the type of Render_Data
}
Scroll_Container_Data :: struct {
	scroll_position: ^[2]f32,
	dimensions: [2]f32,
	content_dimensions: [2]f32,
	config: Clip_Element_Config,
	found: bool,
}
Cursor_Data_Interaction_State :: enum {
	PRESSED_THIS_FRAME,
	PRESSED,
	RELEASED_THIS_FRAME,
	RELEASED,
}
Cursor_Data :: struct {
	position: [2]f32,
	state: Cursor_Data_Interaction_State,
}
Layout_Alignment_X :: enum {
	LEFT,
	RIGHT,
	CENTER,
}
Layout_Alignment_Y :: enum {
	TOP,
	BOTTOM,
	CENTER,
}
Child_Alignment :: struct {
	x: Layout_Alignment_X,
	y: Layout_Alignment_Y,
}
Layout_Direction :: enum {
	LEFT_TO_RIGHT,
	TOP_TO_BOTTOM,
}
Layout_Config :: struct {
	sizing: Sizing,
	padding: Padding,
	child_gap: f32,
	child_alignment: Child_Alignment,
	direction: Layout_Direction,
}
Element_Declaration :: struct {
	layout: Layout_Config,
	color: Color,
	corner_radius: Corner_Radius,
	aspect_ratio: Aspect_Ratio,
	image: Image_Data,
	floating: Floating_Element_Config,
	custom: Custom_Element_Config,
	clip: Clip_Element_Config,
	border: Border_Element_Config,
	user_ptr: rawptr,
}
Element_Data :: struct {
	bounding_box: Bounding_Box,
	found: bool,
}
Error_Type :: enum {
	TEXT_MEASUREMENT_FUNCTION_NOT_PROVIDED,
	ARENA_CAPACITY_EXCEEDED,
	ELEMENTS_CAPACITY_EXCEEDED,
	MEASUREMENT_CAPACITY_EXCEEDED,
	DUPLICATE_ID,
	FLOATING_CONTAINER_PARENT_NOT_FOUND,
	PERCENTAGE_OVER_1,
	INTERNAL_ERROR,
	UNBALANCED_OPEN_CLOSE,
}
Error_Data :: struct {
	type: Error_Type,
	text: string,
	user_ptr: rawptr,
}

// NOTE - Implementation -
Boolean_Warnings :: struct {
	max_elements_exceeded,
	max_render_commands_exceeded,
	max_text_measure_cache_exceeded,
	text_measurement_function_not_set: bool
}

Warning :: struct {
	base_message: string,
	dynamic_message: string,
}

Shared_Element_Config :: struct {
	color: Color,
	corner_radius: Corner_Radius,
	user_ptr: rawptr
}

Element_Config_Type :: enum {
	NONE,
	BORDER,
	FLOATING,
	CLIP,
	ASPECT,
	IMAGE,
	TEXT,
	CUSTOM,
	SHARED,
}

Element_Config :: union {
	^Text_Element_Config,
	^Aspect_Ratio,
	^Image_Data,
	^Floating_Element_Config,
	^Custom_Element_Config,
	^Clip_Element_Config,
	^Border_Element_Config,
	^Shared_Element_Config,
}
Wrapped_Text_Line :: struct {
	dimensions: [2]f32,
	text: string,
}
Text_Element_Data :: struct {
	text: string,
	preferred_dimensions: [2]f32,
	idx: int,
	wrapped_lines: []Wrapped_Text_Line
}
Layout_Element_Children :: distinct Array(int)
Layout_Element :: struct {
	children_or_text: union {^Text_Element_Data, Layout_Element_Children},
	dimensions: [2]f32,
	min_dimensions: [2]f32,
	layout_config: ^Layout_Config,
	 element_configs: Array(Element_Config), // TODO how big should this be?
	id: u32,
	floating_children_count: u16
}
Scroll_Container_Data_Internal :: struct {
	layout_element: ^Layout_Element,
	bounding_box: Bounding_Box,
	content_size: [2]f32,
	scroll_origin: [2]f32,
	cursor_origin: [2]f32,
	scroll_momentum: [2]f32,
	scroll_position: [2]f32,
	previous_delta: [2]f32,
	momentum_time: f32,
	element_id: u32,
	open_this_frame: bool,
	cursor_scroll_active: bool,
}
Debug_Element_Data :: struct {
	collision: bool,
	collapsed: bool,
}
Element_ID :: struct {
	id, offset, base_id: u32,
	string_id: string,

}
Layout_Element_Hash_Map_Item :: struct {
	bounding_box: Bounding_Box,
	element_id: Element_ID,
	layout_element: ^Layout_Element,
	on_hover_function: proc(Element_ID, Cursor_Data, rawptr),
	hover_function_user_ptr: rawptr,
	next_idx: int,
	generation: u32,
	debug_data: ^Debug_Element_Data,
}
Measured_Word :: struct {
	start_offset, length, next: int,
	width: f32,
}
Measure_Text_Cache_Item :: struct {
	unwrapped_dimension: [2]f32,
	measured_words_start_idx: int,
	min_width: f32,
	id: u32,
	next_idx: int,
	generation: u32,
	contains_new_lines: bool,
}
Layout_Element_Tree_Node :: struct {
	layout_element: ^Layout_Element,
	position: [2]f32,
	next_child_offset: [2]f32,
}
Layout_Element_Tree_Root :: struct {
	layout_element_idx: int,
	parent_id: u32,
	clip_element_id: u32,
	z_idx: i16,
	cursor_offset: [2]f32,
}
Array :: struct($T: typeid) {
	items: []T,
	len: int,
	cap: int,
}
Debug_Element_Config_Type_Label_Config :: struct {
	label: string,
	color: Color,
}
Render_Debug_Layout_Data :: struct {
	row_count: int,
	selected_element_row_idx: int
}
Error_Handler :: struct {
	err_proc: proc(Error_Data),
	user_ptr: rawptr
}
// I assume one state at a time. This is probably wrong, but should be easy enough to fix later
State :: struct {
	measure_text: proc(string, Text_Element_Config, rawptr) -> [2]f32,
	query_scroll_offset: proc(element_id: u32, user_ptr: rawptr) -> [2]f32,
	max_element_count: int,
	max_measure_text_cache_word_count: int,
	warnings_enabled: bool,
	error_handler: Error_Handler,
	boolean_warnings: Boolean_Warnings,
	warnings: Array(Warning),

	cursor_info: Cursor_Data,
	layout_dimensions: [2]f32,
	dynamic_element_idx_base_hash: Element_ID,
	dynamic_element_idx: u32,
	debug_mode_enabled: bool,
	disable_culling: bool,
	external_scroll_handling_enabled: bool,
	debug_selected_element_id: u32,
	generation: u32,
	measure_text_user_ptr: rawptr,
	query_scroll_offset_user_ptr: rawptr,
	arena_internal: mem.Arena,
	arena: runtime.Allocator,

	layout_elements: Array(Layout_Element),
	render_commands: Array(Render_Command),
	open_layout_element_stack: Array(int),
	layout_element_children: Layout_Element_Children,
	layout_element_children_buffer: Array(int),
	text_element_data: Array(Text_Element_Data),
	aspect_ratio_element_idxs: Array(int),
	reusable_element_idx_buffer: Array(int),
	layout_element_clip_element_ids: Array(int),

	layout_configs: Array(Layout_Config),
	element_configs: Array(Element_Config),
	text_element_configs: Array(Text_Element_Config),
	aspect_ratio_element_configs: Array(Aspect_Ratio),
	image_element_configs: Array(Image_Data),
	floating_element_configs: Array(Floating_Element_Config),
	clip_element_configs: Array(Clip_Element_Config),
	custom_element_configs: Array(Custom_Element_Config),
	border_element_configs: Array(Border_Element_Config),
	shared_element_configs: Array(Shared_Element_Config),

	layout_element_id_strings: Array(string),
	wrapped_text_lines: Array(Wrapped_Text_Line),
	layout_element_tree_nodes: Array(Layout_Element_Tree_Node),
	layout_element_tree_roots: Array(Layout_Element_Tree_Root),
	layout_elements_hash_map_internal: Array(Layout_Element_Hash_Map_Item),
	layout_elements_hash_map: Array(int),
	measure_text_hash_map_internal: Array(Measure_Text_Cache_Item),
	measure_text_hash_map_internal_free_list: Array(int),
	measure_text_hash_map: Array(int),
	measured_words: Array(Measured_Word),
	measured_words_free_list: Array(int),
	open_clip_element_stack: Array(int),
	cursor_over_ids: Array(Element_ID),
	scroll_container_data: Array(Scroll_Container_Data_Internal),
	tree_node_visited: Array(bool),
	dynamic_string_data: Array(byte),
	debug_element_data: Array(Debug_Element_Data),
}
DEFAULT_MAX_ELEMENT_COUNT :: 8192
DEFAULT_MAX_MEASURE_TEXT_WORD_CACHE_COUNT :: 16384
MAX_FLOAT : f32 : 999999999999999 // TODO

DEFAULT_LAYOUT_CONFIG: Layout_Config = {}
DEFAULT_TEXT_ELEMENT_CONFIG: Text_Element_Config = {}
DEFAULT_ASPECT_RATIO_ELEMENT_CONFIG: Aspect_Ratio = {}
DEFAULT_IMAGE_ELEMENT_CONFIG: Image_Data = {}
DEFAULT_FLOATING_ELEMENT_CONFIG: Floating_Element_Config = {}
DEFAULT_CUSTOM_ELEMENT_CONFIG: Custom_Element_Config = {}
DEFAULT_CLIP_ELEMENT_CONFIG: Clip_Element_Config = {}
DEFAULT_BORDER_ELEMENT_CONFIG: Border_Element_Config = {}
DEFAULT_SHARED_ELEMENT_CONFIG: Shared_Element_Config = {}
DEFAULT_LAYOUT_ELEMENT: Layout_Element = {}
DEFAULT_MEASURE_TEXT_CACHE_ITEM: Measure_Text_Cache_Item = {}
DEFAULT_LAYOUT_ELEMENT_HASH_MAP_ITEM: Layout_Element_Hash_Map_Item = {}
DEFAULT_CORNER_RADIUS: Corner_Radius = {}


/* This proc is some bullshit. It is also slower than hardcoding the arrays.*/
@(private="file")
default_ptr :: proc(t: typeid
) -> rawptr
{
	switch t {
	case Layout_Config: return rawptr(&DEFAULT_LAYOUT_CONFIG)
	case Text_Element_Config: return rawptr(&DEFAULT_TEXT_ELEMENT_CONFIG)
	case Aspect_Ratio: return rawptr(&DEFAULT_ASPECT_RATIO_ELEMENT_CONFIG)
	case Image_Data: return rawptr(&DEFAULT_IMAGE_ELEMENT_CONFIG)
	case Floating_Element_Config: return rawptr(&DEFAULT_FLOATING_ELEMENT_CONFIG)
	case Custom_Element_Config: return rawptr(&DEFAULT_CUSTOM_ELEMENT_CONFIG)
	case Clip_Element_Config: return rawptr(&DEFAULT_CLIP_ELEMENT_CONFIG)
	case Border_Element_Config: return rawptr(&DEFAULT_BORDER_ELEMENT_CONFIG)
	case Layout_Element: return rawptr(&DEFAULT_LAYOUT_ELEMENT)
	}
	return nil
}
s: State

// NOTE - PROCEDURES

// TODO arena stuff. I assume I can offload this to virtual.Arena, but eventually will need to do it myself.
@(private="file")
array_create :: proc($T: typeid, n: int, allo: runtime.Allocator) -> Array(T)
{
	items := make([]T, n, allo)
	return Array(T){items=items, len=0, cap=n}
}


@(private="file")
array_push :: #force_inline proc(array: ^Array($T), value: T
) -> ^T
{
	if array.len >= len(array.items) {
		return (^T)(default_ptr(T))
	}
	array.items[array.len] = value
	array.len += 1
	return &array.items[array.len-1]
}

@(private="file")
array_set :: #force_inline proc(array: ^Array($T), idx: int, value: T
) -> ^T
{
	if idx >= array.len {
		return (^T)(default_ptr(T))
	}
	array.items[idx] = value
	return &array.items[idx]
}

@(private="file")
array_get :: #force_inline proc(array: Array($T), idx: int
) -> T
{
	if idx >= array.len {
		return T{}
	}
	return array.items[idx]
}

@(private="file")
array_get_ptr :: #force_inline proc(array: ^Array($T), idx: int
) -> ^T
{
	if idx >= array.len {
		return (^T)(default_ptr(T))
	}
	return &array.items[idx]
}

@(private="file")
array_peek :: #force_inline proc(array: Array($T)
) -> T
{
	if array.len <= 0 {
		return T{}
	}
	return array.items[array.len - 1]
}

@(private="file")
array_pop :: #force_inline proc(array: ^Array($T)
) -> T
{
	if array.len <= 0 {
		return T{}
	}
	array.len -= 1
	return array.items[array.len]
}

@(private="file")
array_iter :: #force_inline proc(array: Array($T)
) -> []T
{
	return array.items[:array.len]
}

@(private="file")
write_string_to_char_buffer :: proc(text: string
) -> string
{
	offset := s.dynamic_string_data.len+1
	data := ([]byte)(s.dynamic_string_data.items[:])
	data = data[offset:]
	intrinsics.mem_copy(&data, raw_data(text), len(text))
	s.dynamic_string_data.len += len(text)
	return string(s.dynamic_string_data.items[offset:])
}

@(private="file")
get_open_layout_element :: proc() -> ^Layout_Element
{
	stack := s.open_layout_element_stack
	return array_get_ptr(&s.layout_elements, array_get(stack, stack.len-1))
}

@(private="file")
get_parent_element_id :: proc() -> u32
{
	stack := s.open_layout_element_stack
	return array_get(s.layout_elements, array_get(stack, stack.len-2)).id
}

// Storage
// // I figure the other way to do this is use a map for all the config arrays inside the global state, but that would require a lookup so is slightly slower
@(private="file")
store_layout_config :: proc(config: Layout_Config) -> ^Layout_Config { return s.boolean_warnings.max_elements_exceeded ? &DEFAULT_LAYOUT_CONFIG : array_push(&s.layout_configs, config) }
@(private="file")
store_text_element_config :: proc(config: Text_Element_Config) -> ^Text_Element_Config { return s.boolean_warnings.max_elements_exceeded ? &DEFAULT_TEXT_ELEMENT_CONFIG : array_push(&s.text_element_configs, config) }
@(private="file")
store_aspect_ratio_element_config :: proc(config: Aspect_Ratio) -> ^Aspect_Ratio { return s.boolean_warnings.max_elements_exceeded ? &DEFAULT_ASPECT_RATIO_ELEMENT_CONFIG : array_push(&s.aspect_ratio_element_configs, config) }
@(private="file")
store_image_element_config :: proc(config: Image_Data) -> ^Image_Data { return s.boolean_warnings.max_elements_exceeded ? &DEFAULT_IMAGE_ELEMENT_CONFIG : array_push(&s.image_element_configs, config) }
@(private="file")
store_floating_element_config :: proc(config: Floating_Element_Config) -> ^Floating_Element_Config { return s.boolean_warnings.max_elements_exceeded ? &DEFAULT_FLOATING_ELEMENT_CONFIG : array_push(&s.floating_element_configs, config) }
@(private="file")
store_custom_element_config :: proc(config: Custom_Element_Config) -> ^Custom_Element_Config { return s.boolean_warnings.max_elements_exceeded ? &DEFAULT_CUSTOM_ELEMENT_CONFIG : array_push(&s.custom_element_configs, config) }
@(private="file")
store_clip_element_config :: proc(config: Clip_Element_Config) -> ^Clip_Element_Config { return s.boolean_warnings.max_elements_exceeded ? &DEFAULT_CLIP_ELEMENT_CONFIG : array_push(&s.clip_element_configs, config) }
@(private="file")
store_border_element_config :: proc(config: Border_Element_Config) -> ^Border_Element_Config { return s.boolean_warnings.max_elements_exceeded ? &DEFAULT_BORDER_ELEMENT_CONFIG : array_push(&s.border_element_configs, config) }
@(private="file")
store_shared_element_config :: proc(config: Shared_Element_Config) -> ^Shared_Element_Config { return s.boolean_warnings.max_elements_exceeded ? &DEFAULT_SHARED_ELEMENT_CONFIG : array_push(&s.shared_element_configs, config) }

@(private="file")
attach_element_config :: proc(config: Element_Config
) -> Element_Config
{
	if s.boolean_warnings.max_elements_exceeded {
		return {}
	}
	open_layout_element := get_open_layout_element()
	open_layout_element.element_configs.len += 1
	return array_push(&s.element_configs, config)^ // the config is already a pointer since we don't need a type variable.
}

@(private="file")
find_element_config_with_type :: proc(element: ^Layout_Element, type: typeid
) -> Element_Config
{
	for i in 0..<s.element_configs.len {
		config := array_get(s.element_configs, i)
		if type_of(config) == type {
			return config
		}
	}
	return nil
}

@(private="file")
hash_number :: proc(offset: u32, seed: u32
) -> Element_ID
{
	hash := seed
	hash += (offset + 48)
	hash += (hash << 10)
	hash ~= (hash >> 6)

	hash += (hash << 3)
	hash ~= (hash >> 11)
	hash += (hash << 15)
	return Element_ID{id = hash+1, offset = offset, base_id = seed, string_id = ""}
}

@(private="file")
hash_string :: proc(key: string, seed: u32
) -> Element_ID
{
	hash := seed
	for ru in key {
		hash += u32(ru)
		hash += (hash << 10)
		hash ~= (hash >> 6)
	}

	hash += (hash << 3)
	hash ~= (hash >> 11)
	hash += (hash << 15)
	return Element_ID{id = hash+1, offset = 0, base_id = hash + 1, string_id = key}
}

@(private="file")
hash_string_with_offset :: proc(key: string, offset, seed: u32
) -> Element_ID
{
	base := seed
	for ru in key {
		base += u32(ru)
		base += (base << 10)
		base ~= (base >> 6)
	}
	hash := base
	hash += offset
	hash += (hash << 10)
	hash ~= (hash >> 6)

	hash += (hash << 3)
	base += (base << 3)
	hash ~= (hash >> 11)
	base ~= (base >> 11)
	hash += (hash << 15)
	base += (base << 15)
	return Element_ID{id = hash + 1, offset = offset, base_id = base + 1, string_id = key}
}

// TODO figure out how to do SIMD
@(private="file")
hash_data :: proc(data: []byte
) -> u64
{
	hash: u64 = 0
	for b in data {
		hash += u64(b)
		hash += (hash << 10)
		hash ~= (hash >> 6)
	}
	return hash
}

@(private="file")
hash_data_string :: proc(data: string
) -> u32
{
	hash: u32 = 0
	for ru in data {
		hash += u32(ru)
		hash += (hash << 10)
		hash ~= (hash >> 6)
	}
	return hash
}

@(private="file")
hash_string_content_with_config :: proc(text: string, config: ^Text_Element_Config
) -> u32
{
	// HACK not checking if statically allocated
	hash := hash_data_string(text)
	hash += u32(config.font_id)
	hash += (hash << 10)
	hash ~= (hash >> 6)

	hash += transmute(u32)(config.font_size)
	hash += (hash << 10)
	hash ~= (hash >> 6)

	hash += transmute(u32)(config.spacing)
	hash += (hash << 10)
	hash ~= (hash >> 6)

	hash += (hash << 3)
	hash ~= (hash >> 11)
	hash += (hash << 15)
	return hash + 1
}

@(private="file")
add_measured_word :: proc(word: Measured_Word, previous_word: ^Measured_Word
) -> ^Measured_Word
{
	if s.measured_words_free_list.len > 0 {
		new_item_idx := array_get(s.measured_words_free_list, s.measured_words_free_list.len - 1)
		s.measured_words_free_list.len -= 1
		array_set(&s.measured_words, new_item_idx, word)
		previous_word.next = new_item_idx
		return array_get_ptr(&s.measured_words, new_item_idx)
	}
	previous_word.next = s.measured_words.len
	return array_push(&s.measured_words, word)
}

// NOTE - Beware this procedure. Text is evil. (170 lines)
@(private="file")
measure_text_cached :: proc(text: ^string, config: ^Text_Element_Config
) -> ^Measure_Text_Cache_Item
{
	// Before setting a new item, try and clean up some of the cache
	id := hash_string_content_with_config(text^, config)
	hash_bucket := id % u32(s.max_measure_text_cache_word_count / 32)
	element_idx_previous := 0
	// get an index at random?
	element_idx := s.measure_text_hash_map.items[hash_bucket]
	for element_idx != 0 { // if it's a valid element
		// get the actual entry for the item
		hash_entry := array_get_ptr(&s.measure_text_hash_map_internal, element_idx)
		if hash_entry.id == id { // if the id matches our new string (same contents and config)
			// increment the generation so we know how recently it was touched
			hash_entry.generation = s.generation
			// return the measured details
			return hash_entry
		}
		// the hash entry hasn't been seen in a few frames, so delete
		if s.generation - hash_entry.generation > 2 {
			// get the idx to add the next word?
			next_word_idx := hash_entry.measured_words_start_idx
			// While the chain (sentence?) has more words, keep adding them to the free list
			for next_word_idx != -1 {
				measured_word := array_get(s.measured_words, next_word_idx)
				array_push(&s.measured_words_free_list, next_word_idx)
				next_word_idx = measured_word.next
			}
			next_idx := hash_entry.next_idx
			// mark the element_idx as empty in the internal array
			array_set(&s.measure_text_hash_map_internal, element_idx, Measure_Text_Cache_Item{measured_words_start_idx=-1})
			// mark that location as available on the free list
			array_push(&s.measure_text_hash_map_internal_free_list, element_idx)
			if element_idx_previous == 0 { // we are on the first loop
				s.measure_text_hash_map.items[hash_bucket] = next_idx
			} else {
				previous_hash_entry := array_get_ptr(&s.measure_text_hash_map_internal, element_idx_previous)
				// jump from previous to next (skip this location as it's now empty)
				previous_hash_entry.next_idx = hash_entry.next_idx
			}
			element_idx = next_idx
		} else {
			// If we don't need to clear the data, just move on
			element_idx_previous = element_idx
			element_idx = hash_entry.next_idx
		}
	}
	// Now add the new item
	new_item_idx := 0
	new_cache_item := Measure_Text_Cache_Item{measured_words_start_idx = -1, id = id, generation = s.generation}
	measured: ^Measure_Text_Cache_Item = nil
	if s.measure_text_hash_map_internal_free_list.len > 0 {
		new_item_idx := array_pop(&s.measure_text_hash_map_internal_free_list)
		measured = array_set(&s.measure_text_hash_map_internal, new_item_idx, new_cache_item)
	} else {
		// I wonder why this is cap -1 ...
		if s.measure_text_hash_map_internal.len == s.measure_text_hash_map_internal.cap - 1 {
			if !s.boolean_warnings.max_text_measure_cache_exceeded {
				s.error_handler.err_proc(Error_Data{
					type = .ELEMENTS_CAPACITY_EXCEEDED,
					text = "Claydo ran out of capacity while attempting to measure text elements. Try using set_max_element_count() with a higher value.",
					user_ptr = s.error_handler.user_ptr
				})
				s.boolean_warnings.max_text_measure_cache_exceeded = true
			}
			return &DEFAULT_MEASURE_TEXT_CACHE_ITEM
		}
		measured = array_push(&s.measure_text_hash_map_internal, new_cache_item)
		new_item_idx = s.measure_text_hash_map_internal.len - 1
	}

	start := 0
	end := 0
	line_width: f32 = 0
	measured_width: f32 = 0
	measured_height: f32 = 0
	space_width: f32 = s.measure_text(" ", config^, s.measure_text_user_ptr).x
	temp_word := Measured_Word{next = -1}
	previous_word: ^Measured_Word = &temp_word
	for (end < len(text)) {
		if s.measured_words.len == s.measured_words.cap - 1 {
			if !s.boolean_warnings.max_text_measure_cache_exceeded {
				s.error_handler.err_proc(Error_Data{
					type = .MEASUREMENT_CAPACITY_EXCEEDED,
					text = "Claydo has run out of space in it's internal text measurement cache. Try using set_max_measure_text_cache_word_count() (default 16384, with 1 unit storing 1 measured word).",
					user_ptr = s.error_handler.user_ptr,
				})
				s.boolean_warnings.max_text_measure_cache_exceeded = true
			}
			return &DEFAULT_MEASURE_TEXT_CACHE_ITEM
		}
		current := text[end]
		if current == ' ' || current == '\n' {
			length := end - start
			dimensions := [2]f32{}
			if length > 0 {
				dimensions = s.measure_text(text[start:start+length], config^, s.measure_text_user_ptr)
			}
			measured.min_width = max(dimensions.x, measured.min_width)
			measured_height = max(dimensions.y, measured_height)
			if current == ' ' {
				dimensions.x += space_width
				line_width += dimensions.x
				previous_word = add_measured_word(
					Measured_Word{
						start_offset = start,
						length = length + 1,
						width = dimensions.x,
						next = -1
					},
					previous_word
				)
			} else if current == '\n' {
				if length > 0 {
					previous_word = add_measured_word(
						Measured_Word{
							start_offset = start,
							length = length,
							width = dimensions.x,
							next = -1
						},
						previous_word
					)
				}
				previous_word = add_measured_word(
					Measured_Word{
						start_offset = end+1,
						length = 0,
						width = 0,
						next = -1,
					},
					previous_word
				)
				line_width += dimensions.x
				measured_width += max(line_width, measured_width)
				measured.contains_new_lines = true
				line_width = 0
			}
			start = end + 1
		}
		end += 1
	}
	if end - start > 0 {
		dimensions := s.measure_text(text[start:end], config^, s.measure_text_user_ptr)
		add_measured_word(
			Measured_Word{
				start_offset = start,
				length = end - start,
				width = dimensions.x,
				next = -1
			},
			previous_word
		)
		line_width += dimensions.x
		measured_height = max(dimensions.y, measured_height)
		measured.min_width = max(dimensions.x, measured.min_width)
	}
	measured_width = max(line_width, measured_width) - config.spacing

	measured.measured_words_start_idx = temp_word.next
	measured.unwrapped_dimension = {measured_width, measured_height}

	if element_idx_previous != 0 {
		array_get_ptr(&s.measure_text_hash_map_internal, element_idx_previous).next_idx = new_item_idx
	} else {
		s.measure_text_hash_map.items[hash_bucket] = new_item_idx
	}
	return measured
}

@(private="file")
point_is_inside_rect :: proc(point: [2]f32, rect: Bounding_Box
) -> bool
{
	return point.x >= rect.x && point.x <= rect.x + rect.width && point.y >= rect.y && point.y <= rect.y + rect.height
}

@(private="file")
add_hash_map_item :: proc(element_id: Element_ID, layout_element: ^Layout_Element
) -> ^Layout_Element_Hash_Map_Item
{
	if s.layout_elements_hash_map_internal.len == s.layout_elements_hash_map_internal.cap - 1 {
		return nil
	}
	// new item
	item := Layout_Element_Hash_Map_Item{element_id = element_id, layout_element = layout_element, next_idx = -1, generation = s.generation+1}
	hash_bucket := element_id.id % u32(s.layout_elements_hash_map.cap)
	hash_item_previous := -1
	// random layout item?
	hash_item_idx := s.layout_elements_hash_map.items[hash_bucket]
	for hash_item_idx != -1 {
		hash_item := array_get_ptr(&s.layout_elements_hash_map_internal, hash_item_idx)
		// layout item from the hash map collides with the provided id
		if hash_item.element_id == element_id {
			item.next_idx = hash_item.next_idx
			if hash_item.generation <= s.generation { // first collision. Assume same element
				// Update the hash_item
				hash_item.element_id = element_id
				hash_item.generation = s.generation + 1
				hash_item.layout_element = layout_element
				hash_item.debug_data.collision = false
				hash_item.on_hover_function = nil
				hash_item.hover_function_user_ptr = nil
			} else {
				s.error_handler.err_proc(
					Error_Data{
						type = .DUPLICATE_ID,
						text = "An element with this ID was already previously declared during this layout.",
						user_ptr = s.error_handler.user_ptr,
					})
				if s.debug_mode_enabled {
					hash_item.debug_data.collision = true
				}
			}
			return hash_item
		}
		hash_item_previous = hash_item_idx
		hash_item_idx = hash_item.next_idx
	}
	hash_item := array_push(&s.layout_elements_hash_map_internal, item)
	hash_item.debug_data = array_push(&s.debug_element_data, Debug_Element_Data{})
	if hash_item_previous != -1 {
		// If we looped through any items, and didn't collide, then make sure the last one points to the new entry
		array_get_ptr(&s.layout_elements_hash_map_internal, hash_item_previous).next_idx \
			= s.layout_elements_hash_map_internal.len - 1
	} else {
		// If we didn't iterate just set the hash map to point at the inserted location
		s.layout_elements_hash_map.items[hash_bucket] = s.layout_elements_hash_map_internal.len - 1
	}
	return hash_item
}

// Try and retrieve the item from the hash map by it's id (by doing some modulus black magic on a hash value).
// If it's not there return the default.
@(private="file")
get_hash_map_item :: proc(id: u32
) -> ^Layout_Element_Hash_Map_Item
{
	hash_bucket := id % u32(s.layout_elements_hash_map.cap)
	element_idx := s.layout_elements_hash_map.items[hash_bucket]
	for element_idx != -1 {
		hash_item := array_get_ptr(&s.layout_elements_hash_map_internal, element_idx)
		if hash_item.element_id.id == id {
			return hash_item
		}
		element_idx = hash_item.next_idx
	}
	return &DEFAULT_LAYOUT_ELEMENT_HASH_MAP_ITEM
}

@(private="file")
generate_id_for_anonymous_element :: proc(open_layout_element: ^Layout_Element
) -> Element_ID
{
	parent_idx := s.open_layout_element_stack.len - 2
	parent_element := array_get_ptr(&s.layout_elements, array_get(s.open_layout_element_stack, parent_idx))
	offset := parent_element.children_or_text.(Layout_Element_Children).len + int(parent_element.floating_children_count)
	element_id := hash_number(u32(offset), parent_element.id)
	open_layout_element.id = element_id.id
	add_hash_map_item(element_id, open_layout_element)
	array_push(&s.layout_element_id_strings, element_id.string_id)
	return element_id
}

@(private="file")
element_has_config :: proc(layout_element: ^Layout_Element, type: typeid
) -> bool
{
	for config in array_iter(layout_element.element_configs) {
		// TODO this is dumb
		if type_of(config) == type {
			return true
		}
	}
	return false
}

@(private="file")
update_aspect_ratio_box :: proc(layout_element: ^Layout_Element)
{
	for &config in array_iter(layout_element.element_configs) {
		if type_of(config) == ^Aspect_Ratio {
			aspect_config := config.(^Aspect_Ratio)
			if aspect_config^ == 0 {
				break;
			}
			if layout_element.dimensions.x == 0 && layout_element.dimensions.y != 0 {
				layout_element.dimensions.x = layout_element.dimensions.y * f32(aspect_config^)
			} else if layout_element.dimensions.x != 0 && layout_element.dimensions.y == 0 {
				layout_element.dimensions.y = layout_element.dimensions.x * f32(1 / aspect_config^)
			}
			break
		}
	}
}

@(private="file")
close_element :: proc()
{
	if s.boolean_warnings.max_elements_exceeded {
		return
	}
	open_layout_element := get_open_layout_element()
	layout_config := open_layout_element.layout_config
	if layout_config != nil {
		open_layout_element.layout_config = &DEFAULT_LAYOUT_CONFIG
		layout_config = &DEFAULT_LAYOUT_CONFIG
	}
	element_has_clip_horizontal := false
	element_has_clip_vertical := false
	// TODO make iterator
	for config in array_iter(open_layout_element.element_configs) {
		#partial switch v in config {
		case ^Clip_Element_Config: {
			element_has_clip_horizontal = v.horizontal
			element_has_clip_vertical = v.vertical
		}
		case ^Floating_Element_Config: {
			s.open_clip_element_stack.len -= 1
		}
		}
	}

	left_right_padding := layout_config.padding.left + layout_config.padding.right
	top_bottom_padding := layout_config.padding.top + layout_config.padding.bottom

	// Attach children to the current open element
	open_layout_element.children_or_text = s.layout_element_children
	if layout_config.direction == .LEFT_TO_RIGHT {
		open_layout_element.dimensions.x = left_right_padding
		open_layout_element.min_dimensions.x = left_right_padding
		for i in 0..<open_layout_element.children_or_text.(Layout_Element_Children).len {
			child_idx := array_get(s.layout_element_children_buffer, s.layout_element_children_buffer.len \
				- open_layout_element.children_or_text.(Layout_Element_Children).len + i)
			child := array_get_ptr(&s.layout_elements, child_idx)
			open_layout_element.dimensions.x += child.dimensions.x
			open_layout_element.dimensions.y = max(open_layout_element.dimensions.y, child.dimensions.y + top_bottom_padding)
			if !element_has_clip_horizontal {
				open_layout_element.min_dimensions.x += child.min_dimensions.x
			}
			if !element_has_clip_vertical {
				open_layout_element.min_dimensions.y = max(open_layout_element.min_dimensions.y, child.min_dimensions.y + top_bottom_padding)
			}
			array_push(&s.layout_element_children, child_idx)
		}
		child_gap := f32(max(open_layout_element.children_or_text.(Layout_Element_Children).len - 1, 0)) * layout_config.child_gap
		open_layout_element.dimensions.x += child_gap
		if !element_has_clip_horizontal {
			open_layout_element.min_dimensions.x += child_gap
		}
	} else if layout_config.direction == .TOP_TO_BOTTOM {
		open_layout_element.dimensions.y = top_bottom_padding
		open_layout_element.min_dimensions.y = top_bottom_padding
		for i in 0..<open_layout_element.children_or_text.(Layout_Element_Children).len {
			child_idx := array_get(s.layout_element_children_buffer, s.layout_element_children_buffer.len \
				- open_layout_element.children_or_text.(Layout_Element_Children).len + 1)
			child := array_get_ptr(&s.layout_elements, child_idx)
			open_layout_element.dimensions.y += child.dimensions.y
			open_layout_element.dimensions.x = max(open_layout_element.dimensions.x, child.dimensions.x + left_right_padding)
			if !element_has_clip_vertical {
				open_layout_element.min_dimensions.y += child.min_dimensions.y
			}
			if !element_has_clip_horizontal {
				open_layout_element.min_dimensions.x = max(open_layout_element.min_dimensions.x, child.min_dimensions.x + left_right_padding)
			}
			array_get(s.layout_element_children, child_idx)
		}
		child_gap := f32(max(open_layout_element.children_or_text.(Layout_Element_Children).len - 1, 0)) * layout_config.child_gap
		open_layout_element.dimensions.y += child_gap
		if !element_has_clip_vertical {
			open_layout_element.min_dimensions.y += child_gap
		}
	}
	s.layout_element_children_buffer.len -= open_layout_element.children_or_text.(Layout_Element_Children).len
	if type_of(layout_config.sizing.width) != Percent {
		if layout_config.sizing.width.(Sizing_Min_Max).max <= 0 {
			width := layout_config.sizing.width.(Sizing_Min_Max)
			width.max = MAX_FLOAT
			layout_config.sizing.width = width
		}
		open_layout_element.dimensions.x = min(max(open_layout_element.dimensions.x, layout_config.sizing.width.(Sizing_Min_Max).min), layout_config.sizing.width.(Sizing_Min_Max).max)
		open_layout_element.min_dimensions.x = min(max(open_layout_element.dimensions.x, layout_config.sizing.width.(Sizing_Min_Max).min), layout_config.sizing.width.(Sizing_Min_Max).max)
	} else {
		open_layout_element.dimensions.x = 0
	}

	if type_of(layout_config.sizing.height) != Percent {
		if layout_config.sizing.height.(Sizing_Min_Max).max <= 0{
			height := layout_config.sizing.height.(Sizing_Min_Max)
			height.max = MAX_FLOAT
			layout_config.sizing.width = height
		}
		open_layout_element.dimensions.y = min(max(open_layout_element.dimensions.y, layout_config.sizing.height.(Sizing_Min_Max).min), layout_config.sizing.height.(Sizing_Min_Max).max)
		open_layout_element.min_dimensions.y = min(max(open_layout_element.dimensions.y, layout_config.sizing.height.(Sizing_Min_Max).min), layout_config.sizing.height.(Sizing_Min_Max).max)
	} else {
		open_layout_element.dimensions.y = 0
	}
	update_aspect_ratio_box(open_layout_element)

	element_is_floating := element_has_config(open_layout_element, Floating_Element_Config)

	// Close current element
	closing_element_idx := array_pop(&s.open_layout_element_stack)

	open_layout_element = get_open_layout_element()

	if s.open_layout_element_stack.len > 1 {
		if element_is_floating {
			open_layout_element.floating_children_count += 1
			return
		}
		children := open_layout_element.children_or_text.(Layout_Element_Children)
		children.len += 1
		open_layout_element.children_or_text = children
		array_push(&s.layout_element_children_buffer, closing_element_idx)
	}
}

// TODO SIMD
@(private="file")
mem_cmp :: proc(s1, s2: []byte, length: int
) -> bool
{
	for i in 0..<length {
		if s1[i] != s2[i] {
			return false
		}
	}
	return true
}

@(private="file")
open_element :: proc()
{
	if s.layout_elements.len == s.layout_elements.cap - 1 || s.boolean_warnings.max_elements_exceeded {
		s.boolean_warnings.max_elements_exceeded = true
		return
	}
	layout_element: Layout_Element = {}
	open_layout_element := array_push(&s.layout_elements, layout_element)
	array_push(&s.open_layout_element_stack, s.layout_elements.len - 1)
	generate_id_for_anonymous_element(open_layout_element)
	if s.open_clip_element_stack.len > 0 {
		array_set(&s.layout_element_clip_element_ids, s.layout_elements.len - 1, array_peek(s.open_clip_element_stack))
	} else {
		array_set(&s.layout_element_clip_element_ids, s.layout_elements.len - 1, 0)
	}
}

@(private="file")
open_element_with_id :: proc(element_id: Element_ID)
{
	if s.layout_elements.len == s.layout_elements.cap - 1 || s.boolean_warnings.max_elements_exceeded {
		s.boolean_warnings.max_elements_exceeded = true
		return
	}
	layout_element: Layout_Element = {}
	layout_element.id = element_id.id
	open_layout_element := array_push(&s.layout_elements, layout_element)
	array_push(&s.open_layout_element_stack, s.layout_elements.len - 1)
	generate_id_for_anonymous_element(open_layout_element)
	if s.open_clip_element_stack.len > 0 {
		array_set(&s.layout_element_clip_element_ids, s.layout_elements.len - 1, array_peek(s.open_clip_element_stack))
	} else {
		array_set(&s.layout_element_clip_element_ids, s.layout_elements.len - 1, 0)
	}
}

@(private="file")
open_text_element :: proc(text: ^string, config: ^Text_Element_Config)
{
	if s.layout_elements.len == s.layout_elements.cap - 1 || s.boolean_warnings.max_elements_exceeded {
		s.boolean_warnings.max_elements_exceeded = true
		return
	}

	parent_element := get_open_layout_element()

	layout_element: Layout_Element = {}
	text_element := array_push(&s.layout_elements, layout_element)
	if s.open_clip_element_stack.len > 0 {
		array_set(&s.layout_element_clip_element_ids, s.layout_elements.len - 1, array_peek(s.open_clip_element_stack))
	} else {
		array_set(&s.layout_element_clip_element_ids, s.layout_elements.len - 1, 0)
	}

	array_push(&s.layout_element_children_buffer, s.layout_elements.len - 1)
	text_measured := measure_text_cached(text, config)
	element_id := hash_number(u32(parent_element.children_or_text.(Layout_Element_Children).len) + u32(parent_element.floating_children_count), parent_element.id)
	text_element.id = element_id.id
	add_hash_map_item(element_id, text_element)
	array_push(&s.layout_element_id_strings, element_id.string_id)
	text_dimensions := [2]f32{text_measured.unwrapped_dimension.x, config.line_height > 0 ? config.line_height : text_measured.unwrapped_dimension.y}
	text_element.dimensions = text_dimensions
	text_element.min_dimensions = text_dimensions
	text_element.children_or_text = array_push(&s.text_element_data, Text_Element_Data{text = text^, preferred_dimensions = text_measured.unwrapped_dimension, idx = s.layout_elements.len - 1})
	element_count := s.max_element_count
	text_element.element_configs = array_create(Element_Config, element_count, s.arena) // TODO size?
	text_element.layout_config = &DEFAULT_LAYOUT_CONFIG
	children := parent_element.children_or_text.(Layout_Element_Children)
	children.len += 1
	parent_element.children_or_text = children
}

@(private="file")
configure_open_element_ptr :: proc(declaration: ^Element_Declaration)
{
	open_layout_element := get_open_layout_element()
	open_layout_element.layout_config = store_layout_config(declaration.layout)
	if (type_of(declaration.layout.sizing.width) == Percent && declaration.layout.sizing.width.(Percent) > 1) || (type_of(declaration.layout.sizing.height) == Percent && declaration.layout.sizing.height.(Percent) > 1) {
		s.error_handler.err_proc(
			Error_Data{
				type = .PERCENTAGE_OVER_1,
				text = "An element was configured with PERCENT sizing, but the provided percentage value was over 1.0. Claydo expects a value between 0 and 1, i.e. 20% is 0.2.",
				user_ptr = s.error_handler.user_ptr,
			}
		)
	}
	open_layout_element.element_configs.items = (&s.element_configs).items[s.element_configs.len:]
	shared_config: ^Shared_Element_Config = nil
	if declaration.color.a > 0 {
		shared_config = store_shared_element_config(Shared_Element_Config{color = declaration.color})
		attach_element_config(shared_config)
	}
	if declaration.corner_radius != DEFAULT_CORNER_RADIUS {
		if shared_config != nil {
			shared_config.corner_radius = declaration.corner_radius
		} else {
			shared_config = store_shared_element_config(Shared_Element_Config{corner_radius = declaration.corner_radius})
			attach_element_config(shared_config)
		}
	}
	if declaration.user_ptr != nil {
		if shared_config != nil {
			shared_config.user_ptr = declaration.user_ptr
		} else {
			shared_config = store_shared_element_config(Shared_Element_Config{user_ptr = declaration.user_ptr})
			attach_element_config(shared_config)
		}
	}
	if declaration.image != nil {
		attach_element_config(store_image_element_config(declaration.image))
	}
	if declaration.aspect_ratio > 0 {
		attach_element_config(store_aspect_ratio_element_config(declaration.aspect_ratio))
	}
	if declaration.floating.attach_to != .NONE {
		floating_config := declaration.floating
		hierarchical_parent := array_get_ptr(&s.layout_elements, array_get(s.open_layout_element_stack, s.open_layout_element_stack.len - 2))
		if hierarchical_parent != nil {
			clip_element_id := 0
			// TODO switch
			switch declaration.floating.attach_to {
			case .PARENT: {
				// attach to direct hierarchical parent
				floating_config.parent_id = hierarchical_parent.id
				if s.open_clip_element_stack.len > 0 {
					clip_element_id = array_get(s.open_clip_element_stack, s.open_clip_element_stack.len-1)
				}
			}
			case .ELEMENT_WITH_ID: {
				parent_item := get_hash_map_item(floating_config.parent_id)
				if parent_item == &DEFAULT_LAYOUT_ELEMENT_HASH_MAP_ITEM {
					s.error_handler.err_proc(
						Error_Data{
							type = .FLOATING_CONTAINER_PARENT_NOT_FOUND,
							text = "A floating element was declared with a parent_id, but no element with that ID was found.",
							user_ptr = s.error_handler.user_ptr,
						}
					)
				} else {
					// HACK need to get the index of the layout element. I doubt this works
					clip_element_id = array_get(s.layout_element_clip_element_ids, intrinsics.ptr_sub(parent_item.layout_element, &s.layout_elements.items[0]))
				}
			}
			case .ROOT: {
				floating_config.parent_id = hash_string("Root_Container", 0).id
			}
			case .NONE:
				clip_element_id = 0
			}
			current_element_idx := array_peek(s.open_layout_element_stack)
			array_set(&s.layout_element_clip_element_ids, current_element_idx, clip_element_id)
			array_push(&s.open_clip_element_stack, clip_element_id)
			array_push(&s.layout_element_tree_roots,
				Layout_Element_Tree_Root{
					layout_element_idx = array_peek(s.open_layout_element_stack),
					parent_id = floating_config.parent_id,
					clip_element_id = u32(clip_element_id),
					z_idx = floating_config.z_idx
			})
			attach_element_config(store_floating_element_config(floating_config))
		}
	}
	if declaration.custom != nil {
		attach_element_config(store_custom_element_config(declaration.custom))
	}
	if declaration.clip.horizontal || declaration.clip.vertical {
		attach_element_config(store_clip_element_config(declaration.clip))
		array_push(&s.open_clip_element_stack, int(open_layout_element.id))
		scroll_offset : ^Scroll_Container_Data_Internal = nil
		for &mapping in array_iter(s.scroll_container_data) {
			if open_layout_element.id == mapping.element_id {
				scroll_offset = &mapping
				scroll_offset.layout_element = mapping.layout_element
				scroll_offset.open_this_frame = true
			}
		}
		if scroll_offset == nil {
			scroll_offset = array_push(&s.scroll_container_data,
				Scroll_Container_Data_Internal{
					layout_element = open_layout_element,
					scroll_origin = {-1,-1},
					element_id = open_layout_element.id,
					open_this_frame = true}
			)
		}
		if s.external_scroll_handling_enabled {
			scroll_offset.scroll_position = s.query_scroll_offset(scroll_offset.element_id, s.query_scroll_offset_user_ptr)
		}
	}
	if declaration.border.width != DEFAULT_BORDER_ELEMENT_CONFIG.width {
		attach_element_config(store_border_element_config(declaration.border))
	}
}

// 2180
@(private="file")
initialize_ephemeral_memory :: proc()
{
	max_element_count := s.max_element_count
	s.layout_element_children_buffer = array_create(int, max_element_count, s.arena)
	s.layout_elements = array_create(Layout_Element, max_element_count, s.arena)
	s.warnings = array_create(Warning, 100, s.arena)

	s.layout_configs = array_create(Layout_Config, max_element_count, s.arena)
	s.element_configs = array_create(Element_Config, max_element_count, s.arena)
	s.text_element_configs = array_create(Text_Element_Config, max_element_count, s.arena)
	s.aspect_ratio_element_configs = array_create(Aspect_Ratio, max_element_count, s.arena)
	s.image_element_configs = array_create(Image_Data, max_element_count, s.arena)
	s.floating_element_configs = array_create(Floating_Element_Config, max_element_count, s.arena)
	s.clip_element_configs = array_create(Clip_Element_Config, max_element_count, s.arena)
	s.custom_element_configs = array_create(Custom_Element_Config, max_element_count, s.arena)
	s.border_element_configs = array_create(Border_Element_Config, max_element_count, s.arena)
	s.shared_element_configs = array_create(Shared_Element_Config, max_element_count, s.arena)

	s.layout_element_id_strings = array_create(string, max_element_count, s.arena)
	s.wrapped_text_lines = array_create(Wrapped_Text_Line, max_element_count, s.arena)
	s.layout_element_tree_nodes = array_create(Layout_Element_Tree_Node, max_element_count, s.arena)
	s.layout_element_tree_roots = array_create(Layout_Element_Tree_Root, max_element_count, s.arena)
	s.layout_element_children = Layout_Element_Children((array_create(int, max_element_count, s.arena)))
	s.open_layout_element_stack = array_create(int, max_element_count, s.arena)
	s.text_element_data = array_create(Text_Element_Data, max_element_count, s.arena)
	s.aspect_ratio_element_idxs = array_create(int, max_element_count, s.arena)
	s.render_commands = array_create(Render_Command, max_element_count, s.arena)
	s.tree_node_visited = array_create(bool, max_element_count, s.arena)
	s.tree_node_visited.len = s.tree_node_visited.cap
	s.open_clip_element_stack = array_create(int, max_element_count, s.arena)
	s.reusable_element_idx_buffer = array_create(int, max_element_count, s.arena)
	s.layout_element_clip_element_ids = array_create(int, max_element_count, s.arena)
	s.dynamic_string_data = array_create(byte, max_element_count, s.arena)
}

@(private="file")
initialize_persistent_memory :: proc(s: ^State)
{
	max_element_count := s.max_element_count
	max_max_measure_text_cache_word_count := s.max_measure_text_cache_word_count
	s.scroll_container_data = array_create(Scroll_Container_Data_Internal, 100, s.arena)
	s.layout_elements_hash_map_internal = array_create(Layout_Element_Hash_Map_Item, max_element_count, s.arena)
	s.layout_elements_hash_map = array_create(int, max_element_count, s.arena)
	s.measure_text_hash_map_internal = array_create(Measure_Text_Cache_Item, max_element_count, s.arena)
	s.measure_text_hash_map_internal_free_list = array_create(int, max_element_count, s.arena)
	s.measured_words_free_list = array_create(int, max_element_count, s.arena)
	s.measured_words = array_create(Measured_Word, max_max_measure_text_cache_word_count, s.arena)
	s.cursor_over_ids = array_create(Element_ID, max_element_count, s.arena)
	s.debug_element_data = array_create(Debug_Element_Data, max_element_count, s.arena)
}

@(private="file")
size_containers_along_axis :: proc(x_axis: bool)
{
	bfs_buffer := s.layout_element_children_buffer
	resizable_container_buffer := s.open_layout_element_stack
	for &root in array_iter(s.layout_element_tree_roots) {
		bfs_buffer.len = 0
		root_element := array_get_ptr(&s.layout_elements, root.layout_element_idx)
		array_push(&bfs_buffer, root.layout_element_idx)

		if element_has_config(root_element, Floating_Element_Config) {
			floating_element_config := find_element_config_with_type(root_element, Floating_Element_Config).(^Floating_Element_Config)
			parent_item := get_hash_map_item(floating_element_config.parent_id)
			if parent_item != nil && parent_item != &DEFAULT_LAYOUT_ELEMENT_HASH_MAP_ITEM {
				parent_layout_element := parent_item.layout_element
				switch v in root_element.layout_config.sizing.width {
				case Sizing_Min_Max: {

				}
				case Percent: {

				}
				}
			}

		}


	}
}

@(private="file")
int_to_string :: proc(integer: int
) -> string
{return ""}

@(private="file")
push_render_command :: proc(render_command: Render_Command)
{}

@(private="file")
element_is_offscreen :: proc(bounding_box: ^Bounding_Box
) -> bool
{return true}

@(private="file")
calculate_final_layout :: proc() // 600 line function
{}

@(private="file")
debug_get_element_config_type_label :: proc(type: Debug_Element_Config_Type_Label_Config
) -> Debug_Element_Config_Type_Label_Config
{
	return Debug_Element_Config_Type_Label_Config{}
}

@(private="file")
render_debug_elements_list :: proc(initial_roots_length: int, highlighted_row_idx: int
) -> Render_Debug_Layout_Data
{
	return Render_Debug_Layout_Data{}
}

@(private="file")
render_debug_layout_sizing :: proc(sizing: Sizing_Axis, info_text_config: ^Text_Element_Config)
{}

@(private="file")
render_debug_view_element_config_header :: proc(element_id: string, type: typeid)
{}

@(private="file")
render_debug_view_color :: proc(color: Color, config: ^Text_Element_Config)
{}

@(private="file")
render_debug_view_corner_radius :: proc(corner_radius: Corner_Radius, config: ^Text_Element_Config)
{}

@(private="file")
handle_debug_view_close_button_interaction :: proc(element_id: Element_ID, cursor_info: Cursor_Data, user_ptr: rawptr)
{}

@(private="file")
DEBUG_VIEW_WIDTH : f32 : 400
@(private="file")
DEBUG_VIEW_HIGHLIGHT_COLOR : Color : {168, 66, 28, 100}
@(private="file")
render_debug_view :: proc()
{}

@(private="file")
Warning_Array_Allocate_Arena :: proc(cap: int, arena: virtual.Arena
) -> Array(Warning)
{
	return Array(Warning){}
}

@(private="file")
Array_Allocate_Arena :: proc(cap: int, item_size: u32, arena: virtual.Arena
) -> rawptr
{
	return nil
}

// NOTE - PUBLIC API

min_memory_size :: proc() -> u32
{}

create_arena_with_capacity_and_memory :: proc(cap: u32, memory: rawptr)
{}

set_measure_text_procedure :: proc(procedure: proc(string, Text_Element_Config, rawptr) -> [2]f32, user_ptr: rawptr)
{}

set_query_scroll_offset_procedure :: proc(procedure: proc(element_id: u32, user_ptr: rawptr) -> [2]f32, user_ptr: rawptr)
{}

set_layout_dimensions :: proc(dimensions: [2]f32)
{}

set_cursor_state :: proc(position: [2]f32, is_pointer_down: bool)
{}

initialize :: proc(arena: virtual.Arena, layout_dimensions: [2]f32, error_handler: Error_Handler)
{}

get_scroll_offset :: proc() -> [2]f32
{}

update_scroll_containers :: proc(enable_drag_scrolling: bool, scroll_delta: [2]f32, delta_time: f32)
{}

begin_layout :: proc()
{}

end_layout :: proc()
{}

get_element_id :: proc(id_string: string) -> Element_ID
{return {}}

get_element_id_with_idx :: proc(id_string: string, idx: u32) -> Element_ID
{return {}}

hovered :: proc() -> bool
{return {}}

clicked :: proc() -> bool
{return {}}

cursor_over :: proc(element_id: Element_ID) -> bool
{return {}}

get_scroll_container_data :: proc(id: Element_ID) -> Scroll_Container_Data
{return {}}

get_element_data :: proc(id: Element_ID) -> Element_Data
{return {}}

set_debug_mode_enabled :: proc(enabled: bool)
{}

is_debug_mode_enabled :: proc() -> bool
{return {}}

set_culling_enabled :: proc(enabled: bool)
{}

set_external_scroll_handling_enabled :: proc(enabled: bool)
{}

get_max_element_count :: proc() -> int
{return {}}

set_max_element_count :: proc(max_count: int)
{}

get_max_measure_text_cache_word_count :: proc() -> int
{return {}}

set_max_measure_text_cache_word_count :: proc(count: int)
{}

reset_measure_text_cache :: proc()
{}
