require 'quotes'
require './application_base'

class QuotesApp < ApplicationBase

  get '/' do
    haml :index, :locals => {:quotes => [quotes.sample]}
  end

  post '/search' do
    results = search_results.quotes
    tags    = search_results.tags
    query   = search_results.query

    msg = "#{results.count} quotes"
    msg += " tagged #{tags.map(&:upcase).join(' and ')}" if tags.any?
    msg += " that include '#{query}'" unless query.empty?

    haml :index, :locals => {
      :quotes   => search_results.quotes,
      :message  => msg
    }
  end

  get '/quote/:id' do
    haml :index, :locals => {:quotes => [quote_by_id(id)]}
  end

  get '/quotes' do
    haml :index, :locals => {:quotes => quotes}
  end

  get '/tag/:tag' do
    haml :index, :locals => {:quotes => quotes_by_tag(params[:tag])}
  end

  get '/tags' do
    haml :attribute_index, :locals => {
      :attributes => get_tags,
      :kind       => 'tag'
    }
  end

  get '/starred' do
    msg = "You haven't got any favorite quotes" if starred.empty?

    haml :index, :locals => {
      :quotes   => starred,
      :message  => msg
    }
  end

  get '/author/:author' do
    haml :index, :locals => {:quotes => quotes_by_author(params[:author])}
  end

  get '/authors' do
    haml :attribute_index, :locals => {
      :attributes => get_authors,
      :kind       => 'author'
    }
  end

  get '/title/:title' do
    haml :index, :locals => {:quotes => quotes_by_title(params[:title])}
  end

  get '/titles' do
    haml :attribute_index, :locals => {
      :attributes => get_titles,
      :kind       => 'title'
    }
  end

  get '/new' do
    form_page

    haml :form, :locals => {:tags => get_top_tags}
  end

  post '/new' do
    result = build_quote
    if use_case_type_of(result, 'Success')
      redirect "/quote/#{result.id}"
    else
      redirect '/new'
    end
  end

  get '/edit/:id' do
    form_page

    haml :form, :locals => {
      :tags   => get_top_tags,
      :quote  => quote_by_id(id)
    }
  end

  post '/edit/:id' do
    update_quote

    redirect "/quote/#{id}"
  end

  get '/delete/:id' do
    form_page

    haml :confirm_delete, :locals => {:quote => quote_by_id(id)}
  end

  post '/delete/:id' do
    result = delete_quote

    if result != 0
      msg = "Quote with ID ##{id} has been deleted"
    else
      msg = "Something went wrong.  Quote with ID #{id} was not deleted"
    end

    haml :index, :locals => {
      :quotes   => quotes,
      :message  => msg
    }
  end

  get '/toggle_star' do
    toggle_star
    render :haml, :star, :layout => nil, :locals => { :quote => quote_by_id(id) }
  end

end