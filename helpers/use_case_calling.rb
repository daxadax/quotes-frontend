require 'manager'

module Helpers
  module UseCaseCalling

    def build_search_results
      input = { :query => params['search'] }

      call_use_case :search, input
    end

    def build_publication
      call_use_case :create_publication,
        :user_uid => current_user_uid,
        :publication => symbolize_keys(params)
    end

    def build_quote
      if !params['publication_uid']
        result = build_publication
        return result if result.error
        params['publication_uid'] = result.uid
      else
        params['publication_uid'].to_i
      end

      params['tags'] = build_tags

      call_use_case :create_quote,
        :user_uid => current_user_uid,
        :quote => symbolize_keys(params)
    end

    def import_from_kindle
      file = File.read params[:file][:tempfile]

      call_use_case :import_from_kindle,
        :user_uid => current_user_uid,
        :file => file
    end

    def autotag
      call_use_case :autotag_quotes
    end

    def update_quote
      quote = quote_by_uid(uid)
      params['tags'] = build_tags

      call_use_case :update_quote,
        :user_uid => current_user.uid,
        :uid => uid,
        :updates => symbolize_keys(params)
    end

    def update_publication
      call_use_case :update_publication,
        :user_uid => current_user_uid,
        :uid => uid,
        :updates => symbolize_keys(params)
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
      result = call_use_case :get_user, :uid => uid
      return result.user unless result.error
    end

    def toggle_star(quote_uid)
      call_use_case :toggle_favorite,
        :uid => current_user_uid,
        :quote_uid => quote_uid.to_i
    end

    private

    def symbolize_keys(hash)
      hash.inject({}) do |result, (key, value)|
        new_key = key.is_a?(String) ? key.to_sym : key
        new_value = value.is_a?(Hash) ? symbolize_keys(value) : value

        result[new_key] = new_value
        result
      end
    end

    def build_tags
      params['tags'].split(',').each(&:strip!) if params['tags']
    end

    def call_use_case(use_case, args = nil)
      eval("Manager::Interface.#{use_case}(#{args})")
    end

  end
end
