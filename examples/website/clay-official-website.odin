package main

import "../../claydo"
import "core:c"
import "core:fmt"
import "vendor:raylib"

windowWidth: i32 = 2048
windowHeight: i32 = 1400

syntaxImage: raylib.Texture2D = {}
checkImage1: raylib.Texture2D = {}
checkImage2: raylib.Texture2D = {}
checkImage3: raylib.Texture2D = {}
checkImage4: raylib.Texture2D = {}
checkImage5: raylib.Texture2D = {}

FONT_ID_BODY_16 :: 0
FONT_ID_TITLE_56 :: 9
FONT_ID_TITLE_52 :: 1
FONT_ID_TITLE_48 :: 2
FONT_ID_TITLE_36 :: 3
FONT_ID_TITLE_32 :: 4
FONT_ID_BODY_36 :: 5
FONT_ID_BODY_30 :: 6
FONT_ID_BODY_28 :: 7
FONT_ID_BODY_24 :: 8

COLOR_LIGHT := claydo.Color{244, 235, 230, 255} / 255
COLOR_LIGHT_HOVER := claydo.Color{224, 215, 210, 255} / 255
COLOR_BUTTON_HOVER := claydo.Color{238, 227, 225, 255} / 255
COLOR_BROWN := claydo.Color{61, 26, 5, 255} / 255
//COLOR_RED :: claydo.Color {252, 67, 27, 255} / 255
COLOR_RED := claydo.Color{168, 66, 28, 255} / 255
COLOR_RED_HOVER := claydo.Color{148, 46, 8, 255} / 255
COLOR_ORANGE := claydo.Color{225, 138, 50, 255} / 255
COLOR_BLUE := claydo.Color{111, 173, 162, 255} / 255
COLOR_TEAL := claydo.Color{111, 173, 162, 255} / 255
COLOR_BLUE_DARK := claydo.Color{2, 32, 82, 255} / 255

// Colors for top stripe
COLOR_TOP_BORDER_1 := claydo.Color{168, 66, 28, 255} / 255
COLOR_TOP_BORDER_2 := claydo.Color{223, 110, 44, 255} / 255
COLOR_TOP_BORDER_3 := claydo.Color{225, 138, 50, 255} / 255
COLOR_TOP_BORDER_4 := claydo.Color{236, 189, 80, 255} / 255
COLOR_TOP_BORDER_5 := claydo.Color{240, 213, 137, 255} / 255

COLOR_BLOB_BORDER_1 := claydo.Color{168, 66, 28, 255} / 255
COLOR_BLOB_BORDER_2 := claydo.Color{203, 100, 44, 255} / 255
COLOR_BLOB_BORDER_3 := claydo.Color{225, 138, 50, 255} / 255
COLOR_BLOB_BORDER_4 := claydo.Color{236, 159, 70, 255} / 255
COLOR_BLOB_BORDER_5 := claydo.Color{240, 189, 100, 255} / 255

headerTextConfig := claydo.TextElementConfig {
	fontId    = FONT_ID_BODY_24,
	fontSize  = 24,
	textColor = claydo.Color({61, 26, 5, 255} / 255),
}

border2pxRed := claydo.BorderElementConfig {
	width = {2, 2, 2, 2, 0},
	color = COLOR_RED,
}

LandingPageBlob :: proc(
	index: u32,
	fontSize: f32,
	fontId: u16,
	color: claydo.Color,
	$text: string,
	image: ^raylib.Texture2D,
) {
	if claydo.UI(claydo.id("HeroBlob", index))(
	{
		layout = {
			sizing = {width = claydo.sizingGrow(max = 480)},
			padding = claydo.paddingAll(16),
			childGap = 16,
		}, //childAlignment = claydo.ChildAlignment{ y = .CENTER } },
		border = border2pxRed,
		cornerRadius = claydo.cornerRadiusAll(10),
	},
	) {
		if claydo.UI(claydo.id("CheckImage", index))(
		{
			layout = {sizing = {width = claydo.sizingFixed(32)}},
			aspectRatio = 1.0,
			image = claydo.ImageData(image),
		},
		) {}
		claydo.text(text, {fontSize = fontSize, fontId = fontId, textColor = color})
	}
}

