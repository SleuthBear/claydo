package main

import "../claydo"
import "core:c"
import "core:fmt"
import "vendor:raylib"

windowWidth: i32 = 1024
windowHeight: i32 = 768

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

headerTextConfig := claydo.Text_Element_Config {
    font_id   = FONT_ID_BODY_24,
    font_size  = 24,
    text_color = claydo.Color({61, 26, 5, 255} / 255),
}

border2pxRed := claydo.Border_Element_Config {
    width = { 2, 2, 2, 2, 0 },
    color = COLOR_RED
}

LandingPageBlob :: proc(index: u32, font_size: f32, font_id: u16, color: claydo.Color, $text: string, image: ^raylib.Texture2D) {
    if claydo.ui(claydo.id("HeroBlob", index))({
        layout = { sizing = { width = claydo.sizing_grow(max = 480) }, padding = claydo.padding_all(16), child_gap = 16, child_alignment = claydo.Child_Alignment{ y = .CENTER } },
        border = border2pxRed,
        corner_radius = claydo.corner_radius_all(10)
    }) {
        if claydo.ui(claydo.id("CheckImage", index))({
            layout = { sizing = { width = claydo.sizing_fixed(32) } },
            aspect_ratio = 1.0,
            image = claydo.Image_Data(image),
        }) {}
        claydo.text(text, claydo.text_config({font_size = font_size, font_id = font_id, text_color = color}))
    }
}

LandingPageDesktop :: proc() {
    if claydo.ui(claydo.id("LandingPage1Desktop"))({
        layout = { sizing = { width = claydo.sizing_grow(), height = claydo.sizing_fit(min = cast(f32)windowHeight - 70) }, child_alignment = { y = .CENTER }, padding = { left = 50, right = 50 } },
    }) {
        if claydo.ui(claydo.id("LandingPage1"))({
            layout = { sizing = { claydo.sizing_grow(), claydo.sizing_grow() }, child_alignment = { y = .CENTER }, padding = claydo.padding_all(32), child_gap = 32 },
            border = { COLOR_RED, { left = 2, right = 2 } },
        }) {
            if claydo.ui(claydo.id("LeftText"))({ layout = { sizing = { width = claydo.sizing_percent(0.55) }, direction = .TOP_TO_BOTTOM, child_gap = 8 } }) {
                claydo.text(
                    "Clay is a flex-box style UI auto layout library in C, with declarative syntax and microsecond performance.",
                    claydo.text_config({font_size = 56, font_id = FONT_ID_TITLE_56, text_color = COLOR_RED}),
                )
                if claydo.ui()({ layout = { sizing = { width = claydo.sizing_grow({}), height = claydo.sizing_fixed(32) } } }) {}
                claydo.text(
                    "Clay is laying out this webpage right now!",
                    claydo.text_config({font_size = 36, font_id = FONT_ID_TITLE_36, text_color = COLOR_ORANGE}),
                )
            }
            if claydo.ui(claydo.id("HeroImageOuter"))({
                layout = { direction = .TOP_TO_BOTTOM, sizing = { width = claydo.sizing_percent(0.45) }, child_alignment = { x = .CENTER }, child_gap = 16 },
            }) {
                LandingPageBlob(1, 30, FONT_ID_BODY_30, COLOR_BLOB_BORDER_5, "High performance", &checkImage5)
                LandingPageBlob(2, 30, FONT_ID_BODY_30, COLOR_BLOB_BORDER_4, "Flexbox-style responsive layout", &checkImage4)
                LandingPageBlob(3, 30, FONT_ID_BODY_30, COLOR_BLOB_BORDER_3, "Declarative syntax", &checkImage3)
                LandingPageBlob(4, 30, FONT_ID_BODY_30, COLOR_BLOB_BORDER_2, "Single .h file for C/C++", &checkImage2)
                LandingPageBlob(5, 30, FONT_ID_BODY_30, COLOR_BLOB_BORDER_1, "Compile to 15kb .wasm", &checkImage1)
            }
        }
    }
}

