require "test_helper"

class BooksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "削除に失敗した場合は本が残り、エラーが表示される" do
    user = users(:one)
    book = books(:one)
    sign_in user

    stop_destroy = proc { throw :abort }
    Book.set_callback(:destroy, :before, stop_destroy)

    begin
      assert_no_difference("Book.count") do
        delete book_path(book)
      end

      assert Book.exists?(book.id)
      assert_redirected_to books_path
      assert_equal "本を削除できませんでした", flash[:alert]
      assert_nil flash[:notice]

      follow_redirect!

      assert_response :success
      assert_select ".alert", text: "本を削除できませんでした"
    ensure
      Book.skip_callback(:destroy, :before, stop_destroy)
    end
  end
end
