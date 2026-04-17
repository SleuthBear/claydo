package claydo

import "base:intrinsics"
import "base:runtime"
import "core:fmt"
import "core:mem/virtual"
import "core:strconv"

// NOTE -- TYPES --
Color :: [4]f32
WrapMode :: enum {
	WRAP_WORDS,
	WRAP_NEWLINES,
	WRAP_NONE,
}
Padding :: struct {
	left, right, top, bottom: f32,
}
Sizing :: struct {
	width, height: SizingAxis,
}
SizingType :: enum {
	FIT,
	GROW,
	PERCENT,
	FIXED,
}
SizingAxis :: struct {
	type:  SizingType,
	value: union {
		Percent,
		SizingMinMax,
	},
}
Percent :: distinct f32
SizingMinMax :: struct {
	min, max: f32,
}
BoundingBox :: struct {
	x, y:          f32,
	width, height: f32,
}
Alignment :: enum {
	LEFT,
	RIGHT,
	CENTER,
}
TextElementConfig :: struct {
	userPtr:    rawptr,
	textColor:  Color,
	fontId:     u16,
	fontSize:   f32,
	spacing:    f32,
	lineHeight: f32,
	wrapMode:   WrapMode,
	alignment:  Alignment,
}
AspectRatio :: distinct f32
ImageData :: distinct rawptr
AttachPointType :: enum {
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
FloatingAttachPoints :: struct {
	element: AttachPointType,
	parent:  AttachPointType,
}
PointerCaptureMode :: enum {
	CAPTURE,
	PASSTHROUGH,
}
FloatingAttachToElement :: enum {
	NONE,
	PARENT,
	ELEMENT_WITH_ID,
	ROOT,
	INLINE,
}
FloatingClipToElement :: enum {
	NONE,
	ATTACHED_PARENT,
}
FloatingElementConfig :: struct {
	offset:             [2]f32,
	expand:             [2]f32,
	parentId:           u32,
	zIdx:               i16,
	attachPoints:       FloatingAttachPoints,
	pointerCaptureMode: PointerCaptureMode,
	attachTo:           FloatingAttachToElement,
	clipTo:             FloatingClipToElement,
}
CustomElementConfig :: distinct rawptr
ClipElementConfig :: struct {
	horizontal:  bool,
	vertical:    bool,
	childOffset: [2]f32,
}
BorderWidth :: struct {
	left, right, top, bottom: f32,
	betweenChildren:          f32,
}
BorderElementConfig :: struct {
	color: Color,
	width: BorderWidth,
}
CornerRadius :: struct {
	topLeft, topRight, bottomLeft, bottomRight: f32,
}
TextRenderData :: struct {
	text:       string,
	color:      Color,
	fontId:     u16,
	fontSize:   f32,
	spacing:    f32,
	lineHeight: f32,
}
RectangleRenderData :: struct {
	color:        Color,
	cornerRadius: CornerRadius,
}
ImageRenderData :: struct {
	color:        Color,
	cornerRadius: CornerRadius,
	data:         ImageData,
}
CustomRenderData :: struct {
	color:        Color,
	cornerRadius: CornerRadius,
	data:         rawptr,
}
ClipRenderData :: struct {
	horizontal: bool,
	vertical:   bool,
}
BorderRenderData :: struct {
	color:        Color,
	cornerRadius: CornerRadius,
	width:        BorderWidth,
	overlayColor: OverlayColorRenderData,
}
// TODO render data should not exist. Render command should be a union of commands we can switch on
RenderData :: union {
	TextRenderData,
	RectangleRenderData,
	ImageRenderData,
	CustomRenderData,
	BorderRenderData,
	ClipRenderData,
	OverlayColorRenderData,
}
RenderCommand :: struct {
	boundingBox: BoundingBox,
	renderData:  RenderData,
	userPtr:     rawptr,
	id:          u32,
	zIdx:        i16,
	type:        RenderCommandType,
}
RenderCommandType :: enum {
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
ScrollContainerData :: struct {
	scrollPosition:    ^[2]f32,
	dimensions:        [2]f32,
	contentDimensions: [2]f32,
	config:            ClipElementConfig,
	found:             bool,
}
PointerDataInteractionState :: enum {
	PRESSED_THIS_FRAME,
	PRESSED,
	RELEASED_THIS_FRAME,
	RELEASED,
}
PointerData :: struct {
	position: [2]f32,
	state:    PointerDataInteractionState,
}
LayoutAlignmentX :: enum {
	LEFT,
	RIGHT,
	CENTER,
}
LayoutAlignmentY :: enum {
	CENTER,
	TOP,
	BOTTOM,
}
ChildAlignment :: struct {
	x: LayoutAlignmentX,
	y: LayoutAlignmentY,
}
LayoutDirection :: enum {
	LEFT_TO_RIGHT,
	TOP_TO_BOTTOM,
}
LayoutConfig :: struct {
	sizing:         Sizing,
	padding:        Padding,
	childGap:       f32,
	childAlignment: ChildAlignment,
	direction:      LayoutDirection,
}
ElementDeclaration :: struct {
	layout:          LayoutConfig,
	backgroundColor: Color,
	cornerRadius:    CornerRadius,
	aspectRatio:     AspectRatio,
	image:           ImageData,
	floating:        FloatingElementConfig,
	custom:          CustomElementConfig,
	clip:            ClipElementConfig,
	border:          BorderElementConfig,
	overlayColor:    Color,
	transition:      TransitionElementConfig,
	userPtr:         rawptr,
}
ElementData :: struct {
	boundingBox: BoundingBox,
	found:       bool,
}
ErrorType :: enum {
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
ErrorData :: struct {
	type:    ErrorType,
	text:    string,
	userPtr: rawptr,
}
// NOTE - Implementation -
BooleanWarnings :: struct {
	maxElementsExceeded,
	maxRenderCommandsExceeded,
	maxTextMeasureCacheExceeded,
	textMeasurementFunctionNotSet: bool,
}
Warning :: struct {
	baseMessage:    string,
	dynamicMessage: string,
}
TransitionData :: struct {
	boundingBox:  BoundingBox,
	color:        Color,
	overlayColor: Color,
	borderColor:  Color,
	borderWidth:  BorderWidth,
}
TransitionState :: enum {
	IDLE,
	ENTERING,
	TRANSITIONING,
	EXITING,
}
TransitionProperty :: enum u8 {
	X,
	Y,
	WIDTH,
	HEIGHT,
	BACKGROUND_COLOR,
	OVERLAY_COLOR,
	CORNER_RADIUS,
	BORDER_COLOR,
	BORDER_WIDTH,
}

TransitionCallbackArguments :: struct {
	state:       TransitionState,
	initial:     TransitionData,
	current:     ^TransitionData,
	target:      TransitionData,
	elapsedTime: f32,
	duration:    f32,
	properties:  bit_set[TransitionProperty],
}

TransitionEnterTriggerType :: enum {
	SKIP_ON_FIRST_PARENT_FRAME,
	TRIGGER_ON_FIRST_PARENT_FRAME,
}

TransitionExitTriggerType :: enum {
	SKIP_WHEN_PARENT_EXITS,
	TRIGGER_WHEN_PARENT_EXITS,
}

TransitionInteractionHandlingType :: enum {
	DISABLE_INTERACTIONS_WHILE_TRANSITIONING_POSITION,
	ALLOW_INTERACTIONS_WHILE_TRANSITIONING_POSITION,
}

ExitTransitionSiblingOrdering :: enum {
	UNDERNEATH_SIBLINGS,
	NATURAL_ORDER,
	ABOVE_SIBLINGS,
}

TransitionElementConfig :: struct {
	handler:             proc(_: TransitionCallbackArguments) -> bool,
	duration:            f32,
	properties:          bit_set[TransitionProperty],
	interactionHandling: TransitionInteractionHandlingType,
	enter:               struct {
		setInitialState: proc(
			targetState: TransitionData,
			properties: bit_set[TransitionProperty],
		) -> TransitionData,
		trigger:         TransitionEnterTriggerType,
	},
	exit:                struct {
		setFinalState:   proc(
			initialState: TransitionData,
			properties: bit_set[TransitionProperty],
		) -> TransitionData,
		trigger:         TransitionExitTriggerType,
		siblingOrdering: ExitTransitionSiblingOrdering,
	},
}
OverlayColorRenderData :: distinct Color
WrappedTextLine :: struct {
	dimensions: [2]f32,
	text:       string,
}
TextElementData :: struct {
	text:                string,
	preferredDimensions: [2]f32,
	wrappedLines:        Array(WrappedTextLine),
}
TextDeclaration :: struct {
	config: TextElementConfig,
	data:   TextElementData,
}
LayoutElement :: struct {
	children:              Array(int),
	dimensions:            [2]f32,
	minDimensions:         [2]f32,
	id:                    u32,
	floatingChildrenCount: u16,
	config:                union {
		ElementDeclaration,
		TextDeclaration,
	},
	exiting:               bool,
}
TransitionDataInternal :: struct {
	initialState:              TransitionData,
	currentState:              TransitionData,
	targetState:               TransitionData,
	elementThisFrame:          ^LayoutElement,
	elementId:                 u32,
	parentId:                  u32,
	oldParentRelativePosition: [2]f32,
	siblingIdx:                u32,
	elapsedTime:               f32,
	state:                     TransitionState,
	transitionOut:             bool,
	reparented:                bool,
	activeProperties:          bit_set[TransitionProperty],
}
ScrollContainerDataInternal :: struct {
	layoutElement:       ^LayoutElement,
	boundingBox:         BoundingBox,
	contentSize:         [2]f32,
	scrollOrigin:        [2]f32,
	pointerOrigin:       [2]f32,
	scrollMomentum:      [2]f32,
	scrollPosition:      [2]f32,
	previousDelta:       [2]f32,
	momentumTime:        f32,
	elementId:           u32,
	openThisFrame:       bool,
	pointerScrollActive: bool,
}
DebugElementData :: struct {
	collision: bool,
	collapsed: bool,
}
ElementID :: struct {
	id, offset, baseId: u32,
	stringId:           string,
}
LayoutElementHashMapItem :: struct {
	boundingBox:          BoundingBox,
	elementId:            ElementID,
	layoutElement:        ^LayoutElement,
	onHoverFunction:      proc(_: ElementID, _: PointerData, _: rawptr),
	hoverFunctionUserPtr: rawptr,
	nextIdx:              int,
	generation:           u32,
	debugData:            ^DebugElementData,
	appearedThisFrame:    bool,
}
MeasuredWord :: struct {
	startOffset, length, next: int,
	width:                     f32,
}
MeasureTextCacheItem :: struct {
	unwrappedDimension:    [2]f32,
	measuredWordsStartIdx: int,
	minWidth:              f32,
	id:                    u32,
	nextIdx:               int,
	generation:            u32,
	containsNewLines:      bool,
}
LayoutElementTreeNode :: struct {
	layoutElement:   ^LayoutElement,
	position:        [2]f32,
	nextChildOffset: [2]f32,
}
LayoutElementTreeRoot :: struct {
	layoutElementIdx: int,
	parentId:         u32,
	clipElementId:    u32,
	zIdx:             i16,
	pointerOffset:    [2]f32,
}
TransitionElementsAddedCount :: struct {
	elementsAdded:        int,
	elementChildrenAdded: int,
}
Array :: struct($T: typeid) {
	items: []T,
	len:   int,
	cap:   int,
}
DebugElementConfigTypeLabelConfig :: struct {
	label: string,
	color: Color,
}
RenderDebugLayoutData :: struct {
	rowCount:              int,
	selectedElementRowIdx: int,
}
ErrorHandler :: struct {
	errProc: proc(_: ErrorData),
	userPtr: rawptr,
}
Arena :: virtual.Arena
// I assume one state at a time. This is probably wrong, but should be easy enough to fix later
State :: struct {
	measureText:                        proc(_: string, _: TextElementConfig, _: rawptr) -> [2]f32,
	queryScrollOffset:                  proc(elementId: u32, userPtr: rawptr) -> [2]f32,
	exitingElementsLength:              int,
	exitingElementsChildrenLength:      int,
	maxElementCount:                    int,
	maxMeasureTextCacheWordCount:       int,
	warningsEnabled:                    bool,
	errorHandler:                       ErrorHandler,
	booleanWarnings:                    BooleanWarnings,
	warnings:                           Array(Warning),
	pointerInfo:                        PointerData,
	layoutDimensions:                   [2]f32,
	dynamicElementIdxBaseHash:          ElementID,
	dynamicElementIdx:                  u32,
	debugModeEnabled:                   bool,
	disableCulling:                     bool,
	externalScrollHandlingEnabled:      bool,
	debugSelectedElementId:             u32,
	generation:                         u32,
	measureTextUserPtr:                 rawptr,
	queryScrollOffsetUserPtr:           rawptr,
	arenaInternal:                      Arena,
	arena:                              runtime.Allocator,
	arenaResetPoint:                    uint,
	layoutElements:                     Array(LayoutElement),
	renderCommands:                     Array(RenderCommand),
	openLayoutElementStack:             Array(int),
	layoutElementChildren:              Array(int),
	layoutElementChildrenBuffer:        Array(int),
	reusableElementIdxBuffer:           Array(int),
	layoutElementClipElementIds:        Array(int),
	layoutElementIdStrings:             Array(string),
	wrappedTextLines:                   Array(WrappedTextLine),
	layoutElementTreeNodes:             Array(LayoutElementTreeNode),
	layoutElementTreeRoots:             Array(LayoutElementTreeRoot),
	layoutElementsHashMapInternal:      Array(LayoutElementHashMapItem),
	layoutElementsHashMap:              Array(int),
	measureTextHashMapInternal:         Array(MeasureTextCacheItem),
	measureTextHashMapInternalFreeList: Array(int),
	measureTextHashMap:                 Array(int),
	measuredWords:                      Array(MeasuredWord),
	measuredWordsFreeList:              Array(int),
	openClipElementStack:               Array(int),
	pointerOverIds:                     Array(ElementID),
	scrollContainerDatas:               Array(ScrollContainerDataInternal),
	transitionDatas:                    Array(TransitionDataInternal),
	treeNodeVisited:                    Array(bool),
	dynamicStringData:                  Array(byte),
	debugElementData:                   Array(DebugElementData),
	rootResizedLastFrame:               bool,
}
DEFAULT_MAX_ELEMENT_COUNT :: 8192
DEFAULT_MAX_MEASURE_TEXT_WORD_CACHE_COUNT :: 16384
MAX_FLOAT: f32 : 999999999999999 // TODO
EPSILON: f32 : 0.01

DEFAULT_LAYOUT_CONFIG: LayoutConfig = {}
DEFAULT_TEXT_ELEMENT_CONFIG: TextElementConfig = {}
DEFAULT_ASPECT_RATIO_ELEMENT_CONFIG: AspectRatio = {}
DEFAULT_IMAGE_ELEMENT_CONFIG: ImageData = {}
DEFAULT_FLOATING_ELEMENT_CONFIG: FloatingElementConfig = {}
DEFAULT_CUSTOM_ELEMENT_CONFIG: CustomElementConfig = {}
DEFAULT_CLIP_ELEMENT_CONFIG: ClipElementConfig = {}
DEFAULT_BORDER_ELEMENT_CONFIG: BorderElementConfig = {}
DEFAULT_LAYOUT_ELEMENT: LayoutElement = {}
DEFAULT_MEASURE_TEXT_CACHE_ITEM: MeasureTextCacheItem = {}
DEFAULT_LAYOUT_ELEMENT_HASH_MAP_ITEM: LayoutElementHashMapItem = {}
DEFAULT_CORNER_RADIUS: CornerRadius = {}


/* This proc is some bullshit. It is also slower than hardcoding the arrays.*/
@(private = "file")
defaultPtr :: proc(t: typeid) -> rawptr {
	switch t {
	case LayoutConfig:
		return rawptr(&DEFAULT_LAYOUT_CONFIG)
	case TextElementConfig:
		return rawptr(&DEFAULT_TEXT_ELEMENT_CONFIG)
	case AspectRatio:
		return rawptr(&DEFAULT_ASPECT_RATIO_ELEMENT_CONFIG)
	case ImageData:
		return rawptr(&DEFAULT_IMAGE_ELEMENT_CONFIG)
	case FloatingElementConfig:
		return rawptr(&DEFAULT_FLOATING_ELEMENT_CONFIG)
	case CustomElementConfig:
		return rawptr(&DEFAULT_CUSTOM_ELEMENT_CONFIG)
	case ClipElementConfig:
		return rawptr(&DEFAULT_CLIP_ELEMENT_CONFIG)
	case BorderElementConfig:
		return rawptr(&DEFAULT_BORDER_ELEMENT_CONFIG)
	case LayoutElement:
		return rawptr(&DEFAULT_LAYOUT_ELEMENT)
	}
	return nil
}
s: ^State

// NOTE - PROCEDURES

// TODO arena stuff. I assume I can offload this to virtual.Arena, but eventually will need to do it myself.
@(private = "file")
arrayCreate :: proc($T: typeid, n: int, allo: runtime.Allocator) -> Array(T) {
	items, err := make([]T, n, allo)

	if err != nil {
		s.errorHandler.errProc(
			ErrorData {
				type = .ARENA_CAPACITY_EXCEEDED,
				text = "Claydo attempted to allocate memory in its arena, but ran out of capacity. Try increasing the capacity of the arena passed to initialize()",
				userPtr = s.errorHandler.userPtr,
			},
		)
		return {}
	}
	return Array(T){items = items, len = 0, cap = n}
}

@(private = "file")
arraySlice :: #force_inline proc(array: ^Array($T), offset, len: int) -> Array(T) {
	if len + offset > array.cap {
		return {}
	}
	slicedArray := Array(T) {
		items = array.items[offset:],
		len   = len,
		cap   = array.cap - offset,
	}
	return slicedArray
}

@(private = "file")
arrayPush :: #force_inline proc(array: ^Array($T), value: T) -> ^T {
	if array.len >= array.cap {
		return (^T)(defaultPtr(T))
	}
	array.items[array.len] = value
	array.len += 1
	return &array.items[array.len - 1]
}

@(private = "file")
arraySet :: #force_inline proc(array: ^Array($T), idx: int, value: T) -> ^T {
	if idx >= array.len {
		return (^T)(defaultPtr(T))
	}
	array.items[idx] = value
	return &array.items[idx]
}

@(private = "file")
arrayGet :: #force_inline proc(array: Array($T), idx: int) -> T {
	if idx >= array.len {
		return T{}
	}
	return array.items[idx]
}

@(private = "file")
arrayGetPtr :: #force_inline proc(array: ^Array($T), idx: int) -> ^T {
	if idx >= array.len {
		return (^T)(defaultPtr(T))
	}
	return &array.items[idx]
}

@(private = "file")
arrayPeek :: #force_inline proc(array: Array($T)) -> T {
	if array.len <= 0 {
		return T{}
	}
	return array.items[array.len - 1]
}

@(private = "file")
arrayPop :: #force_inline proc(array: ^Array($T)) -> T {
	if array.len <= 0 {
		return T{}
	}
	array.len -= 1
	return array.items[array.len]
}

@(private = "file")
arraySwapback :: #force_inline proc(array: ^Array($T), idx: int) {
	if idx >= array.len {
		return
	}
	array.items[idx] = array.items[array.len - 1]
	array.len -= 1
}

@(private = "file")
arrayIter :: #force_inline proc(array: Array($T)) -> []T {
	return array.items[:array.len]
}

@(private = "file")
floatEquals :: proc(a, b: f32) -> bool {
	return abs(a - b) < EPSILON
}

@(private = "file")
writeStringToCharBuffer :: proc(text: string) -> string {
	offset := s.dynamicStringData.len + 1
	data := ([]byte)(s.dynamicStringData.items[:])
	data = data[offset:]
	intrinsics.mem_copy(&data, raw_data(text), len(text))
	s.dynamicStringData.len += len(text)
	return string(s.dynamicStringData.items[offset:])
}

@(private = "file")
getOpenLayoutElement :: proc() -> ^LayoutElement {
	return arrayGetPtr(
		&s.layoutElements,
		arrayGet(s.openLayoutElementStack, s.openLayoutElementStack.len - 1),
	)
}

getOpenElementId :: proc() -> u32 {
	return getOpenLayoutElement().id

}
@(private = "file")
getParentElement :: proc() -> ^LayoutElement {
	stack := s.openLayoutElementStack
	return arrayGetPtr(&s.layoutElements, arrayGet(stack, stack.len - 2))
}

@(private = "file")
getParentElementId :: proc() -> u32 {
	return getParentElement().id
}

@(private = "file")
borderHasAnyWidth :: proc(borderConfig: ^BorderElementConfig) -> bool {
	return(
		borderConfig.width.betweenChildren > 0 ||
		borderConfig.width.left > 0 ||
		borderConfig.width.right > 0 ||
		borderConfig.width.top > 0 ||
		borderConfig.width.bottom > 0 \
	)
}

hashNumber :: proc(offset: u32, seed: u32) -> ElementID {
	hash := seed
	hash += (offset + 48)
	hash += (hash << 10)
	hash ~= (hash >> 6)

	hash += (hash << 3)
	hash ~= (hash >> 11)
	hash += (hash << 15)
	return ElementID{id = hash + 1, offset = offset, baseId = seed, stringId = ""}
}

hashString :: proc(key: string, seed: u32) -> ElementID {
	hash := seed
	for ru in key {
		hash += u32(ru)
		hash += (hash << 10)
		hash ~= (hash >> 6)
	}

	hash += (hash << 3)
	hash ~= (hash >> 11)
	hash += (hash << 15)
	return ElementID{id = hash + 1, offset = 0, baseId = hash + 1, stringId = key}
}

@(private = "file")
hashStringWithOffset :: proc(key: string, offset, seed: u32) -> ElementID {
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
	return ElementID{id = hash + 1, offset = offset, baseId = base + 1, stringId = key}
}

// TODO figure out how to do SIMD
@(private = "file")
hashData :: proc(data: []byte) -> u64 {
	hash: u64 = 0
	for b in data {
		hash += u64(b)
		hash += (hash << 10)
		hash ~= (hash >> 6)
	}
	return hash
}

