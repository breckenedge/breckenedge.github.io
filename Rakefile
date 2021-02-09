task :new_post, :title do |t, args|
  require "time"

  new_post_filename = "#{Time.now.strftime("%Y-%m-%d")}-#{args[:title].gsub(' ', '_')}.markdown"

  File.open("_posts/#{new_post_filename}", "w") do |f|
    f.write(<<~HEADER)
      ---
      layout: post
      title: #{args[:title]}
      date: #{Time.now.iso8601}
      categories:
      ---
    HEADER
  end
end