LandingPageMobile :: proc() {
    if claydo.ui(claydo.id("LandingPage1Mobile"))({
        layout = {
            direction = .TOP_TO_BOTTOM,
            sizing = { width = claydo.sizing_grow(), height = claydo.sizing_fit(min = cast(f32)windowHeight - 70 ) },
            child_alignment = { x = .CENTER, y = .CENTER },
            padding = { 16, 16, 32, 32 },
            child_gap = 32,
        },
    }) {
        if claydo.ui(claydo.id("LeftText"))({ layout = { sizing = { width = claydo.sizing_grow() }, direction = .TOP_TO_BOTTOM, child_gap = 8 } }) {
            claydo.text(
                "Clay is a flex-box style UI auto layout library in C, with declarative syntax and microsecond performance.",
                claydo.text_config({font_size = 48, font_id = FONT_ID_TITLE_48, text_color = COLOR_RED}),
            )
            if claydo.ui()({ layout = { sizing = { width = claydo.sizing_grow({}), height = claydo.sizing_fixed(32) } } }) {}
            claydo.text(
                "Clay is laying out this webpage right now!",
                claydo.text_config({font_size = 32, font_id = FONT_ID_TITLE_32, text_color = COLOR_ORANGE}),
            )
        }
        if claydo.ui(claydo.id("HeroImageOuter"))({
            layout = { direction = .TOP_TO_BOTTOM, sizing = { width = claydo.sizing_grow() }, child_alignment = { x = .CENTER }, child_gap = 16 },
        }) {
            LandingPageBlob(1, 24, FONT_ID_BODY_24, COLOR_BLOB_BORDER_5, "High performance", &checkImage5)
            LandingPageBlob(2, 24, FONT_ID_BODY_24, COLOR_BLOB_BORDER_4, "Flexbox-style responsive layout", &checkImage4)
            LandingPageBlob(3, 24, FONT_ID_BODY_24, COLOR_BLOB_BORDER_3, "Declarative syntax", &checkImage3)
            LandingPageBlob(4, 24, FONT_ID_BODY_24, COLOR_BLOB_BORDER_2, "Single .h file for C/C++", &checkImage2)
            LandingPageBlob(5, 24, FONT_ID_BODY_24, COLOR_BLOB_BORDER_1, "Compile to 15kb .wasm", &checkImage1)
        }
    }
}

FeatureBlocks :: proc(widthSizing: claydo.Sizing_Axis, outerPadding: f32) {
    textConfig := claydo.text_config({font_size = 24, font_id = FONT_ID_BODY_24, text_color = COLOR_RED})
    if claydo.ui(claydo.id("HFileBoxOuter"))({
        layout = { direction = .TOP_TO_BOTTOM, sizing = { width = widthSizing }, child_alignment = { y = .CENTER }, padding = { outerPadding, outerPadding, 32, 32 }, child_gap = 8 },
    }) {
        if claydo.ui(claydo.id("HFileIncludeOuter"))({ layout = { padding = { 8, 8, 4, 4 } }, color = COLOR_RED, corner_radius = claydo.corner_radius_all(8) }) {
            claydo.text("#include claydo.h", claydo.text_config({font_size = 24, font_id = FONT_ID_BODY_24, text_color = COLOR_LIGHT}))
        }
        claydo.text("~2000 lines of C99.", textConfig)
        claydo.text("Zero dependencies, including no C standard library.", textConfig)
    }
    if claydo.ui(claydo.id("BringYourOwnRendererOuter"))({
        layout = { direction = .TOP_TO_BOTTOM, sizing = { width = widthSizing }, child_alignment = { y = .CENTER }, padding = { outerPadding, outerPadding, 32, 32 }, child_gap = 8 },
    }) {
        claydo.text("Renderer agnostic.", claydo.text_config({font_id = FONT_ID_BODY_24, font_size = 24, text_color = COLOR_ORANGE}))
        claydo.text("Layout with clay, then render with Raylib, WebGL Canvas or even as HTML.", textConfig)
        claydo.text("Flexible output for easy compositing in your custom engine or environment.", textConfig)
    }
}