@(private = "file")
hashDataString :: proc(data: string) -> u32 {
	hash: u32 = 0
	for ru in data {
		hash += u32(ru)
		hash += (hash << 10)
		hash ~= (hash >> 6)
	}
	return hash
}

@(private = "file")
hashStringContentWithConfig :: proc(text: string, config: TextElementConfig) -> u32 {
	// HACK not checking if statically allocated
	hash := hashDataString(text)
	hash += u32(config.fontId)
	hash += (hash << 10)
	hash ~= (hash >> 6)

	hash += transmute(u32)(config.fontSize)
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
addMeasuredWord :: proc(word: MeasuredWord, previousWord: ^MeasuredWord) -> ^MeasuredWord {
	if s.measuredWordsFreeList.len > 0 {
		newItemIdx := arrayGet(s.measuredWordsFreeList, s.measuredWordsFreeList.len - 1)
		s.measuredWordsFreeList.len -= 1
		arraySet(&s.measuredWords, newItemIdx, word)
		previousWord.next = newItemIdx
		return arrayGetPtr(&s.measuredWords, newItemIdx)
	}
	previousWord.next = s.measuredWords.len
	return arrayPush(&s.measuredWords, word)
}

// NOTE - Beware this procedure. Text is evil. (170 lines)
@(private = "file")
measureTextCached :: proc(text: string, config: TextElementConfig) -> ^MeasureTextCacheItem {
	// Before setting a new item, try and clean up some of the cache
	id := hashStringContentWithConfig(text, config)
	hashBucket := id % u32(s.maxMeasureTextCacheWordCount / 32)
	elementIdxPrevious := 0
	// get an index at random?
	elementIdx := s.measureTextHashMap.items[hashBucket]
	for elementIdx != 0 { 	// if it's a valid element
		// get the actual entry for the item
		hashEntry := arrayGetPtr(&s.measureTextHashMapInternal, elementIdx)
		if hashEntry.id == id { 	// if the id matches our new string (same contents and config)
			// increment the generation so we know how recently it was touched
			hashEntry.generation = s.generation
			// return the measured details
			return hashEntry
		}
		// the hash entry hasn't been seen in a few frames, so delete
		if s.generation - hashEntry.generation > 2 {
			// get the idx to add the next word?
			nextWordIdx := hashEntry.measuredWordsStartIdx
			// While the chain (sentence?) has more words, keep adding them to the free list
			for nextWordIdx != -1 {
				measuredWord := arrayGet(s.measuredWords, nextWordIdx)
				arrayPush(&s.measuredWordsFreeList, nextWordIdx)
				nextWordIdx = measuredWord.next
			}
			nextIdx := hashEntry.nextIdx
			// mark the elementIdx as empty in the internal array
			arraySet(
				&s.measureTextHashMapInternal,
				elementIdx,
				MeasureTextCacheItem{measuredWordsStartIdx = -1},
			)
			// mark that location as available on the free list
			arrayPush(&s.measureTextHashMapInternalFreeList, elementIdx)
			if elementIdxPrevious == 0 { 	// we are on the first loop
				s.measureTextHashMap.items[hashBucket] = nextIdx
			} else {
				previousHashEntry := arrayGetPtr(&s.measureTextHashMapInternal, elementIdxPrevious)
				// jump from previous to next (skip this location as it's now empty)
				previousHashEntry.nextIdx = hashEntry.nextIdx
			}
			elementIdx = nextIdx
		} else {
			// If we don't need to clear the data, just move on
			elementIdxPrevious = elementIdx
			elementIdx = hashEntry.nextIdx
		}
	}
	// Now add the new item
	newItemIdx := 0
	newCacheItem := MeasureTextCacheItem {
		measuredWordsStartIdx = -1,
		id                    = id,
		generation            = s.generation,
	}
	measured: ^MeasureTextCacheItem = nil
	if s.measureTextHashMapInternalFreeList.len > 0 {
		newItemIdx := arrayPop(&s.measureTextHashMapInternalFreeList)
		measured = arraySet(&s.measureTextHashMapInternal, newItemIdx, newCacheItem)
	} else {
		// I wonder why this is cap -1 ...
		if s.measureTextHashMapInternal.len == s.measureTextHashMapInternal.cap - 1 {
			if !s.booleanWarnings.maxTextMeasureCacheExceeded {
				s.errorHandler.errProc(
					ErrorData {
						type = .ELEMENTS_CAPACITY_EXCEEDED,
						text = "Claydo ran out of capacity while attempting to measure text elements. Try using setMaxElementCount() with a higher value.",
						userPtr = s.errorHandler.userPtr,
					},
				)
				s.booleanWarnings.maxTextMeasureCacheExceeded = true
			}
			return &DEFAULT_MEASURE_TEXT_CACHE_ITEM
		}
		measured = arrayPush(&s.measureTextHashMapInternal, newCacheItem)
		newItemIdx = s.measureTextHashMapInternal.len - 1
	}

	start := 0
	end := 0
	lineWidth: f32 = 0
	measuredWidth: f32 = 0
	measuredHeight: f32 = 0
	spaceWidth: f32 = s.measureText(" ", config, s.measureTextUserPtr).x
	tempWord := MeasuredWord {
		next = -1,
	}
	previousWord: ^MeasuredWord = &tempWord
	for (end < len(text)) {
		if s.measuredWords.len == s.measuredWords.cap - 1 {
			if !s.booleanWarnings.maxTextMeasureCacheExceeded {
				s.errorHandler.errProc(
					ErrorData {
						type = .MEASUREMENT_CAPACITY_EXCEEDED,
						text = "Claydo has run out of space in it's internal text measurement cache. Try using setMaxMeasureTextCacheWordCount() (default 16384, with 1 unit storing 1 measured word).",
						userPtr = s.errorHandler.userPtr,
					},
				)
				s.booleanWarnings.maxTextMeasureCacheExceeded = true
			}
			return &DEFAULT_MEASURE_TEXT_CACHE_ITEM
		}
		current := text[end]
		if current == ' ' || current == '\n' {
			length := end - start
			dimensions := [2]f32{}
			if length > 0 {
				dimensions = s.measureText(
					text[start:start + length],
					config,
					s.measureTextUserPtr,
				)
			}
			measured.minWidth = max(dimensions.x, measured.minWidth)
			measuredHeight = max(dimensions.y, measuredHeight)
			if current == ' ' {
				dimensions.x += spaceWidth
				lineWidth += dimensions.x
				previousWord = addMeasuredWord(
					MeasuredWord {
						startOffset = start,
						length = length + 1,
						width = dimensions.x,
						next = -1,
					},
					previousWord,
				)
			} else if current == '\n' {
				if length > 0 {
					previousWord = addMeasuredWord(
						MeasuredWord {
							startOffset = start,
							length = length,
							width = dimensions.x,
							next = -1,
						},
						previousWord,
					)
				}
				previousWord = addMeasuredWord(
					MeasuredWord{startOffset = end + 1, length = 0, width = 0, next = -1},
					previousWord,
				)
				lineWidth += dimensions.x
				measuredWidth += max(lineWidth, measuredWidth)
				measured.containsNewLines = true
				lineWidth = 0
			}
			start = end + 1
		}
		end += 1
	}
	if end - start > 0 {
		dimensions := s.measureText(text[start:end], config, s.measureTextUserPtr)
		addMeasuredWord(
			MeasuredWord {
				startOffset = start,
				length = end - start,
				width = dimensions.x,
				next = -1,
			},
			previousWord,
		)
		lineWidth += dimensions.x
		measuredHeight = max(dimensions.y, measuredHeight)
		measured.minWidth = max(dimensions.x, measured.minWidth)
	}
	measuredWidth = max(lineWidth, measuredWidth) - config.spacing

	measured.measuredWordsStartIdx = tempWord.next
	measured.unwrappedDimension = {measuredWidth, measuredHeight}

	if elementIdxPrevious != 0 {
		arrayGetPtr(&s.measureTextHashMapInternal, elementIdxPrevious).nextIdx = newItemIdx
	} else {
		s.measureTextHashMap.items[hashBucket] = newItemIdx
	}
	return measured
}

@(private = "file")
pointIsInsideRect :: proc(point: [2]f32, rect: BoundingBox) -> bool {
	return(
		point.x >= rect.x &&
		point.x <= rect.x + rect.width &&
		point.y >= rect.y &&
		point.y <= rect.y + rect.height \
	)
}

@(private = "file")
addHashMapItem :: proc(
	elementId: ElementID,
	layoutElement: ^LayoutElement,
) -> ^LayoutElementHashMapItem {
	if s.layoutElementsHashMapInternal.len == s.layoutElementsHashMapInternal.cap - 1 {
		return nil
	}
	// new item
	item := LayoutElementHashMapItem {
		elementId         = elementId,
		layoutElement     = layoutElement,
		nextIdx           = -1,
		generation        = s.generation + 1,
		appearedThisFrame = true,
	}
	hashBucket := elementId.id % u32(s.layoutElementsHashMap.cap)
	hashItemPrevious := -1
	// random layout item?
	hashItemIdx := s.layoutElementsHashMap.items[hashBucket]
	for hashItemIdx != -1 {
		hashItem := arrayGetPtr(&s.layoutElementsHashMapInternal, hashItemIdx)
		// layout item from the hash map collides with the provided id
		if hashItem.elementId.id == elementId.id {
			item.nextIdx = hashItem.nextIdx
			if hashItem.generation <= s.generation { 	// first collision. Assume same element
				// Update the hashItem
				hashItem.appearedThisFrame = hashItem.generation < s.generation
				hashItem.elementId = elementId
				hashItem.generation = s.generation + 1
				hashItem.layoutElement = layoutElement
				hashItem.debugData.collision = false
				hashItem.onHoverFunction = nil
				hashItem.hoverFunctionUserPtr = nil
			} else {
				s.errorHandler.errProc(
					ErrorData {
						type = .DUPLICATE_ID,
						text = "An element with this ID was already previously declared during this layout.",
						userPtr = s.errorHandler.userPtr,
					},
				)
				if s.debugModeEnabled {
					hashItem.debugData.collision = true
				}
			}
			return hashItem
		}
		hashItemPrevious = hashItemIdx
		hashItemIdx = hashItem.nextIdx
	}
	hashItem := arrayPush(&s.layoutElementsHashMapInternal, item)
	hashItem.debugData = arrayPush(&s.debugElementData, DebugElementData{})
	if hashItemPrevious != -1 {
		// If we looped through any items, and didn't collide, then make sure the last one points to the new entry
		arrayGetPtr(&s.layoutElementsHashMapInternal, hashItemPrevious).nextIdx =
			s.layoutElementsHashMapInternal.len - 1
	} else {
		// If we didn't iterate just set the hash map to point at the inserted location
		s.layoutElementsHashMap.items[hashBucket] = s.layoutElementsHashMapInternal.len - 1
	}
	return hashItem
}

// Try and retrieve the item from the hash map by it's id (by doing some modulus black magic on a hash value).
// If it's not there return the default.
@(private = "file")
getHashMapItem :: proc(id: u32) -> ^LayoutElementHashMapItem {
	hashBucket := id % u32(s.layoutElementsHashMap.cap)
	elementIdx := s.layoutElementsHashMap.items[hashBucket]
	for elementIdx != -1 {
		hashItem := arrayGetPtr(&s.layoutElementsHashMapInternal, elementIdx)
		if hashItem.elementId.id == id {
			return hashItem
		}
		elementIdx = hashItem.nextIdx
	}
	return &DEFAULT_LAYOUT_ELEMENT_HASH_MAP_ITEM
}

@(private = "file")
updateAspectRatioBox :: proc(layoutElement: ^LayoutElement) {
	if layoutElement.config.(ElementDeclaration).aspectRatio != 0 {
		if layoutElement.dimensions.x == 0 && layoutElement.dimensions.y != 0 {
			layoutElement.dimensions.x =
				layoutElement.dimensions.y *
				f32(layoutElement.config.(ElementDeclaration).aspectRatio)
		} else if layoutElement.dimensions.x != 0 && layoutElement.dimensions.y == 0 {
			layoutElement.dimensions.y =
				layoutElement.dimensions.x *
				f32(1 / layoutElement.config.(ElementDeclaration).aspectRatio)
		}
	}
}

closeElement :: proc() {
	if s.booleanWarnings.maxElementsExceeded && s.openLayoutElementStack.len == 1 {
		return
	}
	openLayoutElement := getOpenLayoutElement()
	config := &openLayoutElement.config.(ElementDeclaration)
	elementHasClipHorizontal := config.clip.horizontal
	elementHasClipVertical := config.clip.vertical
	if elementHasClipHorizontal || elementHasClipVertical || config.floating.attachTo != .NONE {
		s.openClipElementStack.len -= 1
	}

	leftRightPadding := config.layout.padding.left + config.layout.padding.right
	topBottomPadding := config.layout.padding.top + config.layout.padding.bottom


	// Attach children to the current open element
	openLayoutElement.children.items = s.layoutElementChildren.items[s.layoutElementChildren.len:]
	openLayoutElement.children.cap = s.layoutElementChildren.cap - s.layoutElementChildren.len
	if config.layout.direction == .LEFT_TO_RIGHT {
		openLayoutElement.dimensions.x = leftRightPadding
		openLayoutElement.minDimensions.x = leftRightPadding
		for i in 0 ..< openLayoutElement.children.len {
			childIdx := arrayGet(
				s.layoutElementChildrenBuffer,
				s.layoutElementChildrenBuffer.len - openLayoutElement.children.len + i,
			)
			child := arrayGetPtr(&s.layoutElements, childIdx)
			openLayoutElement.dimensions.x += child.dimensions.x
			openLayoutElement.dimensions.y = max(
				openLayoutElement.dimensions.y,
				child.dimensions.y + topBottomPadding,
			)
			// Minimum size of child elements doesn't matter to clip containers as they can shrink and hide their contents
			if !elementHasClipHorizontal {
				openLayoutElement.minDimensions.x += child.minDimensions.x
			}
			if !elementHasClipVertical {
				openLayoutElement.minDimensions.y = max(
					openLayoutElement.minDimensions.y,
					child.minDimensions.y + topBottomPadding,
				)
			}
			arrayPush(&s.layoutElementChildren, childIdx)
		}
		childGap := f32(max(openLayoutElement.children.len - 1, 0)) * config.layout.childGap
		openLayoutElement.dimensions.x += childGap
		if !elementHasClipHorizontal {
			openLayoutElement.minDimensions.x += childGap
		}
	} else if config.layout.direction == .TOP_TO_BOTTOM {
		openLayoutElement.dimensions.y = topBottomPadding
		openLayoutElement.minDimensions.y = topBottomPadding

		for i in 0 ..< openLayoutElement.children.len {
			childIdx := arrayGet(
				s.layoutElementChildrenBuffer,
				s.layoutElementChildrenBuffer.len - openLayoutElement.children.len + i,
			)
			child := arrayGetPtr(&s.layoutElements, childIdx)
			openLayoutElement.dimensions.y += child.dimensions.y
			openLayoutElement.dimensions.x = max(
				openLayoutElement.dimensions.x,
				child.dimensions.x + leftRightPadding,
			)
			if !elementHasClipVertical {
				openLayoutElement.minDimensions.y += child.minDimensions.y
			}
			if !elementHasClipHorizontal {
				openLayoutElement.minDimensions.x = max(
					openLayoutElement.minDimensions.x,
					child.minDimensions.x + leftRightPadding,
				)
			}
			arrayPush(&s.layoutElementChildren, childIdx)
		}
		childGap := f32(max(openLayoutElement.children.len - 1, 0)) * config.layout.childGap
		openLayoutElement.dimensions.y += childGap
		if !elementHasClipVertical {
			openLayoutElement.minDimensions.y += childGap
		}
	}
	s.layoutElementChildrenBuffer.len -= openLayoutElement.children.len

	// Clamp element min and max height to the values configured in the layout
	if config.layout.sizing.width.type != .PERCENT {
		if config.layout.sizing.width.value == nil {
			config.layout.sizing.width.value = SizingMinMax{}
		}
		if config.layout.sizing.width.value.(SizingMinMax).max <= 0 {
			width := config.layout.sizing.width.value.(SizingMinMax)
			width.max = MAX_FLOAT
			config.layout.sizing.width.value = width
		}
		openLayoutElement.dimensions.x = min(
			max(
				openLayoutElement.dimensions.x,
				config.layout.sizing.width.value.(SizingMinMax).min,
			),
			config.layout.sizing.width.value.(SizingMinMax).max,
		)
		openLayoutElement.minDimensions.x = min(
			max(
				openLayoutElement.minDimensions.x,
				config.layout.sizing.width.value.(SizingMinMax).min,
			),
			config.layout.sizing.width.value.(SizingMinMax).max,
		)
	} else {
		openLayoutElement.dimensions.x = 0
	}

	if config.layout.sizing.height.type != .PERCENT {
		if config.layout.sizing.height.value == nil {
			config.layout.sizing.height.value = SizingMinMax{}
		}
		if config.layout.sizing.height.value.(SizingMinMax).max <= 0 {
			height := config.layout.sizing.height.value.(SizingMinMax)
			height.max = MAX_FLOAT
			config.layout.sizing.height.value = height
		}
		openLayoutElement.dimensions.y = min(
			max(
				openLayoutElement.dimensions.y,
				config.layout.sizing.height.value.(SizingMinMax).min,
			),
			config.layout.sizing.height.value.(SizingMinMax).max,
		)
		openLayoutElement.minDimensions.y = min(
			max(
				openLayoutElement.minDimensions.y,
				config.layout.sizing.height.value.(SizingMinMax).min,
			),
			config.layout.sizing.height.value.(SizingMinMax).max,
		)
	} else {
		openLayoutElement.dimensions.y = 0
	}
	updateAspectRatioBox(openLayoutElement)

	elementIsFloating := config.floating.attachTo != .NONE

	// Close current element
	closingElementIdx := arrayPop(&s.openLayoutElementStack)
	openLayoutElement = getOpenLayoutElement()

	if s.openLayoutElementStack.len > 1 { 	// > 1 due to default root
		if elementIsFloating {
			openLayoutElement.floatingChildrenCount += 1
			return
		}
		openLayoutElement.children.len += 1
		arrayPush(&s.layoutElementChildrenBuffer, closingElementIdx)
	}
}

// TODO SIMD
@(private = "file")
memCmp :: proc(s1, s2: []byte, length: int) -> bool {
	for i in 0 ..< length {
		if s1[i] != s2[i] {
			return false
		}
	}
	return true
}

openElement :: proc() {
	if s.layoutElements.len == s.layoutElements.cap - 1 || s.booleanWarnings.maxElementsExceeded {
		s.booleanWarnings.maxElementsExceeded = true
		return
	}
	layoutElement: LayoutElement = {}
	openLayoutElement := arrayPush(&s.layoutElements, layoutElement)
	arrayPush(&s.openLayoutElementStack, s.layoutElements.len - 1)
	// Generate an ID
	parentElement := arrayGetPtr(
		&s.layoutElements,
		arrayGet(s.openLayoutElementStack, s.openLayoutElementStack.len - 2),
	)
	offset := parentElement.children.len + int(parentElement.floatingChildrenCount)
	elementId := hashNumber(u32(offset), parentElement.id)
	openLayoutElement.id = elementId.id
	addHashMapItem(elementId, openLayoutElement)
	arrayPush(&s.layoutElementIdStrings, elementId.stringId)

	if s.openClipElementStack.len > 0 {
		arraySet(
			&s.layoutElementClipElementIds,
			s.layoutElements.len - 1,
			arrayPeek(s.openClipElementStack),
		)
	} else {
		arraySet(&s.layoutElementClipElementIds, s.layoutElements.len - 1, 0)
	}
}

openElementWithId :: proc(elementId: ElementID) {
	if s.layoutElements.len == s.layoutElements.cap - 1 || s.booleanWarnings.maxElementsExceeded {
		s.booleanWarnings.maxElementsExceeded = true
		return
	}
	layoutElement: LayoutElement = {}
	layoutElement.id = elementId.id
	openLayoutElement := arrayPush(&s.layoutElements, layoutElement)
	arrayPush(&s.openLayoutElementStack, s.layoutElements.len - 1)
	addHashMapItem(elementId, openLayoutElement)
	arrayPush(&s.layoutElementIdStrings, elementId.stringId)
	if s.openClipElementStack.len > 0 {
		arraySet(
			&s.layoutElementClipElementIds,
			s.layoutElements.len - 1,
			arrayPeek(s.openClipElementStack),
		)
	} else {
		arraySet(&s.layoutElementClipElementIds, s.layoutElements.len - 1, 0)
	}
}

@(private = "file")
openTextElement :: proc(text: string, config: TextElementConfig) {
	if s.layoutElements.len == s.layoutElements.cap - 1 || s.booleanWarnings.maxElementsExceeded {
		s.booleanWarnings.maxElementsExceeded = true
		return
	}

	parentElement := getOpenLayoutElement()

	layoutElement := LayoutElement {
		config = TextDeclaration{config = config},
	}
	textElement := arrayPush(&s.layoutElements, layoutElement)
	if s.openClipElementStack.len > 0 {
		arraySet(
			&s.layoutElementClipElementIds,
			s.layoutElements.len - 1,
			arrayPeek(s.openClipElementStack),
		)
	} else {
		arraySet(&s.layoutElementClipElementIds, s.layoutElements.len - 1, 0)
	}

	arrayPush(&s.layoutElementChildrenBuffer, s.layoutElements.len - 1)
	textMeasured := measureTextCached(text, config)
	elementId := hashNumber(
		u32(parentElement.children.len) + u32(parentElement.floatingChildrenCount),
		parentElement.id,
	)
	textElement.id = elementId.id
	addHashMapItem(elementId, textElement)
	arrayPush(&s.layoutElementIdStrings, elementId.stringId)
	textDimensions := [2]f32 {
		textMeasured.unwrappedDimension.x,
		config.lineHeight > 0 ? config.lineHeight : textMeasured.unwrappedDimension.y,
	}
	textElement.dimensions = textDimensions
	textElement.minDimensions = {textMeasured.minWidth, textDimensions.y}
	config := &textElement.config.(TextDeclaration)
	config.data = TextElementData {
		text                = text,
		preferredDimensions = textMeasured.unwrappedDimension,
	}
	parentElement.children.len += 1
}

configureOpenElement :: proc(declaration: ElementDeclaration) -> bool {
	openLayoutElement := getOpenLayoutElement()
	openLayoutElement.config = declaration
	config := &openLayoutElement.config.(ElementDeclaration)
	if (declaration.layout.sizing.width.type == .PERCENT &&
		   declaration.layout.sizing.width.value.(Percent) > 1) ||
	   (declaration.layout.sizing.height.type == .PERCENT &&
			   declaration.layout.sizing.height.value.(Percent) > 1) {
		s.errorHandler.errProc(
			ErrorData {
				type = .PERCENTAGE_OVER_1,
				text = "An element was configured with PERCENT sizing, but the provided percentage value was over 1.0. Claydo expects a value between 0 and 1, i.e. 20% is 0.2.",
				userPtr = s.errorHandler.userPtr,
			},
		)
	}
	if declaration.floating.attachTo != .NONE {
		floatingConfig := &config.floating
		hierarchicalParent := arrayGetPtr(
			&s.layoutElements,
			arrayGet(s.openLayoutElementStack, s.openLayoutElementStack.len - 2),
		)
		if hierarchicalParent != nil {
			clipElementId := 0
			if declaration.floating.attachTo == .PARENT {
				// attach to direct hierarchical parent
				floatingConfig.parentId = hierarchicalParent.id
				if s.openClipElementStack.len > 0 {
					clipElementId = arrayGet(
						s.openClipElementStack,
						s.openClipElementStack.len - 1,
					)
				}
			} else if declaration.floating.attachTo == .ELEMENT_WITH_ID {
				parentItem := getHashMapItem(floatingConfig.parentId)
				if parentItem == &DEFAULT_LAYOUT_ELEMENT_HASH_MAP_ITEM {
					s.errorHandler.errProc(
						ErrorData {
							type = .FLOATING_CONTAINER_PARENT_NOT_FOUND,
							text = "A floating element was declared with a parentId, but no element with that ID was found.",
							userPtr = s.errorHandler.userPtr,
						},
					)
				} else {
					clipElementId = arrayGet(
						s.layoutElementClipElementIds,
						intrinsics.ptr_sub(parentItem.layoutElement, &s.layoutElements.items[0]),
					)
				}
			} else if declaration.floating.attachTo == .ROOT {
				floatingConfig.parentId = hashString("Clay__RootContainer", 0).id
			}
			if declaration.floating.clipTo == .NONE {
				clipElementId = 0
			}
			currentElementIdx := arrayPeek(s.openLayoutElementStack)
			arraySet(&s.layoutElementClipElementIds, currentElementIdx, clipElementId)
			arrayPush(&s.openClipElementStack, clipElementId)
			arrayPush(
				&s.layoutElementTreeRoots,
				LayoutElementTreeRoot {
					layoutElementIdx = arrayPeek(s.openLayoutElementStack),
					parentId = floatingConfig.parentId,
					clipElementId = u32(clipElementId),
					zIdx = floatingConfig.zIdx,
				},
			)
		}
	}
	if declaration.clip.horizontal || declaration.clip.vertical {
		arrayPush(&s.openClipElementStack, int(openLayoutElement.id))
		scrollOffset: ^ScrollContainerDataInternal = nil
		for &mapping in arrayIter(s.scrollContainerDatas) {
			if openLayoutElement.id == mapping.elementId {
				scrollOffset = &mapping
				scrollOffset.layoutElement = mapping.layoutElement
				scrollOffset.openThisFrame = true
			}
		}
		if scrollOffset == nil {
			scrollOffset = arrayPush(
				&s.scrollContainerDatas,
				ScrollContainerDataInternal {
					layoutElement = openLayoutElement,
					scrollOrigin = {-1, -1},
					elementId = openLayoutElement.id,
					openThisFrame = true,
				},
			)
		}
		if s.externalScrollHandlingEnabled {
			scrollOffset.scrollPosition = s.queryScrollOffset(
				scrollOffset.elementId,
				s.queryScrollOffsetUserPtr,
			)
		}
	}
	if declaration.transition.handler != nil {
		// Setup data to track transitions across frames
		transitionData: ^TransitionDataInternal = {}
		parentElement := getParentElement()
		for &existingData in arrayIter(s.transitionDatas) {
			if (openLayoutElement.id == existingData.elementId) {
				if (existingData.state == .EXITING) {
					existingData.state = .IDLE
					hashMapItem := getHashMapItem(openLayoutElement.id)
					hashMapItem.appearedThisFrame = false
				}
				transitionData = &existingData
				transitionData.elementThisFrame = openLayoutElement
				if transitionData.parentId != parentElement.id {
					transitionData.reparented = true
				}
				transitionData.parentId = parentElement.id
				transitionData.siblingIdx = u32(parentElement.children.len)
				transitionData.transitionOut = declaration.transition.exit.setFinalState != nil
			}
		}
		if transitionData == nil {
			transitionData = arrayPush(
				&s.transitionDatas,
				TransitionDataInternal {
					elementThisFrame = openLayoutElement,
					elementId = openLayoutElement.id,
					parentId = parentElement.id,
					siblingIdx = u32(parentElement.children.len),
					transitionOut = declaration.transition.exit.setFinalState != nil,
				},
			)
		}
	}
	return true
}

// TODO just clear instead of re-initializing
@(private = "file")
initializeEphemeralMemory :: proc(s: ^State) {
	maxElementCount := s.maxElementCount
	// TODO don't need to zero
	virtual.arena_static_reset_to(&s.arenaInternal, s.arenaResetPoint)
	s.layoutElementChildrenBuffer = arrayCreate(int, maxElementCount, s.arena)
	s.layoutElements = arrayCreate(LayoutElement, maxElementCount, s.arena)
	s.warnings = arrayCreate(Warning, 100, s.arena)

	s.layoutElementIdStrings = arrayCreate(string, maxElementCount, s.arena)
	s.wrappedTextLines = arrayCreate(WrappedTextLine, maxElementCount, s.arena)
	s.layoutElementTreeNodes = arrayCreate(LayoutElementTreeNode, maxElementCount, s.arena)
	s.layoutElementTreeRoots = arrayCreate(LayoutElementTreeRoot, maxElementCount, s.arena)
	s.layoutElementChildren = arrayCreate(int, maxElementCount, s.arena)
	s.openLayoutElementStack = arrayCreate(int, maxElementCount, s.arena)
	s.renderCommands = arrayCreate(RenderCommand, maxElementCount, s.arena)
	s.treeNodeVisited = arrayCreate(bool, maxElementCount, s.arena)
	s.treeNodeVisited.len = s.treeNodeVisited.cap
	s.openClipElementStack = arrayCreate(int, maxElementCount, s.arena)
	s.reusableElementIdxBuffer = arrayCreate(int, maxElementCount, s.arena)
	s.layoutElementClipElementIds = arrayCreate(int, maxElementCount, s.arena)
	s.dynamicStringData = arrayCreate(byte, maxElementCount, s.arena)
}

@(private = "file")
initializePersistentMemory :: proc(s: ^State) {
	maxElementCount := s.maxElementCount
	maxMaxMeasureTextCacheWordCount := s.maxMeasureTextCacheWordCount
	s.scrollContainerDatas = arrayCreate(ScrollContainerDataInternal, 100, s.arena)
	s.transitionDatas = arrayCreate(TransitionDataInternal, 100, s.arena)
	s.layoutElementsHashMapInternal = arrayCreate(
		LayoutElementHashMapItem,
		maxElementCount,
		s.arena,
	)
	s.layoutElementsHashMap = arrayCreate(int, maxElementCount, s.arena)
	s.measureTextHashMap = arrayCreate(int, maxElementCount, s.arena)
	s.measureTextHashMapInternal = arrayCreate(MeasureTextCacheItem, maxElementCount, s.arena)
	s.measureTextHashMapInternalFreeList = arrayCreate(int, maxElementCount, s.arena)
	s.measuredWordsFreeList = arrayCreate(int, maxElementCount, s.arena)
	s.measuredWords = arrayCreate(MeasuredWord, maxMaxMeasureTextCacheWordCount, s.arena)
	s.pointerOverIds = arrayCreate(ElementID, maxElementCount, s.arena)
	s.debugElementData = arrayCreate(DebugElementData, maxElementCount, s.arena)
}

@(private = "file")
sizeContainersAlongAxis :: proc(
	xAxis: bool,
	deltaTime: f32,
	textElementsOut: ^Array(int),
	aspectRatioElementsOut: ^Array(int),
) {
	bfsBuffer := s.layoutElementChildrenBuffer
	resizableContainerBuffer := s.openLayoutElementStack
	for &root in arrayIter(s.layoutElementTreeRoots) {
		bfsBuffer.len = 0
		rootElement := arrayGetPtr(&s.layoutElements, root.layoutElementIdx)
		config := rootElement.config.(ElementDeclaration)
		arrayPush(&bfsBuffer, root.layoutElementIdx)
		if config.floating.attachTo != .NONE {
			floatingElementConfig := &config.floating
			parentItem := getHashMapItem(floatingElementConfig.parentId)
			if parentItem != nil && parentItem != &DEFAULT_LAYOUT_ELEMENT_HASH_MAP_ITEM {
				parentLayoutElement := parentItem.layoutElement
				#partial switch config.layout.sizing.width.type {
				case .GROW:
					{
						rootElement.dimensions.x = parentLayoutElement.dimensions.x
					}
				case .PERCENT:
					{
						rootElement.dimensions.x =
							parentLayoutElement.dimensions.x *
							f32(config.layout.sizing.width.value.(Percent))
					}
				}

				#partial switch config.layout.sizing.height.type {
				case .GROW:
					{
						rootElement.dimensions.y = parentLayoutElement.dimensions.y
					}
				case .PERCENT:
					{
						rootElement.dimensions.y =
							parentLayoutElement.dimensions.y *
							f32(config.layout.sizing.height.value.(Percent))
					}
				}
			}
		}
		if config.layout.sizing.width.type != .PERCENT {
			rootElement.dimensions.x = min(
				max(rootElement.dimensions.x, config.layout.sizing.width.value.(SizingMinMax).min),
				config.layout.sizing.width.value.(SizingMinMax).max,
			)
		}
		if config.layout.sizing.height.type != .PERCENT {
			rootElement.dimensions.y = min(
				max(
					rootElement.dimensions.y,
					config.layout.sizing.height.value.(SizingMinMax).min,
				),
				config.layout.sizing.height.value.(SizingMinMax).max,
			)
		}
		for i := 0; i < bfsBuffer.len; i += 1 {
			parentIdx := arrayGet(bfsBuffer, i)
			parent := arrayGetPtr(&s.layoutElements, parentIdx)
			parentLayout := parent.config.(ElementDeclaration).layout
			growContainerCount := 0
			parentSize := xAxis ? parent.dimensions.x : parent.dimensions.y
			parentPadding :=
				xAxis ? parentLayout.padding.left + parentLayout.padding.right : parentLayout.padding.top + parentLayout.padding.bottom
			innerContentSize: f32 = 0
			totalPaddingAndChildGaps := parentPadding
			sizingAlongAxis :=
				(xAxis && parentLayout.direction == .LEFT_TO_RIGHT) ||
				(!xAxis && parentLayout.direction == .TOP_TO_BOTTOM)
			resizableContainerBuffer.len = 0
			parentChildGap := parentLayout.childGap
			isFirstChild := true
			for childElementIndex, childOffset in arrayIter(parent.children) {
				childElement := arrayGetPtr(&s.layoutElements, childElementIndex)
				childConfig, isLayout := childElement.config.(ElementDeclaration)
				childSizing: SizingType
				childSizing =
					isLayout ? (xAxis ? childConfig.layout.sizing.width.type : childConfig.layout.sizing.height.type) : .FIT
				childSize := xAxis ? childElement.dimensions.x : childElement.dimensions.y

				// If the child has children, add it to the buffer to process
				if textElementsOut != nil && !isLayout {
					arrayPush(textElementsOut, childElementIndex)
				} else if childElement.children.len > 0 {
					arrayPush(&bfsBuffer, childElementIndex)
				}

				if isLayout && aspectRatioElementsOut != nil && childConfig.aspectRatio > 0 {
					arrayPush(aspectRatioElementsOut, childElementIndex)
				}

				// Setting isFirstChild = false is skipped
				if childElement.exiting {
					continue
				}

				if childSizing != .PERCENT &&
				   childSizing != .FIXED &&
				   (isLayout ||
						   childElement.config.(TextDeclaration).config.wrapMode == .WRAP_WORDS) {
					arrayPush(&resizableContainerBuffer, childElementIndex)
				}

				if sizingAlongAxis {
					innerContentSize += (childSizing == .PERCENT ? 0 : childSize)
					if childSizing == .GROW {
						growContainerCount += 1
					}
					if !isFirstChild {
						innerContentSize += parentChildGap // after 0, offset is the is the gap to the previous child
						totalPaddingAndChildGaps += parentChildGap
					}
				} else {
					innerContentSize = max(childSize, innerContentSize)
				}
				isFirstChild = false
			}
			for childElementIndex, childOffset in arrayIter(parent.children) {
				childElement := arrayGetPtr(&s.layoutElements, childElementIndex)
				childConfig, isLayout := childElement.config.(ElementDeclaration)
				childSizing :=
					isLayout ? (xAxis ? childConfig.layout.sizing.width : childConfig.layout.sizing.height) : sizingFit()
				childSize := xAxis ? &(childElement.dimensions.x) : &(childElement.dimensions.y)
				if childSizing.type == .PERCENT {
					childSize^ =
						(parentSize - totalPaddingAndChildGaps) * f32(childSizing.value.(Percent))
					if sizingAlongAxis {
						innerContentSize += childSize^
					}
					updateAspectRatioBox(childElement)
				}
			}
			if sizingAlongAxis {

				sizeToDistribute := parentSize - parentPadding - innerContentSize
				// content is too large, compress children as much as possible
				if sizeToDistribute < 0 {
					config, isLayout := parent.config.(ElementDeclaration)
					if isLayout &&
					   ((xAxis && config.clip.horizontal) || (!xAxis && config.clip.vertical)) {
						continue
					}
					for sizeToDistribute < -EPSILON && resizableContainerBuffer.len > 0 {
						largest: f32 = 0
						secondLargest: f32 = 0
						widthToAdd := sizeToDistribute
						for childIdx in arrayIter(resizableContainerBuffer) {
							child := arrayGetPtr(&s.layoutElements, childIdx)
							childSize := xAxis ? child.dimensions.x : child.dimensions.y
							if childSize > parent.dimensions.x {
							}
							if floatEquals(childSize, largest) {
								continue
							}
							if childSize > largest {
								secondLargest = largest
								largest = childSize
							}
							if childSize < largest {
								secondLargest = max(secondLargest, childSize)
								widthToAdd = secondLargest - largest
							}
						}

						widthToAdd = max(
							widthToAdd,
							sizeToDistribute / f32(resizableContainerBuffer.len),
						)
						for childIdx := 0; childIdx < resizableContainerBuffer.len; childIdx += 1 {
							child := arrayGetPtr(
								&s.layoutElements,
								arrayGet(resizableContainerBuffer, childIdx),
							)
							childSize := xAxis ? &child.dimensions.x : &child.dimensions.y
							minSize := xAxis ? child.minDimensions.x : child.minDimensions.y
							previousWidth := childSize^
							if childSize^ == largest {
								childSize^ += widthToAdd
								if childSize^ <= minSize {
									childSize^ = minSize
									arraySwapback(&resizableContainerBuffer, childIdx)
									childIdx -= 1
								}
								sizeToDistribute -= (childSize^ - previousWidth)
							}
						}
					}
					// content is too small, expand to fit container
				} else if sizeToDistribute > 0 && growContainerCount > 0 {
					for childIdx := 0; childIdx < resizableContainerBuffer.len; childIdx += 1 {
						child := arrayGetPtr(
							&s.layoutElements,
							arrayGet(resizableContainerBuffer, childIdx),
						)
						config, isLayout := child.config.(ElementDeclaration)
						childSizing :=
							isLayout ? (xAxis ? config.layout.sizing.width.type : config.layout.sizing.height.type) : .FIT
						if childSizing != .GROW {
							arraySwapback(&resizableContainerBuffer, childIdx)
							childIdx -= 1
						}
					}
					for sizeToDistribute > EPSILON && resizableContainerBuffer.len > 0 {
						smallest := MAX_FLOAT
						secondSmallest := MAX_FLOAT
						widthToAdd := sizeToDistribute
						for childIdx in arrayIter(resizableContainerBuffer) {
							child := arrayGetPtr(&s.layoutElements, childIdx)
							childSize := xAxis ? child.dimensions.x : child.dimensions.y
							if childSize == smallest {
								continue
							}
							if childSize < smallest {
								secondSmallest = smallest
								smallest = childSize
							}
							if childSize > smallest {
								secondSmallest = min(secondSmallest, childSize)
								widthToAdd = secondSmallest - smallest
							}
						}
						widthToAdd = min(
							widthToAdd,
							sizeToDistribute / f32(resizableContainerBuffer.len),
						)

						for childIdx := 0; childIdx < resizableContainerBuffer.len; childIdx += 1 {
							child := arrayGetPtr(
								&s.layoutElements,
								arrayGet(resizableContainerBuffer, childIdx),
							)
							childSize := xAxis ? &child.dimensions.x : &child.dimensions.y
							maxSize :=
								xAxis ? config.layout.sizing.width.value.(SizingMinMax).max : config.layout.sizing.height.value.(SizingMinMax).max
							previousWidth := childSize^
							if childSize^ == smallest {
								childSize^ += widthToAdd
								if childSize^ >= maxSize {
									childSize^ = maxSize
									arraySwapback(&resizableContainerBuffer, childIdx)
									childIdx -= 1
								}
								sizeToDistribute -= (childSize^ - previousWidth)
							}
						}
					}
				}
				// Sizing off-axis
			} else {
				for childOffset in arrayIter(resizableContainerBuffer) {
					childElement := arrayGetPtr(&s.layoutElements, childOffset)
					config, isLayout := childElement.config.(ElementDeclaration)
					childSizing :=
						isLayout ? (xAxis ? config.layout.sizing.width : config.layout.sizing.height) : sizingFit()
					minSize := xAxis ? childElement.minDimensions.x : childElement.minDimensions.y
					childSize := xAxis ? &childElement.dimensions.x : &childElement.dimensions.y
					maxSize := parentSize - parentPadding
					// if laying out children of scroll panel grow containers expand to inner content not outer container
					parentConfig := parent.config.(ElementDeclaration)
					if (xAxis && parentConfig.clip.horizontal) ||
					   (!xAxis && parentConfig.clip.vertical) {
						maxSize = max(maxSize, innerContentSize)
					}
					if childSizing.type == .GROW {
						childSize^ = min(maxSize, childSizing.value.(SizingMinMax).max)
					}
					childSize^ = max(minSize, min(childSize^, maxSize))
				}
			}
		}
	}
}


