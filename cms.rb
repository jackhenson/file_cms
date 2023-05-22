require "sinatra"
require "sinatra/reloader"
require "sinatra/content_for"
require "tilt/erubis"
require "redcarpet"

configure do
  enable :sessions
  set :session_secret, 'super_secret'
end

#before do
#  session[:files] = ["about.txt", "changes.txt", "history.txt"]
#end

root = File.expand_path("..", __FILE__)

def render_markdown(text)
  markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  markdown.render(text)
end

def load_file_content(path)
  content = File.read(path)
  case File.extname(path)
  when ".txt"
    headers["Content-Type"] = "text/plain"
    File.read(path)
  when ".md"
    render_markdown(content)
  end
end

def data_path
  if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/data", __FILE__)
  else
    File.expand_path("../data", __FILE__)
  end
end

get "/" do
  pattern = File.join(data_path, "*")
  @files = Dir.glob(pattern).map do |path|
    File.basename(path)
  end
  erb :index, layout: :layout
end

get "/:filename" do
  file_path = File.join(data_path, params['filename']) 

  if File.exist?(file_path) 
    load_file_content(file_path) 
  else
    session[:message] = "#{params['filename']} does not exist."
    redirect '/' 
  end
end

# Edit contents of existing page
get "/:filename/edit" do
  file_path = File.join(data_path, params['filename'])
  @filename = params['filename']
  @content = File.read(file_path)

  erb :edit, layout: :layout
end

# Updates existing page
post "/:filename" do
  file_path = File.join(data_path, params['filename'])

  File.write(file_path, params[:content])

  session[:message] = "#{params['filename']} has been updated."
  redirect "/"
end