FeatureBlocksDesktop :: proc() {
    if claydo.ui(claydo.id("FeatureBlocksOuter"))({ layout = { sizing = { width = claydo.sizing_grow({}) } } }) {
        if claydo.ui(claydo.id("FeatureBlocksInner"))({
            layout = { sizing = { width = claydo.sizing_grow() }, child_alignment = { y = .CENTER } },
            border = { width = { between_children = 2}, color = COLOR_RED },
        }) {
            FeatureBlocks(claydo.sizing_percent(0.5), 50)
        }
    }
}

FeatureBlocksMobile :: proc() {
    if claydo.ui(claydo.id("FeatureBlocksInner"))({
        layout = { direction = .TOP_TO_BOTTOM, sizing = { width = claydo.sizing_grow() } },
        border = { width = { between_children = 2}, color = COLOR_RED },
    }) {
        FeatureBlocks(claydo.sizing_grow({}), 16)
    }
}

DeclarativeSyntaxPage :: proc(titleTextConfig: claydo.Text_Element_Config, widthSizing: claydo.Sizing_Axis) {
    if claydo.ui(claydo.id("SyntaxPageLeftText"))({ layout = { sizing = { width = widthSizing }, direction = .TOP_TO_BOTTOM, child_gap = 8 } }) {
        claydo.text("Declarative Syntax", claydo.text_config(titleTextConfig))
        if claydo.ui(claydo.id("SyntaxSpacer"))({ layout = { sizing = { width = claydo.sizing_grow(max = 16) } } }) {}
        claydo.text(
            "Flexible and readable declarative syntax with nested UI element hierarchies.",
            claydo.text_config({font_size = 28, font_id = FONT_ID_BODY_28, text_color = COLOR_RED}),
        )
        claydo.text(
            "Mix elements with standard C code like loops, conditionals and functions.",
            claydo.text_config({font_size = 28, font_id = FONT_ID_BODY_28, text_color = COLOR_RED}),
        )
        claydo.text(
            "Create your own library of re-usable components from UI primitives like text, images and rectangles.",
            claydo.text_config({font_size = 28, font_id = FONT_ID_BODY_28, text_color = COLOR_RED}),
        )
    }
    if claydo.ui(claydo.id("SyntaxPageRightImage"))({ layout = { sizing = { width = widthSizing }, child_alignment = { x = .CENTER } } }) {
        if claydo.ui(claydo.id("SyntaxPageRightImageInner"))({
            layout = { sizing = { width = claydo.sizing_grow(max = 568) } },
            aspect_ratio = 1136.0 / 1194.0,
            image = claydo.Image_Data(&syntaxImage),
        }) {}
    }
}

DeclarativeSyntaxPageDesktop :: proc() {
    if claydo.ui(claydo.id("SyntaxPageDesktop"))({
        layout = { sizing = { claydo.sizing_grow(), claydo.sizing_fit(min = cast(f32)windowHeight - 50) }, child_alignment = { y = .CENTER }, padding = { left = 50, right = 50 } },
    }) {
        if claydo.ui(claydo.id("SyntaxPage"))({
            layout = { sizing = { claydo.sizing_grow(), claydo.sizing_grow() }, child_alignment = { y = .CENTER }, padding = claydo.padding_all(32), child_gap = 32 },
            border = border2pxRed,
        }) {
            DeclarativeSyntaxPage({font_size = 52, font_id = FONT_ID_TITLE_52, text_color = COLOR_RED}, claydo.sizing_percent(0.5))
        }
    }
}

