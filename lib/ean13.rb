require 'RMagick'

class EAN13
  include Magick

  ENC_PATTERN = [
    [0, 0, 0, 0, 0, 0],
    [0, 0, 1, 0, 1, 1],
    [0, 0, 1, 1, 0, 1],
    [0, 0, 1, 1, 1, 0],
    [0, 1, 0, 0, 1, 1],
    [0, 1, 1, 0, 0, 1],
    [0, 1, 1, 1, 0, 0],
    [0, 1, 0, 1, 0, 1],
    [0, 1, 0, 1, 1, 0],
    [0, 1, 1, 0, 1, 0],
  ]

  ENC = [
    ['0001101', '0011001', '0010011', '0111101', '0100011', '0110001', '0101111', '0111011', '0110111', '0001011'],
    ['0100111', '0110011', '0011011', '0100001', '0011101', '0111001', '0000101', '0010001', '0001001', '0010111'],
    ['1110010', '1100110', '1101100', '1000010', '1011100', '1001110', '1010000', '1000100', '1001000', '1110100'],
  ]

  GUARD = '101'
  GUARD_MID = '01010'

  class ChecksumError < StandardError; end

  def initialize(text)
    raise ArgumentError, 'must be 12 or 13 digits' unless text =~ /\d{12,13}/

    text = $&
    @nums = text[0,12].chars.map{|c|c.to_i}
    checksum = (10 - @nums.reverse.map.with_index{|c, i|i.odd? ? c : c * 3}.inject(:+)) % 10
    raise ChecksumError, "invalid checksum #{text[12]} (must be #{checksum})" if text.size == 13 && text[12].to_i != checksum

    @nums << checksum

    pattern = ENC_PATTERN[@nums.first]
    @six1 = @nums[1,6].map.with_index{|n, i|ENC[pattern[i]][n]}.inject(:+)
    @six2 = @nums[7,12].map{|n|ENC[2][n]}.inject(:+)
  end

  def to_png(opts = {})
    opts = {width: 200, height: 150}.merge(opts)

    w = opts[:width]
    h = opts[:height]

    x = y = pad = 0.1*w
    w_bar = (w - pad * 2.0) / 95
    y_bar = (h - pad * 2.5) + pad
    y_bar_guard = y_bar + 7*w/200
    y_text = y_bar + 14*w/200

    im = Image.new(w, h)
    d = Magick::Draw.new

    draw = lambda do |bars, guard = false|
      bars.chars.each do |b|
        d.rectangle x, y, x + w_bar, (guard ? y_bar_guard : y_bar) if b == '1'
        x += w_bar
      end
    end

    draw.call(GUARD, true)
    draw.call(@six1)
    draw.call(GUARD_MID, true)
    draw.call(@six2)
    draw.call(GUARD, true)

    d.font 'saxmono.ttf'
    d.pointsize 16*w/200;
    d.kerning (42 * w_bar / 10 - 6*w/200) * 10 / 6
    d.text_align Magick::CenterAlign
    d.text 10*w/200, y_text, @nums.first.to_s
    d.text pad + 25 * w_bar, y_text, @nums[1,6].join
    d.text pad + 70 * w_bar, y_text, @nums[7,12].join
    d.text 28*w/200 + 95 * w_bar, y_text, '>'
    d.draw(im)

    im.to_blob{self.format='png'}
  end

  def save(opts = {})
    File.open(opts[:to] || @nums.join + '.png', 'w') { |f| f << to_png(opts) }
  end
end
