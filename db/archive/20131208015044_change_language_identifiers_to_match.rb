class ChangeLanguageIdentifiersToMatch < ActiveRecord::Migration
  def mapping
    {"C++" => 'c++03', 'C' => 'c99', 'Python' => 'python2', 'Haskell' => 'haskell2010'}
  end

  def up
    Language.all.each do |language|
      language.update_attributes(:name => language.identifier, :identifier => mapping.fetch(language.identifier, language.identifier))
    end
  end

  def down
    Language.all.each do |language|
      language.update_attributes(:identifier => mapping.invert.fetch(language.identifier, language.identifier))
    end
  end
end