DeclarativeSyntaxPageMobile :: proc() {
    if claydo.ui(claydo.id("SyntaxPageMobile"))({
        layout = {
            direction = .TOP_TO_BOTTOM,
            sizing = { claydo.sizing_grow(), claydo.sizing_fit(min = cast(f32)windowHeight - 50) },
            child_alignment = { x = .CENTER, y = .CENTER },
            padding = { 16, 16, 32, 32 },
            child_gap = 16,
        },
    }) {
        DeclarativeSyntaxPage({font_size = 48, font_id = FONT_ID_TITLE_48, text_color = COLOR_RED}, claydo.sizing_grow({}))
    }
}

ColorLerp :: proc(a: claydo.Color, b: claydo.Color, amount: f32) -> claydo.Color {
    return claydo.Color{a.r + (b.r - a.r) * amount, a.g + (b.g - a.g) * amount, a.b + (b.b - a.b) * amount, a.a + (b.a - a.a) * amount}
}

LOREM_IPSUM_TEXT :: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."

HighPerformancePage :: proc(lerpValue: f32, titleTextConfig: claydo.Text_Element_Config, widthSizing: claydo.Sizing_Axis) {
    if claydo.ui(claydo.id("PerformanceLeftText"))({ layout = { sizing = { width = widthSizing }, direction = .TOP_TO_BOTTOM, child_gap = 8 } }) {
        claydo.text("High Performance", claydo.text_config(titleTextConfig))
        if claydo.ui()({ layout = { sizing = { width = claydo.sizing_grow(max = 16) } }}) {}
        claydo.text(
            "Fast enough to recompute your entire UI every frame.",
            claydo.text_config({font_size = 28, font_id = FONT_ID_BODY_36, text_color = COLOR_LIGHT}),
        )
        claydo.text(
            "Small memory footprint (3.5mb default) with static allocation & reuse. No malloc / free.",
            claydo.text_config({font_size = 28, font_id = FONT_ID_BODY_36, text_color = COLOR_LIGHT}),
        )
        claydo.text(
            "Simplify animations and reactive UI design by avoiding the standard performance hacks.",
            claydo.text_config({font_size = 28, font_id = FONT_ID_BODY_36, text_color = COLOR_LIGHT}),
        )
    }
    if claydo.ui(claydo.id("PerformanceRightImageOuter"))({ layout = { sizing = { width = widthSizing }, child_alignment = { x = .CENTER } } }) {
        if claydo.ui(claydo.id("PerformanceRightBorder"))({
            layout = { sizing = { claydo.sizing_grow(), claydo.sizing_fixed(400) } },
            border = {  COLOR_LIGHT, {2, 2, 2, 2, 2} },
        }) {
            if claydo.ui(claydo.id("AnimationDemoContainerLeft"))({
                layout = { sizing = { claydo.sizing_percent(0.35 + 0.3 * lerpValue), claydo.sizing_grow() }, child_alignment = { y = .CENTER }, padding = claydo.padding_all(16) },
                color = ColorLerp(COLOR_RED, COLOR_ORANGE, lerpValue),
            }) {
                claydo.text(LOREM_IPSUM_TEXT, claydo.text_config({font_size = 16, font_id = FONT_ID_BODY_16, text_color = COLOR_LIGHT}))
            }
            if claydo.ui(claydo.id("AnimationDemoContainerRight"))({
                layout = { sizing = { claydo.sizing_grow(), claydo.sizing_grow() }, child_alignment = { y = .CENTER }, padding = claydo.padding_all(16) },
                color = ColorLerp(COLOR_ORANGE, COLOR_RED, lerpValue),
            }) {
                claydo.text(LOREM_IPSUM_TEXT, claydo.text_config({font_size = 16, font_id = FONT_ID_BODY_16, text_color = COLOR_LIGHT}))
            }
        }
    }
}

