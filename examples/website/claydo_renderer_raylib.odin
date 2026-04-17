
package main

import "../../claydo"
import "base:runtime"
import "core:math"
import "core:strings"
import "core:unicode/utf8"
import rl "vendor:raylib"

RaylibFont :: struct {
	fontId: u16,
	font:   rl.Font,
}

clayColorToRlColor :: proc(color: claydo.Color) -> rl.Color {
	return {u8(color.r * 255), u8(color.g * 255), u8(color.b * 255), u8(color.a * 255)}
}

raylibFonts := [dynamic]RaylibFont{}

// Alias for compatibility, default to ascii support
measureText :: measureTextAscii

measureTextUnicode :: proc(
	text: string,
	config: claydo.TextElementConfig,
	userData: rawptr,
) -> [2]f32 {
	// Needed for graphemeCount
	context = runtime.default_context()

	lineWidth: f32 = 0

	font := raylibFonts[config.fontId].font

	// This function seems somewhat expensive, if you notice performance issues, you could assume
	// - 1 codepoint per visual character (no grapheme clusters), where you can get the length from the loop
	// - 1 byte per visual character (ascii), where you can get the length with `text.length`
	// see `measureTextAscii`
	graphemeCount, _, _ := utf8.grapheme_count(text)

	for letter, byteIdx in text {
		glyphIndex := rl.GetGlyphIndex(font, letter)

		glyph := font.glyphs[glyphIndex]

		if glyph.advanceX != 0 {
			lineWidth += f32(glyph.advanceX)
		} else {
			lineWidth += font.recs[glyphIndex].width + f32(font.glyphs[glyphIndex].offsetX)
		}
	}

	scaleFactor := f32(config.fontSize) / f32(font.baseSize)

	// Note:
	//   I'd expect this to be `graphemeCount - 1`,
	//   but that seems to be one letterSpacing too small
	//   maybe that's a raylib bug, maybe that's Clay?
	totalSpacing := f32(graphemeCount) * f32(config.spacing)

	return [2]f32{lineWidth * scaleFactor + totalSpacing, f32(config.fontSize)}
}

measureTextAscii :: proc(
	text: string,
	config: claydo.TextElementConfig,
	userData: rawptr,
) -> [2]f32 {
	lineWidth: f32 = 0

	font := raylibFonts[config.fontId].font

	for i in 0 ..< len(text) {
		glyphIndex := text[i] - 32

		glyph := font.glyphs[glyphIndex]

		if glyph.advanceX != 0 {
			lineWidth += f32(glyph.advanceX)
		} else {
			lineWidth += font.recs[glyphIndex].width + f32(font.glyphs[glyphIndex].offsetX)
		}
	}

	scaleFactor := f32(config.fontSize) / f32(font.baseSize)

	// Note:
	//   I'd expect this to be `len(textStr) - 1`,
	//   but that seems to be one letterSpacing too small
	//   maybe that's a raylib bug, maybe that's Clay?
	totalSpacing := f32(len(text)) * f32(config.spacing)

	return [2]f32{lineWidth * scaleFactor + totalSpacing, f32(config.fontSize)}
}

