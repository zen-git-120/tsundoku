class BooksController < ApplicationController
  before_action :authenticate_user!

  def index
    per_page = 12
    books = current_user.books

    @total_pages = [ (books.count + per_page - 1) / per_page, 1 ].max

    page = params.fetch(:page, "1").to_s
    @current_page = page.match?(/\A[1-9]\d*\z/) ? page.to_i : 0

    unless @current_page.between?(1, @total_pages)
      redirect_to books_path, alert: "指定されたページはありません。本棚の最初のページを表示します。"
      return
    end

    @books = books.order(created_at: :desc, id: :desc)
                  .limit(per_page)
                  .offset((@current_page - 1) * per_page)
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
