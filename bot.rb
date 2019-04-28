# frozen_string_literal: true

require 'discordrb'
require 'json'
require 'net/http'
require 'open-uri'

bot = Discordrb::Commands::CommandBot.new(
  token: ENV['DISCORD_TOKEN'],
  client_id: ENV['DISCORD_CLIENT_ID'],
  prefix: '/'
)
ORIGIN = 'http://xxx.lvh.me'
API_ROOT = "#{ORIGIN}/api"

if ORIGIN == 'http://xxx.lvh.me'
  puts "\e[31mORIGIN: #{ORIGIN} を適切な値に書き換えてから実行して下さい\e[0m"
end

def request(path = '/')
  request_path = File.join(API_ROOT, path)
  url = URI.parse(request_path)
  res = Net::HTTP.get(url)

  JSON.parse(res, symbolize_names: true)
end

def make_tmpfile(path)
  uri = URI.parse(File.join(ORIGIN, path))
  tmp = Tempfile.new(['resume', '.png'])
  tmp.binmode
  uri.open do |f|
    tmp.write(f.read)
  end
  tmp.rewind
  tmp
end

bot.command :my_resume do |event|
  res = request "/resumes/image_path?uid=#{event.user.id}"
  tmpfile = make_tmpfile(res[:image_path])
  event.send_file(tmpfile)
  tmpfile.delete
  tmpfile.close
  nil # 最後の戻り値がメッセージとして送信されるため
end

bot.run