@(private = "file")
intToString :: proc(integer: int) -> string {
	integer := integer
	if integer == 0 {
		return "0"
	}
	chars := s.dynamicStringData.items[s.dynamicStringData.len:]
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
	s.dynamicStringData.len += length
	return string(chars[:length])
}

@(private = "file")
pushRenderCommand :: proc(renderCommand: RenderCommand) {
	if s.renderCommands.len < s.renderCommands.cap - 1 {
		arrayPush(&s.renderCommands, renderCommand)
	} else {
		if !s.booleanWarnings.maxRenderCommandsExceeded {
			s.booleanWarnings.maxRenderCommandsExceeded = true
			s.errorHandler.errProc(
				ErrorData {
					type = .ELEMENTS_CAPACITY_EXCEEDED,
					text = "Claydo ran out of capacity while attempting to create render commands. This is usually caused by a large amount of wrapping text elements while close to the max element capacity. Try using setMaxElementCount() with a higher value.",
					userPtr = s.errorHandler.userPtr,
				},
			)
		}
	}
}

@(private = "file")
elementIsOffscreen :: proc(boundingBox: ^BoundingBox) -> bool {
	if s.disableCulling {
		return false
	}
	return(
		(boundingBox.x > s.layoutDimensions.x) ||
		(boundingBox.y > s.layoutDimensions.y) ||
		(boundingBox.x + boundingBox.width < 0) ||
		(boundingBox.y + boundingBox.height < 0) \
	)
}

@(private = "file")
createTransitionDataForElement :: proc(
	boundingBox: ^BoundingBox,
	layoutElement: ^LayoutElement,
) -> TransitionData {
	return TransitionData {
		boundingBox = boundingBox^,
		color = layoutElement.config.(ElementDeclaration).backgroundColor,
		overlayColor = layoutElement.config.(ElementDeclaration).overlayColor,
	}
}

@(private = "file")
shouldTransition :: proc(current: ^TransitionData, target: ^TransitionData) -> bool {
	if !floatEquals(current.boundingBox.x, target.boundingBox.x) ||
	   !floatEquals(current.boundingBox.y, target.boundingBox.y) ||
	   !floatEquals(current.boundingBox.width, target.boundingBox.width) ||
	   !floatEquals(current.boundingBox.height, target.boundingBox.height) {
		return true
	}
	if current.color != target.color {
		return true
	}
	if current.overlayColor != target.overlayColor {
		return true
	}
	return false
}

@(private = "file")
cloneElementsWithExitTransition :: proc() {
	nextIndex := s.layoutElements.cap - 1
	nextChildIndex := s.layoutElementChildren.cap - 1

	for &data in arrayIter(s.transitionDatas) {
		config := &(data.elementThisFrame.config.(ElementDeclaration))
		if data.transitionOut {
			bfsBuffer := s.openLayoutElementStack
			bfsBuffer.len = 0
			newElement := arraySet(&s.layoutElements, nextIndex, data.elementThisFrame^)
			arraySet(
				&s.layoutElementIdStrings,
				nextIndex,
				arrayGet(
					s.layoutElementIdStrings,
					intrinsics.ptr_sub(data.elementThisFrame, &s.layoutElements.items[0]),
				),
			)
			arrayPush(&bfsBuffer, nextIndex)
			data.elementThisFrame = newElement
			nextIndex -= 1

			bufferIndex := 0
			for bufferIndex < bfsBuffer.len {
				layoutElement := arrayGetPtr(&s.layoutElements, arrayGet(bfsBuffer, bufferIndex))
				bufferIndex += 1
				for j := layoutElement.children.len - 1; j >= 0; j -= 1 {
					childElement := arrayGetPtr(&s.layoutElements, layoutElement.children.items[j])
					arrayPush(&bfsBuffer, nextIndex)
					newChildElement := arraySet(&s.layoutElements, nextIndex, childElement^)
					arraySet(
						&s.layoutElementIdStrings,
						nextIndex,
						arrayGet(
							s.layoutElementIdStrings,
							intrinsics.ptr_sub(childElement, &s.layoutElements.items[0]),
						),
					)
					arraySet(&s.layoutElementChildren, nextChildIndex, nextIndex)
					nextIndex -= 1
					nextChildIndex -= 1
				}
				layoutElement.children.items = s.layoutElementChildren.items[nextChildIndex + 1:]
			}
		}
	}
}

