worker_processes {{ getenv "UNICORN_WORKER_PROCESSES" "4" }}

user "{{ getenv "UNICORN_USER" "www-data" }}", "{{ getenv "UNICORN_GROUP" "www-data" }}"

working_directory "{{ getenv "UNICORN_WORKING_DIRECTORY" "/usr/src/app" }}"

listen "/path/to/.unicorn.sock", :backlog => 64
listen 8080, :tcp_nopush => true

timeout {{ getenv "UNICORN_TIMEOUT" "30" }}

stderr_path "/proc/self/fd/2"
stdout_path "/proc/self/fd/1"

preload_app {{ getenv "UNICORN_PRELOAD_APP" "true" }}

check_client_connection {{ getenv "UNICORN_CHECK_CLIENT_CONNECTION" "false" }}

run_once = {{ getenv "UNICORN_RUN_ONCE" "true" }}

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!

  if run_once
    run_once = false
  end
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end