require 'quotes'
require './application_base'

class QuotesApp < ApplicationBase

  get '/' do
    haml :quote_index, :locals => {:quotes => [quotes.sample]}
  end

  post '/search' do
    results = search_results.quotes
    tags = search_results.tags
    query = search_results.query

    msg = "#{results.count} quotes"
    msg += " tagged #{tags.join(' and ')}" if tags.any?
    msg += " that include '#{query}'" unless query.empty?

    haml :quote_index, :locals => {
      :quotes   => search_results.quotes,
      :message  => msg
    }
  end

  ######### start users #########

  get '/login' do
    form_page

    haml :login
  end

  post '/login' do
    result = call_use_case :authenticate_user,
      :nickname => params[:nickname],
      :auth_key => params[:authkey]

    if result.error
      redirect '/login'
    else
      session[:current_user] = result.user
      redirect '/'
    end
  end

  ######### end users #########

  ######### start publications #########

  get '/publications' do
    haml :publication_index, :locals => {:publications => publications}
  end

  ######### end publications #########

  ######### start quotes #########

  get '/quote/:uid' do
    haml :quote_index, :locals => {:quotes => [quote_by_uid(uid)]}
  end

  get '/quotes' do
    haml :quote_index, :locals => {
      :quotes => quotes
    }
  end

  get '/new/quote' do
    form_page

    haml "forms/new_quote".to_sym, :locals => {
      :publications => publications
    }
  end

  post '/new/quote' do
    result = build_quote
    if use_case_type_of(result, 'Success')
      redirect "/quote/#{result.uid}"
    else
      redirect '/quote/new'
    end
  end

  get 'quote/edit/:uid' do
    form_page

    haml "forms/edit_quote".to_sym, :locals => {
      :quote  => quote_by_uid(uid)
    }
  end

  post 'quote/edit/:uid' do
    update_quote

    redirect "/quote/#{uid}"
  end

  get 'quote/delete/:uid' do
    form_page

    haml :confirm_delete, :locals => {:quote => quote_by_uid(uid)}
  end

  post 'quote/delete/:uid' do
    result = delete_quote

    if result != 0
      msg = "Quote with ID ##{uid} has been deleted"
    else
      msg = "Something went wrong.  Quote with ID #{uid} was not deleted"
    end

    haml :quote_index, :locals => {
      :quotes   => quotes,
      :message  => msg
    }
  end

  ######### end quotes #########

  get '/tag/:tag' do
    haml :quote_index, :locals => {:quotes => quotes_by_tag(params[:tag])}
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

  get '/toggle_star' do
    toggle_star
    render :haml, :star, :layout => nil, :locals => { :quote => quote_by_uid(uid) }
  end

end
