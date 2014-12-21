module Helpers
  module UseCaseCalling

    def build_search_results
      input = { :query => params[:search] }

      call_use_case(:search, input)
    end

    def build_publication
      call_use_case :create_publication,
        :user_uid => current_user_uid,
        :publication => {
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
        :user_uid => current_user_uid,
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
           :added_by => quote.added_by,
           :content => params[:content] || quote.content,
           :publication_uid => params[:publication].to_i || quote.publication_uid,
           :page_number => params[:pagenumber].to_i || quote.page_number,
           :links => params[:links] || quote.links,
           :tags => build_tags || quote.tags
        }
    end

    def update_publication
      call_use_case :update_publication,
        :user_uid => current_user_uid,
        :uid => uid,
        :updates => params
    end

    def delete_quote
      call_use_case :delete_quote,
        :user_uid => current_user_uid,
        :uid => uid
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

    def toggle_star(quote_uid)
      call_use_case :toggle_favorite,
        :uid => current_user_uid,
        :quote_uid => quote_uid.to_i
    end

    private

    def build_tags
      params[:tags].split(',').each(&:strip!) if params[:tags]
    end

    def call_use_case(use_case, args = nil)
      eval("Manager::Interface.#{use_case}(#{args})")
    end

  end
end
