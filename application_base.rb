enable :sessions

class ApplicationBase < Sinatra::Application

    def quotes
      #cache for 60 seconds

      @quotes ||= get_quotes
    end

    def publications
      #cache for 60 seconds

      @publications ||= get_publications
    end

    def current_user
      return nil unless current_user_uid
      get_user current_user_uid
    end

    def current_user_owns?(quote)
      current_user.uid == quote.added_by ? true : false
    end

    def current_user_uid
      return nil unless session[:current_user_uid]
      session[:current_user_uid].to_i
    end

    def display_messages_and_reset_cache(&block)
      session[:messages].each &block
      session[:messages] = Array.new
    end

    def search_results
      @search_results ||= build_search_results
    end

    def starred
      quotes.select {|q| q.starred == true}
    end

    def quote_by_uid(uid)
      result  = call_use_case :get_quote, :uid => uid

      result.quote
    end

    def publication_by_uid(uid)
      result = call_use_case :get_publication, :uid => uid

      result.publication
    end

    def quotes_by_tag(tag)
     quotes.select {|quote| quote.tags.include?(tag)}
    end

    def quotes_by_author(author)
      quotes.select { |quote| quote.author == author}
    end

    def quotes_by_title(title)
      quotes.select { |quote| quote.title == title }
    end

    def form_page
      @form_page = true
    end

    def build_search_results
      input = { :query => params[:search] }

      call_use_case(:search, input)
    end

    def build_publication
      call_use_case :create_publication, :publication => {
        :author => params[:author],
        :title => params[:title],
        :publisher => params[:publisher],
        :year => params[:year]
      }
    end

    def build_quote
      page_number = params[:pagenumber]  unless params[:pagenumber].empty?
      links = nil

      call_use_case :create_quote,
        :user_uid => current_user.uid,
        :quote => {
          :content => params[:content],
          :publication_uid => params[:publication].to_i,
          :page_number => page_number,
          :tags => build_tags,
          :links => links
        }
    end

    def update_quote
      quote = quote_by_uid(uid)

      call_use_case :update_quote,
        :user_uid => current_user.uid,
        :quote => {
           :uid => uid,
           :content => params[:content] || quote.content,
           :publication_uid => params[:publication].to_i || quote.publication_uid,
           :page_number => params[:pagenumber] || quote.page_number,
           :links => params[:links] || quote.links,
           :tags => build_tags || quote.tags
        }
    end

    def build_tags
      params[:tags].split(',').each(&:strip!) if params[:tags]
    end

    def delete_quote
      input = { :uid => uid }

      call_use_case(:delete_quote, input)
    end

    def get_publications
      call_use_case(:get_publications).publications
    end

    def get_quotes
      call_use_case(:get_quotes).quotes
    end

    def get_user(uid)
      result = call_use_case(:get_user, :uid => uid)

      return result.user unless result.error
    end

    def get_tags
      @tags ||= build_attributes quotes.flat_map(&:tags)
    end

    def get_top_tags
      @top_tags ||= get_tags.select{ |tag, count| count > 0}
    end

    def get_authors
      @authors ||= build_attributes quotes.flat_map(&:author)
    end

    def get_titles
      @titles ||= build_attributes quotes.flat_map(&:title)
    end

    def build_attributes(attributes)
      hash = Hash.new { |h, k| h[k] = 0}

      attributes.inject { |result, attribute| hash[attribute] += 1; result}

      hash.sort_by {|k, v| v}.reverse
    end

    def call_use_case(use_case, args = nil)
      eval("Manager::Interface.#{use_case}(#{args})")
    end

    def uid
      params[:uid].to_i
    end

  end

  helpers do

    def link_to(url,text=url,opts={})
      attributes = ""
      opts.each { |key,value| attributes << key.to_s << "=\"" << value << "\" "}
      "<a href=\"#{url}\" #{attributes}>#{text}</a>"
    end

    def show_author_for(quote)
      author = quote.author

      link_to "/author/#{author}", author unless params[:author]
    end

    def show_publication_information_for(quote)
      title = quote.title
      page_information = " page #{quote.page_number}" if !quote.page_number.empty?


      "#{link_to "/title/#{title}", title unless params[:title]} #{page_information}"
    end

    def display_relevant_count_for(quotes)
      return "#{quotes.size} quotes tagged '#{params[:tag]}'" if params[:tag]
      return "#{quotes.size} quotes by #{params[:author]}" if params[:author]
      return "#{quotes.size} quotes from #{params[:title]}" if params[:title]
    end

    def markdown(text)
      render_options = {
        filter_html: true,
        hard_wrap: true
      }
      renderer = Redcarpet::Render::HTML.new(render_options)

      extensions = {
        autolink: true,
        fenced_code_blocks: true,
        lax_spacing: true,
        no_intra_emphasis: true,
        strikethrough: true,
        superscript: true
      }

      Redcarpet::Markdown.new(renderer, extensions).render(text)
    end

  end
