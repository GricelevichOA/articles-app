class ArticlesController < ApplicationController
	protect_from_forgery except: :index
	before_action :set_article, only: [:show, :edit, :update, :destroy]

	def index
		@articles = Article.where("created_at >= ?", 1.week.ago.utc)

		respond_to do |format|
			format.html 
			format.js
		end
	end

	def show
		respond_to do |format|
			format.html 
			format.js
		end
	end

	def new
		@article = Article.new
	end

	def create
		@article = Article.new(article_params)
		if @article.save
			redirect_to articles_url, notice: 'Article was successfully created.'
			ActionCable.server.broadcast 'activity_channel', content: "Created article: #{@article.title}"
		else
			render :new
		end
	end

	def edit
	end

	def update
		if @article.update(article_params)
			ActionCable.server.broadcast 'activity_channel', content: "Edited article: #{@article.title}"
			redirect_to articles_url, notice: 'Article was successfully updated.'
		else
			render :edit
		end
	end

	def destroy
		@article.destroy
		redirect_to articles_url, notice: 'Article was successfully destroyed.'
		ActionCable.server.broadcast 'activity_channel', content: "Deleted article: #{@article.title}"
	end

	private

	def set_article
		@article = Article.find(params[:id])
	end

	def article_params
		params.require(:article).permit(:title, :body)
	end
end