LandingPageDesktop :: proc() {
	if claydo.UI(claydo.id("LandingPage1Desktop"))(
	{
		layout = {
			sizing = {
				width = claydo.sizingGrow(),
				height = claydo.sizingFit(min = cast(f32)windowHeight - 70),
			},
			childAlignment = {y = .CENTER},
			padding = {left = 50, right = 50},
		},
	},
	) {
		if claydo.UI(claydo.id("LandingPage1"))(
		{
			layout = {
				sizing = {claydo.sizingGrow(), claydo.sizingGrow()},
				childAlignment = {y = .CENTER},
				padding = claydo.paddingAll(32),
				childGap = 32,
			},
			border = {COLOR_RED, {left = 2, right = 2}},
		},
		) {
			if claydo.UI(claydo.id("LeftText"))(
			{
				layout = {
					sizing = {width = claydo.sizingPercent(0.55)},
					direction = .TOP_TO_BOTTOM,
					childGap = 8,
				},
			},
			) {
				claydo.text(
					"Clay is a flex-box style UI auto layout library in C, with declarative syntax and microsecond performance.",
					{fontSize = 56, fontId = FONT_ID_TITLE_56, textColor = COLOR_RED},
				)
				if claydo.UI()(
				{
					layout = {
						sizing = {width = claydo.sizingGrow({}), height = claydo.sizingFixed(32)},
					},
				},
				) {}
				claydo.text(
					"Clay is laying out this webpage right now!",
					{fontSize = 36, fontId = FONT_ID_TITLE_36, textColor = COLOR_ORANGE},
				)
			}
			if claydo.UI(claydo.id("HeroImageOuter"))(
			{
				layout = {
					direction = .TOP_TO_BOTTOM,
					sizing = {width = claydo.sizingPercent(0.45)},
					childAlignment = {x = .CENTER},
					childGap = 16,
				},
			},
			) {
				LandingPageBlob(
					1,
					30,
					FONT_ID_BODY_30,
					COLOR_BLOB_BORDER_5,
					"High performance",
					&checkImage5,
				)
				LandingPageBlob(
					2,
					30,
					FONT_ID_BODY_30,
					COLOR_BLOB_BORDER_4,
					"Flexbox-style responsive layout",
					&checkImage4,
				)
				LandingPageBlob(
					3,
					30,
					FONT_ID_BODY_30,
					COLOR_BLOB_BORDER_3,
					"Declarative syntax",
					&checkImage3,
				)
				LandingPageBlob(
					4,
					30,
					FONT_ID_BODY_30,
					COLOR_BLOB_BORDER_2,
					"Single .h file for C/C++",
					&checkImage2,
				)
				LandingPageBlob(
					5,
					30,
					FONT_ID_BODY_30,
					COLOR_BLOB_BORDER_1,
					"Compile to 15kb .wasm",
					&checkImage1,
				)
			}
		}
	}
}

LandingPageMobile :: proc() {
	if claydo.UI(claydo.id("LandingPage1Mobile"))(
	{
		layout = {
			direction = .TOP_TO_BOTTOM,
			sizing = {
				width = claydo.sizingGrow(),
				height = claydo.sizingFit(min = cast(f32)windowHeight - 70),
			},
			childAlignment = {x = .CENTER, y = .CENTER},
			padding = {16, 16, 32, 32},
			childGap = 32,
		},
	},
	) {
		if claydo.UI(claydo.id("LeftText"))(
		{
			layout = {
				sizing = {width = claydo.sizingGrow()},
				direction = .TOP_TO_BOTTOM,
				childGap = 8,
			},
		},
		) {
			claydo.text(
				"Clay is a flex-box style UI auto layout library in C, with declarative syntax and microsecond performance.",
				{fontSize = 48, fontId = FONT_ID_TITLE_48, textColor = COLOR_RED},
			)
			if claydo.UI()(
			{layout = {sizing = {width = claydo.sizingGrow({}), height = claydo.sizingFixed(32)}}},
			) {}
			claydo.text(
				"Clay is laying out this webpage right now!",
				{fontSize = 32, fontId = FONT_ID_TITLE_32, textColor = COLOR_ORANGE},
			)
		}
		if claydo.UI(claydo.id("HeroImageOuter"))(
		{
			layout = {
				direction = .TOP_TO_BOTTOM,
				sizing = {width = claydo.sizingGrow()},
				childAlignment = {x = .CENTER},
				childGap = 16,
			},
		},
		) {
			LandingPageBlob(
				1,
				24,
				FONT_ID_BODY_24,
				COLOR_BLOB_BORDER_5,
				"High performance",
				&checkImage5,
			)
			LandingPageBlob(
				2,
				24,
				FONT_ID_BODY_24,
				COLOR_BLOB_BORDER_4,
				"Flexbox-style responsive layout",
				&checkImage4,
			)
			LandingPageBlob(
				3,
				24,
				FONT_ID_BODY_24,
				COLOR_BLOB_BORDER_3,
				"Declarative syntax",
				&checkImage3,
			)
			LandingPageBlob(
				4,
				24,
				FONT_ID_BODY_24,
				COLOR_BLOB_BORDER_2,
				"Single .h file for C/C++",
				&checkImage2,
			)
			LandingPageBlob(
				5,
				24,
				FONT_ID_BODY_24,
				COLOR_BLOB_BORDER_1,
				"Compile to 15kb .wasm",
				&checkImage1,
			)
		}
	}
}