@(private = "file")
updateElementWithTransitionData :: proc(
	boundingBox: ^BoundingBox,
	layoutElement: ^LayoutElement,
	data: ^TransitionData,
) {
	boundingBox^ = data.boundingBox
	config := &(layoutElement.config.(ElementDeclaration))
	config.backgroundColor = data.color
	config.overlayColor = data.overlayColor
}

@(private = "file")
calculateFinalLayout :: proc(
	deltaTime: f32,
	useStoredBoundingBoxes: bool,
	generateRenderCommands: bool,
) {

	// calculate sizing along x axis
	// using clip element stack as it's available
	textElements := s.openClipElementStack
	textElements.len = 0
	aspectRatioElements := s.reusableElementIdxBuffer
	aspectRatioElements.len = 0
	sizeContainersAlongAxis(true, deltaTime, &textElements, &aspectRatioElements)

	// Wrap text
	// loop through each text element in the layout
	for &textElementIdx in arrayIter(textElements) {

		// set the wrappedLines array to the end of the state's wrappedTextLines array
		element := arrayGetPtr(&s.layoutElements, textElementIdx)
		textElementData := &(&element.config.(TextDeclaration)).data
		textElementData.wrappedLines.items = s.wrappedTextLines.items[s.wrappedTextLines.len:]
		textElementData.wrappedLines.cap = s.wrappedTextLines.cap - s.wrappedTextLines.len
		textElementData.wrappedLines.len = 0

		// get the container and measure the text
		containerElement := arrayGetPtr(&s.layoutElements, textElementIdx)
		textConfig := containerElement.config.(TextDeclaration).config

		measureTextCacheItem := measureTextCached(textElementData.text, textConfig)
		lineWidth: f32 = 0
		lineHeight :=
			textConfig.lineHeight > 0 ? textConfig.lineHeight : textElementData.preferredDimensions.y
		lineLengthChars := 0
		lineStartOffset := 0

		// There are no newlines in the item, and it fits inside the container
		if !measureTextCacheItem.containsNewLines &&
		   textElementData.preferredDimensions.x <= containerElement.dimensions.x {
			arrayPush(
				&s.wrappedTextLines,
				WrappedTextLine {
					dimensions = containerElement.dimensions,
					text = textElementData.text,
				},
			)
			// We increment the lenth here because textElementData.wrappedLines is backed by the global store
			textElementData.wrappedLines.len += 1
			continue
		}
		spaceWidth := s.measureText(" ", textConfig, s.measureTextUserPtr).x

		// get the index of the cached measuredWord for the first word
		wordIdx := measureTextCacheItem.measuredWordsStartIdx
		for wordIdx != -1 {
			// Can't store any more wrapped text
			if s.wrappedTextLines.len > s.wrappedTextLines.cap - 1 {
				break
			}
			measuredWord := arrayGetPtr(&s.measuredWords, wordIdx)
			// if the only word on the line is too large, render it anyway
			if lineLengthChars == 0 &&
			   lineWidth + measuredWord.width > containerElement.dimensions.x {
				// We push a wrapped line onto the global array, but the backing data is from textElementData
				arrayPush(
					&s.wrappedTextLines,
					WrappedTextLine {
						dimensions = {measuredWord.width, lineHeight},
						text = string(
							textElementData.text[measuredWord.startOffset:][:measuredWord.length],
						),
					},
				)
				// increment wrappedLines length since it is backed by the global array
				textElementData.wrappedLines.len += 1
				// Move on to the next word
				wordIdx = measuredWord.next
				lineStartOffset = measuredWord.startOffset + measuredWord.length
				// measuredWord.length == 0 means new line. (or the measured width is too large)
			} else if measuredWord.length == 0 ||
			   lineWidth + measuredWord.width > containerElement.dimensions.x {
				// if wrapped text lines list has overflowed, just render out the line
				finalCharIsSpace :=
					textElementData.text[max(lineStartOffset + lineLengthChars - 1, 0)] == ' '
				arrayPush(
					&s.wrappedTextLines,
					WrappedTextLine {
						dimensions = {
							lineWidth + (finalCharIsSpace ? -spaceWidth : 0),
							lineHeight,
						},
						text = string(
							textElementData.text[lineStartOffset:][:lineLengthChars +
							(finalCharIsSpace ? -1 : 0)],
						),
					},
				)
				textElementData.wrappedLines.len += 1
				if lineLengthChars == 0 || measuredWord.length == 0 {
					wordIdx = measuredWord.next
				}
				// reset for new line
				lineWidth = 0
				lineLengthChars = 0
				lineStartOffset = measuredWord.startOffset
				// fits on the line
			} else {
				lineWidth += measuredWord.width + textConfig.spacing
				lineLengthChars += measuredWord.length
				wordIdx = measuredWord.next
			}
		}
		// push the remaining characters
		if lineLengthChars > 0 {
			arrayPush(
				&s.wrappedTextLines,
				WrappedTextLine {
					dimensions = {lineWidth - textConfig.spacing, lineHeight},
					text = textElementData.text[lineStartOffset:lineStartOffset + lineLengthChars],
				},
			)
			textElementData.wrappedLines.len += 1
		}
		containerElement.dimensions.y = lineHeight * f32(textElementData.wrappedLines.len)
	}

	// scale vertical heights according to aspect ratio
	for aspectRatioElementIdx in arrayIter(aspectRatioElements) {
		aspectElement := arrayGetPtr(&s.layoutElements, aspectRatioElementIdx)
		config := &aspectElement.config.(ElementDeclaration)
		aspectElement.dimensions.y = f32(1.0 / config.aspectRatio) * aspectElement.dimensions.x
		minMaxSizing := &config.layout.sizing.height.value.(SizingMinMax)
		minMaxSizing.max = aspectElement.dimensions.y
	}

	// propagate effect of text wrapping, aspect scalign etc. on height of parents
	dfsBuffer := s.layoutElementTreeNodes
	dfsBuffer.len = 0
	// For each tree root in the layout, add it into a depth first search buffer
	for root in arrayIter(s.layoutElementTreeRoots) {
		s.treeNodeVisited.items[dfsBuffer.len] = false
		arrayPush(
			&dfsBuffer,
			LayoutElementTreeNode {
				layoutElement = arrayGetPtr(&s.layoutElements, root.layoutElementIdx),
			},
		)
	}
	// Keep processing until the buffer is empty
	for dfsBuffer.len > 0 {
		// peek
		currentElementTreeNode := arrayGetPtr(&dfsBuffer, dfsBuffer.len - 1)
		currentElement := currentElementTreeNode.layoutElement
		if !s.treeNodeVisited.items[dfsBuffer.len - 1] {
			s.treeNodeVisited.items[dfsBuffer.len - 1] = true
			// if it's got no children or is just a text container then don't bother inspecting
			if _, isText := currentElement.config.(TextDeclaration);
			   isText || currentElement.children.len == 0 {
				dfsBuffer.len -= 1
				continue
			}
			// add the children to the DFS buffer (needs to be pushed in reverse so the that the stack traversal is in correct layout order)
			for childIdx in arrayIter(currentElement.children) {
				s.treeNodeVisited.items[dfsBuffer.len] = false
				arrayPush(
					&dfsBuffer,
					LayoutElementTreeNode {
						layoutElement = arrayGetPtr(&s.layoutElements, childIdx),
					},
				)
			}
			continue
		}
		dfsBuffer.len -= 1
		// DFS node has been visited, this is on the way back up to the root
		layoutConfig := currentElement.config.(ElementDeclaration).layout
		if layoutConfig.direction == .LEFT_TO_RIGHT {
			// resize any parent containers that have grown in height along their non layout axis
			for &childIdx in arrayIter(currentElement.children) {
				childElement := arrayGetPtr(&s.layoutElements, childIdx)
				childHeightWithPadding := max(
					childElement.dimensions.y +
					layoutConfig.padding.top +
					layoutConfig.padding.bottom,
					currentElement.dimensions.y,
				)
				currentElement.dimensions.y = min(
					max(
						childHeightWithPadding,
						layoutConfig.sizing.height.value.(SizingMinMax).min,
					),
					layoutConfig.sizing.height.value.(SizingMinMax).max,
				)
			}
		} else if layoutConfig.direction == .TOP_TO_BOTTOM {
			// resizing along the layout axis
			contentHeight := layoutConfig.padding.top + layoutConfig.padding.bottom
			for childIdx in arrayIter(currentElement.children) {
				childElement := arrayGetPtr(&s.layoutElements, childIdx)
				contentHeight += childElement.dimensions.y
			}
			contentHeight += f32(max(currentElement.children.len - 1, 0)) * layoutConfig.childGap
			currentElement.dimensions.y = min(
				max(contentHeight, layoutConfig.sizing.height.value.(SizingMinMax).min),
				layoutConfig.sizing.height.value.(SizingMinMax).max,
			)
		}
	}
	// calculate sizing along y axis
	sizeContainersAlongAxis(false, deltaTime, nil, nil)

	// scale horizontal widths according to aspect ratio
	for aspectIdx in arrayIter(aspectRatioElements) {
		aspectElement := arrayGetPtr(&s.layoutElements, aspectIdx)
		aspectElement.dimensions.x =
			f32(aspectElement.config.(ElementDeclaration).aspectRatio) * aspectElement.dimensions.y
	}

	// sort tree roots by z-index
	sortMax := s.layoutElementTreeRoots.len - 1
	for sortMax > 0 {
		for i := 0; i < sortMax; i += 1 {
			current := arrayGet(s.layoutElementTreeRoots, i)
			next := arrayGet(s.layoutElementTreeRoots, i + 1)
			if next.zIdx < current.zIdx {
				arraySet(&s.layoutElementTreeRoots, i, next)
				arraySet(&s.layoutElementTreeRoots, i + 1, current)
			}
		}
		sortMax -= 1
	}

	// Calculate final positions and generate render commands
	s.renderCommands.len = 0
	dfsBuffer.len = 0
	for &root in arrayIter(s.layoutElementTreeRoots) {
		dfsBuffer.len = 0
		rootElement := arrayGetPtr(&s.layoutElements, root.layoutElementIdx)
		rootConfig, isLayout := rootElement.config.(ElementDeclaration)
		rootPosition: [2]f32
		parentHashMapItem := getHashMapItem(root.parentId)
		if isLayout && rootConfig.floating.attachTo != .NONE && parentHashMapItem != nil {
			config := rootConfig.floating
			rootDimensions := rootElement.dimensions
			parentBoundingBox := parentHashMapItem.boundingBox
			targetAttachPosition: [2]f32
			switch config.attachPoints.parent {
			case .LEFT_TOP, .LEFT_CENTER, .LEFT_BOTTOM:
				targetAttachPosition.x = parentBoundingBox.x
			case .CENTER_TOP, .CENTER_CENTER, .CENTER_BOTTOM:
				targetAttachPosition.x = parentBoundingBox.x + (parentBoundingBox.width / 2.0)
			case .RIGHT_TOP, .RIGHT_CENTER, .RIGHT_BOTTOM:
				targetAttachPosition.x = parentBoundingBox.x + parentBoundingBox.width
			}
			#partial switch config.attachPoints.element {
			case .CENTER_TOP, .CENTER_CENTER, .CENTER_BOTTOM:
				targetAttachPosition.x -= rootDimensions.x / 2.0
			case .RIGHT_TOP, .RIGHT_CENTER, .RIGHT_BOTTOM:
				targetAttachPosition.x -= rootDimensions.x
			}
			switch config.attachPoints.parent {
			case .LEFT_TOP, .RIGHT_TOP, .CENTER_TOP:
				targetAttachPosition.y = parentBoundingBox.y
			case .LEFT_CENTER, .CENTER_CENTER, .RIGHT_CENTER:
				targetAttachPosition.y = parentBoundingBox.y + (parentBoundingBox.height / 2.0)
			case .LEFT_BOTTOM, .CENTER_BOTTOM, .RIGHT_BOTTOM:
				targetAttachPosition.y = parentBoundingBox.y + parentBoundingBox.height
			}
			#partial switch config.attachPoints.element {
			case .LEFT_CENTER, .CENTER_CENTER, .RIGHT_CENTER:
				targetAttachPosition.y -= (rootDimensions.y / 2.0)
			case .LEFT_BOTTOM, .CENTER_BOTTOM, .RIGHT_BOTTOM:
				targetAttachPosition.y -= rootDimensions.y
			}
			targetAttachPosition.x += config.offset.x
			targetAttachPosition.y += config.offset.y
			rootPosition = targetAttachPosition
		}
		if root.clipElementId != 0 {
			clipHashMapItem := getHashMapItem(root.clipElementId)
			if clipHashMapItem != nil && !elementIsOffscreen(&clipHashMapItem.boundingBox) {
				if s.externalScrollHandlingEnabled {
					clipConfig := clipHashMapItem.layoutElement.config.(ElementDeclaration).clip
					if clipConfig.horizontal {
						rootPosition.x += clipConfig.childOffset.x
					}
					if clipConfig.vertical {
						rootPosition.y += clipConfig.childOffset.y
					}
				}
				if generateRenderCommands {
					pushRenderCommand(
						RenderCommand {
							boundingBox = clipHashMapItem.boundingBox,
							userPtr = nil,
							id = hashNumber(rootElement.id, u32(rootElement.children.len) + 10).id,
							zIdx = root.zIdx,
							type = .SCISSOR_START,
						},
					)
				}
			}
		}
		arrayPush(
			&dfsBuffer,
			LayoutElementTreeNode {
				layoutElement = rootElement,
				position = rootPosition,
				nextChildOffset = {rootConfig.layout.padding.left, rootConfig.layout.padding.top},
			},
		)
		s.treeNodeVisited.items[0] = false
		for dfsBuffer.len > 0 {
			currentElementTreeNode := arrayGetPtr(&dfsBuffer, dfsBuffer.len - 1)
			currentElement := currentElementTreeNode.layoutElement
			config, isLayout := &(currentElement.config.(ElementDeclaration))
			scrollOffset: [2]f32

			// DFS is returning back upwards
			if s.treeNodeVisited.items[dfsBuffer.len - 1] {
				if !isLayout {
					dfsBuffer.len -= 1
					continue
				}


				currentElementData := getHashMapItem(currentElement.id)
				if generateRenderCommands && !elementIsOffscreen(&currentElementData.boundingBox) {
					closeClipElement := false
					if isLayout && (config.clip.horizontal || config.clip.vertical) {
						closeClipElement = true
						for &mapping in arrayIter(s.scrollContainerDatas) {
							if mapping.layoutElement == currentElement {
								scrollOffset = config.clip.childOffset
								if s.externalScrollHandlingEnabled {
									scrollOffset = {}
								}
								break
							}
						}
					}
					if isLayout && borderHasAnyWidth(&config.border) {
						pushRenderCommand(
							{
								boundingBox = currentElementData.boundingBox,
								renderData = BorderRenderData {
									color = config.border.color,
									cornerRadius = config.cornerRadius,
									width = config.border.width,
								},
								userPtr = config.userPtr,
								id = hashNumber(currentElement.id, u32(currentElement.children.len)).id,
								type = .BORDER,
							},
						)
						if config.border.width.betweenChildren > 0 && config.border.color.a > 0 {
							halfGap := config.layout.childGap / 2.0
							halfWidth := config.border.width.betweenChildren / 2.0
							borderOffset := [2]f32 {
								config.layout.padding.left - halfGap,
								config.layout.padding.top - halfGap,
							}
							if config.layout.direction == .LEFT_TO_RIGHT {
								for childIdx, idx in arrayIter(currentElement.children) {
									childElement := arrayGetPtr(&s.layoutElements, childIdx)
									if idx > 0 {
										pushRenderCommand(
											{
												boundingBox = {
													currentElementData.boundingBox.x +
													borderOffset.x +
													scrollOffset.x -
													halfWidth,
													currentElementData.boundingBox.y +
													scrollOffset.y,
													config.border.width.betweenChildren,
													currentElement.dimensions.y,
												},
												renderData = RectangleRenderData {
													color = config.border.color,
												},
												userPtr = config.userPtr,
												id = hashNumber(currentElement.id, u32(currentElement.children.len + 1 + idx)).id,
												type = .RECTANGLE,
											},
										)
									}
									borderOffset.x +=
										childElement.dimensions.x + config.layout.childGap
								}
							} else {
								for childIdx, idx in arrayIter(currentElement.children) {
									childElement := arrayGetPtr(&s.layoutElements, childIdx)
									if idx > 0 {
										pushRenderCommand(
											{
												boundingBox = {
													currentElementData.boundingBox.x +
													scrollOffset.x,
													currentElementData.boundingBox.y +
													borderOffset.y +
													scrollOffset.y -
													halfWidth,
													currentElement.dimensions.x,
													config.border.width.betweenChildren,
												},
												renderData = RectangleRenderData {
													color = config.border.color,
												},
												userPtr = config.userPtr,
												id = hashNumber(currentElement.id, u32(currentElement.children.len + 1 + idx)).id,
												type = .RECTANGLE,
											},
										)
									}
									borderOffset.y +=
										childElement.dimensions.y + config.layout.childGap
								}
							}
						}
					}
					if isLayout && config.overlayColor.a > 0 {
						pushRenderCommand(
							{
								userPtr = config.userPtr,
								id = currentElement.id,
								zIdx = root.zIdx,
								type = .COLOR_OVERLAY_END,
							},
						)
					}
					if closeClipElement {
						pushRenderCommand(
							{
								id = hashNumber(currentElement.id, u32(rootElement.children.len + 11)).id,
								type = .SCISSOR_END,
							},
						)
					}
				}
				dfsBuffer.len -= 1
				continue
			}

			// This will only be run a single time for each element in downwards DFS order
			s.treeNodeVisited.items[dfsBuffer.len - 1] = true
			currentElementBoundingBox := BoundingBox {
				currentElementTreeNode.position.x,
				currentElementTreeNode.position.y,
				currentElement.dimensions.x,
				currentElement.dimensions.y,
			}
			found := false
			if isLayout && useStoredBoundingBoxes && config.transition.handler != nil {
				for &transitionData in arrayIter(s.transitionDatas) {
					if (transitionData.elementId == currentElement.id) {
						found = true
						if (transitionData.state != .IDLE) {
							if TransitionProperty.X in config.transition.properties {
								currentElementBoundingBox.x =
									transitionData.currentState.boundingBox.x
							}
							if TransitionProperty.Y in config.transition.properties {
								currentElementBoundingBox.y =
									transitionData.currentState.boundingBox.y
							}
							if TransitionProperty.WIDTH in config.transition.properties {
								currentElementBoundingBox.width =
									transitionData.currentState.boundingBox.width
							}
							if TransitionProperty.HEIGHT in config.transition.properties {
								currentElementBoundingBox.height =
									transitionData.currentState.boundingBox.height
							}
						}
						break
					}
				}
				// An exiting element that completed its transition this frame - skip tree
				if !found {
					dfsBuffer.len -= 1
					continue
				}
			}
			if isLayout && config.floating.attachTo != .NONE {
				expand := config.floating.expand
				currentElementBoundingBox.x -= expand.x
				currentElementBoundingBox.width += expand.x * 2.0
				currentElementBoundingBox.y -= expand.y
				currentElementBoundingBox.height += expand.y * 2.0
			}
			scrollContainerData: ^ScrollContainerDataInternal
			if isLayout && (config.clip.horizontal || config.clip.vertical) {
				for &mapping in arrayIter(s.scrollContainerDatas) {
					if mapping.layoutElement == currentElement {
						scrollContainerData = &mapping
						mapping.boundingBox = currentElementBoundingBox
						scrollOffset = config.clip.childOffset
						if s.externalScrollHandlingEnabled {
							scrollOffset = {}
						}
						break
					}
				}
			}

			offscreen := elementIsOffscreen(&currentElementBoundingBox)

			if generateRenderCommands && !offscreen {

				if textConfig, isText := &currentElement.config.(TextDeclaration); isText {
					naturalLineHeight := textConfig.data.preferredDimensions.y
					finalLineHeight :=
						textConfig.config.lineHeight > 0 ? textConfig.config.lineHeight : naturalLineHeight
					lineHeightOffset := (finalLineHeight - naturalLineHeight) / 2.0
					yPos := lineHeightOffset
					for line, lineIdx in arrayIter(textConfig.data.wrappedLines) {
						if len(line.text) == 0 {
							yPos += finalLineHeight
							continue
						}
						offset := currentElementBoundingBox.width - line.dimensions.x
						if textConfig.config.alignment == .LEFT {
							offset = 0
						}
						if textConfig.config.alignment == .CENTER {
							offset /= 2
						}
						pushRenderCommand(
							{
								boundingBox = {
									currentElementBoundingBox.x + offset,
									currentElementBoundingBox.y + yPos,
									line.dimensions.x,
									line.dimensions.y,
								},
								renderData = TextRenderData {
									text = line.text,
									color = textConfig.config.textColor,
									fontId = textConfig.config.fontId,
									fontSize = textConfig.config.fontSize,
									spacing = textConfig.config.spacing,
									lineHeight = textConfig.config.lineHeight,
								},
								userPtr = textConfig.config.userPtr,
								id = hashNumber(u32(lineIdx), currentElement.id).id,
								zIdx = root.zIdx,
								type = .TEXT,
							},
						)
						yPos += finalLineHeight

						if !s.disableCulling &&
						   currentElementBoundingBox.y + yPos > s.layoutDimensions.y {
							break
						}
					}
				} else {
					if config.overlayColor.a > 0 {
						pushRenderCommand(
							{
								renderData = OverlayColorRenderData(config.overlayColor),
								userPtr = config.userPtr,
								id = currentElement.id,
								zIdx = root.zIdx,
								type = .COLOR_OVERLAY_START,
							},
						)
					}
					if config.image != nil {
						pushRenderCommand(
							{
								boundingBox = currentElementBoundingBox,
								renderData = ImageRenderData {
									color = config.backgroundColor,
									cornerRadius = config.cornerRadius,
									data = config.image,
								},
								userPtr = config.userPtr,
								id = currentElement.id,
								zIdx = root.zIdx,
								type = .IMAGE,
							},
						)
					}
					if config.custom != nil {
						pushRenderCommand(
							{
								boundingBox = currentElementBoundingBox,
								renderData = CustomRenderData {
									color = config.backgroundColor,
									cornerRadius = config.cornerRadius,
									data = config.custom,
								},
								userPtr = config.userPtr,
								id = currentElement.id,
								zIdx = root.zIdx,
								type = .CUSTOM,
							},
						)
					}
					if config.clip.horizontal || config.clip.vertical {

						pushRenderCommand(
							{
								boundingBox = currentElementBoundingBox,
								renderData = ClipRenderData {
									horizontal = config.clip.horizontal,
									vertical = config.clip.vertical,
								},
								userPtr = config.userPtr,
								id = currentElement.id,
								zIdx = root.zIdx,
								type = .SCISSOR_START,
							},
						)
					}
					if config.backgroundColor.a > 0 {
						pushRenderCommand(
							{
								boundingBox = currentElementBoundingBox,
								renderData = RectangleRenderData {
									color = config.backgroundColor,
									cornerRadius = config.cornerRadius,
								},
								userPtr = config.userPtr,
								id = currentElement.id,
								zIdx = root.zIdx,
								type = .RECTANGLE,
							},
						)
					}
				}
			}

			hashMapItem := getHashMapItem(currentElement.id)
			hashMapItem.boundingBox = currentElementBoundingBox

			if !isLayout {continue}

			// Setup initial on-axis alignment
			contentSizeCurrent := [2]f32{0, 0}
			if config.layout.direction == .LEFT_TO_RIGHT {
				for childIdx in arrayIter(currentElement.children) {
					childElement := arrayGetPtr(&s.layoutElements, childIdx)
					if childElement.exiting {continue}

					contentSizeCurrent.x += childElement.dimensions.x
					contentSizeCurrent.y = max(contentSizeCurrent.y, childElement.dimensions.y)
				}
				contentSizeCurrent.x +=
					f32(max(currentElement.children.len - 1, 0)) * config.layout.childGap
				extraSpace :=
					currentElement.dimensions.x -
					config.layout.padding.left -
					config.layout.padding.right -
					contentSizeCurrent.x
				#partial switch config.layout.childAlignment.x {
				case .LEFT:
					extraSpace = 0
				case .CENTER:
					extraSpace /= 2
				}
				extraSpace = max(0, extraSpace)
				currentElementTreeNode.nextChildOffset.x += extraSpace
			} else if config.layout.direction == .TOP_TO_BOTTOM {
				for childIdx in arrayIter(currentElement.children) {
					childElement := arrayGetPtr(&s.layoutElements, childIdx)
					if childElement.exiting {continue}
					contentSizeCurrent.x = max(contentSizeCurrent.x, childElement.dimensions.x)
					contentSizeCurrent.y += childElement.dimensions.y
				}
				contentSizeCurrent.y +=
					f32(max(currentElement.children.len - 1, 0)) * config.layout.childGap
				extraSpace :=
					currentElement.dimensions.y -
					config.layout.padding.top -
					config.layout.padding.bottom -
					contentSizeCurrent.y
				#partial switch config.layout.childAlignment.y {
				case .TOP:
					extraSpace = 0
				case .CENTER:
					extraSpace /= 2
				}
				extraSpace = max(0, extraSpace)
				currentElementTreeNode.nextChildOffset.y += extraSpace
			}

			if scrollContainerData != nil {
				scrollContainerData.contentSize = [2]f32 {
					contentSizeCurrent.x +
					config.layout.padding.left +
					config.layout.padding.right,
					contentSizeCurrent.y +
					config.layout.padding.top +
					config.layout.padding.bottom,
				}
			}


			// Add children to the DFS Buffer
			dfsBuffer.len += currentElement.children.len
			for childIdx, idx in arrayIter(currentElement.children) {
				childElement := arrayGetPtr(&s.layoutElements, childIdx)
				childConfig, childIsLayout := childElement.config.(ElementDeclaration)
				if config.layout.direction == .LEFT_TO_RIGHT {
					currentElementTreeNode.nextChildOffset.y = config.layout.padding.top
					whiteSpaceAroundChild :=
						currentElement.dimensions.y -
						config.layout.padding.top -
						config.layout.padding.bottom -
						childElement.dimensions.y

					#partial switch config.layout.childAlignment.y {
					case .CENTER:
						currentElementTreeNode.nextChildOffset.y += whiteSpaceAroundChild / 2.0
					case .BOTTOM:
						currentElementTreeNode.nextChildOffset.y += whiteSpaceAroundChild
					}

				} else {
					currentElementTreeNode.nextChildOffset.x = config.layout.padding.left
					whiteSpaceAroundChild :=
						currentElement.dimensions.x -
						config.layout.padding.left -
						config.layout.padding.right -
						childElement.dimensions.x
					#partial switch config.layout.childAlignment.x {
					case .CENTER:
						currentElementTreeNode.nextChildOffset.x += whiteSpaceAroundChild / 2.0
					case .RIGHT:
						currentElementTreeNode.nextChildOffset.x += whiteSpaceAroundChild
					}
				}
				childPosition := [2]f32 {
					currentElementTreeNode.position.x +
					currentElementTreeNode.nextChildOffset.x +
					scrollOffset.x,
					currentElementTreeNode.position.y +
					currentElementTreeNode.nextChildOffset.y +
					scrollOffset.y,
				}

				// DFS buffer elements need to be added in reverse because stack traversal happens backwards
				nextChildOffset :=
					childIsLayout ? [2]f32{childConfig.layout.padding.left, childConfig.layout.padding.top} : {0, 0}
				newNodeIdx := dfsBuffer.len - 1 - idx
				dfsBuffer.items[newNodeIdx] = LayoutElementTreeNode {
					layoutElement   = childElement,
					position        = {childPosition.x, childPosition.y},
					nextChildOffset = nextChildOffset,
				}
				s.treeNodeVisited.items[newNodeIdx] = false

				// update parent offsets
				if !childElement.exiting {
					if config.layout.direction == .LEFT_TO_RIGHT {
						currentElementTreeNode.nextChildOffset.x +=
							childElement.dimensions.x + config.layout.childGap
					} else {
						currentElementTreeNode.nextChildOffset.y +=
							childElement.dimensions.y + config.layout.childGap
					}
				}
			}
		}

		if root.clipElementId != 0 {
			clipHashMapItem := getHashMapItem(root.clipElementId)
			if clipHashMapItem != nil && !elementIsOffscreen(&clipHashMapItem.boundingBox) {
				pushRenderCommand(
					RenderCommand {
						id = hashNumber(rootElement.id, u32(rootElement.children.len + 11)).id,
						type = .SCISSOR_END,
					},
				)
			}
		}
	}
}


