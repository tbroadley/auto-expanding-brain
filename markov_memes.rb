require 'literate_randomizer'

def get_meme_material
  first_word = "Eating"

  (1..4).map do
    LiterateRandomizer.sentence
  end
end

def make_dreams_into_memes(meme_material)
  return if meme_material.nil?

  command = "convert template.png -font Arial -pointsize 36 -size 100x"

  meme_material.each_with_index do |text, index|
    command += " -draw \"text 15,#{150 + 300 * index} '#{escape_things(text)}'\""
  end

  filename = Time.now.to_i

  command += " output/markov_memes/#{filename}.png"

  puts command

  system command
end

def escape_things(thing)
  thing.gsub('"', '\"').gsub("'", "\\'")
end

# while true
  make_dreams_into_memes(get_meme_material)
# end
