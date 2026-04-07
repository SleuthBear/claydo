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
headerTextConfig := claydo.TextElementConfig {
	fontId    = 1,
	spacing   = 5,
	fontSize  = 16,
	textColor = {0, 0, 0, 255},
}

frameArena: claydo.Arena

HandleHeaderButtonInteraction :: proc(
	elementId: claydo.ElementID,
	cursorData: claydo.CursorData,
	userData: rawptr,
) {
	if (cursorData.state == .PRESSED_THIS_FRAME) {
		// Do some click handling
	}
}

HeaderButtonStyle :: proc(hovered: bool) -> claydo.ElementDeclaration {
	return {
		layout = {padding = {16, 16, 8, 8}},
		backgroundColor = hovered ? COLOR_ORANGE : COLOR_BLUE,
	}
}

// Examples of re-usable "Components"
RenderHeaderButton :: proc(text: string) {
	{claydo.ui()(HeaderButtonStyle(claydo.hovered()))
		claydo.text(text, headerTextConfig)
	}
}

dropdownTextItemLayout := claydo.LayoutConfig {
	padding = {8, 8, 4, 4},
}
dropdownTextElementConfig := claydo.TextElementConfig {
	fontSize  = 24,
	textColor = {1, 1, 1, 1},
}

RenderDropdownTextItem :: proc(index: int) {
	{claydo.ui()({layout = dropdownTextItemLayout, backgroundColor = ({180, 180, 180, 255} / 255)})
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
	{.GROW, claydo.SizingMinMax{0, claydo.MAX_FLOAT}},
	{.GROW, claydo.SizingMinMax{0, claydo.MAX_FLOAT}},
}

cWHITE := claydo.Color{255, 255, 255, 255} / 255

Test :: struct {
	value: int,
}

EnterExitSlideUp :: proc(
	initialState: claydo.TransitionData,
	properties: bit_set[claydo.TransitionProperty],
) -> claydo.TransitionData {
	targetState := initialState
	if .Y in properties {
		targetState.boundingBox.y += 20
	}
	if .OVERLAY_COLOR in properties {
		targetState.overlayColor = claydo.Color{255, 255, 255, 255} / 255
	}
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
	elementId: claydo.ElementID,
	cursorData: claydo.CursorData,
	userData: rawptr,
) {
	if (cursorData.state == .PRESSED_THIS_FRAME) {
		shuffle(colors[:], cellCount)
	}
}

HandlePinkButtonInteraction :: proc(
	elementId: claydo.ElementID,
	cursorData: claydo.CursorData,
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
	elementId: claydo.ElementID,
	cursorData: claydo.CursorData,
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
	elementId: claydo.ElementID,
	cursorData: claydo.CursorData,
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

CreateLayout :: proc() -> []claydo.RenderCommand {
	claydo.beginLayout()
	{claydo.ui(claydo.id("OuterContainer"))(
		{
			layout = {
				direction = .TOP_TO_BOTTOM,
				sizing = {width = claydo.sizingGrow(), height = claydo.sizingGrow()},
				padding = {16, 16, 16, 16},
				childGap = 12,
			},
			backgroundColor = cWHITE,
		},
		)
		{claydo.ui()(
			{
				layout = {
					sizing = {claydo.sizingGrow(), claydo.sizingFixed(60)},
					padding = {left = 16},
					childGap = 16,
					childAlignment = {y = .CENTER},
				},
				cornerRadius = {12, 12, 12, 12},
				backgroundColor = ({174, 143, 204, 255} / 255),
			},
			)
			{claydo.ui(claydo.id("ShuffleButton"))(
				{
					backgroundColor = claydo.hovered() ? ({154, 123, 184, 255} / 255) : {},
					layout = {padding = {16, 16, 8, 8}},
					cornerRadius = claydo.cornerRadiusAll(6),
					border = {color = cWHITE, width = claydo.borderOutside(2)},
				},
				)
				claydo.onHover(HandleRandomiseButtonInteraction, nil)
				claydo.text("Randomise", {fontSize = 20, textColor = cWHITE})
			}
			{claydo.ui(claydo.id("bluebutton"))(
				{
					backgroundColor = claydo.hovered() ? ({154, 123, 184, 255} / 255) : {},
					layout = {padding = {16, 16, 8, 8}},
					cornerRadius = claydo.cornerRadiusAll(6),
					border = {color = cWHITE, width = claydo.borderOutside(2)},
				},
				)
				claydo.onHover(HandleBlueButtonInteraction, nil)
				claydo.text("Blue", {fontSize = 20, textColor = cWHITE})
			}
			{claydo.ui(claydo.id("PinkButton"))(
				{
					backgroundColor = claydo.hovered() ? ({154, 123, 184, 255} / 255) : {},
					layout = {padding = {16, 16, 8, 8}},
					cornerRadius = claydo.cornerRadiusAll(6),
					border = {color = cWHITE, width = claydo.borderOutside(2)},
				},
				)
				claydo.onHover(HandlePinkButtonInteraction, nil)
				claydo.text("Pink", {fontSize = 20, textColor = cWHITE})
			}
			{claydo.ui(claydo.id("AddButton"))(
				{
					backgroundColor = claydo.hovered() ? ({154, 123, 184, 255} / 255) : {},
					layout = {padding = {16, 16, 8, 8}},
					cornerRadius = claydo.cornerRadiusAll(6),
					border = {color = cWHITE, width = claydo.borderOutside(2)},
				},
				)
				claydo.onHover(HandleNewButtonInteraction, nil)
				claydo.text("Add Box", {fontSize = 20, textColor = cWHITE})
			}
		}
		for i := 0; i < 5; i += 1 {
			{claydo.ui(claydo.idi("row", u32(i)))({layout = {childGap = 12, sizing = GG}})
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
							layout = {sizing = GG, childAlignment = {.CENTER, .CENTER}},
							backgroundColor = colors[index].color,
							overlayColor = claydo.hovered() ? ({80, 80, 80, 80} / 255) : {1, 1, 1, 0},
							cornerRadius = {12, 12, 12, 12},
							border = {darker, claydo.borderOutside(3)},
							transition = {
								handler = claydo.easeOut,
								duration = 0.5,
								properties = {.WIDTH, .X, .Y, .BACKGROUND_COLOR, .OVERLAY_COLOR},
								enter = {setInitialState = EnterExitSlideUp},
								exit = {setFinalState = EnterExitSlideUp},
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
								fontSize = 32,
								textColor = colors[index].id > 29 ? ({255, 255, 255, 255} / 255) : ({154, 123, 184, 255} / 255),
							},
						)
					}
				}
			}
		}
	}
	return claydo.endLayout(rl.GetFrameTime())
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
		claydo.setDebugModeEnabled(debugEnabled)
	}
	//----------------------------------------------------------------------------------
	// Handle scroll containers
	mousePosition := rl.GetMousePosition()
	claydo.setCursorState(mousePosition, rl.IsMouseButtonDown(.LEFT) && !scrollbarData.mouseDown)
	claydo.setLayoutDimensions({f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight())})
	if (!rl.IsMouseButtonDown(.LEFT)) {
		scrollbarData.mouseDown = false
	}

	if (rl.IsMouseButtonDown(.LEFT) &&
		   !scrollbarData.mouseDown &&
		   claydo.cursorOver(claydo.hashString("ScrollBar", 0))) {
		scrollContainerData := claydo.getScrollContainerData(claydo.hashString("MainContent", 0))
		scrollbarData.clickOrigin = mousePosition
		scrollbarData.positionOrigin = scrollContainerData.scrollPosition^
		scrollbarData.mouseDown = true
	} else if (scrollbarData.mouseDown) {
		scrollContainerData := claydo.getScrollContainerData(claydo.hashString("MainContent", 0))
		if (scrollContainerData.contentDimensions.y > 0) {
			ratio: [2]f32 = {
				scrollContainerData.contentDimensions.x / scrollContainerData.dimensions.x,
				scrollContainerData.contentDimensions.x / scrollContainerData.dimensions.y,
			}
			if (scrollContainerData.config.vertical) {
				scrollContainerData.scrollPosition.y =
					scrollbarData.positionOrigin.y +
					(scrollbarData.clickOrigin.y - mousePosition.y) * ratio.y
			}
			if (scrollContainerData.config.horizontal) {
				scrollContainerData.scrollPosition.x =
					scrollbarData.positionOrigin.x +
					(scrollbarData.clickOrigin.x - mousePosition.x) * ratio.x
			}
		}
	}

	claydo.updateScrollContainers(true, {mouseWheelX, mouseWheelY}, rl.GetFrameTime())
	// Generate the auto layout for rendering
	currentTime := rl.GetTime()
	renderCommands := CreateLayout()
	// RENDERING ---------------------------------
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)
	rr.clayRaylibRender(renderCommands)
	rl.EndDrawing()
	//----------------------------------------------------------------------------------
}

