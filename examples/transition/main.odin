package main
import "../../claydo"
import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:strconv"
import rr "raylib_renderer"
import rl "vendor:raylib"

FONT_ID_BODY_24: u16 = 0
FONT_ID_BODY_16: u16 = 1
COLOR_ORANGE := claydo.Color{225, 138, 50, 255} / 255
COLOR_BLUE := claydo.Color{111, 173, 162, 255} / 255

profilePicture: rl.Texture2D
profileText := "Profile Page one two three four five six seven eight nine ten eleven twelve thirteen fourteen fifteen"
headerTextConfig := claydo.Text_Element_Config {
	font_id    = 1,
	spacing    = 5,
	font_size  = 16,
	text_color = {0, 0, 0, 255},
}

frameArena: claydo.Arena

HandleHeaderButtonInteraction :: proc(
	elementId: claydo.Element_ID,
	cursor_data: claydo.Cursor_Data,
	userData: rawptr,
) {
	if (cursor_data.state == .PRESSED_THIS_FRAME) {
		// Do some click handling
	}
}

HeaderButtonStyle :: proc(hovered: bool) -> claydo.Element_Declaration {
	return {layout = {padding = {16, 16, 8, 8}}, color = hovered ? COLOR_ORANGE : COLOR_BLUE}
}

// Examples of re-usable "Components"
RenderHeaderButton :: proc(text: string) {
	{claydo.ui()(HeaderButtonStyle(claydo.hovered()))
		claydo.text(text, headerTextConfig)
	}
}

dropdownTextItemLayout := claydo.Layout_Config {
	padding = {8, 8, 4, 4},
}
dropdownTextElementConfig := claydo.Text_Element_Config {
	font_size  = 24,
	text_color = {1, 1, 1, 1},
}

RenderDropdownTextItem :: proc(index: int) {
	{claydo.ui()({layout = dropdownTextItemLayout, color = ({180, 180, 180, 255} / 255)})
		claydo.text("I'm a text field in a scroll container.", dropdownTextElementConfig)
	}
}


SortableBox :: struct {
	id:       int,
	color:    claydo.Color,
	stringId: string,
}

maxCount := 30
cellCount := 30
charData: []u8
colors: [100]SortableBox

blueColor := false

GG := claydo.Sizing {
	{.GROW, claydo.Sizing_Min_Max{0, claydo.MAX_FLOAT}},
	{.GROW, claydo.Sizing_Min_Max{0, claydo.MAX_FLOAT}},
}

cWHITE := claydo.Color{255, 255, 255, 255} / 255

Test :: struct {
	value: int,
}

EaseOut :: proc(arguments: claydo.Transition_Callback_Arguments) -> bool {
	ratio := arguments.elapsed_time / arguments.duration
	if arguments.elapsed_time < arguments.duration {
		lerpAmount := 1 - math.pow(1 - ratio, 3.0)
		allProperties := .ALL in arguments.properties
		if allProperties || .BOUNDING_BOX in arguments.properties {
			arguments.current.bounding_box = {
				x      = rl.Lerp(
					arguments.initial.bounding_box.x,
					arguments.target.bounding_box.x,
					lerpAmount,
				),
				y      = rl.Lerp(
					arguments.initial.bounding_box.y,
					arguments.target.bounding_box.y,
					lerpAmount,
				),
				width  = rl.Lerp(
					arguments.initial.bounding_box.width,
					arguments.target.bounding_box.width,
					lerpAmount,
				),
				height = rl.Lerp(
					arguments.initial.bounding_box.height,
					arguments.target.bounding_box.height,
					lerpAmount,
				),
			}
		} else {
			arguments.current.bounding_box = arguments.target.bounding_box
		}
		if (allProperties || .COLOR in arguments.properties) {
			arguments.current.color = {
				rl.Lerp(arguments.initial.color.r, arguments.target.color.r, lerpAmount),
				rl.Lerp(arguments.initial.color.g, arguments.target.color.g, lerpAmount),
				rl.Lerp(arguments.initial.color.b, arguments.target.color.b, lerpAmount),
				rl.Lerp(arguments.initial.color.a, arguments.target.color.a, lerpAmount),
			}
		} else {
			arguments.current.color = arguments.target.color
		}
		if allProperties || .OVERLAY_COLOR in arguments.properties {
			arguments.current.overlay_color = {
				rl.Lerp(
					arguments.initial.overlay_color.r,
					arguments.target.overlay_color.r,
					lerpAmount,
				),
				rl.Lerp(
					arguments.initial.overlay_color.g,
					arguments.target.overlay_color.g,
					lerpAmount,
				),
				rl.Lerp(
					arguments.initial.overlay_color.b,
					arguments.target.overlay_color.b,
					lerpAmount,
				),
				rl.Lerp(
					arguments.initial.overlay_color.a,
					arguments.target.overlay_color.a,
					lerpAmount,
				),
			}
		} else {
			arguments.current.overlay_color = arguments.target.overlay_color
		}
		return false
	} else {
		return true
	}
}


