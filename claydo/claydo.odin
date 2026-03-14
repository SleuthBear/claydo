

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
	left, right, top, bottom: f32,
}
Sizing :: struct {
	width, height: Sizing_Axis,
}
Sizing_Type :: enum {
	FIT,
	GROW,
	PERCENT,
	FIXED,
}
Sizing_Axis :: struct {
	type:  Sizing_Type,
	value: union {
		Percent,
		Sizing_Min_Max,
	},
}
Percent :: distinct f32
Sizing_Min_Max :: struct {
	min, max: f32,
}
Bounding_Box :: struct {
	x, y:          f32,
	width, height: f32,
}
Alignment :: enum {
	LEFT,
	RIGHT,
	CENTER,
}
Text_Element_Config :: struct {
	user_ptr:    rawptr,
	text_color:  Color,
	font_id:     u16,
	font_size:   f32,
	spacing:     f32,
	line_height: f32,
	wrap_mode:   Wrap_Mode,
	alignment:   Alignment,
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
	RIGHT_BOTTOM,
}
Floating_Attach_Points :: struct {
	element: Attach_Point_Type,
	parent:  Attach_Point_Type,
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
	INLINE,
}
Floating_Clip_To_Element :: enum {
	NONE,
	ATTACHED_PARENT,
}
Floating_Element_Config :: struct {
	offset:              [2]f32,
	expand:              [2]f32,
	parent_id:           u32,
	z_idx:               i16,
	attach_points:       Floating_Attach_Points,
	cursor_capture_mode: Pointer_Capture_Mode,
	attach_to:           Floating_Attach_To_Element,
	clip_to:             Floating_Clip_To_Element,
}
Custom_Element_Config :: distinct rawptr
Clip_Element_Config :: struct {
	horizontal:   bool,
	vertical:     bool,
	child_offset: [2]f32,
}
Border_Width :: struct {
	left, right, top, bottom: f32,
	between_children:         f32,
}
Border_Element_Config :: struct {
	color: Color,
	width: Border_Width,
}
Corner_Radius :: struct {
	top_left, top_right, bottom_left, bottom_right: f32,
}
Text_Render_Data :: struct {
	text:        string,
	color:       Color,
	font_id:     u16,
	font_size:   f32,
	spacing:     f32,
	line_height: f32,
}
Rectangle_Render_Data :: struct {
	color:         Color,
	corner_radius: Corner_Radius,
}
Image_Render_Data :: struct {
	color:         Color,
	corner_radius: Corner_Radius,
	data:          Image_Data,
}
Custom_Render_Data :: struct {
	color:         Color,
	corner_radius: Corner_Radius,
	data:          rawptr,
}
Clip_Render_Data :: struct {
	horizontal: bool,
	vertical:   bool,
}
Border_Render_Data :: struct {
	color:         Color,
	corner_radius: Corner_Radius,
	width:         Border_Width,
}
// TODO render data should not exist. Render command should be a union of commands we can switch on
Render_Data :: union {
	Text_Render_Data,
	Rectangle_Render_Data,
	Image_Render_Data,
	Custom_Render_Data,
	Border_Render_Data,
	Clip_Render_Data,
	Color_Overlay_Render_Data,
}
Render_Command :: struct {
	bounding_box: Bounding_Box,
	render_data:  Render_Data,
	user_ptr:     rawptr,
	id:           u32,
	z_idx:        i16,
	type:         Render_Command_Type,
}
Render_Command_Type :: enum {
	NONE,
	RECTANGLE,
	BORDER,
	TEXT,
	IMAGE,
	SCISSOR_START,
	SCISSOR_END,
	COLOR_OVERLAY_START,
	COLOR_OVERLAY_END,
	CUSTOM,
}
Scroll_Container_Data :: struct {
	scroll_position:    ^[2]f32,
	dimensions:         [2]f32,
	content_dimensions: [2]f32,
	config:             Clip_Element_Config,
	found:              bool,
}
Cursor_Data_Interaction_State :: enum {
	PRESSED_THIS_FRAME,
	PRESSED,
	RELEASED_THIS_FRAME,
	RELEASED,
}
Cursor_Data :: struct {
	position: [2]f32,
	state:    Cursor_Data_Interaction_State,
}
Layout_Alignment_X :: enum {
	LEFT,
	RIGHT,
	CENTER,
}
Layout_Alignment_Y :: enum {
	CENTER,
	TOP,
	BOTTOM,
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
	sizing:          Sizing,
	padding:         Padding,
	child_gap:       f32,
	child_alignment: Child_Alignment,
	direction:       Layout_Direction,
}
Element_Declaration :: struct {
	layout:        Layout_Config,
	color:         Color,
	corner_radius: Corner_Radius,
	aspect_ratio:  Aspect_Ratio,
	image:         Image_Data,
	floating:      Floating_Element_Config,
	custom:        Custom_Element_Config,
	clip:          Clip_Element_Config,
	border:        Border_Element_Config,
	overlay_color: Color,
	transition:    Transition_Element_Config,
	user_ptr:      rawptr,
}
Element_Data :: struct {
	bounding_box: Bounding_Box,
	found:        bool,
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
	type:     Error_Type,
	text:     string,
	user_ptr: rawptr,
}
// NOTE - Implementation -
Boolean_Warnings :: struct {
	max_elements_exceeded,
	max_render_commands_exceeded,
	max_text_measure_cache_exceeded,
	text_measurement_function_not_set: bool,
}
Warning :: struct {
	base_message:    string,
	dynamic_message: string,
}
Transition_Data :: struct {
	bounding_box:  Bounding_Box,
	color:         Color,
	overlay_color: Color,
}
Transition_State :: enum {
	IDLE,
	ENTERING,
	TRANSITIONING,
	EXITING,
}
Transition_Property :: enum u8 {
	ALL,
	BOUNDING_BOX,
	COLOR,
	OVERLAY_COLOR,
	CORNER_RADIUS,
	BORDER,
}
Transition_Callback_Arguments :: struct {
	state:        Transition_State,
	initial:      Transition_Data,
	current:      ^Transition_Data,
	target:       Transition_Data,
	elapsed_time: f32,
	duration:     f32,
	properties:   bit_set[Transition_Property],
}
Transition_Element_Config :: struct {
	handler:        proc(_: Transition_Callback_Arguments) -> bool,
	duration:       f32,
	properties:     bit_set[Transition_Property],
	on_begin_enter: proc(_: Transition_Data) -> Transition_Data,
	on_begin_exit:  proc(_: Transition_Data) -> Transition_Data,
}
Color_Overlay_Render_Data :: distinct Color
Wrapped_Text_Line :: struct {
	dimensions: [2]f32,
	text:       string,
}
Text_Element_Data :: struct {
	text:                 string,
	preferred_dimensions: [2]f32,
	idx:                  int,
	wrapped_lines:        Array(Wrapped_Text_Line),
}
Text_Declaration :: struct {
	config: Text_Element_Config,
	data:   Text_Element_Data,
}
Layout_Element :: struct {
	children:                Array(int),
	dimensions:              [2]f32,
	min_dimensions:          [2]f32,
	id:                      u32,
	floating_children_count: u16,
	config:                  union {
		Element_Declaration,
		Text_Declaration,
	},
}
Transition_Data_Internal :: struct {
	initial_state:      Transition_Data,
	current_state:      Transition_Data,
	target_state:       Transition_Data,
	element_this_frame: ^Layout_Element,
	element_id:         u32,
	parent_id:          u32,
	sibling_idx:        u32,
	elapsed_time:       f32,
	state:              Transition_State,
}
Scroll_Container_Data_Internal :: struct {
	layout_element:       ^Layout_Element,
	bounding_box:         Bounding_Box,
	content_size:         [2]f32,
	scroll_origin:        [2]f32,
	cursor_origin:        [2]f32,
	scroll_momentum:      [2]f32,
	scroll_position:      [2]f32,
	previous_delta:       [2]f32,
	momentum_time:        f32,
	element_id:           u32,
	open_this_frame:      bool,
	cursor_scroll_active: bool,
}
Debug_Element_Data :: struct {
	collision: bool,
	collapsed: bool,
}
Element_ID :: struct {
	id, offset, base_id: u32,
	string_id:           string,
}
Layout_Element_Hash_Map_Item :: struct {
	bounding_box:            Bounding_Box,
	element_id:              Element_ID,
	layout_element:          ^Layout_Element,
	on_hover_function:       proc(_: Element_ID, _: Cursor_Data, _: rawptr),
	hover_function_user_ptr: rawptr,
	next_idx:                int,
	generation:              u32,
	debug_data:              ^Debug_Element_Data,
}
Measured_Word :: struct {
	start_offset, length, next: int,
	width:                      f32,
}
Measure_Text_Cache_Item :: struct {
	unwrapped_dimension:      [2]f32,
	measured_words_start_idx: int,
	min_width:                f32,
	id:                       u32,
	next_idx:                 int,
	generation:               u32,
	contains_new_lines:       bool,
}
Layout_Element_Tree_Node :: struct {
	layout_element:    ^Layout_Element,
	position:          [2]f32,
	next_child_offset: [2]f32,
}
Layout_Element_Tree_Root :: struct {
	layout_element_idx: int,
	parent_id:          u32,
	clip_element_id:    u32,
	z_idx:              i16,
	cursor_offset:      [2]f32,
}
Transition_Elements_Added_Count :: struct {
	elements_added:         int,
	element_children_added: int,
}
Array :: struct($T: typeid) {
	items: []T,
	len:   int,
	cap:   int,
}
Debug_Element_Config_Type_Label_Config :: struct {
	label: string,
	color: Color,
}
Render_Debug_Layout_Data :: struct {
	row_count:                int,
	selected_element_row_idx: int,
}
Error_Handler :: struct {
	err_proc: proc(_: Error_Data),
	user_ptr: rawptr,
}
Arena :: virtual.Arena
// I assume one state at a time. This is probably wrong, but should be easy enough to fix later
State :: struct {
	measure_text:                             proc(
		_: string,
		_: Text_Element_Config,
		_: rawptr,
	) -> [2]f32,
	query_scroll_offset:                      proc(element_id: u32, user_ptr: rawptr) -> [2]f32,
	exiting_elements_length:                  int,
	exiting_elements_children_length:         int,
	max_element_count:                        int,
	max_measure_text_cache_word_count:        int,
	warnings_enabled:                         bool,
	error_handler:                            Error_Handler,
	boolean_warnings:                         Boolean_Warnings,
	warnings:                                 Array(Warning),
	cursor_info:                              Cursor_Data,
	layout_dimensions:                        [2]f32,
	dynamic_element_idx_base_hash:            Element_ID,
	dynamic_element_idx:                      u32,
	debug_mode_enabled:                       bool,
	disable_culling:                          bool,
	external_scroll_handling_enabled:         bool,
	debug_selected_element_id:                u32,
	generation:                               u32,
	measure_text_user_ptr:                    rawptr,
	query_scroll_offset_user_ptr:             rawptr,
	arena_internal:                           Arena,
	arena:                                    runtime.Allocator,
	arena_reset_point:                        uint,
	layout_elements:                          Array(Layout_Element),
	render_commands:                          Array(Render_Command),
	open_layout_element_stack:                Array(int),
	layout_element_children:                  Array(int),
	layout_element_children_buffer:           Array(int),
	reusable_element_idx_buffer:              Array(int),
	layout_element_clip_element_ids:          Array(int),
	layout_element_id_strings:                Array(string),
	wrapped_text_lines:                       Array(Wrapped_Text_Line),
	layout_element_tree_nodes:                Array(Layout_Element_Tree_Node),
	layout_element_tree_roots:                Array(Layout_Element_Tree_Root),
	layout_elements_hash_map_internal:        Array(Layout_Element_Hash_Map_Item),
	layout_elements_hash_map:                 Array(int),
	measure_text_hash_map_internal:           Array(Measure_Text_Cache_Item),
	measure_text_hash_map_internal_free_list: Array(int),
	measure_text_hash_map:                    Array(int),
	measured_words:                           Array(Measured_Word),
	measured_words_free_list:                 Array(int),
	open_clip_element_stack:                  Array(int),
	cursor_over_ids:                          Array(Element_ID),
	scroll_container_datas:                   Array(Scroll_Container_Data_Internal),
	transition_datas:                         Array(Transition_Data_Internal),
	tree_node_visited:                        Array(bool),
	dynamic_string_data:                      Array(byte),
	debug_element_data:                       Array(Debug_Element_Data),
}
DEFAULT_MAX_ELEMENT_COUNT :: 8192
DEFAULT_MAX_MEASURE_TEXT_WORD_CACHE_COUNT :: 16384
MAX_FLOAT: f32 : 999999999999999 // TODO
EPSILON: f32 : 0.01

DEFAULT_LAYOUT_CONFIG: Layout_Config = {}
DEFAULT_TEXT_ELEMENT_CONFIG: Text_Element_Config = {}
DEFAULT_ASPECT_RATIO_ELEMENT_CONFIG: Aspect_Ratio = {}
DEFAULT_IMAGE_ELEMENT_CONFIG: Image_Data = {}
DEFAULT_FLOATING_ELEMENT_CONFIG: Floating_Element_Config = {}
DEFAULT_CUSTOM_ELEMENT_CONFIG: Custom_Element_Config = {}
DEFAULT_CLIP_ELEMENT_CONFIG: Clip_Element_Config = {}
DEFAULT_BORDER_ELEMENT_CONFIG: Border_Element_Config = {}
DEFAULT_LAYOUT_ELEMENT: Layout_Element = {}
DEFAULT_MEASURE_TEXT_CACHE_ITEM: Measure_Text_Cache_Item = {}
DEFAULT_LAYOUT_ELEMENT_HASH_MAP_ITEM: Layout_Element_Hash_Map_Item = {}
DEFAULT_CORNER_RADIUS: Corner_Radius = {}


/* This proc is some bullshit. It is also slower than hardcoding the arrays.*/
@(private = "file")
default_ptr :: proc(t: typeid) -> rawptr {
	switch t {
	case Layout_Config:
		return rawptr(&DEFAULT_LAYOUT_CONFIG)
	case Text_Element_Config:
		return rawptr(&DEFAULT_TEXT_ELEMENT_CONFIG)
	case Aspect_Ratio:
		return rawptr(&DEFAULT_ASPECT_RATIO_ELEMENT_CONFIG)
	case Image_Data:
		return rawptr(&DEFAULT_IMAGE_ELEMENT_CONFIG)
	case Floating_Element_Config:
		return rawptr(&DEFAULT_FLOATING_ELEMENT_CONFIG)
	case Custom_Element_Config:
		return rawptr(&DEFAULT_CUSTOM_ELEMENT_CONFIG)
	case Clip_Element_Config:
		return rawptr(&DEFAULT_CLIP_ELEMENT_CONFIG)
	case Border_Element_Config:
		return rawptr(&DEFAULT_BORDER_ELEMENT_CONFIG)
	case Layout_Element:
		return rawptr(&DEFAULT_LAYOUT_ELEMENT)
	}
	return nil
}
s: ^State

// NOTE - PROCEDURES

// TODO arena stuff. I assume I can offload this to virtual.Arena, but eventually will need to do it myself.
@(private = "file")
array_create :: proc($T: typeid, n: int, allo: runtime.Allocator) -> Array(T) {
	items, err := make([]T, n, allo)

	if err != nil {
		s.error_handler.err_proc(
			Error_Data {
				type = .ARENA_CAPACITY_EXCEEDED,
				text = "Claydo attempted to allocate memory in its arena, but ran out of capacity. Try increasing the capacity of the arena passed to initialize()",
				user_ptr = s.error_handler.user_ptr,
			},
		)
		return {}
	}
	return Array(T){items = items, len = 0, cap = n}
}

@(private = "file")
array_slice :: #force_inline proc(array: ^Array($T), offset, len: int) -> Array(T) {
	if len + offset > array.cap {
		return {}
	}
	sliced_array := Array(T) {
		items = array.items[offset:],
		len   = len,
		cap   = array.cap - offset,
	}
	return sliced_array
}

@(private = "file")
array_push :: #force_inline proc(array: ^Array($T), value: T) -> ^T {
	if array.len >= array.cap {
		return (^T)(default_ptr(T))
	}
	array.items[array.len] = value
	array.len += 1
	return &array.items[array.len - 1]
}

@(private = "file")
array_set :: #force_inline proc(array: ^Array($T), idx: int, value: T) -> ^T {
	if idx >= array.len {
		return (^T)(default_ptr(T))
	}
	array.items[idx] = value
	return &array.items[idx]
}

@(private = "file")
array_get :: #force_inline proc(array: Array($T), idx: int) -> T {
	if idx >= array.len {
		return T{}
	}
	return array.items[idx]
}

@(private = "file")
array_get_ptr :: #force_inline proc(array: ^Array($T), idx: int) -> ^T {
	if idx >= array.len {
		return (^T)(default_ptr(T))
	}
	return &array.items[idx]
}

@(private = "file")
array_peek :: #force_inline proc(array: Array($T)) -> T {
	if array.len <= 0 {
		return T{}
	}
	return array.items[array.len - 1]
}

@(private = "file")
array_pop :: #force_inline proc(array: ^Array($T)) -> T {
	if array.len <= 0 {
		return T{}
	}
	array.len -= 1
	return array.items[array.len]
}

@(private = "file")
array_swapback :: #force_inline proc(array: ^Array($T), idx: int) {
	if idx >= array.len {
		return
	}
	array.items[idx] = array.items[array.len - 1]
	array.len -= 1
}

@(private = "file")
array_iter :: #force_inline proc(array: Array($T)) -> []T {
	return array.items[:array.len]
}

@(private = "file")
write_string_to_char_buffer :: proc(text: string) -> string {
	offset := s.dynamic_string_data.len + 1
	data := ([]byte)(s.dynamic_string_data.items[:])
	data = data[offset:]
	intrinsics.mem_copy(&data, raw_data(text), len(text))
	s.dynamic_string_data.len += len(text)
	return string(s.dynamic_string_data.items[offset:])
}

@(private = "file")
get_open_layout_element :: proc() -> ^Layout_Element {
	return array_get_ptr(
		&s.layout_elements,
		array_get(s.open_layout_element_stack, s.open_layout_element_stack.len - 1),
	)
}

@(private = "file")
get_parent_element :: proc() -> ^Layout_Element {
	stack := s.open_layout_element_stack
	return array_get_ptr(&s.layout_elements, array_get(stack, stack.len - 2))
}

@(private = "file")
get_parent_element_id :: proc() -> u32 {
	return get_parent_element().id
}

