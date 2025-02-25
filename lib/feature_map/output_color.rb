# frozen_string_literal: true

module OutputColor
  def self.colorize(color_code, text)
    "\e[#{color_code}m#{text}\e[0m"
  end

  def self.red(text)
    colorize(31, text)
  end

  def self.green(text)
    colorize(32, text)
  end

  def self.yellow(text)
    colorize(33, text)
  end

  def self.blue(text)
    colorize(34, text)
  end

  def self.pink(text)
    colorize(35, text)
  end

  def self.light_blue(text)
    colorize(36, text)
  end
end