EnterExitSlideUp :: proc(initialState: claydo.Transition_Data) -> claydo.Transition_Data {
	targetState := initialState
	targetState.bounding_box.y += 20
	targetState.overlay_color = {1, 1, 1, 1}
	return targetState
}
// Swaps two elements in an array
swap :: proc(a: ^SortableBox, b: ^SortableBox) {
	temp := a^
	a^ = b^
	b^ = temp
}

shuffle :: proc(array: []SortableBox, n: int) {
	if n <= 1 {return}
	for i := n - 1; i > 0; i -= 1 {
		j := int(rand.int63()) % (i + 1)
		swap(&array[i], &array[j])
	}
}

add :: proc(array: []SortableBox, length: int, index: int, toAdd: SortableBox) {
	for i := length; i > index; i -= 1 {
		array[i] = array[i - 1]
	}
	array[index] = toAdd
}


HandleRandomiseButtonInteraction :: proc(
	elementId: claydo.Element_ID,
	cursorData: claydo.Cursor_Data,
	userData: rawptr,
) {
	if (cursorData.state == .PRESSED_THIS_FRAME) {
		shuffle(colors[:], cellCount)
	}
}

HandlePinkButtonInteraction :: proc(
	elementId: claydo.Element_ID,
	cursorData: claydo.Cursor_Data,
	userData: rawptr,
) {
	if (cursorData.state == .PRESSED_THIS_FRAME) {
		for i := 0; i < cellCount; i += 1 {
			index := colors[i].id
			fIndex := f32(index)
			colors[i] = {
				id       = index,
				color    = ({255 - fIndex, 255 - fIndex * 4, 255 - fIndex * 2, 255} / 255),
				stringId = colors[i].stringId,
			}
		}
	}
}

HandleNewButtonInteraction :: proc(
	elementId: claydo.Element_ID,
	cursorData: claydo.Cursor_Data,
	userData: rawptr,
) {
	if (cursorData.state == .PRESSED_THIS_FRAME) {
		randomIndex := int(rand.int63()) % (cellCount + 1)
		newId := maxCount
		fNewId := f32(newId)
		buf := make([]u8, 8) // probably leaks. whatever
		add(
			colors[:],
			maxCount,
			randomIndex,
			(SortableBox) {
				id = newId,
				color = ({255 - fNewId, 255 - fNewId * 4, 255 - fNewId * 2, 255} / 255),
				stringId = strconv.write_int(buf, i64(newId), 10),
			},
		)

		cellCount += 1
		maxCount += 1
	}
}


HandleBlueButtonInteraction :: proc(
	elementId: claydo.Element_ID,
	cursorData: claydo.Cursor_Data,
	userData: rawptr,
) {
	if cursorData.state == .PRESSED_THIS_FRAME {
		for i := 0; i < cellCount; i += 1 {
			index := colors[i].id
			fIndex := f32(index)
			colors[i] = {
				id       = index,
				color    = ({255 - fIndex * 4, 255 - fIndex * 2, 255 - fIndex, 255} / 255),
				stringId = colors[i].stringId,
			}
		}
	}
}

