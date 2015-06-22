require 'sinatra'
require 'rubygems'
require 'nokogiri'
require 'open-uri'

URL = 'http://a2oj.com/Profile.jsp?Username='

JUDGE = 'codeforces'
ID = '245H'

class User 
	attr_accessor :id
	attr_accessor :page
	attr_accessor :ac
	attr_accessor :acs
end

users = []

judgeNames = ["A2", "TopCoder", "UVA", "SPOJ", "Live", "Codeforces", "TJU", "PKU", "Timus", "All"]

get '/' do
	erb :index, :locals => {:users => users, :judgeNames => judgeNames}
end

post '/upload' do
	unless params[:file] && tempfile = params['file'][:tempfile]
		erb :index, :locals => {:error => "error on uploading file!"}
	else 
		users = []
		tempfile.read.each_line do |user|
			
			id = user.delete("\n")
			puts "loading " + id + " data"

			u = User.new
			u.ac = false
			u.id = id
			u.page = nil
			#u.page = Nokogiri::HTML(open(URL + id))
			u.page = Nokogiri::HTML(File.open("bimaoe.html", "r").read);

			#get acs	
			u.acs = {};
			table = u.page.css("table")[3].css("td")
			for i in 0..table.length-2
				if i % 2 == 0
					judgeName = table[i].text.split(' ')[0]
					u.acs[judgeName] = table[i+1].text
				end 
			end

			users.push(u)
		end
		
		erb :index, :locals => {:users => users, :judgeNames => judgeNames}
	end
end

post '/check' do
	judge = params[:judge]
	problem =  params[:problem]
	for u in 0..users.length-1
		users[u].ac = false
		unless users[u].page.nil?
			tablelist = users[u].page.css("table")
			for i in 1..tablelist.length-1
				problemlist = tablelist[i].css("a")
				for j in 0..problemlist.length-1
					link = problemlist[j]['href']
					id = problemlist[j].text
					if link.include? judge and id.eql? problem
						users[u].ac = true
						puts users[u].id + link + " " + id 
						break
					end
				end
			end
		end
	end
	erb :index, :locals => {:users => users, :jnames => judgeNames}
end


