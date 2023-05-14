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

get "/" do
  @files = Dir.glob(root + "/data/*").map do |path|
    File.basename(path)
  end
  erb :index, layout: :layout
end

get "/:filename" do
  file_path = root + "/data/" + params['filename']
 
  if File.file?(file_path) 
    headers["Content-Type"] = "text/plain"
    File.read(file_path)
  else
    session[:message] = "#{params['filename']} does not exist."
    redirect '/' 
  end
end
