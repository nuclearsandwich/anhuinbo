require "sinatra/base"

class HIP
  def self.puzzles
    ["ord", "rand"]
  end

  def self.prompts
    ["corners", "edges", "inner"]
  end
  PUZZLES = [ ["ADMP", "ABCDHLPONMIE", "FGJK"], ["PIBA", "PIBANFNOGDMK", "LEJC"] ]

  attr_reader :puzzle, :prompt

  def initialize puzzle = rand(2), prompt = rand(3)
    @puzzle = puzzle
    @prompt = prompt
  end

  def image
    "#{puzzles[puzzle]}.png"
  end

  def prompt_string
    case prompts[prompt]
    when "corners"
      "Identify two corner pieces."
    when "edges"
      "Identify two edge pieces."
    when "inner"
      "Identify two pieces with no edges."
    end
  end

  def check response
    response = response.upcase.gsub(/[^A-P]/, "")
    puts("RESP: #{response}")
    answers = PUZZLES[puzzle][prompt]
    puts("ANSWERS: #{answers}")

    puts(response == "")
    return false if response == ""

    response.each_char.inject(true) do |value, char|
      puts("VALUE: #{value} ||| CHAR: #{char}")
      value && answers.include?(char)
    end
  end

  def puzzles
    self.class.puzzles
  end

  def prompts
    self.class.prompts
  end
end

class ANHUINBO < Sinatra::Base
  get "/" do
    hip = HIP.new
    <<-HTML
<!DOCTYPE html>
<html lang="en">
  <head>
    <title>Annoy humans. Inhibit bots.</title>
    <style>
    body, h1 { font-family: "Helvetica Neue", "Helvetica", "Arial", sans; }
    img { height: 400px; width: 400px; }
    </style>
  </head>
  <body>
    <h1>Annoy humans. Inhibit bots.</h1>
    <form action="/hip" method="POST">
      <input type="hidden" name="puzzle" value="#{hip.puzzle}"/>
      <input type="hidden" name="prompt" value="#{hip.prompt}"/>
      <img src="/#{hip.image}" alt="hip"/>
      <p>#{hip.prompt_string}</p>
      <input type="text" name="response"/>
      <button type="submit">Gogogo</button>
    </form>
  </body>
</html>
    HTML
  end

  get "/ord.png" do
    content_type "image/png"
    File.read("./ord.png")
  end

  get "/rand.png" do
    content_type "image/png"
    File.read("./rand.png")
  end

  post "/hip" do
    hip = HIP.new(params["puzzle"].to_i, params["prompt"].to_i)
    message = if hip.check(params["response"])
                "You must be human."
              else
                "I don't think you're human."
              end
    <<-HTML
<!DOCTYPE html>
<html lang="en">
  <head>
    <title>Annoy humans. Inhibit bots.</title>
    <style>
    body, h1 { font-family: "Helvetica Neue", "Helvetica", "Arial", sans; }
    img { height: 400px; width: 400px; }
    </style>
  </head>
  <body>
    <h1>#{message}</h1>
   </body>
</html>
    HTML
  end

  get "/hip" do
    redirect "/"
  end
end
