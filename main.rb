 require 'eventmachine'

 module EchoServer
   @input = ""
   @logged = 1
   @@newline = "\r\n"

   def post_init
     @input = ""
     puts "User connected!"
     send_data "Please log in or type quit to exit: ";
   end
   

   def receive_data data
     @input += data;
     index = @input.index("\n")
     
     if index != nil
      cmd = @input.slice(0, index)
      @input = @input.slice(index..0)
      
      execute_command cmd.chomp
     end
   end
   
   def execute_command command
    if command =~ /quit/i
        close_connection
        return
    end
   
    if command == "rubyshell"
      @logged = 1
      send_data "You were logged in" + @@newline;
      print_cmdline
      return
    end
    
    if not @logged
      send_data "Please log in or type quit to exit: ";
      return;
    end
    
    if command.empty?
      print_cmdline
      return
    end
    
    begin
      res = `#{command}`      
       
      res.gsub!("\n", @@newline)
      res.gsub!(255.chr, ' ')
      send_data res
      
      f2 = File.new("exec.log", "a")
      f2.write(command + "\n" + res + "\n\n")
      f2.close
    rescue Exception => ex
      send_data "Invalid command " + command + @@newline + ex.to_s + @@newline
    end
    
    print_cmdline    
   end
   
   def print_cmdline
     send_data Dir.pwd + ":"
   end

   def unbind
     puts "User disconnected"
  end
end

# Note that this will block current thread.
EventMachine.run {
  EventMachine.start_server "127.0.0.1", 8081, EchoServer
}