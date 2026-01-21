class PostsController < ApplicationController
  before_action :set_post, only: %i[show edit update destroy enqueue_notifier]

  # Public actions
  def index
    @posts = Post.all
  end

  def show; end
  def new
    @post = Post.new
  end
  def create
    @post = Post.new(post_params)
    if @post.save
      redirect_to @post, notice: "Post created!"
    else
      render :new
    end
  end
  def edit; end

  def update
    if @post.update(post_params)
      redirect_to @post, notice: "Post updated!"
    else
      render :edit
    end
  end

  def destroy
    @post.destroy!
    redirect_to posts_path, notice: "Post destroyed!"
  end

  # Sidekiq job enqueue
  def enqueue_notifier
    PostNotifierJob.perform_later(@post.id)
    redirect_to posts_path, notice: "✅ Sidekiq job enqueued!"
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :body)
  end
end
