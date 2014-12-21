require 'quotes'
require './application_base'

class QuotesApp < ApplicationBase

  get '/' do
    display_page quotes_path, :quotes => [quotes.sample]
  end

  post '/search' do
    results = search_results.quotes
    tags = search_results.tags
    query = search_results.query

    msg = "#{results.count} quotes"
    msg += " tagged #{tags.join(' and ')}" if tags.any?
    msg += " that include '#{query}'" unless query.empty?

    messages << msg
    display_page quotes_path, :quotes => result.quotes
  end

  ######### start users #########

  get '/login' do
    display_page login_path, :form_page => true
  end

  post '/login' do
    auth_key = params[:nickname] + params[:password]

    result = call_use_case :authenticate_user,
      :nickname => params[:nickname],
      :auth_key => auth_key,
      :login_data => {
        :ip_address => 'how to get the ip in sinatra?'
      }

    if result.error
      handle_login_error(result.error)
    else
      session[:current_user_uid] = result.uid
      messages << 'Authentication successful'

      redirect '/'
    end
  end

  get '/logout' do
    session[:current_user_uid] = nil
    messages << "You have been signed out"

    redirect '/'
  end

  get '/user/new' do
    display_page registration_path, :form_page => true
  end

  post '/user/new' do
    email = params[:email].empty? ? 'no email added' : params[:email]
    auth_key = params[:nickname] + params[:password]

    result = call_use_case :create_user,
      :nickname => params[:nickname],
      :email => email,
      :auth_key => auth_key

    if result.error
      messages << "Invalid input"
      redirect '/user/new'
    else
      session[:current_user_uid] = result.uid
      messages << "Registration successful"
      redirect '/'
    end
  end

  get '/user/:uid' do
    user = get_user(uid)

    display_page user_partial, :user => user
  end

  get '/user/:uid/added/quotes' do
    quotes = quotes_by_user uid
    quotes = quotes.first(params[:limit].to_i) if params[:limit]

    messages << "You haven't added any quotes!" if quotes.empty?
    display_page quotes_path, :quotes => quotes
  end

  get '/user/:uid/added/publications' do
    publications = publications_by_user uid
    publications = publications.first(params[:limit].to_i) if params[:limit]

    messages << "You haven't added any publications!" if publications.empty?
    display_page publications_path, :publications => publications
  end

  get '/user/:uid/untagged' do
    quotes = untagged_quotes_for_user uid

    if quotes.empty?
      messages << "You haven't added any quotes!"
    else
      messages << "#{quotes.size} quotes with no tags"
    end

    display_page quotes_path, :quotes => quotes
  end

  get '/user/:uid/favorites' do
    quotes = favorite_quotes_for_user uid
    quotes = quotes.first(params[:limit].to_i) if params[:limit]

    if quotes.empty?
      messages << "You haven't marked any favorite quotes!"
    else
      messages << "#{quotes.size} favorite quotes"
    end

    display_page quotes_path, :quotes => quotes
  end

  get '/user/:uid/tags' do
    tags = get_tags(uid)
    tags = tags.first(params[:limit].to_i) if params[:limit]

    messages << "You haven't tagged any quotes!" if tags.empty?
    display_page :attribute_index, :attributes => tags, :kind => 'tag'
  end

  ######### end users #########

  ######### start publications #########

  get '/publications' do
    display_page publications_path, :publications => publications
  end

  get %r{/publication/([\d]+)} do |uid|
    display_page publications_path, :publications => [publication_by_uid(uid)]
  end

  get '/publication/new' do
    display_page new_publication_path, :form_page => true
  end

  post '/publication/new' do
    result = build_publication

    if result.error
      session[:messages] << "Invalid input"
      redirect '/publication/new'
    else
      session[:messages] << "Publication created successfully"
      redirect "/publication/#{result.uid}"
    end
  end

  get '/user/:uid/added/publications' do
    publications = publications_by_user uid

    session[:messages] << "You haven't added any publications!" if publications.empty?
    display_page publications_path, :publications => publications
  end

  ######### end publications #########

  ######### start quotes #########

  get %r{/quote/([\d]+)} do |uid|
    display_page quotes_path, :quotes => [ quote_by_uid(uid) ]
  end

  get '/quotes' do
    display_page quotes_path, :quotes => quotes
  end

  get '/quote/new' do
    display_page new_quote_path,
      :form_page => true,
      :publications => publications
  end

  post '/quote/new' do
    result = build_quote

    if result.error
      messages << "Invalid input"
      redirect '/quote/new'
    else
      messages << "Quote created successfully"
      redirect "/quote/#{result.uid}"
    end
  end

  get '/quote/edit/:uid' do
    display_page edit_quote_path,
      :form_page => true,
      :quote => quote_by_uid(uid)
  end

  post '/quote/edit/:uid' do
    result = update_quote
    redirect "/quote/#{uid}"
  end

  get '/quote/delete/:uid' do
    display_page :confirm_delete,
      :form_page => true,
      :quote => quote_by_uid(uid)
  end

  post '/quote/delete/:uid' do
    result = delete_quote

    if result.error
      msg = "Something went wrong.  Quote with ID #{uid} was not deleted"
    else
      msg = "Quote with ID ##{uid} has been deleted"
    end

    messages << msg
    redirect '/'
  end

  ######### end quotes #########

  get '/tag/:tag' do
    display_page quotes_path, :quotes => quotes_by_tag(params[:tag])
  end

  get '/tags' do
    display_page :attribute_index,
      :attributes => get_tags,
      :kind => 'tag'
  end

  get '/author/:author' do
    display_page quotes_path, :quotes => quotes_by_author(params[:author])
  end

  get '/authors' do
    display_page :attribute_index,
      :attributes => get_authors,
      :kind => 'author'
  end

  get '/title/:title' do
    display_page quotes_path, :quotes => quotes_by_title(params[:title])
  end

  get '/titles' do
    display_page :attribute_index,
      :attributes => get_titles,
      :kind => 'title'
  end

  get '/toggle_star' do
    toggle_star
    render :haml, :star, :layout => nil, :locals => { :quote => quote_by_uid(uid) }
  end

end
