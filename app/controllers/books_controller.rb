class BooksController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def new
    @book = current_user.books.build
  end
end
