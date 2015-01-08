module Slices
  class Translations
    # To enable editors to translate a site into other languages,
    # redefine this method in an initializer in the site's Rails app.
    def self.all
      { en: 'English' }
    end

    def self.available?
      all.keys.size > 1
    end
  end
end
