require "yaml"
require "classy_hash"
require_relative 'args/unit_conversion'


module Squib
  class Template
    # Defaults are set for poker sized deck on a A4 sheet, with no cards
    DEFAULTS = {
      'sheet_width' => '210mm',
      'sheet_height' => '297mm',
      'card_width' => '63mm',
      'card_height' => '88mm',
      'dpi' => 300,
      'crop_line' => {
        'style' => :solid,
        'width' => '0.02mm',
        'color' => :color,
        'page_style' => :margin_only,
        'lines' => []
      },
      'cards' => []
    }


    def initialize(template_hash = DEFAULTS)
      ClassyHash.validate(template_hash, SCHEMA)
      @template_hash = template_hash
      @crop_line_default = @template_hash.select {
        |k, v| ["style", "width", "color"].include? k}
    end

    # Load the template definition file
    def self.load(file)
      yaml = {}
      thefile = File.exist?(file) ? file: builtin(file)
      if File.exists? thefile
        yaml = YAML.load_file(thefile) || {}
      end
      warn_unrecognized(yaml)
      Template.new(DEFAULTS.merge(yaml))
    end

    def sheet_width
      Args::UnitConversion.parse(
        @template_hash['sheet_width'], @template_hash['dpi'])
    end

    def sheet_height
      Args::UnitConversion.parse(
        @template_hash['sheet_height'], @template_hash['dpi'])
    end

    def card_width
      Args::UnitConversion.parse(
        @template_hash['card_width'], @template_hash['dpi'])
    end

    def card_height
      Args::UnitConversion.parse(
        @template_hash['card_height'], @template_hash['dpi'])
    end

    def crop_lines
      lines = @template_hash['crop_line']['lines'].map(
        &method(:parse_crop_line))
      if block_given?
        lines.each { |v| yield v }
      else
        lines
      end
    end

    def cards
      cards = @template_hash['cards'].map(&method(:parse_card))
      if block_given?
        cards.each { |v| yield v }
      else
        cards
      end
    end

    private

    # Template file schema
    UNIT_REGEX = /^(\d*[.])?\d+(in|cm|mm)?$/
    SCHEMA = {
      "sheet_width" => UNIT_REGEX,
      "sheet_height" => UNIT_REGEX,
      "card_width" => UNIT_REGEX,
      "card_height" => UNIT_REGEX,
      "dpi" => ->(v){ (v.is_a?(Integer) && v > 0) || "a positive number"},
      "crop_line" => {
        "style" => ClassyHash::G.enum(:solid, :dotted, :dashed),
        "width" => UNIT_REGEX,
        "color" => [ String, Symbol ],
        "page_style" => ClassyHash::G.enum(:margin_only, :overlay),
        "lines" => [[{
          "type" => ClassyHash::G.enum(:horizontal, :vertical, :custom),
          "position" => UNIT_REGEX,
          "style" => [
            :optional, ClassyHash::G.enum(:solid, :dotted, :dashed)],
          "width" => [:optional, UNIT_REGEX],
          "color" => [:optional, String, Symbol],
        }]]
      },
      "cards" => [[{ "x" => UNIT_REGEX, "y" => UNIT_REGEX }]]
    }

    # Return path for built-in sheet templates
    def builtin(file)
      "#{File.dirname(__FILE__)}/sheet_templates/#{file}"
    end

    # Warn unrecognized options in the template sheet
    def self.warn_unrecognized(yaml)
      unrec = yaml.keys - DEFAULTS.keys
      if unrec.any?
        Squib::logger.warn(
          "Unrecognized configuration option(s): #{unrec.join(',')}")
      end
    end

    # Parse crop line definitions from template.
    def parse_crop_line(line)
      new_line = @crop_line_default.merge line
      new_line['width'] = Args::UnitConversion.parse(
        new_line['width'], @template_hash['dpi'])
      new_line
    end

    # Parse card definitions from template.
    def parse_card(card)
      new_card = card.rehash
      new_card["x"] = Args::UnitConversion.parse(
        card["x"], @template_hash["dpi"])
      new_card["y"] = Args::UnitConversion.parse(
        card["y"], @template_hash["dpi"])
      new_card
    end
  end
end