@(private = "file")
getPointerOverIds :: proc() -> Array(ElementID) {
	return s.pointerOverIds
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
DEBUG_VIEW_TEXT_NAME_CONFIG: TextElementConfig = {
	textColor = Color({238, 226, 231, 255} / 255),
	fontSize  = 16,
	wrapMode  = .WRAP_NONE,
}
debugViewScrollViewItemLayoutConfig: LayoutConfig = {}

DebugElementConfigType :: enum {
	BACKGROUND_COLOR,
	OVERLAY_COLOR,
	CORNER_RADIUS,
	TEXT,
	ASPECT,
	IMAGE,
	FLOATING,
	CLIP,
	BORDER,
	CUSTOM,
}

@(private = "file")
debugGetElementConfigTypeLabel :: proc(
	config: DebugElementConfigType,
) -> DebugElementConfigTypeLabelConfig {
	#partial switch config {
	case .BACKGROUND_COLOR:
		return {"Background", Color({243, 134, 48, 255} / 255)}
	case .OVERLAY_COLOR:
		return {"Overlay", Color({142, 129, 206, 255} / 255)}
	case .CORNER_RADIUS:
		return {"Radius", Color({239, 148, 157, 255} / 255)}
	case .TEXT:
		return {"Text", Color({105, 210, 231, 255} / 255)}
	case .ASPECT:
		return {"Aspect", Color({101, 149, 194, 255} / 255)}
	case .IMAGE:
		return {"Image", Color({121, 189, 154, 255} / 255)}
	}
	return {"Error", Color({0, 0, 0, 255} / 255)}
}

renderElementConfigTypeLabel :: proc(label: string, color: Color, offscreen: bool) {
	backgroundColor := color
	backgroundColor.a = 90 / 255
	{ui()(
		{
			layout = {padding = {8, 8, 2, 2}},
			backgroundColor = backgroundColor,
			cornerRadius = cornerRadiusAll(4),
			border = {color = color, width = {1, 1, 1, 1, 0}},
		},
		)
		text(
			label,
			{textColor = offscreen ? DEBUG_VIEW_COLOR_3 : DEBUG_VIEW_COLOR_4, fontSize = 16},
		)
	}
}

idi :: proc(label: string, offset: u32) -> ElementID {
	return hashStringWithOffset(label, offset, 0)
}

@(private = "file")
renderDebugLayoutElementsList :: proc(
	initialRootsLength: int,
	highlightedRowIdx: int,
) -> RenderDebugLayoutData {
	dfsBuffer := s.reusableElementIdxBuffer
	debugViewScrollViewItemLayoutConfig = {
		sizing = {height = sizingFixed(DEBUG_VIEW_ROW_HEIGHT)},
		childGap = 6,
		childAlignment = {y = .CENTER},
	}
	layoutData: RenderDebugLayoutData
	highlightedElementId: u32 = 0
	for i := 0; i < initialRootsLength; i += 1 {
		rootIdx := u32(i)
		root := arrayGetPtr(&s.layoutElementTreeRoots, i)
		dfsBuffer.len = 0
		arrayPush(&dfsBuffer, root.layoutElementIdx)
		s.treeNodeVisited.items[0] = false
		if rootIdx > 0 {
			{ui(idi("claydoDebugViewEmptyRowOuter", rootIdx))(
				{
					layout = {
						sizing = {width = sizingGrow(0)},
						padding = {DEBUG_VIEW_INDENT_WIDTH / 2.0, 0, 0, 0},
					},
				},
				)
				{ui(idi("claydoDebugViewEmptyRow", rootIdx))(
					{
						layout = {
							sizing = {
								width = sizingGrow(0),
								height = sizingFixed(DEBUG_VIEW_ROW_HEIGHT),
							},
						},
						border = {color = DEBUG_VIEW_COLOR_3, width = {top = 1}},
					},
					)}
			}
			layoutData.rowCount += 1
		}
		for dfsBuffer.len > 0 {
			currentElementIdx := arrayPeek(dfsBuffer)
			currentElement := arrayGetPtr(&s.layoutElements, currentElementIdx)
			textConfig, isText := currentElement.config.(TextDeclaration)
			config, isLayout := currentElement.config.(ElementDeclaration)
			if s.treeNodeVisited.items[dfsBuffer.len - 1] {
				if !isText && currentElement.children.len > 0 {
					closeElement()
					closeElement()
					closeElement()
				}
				dfsBuffer.len -= 1
				continue
			}

			if currentElement.exiting { 	// TODO there is a duplicate ID problem with exiting elements
				dfsBuffer.len -= 1
				continue
			}

			if highlightedRowIdx == layoutData.rowCount {
				if s.pointerInfo.state == .PRESSED_THIS_FRAME {
					s.debugSelectedElementId = currentElement.id
				}
				highlightedElementId = currentElement.id
			}
			s.treeNodeVisited.items[dfsBuffer.len - 1] = true
			currentElementData := getHashMapItem(currentElement.id)
			offscreen := elementIsOffscreen(&currentElementData.boundingBox)
			if s.debugSelectedElementId == currentElement.id {
				layoutData.selectedElementRowIdx = layoutData.rowCount
			}

			{ui(idi("claydoDebugViewElementOuter", currentElement.id))(
				{layout = debugViewScrollViewItemLayoutConfig},
				)
				if !(isText || currentElement.children.len == 0) {
					{ui(idi("claydoDebugViewCollapseElement", currentElement.id))(
						{
							layout = {
								sizing = {sizingFixed(16), sizingFixed(16)},
								childAlignment = {.CENTER, .CENTER},
							},
							cornerRadius = cornerRadiusAll(4),
							border = {color = DEBUG_VIEW_COLOR_3, width = {1, 1, 1, 1, 0}},
						},
						)
						text(
							currentElementData != nil && currentElementData.debugData.collapsed ? "+" : "-",
							{textColor = DEBUG_VIEW_COLOR_4, fontSize = 16},
						)
					}
				} else { 	// square dot for empty containers
					{ui()(
						{
							layout = {
								sizing = {sizingFixed(16), sizingFixed(16)},
								childAlignment = {.CENTER, .CENTER},
							},
						},
						)
						{ui()(
							{
								layout = {sizing = {sizingFixed(8), sizingFixed(8)}},
								backgroundColor = DEBUG_VIEW_COLOR_3,
								cornerRadius = cornerRadiusAll(2),
							},
							)}
					}
				}
				// collisions and offscreen info
				if currentElementData != nil {
					if currentElementData.debugData.collision {
						{ui()(
							{
								layout = {padding = {8, 8, 2, 2}},
								border = {
									color = Color({177, 147, 8, 255} / 255),
									width = {1, 1, 1, 1, 0},
								},
							},
							)
							text("Duplicate ID", {textColor = DEBUG_VIEW_COLOR_3, fontSize = 16})
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
							text("Offscreen", {textColor = DEBUG_VIEW_COLOR_3, fontSize = 16})
						}
					}
				}
				if len(currentElementData.elementId.stringId) > 0 {
					{ui()({})
						textConfig :=
							offscreen ? TextElementConfig{textColor = DEBUG_VIEW_COLOR_3, fontSize = 16} : DEBUG_VIEW_TEXT_NAME_CONFIG
						text(currentElementData.elementId.stringId, textConfig)
						if currentElementData.elementId.offset != 0 {
							text(" (", textConfig)

							str_buf: [10]u8
							currentOffset := strconv.write_int(
								str_buf[:],
								i64(currentElementData.elementId.offset),
								10,
							)
							text(currentOffset, textConfig)
							text(")", textConfig)
						}
					}
				}
				if isText {
					renderElementConfigTypeLabel(
						"Text",
						[4]f32{105, 210, 231, 255} / 255,
						offscreen,
					)
				} else {
					if config.backgroundColor.a > 0 {
						labelConfig := debugGetElementConfigTypeLabel(.BACKGROUND_COLOR)
						renderElementConfigTypeLabel(
							labelConfig.label,
							config.backgroundColor,
							offscreen,
						)
					}
					if config.overlayColor.a > 0 {
						labelConfig := debugGetElementConfigTypeLabel(.OVERLAY_COLOR)
						renderElementConfigTypeLabel(
							labelConfig.label,
							config.backgroundColor,
							offscreen,
						)
					}
					if config.cornerRadius != DEFAULT_CORNER_RADIUS {
						labelConfig := debugGetElementConfigTypeLabel(.CORNER_RADIUS)
						renderElementConfigTypeLabel(
							labelConfig.label,
							config.backgroundColor,
							offscreen,
						)
					}
					if config.aspectRatio != 0 {
						labelConfig := debugGetElementConfigTypeLabel(.ASPECT)
						renderElementConfigTypeLabel(
							labelConfig.label,
							config.backgroundColor,
							offscreen,
						)
					}
					if config.image != nil {
						labelConfig := debugGetElementConfigTypeLabel(.IMAGE)
						renderElementConfigTypeLabel(
							labelConfig.label,
							config.backgroundColor,
							offscreen,
						)
					}
					if config.floating.attachTo != .NONE {
						labelConfig := debugGetElementConfigTypeLabel(.FLOATING)
						renderElementConfigTypeLabel(
							labelConfig.label,
							config.backgroundColor,
							offscreen,
						)
					}
					if config.clip.horizontal || config.clip.vertical {
						labelConfig := debugGetElementConfigTypeLabel(.CLIP)
						renderElementConfigTypeLabel(
							labelConfig.label,
							config.backgroundColor,
							offscreen,
						)
					}
					if borderHasAnyWidth(&config.border) {
						labelConfig := debugGetElementConfigTypeLabel(.BORDER)
						renderElementConfigTypeLabel(
							labelConfig.label,
							config.backgroundColor,
							offscreen,
						)
					}
					if config.custom != nil {
						labelConfig := debugGetElementConfigTypeLabel(.CUSTOM)
						renderElementConfigTypeLabel(
							labelConfig.label,
							config.backgroundColor,
							offscreen,
						)
					}
				}
			}
			// Render the text contents below the element as a non-interactive row
			if isText {
				layoutData.rowCount += 1
				rawTextConfig :=
					offscreen ? TextElementConfig{textColor = DEBUG_VIEW_COLOR_3, fontSize = 16} : DEBUG_VIEW_TEXT_NAME_CONFIG
				{ui()(
					{
						layout = {
							sizing = {height = sizingFixed(DEBUG_VIEW_ROW_HEIGHT)},
							childAlignment = {y = .CENTER},
						},
					},
					)
					{ui()(
						{layout = {sizing = {width = sizingFixed(DEBUG_VIEW_INDENT_WIDTH + 16)}}},
						)}
					text("\"", rawTextConfig)
					text(
						len(textConfig.data.text) > 40 ? textConfig.data.text[:40] : textConfig.data.text,
						rawTextConfig,
					)
					if len(textConfig.data.text) > 40 {
						text("...", rawTextConfig)
					}
					text("\"", rawTextConfig)
				}
			} else if currentElement.children.len > 0 {
				openElement()
				configureOpenElement({layout = {padding = {left = 8}}})
				openElement()
				configureOpenElement(
					{
						layout = {padding = {left = DEBUG_VIEW_INDENT_WIDTH}},
						border = {color = DEBUG_VIEW_COLOR_3, width = {left = 1}},
					},
				)
				openElement()
				configureOpenElement({layout = {direction = .TOP_TO_BOTTOM}})
			}

			layoutData.rowCount += 1
			if !isText || (currentElementData != nil && currentElementData.debugData.collapsed) {
				for i := currentElement.children.len - 1; i >= 0; i -= 1 {
					arrayPush(&dfsBuffer, currentElement.children.items[i])
					s.treeNodeVisited.items[dfsBuffer.len - 1] = false // TODO needs to be ranged checked
				}
			}
		}
	}
	if s.pointerInfo.state == .PRESSED_THIS_FRAME {
		collapseButtonId := hashString("Clay__DebugView_CollapseElement", 0)
		for i := s.pointerOverIds.len - 1; i >= 0; i -= 1 {
			elementId := arrayGet(s.pointerOverIds, i)
			if elementId.baseId == collapseButtonId.baseId {
				highlightedItem := getHashMapItem(elementId.offset)
				highlightedItem.debugData.collapsed = !highlightedItem.debugData.collapsed
				break
			}
		}
	}

	if highlightedElementId != 0 {
		{ui(id("Clay__DebugView_ElementHighlight"))(
			{
				layout = {sizing = {sizingGrow(0), sizingGrow(0)}},
				floating = {
					parentId = highlightedElementId,
					zIdx = 32767,
					pointerCaptureMode = .PASSTHROUGH,
					attachTo = .ELEMENT_WITH_ID,
				},
			},
			)
			{ui(id("Clay__DebugView_ElementHighlightRectangle"))(
				{
					layout = {sizing = {sizingGrow(0), sizingGrow(0)}},
					backgroundColor = DEBUG_VIEW_HIGHLIGHT_COLOR,
				},
				)}
		}
	}
	return layoutData
}

@(private = "file")
renderDebugLayoutSizing :: proc(sizing: SizingAxis, infoTextConfig: TextElementConfig) {
	sizing := sizing
	sizingLabel := "GROW"
	if sizing.type == .FIT {
		sizingLabel = "FIT"
	} else if sizing.type == .PERCENT {
		sizingLabel = "PERCENT"
	} else if sizing.type == .FIXED {
		sizingLabel = "FIXED"
	}
	text(sizingLabel, infoTextConfig)
	if sizing.type == .GROW ||
	   sizing.type == .FIXED ||
	   sizing.type == .FIT && sizing.value != nil {
		text("(", infoTextConfig)
		if sizing.value.(SizingMinMax).min != 0 {
			text("min: ", infoTextConfig)
			text(intToString(int(sizing.value.(SizingMinMax).min)), infoTextConfig)
		}
		if sizing.value.(SizingMinMax).max != MAX_FLOAT {
			text("max: ", infoTextConfig)
			text(intToString(int(sizing.value.(SizingMinMax).max)), infoTextConfig)
		}
		text(")", infoTextConfig)
	} else if sizing.type == .PERCENT {
		if sizing.value == nil {
			sizing.value = Percent(0)
		}
		text("( ", infoTextConfig)
		text(intToString(int(sizing.value.(Percent) * 100)), infoTextConfig)
		text("%)", infoTextConfig)
	}
}

@(private = "file")
renderDebugViewElementConfigHeader :: proc(elementId: string, type: DebugElementConfigType) {
	config := debugGetElementConfigTypeLabel(type)
	backgroundColor := config.color
	backgroundColor.a = 90 / 255
	{ui()(
		{
			layout = {padding = {8, 8, 2, 2}},
			backgroundColor = backgroundColor,
			cornerRadius = cornerRadiusAll(4),
			border = {color = config.color, width = {1, 1, 1, 1, 0}},
		},
		)
		text(config.label, {textColor = DEBUG_VIEW_COLOR_4, fontSize = 16})
	}
}

