# frozen_string_literal: true

# typed: strict

module OutputColor
  extend T::Sig

  sig { params(color_code: Integer, text: String).returns(String) }
  def self.colorize(color_code, text)
    "\e[#{color_code}m#{text}\e[0m"
  end

  sig { params(text: String).returns(String) }
  def self.red(text)
    colorize(31, text)
  end

  sig { params(text: String).returns(String) }
  def self.green(text)
    colorize(32, text)
  end

  sig { params(text: String).returns(String) }
  def self.yellow(text)
    colorize(33, text)
  end

  sig { params(text: String).returns(String) }
  def self.blue(text)
    colorize(34, text)
  end

  sig { params(text: String).returns(String) }
  def self.pink(text)
    colorize(35, text)
  end

  sig { params(text: String).returns(String) }
  def self.light_blue(text)
    colorize(36, text)
  end
end