FeatureBlocks :: proc(widthSizing: claydo.SizingAxis, outerPadding: f32) {
	textConfig := claydo.TextElementConfig {
		fontSize  = 24,
		fontId    = FONT_ID_BODY_24,
		textColor = COLOR_RED,
	}
	if claydo.UI(claydo.id("HFileBoxOuter"))(
	{
		layout = {
			direction = .TOP_TO_BOTTOM,
			sizing = {width = widthSizing},
			childAlignment = {y = .CENTER},
			padding = {outerPadding, outerPadding, 32, 32},
			childGap = 8,
		},
	},
	) {
		if claydo.UI(claydo.id("HFileIncludeOuter"))(
		{
			layout = {padding = {8, 8, 4, 4}},
			backgroundColor = COLOR_RED,
			cornerRadius = claydo.cornerRadiusAll(8),
		},
		) {
			claydo.text(
				"#include clay.h",
				{fontSize = 24, fontId = FONT_ID_BODY_24, textColor = COLOR_LIGHT},
			)
		}
		claydo.text("~2000 lines of C99.", textConfig)
		claydo.text("Zero dependencies, including no C standard library.", textConfig)
	}
	if claydo.UI(claydo.id("BringYourOwnRendererOuter"))(
	{
		layout = {
			direction = .TOP_TO_BOTTOM,
			sizing = {width = widthSizing},
			childAlignment = {y = .CENTER},
			padding = {outerPadding, outerPadding, 32, 32},
			childGap = 8,
		},
	},
	) {
		claydo.text(
			"Renderer agnostic.",
			{fontId = FONT_ID_BODY_24, fontSize = 24, textColor = COLOR_ORANGE},
		)
		claydo.text(
			"Layout with clay, then render with Raylib, WebGL Canvas or even as HTML.",
			textConfig,
		)
		claydo.text(
			"Flexible output for easy compositing in your custom engine or environment.",
			textConfig,
		)
	}
}

FeatureBlocksDesktop :: proc() {
	if claydo.UI(claydo.id("FeatureBlocksOuter"))(
	{layout = {sizing = {width = claydo.sizingGrow({})}}},
	) {
		if claydo.UI(claydo.id("FeatureBlocksInner"))(
		{
			layout = {sizing = {width = claydo.sizingGrow()}, childAlignment = {y = .CENTER}},
			border = {width = {betweenChildren = 2}, color = COLOR_RED},
		},
		) {
			FeatureBlocks(claydo.sizingPercent(0.5), 50)
		}
	}
}

FeatureBlocksMobile :: proc() {
	if claydo.UI(claydo.id("FeatureBlocksInner"))(
	{
		layout = {direction = .TOP_TO_BOTTOM, sizing = {width = claydo.sizingGrow()}},
		border = {width = {betweenChildren = 2}, color = COLOR_RED},
	},
	) {
		FeatureBlocks(claydo.sizingGrow({}), 16)
	}
}