@(private = "file")
border_has_any_width :: proc(border_config: ^Border_Element_Config) -> bool {
	return(
		border_config.width.between_children > 0 ||
		border_config.width.left > 0 ||
		border_config.width.right > 0 ||
		border_config.width.top > 0 ||
		border_config.width.bottom > 0 \
	)
}

hash_number :: proc(offset: u32, seed: u32) -> Element_ID {
	hash := seed
	hash += (offset + 48)
	hash += (hash << 10)
	hash ~= (hash >> 6)

	hash += (hash << 3)
	hash ~= (hash >> 11)
	hash += (hash << 15)
	return Element_ID{id = hash + 1, offset = offset, base_id = seed, string_id = ""}
}

hash_string :: proc(key: string, seed: u32) -> Element_ID {
	hash := seed
	for ru in key {
		hash += u32(ru)
		hash += (hash << 10)
		hash ~= (hash >> 6)
	}

	hash += (hash << 3)
	hash ~= (hash >> 11)
	hash += (hash << 15)
	return Element_ID{id = hash + 1, offset = 0, base_id = hash + 1, string_id = key}
}

@(private = "file")
hash_string_with_offset :: proc(key: string, offset, seed: u32) -> Element_ID {
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
@(private = "file")
hash_data :: proc(data: []byte) -> u64 {
	hash: u64 = 0
	for b in data {
		hash += u64(b)
		hash += (hash << 10)
		hash ~= (hash >> 6)
	}
	return hash
}

@(private = "file")
hash_data_string :: proc(data: string) -> u32 {
	hash: u32 = 0
	for ru in data {
		hash += u32(ru)
		hash += (hash << 10)
		hash ~= (hash >> 6)
	}
	return hash
}

@(private = "file")
hash_string_content_with_config :: proc(text: string, config: Text_Element_Config) -> u32 {
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

@(private = "file")
add_measured_word :: proc(word: Measured_Word, previous_word: ^Measured_Word) -> ^Measured_Word {
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
@(private = "file")
measure_text_cached :: proc(
	text: string,
	config: Text_Element_Config,
) -> ^Measure_Text_Cache_Item {
	// Before setting a new item, try and clean up some of the cache
	id := hash_string_content_with_config(text, config)
	hash_bucket := id % u32(s.max_measure_text_cache_word_count / 32)
	element_idx_previous := 0
	// get an index at random?
	element_idx := s.measure_text_hash_map.items[hash_bucket]
	for element_idx != 0 { 	// if it's a valid element
		// get the actual entry for the item
		hash_entry := array_get_ptr(&s.measure_text_hash_map_internal, element_idx)
		if hash_entry.id == id { 	// if the id matches our new string (same contents and config)
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
			array_set(
				&s.measure_text_hash_map_internal,
				element_idx,
				Measure_Text_Cache_Item{measured_words_start_idx = -1},
			)
			// mark that location as available on the free list
			array_push(&s.measure_text_hash_map_internal_free_list, element_idx)
			if element_idx_previous == 0 { 	// we are on the first loop
				s.measure_text_hash_map.items[hash_bucket] = next_idx
			} else {
				previous_hash_entry := array_get_ptr(
					&s.measure_text_hash_map_internal,
					element_idx_previous,
				)
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
	new_cache_item := Measure_Text_Cache_Item {
		measured_words_start_idx = -1,
		id                       = id,
		generation               = s.generation,
	}
	measured: ^Measure_Text_Cache_Item = nil
	if s.measure_text_hash_map_internal_free_list.len > 0 {
		new_item_idx := array_pop(&s.measure_text_hash_map_internal_free_list)
		measured = array_set(&s.measure_text_hash_map_internal, new_item_idx, new_cache_item)
	} else {
		// I wonder why this is cap -1 ...
		if s.measure_text_hash_map_internal.len == s.measure_text_hash_map_internal.cap - 1 {
			if !s.boolean_warnings.max_text_measure_cache_exceeded {
				s.error_handler.err_proc(
					Error_Data {
						type = .ELEMENTS_CAPACITY_EXCEEDED,
						text = "Claydo ran out of capacity while attempting to measure text elements. Try using set_max_element_count() with a higher value.",
						user_ptr = s.error_handler.user_ptr,
					},
				)
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
	space_width: f32 = s.measure_text(" ", config, s.measure_text_user_ptr).x
	temp_word := Measured_Word {
		next = -1,
	}
	previous_word: ^Measured_Word = &temp_word
	for (end < len(text)) {
		if s.measured_words.len == s.measured_words.cap - 1 {
			if !s.boolean_warnings.max_text_measure_cache_exceeded {
				s.error_handler.err_proc(
					Error_Data {
						type = .MEASUREMENT_CAPACITY_EXCEEDED,
						text = "Claydo has run out of space in it's internal text measurement cache. Try using set_max_measure_text_cache_word_count() (default 16384, with 1 unit storing 1 measured word).",
						user_ptr = s.error_handler.user_ptr,
					},
				)
				s.boolean_warnings.max_text_measure_cache_exceeded = true
			}
			return &DEFAULT_MEASURE_TEXT_CACHE_ITEM
		}
		current := text[end]
		if current == ' ' || current == '\n' {
			length := end - start
			dimensions := [2]f32{}
			if length > 0 {
				dimensions = s.measure_text(
					text[start:start + length],
					config,
					s.measure_text_user_ptr,
				)
			}
			measured.min_width = max(dimensions.x, measured.min_width)
			measured_height = max(dimensions.y, measured_height)
			if current == ' ' {
				dimensions.x += space_width
				line_width += dimensions.x
				previous_word = add_measured_word(
					Measured_Word {
						start_offset = start,
						length = length + 1,
						width = dimensions.x,
						next = -1,
					},
					previous_word,
				)
			} else if current == '\n' {
				if length > 0 {
					previous_word = add_measured_word(
						Measured_Word {
							start_offset = start,
							length = length,
							width = dimensions.x,
							next = -1,
						},
						previous_word,
					)
				}
				previous_word = add_measured_word(
					Measured_Word{start_offset = end + 1, length = 0, width = 0, next = -1},
					previous_word,
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
		dimensions := s.measure_text(text[start:end], config, s.measure_text_user_ptr)
		add_measured_word(
			Measured_Word {
				start_offset = start,
				length = end - start,
				width = dimensions.x,
				next = -1,
			},
			previous_word,
		)
		line_width += dimensions.x
		measured_height = max(dimensions.y, measured_height)
		measured.min_width = max(dimensions.x, measured.min_width)
	}
	measured_width = max(line_width, measured_width) - config.spacing

	measured.measured_words_start_idx = temp_word.next
	measured.unwrapped_dimension = {measured_width, measured_height}

	if element_idx_previous != 0 {
		array_get_ptr(&s.measure_text_hash_map_internal, element_idx_previous).next_idx =
			new_item_idx
	} else {
		s.measure_text_hash_map.items[hash_bucket] = new_item_idx
	}
	return measured
}

@(private = "file")
point_is_inside_rect :: proc(point: [2]f32, rect: Bounding_Box) -> bool {
	return(
		point.x >= rect.x &&
		point.x <= rect.x + rect.width &&
		point.y >= rect.y &&
		point.y <= rect.y + rect.height \
	)
}

@(private = "file")
add_hash_map_item :: proc(
	element_id: Element_ID,
	layout_element: ^Layout_Element,
) -> ^Layout_Element_Hash_Map_Item {
	if s.layout_elements_hash_map_internal.len == s.layout_elements_hash_map_internal.cap - 1 {
		return nil
	}
	// new item
	item := Layout_Element_Hash_Map_Item {
		element_id     = element_id,
		layout_element = layout_element,
		next_idx       = -1,
		generation     = s.generation + 1,
	}
	hash_bucket := element_id.id % u32(s.layout_elements_hash_map.cap)
	hash_item_previous := -1
	// random layout item?
	hash_item_idx := s.layout_elements_hash_map.items[hash_bucket]
	for hash_item_idx != -1 {
		hash_item := array_get_ptr(&s.layout_elements_hash_map_internal, hash_item_idx)
		// layout item from the hash map collides with the provided id
		if hash_item.element_id == element_id {
			item.next_idx = hash_item.next_idx
			if hash_item.generation <= s.generation { 	// first collision. Assume same element
				// Update the hash_item
				hash_item.element_id = element_id
				hash_item.generation = s.generation + 1
				hash_item.layout_element = layout_element
				hash_item.debug_data.collision = false
				hash_item.on_hover_function = nil
				hash_item.hover_function_user_ptr = nil
			} else {
				s.error_handler.err_proc(
					Error_Data {
						type = .DUPLICATE_ID,
						text = "An element with this ID was already previously declared during this layout.",
						user_ptr = s.error_handler.user_ptr,
					},
				)
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
		array_get_ptr(&s.layout_elements_hash_map_internal, hash_item_previous).next_idx =
			s.layout_elements_hash_map_internal.len - 1
	} else {
		// If we didn't iterate just set the hash map to point at the inserted location
		s.layout_elements_hash_map.items[hash_bucket] = s.layout_elements_hash_map_internal.len - 1
	}
	return hash_item
}

// Try and retrieve the item from the hash map by it's id (by doing some modulus black magic on a hash value).
// If it's not there return the default.
@(private = "file")
get_hash_map_item :: proc(id: u32) -> ^Layout_Element_Hash_Map_Item {
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

@(private = "file")
generate_id_for_anonymous_element :: proc(open_layout_element: ^Layout_Element) -> Element_ID {
	parent_idx := s.open_layout_element_stack.len - 2
	parent_element := array_get_ptr(
		&s.layout_elements,
		array_get(s.open_layout_element_stack, parent_idx),
	)
	offset := parent_element.children.len + int(parent_element.floating_children_count)
	element_id := hash_number(u32(offset), parent_element.id)
	open_layout_element.id = element_id.id
	add_hash_map_item(element_id, open_layout_element)
	array_push(&s.layout_element_id_strings, element_id.string_id)
	return element_id
}

@(private = "file")
update_aspect_ratio_box :: proc(layout_element: ^Layout_Element) {
	if layout_element.config.(Element_Declaration).aspect_ratio > 0 {
		if layout_element.dimensions.x == 0 && layout_element.dimensions.y != 0 {
			layout_element.dimensions.x =
				layout_element.dimensions.y *
				f32(layout_element.config.(Element_Declaration).aspect_ratio)
		} else if layout_element.dimensions.x != 0 && layout_element.dimensions.y == 0 {
			layout_element.dimensions.y =
				layout_element.dimensions.x *
				f32(1 / layout_element.config.(Element_Declaration).aspect_ratio)
		}
	}
}

close_element :: proc() {
	if s.boolean_warnings.max_elements_exceeded {
		return
	}
	open_layout_element := get_open_layout_element()
	config := &open_layout_element.config.(Element_Declaration)
	element_has_clip_horizontal := config.clip.horizontal
	element_has_clip_vertical := config.clip.vertical

	if element_has_clip_horizontal ||
	   element_has_clip_vertical ||
	   config.floating.attach_to != .NONE {
		s.open_clip_element_stack.len -= 1
	}

	left_right_padding := config.layout.padding.left + config.layout.padding.right
	top_bottom_padding := config.layout.padding.top + config.layout.padding.bottom


	// Attach children to the current open element
	open_layout_element.children.items = s.layout_element_children.items[s.layout_element_children.len:]
	open_layout_element.children.cap =
		s.layout_element_children.cap - s.layout_element_children.len
	if config.layout.direction == .LEFT_TO_RIGHT {
		open_layout_element.dimensions.x = left_right_padding
		open_layout_element.min_dimensions.x = left_right_padding
		for i in 0 ..< open_layout_element.children.len {
			child_idx := array_get(
				s.layout_element_children_buffer,
				s.layout_element_children_buffer.len - open_layout_element.children.len + i,
			)
			child := array_get_ptr(&s.layout_elements, child_idx)
			open_layout_element.dimensions.x += child.dimensions.x
			open_layout_element.dimensions.y = max(
				open_layout_element.dimensions.y,
				child.dimensions.y + top_bottom_padding,
			)
			if !element_has_clip_horizontal {
				open_layout_element.min_dimensions.x += child.min_dimensions.x
			}
			if !element_has_clip_vertical {
				open_layout_element.min_dimensions.y = max(
					open_layout_element.min_dimensions.y,
					child.min_dimensions.y + top_bottom_padding,
				)
			}
			array_push(&s.layout_element_children, child_idx)
		}
		child_gap := f32(max(open_layout_element.children.len - 1, 0)) * config.layout.child_gap
		open_layout_element.dimensions.x += child_gap
		if !element_has_clip_horizontal {
			open_layout_element.min_dimensions.x += child_gap
		}
	} else if config.layout.direction == .TOP_TO_BOTTOM {
		open_layout_element.dimensions.y = top_bottom_padding
		open_layout_element.min_dimensions.y = top_bottom_padding

		for i in 0 ..< open_layout_element.children.len {
			child_idx := array_get(
				s.layout_element_children_buffer,
				s.layout_element_children_buffer.len - open_layout_element.children.len + i,
			)
			child := array_get_ptr(&s.layout_elements, child_idx)
			open_layout_element.dimensions.y += child.dimensions.y
			open_layout_element.dimensions.x = max(
				open_layout_element.dimensions.x,
				child.dimensions.x + left_right_padding,
			)
			if !element_has_clip_vertical {
				open_layout_element.min_dimensions.y += child.min_dimensions.y
			}
			if !element_has_clip_horizontal {
				open_layout_element.min_dimensions.x = max(
					open_layout_element.min_dimensions.x,
					child.min_dimensions.x + left_right_padding,
				)
			}
			array_push(&s.layout_element_children, child_idx)
		}
		child_gap := f32(max(open_layout_element.children.len - 1, 0)) * config.layout.child_gap
		open_layout_element.dimensions.y += child_gap
		if !element_has_clip_vertical {
			open_layout_element.min_dimensions.y += child_gap
		}
	}
	s.layout_element_children_buffer.len -= open_layout_element.children.len

	if config.layout.sizing.width.type != .PERCENT {
		if config.layout.sizing.width.value == nil {
			config.layout.sizing.width.value = Sizing_Min_Max{}
		}
		if config.layout.sizing.width.value.(Sizing_Min_Max).max <= 0 {
			width := config.layout.sizing.width.value.(Sizing_Min_Max)
			width.max = MAX_FLOAT
			config.layout.sizing.width.value = width
		}
		open_layout_element.dimensions.x = min(
			max(
				open_layout_element.dimensions.x,
				config.layout.sizing.width.value.(Sizing_Min_Max).min,
			),
			config.layout.sizing.width.value.(Sizing_Min_Max).max,
		)
		open_layout_element.min_dimensions.x = min(
			max(
				open_layout_element.min_dimensions.x,
				config.layout.sizing.width.value.(Sizing_Min_Max).min,
			),
			config.layout.sizing.width.value.(Sizing_Min_Max).max,
		)
	} else {
		open_layout_element.dimensions.x = 0
	}

	if config.layout.sizing.height.type != .PERCENT {
		if config.layout.sizing.height.value == nil {
			config.layout.sizing.height.value = Sizing_Min_Max{}
		}
		if config.layout.sizing.height.value.(Sizing_Min_Max).max <= 0 {
			height := config.layout.sizing.height.value.(Sizing_Min_Max)
			height.max = MAX_FLOAT
			config.layout.sizing.height.value = height
		}
		open_layout_element.dimensions.y = min(
			max(
				open_layout_element.dimensions.y,
				config.layout.sizing.height.value.(Sizing_Min_Max).min,
			),
			config.layout.sizing.height.value.(Sizing_Min_Max).max,
		)
		open_layout_element.min_dimensions.y = min(
			max(
				open_layout_element.min_dimensions.y,
				config.layout.sizing.height.value.(Sizing_Min_Max).min,
			),
			config.layout.sizing.height.value.(Sizing_Min_Max).max,
		)
	} else {
		open_layout_element.dimensions.y = 0
	}
	update_aspect_ratio_box(open_layout_element)

	element_is_floating := config.floating.attach_to != .NONE

	// Close current element
	closing_element_idx := array_pop(&s.open_layout_element_stack)
	open_layout_element = get_open_layout_element()

	if s.open_layout_element_stack.len > 1 { 	// > 1 due to default root
		if element_is_floating {
			open_layout_element.floating_children_count += 1
			return
		}
		open_layout_element.children.len += 1
		array_push(&s.layout_element_children_buffer, closing_element_idx)
	}
}

// TODO SIMD
@(private = "file")
mem_cmp :: proc(s1, s2: []byte, length: int) -> bool {
	for i in 0 ..< length {
		if s1[i] != s2[i] {
			return false
		}
	}
	return true
}

open_element :: proc() {
	if s.layout_elements.len == s.layout_elements.cap - 1 ||
	   s.boolean_warnings.max_elements_exceeded {
		s.boolean_warnings.max_elements_exceeded = true
		return
	}
	layout_element: Layout_Element = {}
	open_layout_element := array_push(&s.layout_elements, layout_element)
	array_push(&s.open_layout_element_stack, s.layout_elements.len - 1)
	generate_id_for_anonymous_element(open_layout_element)
	if s.open_clip_element_stack.len > 0 {
		array_set(
			&s.layout_element_clip_element_ids,
			s.layout_elements.len - 1,
			array_peek(s.open_clip_element_stack),
		)
	} else {
		array_set(&s.layout_element_clip_element_ids, s.layout_elements.len - 1, 0)
	}
}

open_element_with_id :: proc(element_id: Element_ID) {
	if s.layout_elements.len == s.layout_elements.cap - 1 ||
	   s.boolean_warnings.max_elements_exceeded {
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
		array_set(
			&s.layout_element_clip_element_ids,
			s.layout_elements.len - 1,
			array_peek(s.open_clip_element_stack),
		)
	} else {
		array_set(&s.layout_element_clip_element_ids, s.layout_elements.len - 1, 0)
	}
}

@(private = "file")
open_text_element :: proc(text: string, config: Text_Element_Config) {
	if s.layout_elements.len == s.layout_elements.cap - 1 ||
	   s.boolean_warnings.max_elements_exceeded {
		s.boolean_warnings.max_elements_exceeded = true
		return
	}

	parent_element := get_open_layout_element()

	layout_element := Layout_Element {
		config = Text_Declaration{config = config},
	}
	text_element := array_push(&s.layout_elements, layout_element)
	if s.open_clip_element_stack.len > 0 {
		array_set(
			&s.layout_element_clip_element_ids,
			s.layout_elements.len - 1,
			array_peek(s.open_clip_element_stack),
		)
	} else {
		array_set(&s.layout_element_clip_element_ids, s.layout_elements.len - 1, 0)
	}

	array_push(&s.layout_element_children_buffer, s.layout_elements.len - 1)
	text_measured := measure_text_cached(text, config)
	element_id := hash_number(
		u32(parent_element.children.len) + u32(parent_element.floating_children_count),
		parent_element.id,
	)
	text_element.id = element_id.id
	add_hash_map_item(element_id, text_element)
	array_push(&s.layout_element_id_strings, element_id.string_id)
	text_dimensions := [2]f32 {
		text_measured.unwrapped_dimension.x,
		config.line_height > 0 ? config.line_height : text_measured.unwrapped_dimension.y,
	}
	text_element.dimensions = text_dimensions
	text_element.min_dimensions = {text_measured.min_width, text_dimensions.y}
	config := &text_element.config.(Text_Declaration)
	config.data = Text_Element_Data {
		text                 = text,
		preferred_dimensions = text_measured.unwrapped_dimension,
		idx                  = s.layout_elements.len - 1,
	}
	element_count := s.max_element_count
	parent_element.children.len += 1
}

configure_open_element :: proc(declaration: Element_Declaration) -> bool {
	open_layout_element := get_open_layout_element()
	open_layout_element.config = declaration
	config := &open_layout_element.config.(Element_Declaration)
	if (declaration.layout.sizing.width.type == .PERCENT &&
		   declaration.layout.sizing.width.value.(Percent) > 1) ||
	   (declaration.layout.sizing.height.type == .PERCENT &&
			   declaration.layout.sizing.height.value.(Percent) > 1) {
		s.error_handler.err_proc(
			Error_Data {
				type = .PERCENTAGE_OVER_1,
				text = "An element was configured with PERCENT sizing, but the provided percentage value was over 1.0. Claydo expects a value between 0 and 1, i.e. 20% is 0.2.",
				user_ptr = s.error_handler.user_ptr,
			},
		)
	}
	if declaration.floating.attach_to != .NONE {
		floating_config := &config.floating
		hierarchical_parent := array_get_ptr(
			&s.layout_elements,
			array_get(s.open_layout_element_stack, s.open_layout_element_stack.len - 2),
		)
		if hierarchical_parent != nil {
			clip_element_id := 0
			if declaration.floating.attach_to == .PARENT {
				// attach to direct hierarchical parent
				floating_config.parent_id = hierarchical_parent.id
				if s.open_clip_element_stack.len > 0 {
					clip_element_id = array_get(
						s.open_clip_element_stack,
						s.open_clip_element_stack.len - 1,
					)
				}
			} else if declaration.floating.attach_to == .ELEMENT_WITH_ID {
				parent_item := get_hash_map_item(floating_config.parent_id)
				if parent_item == &DEFAULT_LAYOUT_ELEMENT_HASH_MAP_ITEM {
					s.error_handler.err_proc(
						Error_Data {
							type = .FLOATING_CONTAINER_PARENT_NOT_FOUND,
							text = "A floating element was declared with a parent_id, but no element with that ID was found.",
							user_ptr = s.error_handler.user_ptr,
						},
					)
				} else {
					clip_element_id = array_get(
						s.layout_element_clip_element_ids,
						intrinsics.ptr_sub(
							parent_item.layout_element,
							&s.layout_elements.items[0],
						),
					)
				}
			} else if declaration.floating.attach_to == .ROOT {
				floating_config.parent_id = hash_string("claydo_root_container", 0).id
			}
			if declaration.floating.clip_to == .NONE {
				clip_element_id = 0
			}
			current_element_idx := array_peek(s.open_layout_element_stack)
			array_set(&s.layout_element_clip_element_ids, current_element_idx, clip_element_id)
			array_push(&s.open_clip_element_stack, clip_element_id)
			array_push(
				&s.layout_element_tree_roots,
				Layout_Element_Tree_Root {
					layout_element_idx = array_peek(s.open_layout_element_stack),
					parent_id = floating_config.parent_id,
					clip_element_id = u32(clip_element_id),
					z_idx = floating_config.z_idx,
				},
			)
		}
	}
	if declaration.clip.horizontal || declaration.clip.vertical {
		array_push(&s.open_clip_element_stack, int(open_layout_element.id))
		scroll_offset: ^Scroll_Container_Data_Internal = nil
		for &mapping in array_iter(s.scroll_container_datas) {
			if open_layout_element.id == mapping.element_id {
				scroll_offset = &mapping
				scroll_offset.layout_element = mapping.layout_element
				scroll_offset.open_this_frame = true
			}
		}
		if scroll_offset == nil {
			scroll_offset = array_push(
				&s.scroll_container_datas,
				Scroll_Container_Data_Internal {
					layout_element = open_layout_element,
					scroll_origin = {-1, -1},
					element_id = open_layout_element.id,
					open_this_frame = true,
				},
			)
		}
		if s.external_scroll_handling_enabled {
			scroll_offset.scroll_position = s.query_scroll_offset(
				scroll_offset.element_id,
				s.query_scroll_offset_user_ptr,
			)
		}
	}
	if declaration.transition.handler != nil {
		// create cached data to track scroll position across frames
		transition_data: ^Transition_Data_Internal = nil
		parent_element := get_parent_element()
		for &existing_data in array_iter(s.transition_datas) {
			if (open_layout_element.id == existing_data.element_id) {
				transition_data = &existing_data
				transition_data.element_this_frame = open_layout_element
				transition_data.parent_id = parent_element.id
				transition_data.sibling_idx = u32(parent_element.children.len)
			}
		}
		if transition_data == nil {
			transition_data = array_push(
				&s.transition_datas,
				Transition_Data_Internal {
					state = .ENTERING,
					element_id = open_layout_element.id,
					element_this_frame = open_layout_element,
					parent_id = parent_element != nil ? parent_element.id : 0,
					sibling_idx = parent_element != nil ? u32(parent_element.children.len) : 0,
				},
			)
		}
	}
	return true
}

// TODO just clear instead of re-initializing
@(private = "file")
initialize_ephemeral_memory :: proc(s: ^State) {
	max_element_count := s.max_element_count
	// TODO don't need to zero
	virtual.arena_static_reset_to(&s.arena_internal, s.arena_reset_point)
	s.layout_element_children_buffer = array_create(int, max_element_count, s.arena)
	s.layout_elements = array_create(Layout_Element, max_element_count, s.arena)
	s.warnings = array_create(Warning, 100, s.arena)

	s.layout_element_id_strings = array_create(string, max_element_count, s.arena)
	s.wrapped_text_lines = array_create(Wrapped_Text_Line, max_element_count, s.arena)
	s.layout_element_tree_nodes = array_create(
		Layout_Element_Tree_Node,
		max_element_count,
		s.arena,
	)
	s.layout_element_tree_roots = array_create(
		Layout_Element_Tree_Root,
		max_element_count,
		s.arena,
	)
	s.layout_element_children = array_create(int, max_element_count, s.arena)
	s.open_layout_element_stack = array_create(int, max_element_count, s.arena)
	s.render_commands = array_create(Render_Command, max_element_count, s.arena)
	s.tree_node_visited = array_create(bool, max_element_count, s.arena)
	s.tree_node_visited.len = s.tree_node_visited.cap
	s.open_clip_element_stack = array_create(int, max_element_count, s.arena)
	s.reusable_element_idx_buffer = array_create(int, max_element_count, s.arena)
	s.layout_element_clip_element_ids = array_create(int, max_element_count, s.arena)
	s.dynamic_string_data = array_create(byte, max_element_count, s.arena)
}

@(private = "file")
initialize_persistent_memory :: proc(s: ^State) {
	max_element_count := s.max_element_count
	max_max_measure_text_cache_word_count := s.max_measure_text_cache_word_count
	s.scroll_container_datas = array_create(Scroll_Container_Data_Internal, 100, s.arena)
	s.transition_datas = array_create(Transition_Data_Internal, 100, s.arena)
	s.layout_elements_hash_map_internal = array_create(
		Layout_Element_Hash_Map_Item,
		max_element_count,
		s.arena,
	)
	s.layout_elements_hash_map = array_create(int, max_element_count, s.arena)
	s.measure_text_hash_map = array_create(int, max_element_count, s.arena)
	s.measure_text_hash_map_internal = array_create(
		Measure_Text_Cache_Item,
		max_element_count,
		s.arena,
	)
	s.measure_text_hash_map_internal_free_list = array_create(int, max_element_count, s.arena)
	s.measured_words_free_list = array_create(int, max_element_count, s.arena)
	s.measured_words = array_create(Measured_Word, max_max_measure_text_cache_word_count, s.arena)
	s.cursor_over_ids = array_create(Element_ID, max_element_count, s.arena)
	s.debug_element_data = array_create(Debug_Element_Data, max_element_count, s.arena)
}

@(private = "file")
size_containers_along_axis :: proc(
	x_axis: bool,
	text_elements_out: ^Array(int),
	aspect_ratio_elements_out: ^Array(int),
) {
	bfs_buffer := s.layout_element_children_buffer
	resizable_container_buffer := s.open_layout_element_stack
	for &root in array_iter(s.layout_element_tree_roots) {
		bfs_buffer.len = 0
		root_element := array_get_ptr(&s.layout_elements, root.layout_element_idx)
		config := root_element.config.(Element_Declaration)
		array_push(&bfs_buffer, root.layout_element_idx)
		if config.floating.attach_to != .NONE {
			floating_element_config := &config.floating
			parent_item := get_hash_map_item(floating_element_config.parent_id)
			if parent_item != nil && parent_item != &DEFAULT_LAYOUT_ELEMENT_HASH_MAP_ITEM {
				parent_layout_element := parent_item.layout_element
				#partial switch config.layout.sizing.width.type {
				case .GROW:
					{
						root_element.dimensions.x = parent_layout_element.dimensions.x
					}
				case .PERCENT:
					{
						root_element.dimensions.x =
							parent_layout_element.dimensions.x *
							f32(config.layout.sizing.width.value.(Percent))
					}
				}

				#partial switch config.layout.sizing.height.type {
				case .GROW:
					{
						root_element.dimensions.y = parent_layout_element.dimensions.y
					}
				case .PERCENT:
					{
						root_element.dimensions.y =
							parent_layout_element.dimensions.y *
							f32(config.layout.sizing.height.value.(Percent))
					}
				}
			}
		}
		if config.layout.sizing.width.type != .PERCENT {
			root_element.dimensions.x = min(
				max(
					root_element.dimensions.x,
					config.layout.sizing.width.value.(Sizing_Min_Max).min,
				),
				config.layout.sizing.width.value.(Sizing_Min_Max).max,
			)
		}
		if config.layout.sizing.height.type != .PERCENT {
			root_element.dimensions.y = min(
				max(
					root_element.dimensions.y,
					config.layout.sizing.height.value.(Sizing_Min_Max).min,
				),
				config.layout.sizing.height.value.(Sizing_Min_Max).max,
			)
		}
		for i := 0; i < bfs_buffer.len; i += 1 {
			parent_idx := array_get(bfs_buffer, i)
			parent := array_get_ptr(&s.layout_elements, parent_idx)
			parent_layout := parent.config.(Element_Declaration).layout
			grow_container_count := 0
			parent_size := x_axis ? parent.dimensions.x : parent.dimensions.y
			parent_padding :=
				x_axis ? parent_layout.padding.left + parent_layout.padding.right : parent_layout.padding.top + parent_layout.padding.bottom
			inner_content_size: f32 = 0
			total_padding_and_child_gaps := parent_padding
			sizing_along_axis :=
				(x_axis && parent_layout.direction == .LEFT_TO_RIGHT) ||
				(!x_axis && parent_layout.direction == .TOP_TO_BOTTOM)
			resizable_container_buffer.len = 0
			parent_child_gap := parent_layout.child_gap
			for child_element_index, child_offset in array_iter(parent.children) {
				child_element := array_get_ptr(&s.layout_elements, child_element_index)
				child_config, is_layout := child_element.config.(Element_Declaration)
				child_sizing: Sizing_Type
				child_sizing =
					is_layout ? (x_axis ? child_config.layout.sizing.width.type : child_config.layout.sizing.height.type) : .FIT
				child_size := x_axis ? child_element.dimensions.x : child_element.dimensions.y

				// If the child has children, add it to the buffer to process
				if text_elements_out != nil && !is_layout {
					array_push(text_elements_out, child_element_index)
				} else if child_element.children.len > 0 {
					array_push(&bfs_buffer, child_element_index)
				}

				if is_layout && aspect_ratio_elements_out != nil && child_config.aspect_ratio > 0 {
					array_push(aspect_ratio_elements_out, child_element_index)
				}
				if is_layout && child_config.floating.attach_to == .INLINE {
					continue
				}


				if child_sizing != .PERCENT &&
				   child_sizing != .FIXED &&
				   (is_layout ||
						   child_element.config.(Text_Declaration).config.wrap_mode ==
							   .WRAP_WORDS) {
					array_push(&resizable_container_buffer, child_element_index)
				}

				if sizing_along_axis {
					inner_content_size += (child_sizing == .PERCENT ? 0 : child_size)
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
				child_config, is_layout := child_element.config.(Element_Declaration)
				child_sizing :=
					is_layout ? (x_axis ? child_config.layout.sizing.width : child_config.layout.sizing.height) : sizing_fit()
				child_size :=
					x_axis ? &(child_element.dimensions.x) : &(child_element.dimensions.y)
				if child_sizing.type == .PERCENT {
					child_size^ =
						(parent_size - total_padding_and_child_gaps) *
						f32(child_sizing.value.(Percent))
					if sizing_along_axis {
						inner_content_size += child_size^
					}
					update_aspect_ratio_box(child_element)
				}
			}
			if sizing_along_axis {

				size_to_distribute := parent_size - parent_padding - inner_content_size
				// content is too large, compress children as much as possible
				if size_to_distribute < 0 {
					config, is_layout := parent.config.(Element_Declaration)
					if is_layout &&
					   ((x_axis && config.clip.horizontal) || (!x_axis && config.clip.vertical)) {
						continue
					}
					for size_to_distribute < -EPSILON && resizable_container_buffer.len > 0 {
						largest: f32 = 0
						second_largest: f32 = 0
						width_to_add := size_to_distribute
						for child_idx in array_iter(resizable_container_buffer) {
							child := array_get_ptr(&s.layout_elements, child_idx)
							child_size := x_axis ? child.dimensions.x : child.dimensions.y
							if child_size > parent.dimensions.x {
							}
							if child_size == largest { 	// TODO float_equals. Required?
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

						width_to_add = max(
							width_to_add,
							size_to_distribute / f32(resizable_container_buffer.len),
						)
						for child_idx := 0;
						    child_idx < resizable_container_buffer.len;
						    child_idx += 1 {
							child := array_get_ptr(
								&s.layout_elements,
								array_get(resizable_container_buffer, child_idx),
							)
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
					for child_idx := 0;
					    child_idx < resizable_container_buffer.len;
					    child_idx += 1 {
						child := array_get_ptr(
							&s.layout_elements,
							array_get(resizable_container_buffer, child_idx),
						)
						config, is_layout := child.config.(Element_Declaration)
						child_sizing :=
							is_layout ? (x_axis ? config.layout.sizing.width.type : config.layout.sizing.height.type) : .FIT
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
						width_to_add = min(
							width_to_add,
							size_to_distribute / f32(resizable_container_buffer.len),
						)

						for child_idx := 0;
						    child_idx < resizable_container_buffer.len;
						    child_idx += 1 {
							child := array_get_ptr(
								&s.layout_elements,
								array_get(resizable_container_buffer, child_idx),
							)
							child_size := x_axis ? &child.dimensions.x : &child.dimensions.y
							max_size :=
								x_axis ? config.layout.sizing.width.value.(Sizing_Min_Max).max : config.layout.sizing.height.value.(Sizing_Min_Max).max
							previous_width := child_size^
							if child_size^ == smallest {
								child_size^ += width_to_add
								if child_size^ >= max_size {
									child_size^ = max_size
									array_swapback(&resizable_container_buffer, child_idx)
									child_idx -= 1
								}
								size_to_distribute -= (child_size^ - previous_width)
							}
						}
					}
				}
				// Sizing off-axis
			} else {
				for child_offset in array_iter(resizable_container_buffer) {
					child_element := array_get_ptr(&s.layout_elements, child_offset)
					config, is_layout := child_element.config.(Element_Declaration)
					child_sizing :=
						is_layout ? (x_axis ? config.layout.sizing.width : config.layout.sizing.height) : sizing_fit()
					min_size :=
						x_axis ? child_element.min_dimensions.x : child_element.min_dimensions.y
					child_size :=
						x_axis ? &child_element.dimensions.x : &child_element.dimensions.y
					max_size := parent_size - parent_padding
					// if laying out children of scroll panel grow containers expand to inner content not outer container
					if (x_axis && config.clip.horizontal) || (!x_axis && config.clip.vertical) {
						max_size = max(max_size, inner_content_size)
					}
					if child_sizing.type == .GROW {
						child_size^ = min(max_size, child_sizing.value.(Sizing_Min_Max).max)
					}
					child_size^ = max(min_size, min(child_size^, max_size))
				}
			}
		}
	}
}


@(private = "file")
int_to_string :: proc(integer: int) -> string {
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
		chars[length + 1] = byte(integer % 10 + '0')
		length += 1
		integer /= 10
	}
	if sign < 0 {
		chars[length] = '-'
		length += 1
	}

	for j := 0; j < length; j += 1 {
		chars[j], chars[length - j] = chars[length - j], chars[j]
	}
	s.dynamic_string_data.len += length
	return string(chars[:length])
}

@(private = "file")
push_render_command :: proc(render_command: Render_Command) {
	if s.render_commands.len < s.render_commands.cap - 1 {
		array_push(&s.render_commands, render_command)
	} else {
		if !s.boolean_warnings.max_render_commands_exceeded {
			s.boolean_warnings.max_render_commands_exceeded = true
			s.error_handler.err_proc(
				Error_Data {
					type = .ELEMENTS_CAPACITY_EXCEEDED,
					text = "Claydo ran out of capacity while attempting to create render commands. This is usually caused by a large amount of wrapping text elements while close to the max element capacity. Try using set_max_element_count() with a higher value.",
					user_ptr = s.error_handler.user_ptr,
				},
			)
		}
	}
}

@(private = "file")
element_is_offscreen :: proc(bounding_box: ^Bounding_Box) -> bool {
	if s.disable_culling {
		return false
	}
	return(
		(bounding_box.x > s.layout_dimensions.x) ||
		(bounding_box.y > s.layout_dimensions.y) ||
		(bounding_box.x + bounding_box.width < 0) ||
		(bounding_box.y + bounding_box.height < 0) \
	)
}

@(private = "file")
create_transition_data_for_element :: proc(
	bounding_box: ^Bounding_Box,
	layout_element: ^Layout_Element,
) -> Transition_Data {
	return Transition_Data {
		bounding_box = bounding_box^,
		color = layout_element.config.(Element_Declaration).color,
		overlay_color = layout_element.config.(Element_Declaration).overlay_color,
	}
}

@(private = "file")
should_transition :: proc(current: ^Transition_Data, target: ^Transition_Data) -> bool {
	if !float_equal(current.bounding_box.x, target.bounding_box.x) ||
	   !float_equal(current.bounding_box.y, target.bounding_box.y) ||
	   !float_equal(current.bounding_box.width, target.bounding_box.width) ||
	   !float_equal(current.bounding_box.height, target.bounding_box.height) {
		return true
	}
	if current.color != target.color {
		return true
	}
	if current.overlay_color != target.overlay_color {
		return true
	}
	return false
}

@(private = "file")
float_equal :: proc(a, b: f32) -> bool {
	if (a - b < 0.01 && a - b > -0.01) || (b - a < 0.01 && b - a > -0.01) {
		return true
	}
	return false
}

@(private = "file")
update_element_with_transition_data :: proc(
	bounding_box: ^Bounding_Box,
	layout_element: ^Layout_Element,
	data: ^Transition_Data,
) {
	bounding_box^ = data.bounding_box
	config := &(layout_element.config.(Element_Declaration))
	config.color = data.color
	config.overlay_color = data.overlay_color
}

@(private = "file")
calculate_final_layout :: proc(delta_time: f32) {

	for &transition_data in array_iter(s.transition_datas) {
		element_idx := intrinsics.ptr_sub(
			transition_data.element_this_frame,
			&s.layout_elements.items[0],
		)
		if transition_data.state == .EXITING {
			parent_map_item := get_hash_map_item(transition_data.parent_id)
			parent_element := parent_map_item.layout_element
			new_children_start_idx := s.layout_element_children.len
			found := false
			for i := 0; i < parent_element.children.len; i += 1 {
				if u32(i) == transition_data.sibling_idx {
					array_push(&s.layout_element_children, element_idx)
					found = true
				}
				array_push(&s.layout_element_children, parent_element.children.items[i])
			}
			if !found {
				array_push(&s.layout_element_children, element_idx)
			}
			parent_element.children.len += 1
			parent_element.children.items = s.layout_element_children.items[new_children_start_idx:]
			parent_element.children.cap = s.layout_element_children.len - new_children_start_idx
		}
	}


	// calculate sizing along x axis
	// using clip element stack as it's available
	text_elements := s.open_clip_element_stack
	text_elements.len = 0
	aspect_ratio_elements := s.reusable_element_idx_buffer
	aspect_ratio_elements.len = 0
	size_containers_along_axis(true, &text_elements, &aspect_ratio_elements)

	// Wrap text
	// loop through each text element in the layout
	for &text_element_idx in array_iter(text_elements) {

		// set the wrapped_lines array to the end of the state's wrapped_text_lines array
		element := array_get_ptr(&s.layout_elements, text_element_idx)
		text_element_data := &(&element.config.(Text_Declaration)).data
		text_element_data.wrapped_lines.items = s.wrapped_text_lines.items[s.wrapped_text_lines.len:]
		text_element_data.wrapped_lines.cap = s.wrapped_text_lines.cap - s.wrapped_text_lines.len
		text_element_data.wrapped_lines.len = 0

		// get the container and measure the text
		container_element := array_get_ptr(&s.layout_elements, text_element_data.idx)
		text_config := container_element.config.(Text_Declaration).config

		measure_text_cache_item := measure_text_cached(text_element_data.text, text_config)
		line_width: f32 = 0
		line_height :=
			text_config.line_height > 0 ? text_config.line_height : text_element_data.preferred_dimensions.y
		line_length_chars := 0
		line_start_offset := 0

		// There are no newlines in the item, and it fits inside the container
		if !measure_text_cache_item.contains_new_lines &&
		   text_element_data.preferred_dimensions.x <= container_element.dimensions.x {
			array_push(
				&s.wrapped_text_lines,
				Wrapped_Text_Line {
					dimensions = container_element.dimensions,
					text = text_element_data.text,
				},
			)
			// We increment the lenth here because text_element_data.wrapped_lines is backed by the global store
			text_element_data.wrapped_lines.len += 1
			continue
		}
		space_width := s.measure_text(" ", text_config, s.measure_text_user_ptr).x

		// get the index of the cached measured_word for the first word
		word_idx := measure_text_cache_item.measured_words_start_idx
		for word_idx != -1 {
			// Can't store any more wrapped text
			if s.wrapped_text_lines.len > s.wrapped_text_lines.cap - 1 {
				break
			}
			measured_word := array_get_ptr(&s.measured_words, word_idx)
			// if the only word on the line is too large, render it anyway
			if line_length_chars == 0 &&
			   line_width + measured_word.width > container_element.dimensions.x {
				// We push a wrapped line onto the global array, but the backing data is from text_element_data
				array_push(
					&s.wrapped_text_lines,
					Wrapped_Text_Line {
						dimensions = {measured_word.width, line_height},
						text = string(
							text_element_data.text[measured_word.start_offset:][:measured_word.length],
						),
					},
				)
				// increment wrapped_lines length since it is backed by the global array
				text_element_data.wrapped_lines.len += 1
				// Move on to the next word
				word_idx = measured_word.next
				line_start_offset = measured_word.start_offset + measured_word.length
				// measured_word.length == 0 means new line. (or the measured width is too large)
			} else if measured_word.length == 0 ||
			   line_width + measured_word.width > container_element.dimensions.x {
				// if wrapped text lines list has overflowed, just render out the line
				final_char_is_space :=
					text_element_data.text[max(line_start_offset + line_length_chars - 1, 0)] ==
					' '
				array_push(
					&s.wrapped_text_lines,
					Wrapped_Text_Line {
						dimensions = {final_char_is_space ? -space_width : 0, line_height},
						text = string(
							text_element_data.text[line_start_offset:][:line_length_chars +
							(final_char_is_space ? -1 : 0)],
						),
					},
				)
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
			array_push(
				&s.wrapped_text_lines,
				Wrapped_Text_Line {
					dimensions = {line_width - text_config.spacing, line_height},
					text = text_element_data.text[line_start_offset:line_start_offset +
					line_length_chars],
				},
			)
			text_element_data.wrapped_lines.len += 1
		}
		container_element.dimensions.y = line_height * f32(text_element_data.wrapped_lines.len)
	}

	// scale vertical heights according to aspect ratio
	for aspect_ratio_element_idx in array_iter(aspect_ratio_elements) {
		aspect_element := array_get_ptr(&s.layout_elements, aspect_ratio_element_idx)
		config := &aspect_element.config.(Element_Declaration)
		aspect_element.dimensions.y = f32(1.0 / config.aspect_ratio) * aspect_element.dimensions.x
		min_max_sizing := &config.layout.sizing.height.value.(Sizing_Min_Max)
		min_max_sizing.max = aspect_element.dimensions.y
	}

	// propagate effect of text wrapping, aspect scalign etc. on height of parents
	dfs_buffer := s.layout_element_tree_nodes
	dfs_buffer.len = 0
	// For each tree root in the layout, add it into a depth first search buffer
	for root in array_iter(s.layout_element_tree_roots) {
		s.tree_node_visited.items[dfs_buffer.len] = false
		array_push(
			&dfs_buffer,
			Layout_Element_Tree_Node {
				layout_element = array_get_ptr(&s.layout_elements, root.layout_element_idx),
			},
		)
	}
	// Keep processing until the buffer is empty
	for dfs_buffer.len > 0 {
		// peek
		current_element_tree_node := array_get_ptr(&dfs_buffer, dfs_buffer.len - 1)
		current_element := current_element_tree_node.layout_element
		if !s.tree_node_visited.items[dfs_buffer.len - 1] {
			s.tree_node_visited.items[dfs_buffer.len - 1] = true
			// if it's got no children or is just a text container then don't bother inspecting
			if _, is_text := current_element.config.(Text_Declaration);
			   is_text || current_element.children.len == 0 {
				dfs_buffer.len -= 1
				continue
			}
			// add the children to the DFS buffer (needs to be pushed in reverse so the that the stack traversal is in correct layout order)
			for child_idx in array_iter(current_element.children) {
				s.tree_node_visited.items[dfs_buffer.len] = false
				array_push(
					&dfs_buffer,
					Layout_Element_Tree_Node {
						layout_element = array_get_ptr(&s.layout_elements, child_idx),
					},
				)
			}
			continue
		}
		dfs_buffer.len -= 1
		// DFS node has been visited, this is on the way back up to the root
		layout_config := current_element.config.(Element_Declaration).layout
		if layout_config.direction == .LEFT_TO_RIGHT {
			// resize any parent containers that have grown in height along their non layout axis
			for &child_idx in array_iter(current_element.children) {
				child_element := array_get_ptr(&s.layout_elements, child_idx)
				child_height_with_padding := max(
					child_element.dimensions.y +
					layout_config.padding.top +
					layout_config.padding.bottom,
					current_element.dimensions.y,
				)
				current_element.dimensions.y = min(
					max(
						child_height_with_padding,
						layout_config.sizing.height.value.(Sizing_Min_Max).min,
					),
					layout_config.sizing.height.value.(Sizing_Min_Max).max,
				)
			}
		} else if layout_config.direction == .TOP_TO_BOTTOM {
			// resizing along the layout axis
			content_height := layout_config.padding.top + layout_config.padding.bottom
			for child_idx in array_iter(current_element.children) {
				child_element := array_get_ptr(&s.layout_elements, child_idx)
				content_height += child_element.dimensions.y
			}
			content_height +=
				f32(max(current_element.children.len - 1, 0)) * layout_config.child_gap
			current_element.dimensions.y = min(
				max(content_height, layout_config.sizing.height.value.(Sizing_Min_Max).min),
				layout_config.sizing.height.value.(Sizing_Min_Max).max,
			)
		}
	}
	// calculate sizing along y axis
	size_containers_along_axis(false, nil, nil)

	// scale horizontal widths according to aspect ratio
	for aspect_idx in array_iter(aspect_ratio_elements) {
		aspect_element := array_get_ptr(&s.layout_elements, aspect_idx)
		aspect_element.dimensions.x =
			f32(aspect_element.config.(Element_Declaration).aspect_ratio) *
			aspect_element.dimensions.y
	}

	// sort tree roots by z-index
	sort_max := s.layout_element_tree_roots.len - 1
	for sort_max > 0 {
		for i := 0; i < sort_max; i += 1 {
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
		root_config, is_layout := root_element.config.(Element_Declaration)
		root_position: [2]f32
		parent_hash_map_item := get_hash_map_item(root.parent_id)
		if is_layout && root_config.floating.attach_to != .NONE && parent_hash_map_item != nil {
			config := root_config.floating
			root_dimensions := root_element.dimensions
			parent_bounding_box := parent_hash_map_item.bounding_box
			target_attach_position: [2]f32
			switch config.attach_points.parent {
			case .LEFT_TOP, .LEFT_CENTER, .LEFT_BOTTOM:
				target_attach_position.x = parent_bounding_box.x
			case .CENTER_TOP, .CENTER_CENTER, .CENTER_BOTTOM:
				target_attach_position.x =
					parent_bounding_box.x + (parent_bounding_box.width / 2.0)
			case .RIGHT_TOP, .RIGHT_CENTER, .RIGHT_BOTTOM:
				target_attach_position.x = parent_bounding_box.x + parent_bounding_box.width
			}
			#partial switch config.attach_points.element {
			case .CENTER_TOP, .CENTER_CENTER, .CENTER_BOTTOM:
				target_attach_position.x -= root_dimensions.x / 2.0
			case .RIGHT_TOP, .RIGHT_CENTER, .RIGHT_BOTTOM:
				target_attach_position.x -= root_dimensions.x
			}
			switch config.attach_points.parent {
			case .LEFT_TOP, .RIGHT_TOP, .CENTER_TOP:
				target_attach_position.y = parent_bounding_box.y
			case .LEFT_CENTER, .CENTER_CENTER, .RIGHT_CENTER:
				target_attach_position.y =
					parent_bounding_box.y + (parent_bounding_box.height / 2.0)
			case .LEFT_BOTTOM, .CENTER_BOTTOM, .RIGHT_BOTTOM:
				target_attach_position.y = parent_bounding_box.y + parent_bounding_box.height
			}
			#partial switch config.attach_points.element {
			case .LEFT_CENTER, .CENTER_CENTER, .RIGHT_CENTER:
				target_attach_position.y -= (root_dimensions.y / 2.0)
			case .LEFT_BOTTOM, .CENTER_BOTTOM, .RIGHT_BOTTOM:
				target_attach_position.y -= root_dimensions.y
			}
			target_attach_position.x += config.offset.x
			target_attach_position.y += config.offset.y
			root_position = target_attach_position
		}
		if root.clip_element_id != 0 {
			clip_hash_map_item := get_hash_map_item(root.clip_element_id)
			if clip_hash_map_item != nil &&
			   !element_is_offscreen(&clip_hash_map_item.bounding_box) {
				if s.external_scroll_handling_enabled {
					clip_config :=
						clip_hash_map_item.layout_element.config.(Element_Declaration).clip
					if clip_config.horizontal {
						root_position.x += clip_config.child_offset.x
					}
					if clip_config.vertical {
						root_position.y += clip_config.child_offset.y
					}
				}
				array_push(
					&s.render_commands,
					Render_Command {
						bounding_box = clip_hash_map_item.bounding_box,
						user_ptr = nil,
						id = hash_number(root_element.id, u32(root_element.children.len) + 10).id,
						z_idx = root.z_idx,
						type = .SCISSOR_START,
					},
				)
			}
		}
		array_push(
			&dfs_buffer,
			Layout_Element_Tree_Node {
				layout_element = root_element,
				position = root_position,
				next_child_offset = {
					root_config.layout.padding.left,
					root_config.layout.padding.top,
				},
			},
		)
		s.tree_node_visited.items[0] = false
		for dfs_buffer.len > 0 {
			current_element_tree_node := array_get_ptr(&dfs_buffer, dfs_buffer.len - 1)
			current_element := current_element_tree_node.layout_element
			config, is_layout := &(current_element.config.(Element_Declaration))
			scroll_offset: [2]f32

			// This will only be run a single time for each element in downwards DFS order
			if !s.tree_node_visited.items[dfs_buffer.len - 1] {
				s.tree_node_visited.items[dfs_buffer.len - 1] = true
				current_element_bounding_box := Bounding_Box {
					current_element_tree_node.position.x,
					current_element_tree_node.position.y,
					current_element.dimensions.x,
					current_element.dimensions.y,
				}
				if is_layout && config.floating.attach_to != .NONE {
					expand := config.floating.expand
					current_element_bounding_box.x -= expand.x
					current_element_bounding_box.width += expand.x * 2.0
					current_element_bounding_box.y -= expand.y
					current_element_bounding_box.height += expand.y * 2.0
				}
				scroll_container_data: ^Scroll_Container_Data_Internal
				if is_layout && (config.clip.horizontal || config.clip.vertical) {
					for &mapping in array_iter(s.scroll_container_datas) {
						if mapping.layout_element == current_element {
							scroll_container_data = &mapping
							mapping.bounding_box = current_element_bounding_box
							scroll_offset = config.clip.child_offset
							if s.external_scroll_handling_enabled {
								scroll_offset = {}
							}
							break
						}
					}
				}

				if is_layout && config.transition.handler != nil {
					for i := 0; i < s.transition_datas.len; i += 1 {
						transition_data := array_get_ptr(&s.transition_datas, i)
						if transition_data.element_this_frame == current_element {
							current_transition_data := transition_data.current_state
							target_transition_data := create_transition_data_for_element(
								&current_element_bounding_box,
								current_element,
							)

							if transition_data.state == .ENTERING {
								if config.transition.on_begin_enter == nil {
									transition_data.state = .IDLE
									transition_data.initial_state = target_transition_data
									transition_data.current_state = target_transition_data
								} else {
									transition_data.initial_state =
										config.transition.on_begin_enter(target_transition_data)
									transition_data.current_state = transition_data.initial_state
									transition_data.target_state = target_transition_data
									transition_data.state = .TRANSITIONING
									update_element_with_transition_data(
										&current_element_bounding_box,
										current_element,
										&transition_data.initial_state,
									)
								}
							} else {
								if transition_data.state == .EXITING {
									target_transition_data = transition_data.target_state
								}
								if should_transition(
									&transition_data.target_state,
									&target_transition_data,
								) {
									transition_data.elapsed_time = 0
									transition_data.initial_state = transition_data.current_state
									transition_data.target_state = target_transition_data
									transition_data.state = .TRANSITIONING
								}

								transition_complete := config.transition.handler(
									Transition_Callback_Arguments {
										state = transition_data.state,
										initial = transition_data.initial_state,
										current = &current_transition_data,
										target = target_transition_data,
										elapsed_time = transition_data.elapsed_time,
										duration = config.transition.duration,
										properties = config.transition.properties,
									},
								)
								scroll_offset.x +=
									current_transition_data.bounding_box.x -
									current_element_bounding_box.x
								scroll_offset.y +=
									current_transition_data.bounding_box.y -
									current_element_bounding_box.y

								if !transition_complete {
									update_element_with_transition_data(
										&current_element_bounding_box,
										current_element,
										&current_transition_data,
									)
									current_element_bounding_box =
										current_transition_data.bounding_box
									transition_data.elapsed_time += delta_time
									transition_data.current_state = current_transition_data
								} else {
									if transition_data.state == .TRANSITIONING {
										transition_data.state = .IDLE
										transition_data.initial_state = target_transition_data
										transition_data.current_state = target_transition_data
										transition_data.elapsed_time = 0
									} else if transition_data.state == .EXITING {
										array_swapback(&s.transition_datas, i)
										i -= 1
										continue
									}
								}
							}
						}
					}
				}
				hash_map_item := get_hash_map_item(current_element.id)
				if hash_map_item != nil {
					hash_map_item.bounding_box = current_element_bounding_box
				}


				offscreen := element_is_offscreen(&current_element_bounding_box)

				if text_config, is_text := current_element.config.(Text_Declaration);
				   !offscreen && is_text {
					natural_line_height := text_config.data.preferred_dimensions.y
					final_line_height :=
						text_config.config.line_height > 0 ? text_config.config.line_height : natural_line_height
					line_height_offset := (final_line_height - natural_line_height) / 2.0
					y_pos := line_height_offset
					for line, line_idx in array_iter(text_config.data.wrapped_lines) {
						if len(line.text) == 0 {
							y_pos += final_line_height
							continue
						}
						offset := current_element_bounding_box.width - line.dimensions.x
						if text_config.config.alignment == .LEFT {
							offset = 0
						}
						if text_config.config.alignment == .CENTER {
							offset /= 2
						}
						push_render_command(
							{
								bounding_box = {
									current_element_bounding_box.x + offset,
									current_element_bounding_box.y + y_pos,
									line.dimensions.x,
									line.dimensions.y,
								},
								render_data = Text_Render_Data {
									text = line.text,
									color = text_config.config.text_color,
									font_id = text_config.config.font_id,
									font_size = text_config.config.font_size,
									spacing = text_config.config.spacing,
									line_height = text_config.config.line_height,
								},
								user_ptr = text_config.config.user_ptr,
								id = hash_number(u32(line_idx), current_element.id).id,
								z_idx = root.z_idx,
								type = .TEXT,
							},
						)
						y_pos += final_line_height

						if !s.disable_culling &&
						   current_element_bounding_box.y + y_pos > s.layout_dimensions.y {
							break
						}
					}
				} else if !offscreen {
					if config.overlay_color.a > 0 {
						push_render_command(
							{
								render_data = Color_Overlay_Render_Data(config.overlay_color),
								user_ptr = config.user_ptr,
								id = current_element.id,
								z_idx = root.z_idx,
								type = .COLOR_OVERLAY_START,
							},
						)
					}
					if config.image != nil {
						push_render_command(
							{
								bounding_box = current_element_bounding_box,
								render_data = Image_Render_Data {
									color = config.color,
									corner_radius = config.corner_radius,
									data = config.image,
								},
								user_ptr = config.user_ptr,
								id = current_element.id,
								z_idx = root.z_idx,
								type = .IMAGE,
							},
						)
					}
					if config.custom != nil {
						push_render_command(
							{
								bounding_box = current_element_bounding_box,
								render_data = Custom_Render_Data {
									color = config.color,
									corner_radius = config.corner_radius,
									data = config.custom,
								},
								user_ptr = config.user_ptr,
								id = current_element.id,
								z_idx = root.z_idx,
								type = .CUSTOM,
							},
						)
					}
					if config.clip.horizontal || config.clip.vertical {
						push_render_command(
							{
								bounding_box = current_element_bounding_box,
								render_data = Clip_Render_Data {
									horizontal = config.clip.horizontal,
									vertical = config.clip.vertical,
								},
								user_ptr = config.user_ptr,
								id = current_element.id,
								z_idx = root.z_idx,
								type = .SCISSOR_START,
							},
						)
					}
					if config.color.a > 0 {
						push_render_command(
							{
								bounding_box = current_element_bounding_box,
								render_data = Rectangle_Render_Data {
									color = config.color,
									corner_radius = config.corner_radius,
								},
								user_ptr = config.user_ptr,
								id = current_element.id,
								z_idx = root.z_idx,
								type = .RECTANGLE,
							},
						)
					}
				}

				// Setup initial on-axis alignment
				if is_layout { 	// either layout or text
					content_size := [2]f32{0, 0}
					if config.layout.direction == .LEFT_TO_RIGHT {
						for child_idx in array_iter(current_element.children) {
							child_element := array_get_ptr(&s.layout_elements, child_idx)
							content_size.x += child_element.dimensions.x
							content_size.y = max(content_size.y, child_element.dimensions.y)
						}
						content_size.x +=
							f32(max(current_element.children.len - 1, 0)) * config.layout.child_gap
						extra_space :=
							current_element.dimensions.x -
							config.layout.padding.left -
							config.layout.padding.right -
							content_size.x
						#partial switch config.layout.child_alignment.x {
						case .LEFT:
							extra_space = 0
						case .CENTER:
							extra_space /= 2
						}
						extra_space = max(0, extra_space)
						current_element_tree_node.next_child_offset.x += extra_space
					} else {
						for child_idx in array_iter(current_element.children) {
							child_element := array_get_ptr(&s.layout_elements, child_idx)
							content_size.x = max(content_size.x, child_element.dimensions.x)
							content_size.y += child_element.dimensions.y
						}
						content_size.y +=
							f32(max(current_element.children.len - 1, 0)) * config.layout.child_gap
						extra_space :=
							current_element.dimensions.y -
							config.layout.padding.top -
							config.layout.padding.bottom -
							content_size.y
						#partial switch config.layout.child_alignment.y {
						case .TOP:
							extra_space = 0
						case .CENTER:
							extra_space /= 2
						}
						extra_space = max(0, extra_space)
						current_element_tree_node.next_child_offset.y += extra_space
					}
					if scroll_container_data != nil {
						scroll_container_data.content_size = [2]f32 {
							content_size.x +
							config.layout.padding.left +
							config.layout.padding.right,
							content_size.y +
							config.layout.padding.top +
							config.layout.padding.bottom,
						}
					}
				} else {

				}
			} else {
				// DFS is returning back up
				close_clip_element := false
				current_element_data := get_hash_map_item(current_element.id)
				// close clip element if required
				if is_layout && (config.clip.horizontal || config.clip.vertical) {
					close_clip_element = !element_is_offscreen(&current_element_data.bounding_box)
					for &mapping in array_iter(s.scroll_container_datas) {
						if mapping.layout_element == current_element {
							scroll_offset = config.clip.child_offset
							if s.external_scroll_handling_enabled {
								scroll_offset = {}
							}
							break
						}
					}
				}

				if is_layout && border_has_any_width(&config.border) {
					// culling - don't bother to generate render commands for recangles entirely outside the screen. This won't stop their children from being rendered if they overflow
					if !element_is_offscreen(&current_element_data.bounding_box) {
						push_render_command(
							{
								bounding_box = current_element_data.bounding_box,
								render_data = Border_Render_Data {
									color = config.border.color,
									corner_radius = config.corner_radius,
									width = config.border.width,
								},
								user_ptr = config.user_ptr,
								id = hash_number(current_element.id, u32(current_element.children.len)).id,
								type = .BORDER,
							},
						)
						if config.border.width.between_children > 0 && config.border.color.a > 0 {
							half_gap := config.layout.child_gap / 2.0
							border_offset := [2]f32 {
								config.layout.padding.left - half_gap,
								config.layout.padding.top - half_gap,
							}
							if config.layout.direction == .LEFT_TO_RIGHT {
								for child_idx, idx in array_iter(current_element.children) {
									child_element := array_get_ptr(&s.layout_elements, child_idx)
									if idx > 0 {
										push_render_command(
											{
												bounding_box = {
													current_element_data.bounding_box.x +
													border_offset.x +
													scroll_offset.x,
													current_element_data.bounding_box.y +
													scroll_offset.y,
													config.border.width.between_children,
													current_element.dimensions.y,
												},
												render_data = Rectangle_Render_Data {
													color = config.border.color,
												},
												user_ptr = config.user_ptr,
												id = hash_number(current_element.id, u32(current_element.children.len + 1 + idx)).id,
												type = .RECTANGLE,
											},
										)
									}
									border_offset.x +=
										child_element.dimensions.x + config.layout.child_gap
								}
							} else {
								for child_idx, idx in array_iter(current_element.children) {
									child_element := array_get_ptr(&s.layout_elements, child_idx)
									if idx > 0 {
										push_render_command(
											{
												bounding_box = {
													current_element_data.bounding_box.x +
													scroll_offset.x,
													current_element_data.bounding_box.y +
													border_offset.y +
													scroll_offset.y,
													current_element.dimensions.x,
													config.border.width.between_children,
												},
												render_data = Rectangle_Render_Data {
													color = config.border.color,
												},
												user_ptr = config.user_ptr,
												id = hash_number(current_element.id, u32(current_element.children.len + 1 + idx)).id,
												type = .RECTANGLE,
											},
										)
									}
									border_offset.y +=
										child_element.dimensions.y + config.layout.child_gap
								}
							}
						}
					}
				}

				if is_layout && config.overlay_color.a > 0 {
					push_render_command(
						{
							user_ptr = config.user_ptr,
							id = current_element.id,
							z_idx = root.z_idx,
							type = .COLOR_OVERLAY_END,
						},
					)
				}

				// This exists because the scissor needs to end after borders between elements
				if close_clip_element {
					push_render_command(
						Render_Command {
							id = hash_number(current_element.id, u32(root_element.children.len + 11)).id,
							type = .SCISSOR_END,
						},
					)
				}
				dfs_buffer.len -= 1
				continue
			}
			// Add children to the DFS buffer
			if is_layout {
				dfs_buffer.len += current_element.children.len
				for child_idx, idx in array_iter(current_element.children) {
					child_element := array_get_ptr(&s.layout_elements, child_idx)
					child_config, child_is_layout := child_element.config.(Element_Declaration)
					if config.layout.direction == .LEFT_TO_RIGHT {
						current_element_tree_node.next_child_offset.y = config.layout.padding.top
						white_space_around_child :=
							current_element.dimensions.y -
							config.layout.padding.top -
							config.layout.padding.bottom -
							child_element.dimensions.y

						#partial switch config.layout.child_alignment.y {
						case .CENTER:
							current_element_tree_node.next_child_offset.y +=
								white_space_around_child / 2.0
						case .BOTTOM:
							current_element_tree_node.next_child_offset.y +=
								white_space_around_child
						}

					} else {
						current_element_tree_node.next_child_offset.x = config.layout.padding.left
						white_space_around_child :=
							current_element.dimensions.x -
							config.layout.padding.left -
							config.layout.padding.right -
							child_element.dimensions.x
						#partial switch config.layout.child_alignment.x {
						case .CENTER:
							current_element_tree_node.next_child_offset.x +=
								white_space_around_child / 2.0
						case .RIGHT:
							current_element_tree_node.next_child_offset.x +=
								white_space_around_child
						}
					}
					child_position := [2]f32 {
						current_element_tree_node.position.x +
						current_element_tree_node.next_child_offset.x +
						scroll_offset.x,
						current_element_tree_node.position.y +
						current_element_tree_node.next_child_offset.y +
						scroll_offset.y,
					}

					// DFS buffer elements need to be added in reverse because stack traversal happens backwards
					next_child_offset :=
						child_is_layout ? [2]f32{child_config.layout.padding.left, child_config.layout.padding.top} : {0, 0}
					new_node_idx := dfs_buffer.len - 1 - idx
					dfs_buffer.items[new_node_idx] = Layout_Element_Tree_Node {
						layout_element    = child_element,
						position          = {child_position.x, child_position.y},
						next_child_offset = next_child_offset,
					}
					s.tree_node_visited.items[new_node_idx] = false

					// update parent offsets
					if !child_is_layout || child_config.floating.attach_to != .INLINE {
						if config.layout.direction == .LEFT_TO_RIGHT {
							current_element_tree_node.next_child_offset.x +=
								child_element.dimensions.x + config.layout.child_gap
						} else {
							current_element_tree_node.next_child_offset.y +=
								child_element.dimensions.y + config.layout.child_gap
						}
					}
				}
			}
		}
		if root.clip_element_id != 0 {
			push_render_command(
				Render_Command {
					id = hash_number(root_element.id, u32(root_element.children.len + 11)).id,
					type = .SCISSOR_END,
				},
			)
		}
	}
}

@(private = "file")
get_cursor_over_ids :: proc() -> Array(Element_ID) {
	return s.cursor_over_ids
}

@(private = "file")
clone_transition_elements :: proc(
	root_idx: int,
	root_child_idx: int,
	exiting: bool,
) -> Transition_Elements_Added_Count {
	s := s
	next_empty_slot_offset := 0
	next_empty_child_offset := 0
	for &data in array_iter(s.transition_datas) {
		if (exiting && data.state != .EXITING) || (!exiting && data.state == .EXITING) {
			continue
		}
		all_config, is_layout := data.element_this_frame.config.(Element_Declaration)
		if is_layout && all_config.transition.on_begin_exit != nil {
			config := all_config.transition
			bfs_buffer := s.open_layout_element_stack
			bfs_buffer.len = 0
			s.layout_elements.items[root_idx + next_empty_slot_offset] = data.element_this_frame^
			array_push(&bfs_buffer, root_idx + next_empty_slot_offset)
			current_root_idx := root_idx + next_empty_slot_offset
			data.element_this_frame = &(s.layout_elements.items[root_idx + next_empty_slot_offset])
			buffer_idx := 0
			next_empty_slot_offset += 1
			for buffer_idx < bfs_buffer.len {
				// Note: this is purposefully not a range checked access - if the element has transitioned out, it will be beyond the length of the layoutElements array
				layout_element := &(s.layout_elements.items[array_get(bfs_buffer, buffer_idx)])
				buffer_idx += 1
				first_child_slot := root_child_idx + next_empty_child_offset
				for child in array_iter(layout_element.children) {
					array_push(&bfs_buffer, child)
					child_element := &s.layout_elements.items[child]
					next_slot := root_idx + next_empty_slot_offset
					s.layout_elements.items[next_slot] = child_element^
					new_child_element := &s.layout_elements.items[next_slot]
					if text_config, is_text := &new_child_element.config.(Text_Declaration);
					   exiting && is_text {
						text_config.data.wrapped_lines.len = 0
					}
					child_slot := root_child_idx + next_empty_child_offset
					s.layout_element_children.items[child_slot] = next_slot
					if exiting {
						s.layout_element_children.len += 1
					}
					next_empty_slot_offset += 1
					next_empty_child_offset += 1
				}
				layout_element.children.items = s.layout_element_children.items[first_child_slot:]
				layout_element.children.cap = s.layout_element_children.cap - first_child_slot
			}
		}
	}
	return Transition_Elements_Added_Count {
		elements_added = next_empty_slot_offset,
		element_children_added = next_empty_child_offset,
	}
}

// NOTE DEBUG

DEBUG_VIEW_WIDTH: f32 : 400
DEBUG_VIEW_HIGHLIGHT_COLOR: Color = {168, 66, 28, 100} / 255
DEBUG_VIEW_COLOR_1: Color = {58, 56, 52, 255} / 255
DEBUG_VIEW_COLOR_2: Color = {62, 60, 58, 255} / 255
DEBUG_VIEW_COLOR_3: Color = {141, 133, 135, 255} / 255
DEBUG_VIEW_COLOR_4: Color = {238, 226, 231, 255} / 255
DEBUG_VIEW_COLOR_SELECTED_ROW: Color = {102, 80, 78, 255} / 255
DEBUG_VIEW_ROW_HEIGHT: f32 : 30
DEBUG_VIEW_OUTER_PADDING: f32 : 10
DEBUG_VIEW_INDENT_WIDTH: f32 : 16
DEBUG_VIEW_TEXT_NAME_CONFIG: Text_Element_Config = {
	text_color = Color({238, 226, 231, 255} / 255),
	font_size  = 16,
	wrap_mode  = .WRAP_NONE,
}
debug_view_scroll_view_item_layout_config: Layout_Config = {}


// @(private="file")
// debug_get_element_config_type_label :: proc(config: Element_Config
// ) -> Debug_Element_Config_Type_Label_Config
// {
// 	switch v in config {
// 	case ^Shared_Element_Config: return {"Shared", Color({243,134,48,255} / 255) }
// 	case ^Text_Element_Config: return {"Text", Color({105,210,231,255} / 255) }
// 	case ^Aspect_Ratio: return {"Aspect", Color({101,149,194,255} / 255) }
// 	case ^Image_Data: return {"Image", Color({121,189,154,255} / 255) }
// 	case ^Floating_Element_Config: return {"Floating", Color({250,105,0,255} / 255) }
// 	case ^Clip_Element_Config: return {"Scroll", Color({242, 196, 90, 255} / 255) }
// 	case ^Border_Element_Config: return {"Border", Color({108, 91, 123, 255} / 255) }
// 	case ^Custom_Element_Config: return {"Custom", Color({11,72,107,255} / 255) }
// 	}
// 	return {"Error", Color({0, 0, 0, 255} / 255)}
// }
idi :: proc(label: string, offset: u32) -> Element_ID {
	return hash_string_with_offset(label, offset, 0)
}

@(private = "file")
render_debug_layout_elements_list :: proc(
	initial_roots_length: int,
	highlighted_row_idx: int,
) -> Render_Debug_Layout_Data {
	dfs_buffer := s.reusable_element_idx_buffer
	debug_view_scroll_view_item_layout_config = {
		sizing = {height = sizing_fixed(DEBUG_VIEW_ROW_HEIGHT)},
		child_gap = 6,
		child_alignment = {y = .CENTER},
	}
	layout_data: Render_Debug_Layout_Data
	highlighted_element_id: u32 = 0
	for i := 0; i < initial_roots_length; i += 1 {
		root_idx := u32(i)
		root := array_get_ptr(&s.layout_element_tree_roots, i)
		dfs_buffer.len = 0
		array_push(&dfs_buffer, root.layout_element_idx)
		s.tree_node_visited.items[0] = false
		if root_idx > 0 {
			{ui(idi("claydo_debug_view_empty_row_outer", root_idx))(
				{
					layout = {
						sizing = {width = sizing_grow(0)},
						padding = {DEBUG_VIEW_INDENT_WIDTH / 2.0, 0, 0, 0},
					},
				},
				)
				{ui(idi("claydo_debug_view_empty_row", root_idx))(
					{
						layout = {
							sizing = {
								width = sizing_grow(0),
								height = sizing_fixed(DEBUG_VIEW_ROW_HEIGHT),
							},
						},
						border = {color = DEBUG_VIEW_COLOR_3, width = {top = 1}},
					},
					)}
			}
			layout_data.row_count += 1
		}
		for dfs_buffer.len > 0 {
			current_element_idx := array_peek(dfs_buffer)
			current_element := array_get_ptr(&s.layout_elements, current_element_idx)
			text_config, is_text := current_element.config.(Text_Declaration)
			if s.tree_node_visited.items[dfs_buffer.len - 1] {
				if !is_text && current_element.children.len > 0 {
					close_element()
					close_element()
					close_element()
				}
				dfs_buffer.len -= 1
				continue
			}
			if highlighted_row_idx == layout_data.row_count {
				if s.cursor_info.state == .PRESSED_THIS_FRAME {
					s.debug_selected_element_id = current_element.id
				}
				highlighted_element_id = current_element.id
			}
			s.tree_node_visited.items[dfs_buffer.len - 1] = true
			current_element_data := get_hash_map_item(current_element.id)
			offscreen := element_is_offscreen(&current_element_data.bounding_box)
			if s.debug_selected_element_id == current_element.id {
				layout_data.selected_element_row_idx = layout_data.row_count
			}

			{ui(idi("claydo_debug_view_element_outer", current_element.id))(
				{layout = debug_view_scroll_view_item_layout_config},
				)
				if !(is_text || current_element.children.len == 0) {
					{ui(idi("claydo_debug_view_collapse_element", current_element.id))(
						{
							layout = {
								sizing = {sizing_fixed(16), sizing_fixed(16)},
								child_alignment = {.CENTER, .CENTER},
							},
							corner_radius = corner_radius_all(4),
							border = {color = DEBUG_VIEW_COLOR_3, width = {1, 1, 1, 1, 0}},
						},
						)
						text(
							current_element_data != nil && current_element_data.debug_data.collapsed ? "+" : "-",
							{text_color = DEBUG_VIEW_COLOR_4, font_size = 16},
						)
					}
				} else { 	// square dot for empty containers
					{ui()(
						{
							layout = {
								sizing = {sizing_fixed(16), sizing_fixed(16)},
								child_alignment = {.CENTER, .CENTER},
							},
						},
						)
						{ui()(
							{
								layout = {sizing = {sizing_fixed(8), sizing_fixed(8)}},
								color = DEBUG_VIEW_COLOR_3,
								corner_radius = corner_radius_all(2),
							},
							)}
					}
				}
				// collisions and offscreen info
				if current_element_data != nil {
					if current_element_data.debug_data.collision {
						{ui()(
							{
								layout = {padding = {8, 8, 2, 2}},
								border = {
									color = Color({177, 147, 8, 255} / 255),
									width = {1, 1, 1, 1, 0},
								},
							},
							)
							text("Duplicate ID", {text_color = DEBUG_VIEW_COLOR_3, font_size = 16})
						}
					}
					if offscreen {
						{ui()(
							{
								layout = {padding = {8, 8, 2, 2}},
								border = {
									color = Color({177, 147, 8, 255} / 255),
									width = {1, 1, 1, 1, 0},
								},
							},
							)
							text("Offscreen", {text_color = DEBUG_VIEW_COLOR_3, font_size = 16})
						}
					}
				}
				id_string := s.layout_element_id_strings.items[current_element_idx]
				if len(id_string) > 0 {
					text(
						id_string,
						offscreen ? {text_color = DEBUG_VIEW_COLOR_3, font_size = 16} : DEBUG_VIEW_TEXT_NAME_CONFIG,
					)
				}
				if !is_text {
					current_config := current_element.config.(Element_Declaration)
					label_color := Color{243, 134, 48, 90} / 255
					label_color.a = 90 / 255

					color := current_config.color
					radius := current_config.corner_radius
					if color.a > 0 {
						{ui()(
							{
								layout = {padding = {8, 8, 2, 2}},
								color = label_color,
								corner_radius = corner_radius_all(4),
								border = {color = label_color, width = {1, 1, 1, 1, 0}},
							},
							)
							text(
								"Color",
								{
									text_color = offscreen ? DEBUG_VIEW_COLOR_3 : DEBUG_VIEW_COLOR_4,
									font_size = 16,
								},
							)
						}
					}
					if radius.bottom_left > 0 {
						{ui()(
							{
								layout = {padding = {8, 8, 2, 2}},
								color = label_color,
								corner_radius = corner_radius_all(4),
								border = {color = label_color, width = {1, 1, 1, 1, 0}},
							},
							)
							text(
								"Radius",
								{
									text_color = offscreen ? DEBUG_VIEW_COLOR_3 : DEBUG_VIEW_COLOR_4,
									font_size = 16,
								},
							)
						}
					}
				}
			}

			// Render the text contents below the element as a non-interactive row
			if is_text {
				layout_data.row_count += 1
				text_element_data := text_config.data
				raw_text_config :=
					offscreen ? Text_Element_Config{text_color = DEBUG_VIEW_COLOR_3, font_size = 16} : DEBUG_VIEW_TEXT_NAME_CONFIG
				{ui()(
					{
						layout = {
							sizing = {height = sizing_fixed(DEBUG_VIEW_ROW_HEIGHT)},
							child_alignment = {y = .CENTER},
						},
					},
					)
					{ui()(
						{layout = {sizing = {width = sizing_fixed(DEBUG_VIEW_INDENT_WIDTH + 16)}}},
						)}
					text("\"", raw_text_config)
					text(
						len(text_element_data.text) > 40 ? text_element_data.text[:37] : text_element_data.text,
						raw_text_config,
					)
					if len(text_element_data.text) > 40 {
						text("...", raw_text_config)
					}
					text("\"", raw_text_config)
				}
			} else if current_element.children.len > 0 {
				open_element()
				configure_open_element({layout = {padding = {left = 8}}})
				open_element()
				configure_open_element(
					{
						layout = {padding = {left = DEBUG_VIEW_INDENT_WIDTH}},
						border = {color = DEBUG_VIEW_COLOR_3, width = {left = 1}},
					},
				)
				open_element()
				configure_open_element({layout = {direction = .TOP_TO_BOTTOM}})
			}
			layout_data.row_count += 1
			if !is_text ||
			   (current_element_data != nil && current_element_data.debug_data.collapsed) {
				for i := current_element.children.len - 1; i >= 0; i -= 1 {
					array_push(&dfs_buffer, current_element.children.items[i])
					s.tree_node_visited.items[dfs_buffer.len - 1] = false
				}
			}
		}
	}
	if s.cursor_info.state == .PRESSED_THIS_FRAME {
		collapse_button_id := hash_string("claydo_debug_view_collapse_element", 0)
		#reverse for element_id in array_iter(s.cursor_over_ids) {
			if element_id.base_id == collapse_button_id.base_id {
				highlighted_item := get_hash_map_item(element_id.offset)
				highlighted_item.debug_data.collapsed = !highlighted_item.debug_data.collapsed
				break
			}
		}
	}
	if highlighted_element_id != 0 {
		{ui(id("claydo_debug_view_element_highlight"))(
			{
				layout = {sizing = {sizing_grow(0), sizing_grow(0)}},
				floating = {
					parent_id = highlighted_element_id,
					z_idx = 32767,
					cursor_capture_mode = .PASSTHROUGH,
					attach_to = .ELEMENT_WITH_ID,
				},
			},
			)
			{ui(id("claydo_debug_view_element_highlight_rectangle"))(
				{
					layout = {sizing = {sizing_grow(0), sizing_grow(0)}},
					color = DEBUG_VIEW_HIGHLIGHT_COLOR,
				},
				)}
		}
	}
	return layout_data
}


@(private = "file")
render_debug_layout_sizing :: proc(sizing: Sizing_Axis, info_text_config: Text_Element_Config) {
	sizing := sizing
	sizing_label := "GROW"
	if sizing.type == .FIT {
		sizing_label = "FIT"
	} else if sizing.type == .PERCENT {
		sizing_label = "PERCENT"
	} else if sizing.type == .FIXED {
		sizing_label = "FIXED"
	}
	text(sizing_label, info_text_config)
	if sizing.type == .GROW ||
	   sizing.type == .FIXED ||
	   sizing.type == .FIT && sizing.value != nil {
		text("(", info_text_config)
		if sizing.value.(Sizing_Min_Max).min != 0 {
			text("min: ", info_text_config)
			text(int_to_string(int(sizing.value.(Sizing_Min_Max).min)), info_text_config)
		}
		if sizing.value.(Sizing_Min_Max).max != MAX_FLOAT {
			text("max: ", info_text_config)
			text(int_to_string(int(sizing.value.(Sizing_Min_Max).max)), info_text_config)
		}
		text(")", info_text_config)
	} else if sizing.type == .PERCENT {
		if sizing.value == nil {
			sizing.value = Percent(0)
		}
		text("( ", info_text_config)
		text(int_to_string(int(sizing.value.(Percent) * 100)), info_text_config)
		text("%)", info_text_config)
	}
}

// @(private="file")
// render_debug_view_element_config_header :: proc(element_id: string, actual: Element_Config)
// {
// 	config := debug_get_element_config_type_label(actual)
// 	background_color := config.color
// 	background_color.a = 90
// 	{ui()({layout = {sizing = {width = sizing_grow(0)}, padding = padding_all(DEBUG_VIEW_OUTER_PADDING), child_alignment = {y = .CENTER}}})
// 		{ui()({layout = {padding = {8,8,2,2}}, color = background_color, corner_radius = corner_radius_all(4), border = {color=config.color, width={1,1,1,1,0}}})
// 			text(config.label, {text_color = DEBUG_VIEW_COLOR_4, font_size=16})
// 		}
// 		{ui()({layout = {sizing = {width = sizing_grow(0)}}})}
// 		text(element_id, {text_color = DEBUG_VIEW_COLOR_3, font_size = 16, wrap_mode = .WRAP_NONE})
// 	}
// }

@(private = "file")
render_debug_view_color :: proc(color: Color, config: Text_Element_Config) {
	{ui()({layout = {child_alignment = {y = .CENTER}}})
		text("{ r: ", config)
		text(int_to_string(int(color.r * 255)), config)
		text("g: ", config)
		text(int_to_string(int(color.b * 255)), config)
		text("b: ", config)
		text(int_to_string(int(color.g * 255)), config)
		text("a: ", config)
		text(int_to_string(int(color.a * 255)), config)
		text(" }", config)
		{ui()({layout = {sizing = {width = sizing_fixed(10)}}})}
		{ui()(
			{
				layout = {
					sizing = {
						sizing_fixed(DEBUG_VIEW_ROW_HEIGHT - 8),
						sizing_fixed(DEBUG_VIEW_ROW_HEIGHT - 8),
					},
				},
				color = color,
				corner_radius = corner_radius_all(4),
				border = {color = DEBUG_VIEW_COLOR_4, width = {1, 1, 1, 1, 0}},
			},
			)}
	}
}

@(private = "file")
render_debug_view_corner_radius :: proc(
	corner_radius: Corner_Radius,
	config: Text_Element_Config,
) {
	{ui()({layout = {child_alignment = {y = .CENTER}}})
		text("{ top_left: ", config)
		text(int_to_string(int(corner_radius.top_left)), config)
		text(" top_right: ", config)
		text(int_to_string(int(corner_radius.top_right)), config)
		text(" bottom_left: ", config)
		text(int_to_string(int(corner_radius.bottom_left)), config)
		text(" bottom_right: ", config)
		text(int_to_string(int(corner_radius.bottom_right)), config)
		text(" }", config)
	}
}

@(private = "file")
handle_debug_view_close_button_interaction :: proc(
	element_id: Element_ID,
	cursor_info: Cursor_Data,
	user_ptr: rawptr,
) {
	if cursor_info.state == .PRESSED_THIS_FRAME {
		s.debug_mode_enabled = false
	}
}

@(private = "file")
render_debug_view :: proc() {
	close_button_id := hash_string("claydo_debug_view_top_header_close_button_outer", 0)
	if s.cursor_info.state == .PRESSED_THIS_FRAME {
		for id in array_iter(s.cursor_over_ids) {
			if id.id == close_button_id.id {
				s.debug_mode_enabled = false
				return
			}
		}
	}

	initial_roots_length := s.layout_element_tree_roots.len
	initial_elements_len := s.layout_elements.len
	info_text_config := Text_Element_Config {
		text_color = DEBUG_VIEW_COLOR_4,
		font_size  = 16,
		wrap_mode  = .WRAP_NONE,
	}
	info_title_config := Text_Element_Config {
		text_color = DEBUG_VIEW_COLOR_3,
		font_size  = 16,
		wrap_mode  = .WRAP_NONE,
	}
	scroll_id := hash_string("claydo_debug_view_outer_scroll_plane", 0)
	scroll_y_offset: f32 = 0
	cursor_in_debug_view := s.cursor_info.position.y < s.layout_dimensions.y - 300
	for &scroll_container_data in array_iter(s.scroll_container_datas) {
		if scroll_container_data.element_id == scroll_id.id {
			if !s.external_scroll_handling_enabled {
				scroll_y_offset = scroll_container_data.scroll_position.y
			} else {
				cursor_in_debug_view =
					s.cursor_info.position.y + scroll_container_data.scroll_position.y <
					s.layout_dimensions.y - 300
			}
			break
		}
	}
	highlighted_row: int =
		cursor_in_debug_view ? int((s.cursor_info.position.y - scroll_y_offset) / DEBUG_VIEW_ROW_HEIGHT) - 1 : -1
	if s.cursor_info.position.x < s.layout_dimensions.x - DEBUG_VIEW_WIDTH {
		highlighted_row = -1
	}
	layout_data: Render_Debug_Layout_Data = {}
	{ui(id("claydo_debug_view"))(
		{
			layout = {
				sizing = {sizing_fixed(DEBUG_VIEW_WIDTH), sizing_fixed(s.layout_dimensions.y)},
				direction = .TOP_TO_BOTTOM,
			},
			floating = {
				z_idx = 32765,
				attach_points = {element = .LEFT_CENTER, parent = .RIGHT_CENTER},
				attach_to = .ROOT,
				clip_to = .ATTACHED_PARENT,
			},
			border = {color = DEBUG_VIEW_COLOR_3, width = {bottom = 1}},
		},
		)
		{ui()(
			{
				layout = {
					sizing = {sizing_grow(0), sizing_fixed(DEBUG_VIEW_ROW_HEIGHT)},
					padding = {DEBUG_VIEW_OUTER_PADDING, DEBUG_VIEW_OUTER_PADDING, 0, 0},
					child_alignment = {y = .CENTER},
				},
				color = DEBUG_VIEW_COLOR_2,
			},
			)
			text("Claydo Debug Tools", info_text_config)
			{ui()({layout = {sizing = {width = sizing_grow(0)}}})}
			// Close button
			{ui()(
				{
					layout = {
						sizing = {
							sizing_fixed(DEBUG_VIEW_ROW_HEIGHT - 10),
							sizing_fixed(DEBUG_VIEW_ROW_HEIGHT - 10),
						},
						child_alignment = {.CENTER, .CENTER},
					},
					color = {217, 91, 67, 80},
					corner_radius = corner_radius_all(4),
					border = {color = Color({217, 91, 67, 255} / 255), width = {1, 1, 1, 1, 0}},
				},
				)
				on_hover(handle_debug_view_close_button_interaction, nil)
				text("x", {text_color = DEBUG_VIEW_COLOR_4, font_size = 16})
			}
		}
		{ui()({layout = {sizing = {sizing_grow(0), sizing_fixed(1)}}, color = DEBUG_VIEW_COLOR_3})}
		{ui(scroll_id)(
			{
				layout = {sizing = {sizing_grow(0), sizing_grow(0)}},
				clip = {horizontal = true, vertical = true, child_offset = get_scroll_offset()},
			},
			)
			{ui()(
				{
					layout = {
						sizing = {sizing_grow(0), sizing_grow(0)},
						direction = .TOP_TO_BOTTOM,
					},
					color = ((initial_elements_len + initial_roots_length) & 1) == 0 ? DEBUG_VIEW_COLOR_2 : DEBUG_VIEW_COLOR_1,
				},
				)
				panel_contents_id := hash_string("claydo_debug_view_panel_outer", 0)
				{ui(panel_contents_id)(
					{
						layout = {sizing = {sizing_grow(0), sizing_grow(0)}},
						floating = {
							z_idx = 32766,
							cursor_capture_mode = .PASSTHROUGH,
							attach_to = .PARENT,
							clip_to = .ATTACHED_PARENT,
						},
					},
					)
					{ui()(
						{
							layout = {
								sizing = {sizing_grow(0), sizing_grow(0)},
								padding = {
									DEBUG_VIEW_OUTER_PADDING,
									DEBUG_VIEW_OUTER_PADDING,
									0,
									0,
								},
								direction = .TOP_TO_BOTTOM,
							},
						},
						)
						layout_data = render_debug_layout_elements_list(
							initial_roots_length,
							highlighted_row,
						)
					}
				}
				content_width :=
					get_hash_map_item(panel_contents_id.id).layout_element.dimensions.x
				{ui()(
					{
						layout = {
							sizing = {width = sizing_fixed(content_width)},
							direction = .TOP_TO_BOTTOM,
						},
					},
					)}
				for i := 0; i < layout_data.row_count; i += 1 {
					row_color := (i & 1) == 0 ? DEBUG_VIEW_COLOR_2 : DEBUG_VIEW_COLOR_1
					if (i == layout_data.selected_element_row_idx) {
						row_color = DEBUG_VIEW_COLOR_SELECTED_ROW
					}
					if (i == highlighted_row) {
						row_color.r *= 1.25
						row_color.g *= 1.25
						row_color.b *= 1.25
					}
					{ui()(
						{
							layout = {
								sizing = {sizing_grow(0), sizing_fixed(DEBUG_VIEW_ROW_HEIGHT)},
								direction = .TOP_TO_BOTTOM,
							},
							color = row_color,
						},
						)}
				}
			}
		}
		{ui()(
			{
				layout = {sizing = {width = sizing_grow(0), height = sizing_fixed(1)}},
				color = DEBUG_VIEW_COLOR_3,
			},
			)}
		if s.debug_selected_element_id != 0 {
			selected_item := get_hash_map_item(s.debug_selected_element_id)
			text_config, is_text := selected_item.layout_element.config.(Text_Declaration)
			config, is_layout := selected_item.layout_element.config.(Element_Declaration)
			{ui()(
				{
					layout = {
						sizing = {sizing_grow(0), sizing_grow(300)},
						direction = .TOP_TO_BOTTOM,
					},
					color = DEBUG_VIEW_COLOR_2,
					clip = {vertical = true, child_offset = get_scroll_offset()},
					border = {color = DEBUG_VIEW_COLOR_3, width = {between_children = 1}},
				},
				)
				{ui()(
					{
						layout = {
							sizing = {sizing_grow(0), sizing_grow(DEBUG_VIEW_ROW_HEIGHT + 8)},
							padding = {DEBUG_VIEW_OUTER_PADDING, DEBUG_VIEW_OUTER_PADDING, 0, 0},
							child_alignment = {y = .CENTER},
						},
					},
					)
					text("Layout Config", info_text_config)
					{ui()({layout = {sizing = {width = sizing_grow(0)}}})}
					if len(selected_item.element_id.string_id) != 0 {
						text(selected_item.element_id.string_id, info_title_config)
						if (selected_item.element_id.offset != 0) {
							text(" (", info_title_config)
							text(
								int_to_string(int(selected_item.element_id.offset)),
								info_title_config,
							)
							text(")", info_title_config)
						}
					}
				}
				attribute_config_padding := Padding {
					DEBUG_VIEW_OUTER_PADDING,
					DEBUG_VIEW_OUTER_PADDING,
					8,
					8,
				}
				// layout config debug info
				if is_layout {
					{ui()(
						{
							layout = {
								padding = attribute_config_padding,
								child_gap = 8,
								direction = .TOP_TO_BOTTOM,
							},
						},
						)
						text("Bounding Box", info_title_config)
						{ui()({layout = {direction = .LEFT_TO_RIGHT}})
							text("{ x: ", info_text_config)
							text(
								int_to_string(int(selected_item.bounding_box.x)),
								info_text_config,
							)
							text(", y: ", info_text_config)
							text(
								int_to_string(int(selected_item.bounding_box.y)),
								info_text_config,
							)
							text(", width: ", info_text_config)
							text(
								int_to_string(int(selected_item.bounding_box.width)),
								info_text_config,
							)
							text(", height: ", info_text_config)
							text(
								int_to_string(int(selected_item.bounding_box.height)),
								info_text_config,
							)
							text(" }", info_text_config)
						}
						text("Layout Direction", info_title_config)
						layout_config := config.layout
						text(
							layout_config.direction == .TOP_TO_BOTTOM ? "TOP_TO_BOTTOM" : "LEFT_TO_RIGHT",
							info_text_config,
						)
						// sizing
						text("Sizing", info_title_config)
						{ui()({layout = {direction = .LEFT_TO_RIGHT}})
							text("width: ", info_text_config)
							render_debug_layout_sizing(
								layout_config.sizing.width,
								info_text_config,
							)
						}
						{ui()({layout = {direction = .LEFT_TO_RIGHT}})
							text("height: ", info_text_config)
							render_debug_layout_sizing(
								layout_config.sizing.height,
								info_text_config,
							)
						}
						// padding
						text("Padding", info_title_config)
						{ui(id("debug_view_element_info_padding"))(
							{layout = {direction = .LEFT_TO_RIGHT}},
							)
							text("{ left: ", info_text_config)
							text(int_to_string(int(layout_config.padding.left)), info_text_config)
							text(", right: ", info_text_config)
							text(int_to_string(int(layout_config.padding.right)), info_text_config)
							text(", top: ", info_text_config)
							text(int_to_string(int(layout_config.padding.top)), info_text_config)
							text(", bottom: ", info_text_config)
							text(
								int_to_string(int(layout_config.padding.bottom)),
								info_text_config,
							)
							text(" }", info_text_config)
						}
						// child gap
						text("Child Gap", info_title_config)
						text(int_to_string(int(layout_config.child_gap)), info_text_config)
						// child alignment
						text("Child Alignment", info_title_config)
						{ui()({layout = {direction = .LEFT_TO_RIGHT}})
							text("{ x: ", info_text_config)
							align_x := "LEFT"
							if (layout_config.child_alignment.x == .CENTER) {
								align_x = "CENTER"
							} else if (layout_config.child_alignment.x == .RIGHT) {
								align_x = "RIGHT"
							}
							text(align_x, info_text_config)
							text(", y: ", info_text_config)
							align_y := "TOP"
							if (layout_config.child_alignment.y == .CENTER) {
								align_y = "CENTER"
							} else if (layout_config.child_alignment.y == .BOTTOM) {
								align_y = "BOTTOM"
							}
							text(align_y, info_text_config)
							text(" }", info_text_config)
						}
					}
				}
				if is_text {
					{ui()(
						{
							layout = {
								padding = attribute_config_padding,
								child_gap = 8,
								direction = .TOP_TO_BOTTOM,
							},
						},
						)
						// font size
						text("Font Size", info_title_config)
						text(int_to_string(int(text_config.config.font_size)), info_text_config)
						// font_id
						text("Font ID", info_title_config)
						text(int_to_string(int(text_config.config.font_id)), info_text_config)
						// line_height
						text("Line Height", info_title_config)
						text(
							text_config.config.line_height == 0 ? "auto" : int_to_string(int(text_config.config.line_height)),
							info_text_config,
						)
						// spacing
						text("Letter Spacing", info_title_config)
						text(int_to_string(int(text_config.config.spacing)), info_text_config)
						// wrap_mode
						text("Wrap Mode", info_title_config)
						wrap_mode := "WORDS"
						if (text_config.config.wrap_mode == .WRAP_NONE) {
							wrap_mode = "NONE"
						} else if (text_config.config.wrap_mode == .WRAP_NEWLINES) {
							wrap_mode = "NEWLINES"
						}
						text(wrap_mode, text_config.config)
						// alignment
						text("Text Alignment", info_title_config)
						text_alignment := "LEFT"
						if (text_config.config.alignment == .CENTER) {
							text_alignment = "CENTER"
						} else if (text_config.config.alignment == .RIGHT) {
							text_alignment = "RIGHT"
						}
						text(text_alignment, info_text_config)
						// text_color
						text("Text Color", info_title_config)
						render_debug_view_color(text_config.config.text_color, info_text_config)
					}
				}
				if is_layout && config.aspect_ratio > 0 {
					{ui(id("claydo_debug_vie_element_info_aspect_ratio_body"))(
						{
							layout = {
								padding = attribute_config_padding,
								child_gap = 8,
								direction = .TOP_TO_BOTTOM,
							},
						},
						)
						text("Aspect Ratio", info_title_config)
						// Aspect Ratio
						{ui(id("claydo_debug_view_element_info_aspect_ratio"))({})
							text(int_to_string(int(config.aspect_ratio)), info_text_config)
							text(".", info_text_config)
							frac := f32(config.aspect_ratio) - f32(int(config.aspect_ratio))
							frac *= 100
							if int(frac) < 10 {
								text("0", info_text_config)
							}
							text(int_to_string(int(frac)), info_text_config)
						}
					}
				}
				if is_layout && config.image != nil {
					aspect_config :=
						config.aspect_ratio > 0 ? config.aspect_ratio : Aspect_Ratio(1)
					{ui(id("claydo_debug_view_element_info_image_body"))(
						{
							layout = {
								padding = attribute_config_padding,
								child_gap = 8,
								direction = .TOP_TO_BOTTOM,
							},
						},
						)
						// Image Preview
						text("Preview", info_title_config)
						{ui()(
							{
								layout = {
									sizing = {
										width = sizing_grow(64, 128),
										height = sizing_grow(64, 128),
									},
								},
								aspect_ratio = aspect_config,
								image = config.image,
							},
							)}
					}
				}
				if is_layout && config.floating.attach_to != .NONE {
					{ui()(
						{
							layout = {
								padding = attribute_config_padding,
								child_gap = 8,
								direction = .TOP_TO_BOTTOM,
							},
						},
						)
						// offset
						text("Offset", info_title_config)
						{ui()({layout = {direction = .LEFT_TO_RIGHT}})
							text("{ x: ", info_text_config)
							text(int_to_string(int(config.floating.offset.x)), info_text_config)
							text(", y: ", info_text_config)
							text(int_to_string(int(config.floating.offset.y)), info_text_config)
							text(" }", info_text_config)
						}
						// expand
						text("Expand", info_title_config)
						{ui()({layout = {direction = .LEFT_TO_RIGHT}})
							text("{ width: ", info_text_config)
							text(int_to_string(int(config.floating.expand.x)), info_text_config)
							text(", height: ", info_text_config)
							text(int_to_string(int(config.floating.expand.y)), info_text_config)
							text(" }", info_text_config)
						}
						// z_idx
						text("z-index", info_title_config)
						text(int_to_string(int(config.floating.z_idx)), info_text_config)
						// parent_id
						text("Parent", info_title_config)
						hash_item := get_hash_map_item(config.floating.parent_id)
						text(hash_item.element_id.string_id, info_text_config)
						// attach_points
						text("Attach Points", info_title_config)
						{ui()({layout = {direction = .LEFT_TO_RIGHT}})
							text("{ element: ", info_text_config)
							attach_point_element := "LEFT_TOP"
							if (config.floating.attach_points.element == .LEFT_CENTER) {
								attach_point_element = "LEFT_CENTER"
							} else if (config.floating.attach_points.element == .LEFT_BOTTOM) {
								attach_point_element = "LEFT_BOTTOM"
							} else if (config.floating.attach_points.element == .CENTER_TOP) {
								attach_point_element = "CENTER_TOP"
							} else if (config.floating.attach_points.element == .CENTER_CENTER) {
								attach_point_element = "CENTER_CENTER"
							} else if (config.floating.attach_points.element == .CENTER_BOTTOM) {
								attach_point_element = "CENTER_BOTTOM"
							} else if (config.floating.attach_points.element == .RIGHT_TOP) {
								attach_point_element = "RIGHT_TOP"
							} else if (config.floating.attach_points.element == .RIGHT_CENTER) {
								attach_point_element = "RIGHT_CENTER"
							} else if (config.floating.attach_points.element == .RIGHT_BOTTOM) {
								attach_point_element = "RIGHT_BOTTOM"
							}
							text(attach_point_element, info_text_config)
							attach_point_parent := "LEFT_TOP"
							if (config.floating.attach_points.parent == .LEFT_CENTER) {
								attach_point_parent = "LEFT_CENTER"
							} else if (config.floating.attach_points.parent == .LEFT_BOTTOM) {
								attach_point_parent = "LEFT_BOTTOM"
							} else if (config.floating.attach_points.parent == .CENTER_TOP) {
								attach_point_parent = "CENTER_TOP"
							} else if (config.floating.attach_points.parent == .CENTER_CENTER) {
								attach_point_parent = "CENTER_CENTER"
							} else if (config.floating.attach_points.parent == .CENTER_BOTTOM) {
								attach_point_parent = "CENTER_BOTTOM"
							} else if (config.floating.attach_points.parent == .RIGHT_TOP) {
								attach_point_parent = "RIGHT_TOP"
							} else if (config.floating.attach_points.parent == .RIGHT_CENTER) {
								attach_point_parent = "RIGHT_CENTER"
							} else if (config.floating.attach_points.parent == .RIGHT_BOTTOM) {
								attach_point_parent = "RIGHT_BOTTOM"
							}
							text(", parent: ", info_text_config)
							text(attach_point_parent, info_text_config)
							text(" }", info_text_config)
						}
						// cursor_capture_mode
						text("Cursor Capture Mode", info_title_config)
						cursor_capture_mode := "NONE"
						if (config.floating.cursor_capture_mode == .PASSTHROUGH) {
							cursor_capture_mode = "PASSTHROUGH"
						}
						text(cursor_capture_mode, info_text_config)
						// .attach_to
						text("Attach To", info_title_config)
						attach_to := "NONE"
						if (config.floating.attach_to == .PARENT) {
							attach_to = "PARENT"
						} else if (config.floating.attach_to == .ELEMENT_WITH_ID) {
							attach_to = "ELEMENT_WITH_ID"
						} else if (config.floating.attach_to == .ROOT) {
							attach_to = "ROOT"
						}
						text(attach_to, info_text_config)
						// clip_to
						text("Clip To", info_title_config)
						clip_to := "ATTACHED_PARENT"
						if (config.floating.clip_to == .NONE) {
							clip_to = "NONE"
						}
						text(clip_to, info_text_config)
					}
				}
				if is_layout && (config.clip.horizontal || config.clip.vertical) {
					{ui()(
						{
							layout = {
								padding = attribute_config_padding,
								child_gap = 8,
								direction = .TOP_TO_BOTTOM,
							},
						},
						)
						// vertical
						text("Vertical", info_title_config)
						text(config.clip.vertical ? "true" : "false", info_text_config)
						// horizontal
						text("Horizontal", info_title_config)
						text(config.clip.horizontal ? "true" : "false", info_text_config)
					}
				}
				if is_layout && border_has_any_width(&config.border) {
					{ui(id("claydo_debug_view_element_info_border_body"))(
						{
							layout = {
								padding = attribute_config_padding,
								child_gap = 8,
								direction = .TOP_TO_BOTTOM,
							},
						},
						)
						text("Border Widths", info_title_config)
						{ui()({layout = {direction = .LEFT_TO_RIGHT}})
							text("{ left: ", info_text_config)
							text(int_to_string(int(config.border.width.left)), info_text_config)
							text(", right: ", info_text_config)
							text(int_to_string(int(config.border.width.right)), info_text_config)
							text(", top: ", info_text_config)
							text(int_to_string(int(config.border.width.top)), info_text_config)
							text(", bottom: ", info_text_config)
							text(int_to_string(int(config.border.width.bottom)), info_text_config)
							text(" }", info_text_config)
						}
						// color
						text("Border Color", info_title_config)
						render_debug_view_color(config.border.color, info_text_config)
					}
				}
				if is_layout {
					{ui()(
						{
							layout = {
								padding = attribute_config_padding,
								child_gap = 8,
								direction = .TOP_TO_BOTTOM,
							},
						},
						)
						text("Background Color", info_title_config)
						render_debug_view_color(config.border.color, info_text_config)
						text("Corner Radius", info_title_config)
						render_debug_view_corner_radius(config.corner_radius, info_text_config)
					}
				}
			}
		} else {
			{ui(id("claydo_debug_view_warnings_scroll_pane"))(
				{
					layout = {
						sizing = {sizing_grow(0), sizing_fixed(300)},
						child_gap = 6,
						direction = .TOP_TO_BOTTOM,
					},
					color = DEBUG_VIEW_COLOR_2,
					clip = {
						horizontal = true,
						vertical = true,
						child_offset = get_scroll_offset(),
					},
				},
				)
				warning_config := Text_Element_Config {
					text_color = DEBUG_VIEW_COLOR_4,
					font_size  = 16,
					wrap_mode  = .WRAP_NONE,
				}
				{ui(id("claydo_debug_view_warning_item_header"))(
					{
						layout = {
							sizing = {height = sizing_fixed(DEBUG_VIEW_ROW_HEIGHT)},
							padding = {DEBUG_VIEW_OUTER_PADDING, DEBUG_VIEW_OUTER_PADDING, 0, 0},
							child_gap = 8,
							child_alignment = {y = .CENTER},
						},
					},
					)
					text("Warnings", warning_config)
				}
				{ui(id("clay_debug_view_warnings_top_border"))(
					{
						layout = {sizing = {width = sizing_grow(0), height = sizing_fixed(1)}},
						color = Color({200, 200, 200, 255} / 255),
					},
					)}
				previous_warnings_length := s.warnings.len
				for warning, i in array_iter(s.warnings) {
					{ui(idi("claydo_debug_view_warning_item", u32(i)))(
						{
							layout = {
								sizing = {height = sizing_fixed(DEBUG_VIEW_ROW_HEIGHT)},
								padding = {
									DEBUG_VIEW_OUTER_PADDING,
									DEBUG_VIEW_OUTER_PADDING,
									0,
									0,
								},
								child_gap = 8,
								child_alignment = {y = .CENTER},
							},
						},
						)
						text(warning.base_message, warning_config)
						if (len(warning.dynamic_message) > 0) {
							text(warning.dynamic_message, warning_config)
						}
					}
				}
			}
		}
	}
}

// NOTE - PUBLIC API

min_memory_size :: proc() -> uint {
	fake_context := State {
		max_element_count                 = s != nil ? s.max_element_count : DEFAULT_MAX_ELEMENT_COUNT,
		max_measure_text_cache_word_count = s != nil ? s.max_measure_text_cache_word_count : DEFAULT_MAX_MEASURE_TEXT_WORD_CACHE_COUNT,
		arena_internal                    = virtual.Arena{},
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

create_arena_with_capacity :: proc(cap: uint) -> Arena {
	arena: Arena
	err := virtual.arena_init_static(&arena, reserved = cap)
	if err != nil {
		if s.error_handler.err_proc != nil {
			s.error_handler.err_proc(
				Error_Data {
					type = .ARENA_CAPACITY_EXCEEDED,
					text = "Claydo attempted to allocate memory in its arena, but ran out of capacity. Try increasing the capacity of the arena passed to initialize()",
					user_ptr = s.error_handler.user_ptr,
				},
			)
		}
		return {}
	}
	return arena
}

set_measure_text_procedure :: proc(
	procedure: proc(_: string, _: Text_Element_Config, _: rawptr) -> [2]f32,
	user_ptr: rawptr,
) {
	s.measure_text = procedure
	s.measure_text_user_ptr = user_ptr
}

set_query_scroll_offset_procedure :: proc(
	procedure: proc(element_id: u32, user_ptr: rawptr) -> [2]f32,
	user_ptr: rawptr,
) {
	s.query_scroll_offset = procedure
	s.query_scroll_offset_user_ptr = user_ptr
}

set_layout_dimensions :: proc(dimensions: [2]f32) {
	s.layout_dimensions = dimensions
}

set_cursor_state :: proc(position: [2]f32, is_cursor_down: bool) {
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
			if s.tree_node_visited.items[dfs_buffer.len - 1] {
				dfs_buffer.len -= 1
				continue
			}
			s.tree_node_visited.items[dfs_buffer.len - 1] = true
			current_element := array_get_ptr(
				&s.layout_elements,
				array_get(dfs_buffer, dfs_buffer.len - 1),
			)
			map_item := get_hash_map_item(current_element.id)
			clip_element_id := array_get(
				s.layout_element_clip_element_ids,
				intrinsics.ptr_sub(current_element, &s.layout_elements.items[0]),
			)
			clip_item := get_hash_map_item(u32(clip_element_id))
			if map_item != nil {
				element_box := map_item.bounding_box
				element_box.x -= root.cursor_offset.x
				element_box.y -= root.cursor_offset.y
				if point_is_inside_rect(position, element_box) &&
					   (clip_element_id == 0 ||
							   point_is_inside_rect(position, clip_item.bounding_box)) ||
				   s.external_scroll_handling_enabled {
					if map_item.on_hover_function != nil {
						map_item.on_hover_function(
							map_item.element_id,
							s.cursor_info,
							map_item.hover_function_user_ptr,
						)
					}
					array_push(&s.cursor_over_ids, map_item.element_id)
					found = true
				}
				if _, is_text := current_element.config.(Text_Declaration); is_text {
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
		config, is_layout := root_element.config.(Element_Declaration)
		if is_layout &&
		   config.floating.attach_to != .NONE &&
		   config.floating.cursor_capture_mode == .CAPTURE {
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

default_error_handler_proc :: proc(data: Error_Data) {}

initialize :: proc(
	arena: Arena,
	layout_dimensions: [2]f32,
	error_handler: Error_Handler,
) -> ^State {
	old_s := s
	s = new(State)
	s^ = {
		max_element_count                 = old_s != nil ? old_s.max_element_count : DEFAULT_MAX_ELEMENT_COUNT,
		max_measure_text_cache_word_count = old_s != nil ? old_s.max_measure_text_cache_word_count : DEFAULT_MAX_MEASURE_TEXT_WORD_CACHE_COUNT,
		error_handler                     = error_handler.err_proc != nil ? error_handler : Error_Handler{default_error_handler_proc, nil},
		layout_dimensions                 = layout_dimensions,
		arena_internal                    = arena,
	}
	s.arena = virtual.arena_allocator(&s.arena_internal)
	// TODO what happens when we don't free the old data
	initialize_persistent_memory(s)
	s.arena_reset_point = s.arena_internal.total_used
	initialize_ephemeral_memory(s)
	for i in 0 ..< s.layout_elements_hash_map.cap {
		s.layout_elements_hash_map.items[i] = -1
	}
	for i in 0 ..< s.measure_text_hash_map.cap {
		s.measure_text_hash_map.items[i] = 0
	}
	s.measure_text_hash_map_internal.len = 1 // reserve 0 to mean "no next element"
	s.layout_dimensions = layout_dimensions
	return s
}

get_scroll_offset :: proc() -> [2]f32 {
	if s.boolean_warnings.max_elements_exceeded {
		return {}
	}
	open_layout_element := get_open_layout_element()
	if open_layout_element.id == 0 {
		generate_id_for_anonymous_element(open_layout_element)
	}
	for &mapping in array_iter(s.scroll_container_datas) {
		if mapping.layout_element == open_layout_element {
			return mapping.scroll_position
		}
	}
	return {}
}

update_scroll_containers :: proc(
	enable_drag_scrolling: bool,
	scroll_delta: [2]f32,
	delta_time: f32,
) {
	is_cursor_active :=
		enable_drag_scrolling &&
		(s.cursor_info.state == .PRESSED_THIS_FRAME || s.cursor_info.state == .PRESSED)
	highest_priority_element_idx := -1
	highest_priority_scroll_data: ^Scroll_Container_Data_Internal
	for &scroll_data, idx in array_iter(s.scroll_container_datas) {
		if !scroll_data.open_this_frame {
			array_swapback(&s.scroll_container_datas, idx)
			continue
		}
		scroll_data.open_this_frame = false
		hash_map_item := get_hash_map_item(scroll_data.element_id)
		// element isn't rendered this frame but scroll offset has been retained
		if hash_map_item == nil {
			array_swapback(&s.scroll_container_datas, idx)
			continue
		}

		// touch / click is released
		if !is_cursor_active && scroll_data.cursor_scroll_active {
			x_diff := scroll_data.scroll_position.x - scroll_data.scroll_origin.x
			if x_diff < -10 || x_diff > 10 {
				scroll_data.scroll_momentum.x =
					(scroll_data.scroll_position.x - scroll_data.scroll_origin.x) /
					(scroll_data.momentum_time * 25)
			}
			y_diff := scroll_data.scroll_position.y - scroll_data.scroll_origin.y
			if y_diff < -10 || y_diff > 10 {
				scroll_data.scroll_momentum.y =
					(scroll_data.scroll_position.y - scroll_data.scroll_origin.y) /
					(scroll_data.momentum_time * 25)
			}
			scroll_data.cursor_scroll_active = false
			scroll_data.cursor_origin = {0, 0}
			scroll_data.scroll_origin = {0, 0}
			scroll_data.momentum_time = 0
		}

		scroll_occurred := scroll_delta.x != 0 || scroll_delta.y != 0
		scroll_data.scroll_position.x += scroll_data.scroll_momentum.x
		scroll_data.scroll_momentum.x *= 0.95
		if (scroll_data.scroll_momentum.x > -0.1 && scroll_data.scroll_momentum.x < 0.1) ||
		   scroll_occurred {
			scroll_data.scroll_momentum.x = 0
		}
		scroll_data.scroll_position.x = min(
			max(
				scroll_data.scroll_position.x,
				-max(scroll_data.content_size.x - scroll_data.layout_element.dimensions.x, 0),
			),
			0,
		)

		scroll_data.scroll_position.y += scroll_data.scroll_momentum.y
		scroll_data.scroll_momentum.y *= 0.95
		if (scroll_data.scroll_momentum.y > -0.1 && scroll_data.scroll_momentum.y < 0.1) ||
		   scroll_occurred {
			scroll_data.scroll_momentum.y = 0
		}
		scroll_data.scroll_position.y = min(
			max(
				scroll_data.scroll_position.y,
				-max(scroll_data.content_size.y - scroll_data.layout_element.dimensions.y, 0),
			),
			0,
		)
		for j in 0 ..< s.cursor_over_ids.len {
			if scroll_data.layout_element.id == array_get(s.cursor_over_ids, j).id {
				highest_priority_element_idx = j
				highest_priority_scroll_data = &scroll_data
			}
		}
	}
	if highest_priority_element_idx > -1 && highest_priority_scroll_data != nil {
		scroll_element := highest_priority_scroll_data.layout_element
		clip_config := scroll_element.config.(Element_Declaration).clip
		can_scroll_vertically :=
			clip_config.vertical &&
			highest_priority_scroll_data.content_size.y > scroll_element.dimensions.y
		can_scroll_horizontally :=
			clip_config.horizontal &&
			highest_priority_scroll_data.content_size.x > scroll_element.dimensions.x
		// handle wheel scroll
		if can_scroll_vertically {
			highest_priority_scroll_data.scroll_position.y =
				highest_priority_scroll_data.scroll_position.y + scroll_delta.y * 10
		}
		if can_scroll_horizontally {
			highest_priority_scroll_data.scroll_position.x =
				highest_priority_scroll_data.scroll_position.x + scroll_delta.x * 10
		}
		// handle click / touch scroll
		if is_cursor_active {
			highest_priority_scroll_data.scroll_momentum = {}
			if !highest_priority_scroll_data.cursor_scroll_active {
				highest_priority_scroll_data.cursor_origin = s.cursor_info.position
				highest_priority_scroll_data.scroll_origin =
					highest_priority_scroll_data.scroll_position
				highest_priority_scroll_data.cursor_scroll_active = true
			} else {
				scroll_delta_x: f32 = 0
				scroll_delta_y: f32 = 0
				if can_scroll_horizontally {
					old_x_scroll_position := highest_priority_scroll_data.scroll_position.x
					highest_priority_scroll_data.scroll_position.x =
						highest_priority_scroll_data.scroll_origin.x +
						s.cursor_info.position.x -
						highest_priority_scroll_data.cursor_origin.x
					highest_priority_scroll_data.scroll_position.x = max(
						min(highest_priority_scroll_data.scroll_position.x, 0),
						-highest_priority_scroll_data.content_size.x +
						highest_priority_scroll_data.bounding_box.x,
					)
					scroll_delta_x =
						highest_priority_scroll_data.scroll_position.x - old_x_scroll_position
				}
				if can_scroll_vertically {
					old_y_scroll_position := highest_priority_scroll_data.scroll_position.y
					highest_priority_scroll_data.scroll_position.y =
						highest_priority_scroll_data.scroll_origin.y +
						s.cursor_info.position.y -
						highest_priority_scroll_data.cursor_origin.y
					highest_priority_scroll_data.scroll_position.y = max(
						min(highest_priority_scroll_data.scroll_position.y, 0),
						-highest_priority_scroll_data.content_size.y +
						highest_priority_scroll_data.bounding_box.y,
					)
					scroll_delta_y =
						highest_priority_scroll_data.scroll_position.x - old_y_scroll_position
				}
				if scroll_delta_x > -0.1 &&
				   scroll_delta_x < 0.1 &&
				   scroll_delta_y > -0.1 &&
				   scroll_delta_y < 0.1 &&
				   highest_priority_scroll_data.momentum_time > 0.15 {
					highest_priority_scroll_data.momentum_time = 0
					highest_priority_scroll_data.cursor_origin = s.cursor_info.position
					highest_priority_scroll_data.scroll_origin =
						highest_priority_scroll_data.scroll_position
				} else {
					highest_priority_scroll_data.momentum_time += delta_time
				}
			}
		}
		// clamp any changes to scroll position to the maximum size of the contents
		if can_scroll_vertically {
			highest_priority_scroll_data.scroll_position.y = max(
				min(highest_priority_scroll_data.scroll_position.y, 0),
				-highest_priority_scroll_data.content_size.y + scroll_element.dimensions.y,
			)
		}
		if can_scroll_horizontally {
			highest_priority_scroll_data.scroll_position.x = max(
				min(highest_priority_scroll_data.scroll_position.x, 0),
				-highest_priority_scroll_data.content_size.x + scroll_element.dimensions.x,
			)
		}
	}
}

begin_layout :: proc() {
	initialize_ephemeral_memory(s)
	s.generation += 1
	s.dynamic_element_idx = 0
	root_dimensions: [2]f32 = {s.layout_dimensions.x, s.layout_dimensions.y}
	if s.debug_mode_enabled {
		root_dimensions.x -= DEBUG_VIEW_WIDTH
	}
	s.boolean_warnings = {}
	open_element_with_id(id("claydo_root_container"))
	configure_open_element(
		Element_Declaration {
			layout = {
				sizing = {
					width = Sizing_Axis {
						.FIXED,
						Sizing_Min_Max{root_dimensions.x, root_dimensions.x},
					},
					height = Sizing_Axis {
						.FIXED,
						Sizing_Min_Max{root_dimensions.y, root_dimensions.y},
					},
				},
			},
		},
	)
	array_push(&s.open_layout_element_stack, 0)
	array_push(&s.layout_element_tree_roots, Layout_Element_Tree_Root{layout_element_idx = 0})
}

end_layout :: proc(delta_time: f32) -> []Render_Command {
	close_element() // close the root element
	element_exceeded_before_debug_view := s.boolean_warnings.max_elements_exceeded
	if s.debug_mode_enabled && !element_exceeded_before_debug_view {
		s.warnings_enabled = false
		render_debug_view()
		s.warnings_enabled = true
	}
	if s.boolean_warnings.max_elements_exceeded {
		message: string
		if !element_exceeded_before_debug_view {
			message = "Claydo Error: Layout elements exceeded max_element_count after adding the debug-view to the layout."
		} else {
			message = "Claydo Error: Layout elements exceeded max_element_count"
		}
		push_render_command(
			Render_Command {
				// HACK what is this -59*4 thing???ß
				bounding_box = {
					s.layout_dimensions.x / 2.0 - 59 * 4,
					s.layout_dimensions.y / 2.0,
					0,
					0,
				},
				render_data = Text_Render_Data {
					text = message,
					color = Color({255, 0, 0, 255} / 255),
					font_size = 16,
				},
				type = .TEXT,
			},
		)
	} else {
		transition_out_waiting_count := 0
		for &data in array_iter(s.transition_datas) {
			all_config, is_layout := data.element_this_frame.config.(Element_Declaration)
			if is_layout && all_config.transition.on_begin_exit != nil {
				config := all_config.transition
				hash_map_item := get_hash_map_item(data.element_id)
				if hash_map_item.generation == s.generation {
					if data.state != .EXITING {
						(&data.element_this_frame.config.(Element_Declaration)).floating.attach_to = .INLINE
						(&data.element_this_frame.config.(Element_Declaration)).layout.sizing.width =
							sizing_fixed(data.element_this_frame.dimensions.x)
						(&data.element_this_frame.config.(Element_Declaration)).layout.sizing.height =
							sizing_fixed(data.element_this_frame.dimensions.y)
						data.state = .EXITING
						data.elapsed_time = 0
						data.target_state = config.on_begin_exit(data.target_state)
					}
				}
				bfs_buffer := s.open_layout_element_stack
				bfs_buffer.len = 0
				array_push(
					&bfs_buffer,
					intrinsics.ptr_sub(data.element_this_frame, &s.layout_elements.items[0]),
				)
				buffer_idx := 0
				for buffer_idx < bfs_buffer.len {
					layout_element := s.layout_elements.items[array_get(bfs_buffer, buffer_idx)]
					buffer_idx += 1
					for child in array_iter(layout_element.children) {
						array_push(&bfs_buffer, child)
					}
					transition_out_waiting_count += 1
				}
			}
		}

		root_idx := s.layout_elements.len
		root_child_idx := s.layout_element_children.len

		exiting_elements_count := clone_transition_elements(root_idx, root_child_idx, true)

		s.exiting_elements_length = exiting_elements_count.elements_added
		s.exiting_elements_children_length = exiting_elements_count.element_children_added

		s.layout_elements.len += s.exiting_elements_length
		s.layout_element_children.len += s.exiting_elements_children_length
		s.layout_element_clip_element_ids.len += s.exiting_elements_length

		calculate_final_layout(delta_time)

		// TODO why does original implementation use - transition_out_waiting_count
		root_idx = s.layout_elements.len // - transition_out_waiting_count
		root_child_idx = s.layout_element_children.len // - transition_out_waiting_count

		clone_transition_elements(root_idx, root_child_idx, false)
	}
	if s.open_layout_element_stack.len > 1 {
		s.error_handler.err_proc(
			Error_Data {
				type = .UNBALANCED_OPEN_CLOSE,
				text = "There were still open layout elements when end_layout was called. This results from an unequal number of calls to open_element and close_element.",
				user_ptr = s.error_handler.user_ptr,
			},
		)
	}
	return s.render_commands.items[:s.render_commands.len]
}

get_element_id :: proc(id_string: string) -> Element_ID {
	return hash_string(id_string, 0)
}

get_element_id_with_idx :: proc(id_string: string, idx: u32) -> Element_ID {
	return hash_string_with_offset(id_string, idx, 0)
}

hovered :: proc() -> bool {
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

clicked :: proc() -> bool {
	return hovered() && s.cursor_info.state == .PRESSED_THIS_FRAME
}

on_hover :: proc(procedure: proc(_: Element_ID, _: Cursor_Data, _: rawptr), user_ptr: rawptr) {
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

cursor_over :: proc(element_id: Element_ID) -> bool {
	for id in array_iter(s.cursor_over_ids) {
		if id.id == element_id.id {
			return true
		}
	}
	return false
}

get_scroll_container_data :: proc(id: Element_ID) -> Scroll_Container_Data {
	for &scroll_container_data in array_iter(s.scroll_container_datas) {
		if scroll_container_data.element_id == id.id {
			if scroll_container_data.layout_element == nil {
				return {}
			}
			return Scroll_Container_Data {
				scroll_position = &scroll_container_data.scroll_position,
				dimensions = {
					scroll_container_data.bounding_box.width,
					scroll_container_data.bounding_box.height,
				},
				content_dimensions = scroll_container_data.content_size,
				config = scroll_container_data.layout_element.config.(Element_Declaration).clip,
				found = true,
			}
		}
	}
	return {}
}

get_element_data :: proc(id: Element_ID) -> Element_Data {
	item := get_hash_map_item(id.id)
	if item == &DEFAULT_LAYOUT_ELEMENT_HASH_MAP_ITEM {
		return {}
	}
	return Element_Data{bounding_box = item.bounding_box, found = true}
}

set_debug_mode_enabled :: proc(enabled: bool) {
	s.debug_mode_enabled = enabled
}

is_debug_mode_enabled :: proc() -> bool {
	return s.debug_mode_enabled
}

set_culling_enabled :: proc(enabled: bool) {
	s.disable_culling = !enabled
}

set_external_scroll_handling_enabled :: proc(enabled: bool) {
	s.external_scroll_handling_enabled = enabled
}

get_max_element_count :: proc() -> int {
	return s.max_element_count
}

set_max_element_count :: proc(max_count: int) -> bool {
	if s != nil {
		s.max_element_count = max_count
		return true
	} else {
		return false
	}
}

get_max_measure_text_cache_word_count :: proc() -> int {
	return s.max_measure_text_cache_word_count
}

set_max_measure_text_cache_word_count :: proc(count: int) -> bool {
	if s != nil {
		s.max_measure_text_cache_word_count = count
		return true
	} else {
		return false
	}
}

reset_measure_text_cache :: proc() {
	s.measure_text_hash_map_internal_free_list.len = 0
	s.measure_text_hash_map.len = 0
	s.measured_words.len = 0
	s.measured_words_free_list.len = 0

	for i in 0 ..< s.measure_text_hash_map.cap {
		s.measure_text_hash_map.items[i] = 0
	}
	s.measure_text_hash_map_internal.len = 1
}

@(deferred_none = close_element)
ui_with_id :: proc(id: Element_ID) -> proc(config: Element_Declaration) -> bool {
	open_element_with_id(id)
	return configure_open_element
}

@(deferred_none = close_element)
ui_auto_id :: proc() -> proc(config: Element_Declaration) -> bool {
	open_element()
	return configure_open_element
}

ui :: proc {
	ui_with_id,
	ui_auto_id,
}

text :: proc(text: string, config: Text_Element_Config) {
	open_text_element(text, config)
}

padding_all :: proc(all: f32) -> Padding {
	return {left = all, right = all, top = all, bottom = all}
}

border_outside :: proc(width: f32) -> Border_Width {
	return {width, width, width, width, 0}
}

border_all :: proc(width: f32) -> Border_Width {
	return {width, width, width, width, width}
}

corner_radius_all :: proc(radius: f32) -> Corner_Radius {
	return {radius, radius, radius, radius}
}

sizing_fit :: proc(min: f32 = 0, max: f32 = MAX_FLOAT) -> Sizing_Axis {
	return {.FIT, Sizing_Min_Max{min, max}}
}

sizing_grow :: proc(min: f32 = 0, max: f32 = MAX_FLOAT) -> Sizing_Axis {
	return {.GROW, Sizing_Min_Max{min, max}}
}

sizing_fixed :: proc(size: f32 = 0) -> Sizing_Axis {
	return {.FIXED, Sizing_Min_Max{size, size}}
}

sizing_percent :: proc(percent: f32 = 0) -> Sizing_Axis {
	return {.PERCENT, Percent(percent)}
}

id :: proc(label: string, index: u32 = 0) -> Element_ID {
	return hash_string(label, index)
}

id_local :: proc(label: string, index: u32 = 0) -> Element_ID {
	return hash_string_with_offset(label, index, get_parent_element_id())
}