HighPerformancePageDesktop :: proc(lerpValue: f32) {
    if claydo.ui(claydo.id("PerformanceDesktop"))({
        layout = { sizing = { claydo.sizing_grow(), claydo.sizing_fit(min = cast(f32)windowHeight - 50) }, child_alignment = { y = .CENTER }, padding = { 82, 82, 32, 32 }, child_gap = 64 },
        color = COLOR_RED,
    }) {
        HighPerformancePage(lerpValue, {font_size = 52, font_id = FONT_ID_TITLE_52, text_color = COLOR_LIGHT}, claydo.sizing_percent(0.5))
    }
}

HighPerformancePageMobile :: proc(lerpValue: f32) {
    if claydo.ui(claydo.id("PerformanceMobile"))({
        layout = {
            direction = .TOP_TO_BOTTOM,
            sizing = { claydo.sizing_grow(), claydo.sizing_fit(min = cast(f32)windowHeight - 50) },
            child_alignment = { x = .CENTER, y = .CENTER },
            padding = { 16, 16, 32, 32 },
            child_gap = 32,
        },
        color = COLOR_RED,
    }) {
        HighPerformancePage(lerpValue, {font_size = 48, font_id = FONT_ID_TITLE_48, text_color = COLOR_LIGHT}, claydo.sizing_grow({}))
    }
}

RendererButtonActive :: proc(index: i32, $text: string) {
    if claydo.ui()({
        layout = { sizing = { width = claydo.sizing_fixed(300) }, padding = claydo.padding_all(16) },
        color = COLOR_RED,
        corner_radius = claydo.corner_radius_all(10)
    }) {
        claydo.text(text, claydo.text_config({font_size = 28, font_id = FONT_ID_BODY_28, text_color = COLOR_LIGHT}))
    }
}

RendererButtonInactive :: proc(index: u32, $text: string) {
    if claydo.ui()({ border = border2pxRed }) {
        if claydo.ui(claydo.id("RendererButtonInactiveInner", index))({
            layout = { sizing = { width = claydo.sizing_fixed(300) }, padding = claydo.padding_all(16) },
            color = COLOR_LIGHT,
            corner_radius = claydo.corner_radius_all(10)
        }) {
            claydo.text(text, claydo.text_config({font_size = 28, font_id = FONT_ID_BODY_28, text_color = COLOR_RED}))
        }
    }
}

RendererPage :: proc(titleTextConfig: claydo.Text_Element_Config, widthSizing: claydo.Sizing_Axis) {
    if claydo.ui(claydo.id("RendererLeftText"))({ layout = { sizing = { width = widthSizing }, direction = .TOP_TO_BOTTOM, child_gap = 8 } }) {
        claydo.text("Renderer & Platform Agnostic", claydo.text_config(titleTextConfig))
        if claydo.ui()({ layout = { sizing = { width = claydo.sizing_grow(max = 16) } } }) {}
        claydo.text(
            "Clay outputs a sorted array of primitive render commands, such as RECTANGLE, TEXT or IMAGE.",
            claydo.text_config({font_size = 28, font_id = FONT_ID_BODY_36, text_color = COLOR_RED}),
        )
        claydo.text(
            "Write your own renderer in a few hundred lines of code, or use the provided examples for Raylib, WebGL canvas and more.",
            claydo.text_config({font_size = 28, font_id = FONT_ID_BODY_36, text_color = COLOR_RED}),
        )
        claydo.text(
            "There's even an HTML renderer - you're looking at it right now!",
            claydo.text_config({font_size = 28, font_id = FONT_ID_BODY_36, text_color = COLOR_RED}),
        )
    }
    if claydo.ui(claydo.id("RendererRightText"))({
        layout = { sizing = { width = widthSizing }, child_alignment = { x = .CENTER }, direction = .TOP_TO_BOTTOM, child_gap = 16 },
    }) {
        claydo.text("Try changing renderer!", claydo.text_config({font_size = 36, font_id = FONT_ID_BODY_36, text_color = COLOR_ORANGE}))
        if claydo.ui()({ layout = { sizing = { width = claydo.sizing_grow(max = 32) } } }) {}
        RendererButtonActive(0, "Raylib Renderer")
    }
}

