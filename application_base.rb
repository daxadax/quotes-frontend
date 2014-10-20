class ApplicationBase < Sinatra::Application

    def quotes
      @quotes ||= get_quotes
    end

    def search_results
      @search_results ||= build_search_results
    end

    def starred
      quotes.select {|q| q.starred == true}
    end

    def quote_by_id(id)
      input   = { :id => id }
      result  = call_use_case(:GetQuote, input)

      result.quote
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

      call_use_case(:Search, input)
    end

    def build_quote
      year        = params[:year]         unless params[:year].empty?
      publisher   = params[:publisher]    unless params[:publisher].empty?
      page_number = params[:page_number]  unless params[:page_number].empty?
      tags        = params[:tags].split(',').each(&:strip!)
      links       = nil

      input = {
        :author       => params[:author],
        :title        => params[:title],
        :content      => params[:content],
        :year         => year,
        :publisher    => publisher,
        :page_number  => page_number,
        :tags         => tags,
        :links        => links
      }

      call_use_case(:CreateQuote, {:quote => input})
    end

    def update_quote
      quote = quote_by_id(id)

      input = {
        :id           => id,
        :author       => params[:author]        || quote.author,
        :title        => params[:title]         || quote.title,
        :content      => params[:content]       || quote.content,
        :year         => params[:year]          || quote.year,
        :publisher    => params[:publisher]     || quote.publisher,
        :page_number  => params[:page_number]   || quote.page_number,
        :links        => params[:links]         || quote.links,
        :tags         => build_tags(quote.tags)
      }

      call_use_case(:UpdateQuote, {:quote => input})
    end

    def build_tags(tags)
      return params[:tags].split(',').each(&:strip!) if params[:tags]
      tags
    end

    def delete_quote
      input = { :id => id }

      call_use_case(:DeleteQuote, input)
    end

    def toggle_star
      input = { :id => id }

      call_use_case(:ToggleStar, input)
    end

    def get_quotes
      use_case  = Quotes::UseCases::GetQuotes.new
      result    = use_case.call.quotes

      return [] if result.empty?
      result.reverse
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

      attributes.inject { |last, attribute| hash[attribute] += 1; attribute}
      # max_count = @max ||= hash.values.max
      # hash.each { |k, v| hash[k] = build_relative_attribute_count(max_count, v) }

      hash.sort_by {|k, v| v}.reverse
    end

    def build_relative_attribute_count(max, value)
      result = (value/max.to_f)*5

      result.round
    end

    def call_use_case(usecase, input)
      use_case = Quotes::UseCases.const_get(usecase).new(input)

      use_case.call
    end

    def use_case_type_of(result, type)
      result = result.class.name.split('::').last.downcase

      return true if result == type.downcase
      false
    end

    def id
      params[:id].to_i
    end

  end

  helpers do

    def link_to(url,text=url,opts={})
      attributes = ""
      opts.each { |key,value| attributes << key.to_s << "=\"" << value << "\" "}
      "<a href=\"#{url}\" #{attributes}>#{text}</a>"
    end

    def show_author_for(quote)
      link_to "/author/#{quote.author}", quote.author unless params[:author]
    end

    def show_title_for(quote)
      link_to "/title/#{quote.title}", quote.title unless params[:title]
    end

    def display_relevant_count_for(quotes)
      return "#{quotes.size} quotes tagged '#{params[:tag]}'" if params[:tag]
      return "#{quotes.size} quotes by #{params[:author]}" if params[:author]
      return "#{quotes.size} quotes from #{params[:title]}" if params[:title]
    end

    def markdown(text)
      render_options = {
        filter_html:     true,
        hard_wrap:       true
      }
      renderer = Redcarpet::Render::HTML.new(render_options)

      extensions = {
        autolink:           true,
        fenced_code_blocks: true,
        lax_spacing:        true,
        no_intra_emphasis:  true,
        strikethrough:      true,
        superscript:        true
      }

      Redcarpet::Markdown.new(renderer, extensions).render(text)
    end

  end