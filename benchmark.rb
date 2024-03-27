require 'benchmark/ips'
require 'open3'

ITERATIONS=50000

experiments = %w{
  weak-syms
  dlopen
}
experiment_commands = {}

experiments.each do |experiment|
  puts "=== BUILDING #{experiment.upcase}\n"
  system("make -C #{experiment} clean default CFLAGS=-DGC_TEST_ITERS=#{ITERATIONS}> /dev/null");

  env = case experiment
  when "dlopen"
    "RUBY_GC_PATH=#{__dir__}/#{experiment}/libgc.so"
  else
    "LD_PRELOAD=#{__dir__}/#{experiment}/libgc.so"
  end
  
  experiment_commands[experiment] = {
    default: "./#{experiment}/main",
    override: "#{env} ./#{experiment}/main",
  }
end

puts ""

experiment_commands.each_pair do |name, experiment|
  experiment.each_pair do |branch, command|
    puts "=== TESTING #{name}-#{branch}"
    stdout, status = Open3.capture2(command)

    unless stdout.match(/#{branch.to_s.capitalize}/)
      raise StandardError, <<~ERROR
        #{name}-#{branch} does not match expected output.
        \t command:\t\t#{command}
        \t actual:\t\t#{stdout}
        \t expected:\t\t#{branch.to_s.capitalize}
      ERROR
    end
  end
end

puts ""

Benchmark.ips do |x|
  experiment_commands.each_pair do |name, commands|
    commands.each_pair do |branch, experiment_command|
      x.report("#{name}-#{branch}") {
        system("#{experiment_command} > /dev/null")
      }
    end
  end
end