reinitializeClay := false

HandleClayErrors :: proc(errorData: claydo.ErrorData) {
	fmt.println(errorData.text)
	if (errorData.type == .ELEMENTS_CAPACITY_EXCEEDED) {
		reinitializeClay = true
		claydo.setMaxElementCount(claydo.getMaxElementCount() * 2)
	} else if (errorData.type == .MEASUREMENT_CAPACITY_EXCEEDED) {
		reinitializeClay = true
		claydo.setMaxMeasureTextCacheWordCount(claydo.getMaxMeasureTextCacheWordCount() * 2)
	}
}

main :: proc() {
	claydo.setMaxElementCount(8192 * 2)
	totalMemorySize := claydo.minMemorySize()
	arena: claydo.Arena = claydo.createArenaWithCapacity(totalMemorySize)
	claydo.initialize(
		arena,
		{cast(f32)rl.GetScreenWidth(), cast(f32)rl.GetScreenHeight()},
		{errProc = HandleClayErrors},
	)
	claydo.setMeasureTextProcedure(rr.measureText, nil)
	rr.raylibInitialize(
		1024,
		768,
		"Clay - Raylib Renderer Example",
		{.VSYNC_HINT, .WINDOW_RESIZABLE, .MSAA_4X_HINT},
	)
	profilePicture := rl.LoadTexture("resources/profile-picture.png")

	fonts: [2]rl.Font
	rr.loadFont(FONT_ID_BODY_24, 48, "resources/Roboto-Regular.ttf")
	rr.loadFont(FONT_ID_BODY_16, 32, "resources/Roboto-Regular.ttf")
	claydo.setMeasureTextProcedure(rr.measureText, &fonts)
	charData = make([]u8, 100 * 3)
	for i := 0; i < cellCount; i += 1 {
		fi := f32(i)
		buf := make([]u8, 3)
		rInt := rand.int_range(0, 999)
		strId := strconv.write_int(buf[:], i64(i), 10)
		colors[i] = {
			id       = i,
			color    = ({255 - fi, 255 - fi * 4, 255 - fi * 2, 255} / 255),
			stringId = strId,
		}
	}

	//--------------------------------------------------------------------------------------

	// Main game loop
	for !rl.WindowShouldClose() // Detect window close button or ESC key
	{
		if (reinitializeClay) {
			claydo.setMaxElementCount(8192)
			totalMemorySize = claydo.minMemorySize()
			arena = claydo.createArenaWithCapacity(totalMemorySize)
			claydo.initialize(
				arena,
				{cast(f32)rl.GetScreenWidth(), cast(f32)rl.GetScreenHeight()},
				{errProc = HandleClayErrors},
			)
			reinitializeClay = false
		}
		UpdateDrawFrame()
	}
	rl.CloseWindow()
}
