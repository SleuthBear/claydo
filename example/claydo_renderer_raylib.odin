package main

import "core:unicode/utf8"
import "base:runtime"
import "../claydo"
import "core:math"
import "core:strings"
import rl "vendor:raylib"

Raylib_Font :: struct {
    fontId: u16,
    font:   rl.Font,
}

clay_color_to_rl_color :: proc(color: claydo.Color) -> rl.Color {
    return {u8(color.r*255), u8(color.g*255), u8(color.b*255), u8(color.a*255)}
}

raylib_fonts := [dynamic]Raylib_Font{}

// Alias for compatibility, default to ascii support
measure_text :: measure_text_ascii

measure_text_unicode :: proc(text: string, config: claydo.Text_Element_Config, userData: rawptr) -> [2]f32 {
    // Needed for grapheme_count
    context = runtime.default_context()

	line_width: f32 = 0

	font := raylib_fonts[config.font_id].font

    // This function seems somewhat expensive, if you notice performance issues, you could assume
    // - 1 codepoint per visual character (no grapheme clusters), where you can get the length from the loop
    // - 1 byte per visual character (ascii), where you can get the length with `text.length`
    // see `measure_text_ascii`
    grapheme_count, _, _ := utf8.grapheme_count(text)

	for letter, byte_idx in text {
		glyph_index := rl.GetGlyphIndex(font, letter)

        glyph := font.glyphs[glyph_index]

		if glyph.advanceX != 0 {
			line_width += f32(glyph.advanceX)
		} else {
			line_width += font.recs[glyph_index].width + f32(font.glyphs[glyph_index].offsetX)
		}
	}

	scaleFactor := f32(config.font_size) / f32(font.baseSize)

    // Note:
    //   I'd expect this to be `grapheme_count - 1`,
    //   but that seems to be one letterSpacing too small
    //   maybe that's a raylib bug, maybe that's Clay?
	total_spacing := f32(grapheme_count) * f32(config.spacing)

	return [2]f32{line_width * scaleFactor + total_spacing, f32(config.font_size)}
}

measure_text_ascii :: proc(text: string, config: claydo.Text_Element_Config, userData: rawptr) -> [2]f32 {
	line_width: f32 = 0

	font := raylib_fonts[config.font_id].font

	for i in 0..<len(text) {
		glyph_index := text[i] - 32

        glyph := font.glyphs[glyph_index]

		if glyph.advanceX != 0 {
			line_width += f32(glyph.advanceX)
		} else {
			line_width += font.recs[glyph_index].width + f32(font.glyphs[glyph_index].offsetX)
		}
	}

	scaleFactor := f32(config.font_size) / f32(font.baseSize)

    // Note:
    //   I'd expect this to be `len(text_str) - 1`,
    //   but that seems to be one letterSpacing too small
    //   maybe that's a raylib bug, maybe that's Clay?
	total_spacing := f32(len(text)) * f32(config.spacing)

	return [2]f32{line_width * scaleFactor + total_spacing, f32(config.font_size)}
}