DeclarativeSyntaxPage :: proc(
	titleTextConfig: claydo.TextElementConfig,
	widthSizing: claydo.SizingAxis,
) {
	if claydo.UI(claydo.id("SyntaxPageLeftText"))(
	{layout = {sizing = {width = widthSizing}, direction = .TOP_TO_BOTTOM, childGap = 8}},
	) {
		claydo.text("Declarative Syntax", titleTextConfig)
		if claydo.UI(claydo.id("SyntaxSpacer"))(
		{layout = {sizing = {width = claydo.sizingGrow(max = 16)}}},
		) {}
		claydo.text(
			"Flexible and readable declarative syntax with nested UI element hierarchies.",
			{fontSize = 28, fontId = FONT_ID_BODY_28, textColor = COLOR_RED},
		)
		claydo.text(
			"Mix elements with standard C code like loops, conditionals and functions.",
			{fontSize = 28, fontId = FONT_ID_BODY_28, textColor = COLOR_RED},
		)
		claydo.text(
			"Create your own library of re-usable components from UI primitives like text, images and rectangles.",
			{fontSize = 28, fontId = FONT_ID_BODY_28, textColor = COLOR_RED},
		)
	}
	if claydo.UI(claydo.id("SyntaxPageRightImage"))(
	{layout = {sizing = {width = widthSizing}, childAlignment = {x = .CENTER}}},
	) {
		if claydo.UI(claydo.id("SyntaxPageRightImageInner"))(
		{
			layout = {sizing = {width = claydo.sizingGrow(max = 568)}},
			aspectRatio = 1136.0 / 1194.0,
			image = claydo.ImageData(&syntaxImage),
		},
		) {}
	}
}

DeclarativeSyntaxPageDesktop :: proc() {
	if claydo.UI(claydo.id("SyntaxPageDesktop"))(
	{
		layout = {
			sizing = {claydo.sizingGrow(), claydo.sizingFit(min = cast(f32)windowHeight - 50)},
			childAlignment = {y = .CENTER},
			padding = {left = 50, right = 50},
		},
	},
	) {
		if claydo.UI(claydo.id("SyntaxPage"))(
		{
			layout = {
				sizing = {claydo.sizingGrow(), claydo.sizingGrow()},
				childAlignment = {y = .CENTER},
				padding = claydo.paddingAll(32),
				childGap = 32,
			},
			border = border2pxRed,
		},
		) {
			DeclarativeSyntaxPage(
				{fontSize = 52, fontId = FONT_ID_TITLE_52, textColor = COLOR_RED},
				claydo.sizingPercent(0.5),
			)
		}
	}
}

DeclarativeSyntaxPageMobile :: proc() {
	if claydo.UI(claydo.id("SyntaxPageMobile"))(
	{
		layout = {
			direction = .TOP_TO_BOTTOM,
			sizing = {claydo.sizingGrow(), claydo.sizingFit(min = cast(f32)windowHeight - 50)},
			childAlignment = {x = .CENTER, y = .CENTER},
			padding = {16, 16, 32, 32},
			childGap = 16,
		},
	},
	) {
		DeclarativeSyntaxPage(
			{fontSize = 48, fontId = FONT_ID_TITLE_48, textColor = COLOR_RED},
			claydo.sizingGrow({}),
		)
	}
}

ColorLerp :: proc(a: claydo.Color, b: claydo.Color, amount: f32) -> claydo.Color {
	return claydo.Color {
		a.r + (b.r - a.r) * amount,
		a.g + (b.g - a.g) * amount,
		a.b + (b.b - a.b) * amount,
		a.a + (b.a - a.a) * amount,
	}
}

LOREM_IPSUM_TEXT :: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."

