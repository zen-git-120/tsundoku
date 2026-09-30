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

  def edit
    @book = current_user.books.find(params[:id])
  end

  def update
    @book = current_user.books.find(params[:id])

    if @book.update(book_params)
      redirect_to books_path,
                  notice: "本を更新しました",
                  status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @book = current_user.books.find(params[:id])

    if @book.destroy
      redirect_to books_path,
                  notice: "本を削除しました",
                  status: :see_other

    else
      redirect_to books_path,
                  alert: "本を削除できませんでした",
                  status: :see_other
    end
  end

  private

  def book_params
    params.require(:book).permit(:title, :status)
  end
end