CreateLayout :: proc() -> []claydo.Render_Command {
	claydo.begin_layout()
	{claydo.ui(claydo.id("OuterContainer"))(
		{
			layout = {
				direction = .TOP_TO_BOTTOM,
				sizing = {width = claydo.sizing_grow(), height = claydo.sizing_grow()},
				padding = {16, 16, 16, 16},
				child_gap = 12,
			},
			color = cWHITE,
		},
		)
		{claydo.ui()(
			{
				layout = {
					sizing = {claydo.sizing_grow(), claydo.sizing_fixed(60)},
					padding = {left = 16},
					child_gap = 16,
					child_alignment = {y = .CENTER},
				},
				corner_radius = {12, 12, 12, 12},
				color = ({174, 143, 204, 255} / 255),
			},
			)
			{claydo.ui(claydo.id("ShuffleButton"))(
				{
					color = claydo.hovered() ? ({154, 123, 184, 255} / 255) : {},
					layout = {padding = {16, 16, 8, 8}},
					corner_radius = claydo.corner_radius_all(6),
					border = {color = cWHITE, width = claydo.border_outside(2)},
				},
				)
				claydo.on_hover(HandleRandomiseButtonInteraction, nil)
				claydo.text("Randomise", {font_size = 20, text_color = cWHITE})
			}
			{claydo.ui(claydo.id("bluebutton"))(
				{
					color = claydo.hovered() ? ({154, 123, 184, 255} / 255) : {},
					layout = {padding = {16, 16, 8, 8}},
					corner_radius = claydo.corner_radius_all(6),
					border = {color = cWHITE, width = claydo.border_outside(2)},
				},
				)
				claydo.on_hover(HandleBlueButtonInteraction, nil)
				claydo.text("Blue", {font_size = 20, text_color = cWHITE})
			}
			{claydo.ui(claydo.id("PinkButton"))(
				{
					color = claydo.hovered() ? ({154, 123, 184, 255} / 255) : {},
					layout = {padding = {16, 16, 8, 8}},
					corner_radius = claydo.corner_radius_all(6),
					border = {color = cWHITE, width = claydo.border_outside(2)},
				},
				)
				claydo.on_hover(HandlePinkButtonInteraction, nil)
				claydo.text("Pink", {font_size = 20, text_color = cWHITE})
			}
			{claydo.ui(claydo.id("AddButton"))(
				{
					color = claydo.hovered() ? ({154, 123, 184, 255} / 255) : {},
					layout = {padding = {16, 16, 8, 8}},
					corner_radius = claydo.corner_radius_all(6),
					border = {color = cWHITE, width = claydo.border_outside(2)},
				},
				)
				claydo.on_hover(HandleNewButtonInteraction, nil)
				claydo.text("Add Box", {font_size = 20, text_color = cWHITE})
			}
		}
		for i := 0; i < 5; i += 1 {
			{claydo.ui(claydo.idi("row", u32(i)))({layout = {child_gap = 12, sizing = GG}})
				for j := 0; j < 6; j += 1 {
					index := i * 6 + j
					if (index >= cellCount) {
						break
					}
					darker := claydo.Color {
						colors[index].color.r * 0.9,
						colors[index].color.g * 0.9,
						colors[index].color.b * 0.9,
						1,
					}
					{claydo.ui(claydo.idi("box", u32(colors[index].id)))(
						{
							layout = {sizing = GG, child_alignment = {.CENTER, .CENTER}},
							color = colors[index].color,
							overlay_color = claydo.hovered() ? ({80, 80, 80, 80} / 255) : {1, 1, 1, 0},
							corner_radius = {12, 12, 12, 12},
							border = {darker, claydo.border_outside(3)},
							transition = {
								handler = EaseOut,
								duration = 0.5,
								properties = {.COLOR, .OVERLAY_COLOR, .BOUNDING_BOX},
								on_begin_enter = EnterExitSlideUp,
								on_begin_exit = EnterExitSlideUp,
							},
						},
						)
						if claydo.clicked() {
							for i := index; i < cellCount; i += 1 {
								colors[i] = colors[i + 1]
							}
							cellCount = max(cellCount - 1, 0)
						}
						claydo.text(
							colors[index].stringId,
							{
								font_size = 32,
								text_color = colors[index].id > 29 ? ({255, 255, 255, 255} / 255) : ({154, 123, 184, 255} / 255),
							},
						)
					}
				}
			}
		}
	}
	return claydo.end_layout(rl.GetFrameTime())
}


ScrollbarData :: struct {
	clickOrigin:    [2]f32,
	positionOrigin: [2]f32,
	mouseDown:      bool,
}

scrollbarData: ScrollbarData = {}

debugEnabled := false