HighPerformancePage :: proc(
	lerpValue: f32,
	titleTextConfig: claydo.TextElementConfig,
	widthSizing: claydo.SizingAxis,
) {
	if claydo.UI(claydo.id("PerformanceLeftText"))(
	{layout = {sizing = {width = widthSizing}, direction = .TOP_TO_BOTTOM, childGap = 8}},
	) {
		claydo.text("High Performance", titleTextConfig)
		if claydo.UI()({layout = {sizing = {width = claydo.sizingGrow(max = 16)}}}) {}
		claydo.text(
			"Fast enough to recompute your entire UI every frame.",
			{fontSize = 28, fontId = FONT_ID_BODY_36, textColor = COLOR_LIGHT},
		)
		claydo.text(
			"Small memory footprint (3.5mb default) with static allocation & reuse. No malloc / free.",
			{fontSize = 28, fontId = FONT_ID_BODY_36, textColor = COLOR_LIGHT},
		)
		claydo.text(
			"Simplify animations and reactive UI design by avoiding the standard performance hacks.",
			{fontSize = 28, fontId = FONT_ID_BODY_36, textColor = COLOR_LIGHT},
		)
	}
	if claydo.UI(claydo.id("PerformanceRightImageOuter"))(
	{layout = {sizing = {width = widthSizing}, childAlignment = {x = .CENTER}}},
	) {
		if claydo.UI(claydo.id("PerformanceRightBorder"))(
		{
			layout = {sizing = {claydo.sizingGrow(), claydo.sizingFixed(400)}},
			border = {COLOR_LIGHT, {2, 2, 2, 2, 2}},
		},
		) {
			if claydo.UI(claydo.id("AnimationDemoContainerLeft"))(
			{
				layout = {
					sizing = {claydo.sizingPercent(0.35 + 0.3 * lerpValue), claydo.sizingGrow()},
					childAlignment = {y = .CENTER},
					padding = claydo.paddingAll(16),
				},
				backgroundColor = ColorLerp(COLOR_RED, COLOR_ORANGE, lerpValue),
			},
			) {
				claydo.text(
					LOREM_IPSUM_TEXT,
					{fontSize = 16, fontId = FONT_ID_BODY_16, textColor = COLOR_LIGHT},
				)
			}
			if claydo.UI(claydo.id("AnimationDemoContainerRight"))(
			{
				layout = {
					sizing = {claydo.sizingGrow(), claydo.sizingGrow()},
					childAlignment = {y = .CENTER},
					padding = claydo.paddingAll(16),
				},
				backgroundColor = ColorLerp(COLOR_ORANGE, COLOR_RED, lerpValue),
			},
			) {
				claydo.text(
					LOREM_IPSUM_TEXT,
					{fontSize = 16, fontId = FONT_ID_BODY_16, textColor = COLOR_LIGHT},
				)
			}
		}
	}
}

HighPerformancePageDesktop :: proc(lerpValue: f32) {
	if claydo.UI(claydo.id("PerformanceDesktop"))(
	{
		layout = {
			sizing = {claydo.sizingGrow(), claydo.sizingFit(min = cast(f32)windowHeight - 50)},
			childAlignment = {y = .CENTER},
			padding = {82, 82, 32, 32},
			childGap = 64,
		},
		backgroundColor = COLOR_RED,
	},
	) {
		HighPerformancePage(
			lerpValue,
			{fontSize = 52, fontId = FONT_ID_TITLE_52, textColor = COLOR_LIGHT},
			claydo.sizingPercent(0.5),
		)
	}
}

HighPerformancePageMobile :: proc(lerpValue: f32) {
	if claydo.UI(claydo.id("PerformanceMobile"))(
	{
		layout = {
			direction = .TOP_TO_BOTTOM,
			sizing = {claydo.sizingGrow(), claydo.sizingFit(min = cast(f32)windowHeight - 50)},
			childAlignment = {x = .CENTER, y = .CENTER},
			padding = {16, 16, 32, 32},
			childGap = 32,
		},
		backgroundColor = COLOR_RED,
	},
	) {
		HighPerformancePage(
			lerpValue,
			{fontSize = 48, fontId = FONT_ID_TITLE_48, textColor = COLOR_LIGHT},
			claydo.sizingGrow({}),
		)
	}
}

RendererButtonActive :: proc(index: i32, $text: string) {
	if claydo.UI()(
	{
		layout = {sizing = {width = claydo.sizingFixed(300)}, padding = claydo.paddingAll(16)},
		backgroundColor = COLOR_RED,
		cornerRadius = claydo.cornerRadiusAll(10),
	},
	) {
		claydo.text(text, {fontSize = 28, fontId = FONT_ID_BODY_28, textColor = COLOR_LIGHT})
	}
}

RendererButtonInactive :: proc(index: u32, $text: string) {
	if claydo.UI()({border = border2pxRed}) {
		if claydo.UI(claydo.id("RendererButtonInactiveInner", index))(
		{
			layout = {sizing = {width = claydo.sizingFixed(300)}, padding = claydo.paddingAll(16)},
			color = COLOR_LIGHT,
			cornerRadius = claydo.cornerRadiusAll(10),
		},
		) {
			claydo.text(text, {fontSize = 28, fontId = FONT_ID_BODY_28, textColor = COLOR_RED})
		}
	}
}

