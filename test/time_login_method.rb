require 'SecureRandom'

def time_in_ms
  Time.new.to_f * 1000
end

def print_time(ms)
  '%.2f' % ms
end

def register_account(email, password)
  `curl -H "Content-Type: application/json" --url 'http://localhost:9393/users' --data '{"user": {"email":"#{email}", "password":"#{password}"}}' >/dev/null 2>&1`
end

def login(email, password)
  `curl -H "Content-Type: application/json" --url 'http://localhost:9393/sessions' --data '{"user": {"email":"#{email}", "password":"#{password}"}}' >/dev/null 2>&1`
end

def time_function(iterations)
  start_time = time_in_ms
  (0...iterations).each { yield }
  end_time = time_in_ms

  puts "iterations = " + iterations.to_s
  puts "average = #{print_time((end_time-start_time)/iterations)} ms"
  puts "total =  #{print_time(end_time-start_time)} ms"
end

iterations = 100
valid_email = "#{SecureRandom.uuid}@example.com"
register_account(valid_email, 'Password1')

puts 
puts "Invalid email address"
puts '---------------------'
time_function(iterations) { login('bad_email', 'password_doesnt_matter') }
  
puts 
puts "Valid email address"
puts '-------------------'
time_function(iterations) { login(valid_email, 'password_doesnt_matter') }

