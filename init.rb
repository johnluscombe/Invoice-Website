USAGE = <<DOC

################################### COMMAND LINE USAGE ###################################

General usage format:   ruby init.rb <option>
Where:
  option                Required. One of the options listed below.
  e.g.:                 ruby init.rb start

Options:                start, stop, kill, reload, restart, status, help
Where:
  start                 Starts a daemonized rails server using the 'rails s -d' command.
  stop                  Sends a SIGHUP command to stop the rails server.
  kill                  Sends a SIGKILL command to stop the rails server.
  reload                Restarts the server by sending a SIGHUP command to stop the rails
                        server, then starts it again.
  restart               Restarts the server by sending a SIGKILL command to stop the
                        rails server, then starts it again.
  status                Prints whether or not the server is started. If the server is
                        started, also prints out the PID.
  help                  Shows the command line usage.

##########################################################################################

DOC

if ARGV.length == 0
  puts USAGE
else
  case ARGV[0]
    when 'start'
      system('rails s -d')
    when 'stop'
      begin
        file = File.open('tmp/pids/server.pid', 'r')
        pid = file.each_line.to_a[0]
        Process.kill 1, pid.to_i
      rescue Errno::ESRCH, Errno::ENOENT
        puts 'Server is not running'
      end
    when 'kill'
      begin
        file = File.open('tmp/pids/server.pid', 'r')
        pid = file.each_line.to_a[0]
        Process.kill 9, pid.to_i
      rescue Errno::ESRCH, Errno::ENOENT
        puts 'Server is not running'
      end
    when 'reload'
      begin
        file = File.open('tmp/pids/server.pid', 'r')
        pid = file.each_line.to_a[0]
        Process.kill 1, pid.to_i
      rescue Errno::ESRCH, Errno::ENOENT
        nil
      end
      system('rails s -d')
    when 'restart'
      begin
        file = File.open('tmp/pids/server.pid', 'r')
        pid = file.each_line.to_a[0]
        Process.kill 9, pid.to_i
      rescue Errno::ESRCH, Errno::ENOENT
        nil
      end
      system('rails s -d')
    when 'status'
      begin
        file = File.open('tmp/pids/server.pid', 'r')
        pid = file.each_line.to_a[0]
        Process.kill 0, pid.to_i
        puts 'Server is UP under PID: ' + pid
      rescue Errno::ESRCH, Errno::ENOENT
        puts 'Server is DOWN'
      end
    when 'help'
      puts USAGE
    else
      puts 'Unknown command: ' + ARGV[0]
  end
end