@(private = "file")
renderDebugViewColor :: proc(color: Color, config: TextElementConfig) {
	{ui()({layout = {childAlignment = {y = .CENTER}}})
		text("{ r: ", config)
		text(intToString(int(color.r * 255 / 90)), config)
		text("g: ", config)
		text(intToString(int(color.b * 255 / 90)), config)
		text("b: ", config)
		text(intToString(int(color.g * 255 / 90)), config)
		text("a: ", config)
		text(intToString(int(color.a * 255 / 90)), config)
		text(" }", config)
		{ui()({layout = {sizing = {width = sizingFixed(10)}}})}
		{ui()(
			{
				layout = {
					sizing = {
						sizingFixed(DEBUG_VIEW_ROW_HEIGHT - 8),
						sizingFixed(DEBUG_VIEW_ROW_HEIGHT - 8),
					},
				},
				backgroundColor = color,
				cornerRadius = cornerRadiusAll(4),
				border = {color = DEBUG_VIEW_COLOR_4, width = {1, 1, 1, 1, 0}},
			},
			)}
	}
}

@(private = "file")
renderDebugViewCornerRadius :: proc(cornerRadius: CornerRadius, config: TextElementConfig) {
	{ui()({layout = {childAlignment = {y = .CENTER}}})
		text("{ topLeft: ", config)
		text(intToString(int(cornerRadius.topLeft)), config)
		text(" topRight: ", config)
		text(intToString(int(cornerRadius.topRight)), config)
		text(" bottomLeft: ", config)
		text(intToString(int(cornerRadius.bottomLeft)), config)
		text(" bottomRight: ", config)
		text(intToString(int(cornerRadius.bottomRight)), config)
		text(" }", config)
	}
}

@(private = "file")
handleDebugViewCloseButtonInteraction :: proc(
	elementId: ElementID,
	pointerInfo: PointerData,
	userPtr: rawptr,
) {
	if pointerInfo.state == .PRESSED_THIS_FRAME {
		s.debugModeEnabled = false
	}
}