clay_raylib_render :: proc(render_commands: []claydo.Render_Command, allocator := context.temp_allocator) {
	for render_command in render_commands {
        bounds := render_command.bounding_box

        switch render_command.type {
        case .NONE: // None
        case .TEXT:
            config := render_command.render_data.(claydo.Text_Render_Data)

            text := config.text

            // Raylib uses C strings instead of Odin strings, so we need to clone
            // Assume this will be freed elsewhere since we default to the temp allocator
            cstr_text := strings.clone_to_cstring(text, allocator)

            font := raylib_fonts[config.font_id].font
            rl.DrawTextEx(font, cstr_text, {bounds.x, bounds.y}, f32(config.font_size), f32(config.spacing), clay_color_to_rl_color(config.color))
        case .IMAGE:
            config := render_command.render_data.(claydo.Image_Render_Data)
            tint := config.color
            if tint == 0 {
                tint = {255, 255, 255, 255}
            }

            imageTexture := (^rl.Texture2D)(config.data)
            rl.DrawTextureEx(imageTexture^, {bounds.x, bounds.y}, 0, bounds.width / f32(imageTexture.width), clay_color_to_rl_color(tint))
        case .SCISSOR_START:
            rl.BeginScissorMode(i32(math.round(bounds.x)), i32(math.round(bounds.y)), i32(math.round(bounds.width)), i32(math.round(bounds.height)))
        case .SCISSOR_END:
            rl.EndScissorMode()
        case .RECTANGLE:
            config := render_command.render_data.(claydo.Rectangle_Render_Data)
            if config.corner_radius.top_left > 0 {
                radius: f32 = (config.corner_radius.top_left * 2) / min(bounds.width, bounds.height)
                draw_rect_rounded(bounds.x, bounds.y, bounds.width, bounds.height, radius, config.color)
            } else {
                draw_rect(bounds.x, bounds.y, bounds.width, bounds.height, config.color)
            }
        case .BORDER:
            config := render_command.render_data.(claydo.Border_Render_Data)
            // Left border
            if config.width.left > 0 {
                draw_rect(
                    bounds.x,
                    bounds.y + config.corner_radius.top_left,
                    f32(config.width.left),
                    bounds.height - config.corner_radius.top_left - config.corner_radius.bottom_left,
                    config.color,
                )
            }
            // Right border
            if config.width.right > 0 {
                draw_rect(
                    bounds.x + bounds.width - f32(config.width.right),
                    bounds.y + config.corner_radius.top_right,
                    f32(config.width.right),
                    bounds.height - config.corner_radius.top_right - config.corner_radius.bottom_right,
                    config.color,
                )
            }
            // Top border
            if config.width.top > 0 {
                draw_rect(
                    bounds.x + config.corner_radius.top_left,
                    bounds.y,
                    bounds.width - config.corner_radius.top_left - config.corner_radius.top_right,
                    f32(config.width.top),
                    config.color,
                )
            }
            // Bottom border
            if config.width.bottom > 0 {
                draw_rect(
                    bounds.x + config.corner_radius.bottom_left,
                    bounds.y + bounds.height - f32(config.width.bottom),
                    bounds.width - config.corner_radius.bottom_left - config.corner_radius.bottom_right,
                    f32(config.width.bottom),
                    config.color,
                )
            }

            // Rounded Borders
            if config.corner_radius.top_left > 0 {
                draw_arc(
                    bounds.x + config.corner_radius.top_left,
                    bounds.y + config.corner_radius.top_left,
                    config.corner_radius.top_left - f32(config.width.top),
                    config.corner_radius.top_left,
                    180,
                    270,
                    config.color,
                )
            }
            if config.corner_radius.top_right > 0 {
                draw_arc(
                    bounds.x + bounds.width - config.corner_radius.top_right,
                    bounds.y + config.corner_radius.top_right,
                    config.corner_radius.top_right - f32(config.width.top),
                    config.corner_radius.top_right,
                    270,
                    360,
                    config.color,
                )
            }
            if config.corner_radius.bottom_left > 0 {
                draw_arc(
                    bounds.x + config.corner_radius.bottom_left,
                    bounds.y + bounds.height - config.corner_radius.bottom_left,
                    config.corner_radius.bottom_left - f32(config.width.top),
                    config.corner_radius.bottom_left,
                    90,
                    180,
                    config.color,
                )
            }
            if config.corner_radius.bottom_right > 0 {
                draw_arc(
                    bounds.x + bounds.width - config.corner_radius.bottom_right,
                    bounds.y + bounds.height - config.corner_radius.bottom_right,
                    config.corner_radius.bottom_right - f32(config.width.bottom),
                    config.corner_radius.bottom_right,
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
draw_arc :: proc(x, y: f32, inner_rad, outer_rad: f32,start_angle, end_angle: f32, color: claydo.Color){
    rl.DrawRing(
        {math.round(x),math.round(y)},
        math.round(inner_rad),
        outer_rad,
        start_angle,
        end_angle,
        10,
        clay_color_to_rl_color(color),
    )
}

@(private = "file")
draw_rect :: proc(x, y, w, h: f32, color: claydo.Color) {
    rl.DrawRectangle(
        i32(math.round(x)),
        i32(math.round(y)),
        i32(math.round(w)),
        i32(math.round(h)),
        clay_color_to_rl_color(color)
    )
}

@(private = "file")
draw_rect_rounded :: proc(x,y,w,h: f32, radius: f32, color: claydo.Color){
    rl.DrawRectangleRounded({x,y,w,h},radius,8,clay_color_to_rl_color(color))
}
