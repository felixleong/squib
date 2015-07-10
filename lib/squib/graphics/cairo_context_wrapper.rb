require 'forwardable'
require 'squib/graphics/gradient_regex'

module Squib
  module Graphics
    # Wrapper class for the Cairo context. Private.
    # @api private
    class CairoContextWrapper
      extend Forwardable

      # :nodoc:
      # @api private
      attr_accessor :cairo_cxt

      # :nodoc:
      # @api private
      def initialize(cairo_cxt)
        @cairo_cxt = cairo_cxt
      end

      def_delegators :cairo_cxt, :save, :set_source_color, :paint, :restore,
        :translate, :rotate, :move_to, :update_pango_layout, :width, :height,
        :show_pango_layout, :rounded_rectangle, :set_line_width, :stroke, :fill,
        :set_source, :scale, :render_rsvg_handle, :circle, :triangle, :line_to,
        :operator=, :show_page, :clip, :transform, :mask, :create_pango_layout,
        :antialias=, :curve_to, :matrix, :matrix=, :identity_matrix, :pango_layout_path,
        :stroke_preserve, :target, :new_path, :fill_preserve, :close_path,
        :set_line_join, :set_line_cap, :set_dash

      # :nodoc:
      # @api private
      def set_source_squibcolor(arg)
        if match = arg.match(LINEAR_GRADIENT)
          x1, y1, x2, y2 = match.captures
          linear = Cairo::LinearPattern.new(x1.to_f, y1.to_f, x2.to_f, y2.to_f)
          arg.scan(STOPS).each do |color, offset|
            linear.add_color_stop(offset.to_f, color)
          end
          @cairo_cxt.set_source(linear)
        elsif match = arg.match(RADIAL_GRADIENT)
          x1, y1, r1, x2, y2, r2  = match.captures
          linear = Cairo::RadialPattern.new(x1.to_f, y1.to_f, r1.to_f,
                                            x2.to_f, y2.to_f, r2.to_f)
          arg.scan(STOPS).each do |color, offset|
            linear.add_color_stop(offset.to_f, color)
          end
          @cairo_cxt.set_source(linear)
        else
          @cairo_cxt.set_source_color(arg)
        end
      end

      # Convenience method for a common task
      # @api private
      def fill_n_stroke(draw)
        set_source_squibcolor draw.fill_color
        fill_preserve
        set_source_squibcolor draw.stroke_color
        set_line_width draw.stroke_width
        set_line_join draw.join
        set_line_cap draw.cap
        set_dash draw.dash
        stroke
      end

      # Convenience method for a common task
      # @api private
      def fancy_stroke(draw)
        set_source_squibcolor draw.stroke_color
        set_line_width draw.stroke_width
        set_line_join draw.join
        set_line_cap draw.cap
        set_dash draw.dash
        stroke
      end

      def rotate_about(x, y, angle)
        translate(x, y)
        rotate(angle)
        translate(-x, -y)
      end

    end
  end
end