RendererPageDesktop :: proc() {
    if claydo.ui(claydo.id("RendererPageDesktop"))({
        layout = { sizing = { claydo.sizing_grow(), claydo.sizing_fit(min = cast(f32)windowHeight - 50) }, child_alignment = { y = .CENTER }, padding = { left = 50, right = 50 } },
    }) {
        if claydo.ui(claydo.id("RendererPage"))({
            layout = { sizing = { claydo.sizing_grow(), claydo.sizing_grow() }, child_alignment = { y = .CENTER }, padding = claydo.padding_all(32), child_gap = 32 },
            border = { COLOR_RED, { left = 2, right = 2 } },
        }) {
            RendererPage({font_size = 52, font_id = FONT_ID_TITLE_52, text_color = COLOR_RED}, claydo.sizing_percent(0.5))
        }
    }
}

RendererPageMobile :: proc() {
    if claydo.ui(claydo.id("RendererMobile"))({
        layout = {
            direction = .TOP_TO_BOTTOM,
            sizing = { claydo.sizing_grow(), claydo.sizing_fit(min = cast(f32)windowHeight - 50) },
            child_alignment = { x = .CENTER, y = .CENTER },
            padding = { 16, 16, 32, 32 },
            child_gap = 32,
        },
        color = COLOR_LIGHT,
    }) {
        RendererPage({font_size = 48, font_id = FONT_ID_TITLE_48, text_color = COLOR_RED}, claydo.sizing_grow({}))
    }
}

ScrollbarData :: struct {
    clickOrigin:    [2]f32,
    positionOrigin: [2]f32,
    mouseDown:      bool,
}

scrollbarData := ScrollbarData{}
animationLerpValue: f32 = -1.0

