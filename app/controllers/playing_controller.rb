class PlayingController < ApplicationController
  def game
    @grid = generate_grid(8)
  end

  def score
    session[:round] = session[:round].nil? ? 1 : session[:round] + 1

    @round = session[:round]
    @params = params

    answer = params[:answer]
    grid = params[:grid].split('')
    startTime = params[:time].to_time
    @result = run_game(answer, grid, startTime, Time.new);

    score = @result[:score]
    session[:average_score] = session[:average_score] ? (session[:average_score] * (@round-1) + score).to_f / @round : score
    @average_score = session[:average_score]
  end
end


def generate_grid(grid_size)
  grid = []
  grid_size.times do
    grid << ("A".."Z").to_a.sample(1)
  end
  return grid
end

def run_game(attempt, grid, start_time, end_time)
  # TODO: runs the game and return detailed hash of result
  translation = get_translation(attempt)
  score = 0

  if translation != attempt && check_anagram(attempt, grid)
    time = ((end_time - start_time).to_f / 60)
    score = attempt.length.to_f / (1 + ((end_time - start_time) / 60)).to_f
    message = "well done"
  elsif translation == attempt && check_anagram(attempt, grid)
    translation = nil
    message = "not an english word"
  elsif !check_anagram(attempt, grid)
    message = "not in the grid"
  end
  return make_result_hash(time, translation, score, message)
end

def make_result_hash(time, translation, score, message)
  result = {}
  result[:time] = time
  result[:translation] = translation
  result[:score] = score
  result[:message] = message
  return result
end

def check_anagram(attempt, grid)
  attempt = attempt.upcase.split('')
  return attempt.all? do |letter|
    found = false
    if grid.include?(letter)
      found = true
      index = grid.index(letter)
      grid[index] = false
    end
    found
  end
end

def get_translation(attempt)
  url = "https://api-platform.systran.net/translation/text/translate?source=en&target=fr&"
  url += "key=1f9263ee-8434-4d19-b321-47526c307fa7&input=#{attempt}"
  uri = URI(url)
  response = Net::HTTP.get(uri)
  return JSON.parse(response)["outputs"][0]["output"]
end

