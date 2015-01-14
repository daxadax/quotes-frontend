require './application_base'

class QuotesApp < ApplicationBase

  get '/' do
    redirect user_profile_path if current_user
    redirect '/random'
  end

  get '/random' do
    show_quote(quotes.sample)
  end

  post '/search' do
    result = build_search_results
    tags = result.tags
    query = result.query

    msg = "#{result.quotes.count} quotes"
    msg += " tagged #{tags.join(' and ')}" if tags.any?
    msg += " that include '#{query}'" unless query.empty?

    messages << msg
    show_quotes result.quotes
  end

  ######### start users #########

  get '/login' do
    display_page login_template, :form_page => true
  end

  post '/login' do
    auth_key = params[:nickname] + params[:password]

    result = call_use_case :authenticate_user,
      :nickname => params[:nickname],
      :auth_key => auth_key,
      :login_data => {
        :ip_address => request.ip
      }

    if result.error
      handle_login_error(result.error)
    else
      session[:current_user_uid] = result.uid
      messages << 'Authentication successful'

      redirect user_profile_path
    end
  end

  get '/logout' do
    session[:current_user_uid] = nil
    messages << "You have been signed out"

    redirect '/'
  end

  get '/user/new' do
    display_page registration_template, :form_page => true
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
    show_quotes quotes
  end

  get '/user/:uid/untagged' do
    quotes = untagged_quotes_for_user uid

    if quotes.empty?
      messages << "You haven't added any quotes!"
    else
      messages << "#{quotes.size} quotes with no tags"
    end

    show_quotes quotes
  end

  get '/user/:uid/favorites' do
    quotes = favorite_quotes_for_user uid
    quotes = quotes.first(params[:limit].to_i) if params[:limit]

    if quotes.empty?
      messages << "You haven't marked any favorite quotes!"
    end

    show_quotes quotes
  end

  get '/user/:uid/tags' do
    tags = build_attributes get_tags(uid)
    tags = tags.first(params[:limit].to_i) if params[:limit]

    messages << "You haven't tagged any quotes!" if tags.empty?
    display_page :attribute_index, :attributes => tags, :kind => 'tag'
  end

  ######### end users #########

  ######### start publications #########

  get %r{/publication/([\d]+)} do |uid|
    show_quotes quotes_by_publication(uid)
  end

  get '/publication/new' do
    display_as_partial new_publication_template
  end

  get '/publication/edit/:uid' do
    display_page edit_publication_template,
      :form_page => true,
      :publication => publication_by_uid(uid)
  end

  post '/publication/edit/:uid' do
    result = update_publication
    redirect "/publication/#{uid}"
  end

  ######### end publications #########

  ######### start quotes #########

  get %r{/quote/([\d]+)} do |uid|
    show_quote quote_by_uid(uid)
  end

  get '/quotes' do
    show_quotes quotes
  end

  get '/similar_quotes/:uid' do
    show_quotes similar_quotes(uid)
  end

  get '/quote/new' do
    display_page new_quote_template,
      :form_page => true,
      :publications => publications,
      :tags => tags.uniq
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

  get '/edit_quote/:uid' do
    display_page edit_quote_template,
      :form_page => true,
      :quote => quote_by_uid(uid),
      :publications => publications,
      :tags => tags.uniq
  end

  post '/edit_quote/:uid' do
    result = update_quote
    redirect "/quote/#{uid}"
  end

  get '/delete_quote/:uid' do
    display_page :confirm_delete,
      :form_page => true,
      :quote => quote_by_uid(uid)
  end

  post '/delete_quote/:uid' do
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
    show_quotes quotes_by_tag(params[:tag])
  end

  get '/tags' do
    display_page :attribute_index,
      :attributes => build_attributes(tags),
      :kind => 'tag'
  end

  get '/author/:author' do
    show_quotes quotes_by_author(params[:author])
  end

  get '/authors' do
    display_page :attribute_index,
      :attributes => get_authors,
      :kind => 'author'
  end

  get '/toggle_star/:uid' do
    toggle_star(uid)
    nil
  end

end
