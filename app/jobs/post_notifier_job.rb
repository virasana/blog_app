class PostNotifierJob < ApplicationJob
  queue_as :default

  def perform(post_id)
    post = Post.find(post_id)
    Rails.logger.debug "🎉 Sidekiq Job: Post '#{post.title}' triggered from the UI!"
  end
end
