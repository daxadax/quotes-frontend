require 'test_helper'

class ImportFromKindleTest < QuotesAppTest

  let(:route) { '/import_from_kindle' }
  let(:file) { './test/support/kindle_clippings.txt' }

  it 'returns to the import page with an error if no file was added' do
    visit route
    attach_file 'file', nil
    click_button 'submit'

    assert_equal route, current_path
    assert_includes page.body, "Nothing was uploaded"
  end

  describe 'with a file attached' do
    before do
      visit route
      attach_file 'file', file
      click_button 'submit'
    end

    describe 'with an invalid clippings file' do
      let(:file) { './test/support/non_kindle_file' }

      it 'returns to the import page with an error' do
        assert_includes page.body, "Not a valid kindle clippings file"
        assert_equal route, current_path
      end
    end

    it 'imports the quotes in the clippings file' do
      assert_includes page.body, "Import successful"
      # this should pass.  https://github.com/jnicklas/capybara/issues/1460
      # assert_equal '/kindle_import_review', current_path
    end

    describe 'duplicates' do
      before do
        page.driver.post route,
          :file => { :tempfile => file }
      end

      it 'displays duplicates if they are returned' do
        assert_includes page.body, "Import successful"
        assert_includes page.body, "Possible duplicate quotes"
        # this should pass. https://github.com/jnicklas/capybara/issues/1460
        # assert_equal '/kindle_import_review', current_path
      end

      it 'allows possible duplicates to be reviewed and saved or discarded' do
        assert page.has_css?('.add-duplicate-quote'), 'missing css class'
        assert page.has_css?('.remove-duplicate-quote'), 'missing css class'
      end
    end

  end

end