@(private = "file")
renderDebugView :: proc() {
	closeButtonId := hashString("claydoDebugViewTopHeaderCloseButtonOuter", 0)
	if s.pointerInfo.state == .PRESSED_THIS_FRAME {
		for id in arrayIter(s.pointerOverIds) {
			if id.id == closeButtonId.id {
				s.debugModeEnabled = false
				return
			}
		}
	}

	initialRootsLength := s.layoutElementTreeRoots.len
	initialElementsLen := s.layoutElements.len
	infoTextConfig := TextElementConfig {
		textColor = DEBUG_VIEW_COLOR_4,
		fontSize  = 16,
		wrapMode  = .WRAP_NONE,
	}
	infoTitleConfig := TextElementConfig {
		textColor = DEBUG_VIEW_COLOR_3,
		fontSize  = 16,
		wrapMode  = .WRAP_NONE,
	}
	scrollId := hashString("claydoDebugViewOuterScrollPlane", 0)
	scrollY_offset: f32 = 0
	pointerInDebugView := s.pointerInfo.position.y < s.layoutDimensions.y - 300
	for &scrollContainerData in arrayIter(s.scrollContainerDatas) {
		if scrollContainerData.elementId == scrollId.id {
			if !s.externalScrollHandlingEnabled {
				scrollY_offset = scrollContainerData.scrollPosition.y
			} else {
				pointerInDebugView =
					s.pointerInfo.position.y + scrollContainerData.scrollPosition.y <
					s.layoutDimensions.y - 300
			}
			break
		}
	}
	highlightedRow: int =
		pointerInDebugView ? int((s.pointerInfo.position.y - scrollY_offset) / DEBUG_VIEW_ROW_HEIGHT) - 1 : -1
	if s.pointerInfo.position.x < s.layoutDimensions.x - DEBUG_VIEW_WIDTH {
		highlightedRow = -1
	}
	layoutData: RenderDebugLayoutData = {}
	{ui(id("claydoDebugView"))(
		{
			layout = {
				sizing = {sizingFixed(DEBUG_VIEW_WIDTH), sizingFixed(s.layoutDimensions.y)},
				direction = .TOP_TO_BOTTOM,
			},
			floating = {
				zIdx = 32765,
				attachPoints = {element = .LEFT_CENTER, parent = .RIGHT_CENTER},
				attachTo = .ROOT,
				clipTo = .ATTACHED_PARENT,
			},
			border = {color = DEBUG_VIEW_COLOR_3, width = {bottom = 1}},
		},
		)
		{ui()(
			{
				layout = {
					sizing = {sizingGrow(0), sizingFixed(DEBUG_VIEW_ROW_HEIGHT)},
					padding = {DEBUG_VIEW_OUTER_PADDING, DEBUG_VIEW_OUTER_PADDING, 0, 0},
					childAlignment = {y = .CENTER},
				},
				backgroundColor = DEBUG_VIEW_COLOR_2,
			},
			)
			text("Claydo Debug Tools", infoTextConfig)
			{ui()({layout = {sizing = {width = sizingGrow(0)}}})}
			// Close button
			{ui()(
				{
					layout = {
						sizing = {
							sizingFixed(DEBUG_VIEW_ROW_HEIGHT - 10),
							sizingFixed(DEBUG_VIEW_ROW_HEIGHT - 10),
						},
						childAlignment = {.CENTER, .CENTER},
					},
					backgroundColor = {217, 91, 67, 80},
					cornerRadius = cornerRadiusAll(4),
					border = {color = Color({217, 91, 67, 255} / 255), width = {1, 1, 1, 1, 0}},
				},
				)
				onHover(handleDebugViewCloseButtonInteraction, nil)
				text("x", {textColor = DEBUG_VIEW_COLOR_4, fontSize = 16})
			}
		}
		{ui()(
			{
				layout = {sizing = {sizingGrow(0), sizingFixed(1)}},
				backgroundColor = DEBUG_VIEW_COLOR_3,
			},
			)}
		{ui(scrollId)(
			{
				layout = {sizing = {sizingGrow(0), sizingGrow(0)}},
				clip = {horizontal = true, vertical = true, childOffset = getScrollOffset()},
			},
			)
			{ui()(
				{
					layout = {sizing = {sizingGrow(0), sizingGrow(0)}, direction = .TOP_TO_BOTTOM},
					backgroundColor = ((initialElementsLen + initialRootsLength) & 1) == 0 ? DEBUG_VIEW_COLOR_2 : DEBUG_VIEW_COLOR_1,
				},
				)
				panelContentsId := hashString("claydoDebugViewPanelOuter", 0)
				{ui(panelContentsId)(
					{
						layout = {sizing = {sizingGrow(0), sizingGrow(0)}},
						floating = {
							zIdx = 32766,
							pointerCaptureMode = .PASSTHROUGH,
							attachTo = .PARENT,
							clipTo = .ATTACHED_PARENT,
						},
					},
					)
					{ui()(
						{
							layout = {
								sizing = {sizingGrow(0), sizingGrow(0)},
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
						layoutData = renderDebugLayoutElementsList(
							initialRootsLength,
							highlightedRow,
						)
					}
				}
				contentWidth := getHashMapItem(panelContentsId.id).layoutElement.dimensions.x
				{ui()(
					{
						layout = {
							sizing = {width = sizingFixed(contentWidth)},
							direction = .TOP_TO_BOTTOM,
						},
					},
					)}
				for i := 0; i < layoutData.rowCount; i += 1 {
					rowColor := (i & 1) == 0 ? DEBUG_VIEW_COLOR_2 : DEBUG_VIEW_COLOR_1
					if (i == layoutData.selectedElementRowIdx) {
						rowColor = DEBUG_VIEW_COLOR_SELECTED_ROW
					}
					if (i == highlightedRow) {
						rowColor.r *= 1.25
						rowColor.g *= 1.25
						rowColor.b *= 1.25
					}
					{ui()(
						{
							layout = {
								sizing = {sizingGrow(0), sizingFixed(DEBUG_VIEW_ROW_HEIGHT)},
								direction = .TOP_TO_BOTTOM,
							},
							backgroundColor = rowColor,
						},
						)}
				}
			}
		}
		{ui()(
			{
				layout = {sizing = {width = sizingGrow(0), height = sizingFixed(1)}},
				backgroundColor = DEBUG_VIEW_COLOR_3,
			},
			)}
		if s.debugSelectedElementId != 0 {
			selectedItem := getHashMapItem(s.debugSelectedElementId)
			textConfig, isText := selectedItem.layoutElement.config.(TextDeclaration)
			config, isLayout := selectedItem.layoutElement.config.(ElementDeclaration)
			{ui()(
				{
					layout = {
						sizing = {sizingGrow(0), sizingGrow(300)},
						direction = .TOP_TO_BOTTOM,
					},
					backgroundColor = DEBUG_VIEW_COLOR_2,
					clip = {vertical = true, childOffset = getScrollOffset()},
					border = {color = DEBUG_VIEW_COLOR_3, width = {betweenChildren = 1}},
				},
				)
				{ui()(
					{
						layout = {
							sizing = {sizingGrow(0), sizingGrow(DEBUG_VIEW_ROW_HEIGHT + 8)},
							padding = {DEBUG_VIEW_OUTER_PADDING, DEBUG_VIEW_OUTER_PADDING, 0, 0},
							childAlignment = {y = .CENTER},
						},
					},
					)
					text("Element Configuration", infoTextConfig)
					{ui()({layout = {sizing = {width = sizingGrow(0)}}})}
					if len(selectedItem.elementId.stringId) != 0 {
						text(selectedItem.elementId.stringId, infoTitleConfig)
						if (selectedItem.elementId.offset != 0) {
							text(" (", infoTitleConfig)
							text(intToString(int(selectedItem.elementId.offset)), infoTitleConfig)
							text(")", infoTitleConfig)
						}
					}
				}
				attributeConfigPadding := Padding {
					DEBUG_VIEW_OUTER_PADDING,
					DEBUG_VIEW_OUTER_PADDING,
					8,
					8,
				}
				{ui()(
					{
						layout = {
							padding = attributeConfigPadding,
							childGap = 8,
							direction = .TOP_TO_BOTTOM,
						},
					},
					)
					{ui()(
						{
							layout = {padding = {8, 8, 2, 2}},
							backgroundColor = {200, 200, 200, 120},
							cornerRadius = cornerRadiusAll(4),
							border = {color = {200, 200, 200, 255}, width = {1, 1, 1, 1, 0}},
						},
						)
						text("Layout", {textColor = DEBUG_VIEW_COLOR_4, fontSize = 16})
					}
					text("Bounding Box", infoTitleConfig)
					{ui()({layout = {direction = .LEFT_TO_RIGHT}})
						text("{ x: ", infoTextConfig)
						text(intToString(int(selectedItem.boundingBox.x)), infoTextConfig)
						text(", y: ", infoTextConfig)
						text(intToString(int(selectedItem.boundingBox.y)), infoTextConfig)
						text(", width: ", infoTextConfig)
						text(intToString(int(selectedItem.boundingBox.width)), infoTextConfig)
						text(", height: ", infoTextConfig)
						text(intToString(int(selectedItem.boundingBox.height)), infoTextConfig)
						text(" }", infoTextConfig)
					}
					text("Layout Direction", infoTitleConfig)
					layoutConfig := config.layout
					text(
						layoutConfig.direction == .TOP_TO_BOTTOM ? "TOP_TO_BOTTOM" : "LEFT_TO_RIGHT",
						infoTextConfig,
					)
					// sizing
					text("Sizing", infoTitleConfig)
					{ui()({layout = {direction = .LEFT_TO_RIGHT}})
						text("width: ", infoTextConfig)
						renderDebugLayoutSizing(layoutConfig.sizing.width, infoTextConfig)
					}
					{ui()({layout = {direction = .LEFT_TO_RIGHT}})
						text("height: ", infoTextConfig)
						renderDebugLayoutSizing(layoutConfig.sizing.height, infoTextConfig)
					}
					// padding
					text("Padding", infoTitleConfig)
					{ui(id("debugViewElementInfoPadding"))({layout = {direction = .LEFT_TO_RIGHT}})
						text("{ left: ", infoTextConfig)
						text(intToString(int(layoutConfig.padding.left)), infoTextConfig)
						text(", right: ", infoTextConfig)
						text(intToString(int(layoutConfig.padding.right)), infoTextConfig)
						text(", top: ", infoTextConfig)
						text(intToString(int(layoutConfig.padding.top)), infoTextConfig)
						text(", bottom: ", infoTextConfig)
						text(intToString(int(layoutConfig.padding.bottom)), infoTextConfig)
						text(" }", infoTextConfig)
					}
					// child gap
					text("Child Gap", infoTitleConfig)
					text(intToString(int(layoutConfig.childGap)), infoTextConfig)
					// child alignment
					text("Child Alignment", infoTitleConfig)
					{ui()({layout = {direction = .LEFT_TO_RIGHT}})
						text("{ x: ", infoTextConfig)
						alignX := "LEFT"
						if (layoutConfig.childAlignment.x == .CENTER) {
							alignX = "CENTER"
						} else if (layoutConfig.childAlignment.x == .RIGHT) {
							alignX = "RIGHT"
						}
						text(alignX, infoTextConfig)
						text(", y: ", infoTextConfig)
						alignY := "TOP"
						if (layoutConfig.childAlignment.y == .CENTER) {
							alignY = "CENTER"
						} else if (layoutConfig.childAlignment.y == .BOTTOM) {
							alignY = "BOTTOM"
						}
						text(alignY, infoTextConfig)
						text(" }", infoTextConfig)
					}
				}
				if isText {
					{ui()(
						{
							layout = {
								padding = attributeConfigPadding,
								childGap = 8,
								direction = .TOP_TO_BOTTOM,
							},
						},
						)
						// fontSize
						text("Font Size", infoTitleConfig)
						text(intToString(int(textConfig.config.fontSize)), infoTextConfig)
						// fontId
						text("Font ID", infoTitleConfig)
						text(intToString(int(textConfig.config.fontId)), infoTextConfig)
						// lineHeight
						text("Line Height", infoTitleConfig)
						text(
							textConfig.config.lineHeight == 0 ? "auto" : intToString(int(textConfig.config.lineHeight)),
							infoTextConfig,
						)
						// spacing
						text("Letter Spacing", infoTitleConfig)
						text(intToString(int(textConfig.config.spacing)), infoTextConfig)
						// wrapMode
						text("Wrap Mode", infoTitleConfig)
						wrapMode := "WORDS"
						if (textConfig.config.wrapMode == .WRAP_NONE) {
							wrapMode = "NONE"
						} else if (textConfig.config.wrapMode == .WRAP_NEWLINES) {
							wrapMode = "NEWLINES"
						}
						text(wrapMode, infoTextConfig)
						// alignment
						text("Text Alignment", infoTitleConfig)
						textAlignment := "LEFT"
						if (textConfig.config.alignment == .CENTER) {
							textAlignment = "CENTER"
						} else if (textConfig.config.alignment == .RIGHT) {
							textAlignment = "RIGHT"
						}
						text(textAlignment, infoTextConfig)
						// textColor
						text("Text Color", infoTitleConfig)
						renderDebugViewColor(textConfig.config.textColor, infoTextConfig)
					}
				} else {
					{ui(id("Clay__DebugViewElementInfoSharedBody"))(
						{
							layout = {
								padding = attributeConfigPadding,
								childGap = 8,
								direction = .TOP_TO_BOTTOM,
							},
						},
						)
						labelConfig := debugGetElementConfigTypeLabel(.BACKGROUND_COLOR)
						backgroundColor := labelConfig.color
						backgroundColor.a = 90 / 255
						{ui()(
							{
								layout = {padding = {8, 8, 2, 2}},
								backgroundColor = backgroundColor,
								cornerRadius = cornerRadiusAll(4),
								border = {color = labelConfig.color, width = {1, 1, 1, 1, 0}},
							},
							)
							text(
								"Color & Radius",
								TextElementConfig{textColor = DEBUG_VIEW_COLOR_4, fontSize = 16},
							)
						}
						// .backgroundColor
						if config.backgroundColor.a > 0 {
							text("Background Color", infoTitleConfig)
							renderDebugViewColor(config.backgroundColor, infoTextConfig)
						}
						// .cornerRadius
						if config.cornerRadius != DEFAULT_CORNER_RADIUS {
							text("Corner Radius", infoTitleConfig)
							renderDebugViewCornerRadius(config.cornerRadius, infoTextConfig)
						}
						// .overlayColor
						if config.overlayColor.a > 0 {
							text("Overlay Color", infoTitleConfig)
							renderDebugViewColor(config.overlayColor, infoTextConfig)
						}
					}
				}
				if isLayout && config.aspectRatio > 0 {
					{ui(id("claydoDebugViewElementInfoAspectRatioBody"))(
						{
							layout = {
								padding = attributeConfigPadding,
								childGap = 8,
								direction = .TOP_TO_BOTTOM,
							},
						},
						)
						text("Aspect Ratio", infoTitleConfig)
						// Aspect Ratio
						{ui(id("claydoDebugViewElementInfoAspectRatio"))({})
							text(intToString(int(config.aspectRatio)), infoTextConfig)
							text(".", infoTextConfig)
							frac := f32(config.aspectRatio) - f32(int(config.aspectRatio))
							frac *= 100
							if int(frac) < 10 {
								text("0", infoTextConfig)
							}
							text(intToString(int(frac)), infoTextConfig)
						}
					}
				}
				if isLayout && config.image != nil {
					aspectConfig := config.aspectRatio > 0 ? config.aspectRatio : AspectRatio(1)
					{ui(id("claydoDebugViewElementInfoImageBody"))(
						{
							layout = {
								padding = attributeConfigPadding,
								childGap = 8,
								direction = .TOP_TO_BOTTOM,
							},
						},
						)
						// Image Preview
						text("Preview", infoTitleConfig)
						{ui()(
							{
								layout = {
									sizing = {
										width = sizingGrow(64, 128),
										height = sizingGrow(64, 128),
									},
								},
								aspectRatio = aspectConfig,
								image = config.image,
							},
							)}
					}
				}
				if isLayout && config.floating.attachTo != .NONE {
					{ui()(
						{
							layout = {
								padding = attributeConfigPadding,
								childGap = 8,
								direction = .TOP_TO_BOTTOM,
							},
						},
						)
						// offset
						text("Offset", infoTitleConfig)
						{ui()({layout = {direction = .LEFT_TO_RIGHT}})
							text("{ x: ", infoTextConfig)
							text(intToString(int(config.floating.offset.x)), infoTextConfig)
							text(", y: ", infoTextConfig)
							text(intToString(int(config.floating.offset.y)), infoTextConfig)
							text(" }", infoTextConfig)
						}
						// expand
						text("Expand", infoTitleConfig)
						{ui()({layout = {direction = .LEFT_TO_RIGHT}})
							text("{ width: ", infoTextConfig)
							text(intToString(int(config.floating.expand.x)), infoTextConfig)
							text(", height: ", infoTextConfig)
							text(intToString(int(config.floating.expand.y)), infoTextConfig)
							text(" }", infoTextConfig)
						}
						// zIdx
						text("z-index", infoTitleConfig)
						text(intToString(int(config.floating.zIdx)), infoTextConfig)
						// parentId
						text("Parent", infoTitleConfig)
						hashItem := getHashMapItem(config.floating.parentId)
						text(hashItem.elementId.stringId, infoTextConfig)
						// attachPoints
						text("Attach Points", infoTitleConfig)
						{ui()({layout = {direction = .LEFT_TO_RIGHT}})
							text("{ element: ", infoTextConfig)
							attachPointElement := "LEFT_TOP"
							if (config.floating.attachPoints.element == .LEFT_CENTER) {
								attachPointElement = "LEFT_CENTER"
							} else if (config.floating.attachPoints.element == .LEFT_BOTTOM) {
								attachPointElement = "LEFT_BOTTOM"
							} else if (config.floating.attachPoints.element == .CENTER_TOP) {
								attachPointElement = "CENTER_TOP"
							} else if (config.floating.attachPoints.element == .CENTER_CENTER) {
								attachPointElement = "CENTER_CENTER"
							} else if (config.floating.attachPoints.element == .CENTER_BOTTOM) {
								attachPointElement = "CENTER_BOTTOM"
							} else if (config.floating.attachPoints.element == .RIGHT_TOP) {
								attachPointElement = "RIGHT_TOP"
							} else if (config.floating.attachPoints.element == .RIGHT_CENTER) {
								attachPointElement = "RIGHT_CENTER"
							} else if (config.floating.attachPoints.element == .RIGHT_BOTTOM) {
								attachPointElement = "RIGHT_BOTTOM"
							}
							text(attachPointElement, infoTextConfig)
							attachPointParent := "LEFT_TOP"
							if (config.floating.attachPoints.parent == .LEFT_CENTER) {
								attachPointParent = "LEFT_CENTER"
							} else if (config.floating.attachPoints.parent == .LEFT_BOTTOM) {
								attachPointParent = "LEFT_BOTTOM"
							} else if (config.floating.attachPoints.parent == .CENTER_TOP) {
								attachPointParent = "CENTER_TOP"
							} else if (config.floating.attachPoints.parent == .CENTER_CENTER) {
								attachPointParent = "CENTER_CENTER"
							} else if (config.floating.attachPoints.parent == .CENTER_BOTTOM) {
								attachPointParent = "CENTER_BOTTOM"
							} else if (config.floating.attachPoints.parent == .RIGHT_TOP) {
								attachPointParent = "RIGHT_TOP"
							} else if (config.floating.attachPoints.parent == .RIGHT_CENTER) {
								attachPointParent = "RIGHT_CENTER"
							} else if (config.floating.attachPoints.parent == .RIGHT_BOTTOM) {
								attachPointParent = "RIGHT_BOTTOM"
							}
							text(", parent: ", infoTextConfig)
							text(attachPointParent, infoTextConfig)
							text(" }", infoTextConfig)
						}
						// pointerCaptureMode
						text("Pointer Capture Mode", infoTitleConfig)
						pointerCaptureMode := "NONE"
						if (config.floating.pointerCaptureMode == .PASSTHROUGH) {
							pointerCaptureMode = "PASSTHROUGH"
						}
						text(pointerCaptureMode, infoTextConfig)
						// .attachTo
						text("Attach To", infoTitleConfig)
						attachTo := "NONE"
						if (config.floating.attachTo == .PARENT) {
							attachTo = "PARENT"
						} else if (config.floating.attachTo == .ELEMENT_WITH_ID) {
							attachTo = "ELEMENT_WITH_ID"
						} else if (config.floating.attachTo == .ROOT) {
							attachTo = "ROOT"
						}
						text(attachTo, infoTextConfig)
						// clipTo
						text("Clip To", infoTitleConfig)
						clipTo := "ATTACHED_PARENT"
						if (config.floating.clipTo == .NONE) {
							clipTo = "NONE"
						}
						text(clipTo, infoTextConfig)
					}
				}
				if isLayout && (config.clip.horizontal || config.clip.vertical) {
					{ui()(
						{
							layout = {
								padding = attributeConfigPadding,
								childGap = 8,
								direction = .TOP_TO_BOTTOM,
							},
						},
						)
						// vertical
						text("Vertical", infoTitleConfig)
						text(config.clip.vertical ? "true" : "false", infoTextConfig)
						// horizontal
						text("Horizontal", infoTitleConfig)
						text(config.clip.horizontal ? "true" : "false", infoTextConfig)
					}
				}
				if isLayout && borderHasAnyWidth(&config.border) {
					{ui(id("claydoDebugViewElementInfoBorderBody"))(
						{
							layout = {
								padding = attributeConfigPadding,
								childGap = 8,
								direction = .TOP_TO_BOTTOM,
							},
						},
						)
						text("Border Widths", infoTitleConfig)
						{ui()({layout = {direction = .LEFT_TO_RIGHT}})
							text("{ left: ", infoTextConfig)
							text(intToString(int(config.border.width.left)), infoTextConfig)
							text(", right: ", infoTextConfig)
							text(intToString(int(config.border.width.right)), infoTextConfig)
							text(", top: ", infoTextConfig)
							text(intToString(int(config.border.width.top)), infoTextConfig)
							text(", bottom: ", infoTextConfig)
							text(intToString(int(config.border.width.bottom)), infoTextConfig)
							text(" }", infoTextConfig)
						}
						// color
						text("Border Color", infoTitleConfig)
						renderDebugViewColor(config.border.color, infoTextConfig)
					}
				}
			}
		} else {
			{ui(id("claydoDebugViewWarningsScrollPane"))(
				{
					layout = {
						sizing = {sizingGrow(0), sizingFixed(300)},
						childGap = 6,
						direction = .TOP_TO_BOTTOM,
					},
					backgroundColor = DEBUG_VIEW_COLOR_2,
					clip = {horizontal = true, vertical = true, childOffset = getScrollOffset()},
				},
				)
				warningConfig := TextElementConfig {
					textColor = DEBUG_VIEW_COLOR_4,
					fontSize  = 16,
					wrapMode  = .WRAP_NONE,
				}
				{ui(id("claydoDebugViewWarningItemHeader"))(
					{
						layout = {
							sizing = {height = sizingFixed(DEBUG_VIEW_ROW_HEIGHT)},
							padding = {DEBUG_VIEW_OUTER_PADDING, DEBUG_VIEW_OUTER_PADDING, 0, 0},
							childGap = 8,
							childAlignment = {y = .CENTER},
						},
					},
					)
					text("Warnings", warningConfig)
				}
				{ui(id("clayDebugViewWarningsTopBorder"))(
					{
						layout = {sizing = {width = sizingGrow(0), height = sizingFixed(1)}},
						backgroundColor = Color({200, 200, 200, 255} / 255),
					},
					)}
				previousWarningsLength := s.warnings.len
				for warning, i in arrayIter(s.warnings) {
					{ui(idi("claydoDebugViewWarningItem", u32(i)))(
						{
							layout = {
								sizing = {height = sizingFixed(DEBUG_VIEW_ROW_HEIGHT)},
								padding = {
									DEBUG_VIEW_OUTER_PADDING,
									DEBUG_VIEW_OUTER_PADDING,
									0,
									0,
								},
								childGap = 8,
								childAlignment = {y = .CENTER},
							},
						},
						)
						text(warning.baseMessage, warningConfig)
						if (len(warning.dynamicMessage) > 0) {
							text(warning.dynamicMessage, warningConfig)
						}
					}
				}
			}
		}
	}
}

// NOTE - PUBLIC API

minMemorySize :: proc() -> uint {
	fakeContext := State {
		maxElementCount              = s != nil ? s.maxElementCount : DEFAULT_MAX_ELEMENT_COUNT,
		maxMeasureTextCacheWordCount = s != nil ? s.maxMeasureTextCacheWordCount : DEFAULT_MAX_MEASURE_TEXT_WORD_CACHE_COUNT,
		arenaInternal                = virtual.Arena{},
	}
	reserved := make([]byte, 64 * 1024 * 1024) // Up front allocate 64mb. This will be freed later
	defer delete(reserved)
	err := virtual.arena_init_buffer(&fakeContext.arenaInternal, reserved)
	fakeContext.arena = virtual.arena_allocator(&fakeContext.arenaInternal)
	if err != nil {
		return 0
	}
	initializeEphemeralMemory(&fakeContext)
	initializePersistentMemory(&fakeContext)
	minSize := fakeContext.arenaInternal.total_used
	free_all(fakeContext.arena)
	return minSize
}

createArenaWithCapacity :: proc(cap: uint) -> Arena {
	arena: Arena
	reserved := make([]byte, cap + 100)
	err := virtual.arena_init_buffer(&arena, reserved)
	if err != nil {
		if s.errorHandler.errProc != nil {
			s.errorHandler.errProc(
				ErrorData {
					type = .ARENA_CAPACITY_EXCEEDED,
					text = "Claydo attempted to allocate memory in its arena, but ran out of capacity. Try increasing the capacity of the arena passed to initialize()",
					userPtr = s.errorHandler.userPtr,
				},
			)
		}
		return {}
	}
	return arena
}

setMeasureTextProcedure :: proc(
	procedure: proc(_: string, _: TextElementConfig, _: rawptr) -> [2]f32,
	userPtr: rawptr,
) {
	s.measureText = procedure
	s.measureTextUserPtr = userPtr
}

setQueryScrollOffsetProcedure :: proc(
	procedure: proc(elementId: u32, userPtr: rawptr) -> [2]f32,
	userPtr: rawptr,
) {
	s.queryScrollOffset = procedure
	s.queryScrollOffsetUserPtr = userPtr
}

setLayoutDimensions :: proc(dimensions: [2]f32) {
	s.rootResizedLastFrame =
		!floatEquals(s.layoutDimensions.x, dimensions.x) ||
		!floatEquals(s.layoutDimensions.y, dimensions.y)
	s.layoutDimensions = dimensions
	s.rootResizedLastFrame =
		!floatEquals(s.layoutDimensions.x, dimensions.x) ||
		!floatEquals(s.layoutDimensions.y, dimensions.y)

}

setPointerState :: proc(position: [2]f32, isPointerDown: bool) {
	if s.booleanWarnings.maxElementsExceeded {
		return
	}
	s.pointerInfo.position = position
	s.pointerOverIds.len = 0
	dfsBuffer := s.layoutElementChildrenBuffer
	for root in arrayIter(s.layoutElementTreeRoots) {
		dfsBuffer.len = 0
		arrayPush(&dfsBuffer, root.layoutElementIdx)
		s.treeNodeVisited.items[0] = false
		found := false
		skipTree := false
		for dfsBuffer.len > 0 {
			if s.treeNodeVisited.items[dfsBuffer.len - 1] {
				dfsBuffer.len -= 1
				continue
			}
			s.treeNodeVisited.items[dfsBuffer.len - 1] = true
			currentElement := arrayGetPtr(
				&s.layoutElements,
				arrayGet(dfsBuffer, dfsBuffer.len - 1),
			)
			// Skip mouse interactions on an element if it's currently transitioning, based on user config
			config, isLayout := currentElement.config.(ElementDeclaration)
			if isLayout && config.transition.handler != nil {
				for I := 0; I < s.transitionDatas.len; I += 1 {
					data := arrayGetPtr(&s.transitionDatas, I)
					if data.elementId == currentElement.id {
						if config.transition.interactionHandling ==
						   .DISABLE_INTERACTIONS_WHILE_TRANSITIONING_POSITION {
							if data.state == .EXITING ||
							   data.state == .ENTERING ||
							   ((.Y in data.activeProperties || .X in data.activeProperties) &&
									   data.state == .TRANSITIONING) {
								skipTree = true
							}
						} else if config.transition.interactionHandling ==
						   .ALLOW_INTERACTIONS_WHILE_TRANSITIONING_POSITION {
							if data.state == .EXITING {
								skipTree = true
							}
						}
					}
				}
			}
			mapItem := getHashMapItem(currentElement.id)
			clipElementId := arrayGet(
				s.layoutElementClipElementIds,
				intrinsics.ptr_sub(currentElement, &s.layoutElements.items[0]),
			)
			clipItem := getHashMapItem(u32(clipElementId))
			if mapItem != nil && mapItem.generation > s.generation {
				elementBox := mapItem.boundingBox
				elementBox.x -= root.pointerOffset.x
				elementBox.y -= root.pointerOffset.y
				if pointIsInsideRect(position, elementBox) &&
					   (clipElementId == 0 || pointIsInsideRect(position, clipItem.boundingBox)) ||
				   s.externalScrollHandlingEnabled {
					if !skipTree {
						if mapItem.onHoverFunction != nil {
							mapItem.onHoverFunction(
								mapItem.elementId,
								s.pointerInfo,
								mapItem.hoverFunctionUserPtr,
							)
						}
						arrayPush(&s.pointerOverIds, mapItem.elementId)
					}
					found = true
				}
				if _, isText := currentElement.config.(TextDeclaration); skipTree || isText {
					dfsBuffer.len -= 1
					continue
				}
				#reverse for child in arrayIter(currentElement.children) {
					arrayPush(&dfsBuffer, child)
					s.treeNodeVisited.items[dfsBuffer.len - 1] = false // TODO needs to be range checked
				}
			} else {
				dfsBuffer.len -= 1
			}
		}
		rootElement := arrayGetPtr(&s.layoutElements, root.layoutElementIdx)
		config, isLayout := rootElement.config.(ElementDeclaration)
		if isLayout &&
		   config.floating.attachTo != .NONE &&
		   config.floating.pointerCaptureMode == .CAPTURE {
			break
		}
	}

	if isPointerDown {
		if s.pointerInfo.state == .PRESSED_THIS_FRAME {
			s.pointerInfo.state = .PRESSED
		} else if s.pointerInfo.state != .PRESSED {
			s.pointerInfo.state = .PRESSED_THIS_FRAME
		}
	} else {
		if s.pointerInfo.state == .RELEASED_THIS_FRAME {
			s.pointerInfo.state = .RELEASED
		} else if s.pointerInfo.state != .RELEASED {
			s.pointerInfo.state = .RELEASED_THIS_FRAME
		}
	}
}

getPointerState :: proc() -> PointerData {
	return s.pointerInfo
}

defaultErrorHandlerProc :: proc(data: ErrorData) {}

initialize :: proc(arena: Arena, layoutDimensions: [2]f32, errorHandler: ErrorHandler) -> ^State {
	oldS := s
	s = new(State)
	s^ = {
		maxElementCount              = oldS != nil ? oldS.maxElementCount : DEFAULT_MAX_ELEMENT_COUNT,
		maxMeasureTextCacheWordCount = oldS != nil ? oldS.maxMeasureTextCacheWordCount : DEFAULT_MAX_MEASURE_TEXT_WORD_CACHE_COUNT,
		errorHandler                 = errorHandler.errProc != nil ? errorHandler : ErrorHandler{defaultErrorHandlerProc, nil},
		layoutDimensions             = layoutDimensions,
		arenaInternal                = arena,
	}
	s.arena = virtual.arena_allocator(&s.arenaInternal)
	// TODO what happens when we don't free the old data
	initializePersistentMemory(s)
	s.arenaResetPoint = s.arenaInternal.total_used
	initializeEphemeralMemory(s)
	for i in 0 ..< s.layoutElementsHashMap.cap {
		s.layoutElementsHashMap.items[i] = -1
	}
	for i in 0 ..< s.measureTextHashMap.cap {
		s.measureTextHashMap.items[i] = 0
	}
	s.measureTextHashMapInternal.len = 1 // reserve 0 to mean "no next element"
	s.layoutDimensions = layoutDimensions
	return s
}

getScrollOffset :: proc() -> [2]f32 {
	if s.booleanWarnings.maxElementsExceeded {
		return {}
	}
	openLayoutElement := getOpenLayoutElement()
	for &mapping in arrayIter(s.scrollContainerDatas) {
		if mapping.layoutElement == openLayoutElement {
			return mapping.scrollPosition
		}
	}
	return {}
}

updateScrollContainers :: proc(enableDragScrolling: bool, scrollDelta: [2]f32, deltaTime: f32) {
	isPointerActive :=
		enableDragScrolling &&
		(s.pointerInfo.state == .PRESSED_THIS_FRAME || s.pointerInfo.state == .PRESSED)
	highestPriorityElementIdx := -1
	highestPriorityScrollData: ^ScrollContainerDataInternal
	for &scrollData, idx in arrayIter(s.scrollContainerDatas) {
		if !scrollData.openThisFrame {
			arraySwapback(&s.scrollContainerDatas, idx)
			continue
		}
		scrollData.openThisFrame = false
		hashMapItem := getHashMapItem(scrollData.elementId)
		// element isn't rendered this frame but scroll offset has been retained
		if hashMapItem == nil {
			arraySwapback(&s.scrollContainerDatas, idx)
			continue
		}

		// touch / click is released
		if !isPointerActive && scrollData.pointerScrollActive {
			xDiff := scrollData.scrollPosition.x - scrollData.scrollOrigin.x
			if xDiff < -10 || xDiff > 10 {
				scrollData.scrollMomentum.x =
					(scrollData.scrollPosition.x - scrollData.scrollOrigin.x) /
					(scrollData.momentumTime * 25)
			}
			yDiff := scrollData.scrollPosition.y - scrollData.scrollOrigin.y
			if yDiff < -10 || yDiff > 10 {
				scrollData.scrollMomentum.y =
					(scrollData.scrollPosition.y - scrollData.scrollOrigin.y) /
					(scrollData.momentumTime * 25)
			}
			scrollData.pointerScrollActive = false
			scrollData.pointerOrigin = {0, 0}
			scrollData.scrollOrigin = {0, 0}
			scrollData.momentumTime = 0
		}

		scrollOccurred := scrollDelta.x != 0 || scrollDelta.y != 0
		scrollData.scrollPosition.x += scrollData.scrollMomentum.x
		scrollData.scrollMomentum.x *= 0.95
		if (scrollData.scrollMomentum.x > -0.1 && scrollData.scrollMomentum.x < 0.1) ||
		   scrollOccurred {
			scrollData.scrollMomentum.x = 0
		}
		scrollData.scrollPosition.x = min(
			max(
				scrollData.scrollPosition.x,
				-max(scrollData.contentSize.x - scrollData.layoutElement.dimensions.x, 0),
			),
			0,
		)

		scrollData.scrollPosition.y += scrollData.scrollMomentum.y
		scrollData.scrollMomentum.y *= 0.95
		if (scrollData.scrollMomentum.y > -0.1 && scrollData.scrollMomentum.y < 0.1) ||
		   scrollOccurred {
			scrollData.scrollMomentum.y = 0
		}
		scrollData.scrollPosition.y = min(
			max(
				scrollData.scrollPosition.y,
				-max(scrollData.contentSize.y - scrollData.layoutElement.dimensions.y, 0),
			),
			0,
		)
		for j in 0 ..< s.pointerOverIds.len {
			if scrollData.layoutElement.id == arrayGet(s.pointerOverIds, j).id {
				highestPriorityElementIdx = j
				highestPriorityScrollData = &scrollData
			}
		}
	}
	if highestPriorityElementIdx > -1 && highestPriorityScrollData != nil {
		scrollElement := highestPriorityScrollData.layoutElement
		clipConfig := scrollElement.config.(ElementDeclaration).clip
		canScrollVertically :=
			clipConfig.vertical &&
			highestPriorityScrollData.contentSize.y > scrollElement.dimensions.y
		canScrollHorizontally :=
			clipConfig.horizontal &&
			highestPriorityScrollData.contentSize.x > scrollElement.dimensions.x
		// handle wheel scroll
		if canScrollVertically {
			highestPriorityScrollData.scrollPosition.y =
				highestPriorityScrollData.scrollPosition.y + scrollDelta.y * 10
		}
		if canScrollHorizontally {
			highestPriorityScrollData.scrollPosition.x =
				highestPriorityScrollData.scrollPosition.x + scrollDelta.x * 10
		}
		// handle click / touch scroll
		if isPointerActive {
			highestPriorityScrollData.scrollMomentum = {}
			if !highestPriorityScrollData.pointerScrollActive {
				highestPriorityScrollData.pointerOrigin = s.pointerInfo.position
				highestPriorityScrollData.scrollOrigin = highestPriorityScrollData.scrollPosition
				highestPriorityScrollData.pointerScrollActive = true
			} else {
				scrollDeltaX: f32 = 0
				scrollDeltaY: f32 = 0
				if canScrollHorizontally {
					oldX_scrollPosition := highestPriorityScrollData.scrollPosition.x
					highestPriorityScrollData.scrollPosition.x =
						highestPriorityScrollData.scrollOrigin.x +
						s.pointerInfo.position.x -
						highestPriorityScrollData.pointerOrigin.x
					highestPriorityScrollData.scrollPosition.x = max(
						min(highestPriorityScrollData.scrollPosition.x, 0),
						-highestPriorityScrollData.contentSize.x +
						highestPriorityScrollData.boundingBox.x,
					)
					scrollDeltaX = highestPriorityScrollData.scrollPosition.x - oldX_scrollPosition
				}
				if canScrollVertically {
					oldY_scrollPosition := highestPriorityScrollData.scrollPosition.y
					highestPriorityScrollData.scrollPosition.y =
						highestPriorityScrollData.scrollOrigin.y +
						s.pointerInfo.position.y -
						highestPriorityScrollData.pointerOrigin.y
					highestPriorityScrollData.scrollPosition.y = max(
						min(highestPriorityScrollData.scrollPosition.y, 0),
						-highestPriorityScrollData.contentSize.y +
						highestPriorityScrollData.boundingBox.y,
					)
					scrollDeltaY = highestPriorityScrollData.scrollPosition.x - oldY_scrollPosition
				}
				if scrollDeltaX > -0.1 &&
				   scrollDeltaX < 0.1 &&
				   scrollDeltaY > -0.1 &&
				   scrollDeltaY < 0.1 &&
				   highestPriorityScrollData.momentumTime > 0.15 {
					highestPriorityScrollData.momentumTime = 0
					highestPriorityScrollData.pointerOrigin = s.pointerInfo.position
					highestPriorityScrollData.scrollOrigin =
						highestPriorityScrollData.scrollPosition
				} else {
					highestPriorityScrollData.momentumTime += deltaTime
				}
			}
		}
		// clamp any changes to scroll position to the maximum size of the contents
		if canScrollVertically {
			highestPriorityScrollData.scrollPosition.y = max(
				min(highestPriorityScrollData.scrollPosition.y, 0),
				-highestPriorityScrollData.contentSize.y + scrollElement.dimensions.y,
			)
		}
		if canScrollHorizontally {
			highestPriorityScrollData.scrollPosition.x = max(
				min(highestPriorityScrollData.scrollPosition.x, 0),
				-highestPriorityScrollData.contentSize.x + scrollElement.dimensions.x,
			)
		}
	}
}

beginLayout :: proc() {
	initializeEphemeralMemory(s)
	s.generation += 1
	s.dynamicElementIdx = 0
	rootDimensions: [2]f32 = {s.layoutDimensions.x, s.layoutDimensions.y}
	if s.debugModeEnabled {
		rootDimensions.x -= DEBUG_VIEW_WIDTH
	}
	s.booleanWarnings = {}
	openElementWithId(id("Clay__RootContainer"))
	configureOpenElement(
		ElementDeclaration {
			layout = {
				sizing = {
					width = SizingAxis{.FIXED, SizingMinMax{rootDimensions.x, rootDimensions.x}},
					height = SizingAxis{.FIXED, SizingMinMax{rootDimensions.y, rootDimensions.y}},
				},
			},
		},
	)
	arrayPush(&s.openLayoutElementStack, 0)
	arrayPush(&s.layoutElementTreeRoots, LayoutElementTreeRoot{layoutElementIdx = 0})
}

endLayout :: proc(deltaTime: f32) -> []RenderCommand {
	closeElement() // close the root element
	s := s
	// Begin transition section
	for i := 0; i < s.transitionDatas.len; i += 1 {
		data := arrayGetPtr(&s.transitionDatas, i)
		hashMapItem := getHashMapItem(data.elementId)
		// This might seems strange - can't we just look up the element itself, and check the config to see whether it has an exit transition defined?
		// That would work fine if the element actually had an exit transition in the first place. If it doesn't have an exit transition defined, the element
		// will have simply disappeared completely at this point, and there will be no element through which to access the config.
		if data.transitionOut {
			config, isLayout := &(data.elementThisFrame.config.(ElementDeclaration))
			// Element wasn't found this frame - either delete transition data or transition out
			if hashMapItem.generation <= s.generation {
				parentHashMapItem := getHashMapItem(data.parentId)
				// Don't exit transition if the parent has also exited and SKIP_WHEN_PARENT_EXITS is used
				if isLayout &&
				   (config.transition.exit.trigger == .TRIGGER_WHEN_PARENT_EXITS ||
						   parentHashMapItem == nil ||
						   parentHashMapItem.generation > s.generation) {
					if data.state != .EXITING {
						if parentHashMapItem.generation <= s.generation {
							config.floating.attachTo = .ROOT
							config.floating.offset = [2]f32 {
								hashMapItem.boundingBox.x,
								hashMapItem.boundingBox.y,
							}
						}
						data.elementThisFrame.exiting = true
						config.layout.sizing.width = sizingFixed(
							data.elementThisFrame.dimensions.x,
						)
						config.layout.sizing.height = sizingFixed(
							data.elementThisFrame.dimensions.y,
						)
						data.state = .EXITING
						data.activeProperties = config.transition.properties
						data.elapsedTime = 0
						data.targetState = config.transition.exit.setFinalState(
							data.targetState,
							config.transition.properties,
						)
					}
					// Clone the entire subtree back into the main UI layout tree
					bfsBuffer := s.openLayoutElementStack
					bfsBuffer.len = 0
					data.elementThisFrame = arrayPush(&s.layoutElements, data.elementThisFrame^)
					exitingElementIndex := intrinsics.ptr_sub(
						data.elementThisFrame,
						&s.layoutElements.items[0],
					)

					arrayPush(
						&s.layoutElementIdStrings,
						arrayGet(s.layoutElementIdStrings, exitingElementIndex),
					)
					arrayPush(
						&s.layoutElementClipElementIds,
						arrayGet(s.layoutElementClipElementIds, exitingElementIndex),
					)
					arrayPush(&bfsBuffer, exitingElementIndex)
					hashMapItem.layoutElement = data.elementThisFrame
					hashMapItem.generation = s.generation + 1
					bufferIndex := 0
					for bufferIndex < bfsBuffer.len {
						layoutElement := arrayGetPtr(
							&s.layoutElements,
							arrayGet(bfsBuffer, bufferIndex),
						)
						bufferIndex += 1
						firstChildSlot := s.layoutElementChildren.len
						for layoutChildIdx in arrayIter(layoutElement.children) {
							childElement := arrayGetPtr(&s.layoutElements, layoutChildIdx)
							childElementIndex := intrinsics.ptr_sub(
								childElement,
								&(s.layoutElements.items[0]),
							)
							newChildElement := arrayPush(&s.layoutElements, childElement^)
							arrayPush(
								&s.layoutElementIdStrings,
								arrayGet(s.layoutElementIdStrings, childElementIndex),
							)
							arrayPush(
								&s.layoutElementClipElementIds,
								arrayGet(s.layoutElementClipElementIds, childElementIndex),
							)

							arrayPush(&bfsBuffer, s.layoutElements.len - 1)
							textConfig, isText := &(newChildElement.config.(TextDeclaration))
							if isText {
								textConfig.data.wrappedLines.len = 0
							}
							arrayPush(&s.layoutElementChildren, s.layoutElements.len - 1)
						}
						layoutElement.children.items = s.layoutElementChildren.items[firstChildSlot:]
						layoutElement.children.cap = s.layoutElementChildren.cap - firstChildSlot
					}

					// Reattach the inserted subtree to its previous parent if it still exists
					if parentHashMapItem.generation > s.generation {
						parentElement := parentHashMapItem.layoutElement
						newChildrenStartIndex := s.layoutElementChildren.len
						found := false
						if config.transition.exit.siblingOrdering == .UNDERNEATH_SIBLINGS {
							arrayPush(&s.layoutElementChildren, exitingElementIndex)
							found = true
						}
						for j := 0; j < parentElement.children.len; j += 1 {
							if config.transition.exit.siblingOrdering == .NATURAL_ORDER &&
							   u32(j) == data.siblingIdx {
								arrayPush(&s.layoutElementChildren, exitingElementIndex)
								found = true
							}
							arrayPush(&s.layoutElementChildren, parentElement.children.items[j])
						}
						if !found {
							arrayPush(&s.layoutElementChildren, exitingElementIndex)
						}
						parentElement.children.len += 1
						parentElement.children.items = s.layoutElementChildren.items[newChildrenStartIndex:]
						parentElement.children.cap =
							s.layoutElementChildren.cap - newChildrenStartIndex
					} else {
						arrayPush(
							&s.layoutElementTreeRoots,
							LayoutElementTreeRoot {
								layoutElementIdx = intrinsics.ptr_sub(
									data.elementThisFrame,
									&s.layoutElements.items[0],
								),
								parentId = hashString("Clay__RootContainer", 0).id,
								zIdx = 1,
							},
						)
					}
					// Parent exited, just delete child without exit transition
				} else {
					arraySwapback(&s.transitionDatas, i)
					i -= 1
					continue
				}
			}
			// Transition element exited and doesn't have an exit handler defined, delete the transition data
		} else if (hashMapItem.generation <= s.generation) {
			arraySwapback(&s.transitionDatas, i)
			i -= 1
			continue
		}
	}

	// End transition section
	if s.booleanWarnings.maxElementsExceeded {
		message := "Claydo Error: Layout elements exceeded maxElementCount"
		pushRenderCommand(
			RenderCommand {
				// what is this -59*4 thing???ß
				boundingBox = {
					s.layoutDimensions.x / 2.0 - 59 * 4,
					s.layoutDimensions.y / 2.0,
					0,
					0,
				},
				renderData = TextRenderData {
					text = message,
					color = Color({255, 0, 0, 255} / 255),
					fontSize = 16,
				},
				type = .TEXT,
			},
		)
	} else {
		// Start Transition 2
		if s.transitionDatas.len > 0 {
			calculateFinalLayout(deltaTime, false, false)
			for i := 0; i < s.transitionDatas.len; i += 1 {
				transitionData := arrayGetPtr(&s.transitionDatas, i)
				currentElement := transitionData.elementThisFrame
				config := &(currentElement.config.(ElementDeclaration))
				mapItem := getHashMapItem(transitionData.elementId)
				parentMapItem := getHashMapItem(transitionData.parentId)
				targetState := transitionData.targetState
				if transitionData.state != .EXITING {
					targetState = TransitionData {
						mapItem.boundingBox,
						config.backgroundColor,
						config.overlayColor,
						config.border.color,
						config.border.width,
					}
				}
				oldTargetState := transitionData.targetState
				transitionData.targetState = targetState
				if mapItem.appearedThisFrame {
					if config.transition.enter.setInitialState != nil &&
					   !(parentMapItem.appearedThisFrame &&
							   config.transition.enter.trigger == .SKIP_ON_FIRST_PARENT_FRAME) {
						transitionData.state = .ENTERING
						transitionData.initialState = config.transition.enter.setInitialState(
							transitionData.targetState,
							config.transition.properties,
						)
						transitionData.currentState = transitionData.initialState
						applyTransitionedPropertiesToElement(
							currentElement,
							config.transition.properties,
							transitionData.initialState,
							&mapItem.boundingBox,
							transitionData.reparented,
						)
					} else {
						transitionData.initialState = targetState
						transitionData.currentState = targetState
					}
				} else {
					parentConfig := &(parentMapItem.layoutElement.config.(ElementDeclaration))
					parentScrollOffset := parentConfig.clip.childOffset
					newRelativePosition := [2]f32 {
						mapItem.boundingBox.x - parentMapItem.boundingBox.x - parentScrollOffset.x,
						mapItem.boundingBox.y - parentMapItem.boundingBox.y - parentScrollOffset.y,
					}
					oldRelativePosition := transitionData.oldParentRelativePosition
					transitionData.oldParentRelativePosition = newRelativePosition

					properties := config.transition.properties
					activeProperties: bit_set[TransitionProperty] = {}
					if .X in properties {
						if !floatEquals(oldTargetState.boundingBox.x, targetState.boundingBox.x) &&
						   !floatEquals(oldRelativePosition.x, newRelativePosition.x) &&
						   !s.rootResizedLastFrame {
							activeProperties += {.X}
						}
					}
					if .Y in properties {
						if !floatEquals(oldTargetState.boundingBox.y, targetState.boundingBox.y) &&
						   !floatEquals(oldRelativePosition.y, newRelativePosition.y) &&
						   !s.rootResizedLastFrame {
							activeProperties += {.Y}
						}
					}
					if .WIDTH in properties {
						if !floatEquals(
							   oldTargetState.boundingBox.width,
							   targetState.boundingBox.width,
						   ) &&
						   !s.rootResizedLastFrame {
							activeProperties |= {.WIDTH}
						}
					}
					if .HEIGHT in properties {
						if !floatEquals(
							   oldTargetState.boundingBox.height,
							   targetState.boundingBox.height,
						   ) &&
						   !s.rootResizedLastFrame {
							activeProperties += {.HEIGHT}
						}
					}
					if .BACKGROUND_COLOR in properties {
						if oldTargetState.color != targetState.color {
							activeProperties += {.BACKGROUND_COLOR}
						}
					}
					if .OVERLAY_COLOR in properties {
						if oldTargetState.overlayColor != targetState.overlayColor {
							activeProperties += {.OVERLAY_COLOR}
						}
					}
					if .BORDER_COLOR in properties {
						if oldTargetState.borderColor != targetState.borderColor {
							activeProperties += {.BORDER_COLOR}
						}
					}
					if .BORDER_WIDTH in properties {
						if oldTargetState.borderWidth != targetState.borderWidth {
							activeProperties += {.BORDER_WIDTH}
						}
					}

					if activeProperties != {} && transitionData.state != .EXITING {
						transitionData.elapsedTime = 0
						transitionData.initialState = transitionData.currentState
						transitionData.state = .TRANSITIONING
						transitionData.activeProperties = activeProperties
					}

					if transitionData.state == .IDLE {
						transitionData.initialState = targetState
						transitionData.currentState = targetState
						transitionData.targetState = targetState
					} else {
						transitionComplete := true
						transitionComplete = config.transition.handler(
							TransitionCallbackArguments {
								transitionData.state,
								transitionData.initialState,
								&transitionData.currentState,
								targetState,
								transitionData.elapsedTime,
								config.transition.duration,
								config.transition.properties,
							},
						)
						applyTransitionedPropertiesToElement(
							currentElement,
							config.transition.properties,
							transitionData.currentState,
							&mapItem.boundingBox,
							transitionData.reparented,
						)
						transitionData.elapsedTime += deltaTime

						if transitionComplete {
							if transitionData.state == .ENTERING ||
							   transitionData.state == .TRANSITIONING {
								transitionData.state = .IDLE
								transitionData.elapsedTime = 0
								transitionData.reparented = false
								transitionData.activeProperties = {}
							} else if transitionData.state == .EXITING {
								arraySwapback(&s.transitionDatas, i)

							}
						}
					}
				}
			}

			if (s.debugModeEnabled) {
				s.warningsEnabled = false
				renderDebugView()
				s.warningsEnabled = true
			}


			if s.booleanWarnings.maxElementsExceeded {
				message := "Clay Error: Debug view caused layout element count to exceed Clay__maxElementCount"
				pushRenderCommand(
					RenderCommand {
						boundingBox = {
							s.layoutDimensions.x / 2 - 59 * 4,
							s.layoutDimensions.y / 2,
							0,
							0,
						},
						renderData = TextRenderData {
							text = message,
							color = ({255, 0, 0, 255} / 255),
							fontSize = 16,
						},
						type = .TEXT,
					},
				)
			} else {
				calculateFinalLayout(deltaTime, true, true)
				cloneElementsWithExitTransition()
			}
		} else {
			if s.debugModeEnabled {
				s.warningsEnabled = false
				renderDebugView()
				s.warningsEnabled = true
			}

			if s.booleanWarnings.maxElementsExceeded {
				message := "Clay Error: Debug view caused layout element count to exceed Clay__maxElementCount"
				pushRenderCommand(
					RenderCommand {
						boundingBox = {
							s.layoutDimensions.x / 2 - 59 * 4,
							s.layoutDimensions.y / 2,
							0,
							0,
						},
						renderData = TextRenderData {
							text = message,
							color = ({255, 0, 0, 255} / 255),
							fontSize = 16,
						},
						type = .TEXT,
					},
				)
			} else {
				calculateFinalLayout(deltaTime, false, true)
			}
		}
		// End Transition 2
	}
	if s.openLayoutElementStack.len > 1 {
		s.errorHandler.errProc(
			ErrorData {
				type = .UNBALANCED_OPEN_CLOSE,
				text = "There were still open layout elements when endLayout was called. This results from an unequal number of calls to openElement and closeElement.",
				userPtr = s.errorHandler.userPtr,
			},
		)
	}
	return s.renderCommands.items[:s.renderCommands.len]
}

applyTransitionedPropertiesToElement :: proc(
	currentElement: ^LayoutElement,
	properties: bit_set[TransitionProperty],
	currentTransitionData: TransitionData,
	boundingBox: ^BoundingBox,
	reparented: bool,
) {
	config, isLayout := &(currentElement.config.(ElementDeclaration))
	if .WIDTH in properties {
		if (!reparented) {
			currentElement.dimensions.x = currentTransitionData.boundingBox.width
			config.layout.sizing.width = sizingFixed(currentTransitionData.boundingBox.width)
		} else {
			boundingBox.width = currentTransitionData.boundingBox.width
		}
	}
	if .HEIGHT in properties {
		if (!reparented) {
			currentElement.dimensions.y = currentTransitionData.boundingBox.height
			config.layout.sizing.height = sizingFixed(currentTransitionData.boundingBox.height)
		} else {
			boundingBox.height = currentTransitionData.boundingBox.height
		}
	}
	if .X in properties {
		boundingBox.x = currentTransitionData.boundingBox.x
	}
	if .Y in properties {
		boundingBox.y = currentTransitionData.boundingBox.y
	}
	if .OVERLAY_COLOR in properties {
		config.overlayColor = currentTransitionData.overlayColor
	}
	if .BACKGROUND_COLOR in properties {
		config.backgroundColor = currentTransitionData.color
	}
	if .BORDER_COLOR in properties {
		config.border.color = currentTransitionData.borderColor
	}
	if .BORDER_WIDTH in properties {
		config.border.width = currentTransitionData.borderWidth
	}
}

getElementId :: proc(idString: string) -> ElementID {
	return hashString(idString, 0)
}

getElementIdWithIdx :: proc(idString: string, idx: u32) -> ElementID {
	return hashStringWithOffset(idString, idx, 0)
}

hovered :: proc() -> bool {
	if s.booleanWarnings.maxElementsExceeded {
		return false
	}
	openLayoutElement := getOpenLayoutElement()
	for id in arrayIter(s.pointerOverIds) {
		if openLayoutElement.id == id.id {
			return true
		}
	}
	return false
}

clicked :: proc() -> bool {
	return hovered() && s.pointerInfo.state == .PRESSED_THIS_FRAME
}

onHover :: proc(procedure: proc(_: ElementID, _: PointerData, _: rawptr), userPtr: rawptr) {
	if s.booleanWarnings.maxElementsExceeded {
		return
	}
	openLayoutElement := getOpenLayoutElement()
	hashMapItem := getHashMapItem(openLayoutElement.id)
	hashMapItem.onHoverFunction = procedure
	hashMapItem.hoverFunctionUserPtr = userPtr
}

pointerOver :: proc(elementId: ElementID) -> bool {
	for id in arrayIter(s.pointerOverIds) {
		if id.id == elementId.id {
			return true
		}
	}
	return false
}

getScrollContainerData :: proc(id: ElementID) -> ScrollContainerData {
	for &scrollContainerData in arrayIter(s.scrollContainerDatas) {
		if scrollContainerData.elementId == id.id {
			if scrollContainerData.layoutElement == nil {
				return {}
			}
			return ScrollContainerData {
				scrollPosition = &scrollContainerData.scrollPosition,
				dimensions = {
					scrollContainerData.boundingBox.width,
					scrollContainerData.boundingBox.height,
				},
				contentDimensions = scrollContainerData.contentSize,
				config = scrollContainerData.layoutElement.config.(ElementDeclaration).clip,
				found = true,
			}
		}
	}
	return {}
}

getElementData :: proc(id: ElementID) -> ElementData {
	item := getHashMapItem(id.id)
	if item == &DEFAULT_LAYOUT_ELEMENT_HASH_MAP_ITEM {
		return {}
	}
	return ElementData{boundingBox = item.boundingBox, found = true}
}

setDebugModeEnabled :: proc(enabled: bool) {
	s.debugModeEnabled = enabled
}

isDebugModeEnabled :: proc() -> bool {
	return s.debugModeEnabled
}

setCullingEnabled :: proc(enabled: bool) {
	s.disableCulling = !enabled
}

setExternalScrollHandlingEnabled :: proc(enabled: bool) {
	s.externalScrollHandlingEnabled = enabled
}

getMaxElementCount :: proc() -> int {
	return s.maxElementCount
}

setMaxElementCount :: proc(maxCount: int) -> bool {
	if s != nil {
		s.maxElementCount = maxCount
		return true
	} else {
		return false
	}
}

getMaxMeasureTextCacheWordCount :: proc() -> int {
	return s.maxMeasureTextCacheWordCount
}

setMaxMeasureTextCacheWordCount :: proc(count: int) -> bool {
	if s != nil {
		s.maxMeasureTextCacheWordCount = count
		return true
	} else {
		return false
	}
}

resetMeasureTextCache :: proc() {
	s.measureTextHashMapInternalFreeList.len = 0
	s.measureTextHashMap.len = 0
	s.measuredWords.len = 0
	s.measuredWordsFreeList.len = 0

	for i in 0 ..< s.measureTextHashMap.cap {
		s.measureTextHashMap.items[i] = 0
	}
	s.measureTextHashMapInternal.len = 1
}

@(deferred_none = closeElement)
uiWithId :: proc(id: ElementID) -> proc(config: ElementDeclaration) -> bool {
	openElementWithId(id)
	return configureOpenElement
}

@(deferred_none = closeElement)
uiAutoId :: proc() -> proc(config: ElementDeclaration) -> bool {
	openElement()
	return configureOpenElement
}

UI :: proc {
	uiWithId,
	uiAutoId,
}

text :: proc(text: string, config: TextElementConfig) {
	openTextElement(text, config)
}

paddingAll :: proc(all: f32) -> Padding {
	return {left = all, right = all, top = all, bottom = all}
}

borderOutside :: proc(width: f32) -> BorderWidth {
	return {width, width, width, width, 0}
}

borderAll :: proc(width: f32) -> BorderWidth {
	return {width, width, width, width, width}
}

cornerRadiusAll :: proc(radius: f32) -> CornerRadius {
	return {radius, radius, radius, radius}
}

sizingFit :: proc(min: f32 = 0, max: f32 = MAX_FLOAT) -> SizingAxis {
	return {.FIT, SizingMinMax{min, max}}
}

sizingGrow :: proc(min: f32 = 0, max: f32 = MAX_FLOAT) -> SizingAxis {
	return {.GROW, SizingMinMax{min, max}}
}

sizingFixed :: proc(size: f32 = 0) -> SizingAxis {
	return {.FIXED, SizingMinMax{size, size}}
}

sizingPercent :: proc(percent: f32 = 0) -> SizingAxis {
	return {.PERCENT, Percent(percent)}
}

id :: proc(label: string, index: u32 = 0) -> ElementID {
	return hashString(label, index)
}

idLocal :: proc(label: string, index: u32 = 0) -> ElementID {
	return hashStringWithOffset(label, index, getParentElementId())
}

lerp :: #force_inline proc(from, to, mix: f32) -> f32 {
	return from + (to - from) * mix
}

easeOut :: proc(arguments: TransitionCallbackArguments) -> bool {
	ratio: f32 = 1
	if arguments.duration > 0 {
		ratio = min(arguments.elapsedTime / arguments.duration, 1)
	}
	inverse := 1.0 - ratio
	lerpAmount := 1.0 - (inverse * inverse * inverse)
	if .X in arguments.properties {
		arguments.current.boundingBox.x = lerp(
			arguments.initial.boundingBox.x,
			arguments.target.boundingBox.x,
			lerpAmount,
		)
	}
	if .Y in arguments.properties {
		arguments.current.boundingBox.y = lerp(
			arguments.initial.boundingBox.y,
			arguments.target.boundingBox.y,
			lerpAmount,
		)
	}
	if .WIDTH in arguments.properties {
		arguments.current.boundingBox.width = lerp(
			arguments.initial.boundingBox.width,
			arguments.target.boundingBox.width,
			lerpAmount,
		)
	}
	if .HEIGHT in arguments.properties {
		arguments.current.boundingBox.height = lerp(
			arguments.initial.boundingBox.height,
			arguments.target.boundingBox.height,
			lerpAmount,
		)
	}
	if .BACKGROUND_COLOR in arguments.properties {
		arguments.current.color = Color {
			lerp(arguments.initial.color.r, arguments.target.color.r, lerpAmount),
			lerp(arguments.initial.color.g, arguments.target.color.g, lerpAmount),
			lerp(arguments.initial.color.b, arguments.target.color.b, lerpAmount),
			lerp(arguments.initial.color.a, arguments.target.color.a, lerpAmount),
		}
	}
	if .OVERLAY_COLOR in arguments.properties {
		arguments.current.overlayColor = Color {
			lerp(arguments.initial.overlayColor.r, arguments.target.overlayColor.r, lerpAmount),
			lerp(arguments.initial.overlayColor.g, arguments.target.overlayColor.g, lerpAmount),
			lerp(arguments.initial.overlayColor.b, arguments.target.overlayColor.b, lerpAmount),
			lerp(arguments.initial.overlayColor.a, arguments.target.overlayColor.a, lerpAmount),
		}
	}
	if .BORDER_COLOR in arguments.properties {
		arguments.current.borderColor = Color {
			lerp(arguments.initial.borderColor.r, arguments.target.borderColor.r, lerpAmount),
			lerp(arguments.initial.borderColor.g, arguments.target.borderColor.g, lerpAmount),
			lerp(arguments.initial.borderColor.b, arguments.target.borderColor.b, lerpAmount),
			lerp(arguments.initial.borderColor.a, arguments.target.borderColor.a, lerpAmount),
		}
	}
	if .BORDER_WIDTH in arguments.properties {
		arguments.current.borderWidth = BorderWidth {
			lerp(
				arguments.initial.borderWidth.left,
				arguments.target.borderWidth.left,
				lerpAmount,
			),
			lerp(
				arguments.initial.borderWidth.right,
				arguments.target.borderWidth.right,
				lerpAmount,
			),
			lerp(arguments.initial.borderWidth.top, arguments.target.borderWidth.top, lerpAmount),
			lerp(
				arguments.initial.borderWidth.bottom,
				arguments.target.borderWidth.bottom,
				lerpAmount,
			),
			lerp(
				arguments.initial.borderWidth.betweenChildren,
				arguments.target.borderWidth.betweenChildren,
				lerpAmount,
			),
		}
	}
	return ratio >= 1
}
