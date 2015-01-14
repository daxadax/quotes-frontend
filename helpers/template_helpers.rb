module Helpers
  module TemplateHelpers

    def show_quote(quote)
      display_page quote_template, :quote => quote
    end

    def show_quotes(quotes)
      display_page quotes_template, :quotes => quotes
    end

    def registration_template
      'users/register'
    end

    def login_template
      'users/login'
    end

    def user_partial
      '/users/user'
    end

    def publications_template
      'publications/index'
    end

    def new_publication_template
      'publications/new'
    end

    def edit_publication_template
      'publications/edit'
    end

    def publication_partial
      'publications/publication'
    end

    def quotes_template
      'quotes/index'
    end

    def quote_template
      'quotes/show'
    end

    def new_quote_template
      'quotes/new'
    end

    def edit_quote_template
      'quotes/edit'
    end

    def remove_quote_template
      'quotes/remove'
    end

    def quote_partial
      'quotes/quote'
    end

  end
end
