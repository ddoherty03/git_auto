# frozen_string_literal: true

class String
  BLANK_RE = /\A[[:space:]]*\z/
  def blank?
    return true if empty?

    # This is to avoid exception for invalid UTF-8 string
    encode('UTF-8', 'UTF-8', :invalid => :replace).match?(BLANK_RE)
  end
end
