class ApplicationBase < Sinatra::Application
  include Helpers::UseCaseCalling

    def quotes
      #cache for 60 seconds

      get_quotes
    end

    def publications
      #cache for 60 seconds

      get_publications
    end

    def current_user
      return nil unless current_user_uid
      @curent_user ||= get_user(current_user_uid)
    end

    def current_user_owns?(quote)
      return false unless current_user
      current_user.uid == quote.added_by ? true : false
    end

    def current_user_uid
      return nil unless session[:current_user_uid]
      session[:current_user_uid].to_i
    end

    def registration_path
      'users/register'
    end

    def login_path
      'users/login'
    end

    def publications_path
      'publications/index'
    end

    def new_publication_path
      'publications/new'
    end

    def edit_publication_path
      'publications/edit'
    end

    def publication_partial
      'publications/publication'
    end

    def quotes_path
      'quotes/index'
    end

    def new_quote_path
      'quotes/new'
    end

    def edit_quote_path
      'quotes/edit'
    end

    def remove_quote_path
      'quotes/remove'
    end

    def quote_partial
      'quotes/quote'
    end

    def user_profile_path(uid = nil)
      uid ||= current_user.uid

      "/user/#{uid}"
    end

    def user_partial
      '/users/user'
    end

    def user_quotes_path(uid, limit = nil)
      limit = "?limit=#{limit}" if limit

      "/user/#{uid}/added/quotes" + limit.to_s
    end

    def user_publications_path(uid, limit = nil)
      limit = "?limit=#{limit}" if limit

      "/user/#{uid}/added/publications" + limit.to_s
    end

    def favorite_quotes_path(uid, limit = nil)
      limit = "?limit=#{limit}" if limit

      "/user/#{uid}/favorites" + limit.to_s
    end

    def user_tags_path(uid, limit = nil)
      limit = "?limit=#{limit}" if limit

      "/user/#{uid}/tags" + limit.to_s
    end

    def untagged_quotes_path
      "/user/#{current_user_uid}/untagged"
    end

    def handle_login_error(error)
      msg = "No user with that nickname is registered" if error == :user_not_found
      msg = "The password you entererd isn't right" if error == :auth_failure

      messages << msg
      redirect '/login'
    end

    def display_messages_and_reset_cache(&block)
      messages.each &block
      messages.clear
    end

    def messages
      session[:messages] ||= Array.new
    end

    def quote_by_uid(uid)
      result  = call_use_case :get_quote, :uid => uid.to_i

      result.quote
    end

    def publication_by_uid(uid)
      result = call_use_case :get_publication, :uid => uid.to_i

      result.publication
    end

    def publications_by_user(uid)
      publications.select { |publication| publication.added_by == uid }
    end

    def quotes_by_user(uid)
      quotes.select { |quote| quote.added_by == uid }
    end

    def favorite_quotes_for_user(uid)
      user = get_user(uid)

      quotes.select { |quote| user.favorites.include?(quote.uid) }
    end

    def quotes_by_publication(publication_uid)
      quotes.select { |quote| quote.publication_uid == publication_uid.to_i }
    end

    def quotes_by_tag(tag)
     quotes.select {|quote| quote.tags.include?(tag)}
    end

    def untagged_quotes_for_user(uid)
      quotes = quotes_by_user(uid)

      quotes.select {|q| q.tags.empty?}
    end

    def quotes_by_author(author)
      quotes.select { |quote| quote.author == author}
    end

    def quotes_by_title(title)
      quotes.select { |quote| quote.title == title }
    end

    def display_page(location, locals = {})
      @form_page = !locals.delete(:form_page).nil?
      haml location.to_sym, :locals => locals
    end

    def display_widget(locals = {})
      display_page 'widget', locals\
    end

    def get_tags(user_uid = nil)
      used_quotes = user_uid ?  quotes_by_user(user_uid) : quotes

      @tags ||= build_attributes used_quotes.flat_map(&:tags)
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

    def publication_uid_for(object)
      type = object.class.name.split('::').last

      return object.publication_uid if type == 'Quote'
      object.uid
    end

    def uid
      params[:uid].to_i
    end

  end

  helpers do

    def link_to(url, text=url, opts={})
      attributes = ""
      opts.each { |key,value| attributes << key.to_s << "=\"" << value << "\" "}
      "<a href=\"#{url}\" #{attributes}>#{text}</a>"
    end

    def show_author_for(quote)
      author = quote.author
      link_to "/author/#{author}", author unless params[:author]
    end

    def show_title_for(object)
      uid = publication_uid_for object
      title = object.title

      link_to "/publication/#{uid}", title
    end

    def show_author_for(object)
      uid = publication_uid_for object
      author = object.author

      link_to "/authors/#{author}", author
    end

    def determine_favorite_class(quote_uid)
      return ' ' unless current_user
      current_user.favorites.include?(quote_uid) ? 'favorite' : ''
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
