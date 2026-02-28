
package claydo

import "base:intrinsics"
import "base:runtime"
import "core:mem/virtual"

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
	width_type, height_type: Sizing_Type,
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
	cursor_capture_mode: Pointer_Capture_Mode,
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
Clip_Render_Data :: struct {
	horizontal: bool,
	vertical: bool,
}
Border_Render_Data :: struct {
	color: Color,
	corner_radius: Corner_Radius,
	width: Border_Width,
}
// TODO render data should not exist. Render command should be a union of commands we can switch on
Render_Data :: union {
	Text_Render_Data,
	Rectangle_Render_Data,
	Image_Render_Data,
	Custom_Render_Data,
	Border_Render_Data,
	Clip_Render_Data,
}
Render_Command :: struct {
	bounding_box: Bounding_Box,
	render_data: Render_Data,
	user_ptr: rawptr,
	id: u32,
	z_idx: i16,
	type: Render_Command_Type,
}
Render_Command_Type :: enum {
	NONE,
	RECTANGLE,
	BORDER,
	TEXT,
	IMAGE,
	SCISSOR_START,
	SCISSOR_END,
	CUSTOM,
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
	wrapped_lines: Array(Wrapped_Text_Line)
}
Layout_Element :: struct {
	text: ^Text_Element_Data,
	children: Array(int),
	dimensions: [2]f32,
	min_dimensions: [2]f32,
	layout_config: ^Layout_Config,
	element_configs: Array(Element_Config),
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
Arena :: virtual.Arena
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
	arena_internal: Arena,
	arena: runtime.Allocator,
	arena_reset_point: uint,

	layout_elements: Array(Layout_Element),
	render_commands: Array(Render_Command),
	open_layout_element_stack: Array(int),
	layout_element_children: Array(int),
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
EPSILON : f32 : 0.000001

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
s: ^State

// NOTE - PROCEDURES

// TODO arena stuff. I assume I can offload this to virtual.Arena, but eventually will need to do it myself.
@(private="file")
array_create :: proc($T: typeid, n: int, allo: runtime.Allocator
) -> Array(T)
{
	items, err := make([]T, n, allo)

	if err != nil {
		s.error_handler.err_proc(Error_Data{
			type = .ARENA_CAPACITY_EXCEEDED,
			text = "Claydo attempted to allocate memory in its arena, but ran out of capacity. Try increasing the capacity of the arena passed to initialize()",
			user_ptr = s.error_handler.user_ptr,
		})
		return {}
	}
	return Array(T){items=items, len=0, cap=n},
}

@(private="file")
array_slice :: #force_inline proc(array: ^Array($T), offset, len: int) -> Array(T)
{
	if len + offset > array.cap {
		return {}
	}
	sliced_array := Array(T){
		items = array.items[offset:],
		len = len,
		cap = array.cap - offset,
	}
	return sliced_array
}

@(private="file")
array_push :: #force_inline proc(array: ^Array($T), value: T
) -> ^T
{
	if array.len >= array.cap {
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
array_swapback :: #force_inline proc(array: ^Array($T), idx: int)
{
	if idx >= array.len {
		return
	}
	array.items[idx] = array.items[array.len-1]
	array.len -= 1
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
	saved_config := array_push(&s.element_configs, config)^ // the config is already a pointer since we don't need a type variable.
	// the element_configs array is uninitialized.
	if open_layout_element.element_configs.cap == 0 {
		open_layout_element.element_configs = array_slice(&s.element_configs, s.element_configs.len-1, 1)
	} else {
		open_layout_element.element_configs.len += 1
	}
	return saved_config
}

//@(private="file")
// find_element_config_with_type :: proc(element: ^Layout_Element, $T: typeid/Element_Config
// ) -> T
// {
// 	for i in 0..<s.element_configs.len {
// 		config := array_get(s.element_configs, i)
// 		if val, ok := config.(T); ok {
// 			return val
// 		}
// 	}
// 	return nil
// }
@(private="file")
find_element_config_with_type :: proc(element: ^Layout_Element, type: typeid
) -> Element_Config
{
	for config in array_iter(element.element_configs) {
		switch v in config {
		case ^Text_Element_Config: if Text_Element_Config == type {
			return config
		}
		case ^Aspect_Ratio: if Aspect_Ratio == type {
			return config
		}
		case ^Image_Data: if Image_Data == type {
			return config
		}
		case ^Floating_Element_Config: if Floating_Element_Config == type {
			return config
		}
		case ^Custom_Element_Config: if Custom_Element_Config == type {
			return config
		}
		case ^Clip_Element_Config: if Clip_Element_Config == type {
			return config
		}
		case ^Border_Element_Config: if Border_Element_Config == type {
			return config
		}
		case ^Shared_Element_Config: if Shared_Element_Config == type {
			return config
		}
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
measure_text_cached :: proc(text: string, config: ^Text_Element_Config
) -> ^Measure_Text_Cache_Item
{
	// Before setting a new item, try and clean up some of the cache
	id := hash_string_content_with_config(text, config)
	hash_bucket := id % u32(s.max_measure_text_cache_word_count / 32)
	element_idx_previous := 0
	s := s
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
	s := s
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
	offset := parent_element.children.len + int(parent_element.floating_children_count)
	element_id := hash_number(u32(offset), parent_element.id)
	open_layout_element.id = element_id.id
	add_hash_map_item(element_id, open_layout_element)
	array_push(&s.layout_element_id_strings, element_id.string_id)
	return element_id
}

@(private="file")
element_has_config :: proc(element: ^Layout_Element, type: typeid
) -> (Element_Config, bool)
{
	for config in array_iter(element.element_configs) {
		switch v in config {
		case ^Text_Element_Config: if Text_Element_Config == type {
			return config, true
		}
		case ^Aspect_Ratio: if Aspect_Ratio == type {
			return config, true
		}
		case ^Image_Data: if Image_Data == type {
			return config, true
		}
		case ^Floating_Element_Config: if Floating_Element_Config == type {
			return config, true
		}
		case ^Custom_Element_Config: if Custom_Element_Config == type {
			return config, true
		}
		case ^Clip_Element_Config: if Clip_Element_Config == type {
			return config, true
		}
		case ^Border_Element_Config: if Border_Element_Config == type {
			return config, true
		}
		case ^Shared_Element_Config: if Shared_Element_Config == type {
			return config, true
		}
		}
	}
	return nil, false
}

@(private="file")
update_aspect_ratio_box :: proc(layout_element: ^Layout_Element)
{
	for &config in array_iter(layout_element.element_configs) {
		if aspect_config, is_aspect := config.(^Aspect_Ratio); is_aspect {
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

close_element :: proc()
{
	s := s
	if s.boolean_warnings.max_elements_exceeded {
		return
	}
	open_layout_element := get_open_layout_element()
	layout_config := open_layout_element.layout_config
	if layout_config == nil {
		open_layout_element.layout_config = &DEFAULT_LAYOUT_CONFIG
		layout_config = &DEFAULT_LAYOUT_CONFIG
	}
	element_has_clip_horizontal := false
	element_has_clip_vertical := false
	for config in array_iter(open_layout_element.element_configs) {
		if clip_config, is_clip := config.(^Clip_Element_Config); is_clip {
			element_has_clip_horizontal = clip_config.horizontal
			element_has_clip_vertical = clip_config.vertical
		}
		if floating_config, is_floating := config.(^Floating_Element_Config); is_floating {
			s.open_clip_element_stack.len -= 1
		}
	}

	left_right_padding := layout_config.padding.left + layout_config.padding.right
	top_bottom_padding := layout_config.padding.top + layout_config.padding.bottom

	// Attach children to the current open element
	open_layout_element.children.items = s.layout_element_children.items[s.layout_element_children.len:]
	open_layout_element.children.cap = s.layout_element_children.cap - s.layout_element_children.len
	if layout_config.direction == .LEFT_TO_RIGHT {
		open_layout_element.dimensions.x = left_right_padding
		open_layout_element.min_dimensions.x = left_right_padding
		for i in 0..<open_layout_element.children.len {
			child_idx := array_get(s.layout_element_children_buffer, s.layout_element_children_buffer.len \
				- open_layout_element.children.len + i)
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
		child_gap := f32(max(open_layout_element.children.len - 1, 0)) * layout_config.child_gap
		open_layout_element.dimensions.x += child_gap
		if !element_has_clip_horizontal {
			open_layout_element.min_dimensions.x += child_gap
		}
	} else if layout_config.direction == .TOP_TO_BOTTOM {
		open_layout_element.dimensions.y = top_bottom_padding
		open_layout_element.min_dimensions.y = top_bottom_padding
		for i in 0..<open_layout_element.children.len {
			child_idx := array_get(s.layout_element_children_buffer, s.layout_element_children_buffer.len \
				- open_layout_element.children.len + i)
			child := array_get_ptr(&s.layout_elements, child_idx)
			open_layout_element.dimensions.y += child.dimensions.y
			open_layout_element.dimensions.x = max(open_layout_element.dimensions.x, child.dimensions.x + left_right_padding)
			if !element_has_clip_vertical {
				open_layout_element.min_dimensions.y += child.min_dimensions.y
			}
			if !element_has_clip_horizontal {
				open_layout_element.min_dimensions.x = max(open_layout_element.min_dimensions.x, child.min_dimensions.x + left_right_padding)
			}
			array_push(&s.layout_element_children, child_idx)
		}
		child_gap := f32(max(open_layout_element.children.len - 1, 0)) * layout_config.child_gap
		open_layout_element.dimensions.y += child_gap
		if !element_has_clip_vertical {
			open_layout_element.min_dimensions.y += child_gap
		}
	}
	s.layout_element_children_buffer.len -= open_layout_element.children.len

	if layout_config.sizing.width_type != .PERCENT {
		if layout_config.sizing.width == nil {
			layout_config.sizing.width = Sizing_Min_Max{}
		}
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

	if layout_config.sizing.height_type != .PERCENT {
		if layout_config.sizing.height == nil {
			layout_config.sizing.height = Sizing_Min_Max{}
		}
		if layout_config.sizing.height.(Sizing_Min_Max).max <= 0 {
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

	_, element_is_floating := element_has_config(open_layout_element, Floating_Element_Config)

	// Close current element
	closing_element_idx := array_pop(&s.open_layout_element_stack)

	open_layout_element = get_open_layout_element()

	if s.open_layout_element_stack.len > 1 {
		if element_is_floating {
			open_layout_element.floating_children_count += 1
			return
		}
		open_layout_element.children.len += 1
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
	add_hash_map_item(element_id, open_layout_element)
	array_push(&s.layout_element_id_strings, element_id.string_id)
	if s.open_clip_element_stack.len > 0 {
		array_set(&s.layout_element_clip_element_ids, s.layout_elements.len - 1, array_peek(s.open_clip_element_stack))
	} else {
		array_set(&s.layout_element_clip_element_ids, s.layout_elements.len - 1, 0)
	}
}

@(private="file")
open_text_element :: proc(text: string, config: ^Text_Element_Config)
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
	element_id := hash_number(u32(parent_element.children.len) + u32(parent_element.floating_children_count), parent_element.id)
	text_element.id = element_id.id
	add_hash_map_item(element_id, text_element)
	array_push(&s.layout_element_id_strings, element_id.string_id)
	text_dimensions := [2]f32{text_measured.unwrapped_dimension.x, config.line_height > 0 ? config.line_height : text_measured.unwrapped_dimension.y}
	text_element.dimensions = text_dimensions
	text_element.min_dimensions = text_dimensions
	text_element.text = array_push(&s.text_element_data, Text_Element_Data{text = text, preferred_dimensions = text_measured.unwrapped_dimension, idx = s.layout_elements.len - 1})
	element_count := s.max_element_count
	// push the config onto the element configs, then set text_element's config to be backed by that data
	array_push(&s.element_configs, config)
	text_element.element_configs = array_slice(&s.element_configs, s.element_configs.len-1, 1)
	text_element.layout_config = &DEFAULT_LAYOUT_CONFIG
	parent_element.children.len += 1
}

configure_open_element_ptr :: proc(declaration: ^Element_Declaration) -> bool
{
	open_layout_element := get_open_layout_element()
	open_layout_element.layout_config = store_layout_config(declaration.layout)
	if (declaration.layout.sizing.width_type == .PERCENT && declaration.layout.sizing.width.(Percent) > 1) || (declaration.layout.sizing.height_type == .PERCENT && declaration.layout.sizing.height.(Percent) > 1) {
		s.error_handler.err_proc(
			Error_Data{
				type = .PERCENTAGE_OVER_1,
				text = "An element was configured with PERCENT sizing, but the provided percentage value was over 1.0. Claydo expects a value between 0 and 1, i.e. 20% is 0.2.",
				user_ptr = s.error_handler.user_ptr,
			}
		)
	}
	//open_layout_element.element_configs = array_slice(&s.element_configs, s.element_configs.len-1, 0)
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
			if declaration.floating.attach_to == .PARENT {
				// attach to direct hierarchical parent
				floating_config.parent_id = hierarchical_parent.id
				if s.open_clip_element_stack.len > 0 {
					clip_element_id = array_get(s.open_clip_element_stack, s.open_clip_element_stack.len-1)
				}
			} else if declaration.floating.attach_to == .ELEMENT_WITH_ID {
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
					clip_element_id = array_get(s.layout_element_clip_element_ids, intrinsics.ptr_sub(parent_item.layout_element, &s.layout_elements.items[0]))
				}
			} else if declaration.floating.attach_to == .ROOT {
				floating_config.parent_id = hash_string("Root_Container", 0).id
			}
			if declaration.floating.clip_to == .NONE {
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
	return true
}

// TODO just clear instead of re-initializing
@(private="file")
initialize_ephemeral_memory :: proc(s: ^State)
{
	max_element_count := s.max_element_count
	// TODO don't need to zero
	virtual.arena_static_reset_to(&s.arena_internal, s.arena_reset_point)
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
	s.layout_element_children = array_create(int, max_element_count, s.arena)
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
	s.measure_text_hash_map = array_create(int, max_element_count, s.arena)
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

		if config, has := element_has_config(root_element, Floating_Element_Config); has {
			floating_element_config := config.(^Floating_Element_Config)
			parent_item := get_hash_map_item(floating_element_config.parent_id)
			if parent_item != nil && parent_item != &DEFAULT_LAYOUT_ELEMENT_HASH_MAP_ITEM {
				parent_layout_element := parent_item.layout_element
				#partial switch root_element.layout_config.sizing.width_type {
				case .GROW: {
					root_element.dimensions.x = parent_layout_element.dimensions.x
				}
				case .PERCENT: {
					root_element.dimensions.x = parent_layout_element.dimensions.x * f32(root_element.layout_config.sizing.width.(Percent))
				}
				}

				#partial switch root_element.layout_config.sizing.height_type {
				case .GROW: {
					root_element.dimensions.y = parent_layout_element.dimensions.y
				}
				case .PERCENT: {
					root_element.dimensions.y = parent_layout_element.dimensions.y * f32(root_element.layout_config.sizing.height.(Percent))
				}
				}
			}
		}
		if root_element.layout_config.sizing.width_type != .PERCENT {
			root_element.dimensions.x = min(max(root_element.dimensions.x, root_element.layout_config.sizing.width.(Sizing_Min_Max).min), \
							root_element.layout_config.sizing.width.(Sizing_Min_Max).max)
		}
		if root_element.layout_config.sizing.height_type != .PERCENT {
			root_element.dimensions.y = min(max(root_element.dimensions.y, root_element.layout_config.sizing.height.(Sizing_Min_Max).min), \
							root_element.layout_config.sizing.height.(Sizing_Min_Max).max)
		}

		for parent_idx in array_iter(bfs_buffer) {
			parent := array_get_ptr(&s.layout_elements, parent_idx)
			grow_container_count := 0
			parent_size := x_axis ? parent.dimensions.x : parent.dimensions.y
			parent_padding := x_axis ? parent.layout_config.padding.left + parent.layout_config.padding.right : parent.layout_config.padding.top + parent.layout_config.padding.bottom
			inner_content_size : f32 = 0
			total_padding_and_child_gaps := parent_padding
			sizing_along_axis := (x_axis && parent.layout_config.direction == .LEFT_TO_RIGHT) || (!x_axis && parent.layout_config.direction == .TOP_TO_BOTTOM)
			resizable_container_buffer.len = 0
			parent_child_gap := parent.layout_config.child_gap

			for child_element_index, child_offset in array_iter(parent.children) {
				child_element := array_get_ptr(&s.layout_elements, child_element_index)
				child_sizing := x_axis ? child_element.layout_config.sizing.width_type : child_element.layout_config.sizing.height_type
				child_size := x_axis ? child_element.dimensions.x : child_element.dimensions.y
				// If the child has children, add it to the buffer to process
				if _, has := element_has_config(child_element, Text_Element_Config); !has && child_element.children.len > 0 {
					array_push(&bfs_buffer, child_element_index)
				}

				text_config, has_text_config := element_has_config(child_element, Text_Element_Config)
				if child_sizing != .PERCENT \
				&& child_sizing != .FIXED \
				&& (!has_text_config || text_config.(^Text_Element_Config).wrap_mode == .WRAP_WORDS) {
					array_push(&resizable_container_buffer, child_element_index)
				}

				if sizing_along_axis {
					inner_content_size += child_sizing == .PERCENT ? 0 : child_size
					if child_sizing == .GROW {
						grow_container_count += 1
					}
					if child_offset > 0 {
						inner_content_size += parent_child_gap // after 0, offset is the is the gap to the previous child
						total_padding_and_child_gaps += parent_child_gap
					}
				} else {
					inner_content_size = max(child_size, inner_content_size)
				}
			}

			for child_element_index, child_offset in array_iter(parent.children) {
				child_element := array_get_ptr(&s.layout_elements, child_element_index)
				child_sizing := x_axis ? child_element.layout_config.sizing.width_type : child_element.layout_config.sizing.height_type
				child_size_value := x_axis ? child_element.layout_config.sizing.width : child_element.layout_config.sizing.height
				child_size := x_axis ? &(child_element.dimensions.x) : &(child_element.dimensions.y)
				if child_sizing == .PERCENT {
					child_size^ = (parent_size - total_padding_and_child_gaps) * f32(child_size_value.(Percent))
					if sizing_along_axis {
						inner_content_size += child_size^
					}
					update_aspect_ratio_box(child_element)
				}
			}

			if sizing_along_axis {
				size_to_distribute := parent_size - parent_padding - inner_content_size
				if size_to_distribute < 0 {
					clip_element_config := find_element_config_with_type(parent, Clip_Element_Config).(^Clip_Element_Config)
					if clip_element_config != nil {
						if (x_axis && clip_element_config.horizontal) || (!x_axis && clip_element_config.vertical) {
							continue
						}
					}
					for size_to_distribute < -EPSILON && resizable_container_buffer.len > 0 {
						largest: f32 = 0
						second_largest: f32 = 0
						width_to_add := size_to_distribute
						for child_idx in array_iter(resizable_container_buffer) {
							child := array_get_ptr(&s.layout_elements, child_idx)
							child_size := x_axis ? child.dimensions.x : child.dimensions.y
							if child_size == largest { // TODO float_equals. Required?
								continue
							}
							if child_size > largest {
								second_largest = largest
								largest = child_size
							}
							if child_size < largest {
								second_largest = max(second_largest, child_size)
								width_to_add = second_largest - largest
							}
						}

						width_to_add = max(width_to_add, size_to_distribute / f32(resizable_container_buffer.len))

						for child_idx := 0; child_idx < resizable_container_buffer.len; child_idx += 1 {
							child := array_get_ptr(&s.layout_elements, array_get(resizable_container_buffer, child_idx))
							child_size := x_axis ? &child.dimensions.x : &child.dimensions.y
							min_size := x_axis ? child.min_dimensions.x : child.min_dimensions.y
							previous_width := child_size^
							if child_size^ == largest {
								child_size^ += width_to_add
								if child_size^ <= min_size {
									child_size^ = min_size
									array_swapback(&resizable_container_buffer, child_idx)
									child_idx -= 1
								}
								size_to_distribute -= (child_size^ - previous_width)
							}
						}
					}
				// content is too small, expand to fit container
				} else if size_to_distribute > 0 && grow_container_count > 0 {
					for child_idx := 0; child_idx < resizable_container_buffer.len; child_idx += 1 {
						child := array_get_ptr(&s.layout_elements, array_get(resizable_container_buffer, child_idx))
						child_sizing := x_axis ? child.layout_config.sizing.width_type : child.layout_config.sizing.height_type
						if child_sizing != .GROW {
							array_swapback(&resizable_container_buffer, child_idx)
							child_idx -= 1
						}
					}
					for size_to_distribute > EPSILON && resizable_container_buffer.len > 0 {
						smallest := MAX_FLOAT
						second_smallest := MAX_FLOAT
						width_to_add := size_to_distribute
						for child_idx in array_iter(resizable_container_buffer) {
							child := array_get_ptr(&s.layout_elements, child_idx)
							child_size := x_axis ? child.dimensions.x : child.dimensions.y
							if child_size == smallest {
								continue
							}
							if child_size < smallest {
								second_smallest = smallest
								smallest = child_size
							}
							if child_size > smallest {
								second_smallest = min(second_smallest, child_size)
								width_to_add = second_smallest - smallest
							}
						}
						width_to_add = min(width_to_add, size_to_distribute / f32(resizable_container_buffer.len))

						for child_idx := 0; child_idx < resizable_container_buffer.len; child_idx += 1 {
							child := array_get_ptr(&s.layout_elements, array_get(resizable_container_buffer, child_idx))
							child_size := x_axis ? &child.dimensions.x : &child.dimensions.y
							max_size := x_axis ? child.layout_config.sizing.width.(Sizing_Min_Max).max : child.layout_config.sizing.height.(Sizing_Min_Max).max
							previous_width := child_size^
							if child_size^ == smallest {
								child_size^ += width_to_add
								if child_size^ >= max_size {
									child_size^ = max_size
									array_swapback(&resizable_container_buffer, child_idx)
									child_idx -= 1
								}
								size_to_distribute -= child_size^ - previous_width
							}
						}
					}
				}
			// Sizing off-axis
			} else {
				for child_offset in array_iter(resizable_container_buffer) {
					child_element := array_get_ptr(&s.layout_elements, child_offset)
					child_sizing := x_axis ? child_element.layout_config.sizing.width_type : child_element.layout_config.sizing.height_type
					child_sizing_value := x_axis ? child_element.layout_config.sizing.width : child_element.layout_config.sizing.height
					min_size := x_axis ? child_element.min_dimensions.x : child_element.min_dimensions.y
					child_size := x_axis ? &child_element.dimensions.x : &child_element.dimensions.y
					max_size := parent_size - parent_padding
					// if laying out children of scroll panel grow containers expand to inner content not outer container
					if config, has := element_has_config(parent, Clip_Element_Config); has {
						clip_element_config := config.(^Clip_Element_Config)
						if (x_axis && clip_element_config.horizontal) || (!x_axis && clip_element_config.vertical) {
							max_size = max(max_size, inner_content_size)
						}
					}
					if child_sizing == .GROW {
						child_size^ = min(max_size, child_sizing_value.(Sizing_Min_Max).max)
					}
					child_size^ = max(min_size, min(child_size^, max_size))
				}
			}
		}
	}
}


// TODO look into replacing dynamic_string_data with an arena specifically for strings.
@(private="file")
int_to_string :: proc(integer: int
) -> string
{
	integer := integer
	if integer == 0 {
		return "0"
	}
	chars := s.dynamic_string_data.items[s.dynamic_string_data.len:]
	length := 0
	sign := integer
	if integer < 0 {
		integer = -integer
	}
	for integer > 0 {
		chars[length] = byte(integer % 10) + '0'
		length += 1
		integer /= 10
	}
	if sign < 0 {
		chars[length] = '-'
		length += 1
	}

	for j := 0; j < length; j += 1 {
		chars[j], chars[length-j] = chars[length-j], chars[j]
	}
	s.dynamic_string_data.len += length
	return string(chars[:length])
}

@(private="file")
push_render_command :: proc(render_command: Render_Command)
{
	if s.render_commands.len < s.render_commands.cap - 1 {
		array_push(&s.render_commands, render_command)
	} else {
		if !s.boolean_warnings.max_render_commands_exceeded {
			s.boolean_warnings.max_render_commands_exceeded = true
			s.error_handler.err_proc(
				Error_Data{
					type = .ELEMENTS_CAPACITY_EXCEEDED,
					text = "Claydo ran out of capacity while attempting to create render commands. This is usually caused by a large amount of wrapping text elements while close to the max element capacity. Try using set_max_element_count() with a higher value.",
					user_ptr = s.error_handler.user_ptr,
				}
			)
		}
	}
}

@(private="file")
element_is_offscreen :: proc(bounding_box: ^Bounding_Box
) -> bool
{
	if s.disable_culling {
		return false
	}
	return (bounding_box.x > s.layout_dimensions.x) || \
	       (bounding_box.y > s.layout_dimensions.y) || \
	       (bounding_box.x + bounding_box.width < 0) || \
	       (bounding_box.y + bounding_box.height < 0)
}

@(private="file")
calculate_final_layout :: proc()
{


	s := s
	// calculate sizing along x axis
	size_containers_along_axis(true)

	// Wrap text
	// loop through each text element in the layout
	for &text_element_data in array_iter(s.text_element_data) {
		// set the wrapped_lines array to the end of the state's wrapped_text_lines array
		text_element_data.wrapped_lines.items = s.wrapped_text_lines.items[s.wrapped_text_lines.len:]
		text_element_data.wrapped_lines.cap = s.wrapped_text_lines.cap - s.wrapped_text_lines.len
		text_element_data.wrapped_lines.len = 0
		// get the container and measure the text
		container_element := array_get_ptr(&s.layout_elements, text_element_data.idx)
		text_config := find_element_config_with_type(container_element, Text_Element_Config).(^Text_Element_Config)
		measure_text_cache_item := measure_text_cached(text_element_data.text, text_config)
		line_width: f32 = 0
		line_height := text_config.line_height > 0 ? text_config.line_height : text_element_data.preferred_dimensions.y
		line_length_chars := 0
		line_start_offset := 0
		// There are newlines in the item, and it fits inside the container
		if !measure_text_cache_item.contains_new_lines && text_element_data.preferred_dimensions.x <= container_element.dimensions.x {
			array_push(&s.wrapped_text_lines, Wrapped_Text_Line{dimensions = container_element.dimensions, text = text_element_data.text})
			// We increment the lenth here because text_element_data.wrapped_lines is backed by the global store
			text_element_data.wrapped_lines.len += 1
			continue
		}
		space_width := s.measure_text(" ", text_config^, s.measure_text_user_ptr).x
		// get the index of the cached measured_word for the first word
		word_idx := measure_text_cache_item.measured_words_start_idx
		for word_idx != -1 {
			// Can't store any more wrapped text
			if s.wrapped_text_lines.len > s.wrapped_text_lines.cap -1 {
				break;
			}
			measured_word := array_get_ptr(&s.measured_words, word_idx)
			// if the only word on the line is too large, render it anyway
			if line_length_chars == 0 && line_width + measured_word.width > container_element.dimensions.x {
				// TODO These string bounds checkings are super ugly and probably error prone
				// We push a wrapped line onto the global array, but the backing data is from text_element_data
				array_push(&s.wrapped_text_lines, Wrapped_Text_Line{dimensions={measured_word.width, line_height}, text = string(text_element_data.text[measured_word.start_offset:measured_word.start_offset+measured_word.length])})
				// increment wrapped_lines length since it is backed by the global array
				text_element_data.wrapped_lines.len += 1
				// Move on to the next word
				word_idx = measured_word.next
				line_start_offset = measured_word.start_offset + measured_word.length
			// measured_word.length == 0 means new line. (or the measured width is too large)
			} else if measured_word.length == 0 || line_width + measured_word.width > container_element.dimensions.x {
				// if wrapped text lines list has overflowed, just render out the line
				final_char_is_space := text_element_data.text[max(line_start_offset + line_length_chars - 1, 0)] == ' '
				array_push(&s.wrapped_text_lines, Wrapped_Text_Line{dimensions={final_char_is_space ? -space_width : 0, line_height}, text = string(text_element_data.text[line_start_offset:line_start_offset + line_length_chars + (final_char_is_space ? -1 : 0)])})
				text_element_data.wrapped_lines.len += 1
				if line_length_chars == 0 || measured_word.length == 0 {
					word_idx = measured_word.next
				}
				// reset for new line
				line_width = 0
				line_length_chars = 0
				line_start_offset = measured_word.start_offset
			// fits on the line
			} else {
				line_width += measured_word.width + text_config.spacing
				line_length_chars += measured_word.length
				word_idx = measured_word.next
			}
		}
		// push the remaining characters
		if line_length_chars > 0 {
			array_push(&s.wrapped_text_lines, Wrapped_Text_Line{dimensions = {line_width - text_config.spacing, line_height}, text = text_element_data.text[line_start_offset:line_start_offset+line_length_chars]})
			text_element_data.wrapped_lines.len += 1
		}
		container_element.dimensions.y = line_height * f32(text_element_data.wrapped_lines.len)
	}

	// scale vertical heights according to aspect ratio
	for aspect_ratio_element_idx in array_iter(s.aspect_ratio_element_idxs) {
		aspect_element := array_get_ptr(&s.layout_elements, aspect_ratio_element_idx)
		config := find_element_config_with_type(aspect_element, Aspect_Ratio).(^Aspect_Ratio)
		aspect_element.dimensions.y = f32(1.0 / config^) * aspect_element.dimensions.x
		min_max_sizing := &aspect_element.layout_config.sizing.height.(Sizing_Min_Max)
		min_max_sizing.max = aspect_element.dimensions.y
	}

	// propagate effect of text wrapping, aspect scalign etc. on height of parents
	dfs_buffer := s.layout_element_tree_nodes
	dfs_buffer.len = 0
	// For each tree root in the layout, add it into a depth first search buffer
	for root in array_iter(s.layout_element_tree_roots) {
		s.tree_node_visited.items[dfs_buffer.len] = false
		array_push(&dfs_buffer, Layout_Element_Tree_Node{layout_element = array_get_ptr(&s.layout_elements, root.layout_element_idx)})
	}
	// Keep processing until the buffer is empty
	for dfs_buffer.len > 0 {
		// peek
		current_element_tree_node := array_get_ptr(&dfs_buffer, dfs_buffer.len-1)
		current_element := current_element_tree_node.layout_element
		if !s.tree_node_visited.items[dfs_buffer.len-1] {
			s.tree_node_visited.items[dfs_buffer.len-1] = true
			// if it's got no children or is just a text container then don't bother inspecting
			if _, has := element_has_config(current_element, Text_Element_Config); has || current_element.children.len == 0 {
				dfs_buffer.len -= 1
				continue
			}
			// add the children to the DFS buffer (needs to be pushed in reverse so the that the stack traversal is in correct layout order)
			for child_idx in array_iter(current_element.children) {
				s.tree_node_visited.items[dfs_buffer.len] = false
				array_push(&dfs_buffer, Layout_Element_Tree_Node{layout_element=array_get_ptr(&s.layout_elements, child_idx)})
			}
			continue
		}
		dfs_buffer.len -= 1
		// DFS node has been visited, this is on the way back up to the root
		layout_config := current_element.layout_config
		if layout_config.direction == .LEFT_TO_RIGHT {
			// resize any parent containers that have grown in height alogn their non layout axis
			for &child_idx in array_iter(current_element.children) {
				child_element := array_get_ptr(&s.layout_elements, child_idx)
				child_height_with_padding := max(child_element.dimensions.y + layout_config.padding.top + layout_config.padding.bottom, current_element.dimensions.y)
				current_element.dimensions.y = min(max(child_height_with_padding, layout_config.sizing.height.(Sizing_Min_Max).min), layout_config.sizing.height.(Sizing_Min_Max).max)
			}
		} else if layout_config.direction == .TOP_TO_BOTTOM {
			// resizing along the layout axis
			content_height := layout_config.padding.top + layout_config.padding.bottom
			for child_idx in array_iter(current_element.children) {
				child_element := array_get_ptr(&s.layout_elements, child_idx)
				content_height += child_element.dimensions.y
			}
			content_height += f32(max(current_element.children.len - 1, 0)) * layout_config.child_gap
			current_element.dimensions.y = min(max(content_height, layout_config.sizing.height.(Sizing_Min_Max).min), layout_config.sizing.height.(Sizing_Min_Max).max)
		}
	}
	// calculate sizing along y axis
	size_containers_along_axis(false)

	// scale horizontal widths according to aspect ratio
	for aspect_idx in array_iter(s.aspect_ratio_element_idxs) {
		aspect_element := array_get_ptr(&s.layout_elements, aspect_idx)
		config := find_element_config_with_type(aspect_element, Aspect_Ratio).(^Aspect_Ratio)
		aspect_element.dimensions.x = f32(config^) * aspect_element.dimensions.y
	}

	// sort tree roots by z-index
	// my assumption is this is faster than qsort because the array is usually small? (or it's just easier lmao)
	sort_max := s.layout_element_tree_roots.len - 1
	for sort_max > 0 {
		for i := 0; i < sort_max; i+=1 {
			current := array_get(s.layout_element_tree_roots, i)
			next := array_get(s.layout_element_tree_roots, i + 1)
			if next.z_idx < current.z_idx {
				array_set(&s.layout_element_tree_roots, i, next)
				array_set(&s.layout_element_tree_roots, i + 1, current)
			}
		}
		sort_max -= 1
	}

	// Calculate final positions and generate render commands
	s.render_commands.len = 0
	dfs_buffer.len = 0
	for &root in array_iter(s.layout_element_tree_roots) {
		dfs_buffer.len = 0
		root_element := array_get_ptr(&s.layout_elements, root.layout_element_idx)
		root_position: [2]f32
		parent_hash_map_item := get_hash_map_item(root.parent_id)
		if floating_config, has := element_has_config(root_element, Floating_Element_Config); has && parent_hash_map_item != nil {
			config := floating_config.(^Floating_Element_Config)
			root_dimensions := root_element.dimensions
			parent_bounding_box := parent_hash_map_item.bounding_box
			target_attach_position: [2]f32
			switch config.attach_points.parent {
			case .LEFT_TOP, .LEFT_CENTER, .LEFT_BOTTOM: target_attach_position.x = parent_bounding_box.x
			case .CENTER_TOP, .CENTER_CENTER, .CENTER_BOTTOM: target_attach_position.x = parent_bounding_box.x + (parent_bounding_box.width / 2.0)
			case .RIGHT_TOP, .RIGHT_CENTER, .RIGHT_BOTTOM: target_attach_position.x = parent_bounding_box.x + parent_bounding_box.width
			}
			#partial switch config.attach_points.element {
			case .CENTER_TOP, .CENTER_CENTER, .CENTER_BOTTOM: target_attach_position.x -= root_dimensions.x / 2.0
			case .RIGHT_TOP, .RIGHT_CENTER, .RIGHT_BOTTOM: target_attach_position.x -= root_dimensions.x
			}
			switch config.attach_points.parent {
			case .LEFT_TOP, .RIGHT_TOP, .CENTER_TOP: target_attach_position.y = parent_bounding_box.y
			case .LEFT_CENTER, .CENTER_CENTER, .RIGHT_CENTER: target_attach_position.y = parent_bounding_box.y + parent_bounding_box.y / 2.0
			case .LEFT_BOTTOM, .CENTER_BOTTOM, .RIGHT_BOTTOM: target_attach_position.y = parent_bounding_box.y + parent_bounding_box.height
			}
			#partial switch config.attach_points.element {
			case .LEFT_CENTER, .CENTER_CENTER, .RIGHT_CENTER: target_attach_position.y -= (root_dimensions.y / 2.0)
			case .LEFT_BOTTOM, .CENTER_BOTTOM, .RIGHT_BOTTOM: target_attach_position.y -= root_dimensions.y
			}
			target_attach_position.x += config.offset.x
			target_attach_position.y += config.offset.y
			root_position = target_attach_position
		}
		if root.clip_element_id != 0 {
			clip_hash_map_item := get_hash_map_item(root.clip_element_id)
			if clip_hash_map_item != nil {
				if s.external_scroll_handling_enabled {
					clip_config := find_element_config_with_type(clip_hash_map_item.layout_element, Clip_Element_Config).(^Clip_Element_Config)
					if clip_config.horizontal {
						root_position.x += clip_config.child_offset.x
					}
					if clip_config.vertical {
						root_position.y += clip_config.child_offset.y
					}
				}
				array_push(&s.render_commands,
					Render_Command{
						bounding_box = clip_hash_map_item.bounding_box,
						user_ptr = nil,
						id = hash_number(root_element.id, u32(root_element.children.len) + 10).id,
						z_idx = root.z_idx,
						type = .SCISSOR_START,
					})
			}
		}
		array_push(&dfs_buffer,
			Layout_Element_Tree_Node{
				layout_element = root_element,
				position = root_position,
				next_child_offset = {root_element.layout_config.padding.left, root_element.layout_config.padding.top}
			})
		s.tree_node_visited.items[0] = false
		for dfs_buffer.len > 0 {
			current_element_tree_node := array_get_ptr(&dfs_buffer, dfs_buffer.len-1)
			current_element := current_element_tree_node.layout_element
			layout_config := current_element.layout_config
			scroll_offset: [2]f32

			// This will onl be run a single time for each element in downwards DFS order
			if !s.tree_node_visited.items[dfs_buffer.len-1] {
				s.tree_node_visited.items[dfs_buffer.len-1] = true
				current_element_bounding_box := Bounding_Box{current_element_tree_node.position.x, current_element_tree_node.position.y, current_element.dimensions.x, current_element.dimensions.y}
				if config, has := element_has_config(current_element, Floating_Element_Config); has {
					floating_element_config := config.(^Floating_Element_Config)
					expand := floating_element_config.expand
					current_element_bounding_box.x -= expand.x
					current_element_bounding_box.width += expand.x * 2.0
					current_element_bounding_box.y -= expand.y
					current_element_bounding_box.height += expand.y * 2.0
				}
				scroll_container_data: ^Scroll_Container_Data_Internal
				if config, has := element_has_config(current_element, Clip_Element_Config); has {
					clip_config := config.(^Clip_Element_Config)
					for &mapping in array_iter(s.scroll_container_data) {
						if mapping.layout_element == current_element {
							scroll_container_data = &mapping
							mapping.bounding_box = current_element_bounding_box
							scroll_offset = clip_config.child_offset
							if s.external_scroll_handling_enabled {
								scroll_offset = {}
							}
							break
						}
					}
				}
				hash_map_item := get_hash_map_item(current_element.id)
				if hash_map_item != nil {
					hash_map_item.bounding_box = current_element_bounding_box
				}

				sorted_config_indexes: [20]int
				for i in 0..<current_element.element_configs.len {
					sorted_config_indexes[i] = i
				}
				sort_max = current_element.element_configs.len - 1
				for sort_max > 0 { // TODO better sort, this is bad
					for i := 0; i < sort_max; i+=1 {
						current := sorted_config_indexes[i]
						next := sorted_config_indexes[i+1]
						current_type := array_get(current_element.element_configs, current)
						next_type := array_get(current_element.element_configs, next)
						_, is_clip := next_type.(^Clip_Element_Config)
						_, is_border := current_type.(^Border_Element_Config)
						if is_clip || is_border {
							sorted_config_indexes[i] = next
							sorted_config_indexes[i + 1] = current
						}
					}
					sort_max -= 1
				}

				emit_rectangle := false
				config, has := element_has_config(current_element, Shared_Element_Config)
				shared_config: ^Shared_Element_Config
				if !has {
					shared_config = &DEFAULT_SHARED_ELEMENT_CONFIG
				} else {
					shared_config = config.(^Shared_Element_Config)
				}
				if shared_config.color.a > 0 {
					emit_rectangle = true
				}
				for element_config_idx in sorted_config_indexes[:current_element.element_configs.len] {
					element_config := array_get_ptr(&current_element.element_configs, element_config_idx)
					render_command := Render_Command {
						bounding_box = current_element_bounding_box,
						user_ptr = shared_config.user_ptr,
						id = current_element.id,
					}
					offscreen := element_is_offscreen(&current_element_bounding_box)
					should_render := !offscreen
					#partial switch v in element_config^ {
					case ^Clip_Element_Config: {
						render_command.type = .SCISSOR_START
						render_command.render_data = Clip_Render_Data{
							horizontal = v.horizontal,
							vertical = v.vertical,
						}
					}
					case ^Image_Data: {
						render_command.type = .IMAGE
						render_command.render_data = Image_Render_Data{
							color = shared_config.color,
							corner_radius = shared_config.corner_radius,
							data = v^,
						}
						emit_rectangle = false
					}
					case ^Text_Element_Config: {
						if !should_render {
							break
						}
						should_render = false
						text_element_config := element_config.(^Text_Element_Config)
						natural_line_height := current_element.text.preferred_dimensions.y
						final_line_height := text_element_config.line_height > 0 ? text_element_config.line_height : natural_line_height
						line_height_offset := final_line_height / natural_line_height / 2.0
						y_position := line_height_offset
						for &wrapped_line, line_idx in array_iter(current_element.text.wrapped_lines) {
							if len(wrapped_line.text) == 0 {
								y_position += final_line_height
								continue
							}
							offset := current_element_bounding_box.width - wrapped_line.dimensions.x
							if text_element_config.alignment == .LEFT {
								offset = 0
							}
							if text_element_config.alignment == .CENTER {
								offset /= 2
							}
							push_render_command(Render_Command{
								bounding_box = {current_element_bounding_box.x + offset, current_element_bounding_box.y + y_position, wrapped_line.dimensions.x, wrapped_line.dimensions.y},
								render_data = Text_Render_Data{
									text = current_element.text.text,
									color = text_element_config.text_color,
									font_id = text_element_config.font_id,
									font_size = text_element_config.font_size,
									spacing = text_element_config.spacing,
									line_height = text_element_config.line_height
								},
								user_ptr = text_element_config.user_ptr,
								id = hash_number(u32(line_idx), current_element.id).id,
								z_idx = root.z_idx,
								type = .TEXT,
							}
							)
							y_position += final_line_height
							// We have gone past the screen size so break
							if !s.disable_culling && (current_element_bounding_box.y + y_position > s.layout_dimensions.y) {
								break
							}
						}
					}
					case ^Custom_Element_Config: {
						render_command.type = .CUSTOM
						render_command.render_data = Custom_Render_Data {
							color = shared_config.color,
							corner_radius = shared_config.corner_radius,
							data = v,
						}
						emit_rectangle = false
					}
					case: should_render = false
					}

					if should_render {
						push_render_command(render_command)
					}
				}

				if emit_rectangle {
					push_render_command(Render_Command{
						bounding_box = current_element_bounding_box,
						render_data = Rectangle_Render_Data{
							color = shared_config.color,
							corner_radius = shared_config.corner_radius,
						},
						user_ptr = shared_config.user_ptr,
						id = current_element.id,
						z_idx = root.z_idx,
						type = .RECTANGLE,
					})
				}

				// Setup initial on-axis alignment
				if _, has := element_has_config(current_element_tree_node.layout_element, Text_Element_Config); !has {
					content_size := [2]f32{0, 0}
					if layout_config.direction == .LEFT_TO_RIGHT {
						for child_idx in array_iter(current_element.children) {
							child_element := array_get_ptr(&s.layout_elements, child_idx)
							content_size.x += child_element.dimensions.x
							content_size.y = max(content_size.y, child_element.dimensions.y)
						}
						content_size.x += f32(max(current_element.children.len - 1, 0)) * layout_config.child_gap
						extra_space := current_element.dimensions.x - layout_config.padding.left - layout_config.padding.right - content_size.x
						#partial switch layout_config.child_alignment.x {
						case .LEFT: extra_space = 0
						case .CENTER: extra_space /= 2
						}
						current_element_tree_node.next_child_offset.x += extra_space
						extra_space = max(0, extra_space)
					} else {
						for child_idx in array_iter(current_element.children) {
							child_element := array_get_ptr(&s.layout_elements, child_idx)
							content_size.x = max(content_size.x, child_element.dimensions.x)
							content_size.y += child_element.dimensions.y
						}
						content_size.y += f32(max(current_element.children.len -1, 0)) * layout_config.child_gap
						extra_space := current_element.dimensions.y - layout_config.padding.top - layout_config.padding.bottom - content_size.y
						#partial switch layout_config.child_alignment.y {
						case .TOP: extra_space = 0
						case .CENTER: extra_space /=2
						}
						extra_space = max(0, extra_space)
						current_element_tree_node.next_child_offset.y += extra_space
					}
					if scroll_container_data != nil {
						scroll_container_data.content_size = [2]f32{content_size.x + layout_config.padding.left + layout_config.padding.right, content_size.y + layout_config.padding.top + layout_config.padding.bottom}
					}
				}
			} else {
				// DFS is returning back up
				close_clip_element := false
				// close clip element if required

				if config, has := element_has_config(current_element, Clip_Element_Config); has {
					clip_config := config.(^Clip_Element_Config)
					close_clip_element = true
					for &mapping in array_iter(s.scroll_container_data) {
						if mapping.layout_element == current_element {
							scroll_offset = clip_config.child_offset
							if s.external_scroll_handling_enabled {
								scroll_offset = {}
							}
							break
						}
					}
				}

				if config, has := element_has_config(current_element, Border_Element_Config); has {
					current_element_data := get_hash_map_item(current_element.id)
					current_element_bounding_box := current_element_data.bounding_box
					// culling - don't bother to generate render commands for recangles entirely outside the screen. This won't stop their children from being rendered if they overflow
					if !element_is_offscreen(&current_element_bounding_box) {
						config, has := element_has_config(current_element, Shared_Element_Config)
						shared_config := has ? config.(^Shared_Element_Config) : &DEFAULT_SHARED_ELEMENT_CONFIG
						border_config := find_element_config_with_type(current_element, Border_Element_Config).(^Border_Element_Config)
						push_render_command(Render_Command{
							bounding_box = current_element_bounding_box,
							render_data = Border_Render_Data{
								color = border_config.color,
								corner_radius = shared_config.corner_radius,
								width = border_config.width,
							},
							user_ptr = shared_config.user_ptr,
							id = hash_number(current_element.id, u32(current_element.children.len)).id,
							type = .BORDER,
						})
						if border_config.width.between_children > 0 && border_config.color.a > 0 {
							half_gap := layout_config.child_gap / 2.0
							border_offset := [2]f32{layout_config.padding.left - half_gap, layout_config.padding.top - half_gap}
							if layout_config.direction == .LEFT_TO_RIGHT {
								for child_idx, idx in array_iter(current_element.children) {
									child_element := array_get_ptr(&s.layout_elements, child_idx)
									if idx > 0 {
										push_render_command(Render_Command{
											bounding_box = {current_element_bounding_box.x + border_offset.x + scroll_offset.x, current_element_bounding_box.y + scroll_offset.y, border_config.width.between_children, current_element.dimensions.y},
											render_data = Rectangle_Render_Data{
												color = border_config.color
											},
											user_ptr = shared_config.user_ptr,
											id = hash_number(current_element.id, u32(current_element.children.len+1+idx)).id,
											type = .RECTANGLE,
										})
									}
									border_offset.x += child_element.dimensions.x + layout_config.child_gap
								}
							} else {
								for child_idx, idx in array_iter(current_element.children) {
									child_element := array_get_ptr(&s.layout_elements, child_idx)
									if idx > 0 {
										push_render_command(Render_Command{
											bounding_box = {current_element_bounding_box.x + scroll_offset.x, current_element_bounding_box.y + border_offset.y + scroll_offset.y, current_element.dimensions.x, border_config.width.between_children},
											render_data = Rectangle_Render_Data{
												color = border_config.color,
											},
											user_ptr = shared_config.user_ptr,
											id = hash_number(current_element.id, u32(current_element.children.len + 1 + idx)).id,
											type = .RECTANGLE
										})
									}
									border_offset.y += child_element.dimensions.y + layout_config.child_gap
								}
							}
						}
					}
				}
				if close_clip_element {
					push_render_command(Render_Command{
						id = hash_number(current_element.id, u32(root_element.children.len + 11)).id,
						type = .SCISSOR_END
					})
				}
				dfs_buffer.len -= 1
				continue
			}
			// Add children to the DFS buffer
			if _, has := element_has_config(current_element, Text_Element_Config); !has {
				dfs_buffer.len += current_element.children.len
				for child_idx, idx in array_iter(current_element.children) {
					child_element := array_get_ptr(&s.layout_elements, child_idx)
					if layout_config.direction == .LEFT_TO_RIGHT {
						current_element_tree_node.next_child_offset.y = current_element.layout_config.padding.top
						white_space_around_child := current_element.dimensions.y - layout_config.padding.top + layout_config.padding.bottom - child_element.dimensions.y
						#partial switch layout_config.child_alignment.y {
						case .CENTER: current_element_tree_node.next_child_offset.y += white_space_around_child / 2.0
						case .BOTTOM: current_element_tree_node.next_child_offset.y += white_space_around_child
						}

					} else {
						current_element_tree_node.next_child_offset.x = current_element.layout_config.padding.left
						white_space_around_child := current_element.dimensions.x - layout_config.padding.left - layout_config.padding.right - child_element.dimensions.x
						#partial switch layout_config.child_alignment.x {
						case .CENTER: current_element_tree_node.next_child_offset.x += white_space_around_child / 2.0
						case .RIGHT: current_element_tree_node.next_child_offset.x += white_space_around_child
						}
					}
					child_position := [2]f32 {
						current_element_tree_node.position.x + current_element_tree_node.next_child_offset.x + scroll_offset.x,
						current_element_tree_node.position.y + current_element_tree_node.next_child_offset.y + scroll_offset.y,
					}

					// DFS buffer elements need to be added in reverse because stack traversal happens backwards
					new_node_idx := dfs_buffer.len - 1 - idx
					dfs_buffer.items[new_node_idx] = Layout_Element_Tree_Node{
						layout_element = child_element,
						position = {child_position.x, child_position.y},
						next_child_offset = {child_element.layout_config.padding.left, child_element.layout_config.padding.top},
					}
					s.tree_node_visited.items[new_node_idx] = false

					// update parent offsets
					if layout_config.direction == .LEFT_TO_RIGHT {
						current_element_tree_node.next_child_offset.x += child_element.dimensions.x + layout_config.child_gap
					} else {
						current_element_tree_node.next_child_offset.y += child_element.dimensions.y + layout_config.child_gap
					}
				}
			}
		}
		if root.clip_element_id != 0 {
			push_render_command(Render_Command{
				id = hash_number(root_element.id, u32(root_element.children.len + 11)).id,
				type = .SCISSOR_END
			})
		}
	}
}

@(private="file")
get_cursor_over_ids :: proc() -> Array(Element_ID)
{
	return s.cursor_over_ids
}

DEBUG_VIEW_WIDTH : f32 : 400
DEBUG_VIEW_HIGHLIGHT_COLOR : Color : {168, 66, 28, 100}
DEBUG_VIEW_COLOR_1 : Color : {58, 56, 52, 255}
DEBUG_VIEW_COLOR_2 : Color : {62, 60, 58, 255}
DEBUG_VIEW_COLOR_3 : Color : {141, 133, 135, 255}
DEBUG_VIEW_COLOR_4 : Color : {238, 226, 231, 255}
DEBUG_VIEW_COLOR_SELECTED_ROW : Color : {102, 80, 78, 255}
DEBUG_VIEW_ROW_HEIGHT : f32 : 30
DEBUG_VIEW_OUTER_PADDING : f32 : 10
DEBUG_VIEW_INDENT_WIDTH : f32 : 16
DEBUG_VIEW_TEXT_NAME_CONFIG : Text_Element_Config : {text_color = {238, 226, 231, 255}, font_size = 16, wrap_mode = .WRAP_NONE}
DEBUG_VIEW_SCROLL_VIEW_ITEM_LAYOUT_CONFIG : Layout_Config : {}

// TODO populate debug view stuff

// NOTE DEBUG
@(private="file")
debug_get_element_config_type_label :: proc(type: Debug_Element_Config_Type_Label_Config
) -> Debug_Element_Config_Type_Label_Config
{
	return {}
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
render_debug_view :: proc()
{}

// NOTE - PUBLIC API

min_memory_size :: proc() -> uint
{
	fake_context := State{
		max_element_count = s != nil ? s.max_element_count : DEFAULT_MAX_ELEMENT_COUNT,
		max_measure_text_cache_word_count = s != nil ? s.max_measure_text_cache_word_count : DEFAULT_MAX_MEASURE_TEXT_WORD_CACHE_COUNT,
		arena_internal = virtual.Arena{},
	}
	err := virtual.arena_init_static(&fake_context.arena_internal)
	fake_context.arena = virtual.arena_allocator(&fake_context.arena_internal)
	if err != nil {
		return 0
	}
	initialize_ephemeral_memory(&fake_context)
	initialize_persistent_memory(&fake_context)
	// HACK not sure this is correct
	min_size := fake_context.arena_internal.total_used
	free_all(fake_context.arena)
	return min_size
	// TODO check for a leak
}

create_arena_with_capacity :: proc(cap: uint) -> Arena
{
	arena: Arena
	err := virtual.arena_init_static(&arena, reserved = cap)
	if err != nil {
		if s.error_handler.err_proc != nil {
			s.error_handler.err_proc(Error_Data{
				type = .ARENA_CAPACITY_EXCEEDED,
				text = "Claydo attempted to allocate memory in its arena, but ran out of capacity. Try increasing the capacity of the arena passed to initialize()",
				user_ptr = s.error_handler.user_ptr,
			})
		}
		return {}
	}
	return arena
}

set_measure_text_procedure :: proc(procedure: proc(string, Text_Element_Config, rawptr) -> [2]f32, user_ptr: rawptr)
{
	s.measure_text = procedure
	s.measure_text_user_ptr = user_ptr
}

set_query_scroll_offset_procedure :: proc(procedure: proc(element_id: u32, user_ptr: rawptr) -> [2]f32, user_ptr: rawptr)
{
	s.query_scroll_offset = procedure
	s.query_scroll_offset_user_ptr = user_ptr
}

set_layout_dimensions :: proc(dimensions: [2]f32)
{
	s.layout_dimensions = dimensions
}

set_cursor_state :: proc(position: [2]f32, is_cursor_down: bool)
{
	if s.boolean_warnings.max_elements_exceeded {
		return
	}
	s.cursor_info.position = position
	s.cursor_over_ids.len = 0
	dfs_buffer := s.layout_element_children_buffer
	for root in array_iter(s.layout_element_tree_roots) {
		dfs_buffer.len = 0
		array_push(&dfs_buffer, root.layout_element_idx)
		s.tree_node_visited.items[0] = false
		found := false
		for dfs_buffer.len > 0 {
			if s.tree_node_visited.items[dfs_buffer.len-1] {
				dfs_buffer.len -= 1
				continue
			}
			s.tree_node_visited.items[dfs_buffer.len-1] = true
			current_element := array_get_ptr(&s.layout_elements, array_get(dfs_buffer, dfs_buffer.len-1))
			map_item := get_hash_map_item(current_element.id)
			clip_element_id := array_get(s.layout_element_clip_element_ids, intrinsics.ptr_sub(current_element, &s.layout_elements.items[0]))
			clip_item := get_hash_map_item(u32(clip_element_id))
			if map_item != nil {
				element_box := map_item.bounding_box
				element_box.x -= root.cursor_offset.x
				element_box.y -= root.cursor_offset.y
				if point_is_inside_rect(position, element_box) && (clip_element_id == 0 ||point_is_inside_rect(position, clip_item.bounding_box)) || s.external_scroll_handling_enabled {
					if map_item.on_hover_function != nil {
						map_item.on_hover_function(map_item.element_id, s.cursor_info, map_item.hover_function_user_ptr)
					}
					array_push(&s.cursor_over_ids, map_item.element_id)
					found = true
				}
				if _, has := element_has_config(current_element, Text_Element_Config); has {
					dfs_buffer.len -= 1
					continue
				}
				#reverse for child in array_iter(current_element.children) {
					array_push(&dfs_buffer, child)
					s.tree_node_visited.items[dfs_buffer.len - 1] = false // TODO needs to be range checked
				}
			} else {
				dfs_buffer.len -= 1
			}
		}
		root_element := array_get_ptr(&s.layout_elements, root.layout_element_idx)
		if config, has := element_has_config(root_element, Floating_Element_Config); \
		found && has && config.(^Floating_Element_Config).cursor_capture_mode == .CAPTURE {
			break
		}
	}

	if is_cursor_down {
		if s.cursor_info.state == .PRESSED_THIS_FRAME {
			s.cursor_info.state = .PRESSED
		} else if s.cursor_info.state != .PRESSED {
			s.cursor_info.state = .PRESSED_THIS_FRAME
		}
	} else {
		if s.cursor_info.state == .RELEASED_THIS_FRAME {
			s.cursor_info.state = .RELEASED
		} else if s.cursor_info.state != .RELEASED {
			s.cursor_info.state = .RELEASED_THIS_FRAME
		}
	}
}

default_error_handler_proc :: proc(data: Error_Data)
{}

initialize :: proc(arena: Arena, layout_dimensions: [2]f32, error_handler: Error_Handler
) -> ^State
{
	old_s := s
	s = new(State)
	s^ = {
		max_element_count = old_s != nil ? old_s.max_element_count : DEFAULT_MAX_ELEMENT_COUNT,
		max_measure_text_cache_word_count = old_s != nil ? old_s.max_measure_text_cache_word_count : DEFAULT_MAX_MEASURE_TEXT_WORD_CACHE_COUNT,
		error_handler = error_handler.err_proc != nil ? error_handler : Error_Handler{default_error_handler_proc, nil},
		layout_dimensions = layout_dimensions,
		arena_internal = arena,
	}
	s.arena = virtual.arena_allocator(&s.arena_internal)
	// TODO what happens when we don't free the old data
	initialize_persistent_memory(s)
	s.arena_reset_point = s.arena_internal.total_used
	initialize_ephemeral_memory(s)
	s := s
	for i in 0..<s.layout_elements_hash_map.cap {
		s.layout_elements_hash_map.items[i] = -1
	}
	for i in 0..<s.measure_text_hash_map.cap {
		s.measure_text_hash_map.items[i] = 0
	}
	s.measure_text_hash_map_internal.len = 1 // reserve 0 to mean "no next element"
	s.layout_dimensions = layout_dimensions
	return s
}

get_scroll_offset :: proc() -> [2]f32
{
	if s.boolean_warnings.max_elements_exceeded {
		return {}
	}
	open_layout_element := get_open_layout_element()
	if open_layout_element.id == 0 {
		generate_id_for_anonymous_element(open_layout_element)
	}
	for &mapping in array_iter(s.scroll_container_data) {
		if mapping.layout_element == open_layout_element {
			return mapping.scroll_position
		}
	}
	return {}
}

update_scroll_containers :: proc(enable_drag_scrolling: bool, scroll_delta: [2]f32, delta_time: f32)
{
	is_cursor_active := enable_drag_scrolling && (s.cursor_info.state == .PRESSED_THIS_FRAME || s.cursor_info.state == .PRESSED)
	highest_priority_element_idx := -1
	highest_priority_scroll_data: ^Scroll_Container_Data_Internal
	for &scroll_data, idx in array_iter(s.scroll_container_data) {
		if !scroll_data.open_this_frame {
			array_swapback(&s.scroll_container_data, idx)
			continue
		}
		scroll_data.open_this_frame = false
		hash_map_item := get_hash_map_item(scroll_data.element_id)
		// element isn't rendered this frame but scroll offset has been retained
		if hash_map_item == nil {
			array_swapback(&s.scroll_container_data, idx)
			continue
		}

		// touch / click is released
		if !is_cursor_active && scroll_data.cursor_scroll_active {
			x_diff := scroll_data.scroll_position.x - scroll_data.scroll_origin.x
			if x_diff < -10 || x_diff > 10 {
				scroll_data.scroll_momentum.x = (scroll_data.scroll_position.x - scroll_data.scroll_origin.x) / (scroll_data.momentum_time * 25)
			}
			y_diff := scroll_data.scroll_position.y - scroll_data.scroll_origin.y
			if y_diff < -10 || y_diff > 10 {
				scroll_data.scroll_momentum.y = (scroll_data.scroll_position.y - scroll_data.scroll_origin.y) / (scroll_data.momentum_time * 25)
			}
			scroll_data.cursor_scroll_active = false
			scroll_data.cursor_origin = {0,0}
			scroll_data.scroll_origin = {0,0}
			scroll_data.momentum_time = 0
		}

		scroll_occurred := scroll_delta.x != 0 || scroll_delta.y != 0

		scroll_data.scroll_position.x += scroll_data.scroll_momentum.x
		scroll_data.scroll_momentum.x *= 0.95
		if (scroll_data.scroll_momentum.x > -0.1 && scroll_data.scroll_momentum.x < 0.1) || scroll_occurred {
			scroll_data.scroll_momentum.x = 0
		}
		scroll_data.scroll_position.x = min(max(scroll_data.scroll_position.x, -max(scroll_data.content_size.x - scroll_data.layout_element.dimensions.x, 0)), 0)

		scroll_data.scroll_position.y += scroll_data.scroll_momentum.y
		scroll_data.scroll_momentum.y *= 0.95
		if (scroll_data.scroll_momentum.y > -0.1 && scroll_data.scroll_momentum.y < 0.1) || scroll_occurred {
			scroll_data.scroll_momentum.y = 0
		}
		scroll_data.scroll_position.y = min(max(scroll_data.scroll_position.y, -max(scroll_data.content_size.y - scroll_data.layout_element.dimensions.y, 0)), 0)

		for j in 0..<s.scroll_container_data.len {
			if scroll_data.layout_element.id == array_get(s.cursor_over_ids, j).id {
				highest_priority_element_idx = j
				highest_priority_scroll_data = &scroll_data
			}
		}
	}

	if highest_priority_element_idx > -1 && highest_priority_scroll_data != nil {
		scroll_element := highest_priority_scroll_data.layout_element
		clip_config := find_element_config_with_type(scroll_element, Clip_Element_Config).(^Clip_Element_Config)
		can_scroll_vertically := clip_config.vertical && highest_priority_scroll_data.content_size.y > scroll_element.dimensions.y
		can_scroll_horizontally := clip_config.horizontal && highest_priority_scroll_data.content_size.x > scroll_element.dimensions.x
		// handle wheel scroll
		if can_scroll_vertically {
			highest_priority_scroll_data.scroll_position.y = highest_priority_scroll_data.scroll_position.y + scroll_delta.y * 10
		}
		if can_scroll_horizontally {
			highest_priority_scroll_data.scroll_position.x = highest_priority_scroll_data.scroll_position.x + scroll_delta.x * 10
		}
		// handle click / touch scroll
		if is_cursor_active {
			highest_priority_scroll_data.scroll_momentum = {}
			if !highest_priority_scroll_data.cursor_scroll_active {
				highest_priority_scroll_data.cursor_origin = s.cursor_info.position
				highest_priority_scroll_data.scroll_origin = highest_priority_scroll_data.scroll_position
				highest_priority_scroll_data.cursor_scroll_active = true
			} else {
				scroll_delta_x: f32 = 0
				scroll_delta_y: f32 = 0
				if can_scroll_horizontally {
					old_x_scroll_position := highest_priority_scroll_data.scroll_position.x
					highest_priority_scroll_data.scroll_position.x = highest_priority_scroll_data.scroll_origin.x + s.cursor_info.position.x - highest_priority_scroll_data.cursor_origin.x
					highest_priority_scroll_data.scroll_position.x = max(min(highest_priority_scroll_data.scroll_position.x, 0), -highest_priority_scroll_data.content_size.x + highest_priority_scroll_data.bounding_box.x)
					scroll_delta_x = highest_priority_scroll_data.scroll_position.x - old_x_scroll_position
				}
				if can_scroll_vertically {
					old_y_scroll_position := highest_priority_scroll_data.scroll_position.y
					highest_priority_scroll_data.scroll_position.y = highest_priority_scroll_data.scroll_origin.y + s.cursor_info.position.y - highest_priority_scroll_data.cursor_origin.y
					highest_priority_scroll_data.scroll_position.y = max(min(highest_priority_scroll_data.scroll_position.y, 0), -highest_priority_scroll_data.content_size.y + highest_priority_scroll_data.bounding_box.y)
					scroll_delta_y = highest_priority_scroll_data.scroll_position.x - old_y_scroll_position
				}
				if scroll_delta_x > -0.1 && scroll_delta_x < 0.1 && scroll_delta_y > -0.1 && scroll_delta_y < 0.1 && highest_priority_scroll_data.momentum_time > 0.15 {
					highest_priority_scroll_data.momentum_time = 0
					highest_priority_scroll_data.cursor_origin = s.cursor_info.position
					highest_priority_scroll_data.scroll_origin = highest_priority_scroll_data.scroll_position
				} else {
					highest_priority_scroll_data.momentum_time += delta_time
				}
			}
		}
		// clamp any changes to scroll position to the maximum size of the contents
		if can_scroll_vertically {
			highest_priority_scroll_data.scroll_position.y = max(min(highest_priority_scroll_data.scroll_position.y, 0), -highest_priority_scroll_data.content_size.y + scroll_element.dimensions.y)
		}
		if can_scroll_horizontally {
			highest_priority_scroll_data.scroll_position.x = max(min(highest_priority_scroll_data.scroll_position.x, 0), -highest_priority_scroll_data.content_size.x + scroll_element.dimensions.x)
		}
	}
}

begin_layout :: proc()
{
	initialize_ephemeral_memory(s)
	s.generation += 1
	s.dynamic_element_idx = 0
	root_dimensions: [2]f32 = {s.layout_dimensions.x, s.layout_dimensions.y}
	if s.debug_mode_enabled {
		root_dimensions.x -= DEBUG_VIEW_WIDTH
	}
	s.boolean_warnings = {}
	open_element_with_id(ID("claydo_root_container"))
	configure_open_element_ptr(&Element_Declaration{
		layout = {sizing = {width = Sizing_Min_Max{root_dimensions.x, root_dimensions.x}, height = Sizing_Min_Max{root_dimensions.y, root_dimensions.y}, width_type = .FIXED, height_type = .FIXED}}
	})
	array_push(&s.open_layout_element_stack, 0)
	array_push(&s.layout_element_tree_roots, Layout_Element_Tree_Root{layout_element_idx = 0})
}

end_layout :: proc() -> []Render_Command
{
	s := s
	close_element() // close the root element
	element_exceeded_before_debug_view := s.boolean_warnings.max_elements_exceeded
	if s.debug_mode_enabled && !element_exceeded_before_debug_view {
		s.warnings_enabled = false
		// TODO render_debug_view()
		s.warnings_enabled = true
	}
	if s.boolean_warnings.max_elements_exceeded {
		message: string
		if !element_exceeded_before_debug_view {
			message = "Claydo Error: Layout elements exceeded max_element_count after adding the debug-view to the layout."
		} else {
			message = "Claydo Error: Layout elements exceeded max_element_count"
		}
		push_render_command(Render_Command{
			// HACK what is this -59*4 thing???
			bounding_box = {s.layout_dimensions.x / 2.0 - 59*4, s.layout_dimensions.y / 2.0, 0, 0},
			render_data = Text_Render_Data{ text = message, color = {255, 0, 0, 255}, font_size = 16},
			type = .TEXT
		})
	}
	if s.open_layout_element_stack.len > 1 {
		s.error_handler.err_proc(Error_Data{
			type = .UNBALANCED_OPEN_CLOSE,
			text = "There were still open layout elements when end_layout was called. This results from an unequal number of calls to open_element and close_element.",
			user_ptr = s.error_handler.user_ptr
		})
	}
	calculate_final_layout()
	return s.render_commands.items[:s.render_commands.len]
}

get_element_id :: proc(id_string: string) -> Element_ID
{
	return hash_string(id_string, 0)
}

get_element_id_with_idx :: proc(id_string: string, idx: u32) -> Element_ID
{
	return hash_string_with_offset(id_string, idx, 0)
}

hovered :: proc() -> bool
{
	if s.boolean_warnings.max_elements_exceeded {
		return false
	}
	open_layout_element := get_open_layout_element()
	if open_layout_element.id == 0 {
		generate_id_for_anonymous_element(open_layout_element)
	}
	for id in array_iter(s.cursor_over_ids) {
		if open_layout_element.id == id.id {
			return true
		}
	}
	return false
}

clicked :: proc() -> bool
{
	return hovered() && s.cursor_info.state == .PRESSED_THIS_FRAME
}

on_hover :: proc(procedure: proc(Element_ID, Cursor_Data, rawptr), user_ptr: rawptr)
{
	if s.boolean_warnings.max_elements_exceeded {
		return
	}
	open_layout_element := get_open_layout_element()
	if open_layout_element.id == 0 {
		generate_id_for_anonymous_element(open_layout_element)
	}
	hash_map_item := get_hash_map_item(open_layout_element.id)
	hash_map_item.on_hover_function = procedure
	hash_map_item.hover_function_user_ptr = user_ptr
}

cursor_over :: proc(element_id: Element_ID) -> bool
{
	for id in array_iter(s.cursor_over_ids) {
		if id.id == element_id.id {
			return true
		}
	}
	return false
}

get_scroll_container_data :: proc(id: Element_ID) -> Scroll_Container_Data
{
	for &scroll_container_data in array_iter(s.scroll_container_data) {
		if scroll_container_data.element_id == id.id {
			clip_element_config := find_element_config_with_type(scroll_container_data.layout_element, Clip_Element_Config).(^Clip_Element_Config)
			if clip_element_config == nil {
				return {}
			}
			return {
				scroll_position = &scroll_container_data.scroll_position,
				dimensions = {scroll_container_data.bounding_box.width, scroll_container_data.bounding_box.height},
				content_dimensions = scroll_container_data.content_size,
				config = clip_element_config^,
				found = true
			}
		}
	}
	return {}
}

get_element_data :: proc(id: Element_ID) -> Element_Data
{
	item := get_hash_map_item(id.id)
	if item == &DEFAULT_LAYOUT_ELEMENT_HASH_MAP_ITEM {
		return {}
	}
	return Element_Data{
		bounding_box = item.bounding_box,
		found = true,
	}
}

set_debug_mode_enabled :: proc(enabled: bool)
{
	s.debug_mode_enabled = enabled
}

is_debug_mode_enabled :: proc() -> bool
{
	return s.debug_mode_enabled
}

set_culling_enabled :: proc(enabled: bool)
{
	s.disable_culling = !enabled
}

set_external_scroll_handling_enabled :: proc(enabled: bool)
{
	s.external_scroll_handling_enabled = enabled
}

get_max_element_count :: proc() -> int
{
	return s.max_element_count
}

set_max_element_count :: proc(max_count: int) -> bool
{
	if s != nil {
		s.max_element_count = max_count
		return true
	} else {
		return false
	}
}

get_max_measure_text_cache_word_count :: proc() -> int
{
	return s.max_measure_text_cache_word_count
}

set_max_measure_text_cache_word_count :: proc(count: int) -> bool
{
	if s != nil {
		s.max_measure_text_cache_word_count = count
		return true
	} else {
		return false
	}
}

reset_measure_text_cache :: proc()
{
	s.measure_text_hash_map_internal_free_list.len = 0
	s.measure_text_hash_map.len = 0
	s.measured_words.len = 0
	s.measured_words_free_list.len = 0

	for i in 0..<s.measure_text_hash_map.cap {
		s.measure_text_hash_map.items[i] = 0
	}
	s.measure_text_hash_map_internal.len = 1
}

configure_open_element :: proc(declaration: Element_Declaration) -> bool
{
	declaration := declaration
	return configure_open_element_ptr(&declaration)
}

ui_with_id :: proc(id: Element_ID) -> proc (config: Element_Declaration) -> bool {
	open_element_with_id(id)
	return configure_open_element
}

ui_auto_id :: proc() -> proc (config: Element_Declaration) -> bool {
	open_element()
	return configure_open_element
}

ui :: proc{ui_with_id, ui_auto_id}

text :: proc(text: string, config: ^Text_Element_Config)
{
	open_text_element(text, config)
}

text_config :: proc(config: Text_Element_Config) -> ^Text_Element_Config
{
	return store_text_element_config(config)
}

padding_all :: proc(all: f32) -> Padding
{
	return {left = all, right = all, top = all, bottom = all}
}

border_outside :: proc(width: f32) -> Border_Width
{
	return {width, width, width, width, 0}
}

border_all :: proc(width: f32) -> Border_Width
{
	return {width, width, width, width, width}
}

corner_radius_all :: proc(radius: f32) -> Corner_Radius
{
	return {radius, radius, radius, radius}
}

ID :: proc(label: string, index: u32 = 0) -> Element_ID
{
	return hash_string(label, index)
}

ID_LOCAL :: proc(label: string, index: u32 = 0) -> Element_ID
{
	return hash_string_with_offset(label, index, get_parent_element_id())
}