RendererPage :: proc(titleTextConfig: claydo.TextElementConfig, widthSizing: claydo.SizingAxis) {
	if claydo.UI(claydo.id("RendererLeftText"))(
	{layout = {sizing = {width = widthSizing}, direction = .TOP_TO_BOTTOM, childGap = 8}},
	) {
		claydo.text("Renderer & Platform Agnostic", titleTextConfig)
		if claydo.UI()({layout = {sizing = {width = claydo.sizingGrow(max = 16)}}}) {}
		claydo.text(
			"Clay outputs a sorted array of primitive render commands, such as RECTANGLE, TEXT or IMAGE.",
			{fontSize = 28, fontId = FONT_ID_BODY_36, textColor = COLOR_RED},
		)
		claydo.text(
			"Write your own renderer in a few hundred lines of code, or use the provided examples for Raylib, WebGL canvas and more.",
			{fontSize = 28, fontId = FONT_ID_BODY_36, textColor = COLOR_RED},
		)
		claydo.text(
			"There's even an HTML renderer - you're looking at it right now!",
			{fontSize = 28, fontId = FONT_ID_BODY_36, textColor = COLOR_RED},
		)
	}
	if claydo.UI(claydo.id("RendererRightText"))(
	{
		layout = {
			sizing = {width = widthSizing},
			childAlignment = {x = .CENTER},
			direction = .TOP_TO_BOTTOM,
			childGap = 16,
		},
	},
	) {
		claydo.text(
			"Try changing renderer!",
			{fontSize = 36, fontId = FONT_ID_BODY_36, textColor = COLOR_ORANGE},
		)
		if claydo.UI()({layout = {sizing = {width = claydo.sizingGrow(max = 32)}}}) {}
		RendererButtonActive(0, "Raylib Renderer")
	}
}

RendererPageDesktop :: proc() {
	if claydo.UI(claydo.id("RendererPageDesktop"))(
	{
		layout = {
			sizing = {claydo.sizingGrow(), claydo.sizingFit(min = cast(f32)windowHeight - 50)},
			childAlignment = {y = .CENTER},
			padding = {left = 50, right = 50},
		},
	},
	) {
		if claydo.UI(claydo.id("RendererPage"))(
		{
			layout = {
				sizing = {claydo.sizingGrow(), claydo.sizingGrow()},
				childAlignment = {y = .CENTER},
				padding = claydo.paddingAll(32),
				childGap = 32,
			},
			border = {COLOR_RED, {left = 2, right = 2}},
		},
		) {
			RendererPage(
				{fontSize = 52, fontId = FONT_ID_TITLE_52, textColor = COLOR_RED},
				claydo.sizingPercent(0.5),
			)
		}
	}
}

RendererPageMobile :: proc() {
	if claydo.UI(claydo.id("RendererMobile"))(
	{
		layout = {
			direction = .TOP_TO_BOTTOM,
			sizing = {claydo.sizingGrow(), claydo.sizingFit(min = cast(f32)windowHeight - 50)},
			childAlignment = {x = .CENTER, y = .CENTER},
			padding = {16, 16, 32, 32},
			childGap = 32,
		},
		backgroundColor = COLOR_LIGHT,
	},
	) {
		RendererPage(
			{fontSize = 48, fontId = FONT_ID_TITLE_48, textColor = COLOR_RED},
			claydo.sizingGrow({}),
		)
	}
}

ScrollbarData :: struct {
	clickOrigin:    [2]f32,
	positionOrigin: [2]f32,
	mouseDown:      bool,
}

scrollbarData := ScrollbarData{}
animationLerpValue: f32 = -1.0

