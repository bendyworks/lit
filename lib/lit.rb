require "lit/engine"
require 'lit/loader'

module Lit
  mattr_accessor :authentication_function
  mattr_accessor :key_value_engine
  mattr_accessor :storage_options
  mattr_accessor :humanize_key
  mattr_accessor :fallback
  mattr_accessor :api_enabled
  mattr_accessor :api_key
  mattr_accessor :all_translations_are_html_safe

  class << self
    attr_accessor :loader
  end
  def self.init
    @@table_exists ||= Lit::Locale.table_exists?
    if self.loader.nil? && @@table_exists
      self.loader ||= Loader.new
      Lit.humanize_key = true if Lit.humanize_key.nil?
      #if loading all translations on start, migrations have to be performed
      #already, fails on first deploy
      #self.loader.cache.load_all_translations
      Lit.storage_options ||= {}
    end
    self.loader
  end

  def self.get_key_value_engine
    case Lit.key_value_engine
        when 'redis'
          require 'lit/adapters/redis_storage'
          return RedisStorage.new
        else
          require 'lit/adapters/hash_storage'
          return HashStorage.new
    end
  end
end

if defined? Rails
  require 'lit/rails'
end