clayRaylibRender :: proc(
	renderCommands: []claydo.RenderCommand,
	allocator := context.temp_allocator,
) {
	for renderCommand in renderCommands {
		bounds := renderCommand.boundingBox

		#partial switch renderCommand.type {
		case .NONE: // None
		case .TEXT:
			config := renderCommand.renderData.(claydo.TextRenderData)

			text := config.text

			// Raylib uses C strings instead of Odin strings, so we need to clone
			// Assume this will be freed elsewhere since we default to the temp allocator
			cstrText := strings.clone_to_cstring(text, allocator)

			font := raylibFonts[config.fontId].font
			rl.DrawTextEx(
				font,
				cstrText,
				{bounds.x, bounds.y},
				f32(config.fontSize),
				f32(config.spacing),
				clayColorToRlColor(config.color),
			)
		case .IMAGE:
			config := renderCommand.renderData.(claydo.ImageRenderData)
			tint := config.color
			if tint == 0 {
				tint = {1, 1, 1, 1}
			}

			imageTexture := (^rl.Texture2D)(config.data)
			rl.DrawTextureEx(
				imageTexture^,
				{bounds.x, bounds.y},
				0,
				bounds.width / f32(imageTexture.width),
				clayColorToRlColor(tint),
			)
		case .SCISSOR_START:
			rl.BeginScissorMode(
				i32(math.round(bounds.x)),
				i32(math.round(bounds.y)),
				i32(math.round(bounds.width)),
				i32(math.round(bounds.height)),
			)
		case .SCISSOR_END:
			rl.EndScissorMode()
		case .RECTANGLE:
			config := renderCommand.renderData.(claydo.RectangleRenderData)
			if config.cornerRadius.topLeft > 0 {
				radius: f32 = (config.cornerRadius.topLeft * 2) / min(bounds.width, bounds.height)
				drawRectRounded(
					bounds.x,
					bounds.y,
					bounds.width,
					bounds.height,
					radius,
					config.color,
				)
			} else {
				drawRect(bounds.x, bounds.y, bounds.width, bounds.height, config.color)
			}
		case .BORDER:
			config := renderCommand.renderData.(claydo.BorderRenderData)
			// Left border
			if config.width.left > 0 {
				drawRect(
					bounds.x,
					bounds.y + config.cornerRadius.topLeft,
					f32(config.width.left),
					bounds.height - config.cornerRadius.topLeft - config.cornerRadius.bottomLeft,
					config.color,
				)
			}
			// Right border
			if config.width.right > 0 {
				drawRect(
					bounds.x + bounds.width - f32(config.width.right),
					bounds.y + config.cornerRadius.topRight,
					f32(config.width.right),
					bounds.height - config.cornerRadius.topRight - config.cornerRadius.bottomRight,
					config.color,
				)
			}
			// Top border
			if config.width.top > 0 {
				drawRect(
					bounds.x + config.cornerRadius.topLeft,
					bounds.y,
					bounds.width - config.cornerRadius.topLeft - config.cornerRadius.topRight,
					f32(config.width.top),
					config.color,
				)
			}
			// Bottom border
			if config.width.bottom > 0 {
				drawRect(
					bounds.x + config.cornerRadius.bottomLeft,
					bounds.y + bounds.height - f32(config.width.bottom),
					bounds.width -
					config.cornerRadius.bottomLeft -
					config.cornerRadius.bottomRight,
					f32(config.width.bottom),
					config.color,
				)
			}

			// Rounded Borders
			if config.cornerRadius.topLeft > 0 {
				drawArc(
					bounds.x + config.cornerRadius.topLeft,
					bounds.y + config.cornerRadius.topLeft,
					config.cornerRadius.topLeft - f32(config.width.top),
					config.cornerRadius.topLeft,
					180,
					270,
					config.color,
				)
			}
			if config.cornerRadius.topRight > 0 {
				drawArc(
					bounds.x + bounds.width - config.cornerRadius.topRight,
					bounds.y + config.cornerRadius.topRight,
					config.cornerRadius.topRight - f32(config.width.top),
					config.cornerRadius.topRight,
					270,
					360,
					config.color,
				)
			}
			if config.cornerRadius.bottomLeft > 0 {
				drawArc(
					bounds.x + config.cornerRadius.bottomLeft,
					bounds.y + bounds.height - config.cornerRadius.bottomLeft,
					config.cornerRadius.bottomLeft - f32(config.width.top),
					config.cornerRadius.bottomLeft,
					90,
					180,
					config.color,
				)
			}
			if config.cornerRadius.bottomRight > 0 {
				drawArc(
					bounds.x + bounds.width - config.cornerRadius.bottomRight,
					bounds.y + bounds.height - config.cornerRadius.bottomRight,
					config.cornerRadius.bottomRight - f32(config.width.bottom),
					config.cornerRadius.bottomRight,
					0.1,
					90,
					config.color,
				)
			}
		case .CUSTOM:
		// Implement custom element rendering here
		}
	}
}

// Helper procs, mainly for repeated conversions

@(private = "file")
drawArc :: proc(
	x, y: f32,
	innerRad, outerRad: f32,
	startAngle, endAngle: f32,
	color: claydo.Color,
) {
	rl.DrawRing(
		{math.round(x), math.round(y)},
		math.round(innerRad),
		outerRad,
		startAngle,
		endAngle,
		10,
		clayColorToRlColor(color),
	)
}

@(private = "file")
drawRect :: proc(x, y, w, h: f32, color: claydo.Color) {
	rl.DrawRectangle(
		i32(math.round(x)),
		i32(math.round(y)),
		i32(math.round(w)),
		i32(math.round(h)),
		clayColorToRlColor(color),
	)
}

@(private = "file")
drawRectRounded :: proc(x, y, w, h: f32, radius: f32, color: claydo.Color) {
	rl.DrawRectangleRounded({x, y, w, h}, radius, 8, clayColorToRlColor(color))
}