createLayout :: proc(lerpValue: f32, dt: f32) -> []claydo.RenderCommand {
	mobileScreen := windowWidth < 750
	claydo.beginLayout()
	if claydo.UI(claydo.id("OuterContainer"))(
	{
		layout = {direction = .TOP_TO_BOTTOM, sizing = {claydo.sizingGrow(), claydo.sizingGrow()}},
		backgroundColor = COLOR_LIGHT,
	},
	) {
		if claydo.UI(claydo.id("Header"))(
		{
			layout = {
				direction = .LEFT_TO_RIGHT,
				sizing = {claydo.sizingGrow(), claydo.sizingFixed(50)},
				childAlignment = {y = .CENTER},
				childGap = 24,
				padding = {left = 32, right = 32},
			},
		},
		) {
			// This will blow up since it's too many elements
			claydo.text(
				"Docs",
				{
					fontId = FONT_ID_BODY_24,
					fontSize = 24,
					textColor = claydo.Color({61, 26, 5, 255} / 255),
				},
			)
			claydo.text("Clay", headerTextConfig)
			if claydo.UI()({layout = {sizing = {width = claydo.sizingGrow()}}}) {}

			if (!mobileScreen) {
				if claydo.UI(claydo.id("LinkExamplesOuter"))({backgroundColor = {0, 0, 0, 0}}) {
					claydo.text(
						"Examples",
						{
							fontId = FONT_ID_BODY_24,
							fontSize = 24,
							textColor = claydo.Color({61, 26, 5, 255} / 255),
						},
					)
				}
				if claydo.UI(claydo.id("LinkDocsOuter"))({backgroundColor = {0, 0, 0, 0}}) {
					claydo.text(
						"Docs",
						{
							fontId = FONT_ID_BODY_24,
							fontSize = 24,
							textColor = claydo.Color({61, 26, 5, 255} / 255),
						},
					)
				}
			}
			if claydo.UI(claydo.id("LinkGithubOuter"))(
			{
				layout = {padding = {16, 16, 6, 6}},
				border = border2pxRed,
				backgroundColor = claydo.hovered() ? COLOR_LIGHT_HOVER : COLOR_LIGHT,
				cornerRadius = claydo.cornerRadiusAll(10),
			},
			) {
				claydo.text(
					"Github",
					{
						fontId = FONT_ID_BODY_24,
						fontSize = 24,
						textColor = claydo.Color({61, 26, 5, 255} / 255),
					},
				)
			}
		}
		if claydo.UI(claydo.id("TopBorder1"))(
		{
			layout = {sizing = {claydo.sizingGrow(), claydo.sizingFixed(4)}},
			backgroundColor = COLOR_TOP_BORDER_5,
		},
		) {}
		if claydo.UI(claydo.id("TopBorder2"))(
		{
			layout = {sizing = {claydo.sizingGrow(), claydo.sizingFixed(4)}},
			backgroundColor = COLOR_TOP_BORDER_4,
		},
		) {}
		if claydo.UI(claydo.id("TopBorder3"))(
		{
			layout = {sizing = {claydo.sizingGrow(), claydo.sizingFixed(4)}},
			backgroundColor = COLOR_TOP_BORDER_3,
		},
		) {}
		if claydo.UI(claydo.id("TopBorder4"))(
		{
			layout = {sizing = {claydo.sizingGrow(), claydo.sizingFixed(4)}},
			backgroundColor = COLOR_TOP_BORDER_2,
		},
		) {}
		if claydo.UI(claydo.id("TopBorder5"))(
		{
			layout = {sizing = {claydo.sizingGrow(), claydo.sizingFixed(4)}},
			backgroundColor = COLOR_TOP_BORDER_1,
		},
		) {}
		if claydo.UI(claydo.id("ScrollContainerBackgroundRectangle"))(
		{
			clip = {vertical = true, childOffset = claydo.getScrollOffset()},
			layout = {
				sizing = {claydo.sizingGrow(), claydo.sizingGrow()},
				direction = .TOP_TO_BOTTOM,
			},
			backgroundColor = COLOR_LIGHT,
			border = {COLOR_RED, {betweenChildren = 2}},
		},
		) {
			if (!mobileScreen) {
				LandingPageDesktop()
				FeatureBlocksDesktop()
				DeclarativeSyntaxPageDesktop()
				HighPerformancePageDesktop(lerpValue)
				RendererPageDesktop()
			} else {
				LandingPageMobile()
				FeatureBlocksMobile()
				DeclarativeSyntaxPageMobile()
				HighPerformancePageMobile(lerpValue)
				RendererPageMobile()
			}
		}
	}
	return claydo.endLayout(dt)
}

