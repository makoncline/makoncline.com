require 'erb'
require 'date'
require 'rss'
require_relative 'toc.rb'

def template(name)
	ERB.new(File.read("templates/#{name}.erb"), nil, '<>').result
end

def h(str)
	ERB::Util.html_escape(str)
end

class String
	def autolink
		self.gsub(/(http\S*)/, '<a href="\1">\1</a>')
	end
end

def write_if_changed(filepath, contents)
	if File.exist?(filepath)
		old_contents = File.read(filepath).strip
		return unless contents.strip != old_contents
	end
	File.open(filepath, 'w') {|f| f.puts contents }
end

# if it has <img>, return last one. false if not.
def get_img(txt)
	r = %r{<img.*src="([^"]+)"}
	res = txt.scan(r).pop
	return false unless res
	img = res.pop
	(img.start_with? 'http') ? img : 'makoncline.com' + img
end

# if it has youtube URLs, get image from last one. false if not.
def get_youtube_img(txt)
	r = %r{www.youtube(-nocookie)?.com/(embed/|watch\?v=)([^"]+)}
	res = txt.scan(r).pop
	return false unless res
	'http://img.youtube.com/vi/%s/0.jpg' % res.pop
end

def get_image(txt)
	fallback_img = 'makoncline.com/images/test.jpg'
	get_img(txt) || get_youtube_img(txt) || fallback_img
end

# get first <p> or <h> text. strip newlines, quotes, and tags
def get_description(txt)
	r = %r{<(p|h[1-4])>(.+?)</(p|h[1-4])>}m
	m = r.match(txt)
	return 'Chemical Engineer, beginner programmer, avid student of life. I want to make useful things, and share what I learn.' unless m
	m[2].gsub(/[\r\n\t"]/, '').strip.gsub(%r{</?[^>]+?>}, '')
end

# returns hash with bits gleaned from filename
def parse_filename(fullpath)
	filename = File.basename(fullpath)
	if m = /\A([0-9]{4}-[0-9]{2}-[0-9]{2})-(\S+)\Z/.match(filename) # yyyy-mm-dd-url
		{all: m[0], date: m[1], url: m[2], year: m[1][0,4]}
	elsif m = /\A([0-9]{4}-[0-9]{2})-(\S+)\Z/.match(filename) # yyyy-mm-url
		{all: m[0], month: m[1], url: m[2], year: m[1][0,4]}
	elsif m = /\A(\d{4}-\d{2}-\d{2})/.match(filename) # yyyy-mm-dd+?
		{all: m[0], date: m[1]}
	else
		raise "#{fullpath} doesn't match pattern"
	end
end

# some blog posts link to "Articles"/blog, but some link to a book page
def parent_for(uri)
		'<a href="/blog" rel="tag">Articles</a>'
end

# hash to cache uri => title for each blog post
titlecache = {}

desc "build site/ from content/ and templates/"
task :make do
	# collection of all URLs, for making Sitemap
	@urls = []
	# set prev1 and next1 to nil, because universal header checks for them
	@prev1 = @next1 = nil

	########## READ, PARSE, AND WRITE BLOG POSTS
	@blogs = []
	# going through files this way, instead of the usual ".each", to get next1 and prev1
	filez = Dir['content/blog/20*'].sort
	filezmax = filez.size - 1
	(0..filezmax).each do |i|
		infile = filez[i]
		@prev1 = (i == 0) ? nil : parse_filename(filez[i - 1])[:url]
		@next1 = (i == filezmax) ? nil : parse_filename(filez[i + 1])[:url]
		pf = parse_filename(infile)
		@date = pf[:date]
		@url = pf[:url]
		@parent = parent_for(@url)
		@year = pf[:year]
		lines = File.readlines(infile)
		/<!--\s+(.+)\s+-->/.match lines.shift
		@title = $1
		titlecache[@url] = @title
		@body = lines.join('')
		@pagetitle = "#{@title} | Makon Cline"
		@pageimage = get_image(@body)
		@pagedescription = get_description(@body)
		@bodyid = 'oneblog'

		# merge with templates and WRITE file
		html = template('header')
		html << template('blog')
		html << template('comments')
		html << template('footer')
		write_if_changed("site/#{@url}", html)

		# save to array for later use in index and home page
		@blogs << {date: @date, url: @url, title: @title, html: @body}
		@urls << @url
	end
	# set prev1 and next1 to nil (again), because universal header checks for them
	@prev1 = @next1 = nil


	########## WRITE BLOG INDEX PAGE
	@blogs.reverse!
	@pagetitle = 'Makon Cline Blog'
	@pageimage = get_image('')
	@pagedescription = 'all blog posts from 2017 until now'
	@url = 'blog'
	@bodyid = 'bloglist'
	html = template('header')
	html << template('bloglist')
	html << template('footer')
	write_if_changed("site/#{@url}", html)

	########## READ, PARSE, AND WRITE BOOK NOTES
	@books = []
	Dir['content/books/20*'].each do |infile|
		pf = parse_filename(infile)
		@date = pf[:date]
		@uri = pf[:url]
		lines = File.readlines(infile)
		/^TITLE: (.+)$/.match lines.shift
		@title = $1
		/^ISBN: (\w+)$/.match lines.shift
		@isbn = $1
		/^RATING: (\d+)$/.match lines.shift
		@rating = $1
		/^SUMMARY: (.+)$/.match lines.shift
		@summary = $1
		lines.shift	# the line that says 'NOTES:'
		@notes = lines.join('').gsub("\n", "<br>\n")
		@pagetitle = "#{@title} | Derek Sivers"
		@pageimage = get_image(template('book'))
		@pagedescription = @summary.gsub('"', '')
		@bodyid = 'onebook'
		@url = 'book/%s' % @uri

		# merge with templates and WRITE file
		html = template('header')
		html << template('book')
		html << template('footer')
		write_if_changed("site/#{@url}", html)

		# save to array for later use in index and home page
		@books << {date: @date, url: @url, uri: @uri, title: @title, isbn: @isbn, rating: @rating, summary: @summary}
		@urls << @url
	end


	########## WRITE BOOKS INDEX PAGE
	# sivers.org/book = top rated at top
	@books.sort_by!{|x| '%02d%s%s' % [x[:rating], x[:date], x[:url]]}
	@books.reverse!
	@pagetitle = 'BOOKS | Makon Cline'
	@pageimage = get_image('<img src="/images/bookstand.jpg">')
	@pagedescription = 'over 200 book summaries with detailed notes for each'
	@bodyid = 'booklist'
	@url = 'book'
	html = template('header')
	html << template('booklist')
	html << template('footer')
	write_if_changed('site/book/home', html)
	# sivers.org/book/new = newest at top (for auto-RSS followers)
	@books.sort_by!{|x| '%s%02d%s' % [x[:date], x[:rating], x[:url]]}
	@books.reverse!
	@url = 'book/new'
	html = template('header')
	html << template('booklist')
	html << template('footer')
	write_if_changed("site/#{@url}", html)



	########## READ AND PARSE TWEETS
	@tweets = []
	Dir['content/tweets/20*'].sort.each do |infile|
		pf = parse_filename(infile) #	(a at end means favorite)
		date = pf[:date]
		d = Date.parse(date)
		tweet = ERB::Util.html_escape(File.read(infile).strip).autolink
		# save to array for later use in index and home page
		@tweets << {date: date, show_date: d.strftime('%B %-d'), show_year: d.strftime('%B %-d, %Y'), tweet: tweet}
	end


	########## WRITE TWEETS INDEX PAGE
	@tweets.reverse!
	@pagetitle = 'Derek Sivers Tweets'
	@pageimage = get_image('')
	@pagedescription = 'an archive of all tweets from 2007 til now'
	@bodyid = @url = 'tweets'
	html = template('header')
	html << template('tweets')
	html << template('footer')
	write_if_changed("site/#{@url}", html)


	########## WRITE HOME PAGE
	@new_blogs = @blogs[0,6]
	@new_tweets = @tweets[0,6]
	@pagetitle = 'Makon Cline'
	@pageimage = get_image('')
	@pagedescription = get_description('')
	@bodyid = 'home'
	@url = ''
	html = template('header')
	html << template('home')
	html << template('footer')
	write_if_changed('site/home', html)


	########## READ, PARSE, WRITE STATIC PAGES
	Dir['content/pages/*'].each do |infile|

		# PARSE. Filename: uri
		@url = @bodyid = File.basename(infile)
		lines = File.readlines(infile)
		/<!--\s+(.+)\s+-->/.match lines.shift
		@title = $1
		body = lines.join('')
		@pagetitle = "#{@title} | Makon Cline"
		@pageimage = get_image(body)
		@pagedescription = get_description(body)

		# merge with templates and WRITE file
		html = template('header')
		html << body
		html << template('footer')
		write_if_changed("site/#{@url}", html)
		@urls << @url
	end


desc 'make a new tweet'
task :tweet do
	filename = Time.now.strftime('%Y-%m-%d-00')
	system "vim content/tweets/#{filename}"
end

task :default => [:make]
