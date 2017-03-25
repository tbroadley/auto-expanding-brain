require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'
require 'capybara/rspec'
require 'json'

include Capybara::DSL
include Capybara::RSpecMatchers

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, js_errors: false)
end

Capybara.default_driver = :poltergeist

def get_meme_material
  banned_shit = [
    /Template/,
    /Wikipedia:/,
    /Portal/,
    /References/,
    /File:/,
    /#/,
    /Category/,
  ]

  more_banned_shit = [
    /incomplete/,
    /expanding it/,
    'e',
    'edit',
    /\[.*\]/,
    /Jump up/,
    'hide',
    /List of/,
    /Lists of/,
    'show',
    'index',
    /\d+\.\d+/,
    'adding to it',
    'links',
    'Commons',
    'Category',
    /ISBN/,
    /\d+/,
    'top',
    'info',
    'doi',
    /\..+/,
    'Lists portal',
  ]

  visit('https://en.wikipedia.org/wiki/List_of_lists_of_lists')

  list_of_lists_link_elements = all('a[title^="Lists of"]')
  return if list_of_lists_link_elements.empty?

  list_of_lists_link = list_of_lists_link_elements.sample[:href]

  visit(list_of_lists_link)

  puts list_of_lists_link

  list_link = all('#mw-content-text li > a')
    .map { |element| element[:href] }
    .select { |list_link| list_link =~ /\/wiki\// }
    .reject { |list_link| banned_shit.any? { |pattern| list_link =~ pattern } }
    .reject { |list_link| list_link == '' }
    .select { |list_link| list_link =~ /[Ll]ists?_of/ }
    .compact
    .sample

  return if !list_link
  puts list_link

  visit(list_link)

  link_elements = all('#bodyContent div:not(.navbox):not(.vertical-navbox):not(.catlinks) li, #bodyContent table:not(.navbox-inner) td')

  return if link_elements.empty?

  meme_material_all = link_elements
    .map(&:text)
    .reject { |text| more_banned_shit.any? { |pattern| pattern.is_a?(Regexp) ? text =~ pattern : text.include?(pattern) } }
    .reject { |text| text == '' }
    .select { |text| text.length >= 3 }
    .compact

  return if meme_material_all.size < 4

  meme_material = meme_material_all.sample(4)

  return unless meme_material.uniq.size == meme_material.size

  title = page.title
    .gsub(/.*[Ll]ists? of/, "")
    .gsub(" - Wikipedia", "")

  puts "Title: #{title}"
  puts meme_material

  return meme_material, title
end

def make_dreams_into_memes(meme_material, title)
  return if meme_material.nil?

  command = "convert template-redux.png -font Arial -pointsize 36 -size 100x"
  command += " -draw \"text 15,50 '#{escape_things(title)}'\""

  meme_material.each_with_index do |text, index|
    command += " -draw \"text 15,#{250 + 300 * index} '#{escape_things(text)}'\""
  end

  filename = title.gsub(/[^\w\s_-]+/, '')
    .gsub(/(^|\b\s)\s+($|\s?\b)/, '\\1\\2')
    .gsub(/\s+/, '_')

  command += " output/#{filename}.png"

  puts command

  system command
end

def escape_things(thing)
  thing.gsub('"', '\"').gsub("'", "\\'")
end

while true
  meme_material, title = get_meme_material
  make_dreams_into_memes(meme_material, title)
end