createLayout :: proc(lerpValue: f32) -> []claydo.Render_Command {
    mobileScreen := windowWidth < 750
    claydo.begin_layout()
    if claydo.ui(claydo.id("OuterContainer"))({
        layout = { direction = .TOP_TO_BOTTOM, sizing = { claydo.sizing_grow(), claydo.sizing_grow() } },
        color = COLOR_LIGHT,
    }) {
        if claydo.ui(claydo.id("Header"))({
            layout = { direction = .LEFT_TO_RIGHT, sizing = { claydo.sizing_grow(), claydo.sizing_fixed(50) }, child_alignment = { y = .CENTER }, child_gap = 24, padding = { left = 32, right = 32 } },
        }) {
            claydo.text("Clay", &headerTextConfig)
            if claydo.ui()({ layout = { sizing = { width = claydo.sizing_grow() } } }) {}

            if (!mobileScreen) {
                if claydo.ui(claydo.id("LinkExamplesOuter"))({ color = {0, 0, 0, 0} }) {
                    claydo.text("Examples", claydo.text_config({font_id = FONT_ID_BODY_24, font_size = 24, text_color = claydo.Color({61, 26, 5, 255} / 255)}))
                }
                if claydo.ui(claydo.id("LinkDocsOuter"))({ color = {0, 0, 0, 0} }) {
                    claydo.text("Docs", claydo.text_config({font_id = FONT_ID_BODY_24, font_size = 24, text_color = claydo.Color({61, 26, 5, 255} / 255)}))
                }
            }
            if claydo.ui(claydo.id("LinkGithubOuter"))({
                layout = { padding = { 16, 16, 6, 6 } },
                border = border2pxRed,
                color = claydo.hovered() ? COLOR_LIGHT_HOVER : COLOR_LIGHT,
                corner_radius = claydo.corner_radius_all(10)
            }) {
                claydo.text("Github", claydo.text_config({font_id = FONT_ID_BODY_24, font_size = 24, text_color = claydo.Color({61, 26, 5, 255} / 255)}))
            }
        }
        if claydo.ui(claydo.id("TopBorder1"))({ layout = { sizing = { claydo.sizing_grow(), claydo.sizing_fixed(4) } }, color = COLOR_TOP_BORDER_5 } ) {}
        if claydo.ui(claydo.id("TopBorder2"))({ layout = { sizing = { claydo.sizing_grow(), claydo.sizing_fixed(4) } }, color = COLOR_TOP_BORDER_4 } ) {}
        if claydo.ui(claydo.id("TopBorder3"))({ layout = { sizing = { claydo.sizing_grow(), claydo.sizing_fixed(4) } }, color = COLOR_TOP_BORDER_3 } ) {}
        if claydo.ui(claydo.id("TopBorder4"))({ layout = { sizing = { claydo.sizing_grow(), claydo.sizing_fixed(4) } }, color = COLOR_TOP_BORDER_2 } ) {}
        if claydo.ui(claydo.id("TopBorder5"))({ layout = { sizing = { claydo.sizing_grow(), claydo.sizing_fixed(4) } }, color = COLOR_TOP_BORDER_1 } ) {}
        if claydo.ui(claydo.id("ScrollContainerBackgroundRectangle"))({
            clip = { vertical = true, child_offset = claydo.get_scroll_offset() },
            layout = { sizing = { claydo.sizing_grow(), claydo.sizing_grow() }, direction = .TOP_TO_BOTTOM },
            color = COLOR_LIGHT,
            border = { COLOR_RED, { between_children = 2} },
        }) {
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
    return claydo.end_layout()
}

loadFont :: proc(font_id: u16, font_size: u16, path: cstring) {
    assign_at(&raylib_fonts,font_id,Raylib_Font{
        font   = raylib.LoadFontEx(path, cast(i32)font_size * 2, nil, 0),
        fontId = cast(u16)font_id,
    })
    raylib.SetTextureFilter(raylib_fonts[font_id].font.texture, raylib.TextureFilter.TRILINEAR)
}

errorHandler :: proc(errorData: claydo.Error_Data) {
    if (errorData.type == .DUPLICATE_ID) {
        // etc
    }
}

main :: proc() {
    minMemorySize: c.size_t = cast(c.size_t)claydo.min_memory_size()
    arena: claydo.Arena = claydo.create_arena_with_capacity(minMemorySize)
    claydo.initialize(arena, {cast(f32)raylib.GetScreenWidth(), cast(f32)raylib.GetScreenHeight()}, { err_proc = errorHandler })
    claydo.set_measure_text_procedure(measure_text, nil)

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
        defer free_all(context.temp_allocator)

        animationLerpValue += raylib.GetFrameTime()
        if animationLerpValue > 1 {
            animationLerpValue = animationLerpValue - 2
        }
        windowWidth = raylib.GetScreenWidth()
        windowHeight = raylib.GetScreenHeight()
        if (raylib.IsKeyPressed(.D)) {
            debugModeEnabled = !debugModeEnabled
            claydo.set_debug_mode_enabled(debugModeEnabled)
        }
        claydo.set_cursor_state(transmute([2]f32)raylib.GetMousePosition(), raylib.IsMouseButtonDown(raylib.MouseButton.LEFT))
        claydo.update_scroll_containers(false, transmute([2]f32)raylib.GetMouseWheelMoveV(), raylib.GetFrameTime())
        claydo.set_layout_dimensions({cast(f32)raylib.GetScreenWidth(), cast(f32)raylib.GetScreenHeight()})
        renderCommands: []claydo.Render_Command = createLayout(animationLerpValue < 0 ? (animationLerpValue + 1) : (1 - animationLerpValue))
        raylib.BeginDrawing()
        clay_raylib_render(renderCommands)
        raylib.EndDrawing()
    }
}