UpdateDrawFrame :: proc() {
	mouseWheelDelta := rl.GetMouseWheelMoveV()
	mouseWheelX := mouseWheelDelta.x
	mouseWheelY := mouseWheelDelta.y

	if (rl.IsKeyPressed(.D)) {
		debugEnabled = !debugEnabled
		claydo.set_debug_mode_enabled(debugEnabled)
	}
	//----------------------------------------------------------------------------------
	// Handle scroll containers
	mousePosition := rl.GetMousePosition()
	claydo.set_cursor_state(mousePosition, rl.IsMouseButtonDown(.LEFT) && !scrollbarData.mouseDown)
	claydo.set_layout_dimensions({f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight())})
	if (!rl.IsMouseButtonDown(.LEFT)) {
		scrollbarData.mouseDown = false
	}

	if (rl.IsMouseButtonDown(.LEFT) &&
		   !scrollbarData.mouseDown &&
		   claydo.cursor_over(claydo.hash_string("ScrollBar", 0))) {
		scrollContainerData := claydo.get_scroll_container_data(
			claydo.hash_string("MainContent", 0),
		)
		scrollbarData.clickOrigin = mousePosition
		scrollbarData.positionOrigin = scrollContainerData.scroll_position^
		scrollbarData.mouseDown = true
	} else if (scrollbarData.mouseDown) {
		scrollContainerData := claydo.get_scroll_container_data(
			claydo.hash_string("MainContent", 0),
		)
		if (scrollContainerData.content_dimensions.y > 0) {
			ratio: [2]f32 = {
				scrollContainerData.content_dimensions.x / scrollContainerData.dimensions.x,
				scrollContainerData.content_dimensions.x / scrollContainerData.dimensions.y,
			}
			if (scrollContainerData.config.vertical) {
				scrollContainerData.scroll_position.y =
					scrollbarData.positionOrigin.y +
					(scrollbarData.clickOrigin.y - mousePosition.y) * ratio.y
			}
			if (scrollContainerData.config.horizontal) {
				scrollContainerData.scroll_position.x =
					scrollbarData.positionOrigin.x +
					(scrollbarData.clickOrigin.x - mousePosition.x) * ratio.x
			}
		}
	}

	claydo.update_scroll_containers(true, {mouseWheelX, mouseWheelY}, rl.GetFrameTime())
	// Generate the auto layout for rendering
	currentTime := rl.GetTime()
	renderCommands := CreateLayout()
	// RENDERING ---------------------------------
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)
	rr.clay_raylib_render(renderCommands)
	rl.EndDrawing()
	//----------------------------------------------------------------------------------
}

reinitializeClay := false

HandleClayErrors :: proc(errorData: claydo.Error_Data) {
	fmt.println(errorData.text)
	if (errorData.type == .ELEMENTS_CAPACITY_EXCEEDED) {
		reinitializeClay = true
		claydo.set_max_element_count(claydo.get_max_element_count() * 2)
	} else if (errorData.type == .MEASUREMENT_CAPACITY_EXCEEDED) {
		reinitializeClay = true
		claydo.set_max_measure_text_cache_word_count(
			claydo.get_max_measure_text_cache_word_count() * 2,
		)
	}
}

main :: proc() {
	claydo.set_max_element_count(8192 * 2)
	totalMemorySize := claydo.min_memory_size()
	arena: claydo.Arena = claydo.create_arena_with_capacity(totalMemorySize)
	claydo.initialize(
		arena,
		{cast(f32)rl.GetScreenWidth(), cast(f32)rl.GetScreenHeight()},
		{err_proc = HandleClayErrors},
	)
	claydo.set_measure_text_procedure(rr.measure_text, nil)
	rr.raylib_initialize(
		1024,
		768,
		"Clay - Raylib Renderer Example",
		{.VSYNC_HINT, .WINDOW_RESIZABLE, .MSAA_4X_HINT},
	)
	profilePicture := rl.LoadTexture("resources/profile-picture.png")

	fonts: [2]rl.Font
	rr.load_font(FONT_ID_BODY_24, 48, "resources/Roboto-Regular.ttf")
	rr.load_font(FONT_ID_BODY_16, 32, "resources/Roboto-Regular.ttf")
	claydo.set_measure_text_procedure(rr.measure_text, &fonts)
	charData = make([]u8, 100 * 3)
	for i := 0; i < cellCount; i += 1 {
		fi := f32(i)
		buf := make([]u8, 3)
		r_int := rand.int_range(0, 999)
		str_id := strconv.write_int(buf[:], i64(i), 10)
		colors[i] = {
			id       = i,
			color    = ({255 - fi, 255 - fi * 4, 255 - fi * 2, 255} / 255),
			stringId = str_id,
		}
	}

	//--------------------------------------------------------------------------------------

	// Main game loop
	for !rl.WindowShouldClose() // Detect window close button or ESC key
	{
		if (reinitializeClay) {
			claydo.set_max_element_count(8192)
			totalMemorySize = claydo.min_memory_size()
			arena = claydo.create_arena_with_capacity(totalMemorySize)
			claydo.initialize(
				arena,
				{cast(f32)rl.GetScreenWidth(), cast(f32)rl.GetScreenHeight()},
				{err_proc = HandleClayErrors},
			)
			reinitializeClay = false
		}
		UpdateDrawFrame()
	}
	rl.CloseWindow()
}
