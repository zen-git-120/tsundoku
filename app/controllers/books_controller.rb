class BooksController < ApplicationController
  before_action :authenticate_user!

  def index
    @books = current_user.books.order(created_at: :desc)
  end

  def new
    @book = current_user.books.build
  end

  def create
    @book = current_user.books.build(book_params)

    if @book.save
      redirect_to books_path,
                  notice: "本を登録しました",
                  status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def book_params
    params.require(:book).permit(:title, :status)
  end
end
