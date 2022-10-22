# frozen_string_literal: true

require 'open3'
require 'logger'
require 'date'
require 'active_support/multibyte'
require 'fileutils'

require_relative "git_auto/version"
require_relative "git_auto/string"
require_relative "git_auto/git_auto"