loadFont :: proc(fontId: u16, fontSize: u16, path: cstring) {
	assign_at(
		&raylibFonts,
		fontId,
		RaylibFont {
			font = raylib.LoadFontEx(path, cast(i32)fontSize * 2, nil, 0),
			fontId = cast(u16)fontId,
		},
	)
	raylib.SetTextureFilter(raylibFonts[fontId].font.texture, raylib.TextureFilter.TRILINEAR)
}

errorHandler :: proc(errorData: claydo.ErrorData) {
	if (errorData.type == .DUPLICATE_ID) {
		// etc
	}
}

main :: proc() {
	minMemorySize := claydo.minMemorySize()
	fmt.println("ARENA CAPACITY", minMemorySize)
	arena: claydo.Arena = claydo.createArenaWithCapacity(minMemorySize)
	claydo.initialize(
		arena,
		{cast(f32)raylib.GetScreenWidth(), cast(f32)raylib.GetScreenHeight()},
		{errProc = errorHandler},
	)
	claydo.setMeasureTextProcedure(measureText, nil)

	raylib.SetConfigFlags({.VSYNC_HINT, .WINDOW_RESIZABLE, .MSAA_4X_HINT})
	raylib.InitWindow(windowWidth, windowHeight, "Raylib Odin Example")
	raylib.SetTargetFPS(raylib.GetMonitorRefreshRate(0))
	loadFont(FONT_ID_TITLE_56, 56, "resources/Calistoga-Regular.ttf")
	loadFont(FONT_ID_TITLE_52, 52, "resources/Calistoga-Regular.ttf")
	loadFont(FONT_ID_TITLE_48, 48, "resources/Calistoga-Regular.ttf")
	loadFont(FONT_ID_TITLE_36, 36, "resources/Calistoga-Regular.ttf")
	loadFont(FONT_ID_TITLE_32, 32, "resources/Calistoga-Regular.ttf")
	loadFont(FONT_ID_BODY_36, 36, "resources/Quicksand-Semibold.ttf")
	loadFont(FONT_ID_BODY_30, 30, "resources/Quicksand-Semibold.ttf")
	loadFont(FONT_ID_BODY_28, 28, "resources/Quicksand-Semibold.ttf")
	loadFont(FONT_ID_BODY_24, 24, "resources/Quicksand-Semibold.ttf")
	loadFont(FONT_ID_BODY_16, 16, "resources/Quicksand-Semibold.ttf")

	syntaxImage = raylib.LoadTexture("resources/declarative.png")
	checkImage1 = raylib.LoadTexture("resources/check_1.png")
	checkImage2 = raylib.LoadTexture("resources/check_2.png")
	checkImage3 = raylib.LoadTexture("resources/check_3.png")
	checkImage4 = raylib.LoadTexture("resources/check_4.png")
	checkImage5 = raylib.LoadTexture("resources/check_5.png")

	debugModeEnabled: bool = false

	for !raylib.WindowShouldClose() {
		dt := raylib.GetFrameTime()
		defer free_all(context.temp_allocator)

		animationLerpValue += raylib.GetFrameTime()
		if animationLerpValue > 1 {
			animationLerpValue = animationLerpValue - 2
		}
		windowWidth = raylib.GetScreenWidth()
		windowHeight = raylib.GetScreenHeight()
		if (raylib.IsKeyPressed(.D)) {
			debugModeEnabled = !debugModeEnabled
			claydo.setDebugModeEnabled(debugModeEnabled)
		}
		claydo.setCursorState(
			transmute([2]f32)raylib.GetMousePosition(),
			raylib.IsMouseButtonDown(raylib.MouseButton.LEFT),
		)
		claydo.updateScrollContainers(
			false,
			transmute([2]f32)raylib.GetMouseWheelMoveV(),
			raylib.GetFrameTime(),
		)
		claydo.setLayoutDimensions(
			{cast(f32)raylib.GetScreenWidth(), cast(f32)raylib.GetScreenHeight()},
		)
		renderCommands: []claydo.RenderCommand = createLayout(
			animationLerpValue < 0 ? (animationLerpValue + 1) : (1 - animationLerpValue),
			dt,
		)
		raylib.BeginDrawing()
		clayRaylibRender(renderCommands)
		raylib.EndDrawing()
	}
}
