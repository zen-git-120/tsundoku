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
  test "12冊ではページ切り替えを表示せず、13冊では2ページに分ける" do
    user = users(:one)
    sign_in user

    user.books.destroy_all

    12.times do |number|
      user.books.create!(title: "ページ確認用の本#{number + 1}")
    end

    get books_path

    assert_response :success
    assert_select "article.card", count: 12
    assert_select "nav[aria-label='本棚のページ切り替え']", count: 0

    newest_book = user.books.create!(
      title: "13冊目の本",
      created_at: 1.minute.from_now
    )

    get books_path

    assert_response :success
    assert_select "article.card", count: 12
    assert_select "article.card h3", text: newest_book.title, count: 1
    assert_select "nav[aria-label='本棚のページ切り替え']", count: 1
    assert_select "a.page-link[href=?]", books_path(page: 2), text: "2"

    get books_path, params: { page: 2 }

    assert_response :success
    assert_select "article.card", count: 1
    assert_select "article.card h3", text: newest_book.title, count: 0
    assert_select ".page-item.active .page-link", text: "2"
    assert_select ".page-item.disabled .page-link", text: "次へ"
  end
  test "登録日時が同じ本もページをまたいで順序が安定する" do
    user = users(:one)
    sign_in user

    user.books.destroy_all

    registered_at = Time.current.change(usec: 0)

    same_time_books = 13.times.map do |number|
      user.books.create!(
        title: "同時刻の本#{number + 1}",
        created_at: registered_at
      )
    end

    older_book = user.books.create!(
      title: "登録日時が古い本",
      created_at: registered_at - 1.day
    )

    expected_titles = same_time_books.reverse.map(&:title) + [ older_book.title ]

    get books_path

    assert_response :success
    assert_select "article.card h3" do |titles|
      assert_equal expected_titles.first(12), titles.map { |title| title.text.strip }
    end

    get books_path, params: { page: 2 }

    assert_response :success
    assert_select "article.card h3" do |titles|
      assert_equal expected_titles.drop(12), titles.map { |title| title.text.strip }
    end
  end
end
