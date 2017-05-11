require 'spec_helper'

describe Squib::Template do
  it 'loads a template' do
    tmpl = Squib::Template.load(template_file('basic.yml'), 100)
    expect(tmpl.sheet_width).to eq(850)
    expect(tmpl.sheet_height).to eq(1100)
    expect(tmpl.card_width).to eq(250)
    expect(tmpl.card_height).to eq(350)
    expect(tmpl.dpi).to eq(100)
    expect(tmpl.crop_line_overlay).to eq(
      Squib::Template::DEFAULTS['crop_line']['overlay']
    )
    expect(tmpl.crop_lines).to eq([])
    expect(tmpl.cards).to eq([{ 'x' => 50, 'y' => 100, 'rotate' => 0 }])
  end

  it 'loads from the default templates if none exists' do
    tmpl = Squib::Template.load('a4_poker_card_9up.yml', 100)
    expect(tmpl.sheet_width).to eq(826.7716527)
    expect(tmpl.sheet_height).to eq(1169.2913373899999)
    expect(tmpl.card_width).to eq(248.03149580999997)
    expect(tmpl.card_height).to eq(346.45669256)
    expect(tmpl.dpi).to eq(100)
  end

  it 'fails when sheet_width is not defined' do
    expect do
      Squib::Template.load(template_file('fail_no_sheet_width.yml'), 100)
    end.to raise_error(
      RuntimeError,
      '"sheet_width" is not a String matching /^(\d*[.])?\d+(in|cm|mm)$/'
    )
  end

  it 'fails when sheet_height is not defined' do
    expect do
      Squib::Template.load(template_file('fail_no_sheet_height.yml'), 100)
    end.to raise_error(
      RuntimeError,
      '"sheet_height" is not a String matching /^(\d*[.])?\d+(in|cm|mm)$/'
    )
  end

  it 'fails when card_width is not defined' do
    expect do
      Squib::Template.load(template_file('fail_no_card_width.yml'), 100)
    end.to raise_error(
      RuntimeError,
      '"card_width" is not a String matching /^(\d*[.])?\d+(in|cm|mm)$/'
    )
  end

  it 'fails when card_height is not defined' do
    expect do
      Squib::Template.load(template_file('fail_no_card_height.yml'), 100)
    end.to raise_error(
      RuntimeError,
      '"card_height" is not a String matching /^(\d*[.])?\d+(in|cm|mm)$/'
    )
  end
end
