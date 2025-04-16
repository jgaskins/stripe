# This file is used for defining Stripe::Webhook.handle_all

File.each_line "#{__DIR__}/src/webhook.cr" do |line|
  if match = line.match(/\s+define_enable (\w+)/)
    puts "Stripe::Webhook.enable_#{match[1]}"
  end
end

puts <<-CRYSTAL
  Stripe::Webhook.handle \{{::Stripe::Webhook.resolve.all_subclasses.reject(&.abstract?)}}
  CRYSTAL
